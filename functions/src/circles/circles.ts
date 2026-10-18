import "../setup";

import {
  DocumentReference,
  FieldValue,
  QueryDocumentSnapshot,
  Timestamp,
  Transaction,
  getFirestore,
} from "firebase-admin/firestore";

import { LIMITS } from "../config";
import { requireUid } from "../lib/auth";
import { callable } from "../lib/callable";
import { fail, isReason } from "../lib/errors";
import { generateInviteCode, normalizeInviteCode } from "../lib/inviteCode";
import { refs } from "../lib/refs";
import { parse, schemas } from "../lib/validation";

const HOUR_MS = 60 * 60 * 1000;
const DAY_MS = 24 * HOUR_MS;

/**
 * The member doc copies name, roles and phone from users/{uid}. Phone is
 * shared inside the circle so a guardian can tap "Call now".
 */
async function readProfile(tx: Transaction, uid: string) {
  const snap = await tx.get(refs.user(uid));
  if (!snap.exists) fail("PROFILE_MISSING");
  const data = snap.data()!;
  return {
    name: typeof data.name === "string" ? data.name : "",
    roles: Array.isArray(data.roles) ? (data.roles as string[]) : [],
    phone: typeof data.phone === "string" ? data.phone : "",
    ...(data.checkin
      ? {
          checkin: {
            enabled: data.checkin.enabled === true,
            time: data.checkin.time ?? null,
            timezone: data.checkin.timezone ?? null,
            alertAfterHours: data.checkin.alertAfterHours ?? null,
            lastCheckinAt: data.checkin.lastCheckinAt ?? null,
            lastMissedAlertDate: data.checkin.lastMissedAlertDate ?? null,
          },
        }
      : {}),
  };
}

async function requireCircleId(tx: Transaction, uid: string): Promise<string> {
  const snap = await tx.get(refs.membership(uid));
  if (!snap.exists) fail("NOT_IN_CIRCLE");
  return snap.data()!.circleId as string;
}

function memberUidsOf(data: FirebaseFirestore.DocumentData | undefined): string[] {
  return Array.isArray(data?.memberUids) ? (data!.memberUids as string[]) : [];
}

function addMember(
  tx: Transaction,
  circleId: string,
  uid: string,
  profile: { name: string; roles: string[]; phone: string; checkin?: object },
) {
  const now = FieldValue.serverTimestamp();
  tx.create(refs.member(circleId, uid), { ...profile, joinedAt: now });
  tx.create(refs.membership(uid), { circleId, joinedAt: now });
}

function removeMemberDocs(tx: Transaction, circleId: string, uid: string) {
  tx.delete(refs.member(circleId, uid));
  tx.delete(refs.membership(uid));
}

/** createCircle({ name }) → { circleId } */
export const createCircle = callable(async (req) => {
  const uid = requireUid(req);
  const { name } = parse(schemas.createCircle, req.data, "INVALID_NAME");

  const circleRef = refs.circles().doc();
  await getFirestore().runTransaction(async (tx) => {
    if ((await tx.get(refs.membership(uid))).exists) fail("ALREADY_IN_CIRCLE");
    const profile = await readProfile(tx, uid);

    tx.create(circleRef, {
      name,
      ownerUid: uid,
      memberUids: [uid],
      createdAt: FieldValue.serverTimestamp(),
    });
    addMember(tx, circleRef.id, uid, profile);
  });
  return { circleId: circleRef.id };
});

/**
 * createInvite() → { code, expiresAt (ms) }
 * Any member may invite. Re-uses the circle's current invite while it has
 * at least a day left, so families keep seeing the same code.
 */
export const createInvite = callable(async (req) => {
  const uid = requireUid(req);
  const membership = await refs.membership(uid).get();
  if (!membership.exists) fail("NOT_IN_CIRCLE");
  const circleId = membership.data()!.circleId as string;

  const circle = await refs.circle(circleId).get();
  if (memberUidsOf(circle.data()).length >= LIMITS.maxCircleMembers) {
    fail("CIRCLE_FULL");
  }

  const now = Date.now();
  const invites = await refs.invites().where("circleId", "==", circleId).get();
  const isExpired = (d: QueryDocumentSnapshot) =>
    (d.data().expiresAt as Timestamp).toMillis() <= now || d.data().usesLeft <= 0;

  // Housekeeping: drop this circle's dead invites.
  const dead = invites.docs.filter(isExpired);
  if (dead.length > 0) {
    const batch = getFirestore().batch();
    dead.forEach((d) => batch.delete(d.ref));
    await batch.commit();
  }

  const reusable = invites.docs.find(
    (d) =>
      !isExpired(d) &&
      (d.data().expiresAt as Timestamp).toMillis() - now >=
        LIMITS.inviteReuseMinRemainingHours * HOUR_MS,
  );
  if (reusable) {
    return {
      code: reusable.id,
      expiresAt: (reusable.data().expiresAt as Timestamp).toMillis(),
    };
  }

  const expiresAt = Timestamp.fromMillis(now + LIMITS.inviteTtlDays * DAY_MS);
  for (let attempt = 0; attempt < 5; attempt++) {
    const code = generateInviteCode();
    try {
      // create() fails if the code is already taken.
      await refs.invite(code).create({
        circleId,
        createdBy: uid,
        expiresAt,
        usesLeft: LIMITS.inviteUses,
        createdAt: FieldValue.serverTimestamp(),
      });
      return { code, expiresAt: expiresAt.toMillis() };
    } catch (e) {
      if ((e as { code?: number }).code !== 6 /* ALREADY_EXISTS */) throw e;
    }
  }
  throw new Error("Could not allocate a unique invite code");
});

async function checkJoinRateLimit(uid: string) {
  const snap = await refs.joinAttempts(uid).get();
  if (!snap.exists) return;
  const { count, windowStart } = snap.data() as { count: number; windowStart: Timestamp };
  if (Date.now() - windowStart.toMillis() < HOUR_MS && count >= LIMITS.joinFailuresPerHour) {
    fail("TOO_MANY_ATTEMPTS");
  }
}

async function recordJoinFailure(uid: string) {
  const ref = refs.joinAttempts(uid);
  await getFirestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const windowStart = snap.data()?.windowStart as Timestamp | undefined;
    if (!windowStart || Date.now() - windowStart.toMillis() >= HOUR_MS) {
      tx.set(ref, { count: 1, windowStart: Timestamp.now() });
    } else {
      tx.update(ref, { count: FieldValue.increment(1) });
    }
  });
}

/** joinCircle({ code }) → { circleId } */
export const joinCircle = callable(async (req) => {
  const uid = requireUid(req);
  await checkJoinRateLimit(uid);

  const code = normalizeInviteCode(
    schemas.joinCircle.safeParse(req.data ?? {}).data?.code,
  );
  try {
    if (!code) fail("INVALID_CODE");
    const circleId = await getFirestore().runTransaction(async (tx) => {
      const inviteSnap = await tx.get(refs.invite(code));
      const membershipSnap = await tx.get(refs.membership(uid));
      const invite = inviteSnap.data();

      if (membershipSnap.exists) {
        fail(
          membershipSnap.data()!.circleId === invite?.circleId
            ? "ALREADY_MEMBER"
            : "ALREADY_IN_CIRCLE",
        );
      }
      if (!invite) fail("INVALID_CODE");
      if ((invite.expiresAt as Timestamp).toMillis() <= Date.now()) {
        fail("CODE_EXPIRED");
      }

      const circleRef = refs.circle(invite.circleId);
      const circleSnap = await tx.get(circleRef);
      if (!circleSnap.exists) fail("INVALID_CODE");
      if (memberUidsOf(circleSnap.data()).length >= LIMITS.maxCircleMembers) {
        fail("CIRCLE_FULL");
      }
      if (invite.usesLeft <= 0) fail("CODE_USED_UP");
      const profile = await readProfile(tx, uid);

      tx.update(circleRef, { memberUids: FieldValue.arrayUnion(uid) });
      addMember(tx, circleRef.id, uid, profile);
      tx.update(inviteSnap.ref, { usesLeft: FieldValue.increment(-1) });
      return circleRef.id;
    });
    return { circleId };
  } catch (e) {
    if (isReason(e, "INVALID_CODE")) await recordJoinFailure(uid);
    throw e;
  }
});

/**
 * leaveCircle() → { circleDeleted, newOwnerUid }
 * If the owner leaves, ownership passes to the member who joined earliest.
 * If the last member leaves, the circle, its members and invites are deleted.
 */
export const leaveCircle = callable(async (req) => leaveCircleFor(requireUid(req)));

/** Shared by leaveCircle and deleteMyAccount. Throws NOT_IN_CIRCLE. */
export async function leaveCircleFor(uid: string) {
  return getFirestore().runTransaction(async (tx) => {
    const circleId = await requireCircleId(tx, uid);
    const circleRef = refs.circle(circleId);
    const circleSnap = await tx.get(circleRef);
    const membersSnap = await tx.get(refs.members(circleId));
    const remaining = membersSnap.docs.filter((d) => d.id !== uid);

    if (!circleSnap.exists || remaining.length === 0) {
      const invites = await tx.get(refs.invites().where("circleId", "==", circleId));
      invites.docs.forEach((d) => tx.delete(d.ref));
      membersSnap.docs.forEach((d) => tx.delete(d.ref));
      tx.delete(circleRef);
      tx.delete(refs.membership(uid));
      return { circleDeleted: true, newOwnerUid: null };
    }

    let newOwnerUid: string | null = null;
    if (circleSnap.data()!.ownerUid === uid) {
      const joinedAt = (d: QueryDocumentSnapshot) =>
        (d.data().joinedAt as Timestamp | undefined)?.toMillis() ?? 0;
      remaining.sort((a, b) => joinedAt(a) - joinedAt(b) || a.id.localeCompare(b.id));
      newOwnerUid = remaining[0].id;
    }

    tx.update(circleRef, {
      memberUids: FieldValue.arrayRemove(uid),
      ...(newOwnerUid ? { ownerUid: newOwnerUid } : {}),
    });
    removeMemberDocs(tx, circleId, uid);
    return { circleDeleted: false, newOwnerUid };
  });
}

/** removeMember({ uid }) → { removed: true }. Owner only. */
export const removeMember = callable(async (req) => {
  const uid = requireUid(req);
  const { uid: target } = parse(schemas.removeMember, req.data);
  if (target === uid) fail("CANNOT_REMOVE_SELF");

  await getFirestore().runTransaction(async (tx) => {
    const circleId = await requireCircleId(tx, uid);
    const circleRef: DocumentReference = refs.circle(circleId);
    const circle = (await tx.get(circleRef)).data();
    if (circle?.ownerUid !== uid) fail("NOT_OWNER");
    if (!memberUidsOf(circle).includes(target)) fail("MEMBER_NOT_FOUND");

    tx.update(circleRef, { memberUids: FieldValue.arrayRemove(target) });
    removeMemberDocs(tx, circleId, target);
  });
  return { removed: true };
});
