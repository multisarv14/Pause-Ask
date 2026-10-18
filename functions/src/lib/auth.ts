import { CallableRequest } from "firebase-functions/v2/https";

import { fail } from "./errors";

export function requireUid(req: CallableRequest): string {
  if (!req.auth) fail("UNAUTHENTICATED");
  return req.auth.uid;
}
