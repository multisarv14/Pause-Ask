import { defineBoolean } from "firebase-functions/params";
import { CallableOptions, CallableRequest, onCall } from "firebase-functions/v2/https";

/**
 * App Check for every callable. Off by default; set ENFORCE_APP_CHECK=true
 * in functions/.env and redeploy once the release build is verified.
 */
export const ENFORCE_APP_CHECK = defineBoolean("ENFORCE_APP_CHECK", { default: false });

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Handler<T> = (req: CallableRequest<any>) => T | Promise<T>;

/** onCall with our shared options (App Check). */
export function callable<T>(handler: Handler<T>, options: CallableOptions = {}) {
  // invoker "public": the app must be able to reach the function at all;
  // access control happens inside (auth, App Check, validation, rules).
  return onCall({ invoker: "public", enforceAppCheck: ENFORCE_APP_CHECK, ...options }, handler);
}
