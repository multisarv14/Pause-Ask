import assert from "node:assert/strict";
import { test } from "node:test";

import { dueMissedDay } from "../lib/checkins/missed.js";
import { localDate, zonedToUtc } from "../lib/lib/zonedTime.js";

const IST = "Asia/Kolkata";
const at = (iso) => Date.parse(iso); // ISO with explicit offset
const base = {
  enabled: true, time: "09:00", alertAfterHours: 12, timezone: IST,
  // Checked in yesterday morning; so only "today" can be missed.
  lastCheckinAt: at("2026-10-16T10:00:00+05:30"), lastMissedAlertDate: null,
  updatedAt: at("2026-10-01T10:00:00+05:30"),
};

test("zonedToUtc / localDate in IST", () => {
  assert.equal(zonedToUtc(2026, 10, 17, 9, 0, IST), at("2026-10-17T09:00:00+05:30"));
  assert.equal(localDate(at("2026-10-17T00:10:00+05:30"), IST).key, "2026-10-17");
  assert.equal(localDate(at("2026-10-17T00:10:00+05:30"), IST, -1).key, "2026-10-16");
});

test("zonedToUtc handles a DST zone", () => {
  // New York is UTC-4 in summer, UTC-5 in winter.
  assert.equal(zonedToUtc(2026, 7, 1, 9, 0, "America/New_York"), at("2026-07-01T09:00:00-04:00"));
  assert.equal(zonedToUtc(2026, 12, 1, 9, 0, "America/New_York"), at("2026-12-01T09:00:00-05:00"));
});

test("not due before 9:00 + 12h", () => {
  assert.equal(dueMissedDay(at("2026-10-17T20:59:00+05:30"), base), null);
});

test("due at 21:00 IST with no check-in today", () => {
  assert.equal(dueMissedDay(at("2026-10-17T21:00:00+05:30"), base), "2026-10-17");
});

test("check-in any time today prevents it", () => {
  const s = { ...base, lastCheckinAt: at("2026-10-17T07:30:00+05:30") };
  assert.equal(dueMissedDay(at("2026-10-17T22:00:00+05:30"), s), null);
});

test("a missed yesterday is still reported (deadline-after-midnight safety)", () => {
  assert.equal(dueMissedDay(at("2026-10-17T08:00:00+05:30"), { ...base, lastCheckinAt: null }), "2026-10-16");
});

test("yesterday's check-in does not count for today", () => {
  const s = { ...base, lastCheckinAt: at("2026-10-16T23:59:00+05:30"), lastMissedAlertDate: "2026-10-16" };
  assert.equal(dueMissedDay(at("2026-10-17T21:30:00+05:30"), s), "2026-10-17");
});

test("only one alert per day", () => {
  const s = { ...base, lastMissedAlertDate: "2026-10-17" };
  assert.equal(dueMissedDay(at("2026-10-17T23:00:00+05:30"), s), null);
});

test("disabled → never", () => {
  assert.equal(dueMissedDay(at("2026-10-17T23:00:00+05:30"), { ...base, enabled: false }), null);
});

test("settings changed today apply from tomorrow", () => {
  const s = { ...base, updatedAt: at("2026-10-17T08:00:00+05:30") };
  assert.equal(dueMissedDay(at("2026-10-17T23:00:00+05:30"), s), null);
  // Next day it applies.
  assert.equal(dueMissedDay(at("2026-10-18T21:00:00+05:30"), s), "2026-10-18");
});

test("a deadline after midnight alerts for the previous day", () => {
  const s = { ...base, time: "20:00", alertAfterHours: 6 }; // deadline 02:00 next day
  assert.equal(dueMissedDay(at("2026-10-18T01:59:00+05:30"), s), null);
  assert.equal(dueMissedDay(at("2026-10-18T02:00:00+05:30"), s), "2026-10-17");
  // ...and a check-in after midnight cancels that.
  assert.equal(
    dueMissedDay(at("2026-10-18T02:30:00+05:30"), { ...s, lastCheckinAt: at("2026-10-18T00:30:00+05:30") }),
    null,
  );
});

test("alertAfterHours = 1 for quick testing", () => {
  const s = { ...base, alertAfterHours: 1 };
  assert.equal(dueMissedDay(at("2026-10-17T09:59:00+05:30"), s), null);
  assert.equal(dueMissedDay(at("2026-10-17T10:00:00+05:30"), s), "2026-10-17");
});
