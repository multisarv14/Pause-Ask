// analyzeCheck end-to-end in the emulators with the fake LLM provider
// (functions/.env.demo-pauseask). Run with: npm run test:emulator
import assert from "node:assert/strict";
import { after, before, describe, test } from "node:test";

import { initializeApp as initAdmin, getApps } from "firebase-admin/app";
import { getAuth as adminAuth } from "firebase-admin/auth";
import { getFirestore as adminDb } from "firebase-admin/firestore";
import { deleteApp, initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth, signInWithCustomToken } from "firebase/auth";
import { connectFirestoreEmulator, doc, getDoc, getFirestore } from "firebase/firestore";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";

const PROJECT = "demo-pauseask";
if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Run via `npm run test:emulator`.");
if (!getApps().length) initAdmin({ projectId: PROJECT });
const db = adminDb();
const apps = [];

function client(name) {
  const app = initializeApp({ projectId: PROJECT, apiKey: "fake-key" }, `check-${name}`);
  apps.push(app);
  const fns = getFunctions(app, "asia-south1");
  connectFunctionsEmulator(fns, "127.0.0.1", 5001);
  const store = getFirestore(app);
  connectFirestoreEmulator(store, "127.0.0.1", 8080);
  const auth = getAuth(app);
  connectAuthEmulator(auth, "http://127.0.0.1:9099", { disableWarnings: true });
  const analyze = async (data) => (await httpsCallable(fns, "analyzeCheck")(data)).data;
  return { app, auth, db: store, analyze };
}

async function signedIn(uid) {
  const c = client(uid);
  await signInWithCustomToken(c.auth, await adminAuth().createCustomToken(uid));
  return c;
}

async function rejectsWith(promise, reason) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.details?.reason, reason, `expected ${reason}, got ${e.details?.reason ?? e.code}`);
    return true;
  });
}

const check = (text, extra = {}) => ({ text, source: "typed", language: "en", ...extra });

after(async () => Promise.all(apps.map((a) => deleteApp(a))));

describe("analyzeCheck", () => {
  let U;
  before(async () => {
    U = await signedIn("checker");
    await db.doc("memberships/checker").set({ circleId: "circle-1" });
  });

  test("unauthenticated call is rejected", async () => {
    await rejectsWith(client("anon").analyze(check("hello")), "UNAUTHENTICATED");
  });

  test("empty, too long and bad arguments are rejected", async () => {
    await rejectsWith(U.analyze(check("   ")), "INVALID_TEXT");
    await rejectsWith(U.analyze({ source: "typed", language: "en" }), "INVALID_TEXT");
    await rejectsWith(U.analyze(check("x".repeat(5000))), "TEXT_TOO_LONG");
    await rejectsWith(U.analyze(check("hi", { language: "fr" })), "INVALID_ARGUMENT");
    await rejectsWith(U.analyze(check("hi", { source: "email" })), "INVALID_ARGUMENT");
  });

  test("4000 characters is accepted", async () => {
    const r = await U.analyze(check("a".repeat(4000)));
    assert.ok(r.checkId);
  });

  test("saves a masked check with circleId and 30-day expireAt", async () => {
    const text = "This is CBI. Aadhaar 1234 5678 9012 linked to crime. Call 9876543210, OTP 482913, pay to fraud@okaxis or mail x@y.com";
    const { checkId, result } = await U.analyze(check(text, { source: "share", language: "hi" }));
    assert.equal(result.riskLevel, "HIGH");
    assert.equal(result.whatToDo.length, 3);

    const d = (await db.doc(`checks/${checkId}`).get()).data();
    assert.equal(d.uid, "checker");
    assert.equal(d.circleId, "circle-1");
    assert.equal(d.source, "share");
    assert.equal(d.language, "hi");
    assert.equal(d.guardianResponse, null);
    assert.equal(d.result.riskLevel, "HIGH");
    assert.doesNotMatch(d.maskedText, /\d{4,}/);
    for (const t of ["[ACCOUNT]", "[PHONE]", "[CODE]", "[UPI]", "[EMAIL]"]) assert.ok(d.maskedText.includes(t), t);
    const days = (d.expireAt.toMillis() - d.createdAt.toMillis()) / 86400000;
    assert.equal(days, 30);
  });

  test("model output that is not JSON → BE_CAREFUL fallback", async () => {
    const { checkId, result } = await U.analyze(check("FAKE_NOT_JSON", { language: "mr" }));
    assert.equal(result.riskLevel, "BE_CAREFUL");
    assert.match(result.summary, /तपासू/);
    assert.equal((await db.doc(`checks/${checkId}`).get()).data().aiStatus, "fallback:not_json");
  });

  test("model saying 'safe' → BE_CAREFUL fallback", async () => {
    const { checkId, result } = await U.analyze(check("FAKE_SAYS_SAFE"));
    assert.equal(result.riskLevel, "BE_CAREFUL");
    assert.doesNotMatch(result.summary, /is safe/);
    assert.equal((await db.doc(`checks/${checkId}`).get()).data().aiStatus, "fallback:safe_verdict");
  });

  test("model error → BE_CAREFUL fallback", async () => {
    const { result } = await U.analyze(check("FAKE_THROW"));
    assert.equal(result.riskLevel, "BE_CAREFUL");
  });

  test("clients cannot read checks or usage directly", async () => {
    const { checkId } = await U.analyze(check("hello"));
    await assert.rejects(getDoc(doc(U.db, `checks/${checkId}`)));
    await assert.rejects(getDoc(doc(U.db, "usage/checker_20260101")));
  });

  test("11th check of the day → DAILY_LIMIT_REACHED", async () => {
    const V = await signedIn("limit-user");
    for (let i = 1; i <= 10; i++) await V.analyze(check(`message ${i}`));
    await rejectsWith(V.analyze(check("one more")), "DAILY_LIMIT_REACHED");
    // Rejected input does not use up the quota.
    const W = await signedIn("invalid-user");
    for (let i = 0; i < 12; i++) await rejectsWith(W.analyze(check("")), "INVALID_TEXT");
    assert.ok((await W.analyze(check("still allowed"))).checkId);
  });
});
