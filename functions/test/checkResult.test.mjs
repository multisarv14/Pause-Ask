import assert from "node:assert/strict";
import { test } from "node:test";

import { containsSafeVerdict, parseCheckResult } from "../lib/checks/checkResult.js";

const valid = {
  riskLevel: "HIGH",
  scamType: "Digital arrest",
  redFlags: ["Fake CBI officer", "Asks for money"],
  whatToDo: ["Do not pay.", "Call 1930 cyber helpline.", "Tell your family."],
  summary: "This looks like a digital arrest scam.",
};

test("valid JSON passes", () => {
  const r = parseCheckResult(JSON.stringify(valid), "en");
  assert.equal(r.ok, true);
  assert.equal(r.result.riskLevel, "HIGH");
});

test("```json fences are tolerated", () => {
  assert.equal(parseCheckResult("```json\n" + JSON.stringify(valid) + "\n```", "en").ok, true);
});

test("extra red flags / actions are trimmed", () => {
  const r = parseCheckResult(
    JSON.stringify({ ...valid, redFlags: ["1", "2", "3", "4", "5", "6", "7"], whatToDo: ["a", "b", "c", "d"] }),
    "en",
  );
  assert.equal(r.ok, true);
  assert.equal(r.result.redFlags.length, 5);
  assert.equal(r.result.whatToDo.length, 3);
});

const invalid = {
  "not JSON": "I think this is a scam",
  "SAFE risk level": JSON.stringify({ ...valid, riskLevel: "SAFE" }),
  "LOW risk level": JSON.stringify({ ...valid, riskLevel: "LOW" }),
  "only 2 actions": JSON.stringify({ ...valid, whatToDo: ["a", "b"] }),
  "missing summary": JSON.stringify({ ...valid, summary: undefined }),
  "empty scamType": JSON.stringify({ ...valid, scamType: "  " }),
  "array instead of object": "[]",
};
for (const [name, raw] of Object.entries(invalid)) {
  for (const lang of ["en", "hi", "mr"]) {
    test(`${name} → BE_CAREFUL fallback (${lang})`, () => {
      const r = parseCheckResult(raw, lang);
      assert.equal(r.ok, false);
      assert.equal(r.result.riskLevel, "BE_CAREFUL");
      assert.equal(r.result.whatToDo.length, 3);
    });
  }
}

test("fallback is in the requested language", () => {
  assert.match(parseCheckResult("x", "hi").result.summary, /[ऀ-ॿ]/);
  assert.match(parseCheckResult("x", "mr").result.summary, /तपासू/);
  assert.match(parseCheckResult("x", "en").result.summary, /could not check/);
});

const safeVerdicts = [
  "This message is safe.",
  "It looks genuine.",
  "This is not a scam.",
  "There is no risk here.",
  "यह मैसेज सुरक्षित है।",
  "यह असली लगता है।",
  "यह स्कैम नहीं है।",
  "हा मेसेज सुरक्षित आहे.",
  "हा मेसेज खरा वाटतो.",
  "ही फसवणूक नाही.",
];
for (const summary of safeVerdicts) {
  test(`"safe" verdict is rejected: ${summary}`, () => {
    const r = parseCheckResult(JSON.stringify({ ...valid, riskLevel: "BE_CAREFUL", summary }), "en");
    assert.equal(r.ok, false);
    assert.equal(r.reason, "safe_verdict");
  });
}

test("'safe account' as a red flag is not a verdict", () => {
  assert.equal(
    containsSafeVerdict({ ...valid, redFlags: ["Asks you to move money to a 'safe account'"] }),
    false,
  );
});
