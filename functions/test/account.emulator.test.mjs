// deleteMyAccount, updateRoles, sendTestAlert (emulators).
import assert from "node:assert/strict";
import { after, describe, test } from "node:test";

import { getApps, initializeApp as initAdmin } from "firebase-admin/app";
import { getAuth as adminAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore as adminDb } from "firebase-admin/firestore";
import { deleteApp, initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth, signInWithCustomToken } from "firebase/auth";
import { connectFirestoreEmulator, doc, getFirestore, updateDoc } from "firebase/firestore";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";

const PROJECT = "demo-pauseask";
if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Run via `npm run test:emulator`.");
if (!getApps().length) initAdmin({ projectId: PROJECT });
const db = adminDb();
const apps = [];

async function user(uid, { roles = ["protected"], token = `fid-${uid}`, language = "en" } = {}) {
  await db.doc(`users/${uid}`).set({
    name: `User ${uid}`, roles, language, phone: "+919999900001", fcmToken: token,
    largeText: false, consentVersion: 1, consentAcceptedAt: Timestamp.now(), createdAt: Timestamp.now(),
  });
  const app = initializeApp({ projectId: PROJECT, apiKey: "fake-key" }, `acct-${uid}`);
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
    uid, db: store,
    createCircle: call("createCircle"), createInvite: call("createInvite"), joinCircle: call("joinCircle"),
    analyze: call("analyzeCheck"), respond: call("respondToCheck"), sos: call("sendSos"),
    deleteMe: call("deleteMyAccount"), updateRoles: call("updateRoles"), testAlert: call("sendTestAlert"),
  };
}

async function rejectsWith(promise, reason) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.details?.reason, reason, `expected ${reason}, got ${e.details?.reason ?? e.code}`);
    return true;
  });
}

const exists = async (path) => (await db.doc(path).get()).exists;
async function waitForAlert(checkId) {
  for (let i = 0; i < 50; i++) {
    if ((await db.doc(`checks/${checkId}`).get()).data()?.alert) return;
    await new Promise((r) => setTimeout(r, 100));
  }
}

after(async () => Promise.all(apps.map((a) => deleteApp(a))));

describe("deleteMyAccount", () => {
  test("owner deletion: data gone, ownership to the oldest member, Auth user deleted", async () => {
    const A = await user("acct-A");
    const B = await user("acct-B", { roles: ["guardian"] });
    const C = await user("acct-C", { roles: ["protected", "guardian"] });
    const { circleId } = await A.createCircle({ name: "Acct Family" });
    const { code } = await A.createInvite();
    await B.joinCircle({ code });
    await C.joinCircle({ code });

    const { checkId: aCheck } = await A.analyze({ text: "hello", source: "typed", language: "en" });
    await A.sos();
    // A (not a guardian) can't reply; B replies to C's check — kept after A goes.
    const { checkId: cCheck } = await C.analyze({ text: "other", source: "typed", language: "en" });
    await waitForAlert(aCheck);
    await waitForAlert(cCheck);

    assert.deepEqual(await A.deleteMe(), { deleted: true });

    assert.equal(await exists("users/acct-A"), false);
    assert.equal(await exists(`checks/${aCheck}`), false);
    assert.equal((await db.collection("usage").where("uid", "==", "acct-A").get()).size, 0);
    assert.equal(await exists("sosUsage/acct-A"), false);
    assert.equal(await exists("memberships/acct-A"), false);
    assert.equal(await exists(`circles/${circleId}/members/acct-A`), false);
    const circle = (await db.doc(`circles/${circleId}`).get()).data();
    assert.equal(circle.ownerUid, "acct-B"); // joined first
    assert.deepEqual(circle.memberUids.sort(), ["acct-B", "acct-C"]);
    assert.ok(await exists(`checks/${cCheck}`), "other people's checks stay");
    await assert.rejects(adminAuth().getUser("acct-A"), /no user record|user-not-found/i);
  });

  test("guardian deletion anonymises their replies on others' checks", async () => {
    const P = await user("acct-P");
    const G = await user("acct-G", { roles: ["guardian"] });
    await P.createCircle({ name: "P Family" });
    const { code } = await P.createInvite();
    await G.joinCircle({ code });
    const { checkId } = await P.analyze({ text: "hello", source: "typed", language: "en" });
    await G.respond({ checkId, type: "OK" });
    await G.deleteMe();
    const r = (await db.doc(`checks/${checkId}`).get()).data().guardianResponse;
    assert.equal(r.type, "OK");
    assert.equal(r.byName, "");
    assert.equal(r.byUid, "");
  });

  test("last member deleting removes the circle", async () => {
    const L = await user("acct-L");
    const { circleId } = await L.createCircle({ name: "Lonely" });
    await L.createInvite();
    await L.deleteMe();
    assert.equal(await exists(`circles/${circleId}`), false);
    assert.equal((await db.collection("invites").where("circleId", "==", circleId).get()).size, 0);
  });

  test("works without a circle", async () => {
    const N = await user("acct-N");
    assert.deepEqual(await N.deleteMe(), { deleted: true });
    assert.equal(await exists("users/acct-N"), false);
  });
});

describe("updateRoles", () => {
  test("validates, updates the profile and the circle copy; clients can't edit roles directly", async () => {
    const R = await user("acct-R");
    const { circleId } = await R.createCircle({ name: "Roles" });
    await rejectsWith(R.updateRoles({ roles: ["admin"] }), "INVALID_ARGUMENT");
    await rejectsWith(R.updateRoles({ roles: [] }), "INVALID_ARGUMENT");
    assert.deepEqual(await R.updateRoles({ roles: ["guardian", "protected"] }), { roles: ["protected", "guardian"] });
    assert.deepEqual((await db.doc("users/acct-R").get()).data().roles, ["protected", "guardian"]);
    assert.deepEqual((await db.doc(`circles/${circleId}/members/acct-R`).get()).data().roles, ["protected", "guardian"]);
    await assert.rejects(updateDoc(doc(R.db, "users/acct-R"), { roles: ["guardian"] }));
    await updateDoc(doc(R.db, "users/acct-R"), { largeText: true }); // other fields still fine
  });
});

describe("sendTestAlert", () => {
  test("pushes my own phone in my language; no token → sent false", async () => {
    const T = await user("acct-T", { language: "mr" });
    assert.deepEqual(await T.testAlert(), { sent: true });
    const log = (await db.collection("_pushLog").where("uid", "==", "acct-T").get()).docs.map((d) => d.data());
    assert.equal(log[0].title, "PauseAsk चाचणी सूचना ✅");
    assert.equal(log[0].channel, "alerts");
    const U = await user("acct-U", { token: null });
    assert.deepEqual(await U.testAlert(), { sent: false });
  });
});
