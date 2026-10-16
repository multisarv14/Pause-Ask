import assert from "node:assert/strict";
import { test } from "node:test";

import { istDayKey } from "../lib/lib/istDay.js";
import { maskText } from "../lib/lib/masking.js";

const cases = [
  // phones
  ["Call 9876543210 now", "Call [PHONE] now"],
  ["Call +91 98765 43210 now", "Call [PHONE] now"],
  ["Call +91-9876543210", "Call [PHONE]"],
  ["Call 09876543210", "Call [PHONE]"],
  ["Call 98XXXXXXXX immediately", "Call [PHONE] immediately"],
  ["UK: +44 7700 900123", "UK: [PHONE]"],
  // codes
  ["Your OTP is 482913. Do not share it.", "Your OTP is [CODE]. Do not share it."],
  ["PIN 1234", "PIN [CODE]"],
  ["code 12345678", "code [CODE]"],
  // accounts / cards / Aadhaar
  ["A/c 123456789012 debited", "A/c [ACCOUNT] debited"],
  ["Card 4111 1111 1111 1111", "Card [ACCOUNT]"],
  ["Aadhaar 1234-5678-9012", "Aadhaar [ACCOUNT]"],
  // UPI + email
  ["Pay to ramesh.k@okaxis", "Pay to [UPI]"],
  ["Pay to 9876543210@ybl", "Pay to [UPI]"],
  ["Mail me at help.desk@bank-secure.com", "Mail me at [EMAIL]"],
  // money amounts are kept
  ["Transfer ₹50,000 to the safe account", "Transfer ₹50,000 to the safe account"],
  ["Earn ₹3000 daily", "Earn ₹3000 daily"],
  ["pay Rs. 5000 or Rs 2500", "pay Rs. 5000 or Rs 2500"],
  ["need 5000 rupees", "need 5000 rupees"],
];

for (const [input, expected] of cases) {
  test(`masks: ${input}`, () => assert.equal(maskText(input), expected));
}

test("keeps URL domain, strips query string and fragment", () => {
  assert.equal(
    maskText("Update KYC: https://sbi-kyc-update.in/verify?id=9876543210&otp=1234#top now"),
    "Update KYC: https://sbi-kyc-update.in/verify now",
  );
});

test("keeps domains with digits and trailing punctuation", () => {
  assert.equal(maskText("Visit www.win2024prize.com."), "Visit www.win2024prize.com.");
});

test("masks numbers inside a URL path", () => {
  assert.equal(maskText("Chat: https://wa.me/919876543210"), "Chat: https://wa.me/[PHONE]");
});

test("no raw digits of 4+ left in a mixed message", () => {
  const out = maskText(
    "Dear customer, a/c 50100234567890 blocked. OTP 739201. Call 8899776655 or mail kyc@hdfc-help.co. UPI: refund@paytm",
  );
  assert.doesNotMatch(out, /\d{4,}/);
  for (const t of ["[ACCOUNT]", "[CODE]", "[PHONE]", "[EMAIL]", "[UPI]"]) assert.ok(out.includes(t), t);
});

test("Hindi / Marathi text stays readable", () => {
  assert.equal(maskText("आपका OTP 482913 है"), "आपका OTP [CODE] है");
  assert.equal(maskText("माझा नंबर 9876543210 आहे"), "माझा नंबर [PHONE] आहे");
});

test("IST day rolls over at 18:30 UTC", () => {
  assert.equal(istDayKey(new Date("2026-10-16T18:29:59Z")), "20261016");
  assert.equal(istDayKey(new Date("2026-10-16T18:30:00Z")), "20261017");
});
