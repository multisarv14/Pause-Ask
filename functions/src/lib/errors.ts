import { FunctionsErrorCode, HttpsError } from "firebase-functions/v2/https";

/**
 * Error reasons the app understands. Sent as both the message and
 * `details.reason`; the app maps them to localized text.
 */
export const REASONS = {
  UNAUTHENTICATED: "unauthenticated",
  PROFILE_MISSING: "failed-precondition",
  INVALID_NAME: "invalid-argument",
  INVALID_ARGUMENT: "invalid-argument",
  ALREADY_IN_CIRCLE: "failed-precondition",
  ALREADY_MEMBER: "already-exists",
  NOT_IN_CIRCLE: "failed-precondition",
  CIRCLE_FULL: "resource-exhausted",
  INVALID_CODE: "not-found",
  CODE_EXPIRED: "deadline-exceeded",
  CODE_USED_UP: "resource-exhausted",
  NOT_OWNER: "permission-denied",
  CANNOT_REMOVE_SELF: "failed-precondition",
  MEMBER_NOT_FOUND: "not-found",
  TOO_MANY_ATTEMPTS: "resource-exhausted",
  INVALID_TEXT: "invalid-argument",
  TEXT_TOO_LONG: "invalid-argument",
  DAILY_LIMIT_REACHED: "resource-exhausted",
  CHECK_NOT_FOUND: "not-found",
  NOT_GUARDIAN: "permission-denied",
  SOS_LIMIT: "resource-exhausted",
  TOO_MANY_REQUESTS: "resource-exhausted",
  INVALID_SETTINGS: "invalid-argument",
} as const satisfies Record<string, FunctionsErrorCode>;

export type Reason = keyof typeof REASONS;

export function fail(reason: Reason): never {
  throw new HttpsError(REASONS[reason], reason, { reason });
}

export function isReason(error: unknown, reason: Reason): boolean {
  return error instanceof HttpsError && error.message === reason;
}
