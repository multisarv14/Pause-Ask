import { getFirestore } from "firebase-admin/firestore";

const db = () => getFirestore();

export const refs = {
  user: (uid: string) => db().doc(`users/${uid}`),
  /** Server-only index: which circle a user is in (max 1). */
  membership: (uid: string) => db().doc(`memberships/${uid}`),
  circles: () => db().collection("circles"),
  circle: (circleId: string) => db().doc(`circles/${circleId}`),
  members: (circleId: string) => db().collection(`circles/${circleId}/members`),
  member: (circleId: string, uid: string) =>
    db().doc(`circles/${circleId}/members/${uid}`),
  invites: () => db().collection("invites"),
  invite: (code: string) => db().doc(`invites/${code}`),
  checks: () => db().collection("checks"),
  /** Server-only: AI checks used per user per IST day. */
  usage: (uid: string, yyyymmdd: string) => db().doc(`usage/${uid}_${yyyymmdd}`),
  /** Server-only: SOS rate limit. */
  sosUsage: (uid: string) => db().doc(`sosUsage/${uid}`),
  /** Server-only: wrong join codes per user (rate limit). */
  joinAttempts: (uid: string) => db().doc(`joinAttempts/${uid}`),
};
