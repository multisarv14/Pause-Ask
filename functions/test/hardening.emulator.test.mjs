// Concurrency, input validation and rate limits on callables (emulators).
import assert from "node:assert/strict";
import { after, before, describe, test } from "node:test";

import { getApps, initializeApp as initAdmin } from "firebase-admin/app";
import { getAuth as adminAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore as adminDb } from "firebase-admin/firestore";
import { deleteApp, initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth, signInWithCustomToken } from "firebase/auth";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";

const PROJECT = "demo-pauseask";
if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Run via `npm run test:emulator`.");
if (!getApps().length) initAdmin({ projectId: PROJECT });
const db = adminDb();
const apps = [];

async function user(uid, roles = ["protected"]) {
  await db.doc(`users/${uid}`).set({
    name: `User ${uid}`, roles, language: "en", phone: "+919999900001", fcmToken: `fid-${uid}`,
    largeText: false, consentVersion: 1, consentAcceptedAt: Timestamp.now(), createdAt: Timestamp.now(),
  });
  const app = initializeApp({ projectId: PROJECT, apiKey: "fake-key" }, `hard-${uid}`);
  apps.push(app);
  const auth = getAuth(app);
  connectAuthEmulator(auth, "http://127.0.0.1:9099", { disableWarnings: true });
  await signInWithCustomToken(auth, await adminAuth().createCustomToken(uid));
  const fns = getFunctions(app, "asia-south1");
  connectFunctionsEmulator(fns, "127.0.0.1", 5001);
  return (name) => async (data) => (await httpsCallable(fns, name)(data)).data;
}

async function rejectsWith(promise, reason) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.details?.reason, reason, `expected ${reason}, got ${e.details?.reason ?? e.code}`);
    return true;
  });
}

after(async () => Promise.all(apps.map((a) => deleteApp(a))));

describe("hardening", () => {
  let P, G1, G2, G3, checkId;

  before(async () => {
    P = await user("hd-P");
    G1 = await user("hd-G1", ["guardian"]);
    G2 = await user("hd-G2", ["guardian"]);
    G3 = await user("hd-G3", ["guardian"]);
    await P("createCircle")({ name: "Hard" });
    const { code } = await P("createInvite")();
    for (const g of [G1, G2, G3]) await g("joinCircle")({ code });
    ({ checkId } = await P("analyzeCheck")({ text: "hello", source: "typed", language: "en" }));
  });

  test("three guardians replying at the same instant: exactly one wins", async () => {
    const results = await Promise.all([
      G1("respondToCheck")({ checkId, type: "STOP" }),
      G2("respondToCheck")({ checkId, type: "OK" }),
      G3("respondToCheck")({ checkId, type: "CALL" }),
    ]);
    assert.equal(results.filter((r) => r.accepted).length, 1);
    const winner = results.find((r) => r.accepted).response;
    for (const r of results) assert.deepEqual(r.response.byUid, winner.byUid);
    const saved = (await db.doc(`checks/${checkId}`).get()).data().guardianResponse;
    assert.equal(saved.byUid, winner.byUid);
  });

  test("ids with path characters or wrong types are rejected cleanly", async () => {
    await rejectsWith(G1("respondToCheck")({ checkId: "a/b", type: "OK" }), "INVALID_ARGUMENT");
    await rejectsWith(G1("respondToCheck")({ checkId: 42, type: "OK" }), "INVALID_ARGUMENT");
    await rejectsWith(P("deleteCheck")({ checkId: "../users/hd-G1" }), "INVALID_ARGUMENT");
    await rejectsWith(P("removeMember")({ uid: "x/y" }), "INVALID_ARGUMENT");
    await rejectsWith(P("createCircle")({ name: 123 }), "INVALID_NAME");
    await rejectsWith(P("joinCircle")({ code: { $gt: "" } }), "INVALID_CODE");
    await rejectsWith(P("updateRoles")({ roles: ["guardian", "guardian"] }), "INVALID_ARGUMENT");
    await rejectsWith(P("analyzeCheck")({ text: "hi", source: "typed", language: "en", extra: "ok" }).then(() => {
      throw Object.assign(new Error("accepted"), { details: { reason: "ACCEPTED_EXTRA_FIELD_OK" } });
    }), "ACCEPTED_EXTRA_FIELD_OK"); // unknown fields are ignored, not an error
  });

  test("every callable rejects signed-out calls", async () => {
    const app = initializeApp({ projectId: PROJECT, apiKey: "fake-key" }, "hard-anon");
    apps.push(app);
    const fns = getFunctions(app, "asia-south1");
    connectFunctionsEmulator(fns, "127.0.0.1", 5001);
    for (const name of [
      "createCircle", "createInvite", "joinCircle", "leaveCircle", "removeMember", "analyzeCheck",
      "respondToCheck", "deleteCheck", "checkIn", "saveCheckinSettings", "sendSos",
      "deleteMyAccount", "updateRoles", "sendTestAlert",
    ]) {
      await rejectsWith(httpsCallable(fns, name)({}), "UNAUTHENTICATED");
    }
  });

  test("test alert: 5 per hour", async () => {
    for (let i = 0; i < 5; i++) await G1("sendTestAlert")();
    await rejectsWith(G1("sendTestAlert")(), "TOO_MANY_REQUESTS");
  });
});
