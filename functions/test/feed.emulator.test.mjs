// History delete, scam feed seed + rules, weekly feed push (emulators).
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { after, before, describe, test } from "node:test";

process.env.PUSH_MODE = "log";
process.env.FUNCTIONS_EMULATOR = "true";
if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Run via `npm run test:emulator`.");
const { runFeedPush } = await import("../lib/feed/feedPush.js");

import { getAuth as adminAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore as adminDb } from "firebase-admin/firestore";
import { deleteApp, initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth, signInWithCustomToken } from "firebase/auth";
import {
  collection, connectFirestoreEmulator, deleteDoc, doc, getDoc, getDocs, getFirestore,
  orderBy, query, setDoc, where,
} from "firebase/firestore";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";

const PROJECT = "demo-pauseask";
const db = adminDb();
const apps = [];

async function client(uid, profile) {
  if (profile) {
    await db.doc(`users/${uid}`).set({
      name: `User ${uid}`, roles: ["protected"], language: "en", phone: "+919999900001",
      fcmToken: `fid-${uid}`, ...profile,
    });
  }
  const app = initializeApp({ projectId: PROJECT, apiKey: "fake-key" }, `feed-${uid}`);
  apps.push(app);
  const auth = getAuth(app);
  connectAuthEmulator(auth, "http://127.0.0.1:9099", { disableWarnings: true });
  if (uid) await signInWithCustomToken(auth, await adminAuth().createCustomToken(uid));
  const fns = getFunctions(app, "asia-south1");
  connectFunctionsEmulator(fns, "127.0.0.1", 5001);
  const store = getFirestore(app);
  connectFirestoreEmulator(store, "127.0.0.1", 8080);
  const call = (name) => async (data) => (await httpsCallable(fns, name)(data)).data;
  return { db: store, analyze: call("analyzeCheck"), deleteCheck: call("deleteCheck") };
}

async function rejectsWith(promise, reason) {
  await assert.rejects(promise, (e) => {
    assert.equal(e.details?.reason, reason, `expected ${reason}, got ${e.details?.reason ?? e.code}`);
    return true;
  });
}

after(async () => Promise.all(apps.map((a) => deleteApp(a))));

describe("history", () => {
  test("only the owner can delete a check; owner lists only their own", async () => {
    const owner = await client("h-owner", {});
    const other = await client("h-other", {});
    const { checkId } = await owner.analyze({ text: "hello", source: "typed", language: "en" });
    await other.analyze({ text: "other", source: "typed", language: "en" });

    const mine = await getDocs(query(
      collection(owner.db, "checks"), where("uid", "==", "h-owner"), orderBy("createdAt", "desc"),
    ));
    assert.ok(mine.docs.length >= 1 && mine.docs.every((d) => d.data().uid === "h-owner"));
    await assert.rejects(getDocs(query(collection(other.db, "checks"), where("uid", "==", "h-owner"))));

    await rejectsWith(other.deleteCheck({ checkId }), "NOT_OWNER");
    await assert.rejects(deleteDoc(doc(owner.db, `checks/${checkId}`)), "no direct client delete");
    await rejectsWith(owner.deleteCheck({ checkId: "missing" }), "CHECK_NOT_FOUND");
    assert.deepEqual(await owner.deleteCheck({ checkId }), { deleted: true });
    assert.equal((await db.doc(`checks/${checkId}`).get()).exists, false);
  });
});

describe("scam feed", () => {
  before(() => {
    execFileSync(process.execPath, ["scripts/seedFeed.ts", PROJECT], { env: process.env, stdio: "pipe" });
  });

  test("seed script creates 8 active items in en / hi / mr", async () => {
    const items = (await db.collection("scamFeed").get()).docs.filter((d) => d.id.startsWith("seed-"));
    assert.equal(items.length, 8);
    for (const d of items) {
      const x = d.data();
      assert.equal(x.active, true);
      assert.ok(Array.isArray(x.countryCodes) && x.countryCodes.length > 0);
      assert.ok(x.publishedAt instanceof Timestamp);
      for (const f of ["title", "body"]) {
        assert.ok(x[f].en.length > 10, `${d.id}.${f}.en`);
        assert.match(x[f].hi, /[ऀ-ॿ]/, `${d.id}.${f}.hi`);
        assert.match(x[f].mr, /[ऀ-ॿ]/, `${d.id}.${f}.mr`);
      }
    }
  });

  test("signed-in users can read (newest first); nobody can write; signed-out can't read", async () => {
    const reader = await client("f-reader", {});
    const list = await getDocs(query(
      collection(reader.db, "scamFeed"), where("active", "==", true), orderBy("publishedAt", "desc"),
    ));
    assert.ok(list.size >= 8);
    assert.equal(list.docs[0].id, "seed-digital-arrest");
    await assert.rejects(setDoc(doc(reader.db, "scamFeed/x"), { active: true }));
    await assert.rejects(deleteDoc(doc(reader.db, "scamFeed/seed-kyc-update")));
    const anon = await client(null);
    await assert.rejects(getDoc(doc(anon.db, "scamFeed/seed-kyc-update")));
  });

  test("weekly push: one item per run, never twice, by country and in each language", async () => {
    await db.doc("users/f-uk").set({ name: "UK", roles: ["guardian"], language: "en", phone: "+447700900123", fcmToken: "fid-uk" });
    await db.doc("users/f-mr").set({ name: "MR", roles: ["protected"], language: "mr", phone: "+919999900005", fcmToken: "fid-mr" });

    const first = await runFeedPush();
    assert.equal(first, "seed-digital-arrest"); // newest, IN only
    const p1 = (await db.collection("_pushLog").where("data.feedId", "==", first).get()).docs.map((d) => d.data());
    assert.ok(p1.some((p) => p.uid === "f-mr" && p.title === "⚠️ नवीन फसवणूक इशारा" && p.body.includes("डिजिटल अरेस्ट")));
    assert.ok(!p1.some((p) => p.uid === "f-uk"), "IN-only alert not sent to a UK number");
    assert.ok(p1.every((p) => p.channel === "general"));

    const second = await runFeedPush();
    assert.notEqual(second, first);
    assert.ok((await db.doc(`scamFeed/${first}`).get()).data().pushedAt);
  });

  test("inactive or old items are never pushed", async () => {
    await db.doc("scamFeed/old").set({ active: true, publishedAt: Timestamp.fromMillis(Date.now() - 10 * 86_400_000), countryCodes: ["ALL"], title: { en: "old" }, body: { en: "old" } });
    await db.doc("scamFeed/off").set({ active: false, publishedAt: Timestamp.now(), countryCodes: ["ALL"], title: { en: "off" }, body: { en: "off" } });
    const pushed = new Set();
    for (let i = 0; i < 10; i++) {
      const id = await runFeedPush();
      if (!id) break;
      pushed.add(id);
    }
    assert.ok(!pushed.has("old") && !pushed.has("off"));
  });
});
