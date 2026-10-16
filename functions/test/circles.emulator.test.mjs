// End-to-end tests for the circle functions + Firestore rules.
// Run with: npm run test:emulator   (needs JDK 21+ for the emulators)
import assert from "node:assert/strict";
import { after, before, describe, test } from "node:test";

import { initializeApp as initAdmin } from "firebase-admin/app";
import { getAuth as adminAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore as adminDb } from "firebase-admin/firestore";
import { deleteApp, initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth, signInWithCustomToken } from "firebase/auth";
import {
  collection,
  connectFirestoreEmulator,
  doc,
  getDoc,
  getDocs,
  getFirestore,
  query,
  setDoc,
  updateDoc,
  where,
} from "firebase/firestore";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";

const PROJECT = "demo-pauseask";
if (!process.env.FIRESTORE_EMULATOR_HOST) {
  throw new Error("Run via `npm run test:emulator` (emulators not detected).");
}

initAdmin({ projectId: PROJECT });
const db = adminDb();
const apps = [];

/** Signs in a client as `uid` with a users/{uid} profile. */
async function user(uid, roles = ["protected"]) {
  await db.doc(`users/${uid}`).set({ name: `User ${uid}`, roles });
  const app = initializeApp({ projectId: PROJECT, apiKey: "fake-key" }, uid);
  apps.push(app);
  const auth = getAuth(app);
  connectAuthEmulator(auth, "http://127.0.0.1:9099", { disableWarnings: true });
  await signInWithCustomToken(auth, await adminAuth().createCustomToken(uid));
  const fns = getFunctions(app, "asia-south1");
  connectFunctionsEmulator(fns, "127.0.0.1", 5001);
  const store = getFirestore(app);
  connectFirestoreEmulator(store, "127.0.0.1", 8080);
  const call = (name) => async (data) => (await httpsCallable(fns, name)(data)).data;
  return {
    uid,
    db: store,
    createCircle: call("createCircle"),
    createInvite: call("createInvite"),
    joinCircle: call("joinCircle"),
    leaveCircle: call("leaveCircle"),
    removeMember: call("removeMember"),
  };
}

/** Asserts a callable fails with details.reason === reason. */
async function rejectsWith(promise, reason) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.details?.reason, reason, `expected ${reason}, got ${e.details?.reason ?? e.message}`);
    return true;
  });
}

const circleData = async (id) => (await db.doc(`circles/${id}`).get()).data();

before(async () => {
  await fetch(`http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT}/databases/(default)/documents`, { method: "DELETE" });
});
after(async () => Promise.all(apps.map((a) => deleteApp(a))));

describe("family circle", () => {
  let A, B, C, circleId, code;

  before(async () => {
    [A, B, C] = await Promise.all([user("A"), user("B", ["guardian"]), user("C")]);
  });

  test("A creates 'Test Family'", async () => {
    ({ circleId } = await A.createCircle({ name: "  Test Family " }));
    const c = await circleData(circleId);
    assert.equal(c.name, "Test Family");
    assert.equal(c.ownerUid, "A");
    assert.deepEqual(c.memberUids, ["A"]);
    const m = (await db.doc(`circles/${circleId}/members/A`).get()).data();
    assert.equal(m.name, "User A");
    assert.deepEqual(m.roles, ["protected"]);
  });

  test("empty name is rejected", async () => {
    await rejectsWith(C.createCircle({ name: "   " }), "INVALID_NAME");
  });

  test("A cannot create a second circle", async () => {
    await rejectsWith(A.createCircle({ name: "Another" }), "ALREADY_IN_CIRCLE");
  });

  test("invite code is 6 chars and reused", async () => {
    ({ code } = await A.createInvite());
    assert.match(code, /^[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{6}$/);
    assert.equal((await A.createInvite()).code, code);
    const inv = (await db.doc(`invites/${code}`).get()).data();
    assert.equal(inv.circleId, circleId);
    assert.equal(inv.usesLeft, 4);
    const days = (inv.expiresAt.toMillis() - Date.now()) / 86400000;
    assert.ok(days > 6.9 && days <= 7, `expires in ${days} days`);
  });

  test("non-member cannot create an invite", async () => {
    await rejectsWith(C.createInvite(), "NOT_IN_CIRCLE");
  });

  test("B joins with a lowercase, spaced code", async () => {
    const res = await B.joinCircle({ code: ` ${code.slice(0, 3).toLowerCase()} ${code.slice(3)} ` });
    assert.equal(res.circleId, circleId);
    assert.deepEqual((await circleData(circleId)).memberUids, ["A", "B"]);
    const m = (await db.doc(`circles/${circleId}/members/B`).get()).data();
    assert.deepEqual(m.roles, ["guardian"]);
  });

  test("B joining again → ALREADY_MEMBER", async () => {
    await rejectsWith(B.joinCircle({ code }), "ALREADY_MEMBER");
  });

  test("wrong code → INVALID_CODE", async () => {
    await rejectsWith(C.joinCircle({ code: "ZZZZZZ" }), "INVALID_CODE");
    await rejectsWith(C.joinCircle({ code: "abc" }), "INVALID_CODE");
  });

  test("expired code → CODE_EXPIRED", async () => {
    await db.doc("invites/EXP234").set({
      circleId, createdBy: "A", usesLeft: 4, expiresAt: Timestamp.fromMillis(Date.now() - 1000),
    });
    await rejectsWith(C.joinCircle({ code: "EXP234" }), "CODE_EXPIRED");
  });

  test("user in another circle cannot join", async () => {
    await C.createCircle({ name: "C Family" });
    await rejectsWith(C.joinCircle({ code }), "ALREADY_IN_CIRCLE");
    await C.leaveCircle();
  });

  test("6th member is blocked: CIRCLE_FULL", async () => {
    const [D, E, F, G] = await Promise.all(["D", "E", "F", "G"].map((u) => user(u)));
    for (const u of [D, E, F]) await u.joinCircle({ code });
    assert.equal((await circleData(circleId)).memberUids.length, 5);
    await rejectsWith(G.joinCircle({ code }), "CIRCLE_FULL");
    await rejectsWith(A.createInvite(), "CIRCLE_FULL");
  });

  test("only the owner can remove; owner cannot remove self", async () => {
    await rejectsWith(B.removeMember({ uid: "D" }), "NOT_OWNER");
    await rejectsWith(A.removeMember({ uid: "A" }), "CANNOT_REMOVE_SELF");
    await rejectsWith(A.removeMember({ uid: "nobody" }), "MEMBER_NOT_FOUND");
    await A.removeMember({ uid: "D" });
    assert.ok(!(await circleData(circleId)).memberUids.includes("D"));
    assert.equal((await db.doc("memberships/D").get()).exists, false);
  });

  test("used-up invite → CODE_USED_UP once there is room", async () => {
    // 4 uses spent (B, D, E, F); D was removed so there is room again.
    const H = await user("H");
    await rejectsWith(H.joinCircle({ code }), "CODE_USED_UP");
  });

  describe("rules", () => {
    test("members can read the circle and member list", async () => {
      const snap = await getDocs(query(collection(B.db, "circles"), where("memberUids", "array-contains", "B")));
      assert.equal(snap.size, 1);
      const members = await getDocs(collection(B.db, `circles/${circleId}/members`));
      assert.equal(members.size, 4);
    });

    test("non-members cannot read", async () => {
      await assert.rejects(getDoc(doc(C.db, `circles/${circleId}`)));
      await assert.rejects(getDocs(collection(C.db, `circles/${circleId}/members`)));
    });

    test("no direct client writes to circles / members / invites / memberships", async () => {
      await assert.rejects(updateDoc(doc(A.db, `circles/${circleId}`), { name: "x" }));
      await assert.rejects(setDoc(doc(C.db, "circles/new"), { name: "x", ownerUid: "C", memberUids: ["C"] }));
      await assert.rejects(setDoc(doc(A.db, `circles/${circleId}/members/X`), { name: "x" }));
      await assert.rejects(setDoc(doc(A.db, "invites/AAAAAA"), { circleId }));
      await assert.rejects(getDoc(doc(A.db, `invites/${code}`)));
      await assert.rejects(setDoc(doc(C.db, "memberships/C"), { circleId }));
    });
  });

  test("owner leaving transfers ownership to the earliest member", async () => {
    const res = await A.leaveCircle();
    assert.deepEqual(res, { circleDeleted: false, newOwnerUid: "B" });
    const c = await circleData(circleId);
    assert.equal(c.ownerUid, "B");
    assert.ok(!c.memberUids.includes("A"));
  });

  test("last member leaving deletes circle and invites", async () => {
    await B.removeMember({ uid: "E" });
    await B.removeMember({ uid: "F" });
    const res = await B.leaveCircle();
    assert.equal(res.circleDeleted, true);
    assert.equal((await db.doc(`circles/${circleId}`).get()).exists, false);
    assert.equal((await db.collection("invites").where("circleId", "==", circleId).get()).size, 0);
    await rejectsWith(B.leaveCircle(), "NOT_IN_CIRCLE");
  });

  test("too many wrong codes → TOO_MANY_ATTEMPTS", async () => {
    const Z = await user("Z");
    for (let i = 0; i < 10; i++) {
      await rejectsWith(Z.joinCircle({ code: "WRONG2" }), "INVALID_CODE");
    }
    await rejectsWith(Z.joinCircle({ code: "WRONG2" }), "TOO_MANY_ATTEMPTS");
  });
});
