const IST_OFFSET_MS = (5 * 60 + 30) * 60 * 1000;

/** Calendar day in Asia/Kolkata as yyyymmdd (India has no DST). */
export function istDayKey(date: Date = new Date()): string {
  return new Date(date.getTime() + IST_OFFSET_MS)
    .toISOString()
    .slice(0, 10)
    .replace(/-/g, "");
}
