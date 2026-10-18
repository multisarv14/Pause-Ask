// Guardian alerts end-to-end: onCheckCreated pushes, respondToCheck, rules.
// Pushes are written to _pushLog (PUSH_MODE=log in .env.demo-pauseask).
import assert from "node:assert/strict";
import { after, before, describe, test } from "node:test";

import { getApps, initializeApp as initAdmin } from "firebase-admin/app";
import { getAuth as adminAuth } from "firebase-admin/auth";
import { getFirestore as adminDb } from "firebase-admin/firestore";
import { deleteApp, initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth, signInWithCustomToken } from "firebase/auth";
import {
  collection, connectFirestoreEmulator, doc, getDoc, getDocs, getFirestore,
  orderBy, query, updateDoc, where,
} from "firebase/firestore";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";

const PROJECT = "demo-pauseask";
if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Run via `npm run test:emulator`.");
if (!getApps().length) initAdmin({ projectId: PROJECT });
const db = adminDb();
const apps = [];

async function user(uid, { roles, language = "en", token = `token-${uid}` }) {
  await db.doc(`users/${uid}`).set({
    name: `User ${uid}`, roles, language, phone: `+9199999000${uid.length}`, fcmToken: token,
  });
  const app = initializeApp({ projectId: PROJECT, apiKey: "fake-key" }, `ga-${uid}`);
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
    createCircle: call("createCircle"), createInvite: call("createInvite"),
    joinCircle: call("joinCircle"), analyze: call("analyzeCheck"), respond: call("respondToCheck"),
  };
}

async function waitFor(fn, ms = 15000) {
  const end = Date.now() + ms;
  for (;;) {
    const v = await fn();
    if (v) return v;
    if (Date.now() > end) throw new Error("timed out waiting");
    await new Promise((r) => setTimeout(r, 200));
  }
}

const pushesFor = async (checkId) =>
  (await db.collection("_pushLog").where("data.checkId", "==", checkId).get()).docs.map((d) => d.data());

async function rejectsWith(promise, reason) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.details?.reason, reason, `expected ${reason}, got ${e.details?.reason ?? e.code}`);
    return true;
  });
}

after(async () => Promise.all(apps.map((a) => deleteApp(a))));

describe("guardian alerts", () => {
  let A, B, C, D, E, circleId, checkId;
  const TEXT = "This is CBI. Pay 50000 now to 9876543210@ybl";

  before(async () => {
    A = await user("ga-A", { roles: ["protected"], language: "mr" });
    B = await user("ga-B", { roles: ["guardian"], language: "en" });
    C = await user("ga-C", { roles: ["protected", "guardian"], language: "hi" });
    D = await user("ga-D", { roles: ["protected"] });
    E = await user("ga-E", { roles: ["guardian"] });
    ({ circleId } = await A.createCircle({ name: "GA Family" }));
    const { code } = await A.createInvite();
    for (const u of [B, C, D]) await u.joinCircle({ code });
  });

  test("member docs carry the phone for 'Call now'", async () => {
    const m = (await db.doc(`circles/${circleId}/members/ga-A`).get()).data();
    assert.match(m.phone, /^\+91/);
  });

  test("a check pushes every other guardian, in their own language, without message text", async () => {
    ({ checkId } = await A.analyze({ text: TEXT, source: "typed", language: "mr" }));
    const check = await waitFor(async () => {
      const d = (await db.doc(`checks/${checkId}`).get()).data();
      return d.alert ? d : null;
    });
    assert.deepEqual(
      { guardianCount: check.alert.guardianCount, sentCount: check.alert.sentCount },
      { guardianCount: 2, sentCount: 2 },
    );

    const pushes = await pushesFor(checkId);
    assert.deepEqual(pushes.map((p) => p.uid).sort(), ["ga-B", "ga-C"]); // not A, not D
    const b = pushes.find((p) => p.uid === "ga-B");
    const c = pushes.find((p) => p.uid === "ga-C");
    assert.equal(b.title, "User ga-A needs your help");
    assert.match(b.body, /^High risk/);
    assert.equal(c.title, "User ga-A को आपकी मदद चाहिए");
    assert.equal(b.channel, "alerts");
    assert.deepEqual(Object.keys(b.data).sort(), ["checkId", "fromName", "riskLevel", "type"]);
    for (const p of pushes) {
      const all = JSON.stringify(p);
      assert.ok(!/CBI|50000|ybl|\[UPI\]/.test(all), "push must not contain message text");
    }
  });

  test("only guardians of the circle can respond", async () => {
    await rejectsWith(A.respond({ checkId, type: "OK" }), "NOT_GUARDIAN"); // asker
    await rejectsWith(D.respond({ checkId, type: "OK" }), "NOT_GUARDIAN"); // not a guardian
    await rejectsWith(E.respond({ checkId, type: "OK" }), "NOT_GUARDIAN"); // outsider guardian
    await rejectsWith(B.respond({ checkId, type: "MAYBE" }), "INVALID_ARGUMENT");
    await rejectsWith(B.respond({ checkId: "nope", type: "OK" }), "CHECK_NOT_FOUND");
  });

  test("first reply wins; the second guardian sees who answered", async () => {
    const first = await B.respond({ checkId, type: "STOP" });
    assert.equal(first.accepted, true);
    assert.equal(first.response.byName, "User ga-B");

    const second = await C.respond({ checkId, type: "OK" });
    assert.equal(second.accepted, false);
    assert.equal(second.response.byName, "User ga-B");
    assert.equal(second.response.type, "STOP");

    const saved = (await db.doc(`checks/${checkId}`).get()).data().guardianResponse;
    assert.equal(saved.byUid, "ga-B");
    assert.equal(saved.type, "STOP");
  });

  test("asker gets the reply (own language); other guardians get an info push", async () => {
    const pushes = await waitFor(async () => {
      const p = (await pushesFor(checkId)).filter((x) => x.data.type !== "check_alert");
      return p.length >= 2 ? p : null;
    });
    const toA = pushes.find((p) => p.uid === "ga-A");
    assert.equal(toA.data.type, "guardian_response");
    assert.equal(toA.data.responseType, "STOP");
    assert.equal(toA.title, "थांबा – आत्ता काहीही करू नका");
    assert.equal(toA.body, "User ga-B तुम्हाला फोन करतील.");
    const toC = pushes.find((p) => p.uid === "ga-C");
    assert.equal(toC.data.type, "check_answered");
    assert.equal(toC.channel, "general");
    assert.ok(!pushes.some((p) => p.uid === "ga-B"), "responder gets no push");
  });

  describe("rules", () => {
    test("circle members can read and list the circle's checks", async () => {
      assert.ok((await getDoc(doc(B.db, `checks/${checkId}`))).exists());
      const list = await getDocs(query(
        collection(B.db, "checks"), where("circleId", "==", circleId), orderBy("createdAt", "desc"),
      ));
      assert.ok(list.docs.some((d) => d.id === checkId));
    });

    test("non-members cannot read; nobody can write guardianResponse", async () => {
      await assert.rejects(getDoc(doc(E.db, `checks/${checkId}`)));
      await assert.rejects(getDocs(query(collection(E.db, "checks"), where("circleId", "==", circleId))));
      await assert.rejects(updateDoc(doc(B.db, `checks/${checkId}`), { guardianResponse: { type: "OK" } }));
      await assert.rejects(updateDoc(doc(A.db, `checks/${checkId}`), { guardianResponse: null }));
      await assert.rejects(getDocs(collection(A.db, "_pushLog")));
    });
  });

  test("a check without a circle sends nothing and records guardianCount 0", async () => {
    const F = await user("ga-F", { roles: ["protected"] });
    const { checkId: id } = await F.analyze({ text: "hello", source: "typed", language: "en" });
    const check = await waitFor(async () => {
      const d = (await db.doc(`checks/${id}`).get()).data();
      return d.alert ? d : null;
    });
    assert.equal(check.alert.guardianCount, 0);
    assert.equal((await pushesFor(id)).length, 0);
  });
});
