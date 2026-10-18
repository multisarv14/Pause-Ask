import "../setup";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

import { requireUid } from "../lib/auth";
import { callable } from "../lib/callable";
import { fail } from "../lib/errors";
import { Push, loadRecipients, sendPushes } from "../lib/push";
import { refs } from "../lib/refs";
import { parse, schemas } from "../lib/validation";
import {
  ResponseType,
  answeredInfoText,
  checkAlertText,
  responseText,
} from "../notifications/texts";

interface MemberInfo {
  uid: string;
  name: string;
  isGuardian: boolean;
}

async function circleMembers(circleId: string): Promise<MemberInfo[]> {
  const snap = await refs.members(circleId).get();
  return snap.docs.map((d) => ({
    uid: d.id,
    name: typeof d.data().name === "string" ? d.data().name : "",
    isGuardian: Array.isArray(d.data().roles) && d.data().roles.includes("guardian"),
  }));
}

function tokenMap(recipients: { uid: string; token: string | null }[]) {
  return new Map(
    recipients.filter((r) => r.token).map((r) => [r.uid, r.token as string]),
  );
}

/**
 * New check → push every OTHER guardian in the circle, in their language.
 * The push has checkId, name and riskLevel only — never the message text.
 * Records `alert: {guardianCount, sentCount, at}` on the check for the UI.
 */
export const onCheckCreated = onDocumentCreated("checks/{checkId}", async (event) => {
  const check = event.data?.data();
  if (!check) return;
  const checkId = event.params.checkId;
  const circleId = check.circleId as string | null;

  let guardianCount = 0;
  let sentCount = 0;
  if (circleId) {
    const members = await circleMembers(circleId);
    const me = members.find((m) => m.uid === check.uid);
    const guardians = members.filter((m) => m.isGuardian && m.uid !== check.uid);
    guardianCount = guardians.length;

    const recipients = await loadRecipients(guardians.map((g) => g.uid));
    const name = me?.name ?? "";
    const riskLevel = String(check.result?.riskLevel ?? "BE_CAREFUL");
    const pushes: Push[] = recipients.map((r) => ({
      uid: r.uid,
      ...checkAlertText(r.language, name, riskLevel),
      data: { type: "check_alert", checkId, riskLevel, fromName: name },
      channel: "alerts",
    }));
    sentCount = await sendPushes(pushes, tokenMap(recipients));
  }

  await event.data!.ref.update({
    alert: { guardianCount, sentCount, at: FieldValue.serverTimestamp() },
  });
  logger.info("check alert", { checkId, circle: Boolean(circleId), guardianCount, sentCount });
});

/**
 * respondToCheck({ checkId, type: "STOP" | "OK" | "CALL" })
 *   → { accepted, response: {byUid, byName, type, at} }
 * Only guardians in the check's circle (not the asker). First reply wins;
 * later replies get accepted=false with the winning response.
 */
export const respondToCheck = callable(async (req) => {
  const uid = requireUid(req);
  const { checkId, type } = parse(schemas.respondToCheck, req.data);

  const checkRef = refs.checks().doc(checkId);
  const outcome = await getFirestore().runTransaction(async (tx) => {
    const checkSnap = await tx.get(checkRef);
    if (!checkSnap.exists) fail("CHECK_NOT_FOUND");
    const check = checkSnap.data()!;
    const circleId = check.circleId as string | null;
    if (!circleId || check.uid === uid) fail("NOT_GUARDIAN");

    const memberSnap = await tx.get(refs.member(circleId, uid));
    const member = memberSnap.data();
    if (!member || !Array.isArray(member.roles) || !member.roles.includes("guardian")) {
      fail("NOT_GUARDIAN");
    }

    if (check.guardianResponse) {
      return { accepted: false, response: check.guardianResponse, check };
    }
    const response = {
      byUid: uid,
      byName: typeof member.name === "string" ? member.name : "",
      type,
      at: Timestamp.now(),
    };
    tx.update(checkRef, { guardianResponse: response });
    return { accepted: true, response, check };
  });

  const { accepted, response, check } = outcome;
  if (accepted) {
    await notifyAfterResponse(check, checkId, response).catch((e) =>
      logger.warn("response push failed", { checkId, error: (e as Error).name }),
    );
  }
  return {
    accepted,
    response: { ...response, at: (response.at as Timestamp).toMillis() },
  };
});

async function notifyAfterResponse(
  check: FirebaseFirestore.DocumentData,
  checkId: string,
  response: { byUid: string; byName: string; type: ResponseType },
) {
  const members = await circleMembers(check.circleId);
  const askerName = members.find((m) => m.uid === check.uid)?.name ?? "";
  const otherGuardians = members.filter(
    (m) => m.isGuardian && m.uid !== check.uid && m.uid !== response.byUid,
  );
  const recipients = await loadRecipients([check.uid, ...otherGuardians.map((g) => g.uid)]);

  const pushes = recipients.map((r): Push =>
    r.uid === check.uid
      ? {
          uid: r.uid,
          ...responseText(r.language, response.type, response.byName),
          data: {
            type: "guardian_response",
            checkId,
            responseType: response.type,
            byName: response.byName,
          },
          channel: "alerts",
        }
      : {
          uid: r.uid,
          ...answeredInfoText(r.language, response.byName, askerName),
          data: { type: "check_answered", checkId, byName: response.byName },
          channel: "general",
        },
  );
  await sendPushes(pushes, tokenMap(recipients));
}
