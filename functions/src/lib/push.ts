import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";
import { defineString } from "firebase-functions/params";

import { refs } from "./refs";

/** "fcm" (default) or "log" (emulator only: writes to _pushLog for tests). */
export const PUSH_MODE = defineString("PUSH_MODE", { default: "fcm" });

export type PushChannel = "alerts" | "general";

export interface Push {
  uid: string;
  title: string;
  body: string;
  /** Never put message text here: only ids, names and levels. */
  data: Record<string, string>;
  channel: PushChannel;
}

export interface Recipient {
  uid: string;
  token: string | null;
  language: string;
}

/** fcmToken + language for each uid (missing users are skipped). */
export async function loadRecipients(uids: string[]): Promise<Recipient[]> {
  if (uids.length === 0) return [];
  const snaps = await getFirestore().getAll(...uids.map((u) => refs.user(u)));
  return snaps
    .filter((s) => s.exists)
    .map((s) => ({
      uid: s.id,
      token: typeof s.data()!.fcmToken === "string" ? s.data()!.fcmToken : null,
      language: typeof s.data()!.language === "string" ? s.data()!.language : "en",
    }));
}

/**
 * Sends pushes; returns how many were delivered to FCM. Tokens FCM reports
 * as dead are removed from users/{uid}.
 */
export async function sendPushes(pushes: Push[], tokens: Map<string, string>): Promise<number> {
  const deliverable = pushes.filter((p) => tokens.has(p.uid));
  if (deliverable.length === 0) return 0;

  if (PUSH_MODE.value() === "log") {
    if (process.env.FUNCTIONS_EMULATOR !== "true") {
      throw new Error("PUSH_MODE=log is only allowed in the emulator");
    }
    const batch = getFirestore().batch();
    for (const p of deliverable) {
      batch.set(getFirestore().collection("_pushLog").doc(), {
        ...p,
        token: tokens.get(p.uid),
        at: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return deliverable.length;
  }

  const response = await getMessaging().sendEach(
    deliverable.map((p) => ({
      // users/{uid}.fcmToken stores the app's Firebase Installation ID.
      fid: tokens.get(p.uid)!,
      notification: { title: p.title, body: p.body },
      data: p.data,
      android: {
        priority: "high" as const,
        notification: { channelId: p.channel, defaultSound: true },
      },
      apns: { payload: { aps: { sound: "default" } } },
    })),
  );

  const dead: string[] = [];
  response.responses.forEach((r, i) => {
    const code = r.error?.code;
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      dead.push(deliverable[i].uid);
    } else if (r.error) {
      logger.warn("push failed", { uid: deliverable[i].uid, code });
    }
  });
  await Promise.all(
    dead.map((uid) => refs.user(uid).update({ fcmToken: null }).catch(() => undefined)),
  );
  return response.successCount;
}
