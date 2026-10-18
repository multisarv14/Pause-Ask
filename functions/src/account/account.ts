import "../setup";

import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import { leaveCircleFor } from "../circles/circles";
import { requireUid } from "../lib/auth";
import { callable } from "../lib/callable";
import { fail, isReason } from "../lib/errors";
import { loadRecipients, sendPushes } from "../lib/push";
import { consumeRate } from "../lib/rateLimit";
import { refs } from "../lib/refs";
import { parse, schemas } from "../lib/validation";
import { testAlertText } from "../notifications/texts";

/** Deletes every doc a query returns, 400 at a time. */
async function deleteQuery(q: FirebaseFirestore.Query): Promise<number> {
  let total = 0;
  for (;;) {
    const snap = await q.limit(400).get();
    if (snap.empty) return total;
    const batch = getFirestore().batch();
    snap.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();
    total += snap.size;
  }
}

/**
 * deleteMyAccount() → { deleted: true }
 * Play Store / DPDP: removes the user's profile, checks, usage counters and
 * circle membership (ownership passes to the oldest member; an empty circle
 * is deleted), anonymises their name on replies they gave to others, and
 * finally deletes the Firebase Auth user. Safe to call again if it fails
 * half-way.
 */
export const deleteMyAccount = callable(async (req) => {
  const uid = requireUid(req);
  const db = getFirestore();

  try {
    await leaveCircleFor(uid);
  } catch (e) {
    if (!isReason(e, "NOT_IN_CIRCLE")) throw e;
  }

  const checks = await deleteQuery(db.collection("checks").where("uid", "==", uid));
  const usage = await deleteQuery(db.collection("usage").where("uid", "==", uid));

  // Replies this user gave on family members' checks keep the decision
  // but lose the name.
  const replied = await db
    .collection("checks")
    .where("guardianResponse.byUid", "==", uid)
    .get();
  await Promise.all(
    replied.docs.map((d) =>
      d.ref.update({ "guardianResponse.byName": "", "guardianResponse.byUid": "" }),
    ),
  );

  await Promise.all([
    refs.sosUsage(uid).delete(),
    getFirestore().doc(`rateLimits/${uid}_testAlert`).delete(),
    refs.joinAttempts(uid).delete(),
    refs.membership(uid).delete(),
    refs.user(uid).delete(),
  ]);
  try {
    await getAuth().deleteUser(uid);
  } catch (e) {
    if ((e as { code?: string }).code !== "auth/user-not-found") throw e;
  }
  logger.info("account deleted", { uid, checks, usage, replies: replied.size });
  return { deleted: true };
});

/**
 * updateRoles({ roles }) → { roles }. Keeps users/{uid}.roles and the circle
 * member copy (used for guardian alerts) in sync, so clients can't edit
 * roles directly.
 */
export const updateRoles = callable(async (req) => {
  const uid = requireUid(req);
  const { roles } = parse(schemas.updateRoles, req.data);
  const ordered = ["protected", "guardian"].filter((r) => (roles as string[]).includes(r));
  if (!(await refs.user(uid).get()).exists) fail("PROFILE_MISSING");
  await refs.user(uid).update({ roles: ordered });
  const circleId = (await refs.membership(uid).get()).data()?.circleId as string | undefined;
  if (circleId) await refs.member(circleId, uid).update({ roles: ordered });
  return { roles: ordered };
});

/** sendTestAlert() → { sent }. A push to my own phone on the alerts channel. */
export const sendTestAlert = callable(async (req) => {
  const uid = requireUid(req);
  await consumeRate(uid, "testAlert", 5, 60 * 60 * 1000);
  const [me] = await loadRecipients([uid]);
  if (!me?.token) return { sent: false };
  const sent = await sendPushes(
    [{ uid, ...testAlertText(me.language), data: { type: "test" }, channel: "alerts" }],
    new Map([[uid, me.token]]),
  );
  return { sent: sent > 0 };
});
