import assert from "node:assert/strict";
import { test } from "node:test";

import {
  INVITE_ALPHABET,
  generateInviteCode,
  normalizeInviteCode,
} from "../lib/lib/inviteCode.js";

test("alphabet has no look-alike characters", () => {
  for (const ch of "0O1IL") assert.ok(!INVITE_ALPHABET.includes(ch), ch);
});

test("generated codes are 6 valid characters", () => {
  for (let i = 0; i < 1000; i++) {
    const code = generateInviteCode();
    assert.equal(code.length, 6);
    assert.equal(normalizeInviteCode(code), code);
  }
});

test("normalize accepts lowercase, spaces and dashes", () => {
  assert.equal(normalizeInviteCode(" abc-dEf "), "ABCDEF");
  assert.equal(normalizeInviteCode("AB CD 23"), "ABCD23");
});

test("normalize rejects bad input", () => {
  assert.equal(normalizeInviteCode("ABC"), null);
  assert.equal(normalizeInviteCode("ABCDE0"), null); // 0 not allowed
  assert.equal(normalizeInviteCode(123456), null);
  assert.equal(normalizeInviteCode(undefined), null);
});
