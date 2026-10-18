import { localDate, zonedToUtc } from "../lib/zonedTime";

export interface CheckinSettings {
  enabled: boolean;
  /** "HH:MM", local to [timezone]. */
  time: string;
  alertAfterHours: number;
  timezone: string;
  lastCheckinAt?: number | null;
  /** Local "yyyy-mm-dd" of the last missed alert sent. */
  lastMissedAlertDate?: string | null;
  updatedAt?: number | null;
}

export const DEFAULT_CHECKIN = {
  enabled: true,
  time: "09:00",
  alertAfterHours: 12,
} as const;

/**
 * Returns the local day ("yyyy-mm-dd") a missed-check-in alert is due for,
 * or null. A day is missed when its check-in time + alertAfterHours has
 * passed, nobody checked in since that day started, no alert was sent for
 * it (or a later day) yet, and the settings were not changed during that day
 * (changes apply from the next day). Yesterday is also looked at because the
 * deadline can fall after midnight.
 */
export function dueMissedDay(now: number, s: CheckinSettings): string | null {
  if (!s.enabled) return null;
  const [hh, mm] = s.time.split(":").map(Number);
  for (const offset of [0, -1]) {
    const day = localDate(now, s.timezone, offset);
    const dayStart = zonedToUtc(day.y, day.m, day.d, 0, 0, s.timezone);
    const scheduled = zonedToUtc(day.y, day.m, day.d, hh, mm, s.timezone);
    const deadline = scheduled + s.alertAfterHours * 3_600_000;

    if (now < deadline) continue;
    if (s.updatedAt != null && s.updatedAt > dayStart) continue;
    if (s.lastCheckinAt != null && s.lastCheckinAt >= dayStart) continue;
    if (s.lastMissedAlertDate != null && s.lastMissedAlertDate >= day.key) continue;
    return day.key;
  }
  return null;
}
