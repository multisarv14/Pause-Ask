import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";

import { Reason, fail } from "./errors";

/**
 * Fixed-window limiter in rateLimits/{uid}_{key}: at most [limit] calls per
 * [windowMs]. Throws HttpsError [reason] when exceeded.
 */
export async function consumeRate(
  uid: string,
  key: string,
  limit: number,
  windowMs: number,
  reason: Reason = "TOO_MANY_REQUESTS",
): Promise<void> {
  const ref = getFirestore().doc(`rateLimits/${uid}_${key}`);
  await getFirestore().runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data();
    const start = (d?.windowStart as Timestamp | undefined)?.toMillis() ?? 0;
    if (Date.now() - start >= windowMs) {
      tx.set(ref, { uid, count: 1, windowStart: Timestamp.now() });
      return;
    }
    if ((d?.count ?? 0) >= limit) fail(reason);
    tx.update(ref, { count: FieldValue.increment(1) });
  });
}
