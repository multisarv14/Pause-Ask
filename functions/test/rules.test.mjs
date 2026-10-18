// Firestore security rules: allow + deny cases for every collection.
// Runs inside `npm run test:emulator` (Firestore emulator).
import { readFileSync } from "node:fs";
import { after, before, describe, test } from "node:test";

import { assertFails, assertSucceeds, initializeTestEnvironment } from "@firebase/rules-unit-testing";
import {
  Timestamp, collection, deleteDoc, doc, getDoc, getDocs, orderBy, query, serverTimestamp,
  setDoc, updateDoc, where,
} from "firebase/firestore";

if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Run via `npm run test:emulator`.");
const [host, port] = process.env.FIRESTORE_EMULATOR_HOST.split(":");

let env;
const as = (uid, phone = "+919999900001") => env.authenticatedContext(uid, { phone_number: phone }).firestore();
const anon = () => env.unauthenticatedContext().firestore();

const profile = (over = {}) => ({
  name: "Asha", phone: "+919999900001", roles: ["protected"], language: "mr", largeText: false,
  consentVersion: 1, consentAcceptedAt: Timestamp.now(), fcmToken: null, createdAt: serverTimestamp(), ...over,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-pauseask",
    firestore: { host, port: Number(port), rules: readFileSync("../firestore.rules", "utf8") },
  });
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "users/rt-owner"), { ...profile(), createdAt: Timestamp.now(), checkin: { enabled: true } });
    await setDoc(doc(db, "users/rt-other"), { ...profile({ name: "Other" }), createdAt: Timestamp.now() });
    await setDoc(doc(db, "circles/rt-c"), { name: "RT", ownerUid: "rt-owner", memberUids: ["rt-owner", "rt-member"] });
    await setDoc(doc(db, "circles/rt-c/members/rt-owner"), { name: "Asha", roles: ["protected"], phone: "+91..." });
    await setDoc(doc(db, "circles/rt-c/members/rt-member"), { name: "Ravi", roles: ["guardian"] });
    await setDoc(doc(db, "checks/rt-k"), { uid: "rt-owner", circleId: "rt-c", maskedText: "x", createdAt: Timestamp.now(), guardianResponse: null });
    await setDoc(doc(db, "checks/rt-solo"), { uid: "rt-other", circleId: null, maskedText: "y", createdAt: Timestamp.now(), guardianResponse: null });
    await setDoc(doc(db, "scamFeed/rt-f"), { active: true, publishedAt: Timestamp.now(), title: { en: "t" } });
    for (const p of ["invites/RTCODE", "memberships/rt-owner", "joinAttempts/rt-owner", "usage/rt-owner_20261017",
      "sosUsage/rt-owner", "rateLimits/rt-owner_testAlert", "_pushLog/rt-p"]) {
      await setDoc(doc(db, p), { uid: "rt-owner" });
    }
  });
});
after(async () => env?.cleanup());

describe("users/{uid}", () => {
  test("owner reads own profile; others and signed-out can't", async () => {
    await assertSucceeds(getDoc(doc(as("rt-owner"), "users/rt-owner")));
    await assertFails(getDoc(doc(as("rt-member"), "users/rt-owner")));
    await assertFails(getDoc(doc(anon(), "users/rt-owner")));
  });

  test("create: only own doc, valid shape, own phone, server time, no checkin", async () => {
    const me = as("rt-new");
    await assertFails(setDoc(doc(me, "users/rt-new"), profile({ phone: "+910000000000" })));
    await assertFails(setDoc(doc(me, "users/rt-new"), profile({ roles: ["admin"] })));
    await assertFails(setDoc(doc(me, "users/rt-new"), profile({ language: "fr" })));
    await assertFails(setDoc(doc(me, "users/rt-new"), profile({ isAdmin: true })));
    await assertFails(setDoc(doc(me, "users/rt-new"), profile({ createdAt: Timestamp.fromMillis(0) })));
    await assertFails(setDoc(doc(me, "users/rt-new"), profile({ checkin: { enabled: true } })));
    await assertFails(setDoc(doc(me, "users/rt-someone"), profile()));
    await assertSucceeds(setDoc(doc(me, "users/rt-new"), profile()));
  });

  test("update: own settings OK; phone, createdAt, roles, checkin locked; others can't", async () => {
    const me = as("rt-owner");
    await assertSucceeds(updateDoc(doc(me, "users/rt-owner"), { language: "hi", largeText: true, fcmToken: "fid" }));
    await assertFails(updateDoc(doc(me, "users/rt-owner"), { phone: "+910000000000" }));
    await assertFails(updateDoc(doc(me, "users/rt-owner"), { createdAt: Timestamp.now() }));
    await assertFails(updateDoc(doc(me, "users/rt-owner"), { roles: ["guardian"] }));
    await assertFails(updateDoc(doc(me, "users/rt-owner"), { "checkin.enabled": false }));
    await assertFails(updateDoc(doc(me, "users/rt-owner"), { name: "" }));
    await assertFails(updateDoc(doc(as("rt-member"), "users/rt-owner"), { name: "Hacked" }));
  });

  test("no client deletes (deleteMyAccount only)", async () => {
    await assertFails(deleteDoc(doc(as("rt-owner"), "users/rt-owner")));
  });
});

describe("circles and members", () => {
  test("members read the circle and member list; outsiders can't", async () => {
    await assertSucceeds(getDoc(doc(as("rt-member"), "circles/rt-c")));
    await assertSucceeds(getDocs(query(collection(as("rt-member"), "circles"), where("memberUids", "array-contains", "rt-member"))));
    await assertSucceeds(getDocs(collection(as("rt-member"), "circles/rt-c/members")));
    await assertFails(getDoc(doc(as("rt-out"), "circles/rt-c")));
    await assertFails(getDocs(collection(as("rt-out"), "circles/rt-c/members")));
    await assertFails(getDoc(doc(anon(), "circles/rt-c")));
  });

  test("nobody writes circles or members from the app (not even the owner)", async () => {
    const owner = as("rt-owner");
    await assertFails(updateDoc(doc(owner, "circles/rt-c"), { name: "x" }));
    await assertFails(updateDoc(doc(owner, "circles/rt-c"), { memberUids: ["rt-owner", "rt-out"] }));
    await assertFails(setDoc(doc(as("rt-out"), "circles/rt-new"), { ownerUid: "rt-out", memberUids: ["rt-out"] }));
    await assertFails(setDoc(doc(owner, "circles/rt-c/members/rt-out"), { name: "x", roles: ["guardian"] }));
    await assertFails(updateDoc(doc(as("rt-member"), "circles/rt-c/members/rt-member"), { roles: ["protected", "guardian"] }));
    await assertFails(deleteDoc(doc(owner, "circles/rt-c/members/rt-member")));
  });
});

describe("checks", () => {
  test("asker and circle members read; non-members can't", async () => {
    await assertSucceeds(getDoc(doc(as("rt-owner"), "checks/rt-k")));
    await assertSucceeds(getDoc(doc(as("rt-member"), "checks/rt-k")));
    await assertFails(getDoc(doc(as("rt-out"), "checks/rt-k")));
    await assertFails(getDoc(doc(as("rt-member"), "checks/rt-solo")));
    await assertFails(getDoc(doc(anon(), "checks/rt-k")));
  });

  test("list queries: own checks and circle checks only", async () => {
    await assertSucceeds(getDocs(query(collection(as("rt-owner"), "checks"), where("uid", "==", "rt-owner"), orderBy("createdAt", "desc"))));
    await assertSucceeds(getDocs(query(collection(as("rt-member"), "checks"), where("circleId", "==", "rt-c"))));
    await assertFails(getDocs(query(collection(as("rt-out"), "checks"), where("circleId", "==", "rt-c"))));
    await assertFails(getDocs(query(collection(as("rt-out"), "checks"), where("uid", "==", "rt-owner"))));
    await assertFails(getDocs(collection(as("rt-owner"), "checks")));
  });

  test("no client writes: not guardianResponse, not create, not delete", async () => {
    await assertFails(updateDoc(doc(as("rt-member"), "checks/rt-k"), { guardianResponse: { type: "OK", byUid: "rt-member" } }));
    await assertFails(updateDoc(doc(as("rt-owner"), "checks/rt-k"), { maskedText: "changed" }));
    await assertFails(setDoc(doc(as("rt-owner"), "checks/rt-new"), { uid: "rt-owner", circleId: "rt-c" }));
    await assertFails(deleteDoc(doc(as("rt-owner"), "checks/rt-k")));
  });
});

describe("scamFeed", () => {
  test("signed-in users read; signed-out can't; nobody writes", async () => {
    await assertSucceeds(getDoc(doc(as("rt-out"), "scamFeed/rt-f")));
    await assertSucceeds(getDocs(query(collection(as("rt-out"), "scamFeed"), where("active", "==", true))));
    await assertFails(getDoc(doc(anon(), "scamFeed/rt-f")));
    await assertFails(setDoc(doc(as("rt-owner"), "scamFeed/rt-x"), { active: true }));
    await assertFails(updateDoc(doc(as("rt-owner"), "scamFeed/rt-f"), { active: false }));
    await assertFails(deleteDoc(doc(as("rt-owner"), "scamFeed/rt-f")));
  });
});

describe("server-only collections", () => {
  for (const path of ["invites/RTCODE", "memberships/rt-owner", "joinAttempts/rt-owner",
    "usage/rt-owner_20261017", "sosUsage/rt-owner", "rateLimits/rt-owner_testAlert", "_pushLog/rt-p"]) {
    test(`${path.split("/")[0]}: no read or write, even for the owner`, async () => {
      const me = as("rt-owner");
      await assertFails(getDoc(doc(me, path)));
      await assertFails(setDoc(doc(me, path), { uid: "rt-owner" }));
      await assertFails(deleteDoc(doc(me, path)));
    });
  }

  test("unknown collections are locked", async () => {
    await assertFails(setDoc(doc(as("rt-owner"), "anything/x"), { a: 1 }));
    await assertFails(getDoc(doc(as("rt-owner"), "anything/x")));
  });
});
