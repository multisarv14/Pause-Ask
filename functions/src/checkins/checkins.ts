import "../setup";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { requireUid } from "../lib/auth";
import { callable } from "../lib/callable";
import { fail } from "../lib/errors";
import { Push, loadRecipients, sendPushes } from "../lib/push";
import { refs } from "../lib/refs";
import { parse, schemas } from "../lib/validation";
import { isValidTimeZone } from "../lib/zonedTime";
import { missedCheckinText } from "../notifications/texts";
import { CheckinSettings, dueMissedDay } from "./missed";

const ms = (v: unknown): number | null =>
  v instanceof Timestamp ? v.toMillis() : typeof v === "number" ? v : null;

/** users/{uid}.checkin (Timestamps) → plain settings. */
export function toSettings(raw: FirebaseFirestore.DocumentData | undefined): CheckinSettings | null {
  if (!raw || typeof raw.time !== "string" || !isValidTimeZone(raw.timezone)) return null;
  return {
    enabled: raw.enabled === true,
    time: raw.time,
    alertAfterHours: Number(raw.alertAfterHours) || 12,
    timezone: raw.timezone,
    lastCheckinAt: ms(raw.lastCheckinAt),
    lastMissedAlertDate: typeof raw.lastMissedAlertDate === "string" ? raw.lastMissedAlertDate : null,
    updatedAt: ms(raw.updatedAt),
  };
}

/**
 * Copies the check-in status to the user's circle member doc so guardians
 * (who can't read users/{uid}) can show 🟢 / ⚪ / 🔴.
 */
export async function syncMemberCheckin(uid: string): Promise<void> {
  const [membership, user] = await Promise.all([refs.membership(uid).get(), refs.user(uid).get()]);
  const circleId = membership.data()?.circleId as string | undefined;
  const c = user.data()?.checkin;
  if (!circleId || !c) return;
  await refs.member(circleId, uid).update({
    checkin: {
      enabled: c.enabled === true,
      time: c.time ?? null,
      timezone: c.timezone ?? null,
      alertAfterHours: c.alertAfterHours ?? null,
      lastCheckinAt: c.lastCheckinAt ?? null,
      lastMissedAlertDate: c.lastMissedAlertDate ?? null,
    },
  }).catch(() => undefined); // member doc may be gone (left circle)
}

/** "I'm OK": the reminder tap, opening the app, or running a check. */
export async function recordCheckin(uid: string): Promise<Timestamp> {
  const now = Timestamp.now();
  await refs.user(uid).update({ "checkin.lastCheckinAt": now });
  await syncMemberCheckin(uid);
  return now;
}

/** checkIn() → { lastCheckinAt (ms) } */
export const checkIn = callable(async (req) => {
  const uid = requireUid(req);
  if (!(await refs.user(uid).get()).exists) fail("PROFILE_MISSING");
  const at = await recordCheckin(uid);
  return { lastCheckinAt: at.toMillis() };
});

/**
 * saveCheckinSettings({ enabled, time "HH:MM", alertAfterHours 1–24, timezone })
 * Changes apply to missed alerts from the next day.
 */
export const saveCheckinSettings = callable(async (req) => {
  const uid = requireUid(req);
  const d = parse(schemas.saveCheckinSettings, req.data, "INVALID_SETTINGS");
  const hours = d.alertAfterHours;
  const userRef = refs.user(uid);
  if (!(await userRef.get()).exists) fail("PROFILE_MISSING");
  await userRef.update({
    "checkin.enabled": d.enabled,
    "checkin.time": d.time,
    "checkin.alertAfterHours": hours,
    "checkin.timezone": d.timezone,
    "checkin.updatedAt": FieldValue.serverTimestamp(),
  });
  await syncMemberCheckin(uid);
  return { saved: true };
});

/**
 * Sends at most one gentle "hasn't checked in" push per user per local day
 * to the guardians of their circle. Returns how many users were alerted.
 */
export async function runCheckinSweep(now = Date.now()): Promise<number> {
  const users = await getFirestore().collection("users").where("checkin.enabled", "==", true).get();
  let alerted = 0;
  for (const userDoc of users.docs) {
    const uid = userDoc.id;
    const settings = toSettings(userDoc.data().checkin);
    if (!settings) continue;
    const day = dueMissedDay(now, settings);
    if (!day) continue;

    const circleId = (await refs.membership(uid).get()).data()?.circleId as string | undefined;
    if (!circleId) continue;

    // Claim the day first so overlapping runs can't alert twice.
    const claimed = await getFirestore().runTransaction(async (tx) => {
      const fresh = toSettings((await tx.get(userDoc.ref)).data()?.checkin);
      if (!fresh || dueMissedDay(now, fresh) !== day) return false;
      tx.update(userDoc.ref, { "checkin.lastMissedAlertDate": day });
      return true;
    });
    if (!claimed) continue;

    const members = await refs.members(circleId).get();
    const name = members.docs.find((m) => m.id === uid)?.data().name ?? "";
    const guardianUids = members.docs
      .filter((m) => m.id !== uid && Array.isArray(m.data().roles) && m.data().roles.includes("guardian"))
      .map((m) => m.id);
    const recipients = await loadRecipients(guardianUids);
    const pushes: Push[] = recipients.map((r) => ({
      uid: r.uid,
      ...missedCheckinText(r.language, name),
      data: { type: "missed_checkin", uid, name, day },
      channel: "general",
    }));
    await sendPushes(
      pushes,
      new Map(recipients.filter((r) => r.token).map((r) => [r.uid, r.token as string])),
    );
    await syncMemberCheckin(uid);
    alerted++;
  }
  logger.info("check-in sweep", { users: users.size, alerted });
  return alerted;
}

/** Every 30 minutes (Cloud Scheduler). */
export const checkMissedCheckins = onSchedule(
  { schedule: "every 30 minutes", timeZone: "Asia/Kolkata" },
  async () => {
    await runCheckinSweep();
  },
);
