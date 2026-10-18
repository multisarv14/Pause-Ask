import "../setup";

import * as logger from "firebase-functions/logger";

import { requireUid } from "../lib/auth";
import { callable } from "../lib/callable";
import { fail } from "../lib/errors";
import { refs } from "../lib/refs";
import { parse, schemas } from "../lib/validation";

/** deleteCheck({ checkId }) → { deleted: true }. Only the person who asked. */
export const deleteCheck = callable(async (req) => {
  const uid = requireUid(req);
  const { checkId } = parse(schemas.deleteCheck, req.data);
  const ref = refs.checks().doc(checkId);
  const snap = await ref.get();
  if (!snap.exists) fail("CHECK_NOT_FOUND");
  if (snap.data()!.uid !== uid) fail("NOT_OWNER");
  await ref.delete();
  logger.info("check deleted", { uid, checkId });
  return { deleted: true };
});
