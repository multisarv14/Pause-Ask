// Imported first by every module that defines functions, so these options
// apply regardless of import order.
import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";

import { REGION } from "./config";

initializeApp();

// All PauseAsk functions run in Mumbai.
setGlobalOptions({ region: REGION, maxInstances: 10 });
