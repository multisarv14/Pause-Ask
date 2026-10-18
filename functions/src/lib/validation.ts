import { z } from "zod";

import { LIMITS } from "../config";
import { Reason, fail } from "./errors";
import { isValidTimeZone } from "./zonedTime";

/** Firestore document ids / Firebase uids: no "/" or path tricks. */
export const docId = z.string().regex(/^[A-Za-z0-9_-]{1,128}$/);

/** Parses callable input; anything invalid becomes HttpsError [reason]. */
export function parse<T extends z.ZodType>(
  schema: T,
  data: unknown,
  reason: Reason = "INVALID_ARGUMENT",
): z.output<T> {
  const result = schema.safeParse(data ?? {});
  if (!result.success) fail(reason);
  return result.data;
}

export const schemas = {
  createCircle: z.object({
    name: z.string().trim().min(1).max(LIMITS.maxCircleNameLength),
  }),
  /** Format is checked later by normalizeInviteCode (→ INVALID_CODE). */
  joinCircle: z.object({ code: z.string().max(32) }),
  removeMember: z.object({ uid: docId }),
  analyzeCheck: z.object({
    source: z.enum(["share", "image", "voice", "typed"]),
    language: z.enum(["en", "hi", "mr"]),
  }),
  respondToCheck: z.object({
    checkId: docId,
    type: z.enum(["STOP", "OK", "CALL"]),
  }),
  deleteCheck: z.object({ checkId: docId }),
  saveCheckinSettings: z.object({
    enabled: z.boolean(),
    time: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/),
    alertAfterHours: z.number().int().min(1).max(24),
    timezone: z.string().refine(isValidTimeZone),
  }),
  updateRoles: z.object({
    roles: z
      .array(z.enum(["protected", "guardian"]))
      .min(1)
      .max(2)
      .refine((r) => new Set(r).size === r.length),
  }),
};
