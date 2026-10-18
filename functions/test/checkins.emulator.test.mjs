// Check-in, settings, missed-check-in sweep and SOS in the emulators.
import assert from "node:assert/strict";
import { after, before, describe, test } from "node:test";

process.env.PUSH_MODE = "log";
process.env.FUNCTIONS_EMULATOR = "true";
if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Run via `npm run test:emulator`.");
// Imports the compiled sweep, which initialises the default admin app.
const { runCheckinSweep } = await import("../lib/checkins/checkins.js");

import { getAuth as adminAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore as adminDb } from "firebase-admin/firestore";
import { deleteApp, initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth, signInWithCustomToken } from "firebase/auth";
import {
  Timestamp as ClientTimestamp, connectFirestoreEmulator, doc, getDoc, getFirestore, updateDoc,
} from "firebase/firestore";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";

const PROJECT = "demo-pauseask";
const db = adminDb();
const apps = [];

async function user(uid, { roles, language = "en" }) {
  await db.doc(`users/${uid}`).set({
    name: `User ${uid}`, roles, language, phone: "+919999900011", fcmToken: `fid-${uid}`,
    // Complete, rules-valid profile so normal client updates are allowed.
    largeText: false, consentVersion: 1, consentAcceptedAt: Timestamp.now(), createdAt: Timestamp.now(),
  });
  const app = initializeApp({ projectId: PROJECT, apiKey: "fake-key" }, `ci-${uid}`);
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
    checkIn: call("checkIn"), save: call("saveCheckinSettings"), sos: call("sendSos"),
    analyze: call("analyzeCheck"),
  };
}

async function rejectsWith(promise, reason) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.details?.reason, reason, `expected ${reason}, got ${e.details?.reason ?? e.code}`);
    return true;
  });
}

const pushes = async (type) =>
  (await db.collection("_pushLog").where("data.type", "==", type).get()).docs.map((d) => d.data());

after(async () => Promise.all(apps.map((a) => deleteApp(a))));

describe("check-in, missed alerts and SOS", () => {
  let P, G, H, circleId;
  const settings = { enabled: true, time: "09:00", alertAfterHours: 12, timezone: "Asia/Kolkata" };

  before(async () => {
    P = await user("ci-P", { roles: ["protected"], language: "hi" });
    G = await user("ci-G", { roles: ["guardian"], language: "en" });
    H = await user("ci-H", { roles: ["guardian"], language: "mr" });
    ({ circleId } = await P.createCircle({ name: "CI Family" }));
    const { code } = await P.createInvite();
    await G.joinCircle({ code });
    await H.joinCircle({ code });
  });

  test("settings are validated", async () => {
    await rejectsWith(P.save({ ...settings, time: "9am" }), "INVALID_SETTINGS");
    await rejectsWith(P.save({ ...settings, alertAfterHours: 0 }), "INVALID_SETTINGS");
    await rejectsWith(P.save({ ...settings, alertAfterHours: 25 }), "INVALID_SETTINGS");
    await rejectsWith(P.save({ ...settings, timezone: "Mars/Base" }), "INVALID_SETTINGS");
    await rejectsWith(P.save({ ...settings, enabled: "yes" }), "INVALID_SETTINGS");
  });

  test("saving settings stores them and shares status with the circle", async () => {
    await P.save(settings);
    const c = (await db.doc("users/ci-P").get()).data().checkin;
    assert.equal(c.time, "09:00");
    assert.equal(c.timezone, "Asia/Kolkata");
    assert.ok(c.updatedAt);
    const m = (await db.doc(`circles/${circleId}/members/ci-P`).get()).data().checkin;
    assert.equal(m.enabled, true);
    assert.equal(m.time, "09:00");
  });

  test("checkIn updates lastCheckinAt for the user and the circle", async () => {
    const { lastCheckinAt } = await P.checkIn();
    assert.ok(Math.abs(lastCheckinAt - Date.now()) < 10_000);
    const m = (await db.doc(`circles/${circleId}/members/ci-P`).get()).data().checkin;
    assert.equal(m.lastCheckinAt.toMillis(), lastCheckinAt);
  });

  test("a scam check also counts as a check-in", async () => {
    await db.doc("users/ci-P").update({ "checkin.lastCheckinAt": null });
    await P.analyze({ text: "hello", source: "typed", language: "en" });
    const c = (await db.doc("users/ci-P").get()).data().checkin;
    assert.ok(c.lastCheckinAt);
  });

  test("the app cannot write check-in fields directly", async () => {
    await assert.rejects(updateDoc(doc(P.db, "users/ci-P"), { "checkin.lastCheckinAt": ClientTimestamp.now() }));
    await assert.rejects(updateDoc(doc(P.db, "users/ci-P"), { "checkin.lastMissedAlertDate": "2099-01-01" }));
    // Other profile updates still work.
    await updateDoc(doc(P.db, "users/ci-P"), { largeText: true });
  });

  test("guardians can read the member status; nobody else can read users/{uid}", async () => {
    const m = await getDoc(doc(G.db, `circles/${circleId}/members/ci-P`));
    assert.ok(m.data().checkin);
    await assert.rejects(getDoc(doc(G.db, "users/ci-P")));
  });

  test("missed check-in → exactly one gentle alert per day, to guardians, in their language", async () => {
    const twoDaysAgo = Timestamp.fromMillis(Date.now() - 2 * 86_400_000);
    await db.doc("users/ci-P").update({
      "checkin.time": "00:00",
      "checkin.alertAfterHours": 1,
      "checkin.updatedAt": twoDaysAgo,
      "checkin.lastCheckinAt": twoDaysAgo,
      "checkin.lastMissedAlertDate": null,
    });
    // 01:30 IST today is past 00:00 + 1h.
    const now = Date.now();
    const ist = new Date(now + 5.5 * 3_600_000);
    const sweepAt = Date.UTC(ist.getUTCFullYear(), ist.getUTCMonth(), ist.getUTCDate(), 1, 30) - 5.5 * 3_600_000;

    assert.equal(await runCheckinSweep(sweepAt), 1);
    assert.equal(await runCheckinSweep(sweepAt + 30 * 60_000), 0, "no duplicate");

    const sent = await pushes("missed_checkin");
    assert.deepEqual(sent.map((p) => p.uid).sort(), ["ci-G", "ci-H"]);
    assert.equal(sent.find((p) => p.uid === "ci-G").title, "User ci-P hasn't checked in today");
    assert.equal(sent.find((p) => p.uid === "ci-H").title, 'User ci-P यांनी आज "मी ठीक आहे" कळवलं नाही');
    const m = (await db.doc(`circles/${circleId}/members/ci-P`).get()).data().checkin;
    assert.match(m.lastMissedAlertDate, /^\d{4}-\d{2}-\d{2}$/);
  });

  test("check-in off → no missed alerts", async () => {
    await db.doc("users/ci-P").update({ "checkin.enabled": false, "checkin.lastMissedAlertDate": null });
    assert.equal(await runCheckinSweep(Date.now() + 86_400_000), 0);
  });

  test("SOS pushes all guardians urgently and returns the first guardian", async () => {
    const r = await P.sos();
    assert.equal(r.guardianCount, 2);
    assert.equal(r.sentCount, 2);
    assert.equal(r.firstGuardian.uid, "ci-G"); // joined first
    assert.match(r.firstGuardian.phone, /^\+91/);
    const sent = (await pushes("sos")).filter((p) => p.data.fromUid === "ci-P");
    assert.equal(sent.length, 2);
    assert.ok(sent.every((p) => p.channel === "alerts"));
    assert.equal(sent.find((p) => p.uid === "ci-G").title, "🆘 User ci-P needs help now");
  });

  test("6th SOS within an hour is blocked", async () => {
    for (let i = 0; i < 4; i++) await P.sos(); // 5 in total
    await rejectsWith(P.sos(), "SOS_LIMIT");
  });

  test("SOS without a circle still succeeds with no guardians", async () => {
    const lone = await user("ci-L", { roles: ["protected"] });
    assert.deepEqual(await lone.sos(), { guardianCount: 0, sentCount: 0, firstGuardian: null });
  });
});
