import "./setup";

import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { REGION } from "./config";

/** Simple liveness probe: GET → { status: "ok", ... }. */
export const healthCheck = onRequest((req, res) => {
  logger.info("healthCheck called", { method: req.method });
  res.json({
    status: "ok",
    service: "pauseask-functions",
    region: REGION,
    time: new Date().toISOString(),
  });
});

export {
  createCircle,
  createInvite,
  joinCircle,
  leaveCircle,
  removeMember,
} from "./circles/circles";

export { analyzeCheck } from "./checks/analyzeCheck";
export { onCheckCreated, respondToCheck } from "./checks/guardianAlerts";
export { checkIn, checkMissedCheckins, saveCheckinSettings } from "./checkins/checkins";
export { sendSos } from "./sos/sos";
export { deleteCheck } from "./checks/deleteCheck";
export { weeklyFeedPush } from "./feed/feedPush";
export { deleteMyAccount, sendTestAlert, updateRoles } from "./account/account";
