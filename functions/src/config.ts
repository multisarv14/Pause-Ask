/** Region and free-plan limits. Mirrored for display in lib/core/constants. */
export const REGION = "asia-south1";

export const LIMITS = {
  /** Enforced by the memberships/{uid} doc: one per user. */
  maxCirclesPerUser: 1,
  maxCircleMembers: 5,
  maxCircleNameLength: 40,
  inviteTtlDays: 7,
  /** An invite can bring in at most this many people. */
  inviteUses: 4,
  /** Reuse an existing invite only if it is valid for at least this long. */
  inviteReuseMinRemainingHours: 24,
  /** Wrong join codes allowed per user per hour (brute-force guard). */
  joinFailuresPerHour: 10,
  /** AI checks per user per calendar day (Asia/Kolkata). */
  maxChecksPerDay: 10,
  maxCheckTextLength: 4000,
  checkRetentionDays: 30,
  llmTimeoutMs: 25_000,
  sosPerHour: 5,
} as const;
