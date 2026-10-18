import "../setup";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import { recordCheckin } from "../checkins/checkins";
import { LIMITS } from "../config";
import { requireUid } from "../lib/auth";
import { callable } from "../lib/callable";
import { fail } from "../lib/errors";
import { Push, loadRecipients, sendPushes } from "../lib/push";
import { refs } from "../lib/refs";
import { sosText } from "../notifications/texts";

const HOUR_MS = 3_600_000;

async function consumeSos(uid: string) {
  const ref = refs.sosUsage(uid);
  await getFirestore().runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data();
    const start = (d?.windowStart as Timestamp | undefined)?.toMillis() ?? 0;
    if (Date.now() - start >= HOUR_MS) {
      tx.set(ref, { count: 1, windowStart: Timestamp.now() });
      return;
    }
    if ((d?.count ?? 0) >= LIMITS.sosPerHour) fail("SOS_LIMIT");
    tx.update(ref, { count: FieldValue.increment(1) });
  });
}

/**
 * sendSos() → { guardianCount, sentCount, firstGuardian: {uid, name, phone} | null }
 * Urgent push (alerts channel) to every guardian in the circle.
 * Limited to LIMITS.sosPerHour per user.
 */
export const sendSos = callable(async (req) => {
  const uid = requireUid(req);
  await consumeSos(uid);

  const circleId = (await refs.membership(uid).get()).data()?.circleId as string | undefined;
  if (!circleId) {
    logger.info("sos", { uid, circle: false });
    return { guardianCount: 0, sentCount: 0, firstGuardian: null };
  }

  const members = await refs.members(circleId).orderBy("joinedAt").get();
  const me = members.docs.find((m) => m.id === uid)?.data();
  const guardians = members.docs.filter(
    (m) => m.id !== uid && Array.isArray(m.data().roles) && m.data().roles.includes("guardian"),
  );
  const name = (me?.name as string | undefined) ?? "";
  const recipients = await loadRecipients(guardians.map((g) => g.id));
  const pushes: Push[] = recipients.map((r) => ({
    uid: r.uid,
    ...sosText(r.language, name),
    data: { type: "sos", fromUid: uid, fromName: name },
    channel: "alerts",
  }));
  const sentCount = await sendPushes(
    pushes,
    new Map(recipients.filter((r) => r.token).map((r) => [r.uid, r.token as string])),
  );
  // Pressing SOS also shows the family the person is reachable.
  await recordCheckin(uid).catch(() => undefined);

  const first = guardians[0];
  logger.info("sos", { uid, circle: true, guardianCount: guardians.length, sentCount });
  return {
    guardianCount: guardians.length,
    sentCount,
    firstGuardian: first
      ? { uid: first.id, name: first.data().name ?? "", phone: first.data().phone ?? "" }
      : null,
  };
});
