// Runs the ticket's 7 test cases in en / hi / mr against analyzeCheck
// in a running emulator and flags anything that breaks the rules.
//
//   firebase emulators:start --only auth,firestore,functions --project <id>
//   node scripts/try-analyze.mjs [projectId]
//
// With --project demo-pauseask the fake LLM is used. With your real project
// id and functions/.secret.local containing GEMINI_API_KEY=..., real Gemini
// is called (see CLAUDE.md).
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= "127.0.0.1:9099";
process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";

import { initializeApp as initAdmin } from "firebase-admin/app";
import { getAuth as adminAuth } from "firebase-admin/auth";
import { getFirestore as adminDb } from "firebase-admin/firestore";
import { initializeApp } from "firebase/app";
import { connectAuthEmulator, getAuth, signInWithCustomToken } from "firebase/auth";
import { connectFunctionsEmulator, getFunctions, httpsCallable } from "firebase/functions";

import { containsSafeVerdict } from "../lib/checks/checkResult.js";

const projectId = process.argv[2] ?? process.env.GCLOUD_PROJECT ?? "demo-pauseask";
initAdmin({ projectId });
const db = adminDb();

const CASES = [
  ["This is CBI. Your Aadhaar is linked to money laundering. Stay on video call, transfer ₹50,000 to the safe account.", ["HIGH"]],
  ["Your electricity will be disconnected tonight. Call 98XXXXXXXX immediately.", ["HIGH"]],
  ["Hi Mum, my phone broke, this is my new number, need ₹5000 urgently", ["HIGH", "SUSPICIOUS"]],
  ["Earn ₹3000 daily by liking YouTube videos, join our Telegram", ["HIGH"]],
  ["Your OTP is 482913. Do not share it with anyone.", ["BE_CAREFUL"]],
  ["Happy birthday beta, see you Sunday", ["BE_CAREFUL"]],
];
const SAFE_WORDS = /\b(safe|genuine|legitimate)\b|सुरक्षित|असली|खरा/i;

let problems = 0;
for (const language of ["en", "hi", "mr"]) {
  const uid = `try-${language}`;
  await db.doc(`users/${uid}`).set({ name: `Try ${language}`, roles: ["protected"] }, { merge: true });
  const usage = await db.collection("usage").where("uid", "==", uid).get();
  await Promise.all(usage.docs.map((d) => d.ref.delete()));

  const app = initializeApp({ projectId, apiKey: "fake-key" }, uid);
  const auth = getAuth(app);
  connectAuthEmulator(auth, "http://127.0.0.1:9099", { disableWarnings: true });
  await signInWithCustomToken(auth, await adminAuth().createCustomToken(uid));
  const fns = getFunctions(app, "asia-south1");
  connectFunctionsEmulator(fns, "127.0.0.1", 5001);
  const analyze = httpsCallable(fns, "analyzeCheck", { timeout: 70_000 });

  console.log(`\n══════════ ${language.toUpperCase()} ══════════`);
  for (const [i, [text, expected]] of CASES.entries()) {
    const { data } = await analyze({ text, source: "typed", language });
    const r = data.result;
    const check = (await db.doc(`checks/${data.checkId}`).get()).data();
    const issues = [];
    if (!expected.includes(r.riskLevel)) issues.push(`expected ${expected.join("/")}`);
    if (containsSafeVerdict(r)) issues.push("SAFE VERDICT");
    if (SAFE_WORDS.test(r.summary)) issues.push(`summary mentions safe/genuine — read it`);
    if (check.aiStatus !== "ok") issues.push(`AI ${check.aiStatus}`);
    // Money amounts (₹5000) are kept on purpose; any other 4+ digit run is a leak.
    if (/\d{4,}/.test(check.maskedText.replace(/(?:₹|Rs\.?)\s?[\d,]+/g, ""))) issues.push("raw digits stored");
    problems += issues.length;
    console.log(`\n#${i + 1} ${r.riskLevel}  (${r.scamType})  ${issues.length ? "⚠️  " + issues.join("; ") : "✓"}`);
    console.log(`   masked: ${check.maskedText}`);
    console.log(`   summary: ${r.summary}`);
    r.redFlags.forEach((f) => console.log(`   ! ${f}`));
    r.whatToDo.forEach((w, n) => console.log(`   ${n + 1}. ${w}`));
  }

  console.log(`\n#7 validation:`);
  for (const [label, text] of [["empty", ""], ["5000 chars", "x".repeat(5000)]]) {
    try {
      await analyze({ text, source: "typed", language });
      console.log(`   ${label}: ⚠️  accepted`);
      problems++;
    } catch (e) {
      console.log(`   ${label}: rejected with ${e.details?.reason} ✓`);
    }
  }
}
console.log(`\n${problems === 0 ? "All cases OK" : `${problems} issue(s) to review`}`);
process.exit(problems === 0 ? 0 : 1);
