/**
 * Removes private data from a message before it is sent to the AI.
 *
 * - Emails → [EMAIL], UPI IDs → [UPI], phone numbers → [PHONE],
 *   long digit runs (cards, accounts, Aadhaar) → [ACCOUNT],
 *   4–8 digit codes (OTP, PIN) → [CODE].
 * - URLs are kept because the domain matters for scam detection, but query
 *   strings / fragments are dropped and numbers in the path are masked.
 * - Money amounts (₹5000, Rs. 5000, 5000 rupees) are kept: they matter too.
 */

const URL_RE = /\b(?:https?:\/\/|www\.)[^\s<>"'()]+/gi;
const TRAILING_PUNCT_RE = /[.,!?;:]+$/;

const EMAIL_RE = /[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+/g;
// name@okaxis, 98765@ybl — handle without a dot after the @.
const UPI_RE = /[A-Za-z0-9._-]{2,}@[A-Za-z]{2,}(?![A-Za-z0-9.])/g;

// Already partly hidden numbers, e.g. 98XXXXXXXX or +91 98****1234.
const PARTIAL_PHONE_RE = /(?<![\w])(?:\+?91[\s-]?)?[6-9]\d{0,4}[Xx*]{4,9}\d{0,4}(?![\w])/g;
// International: +44 7700 900123, 0044 7700900123.
const INTL_PHONE_RE = /(?<![\w+])(?:\+|00)\d{1,3}(?:[\s-]?\d){6,12}(?!\d)/g;
// Indian mobile with optional +91 / 91 / 0 prefix, spaces or dashes allowed.
const IN_PHONE_RE = /(?<!\d)(?:(?:\+|00)?91[\s-]?|0)?[6-9](?:[\s-]?\d){9}(?!\d)/g;
// 9+ digits, optionally grouped: card, account, Aadhaar numbers.
const ACCOUNT_RE = /(?<!\d)\d(?:[\s-]?\d){8,}(?!\d)/g;
// 4–8 digits that are not a money amount.
const CODE_RE =
  /(?<![\d₹$])(?<!(?:Rs|RS|rs|INR|Rs\.|rs\.)\s?)(?<!₹\s)\b\d{4,8}\b(?!\s?(?:\/-|rs\b|Rs\b|rupees|रुपये|रुपए|रुपय))/g;

function maskPlainText(text: string): string {
  return text
    .replace(EMAIL_RE, "[EMAIL]")
    .replace(UPI_RE, "[UPI]")
    .replace(PARTIAL_PHONE_RE, "[PHONE]")
    .replace(INTL_PHONE_RE, "[PHONE]")
    .replace(IN_PHONE_RE, "[PHONE]")
    .replace(ACCOUNT_RE, "[ACCOUNT]")
    .replace(CODE_RE, "[CODE]");
}

/** Keeps scheme + host; drops ?query and #fragment; masks numbers in the path. */
function maskUrl(url: string): string {
  const withoutQuery = url.replace(/[?#].*$/, "");
  const m = withoutQuery.match(/^((?:https?:\/\/)?[^/]+)(.*)$/i);
  if (!m) return withoutQuery;
  const [, host, path] = m;
  return host + maskPlainText(path);
}

export function maskText(input: string): string {
  const urls: string[] = [];
  // Park URLs so the digit rules below can't touch their domains.
  const parked = input.replace(URL_RE, (match) => {
    const trailing = match.match(TRAILING_PUNCT_RE)?.[0] ?? "";
    const url = trailing ? match.slice(0, -trailing.length) : match;
    urls.push(maskUrl(url));
    return `\u0001${urls.length - 1}\u0001${trailing}`;
  });
  return maskPlainText(parked).replace(
    /\u0001(\d+)\u0001/g,
    (_, i: string) => urls[Number(i)],
  );
}
