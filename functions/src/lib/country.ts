/**
 * ISO country from an E.164 phone number (users don't pick a country).
 * Only the prefixes we expect early on; anything else is "OTHER", which
 * still gets feed items marked "ALL".
 */
const PREFIXES: [string, string][] = [
  ["+91", "IN"], ["+977", "NP"], ["+971", "AE"], ["+966", "SA"], ["+974", "QA"],
  ["+965", "KW"], ["+968", "OM"], ["+973", "BH"], ["+65", "SG"], ["+60", "MY"],
  ["+44", "GB"], ["+61", "AU"], ["+64", "NZ"], ["+1", "US"],
];

export function countryFromPhone(phone: unknown): string {
  if (typeof phone !== "string") return "OTHER";
  const p = phone.replace(/\s/g, "");
  // Longest prefix first so +971 doesn't match a shorter one.
  for (const [prefix, cc] of [...PREFIXES].sort((a, b) => b[0].length - a[0].length)) {
    if (p.startsWith(prefix)) return cc;
  }
  return "OTHER";
}

export function feedMatchesCountry(countryCodes: unknown, country: string): boolean {
  if (!Array.isArray(countryCodes)) return false;
  return countryCodes.includes("ALL") || countryCodes.includes(country);
}
