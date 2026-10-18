import "../setup";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { countryFromPhone, feedMatchesCountry } from "../lib/country";
import { Push, sendPushes } from "../lib/push";
import { newFeedItemText } from "../notifications/texts";

const WEEK_MS = 7 * 86_400_000;

type Localized = Record<string, string>;
const pick = (m: Localized | undefined, lang: string) => m?.[lang] || m?.en || "";

/**
 * Pushes the newest active feed item from the last 7 days that was never
 * pushed, to every user whose country it targets, in their language.
 * One item per run; the schedule runs twice a week → max 2 pushes a week.
 * Returns the pushed item id, or null.
 */
export async function runFeedPush(now = Date.now()): Promise<string | null> {
  const db = getFirestore();
  const recent = await db
    .collection("scamFeed")
    .where("active", "==", true)
    .where("publishedAt", ">=", Timestamp.fromMillis(now - WEEK_MS))
    .orderBy("publishedAt", "desc")
    .get();
  const item = recent.docs.find((d) => !d.data().pushedAt && d.data().publishedAt.toMillis() <= now);
  if (!item) return null;

  // Claim it first so two runs can't push the same item.
  const claimed = await db.runTransaction(async (tx) => {
    const fresh = await tx.get(item.ref);
    if (fresh.data()?.pushedAt) return false;
    tx.update(item.ref, { pushedAt: FieldValue.serverTimestamp() });
    return true;
  });
  if (!claimed) return null;

  const data = item.data();
  const users = await db.collection("users").where("fcmToken", "!=", null).get();
  const tokens = new Map<string, string>();
  const pushes: Push[] = [];
  for (const u of users.docs) {
    const d = u.data();
    if (typeof d.fcmToken !== "string") continue;
    if (!feedMatchesCountry(data.countryCodes, countryFromPhone(d.phone))) continue;
    const lang = typeof d.language === "string" ? d.language : "en";
    tokens.set(u.id, d.fcmToken);
    pushes.push({
      uid: u.id,
      ...newFeedItemText(lang, pick(data.title, lang)),
      data: { type: "feed", feedId: item.id },
      channel: "general",
    });
  }
  // FCM accepts up to 500 messages per call.
  let sent = 0;
  for (let i = 0; i < pushes.length; i += 500) {
    sent += await sendPushes(pushes.slice(i, i + 500), tokens);
  }
  logger.info("feed push", { feedId: item.id, recipients: pushes.length, sent });
  return item.id;
}

/** Mondays and Thursdays, 10:00 IST. */
export const weeklyFeedPush = onSchedule(
  { schedule: "0 10 * * 1,4", timeZone: "Asia/Kolkata" },
  async () => {
    await runFeedPush();
  },
);
