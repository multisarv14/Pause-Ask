# CLAUDE.md — PauseAsk – Family Scam Check

> Tagline: **"Pause. Ask family. Stay safe."**
> Keep this file updated at the end of every step.

## Product
PauseAsk helps families stop scams.

- A **Protected** user (elderly parent, less tech-savvy person) shares a suspicious
  message / screenshot / voice description.
- AI explains the risk **in their language**.
- The family **Circle** (Guardians) gets an instant alert and replies with one tap:
  - "STOP – I'll call you"
  - "I checked, it's OK"
  - "Call now"
- Also: **SOS** button, daily **"I'm OK" check-in** with missed-check-in alerts to
  guardians, **check history** (auto-deleted after 30 days), **"Scam of the day"**
  feed (admin-managed), **settings**.

## Golden rule (non-negotiable)
The AI must **NEVER** say a message is "safe". Only risk levels:
`HIGH` / `SUSPICIOUS` / `BE_CAREFUL`. **Only a human guardian can say "OK".**

## Scope of v1
- Free. Android first (iOS later). Languages: English (`en`), Hindi (`hi`), Marathi (`mr`).
- Free limits (**enforced server-side**): 1 circle per user, max 5 members per circle,
  10 AI checks per user per day.

## Stack
- Flutter (latest stable), **Riverpod** for state, **go_router** for navigation.
- Firebase: Auth (phone OTP), Cloud Firestore, Cloud Functions v2 (TypeScript), FCM.
- Region: **asia-south1**.
- Package name / applicationId: `com.multisarv.pauseask`.

## Privacy
- Only extracted text is sent to the server (OCR and speech-to-text run **on-device**).
- Phone numbers, OTPs and account numbers are **masked before the AI call**.
- **Never** put API keys in the app. Secrets live in Cloud Functions config/Secret Manager.

## Accessibility
- Large tap targets (min button height 56), base font size 18.
- "Large text" mode (text scale 1.0 / 1.3, stored in local prefs).
- Text-to-speech for results. Simple language.

## Architecture summary (v1.0.0)
- **App:** Flutter, Riverpod and go_router. Features live in `lib/features/*` (auth,
  onboarding, profile, home, check, guardian, circle, checkin, sos, history, feed, settings,
  legal). Cross-cutting code is in `lib/services/*` (firebase bootstrap + App Check + emulator
  switch, notifications, share intents, OCR, TTS) and `lib/core/*` (theme, router + startup
  guard, l10n, constants, errors, utils).
- **Backend:** Cloud Functions v2 (TypeScript, asia-south1) plus Firestore with strict rules.
  The app *reads* Firestore directly where rules allow. Every *write* except a user's own
  profile settings goes through a callable or trigger.
- **AI:** `analyzeCheck` masks the text, calls `LlmProvider` (Gemini; Anthropic stub; fake for
  tests), validates the JSON with zod, applies the never-"safe" guard, and stores the check
  for 30 days (TTL).
- **Pushes:** FCM to the Firebase Installation ID in `users/{uid}.fcmToken`, in the
  receiver's language, without message text. `PUSH_MODE=log` writes them to `_pushLog` in the
  emulator.
- **On-device only:** OCR (ML Kit Latin + Devanagari), speech-to-text, TTS, the daily
  reminder (local notification).
- **Security:** least-privilege rules (`firestore.rules`, tested in
  `functions/test/rules.test.mjs`); zod input validation on every callable
  (`functions/src/lib/validation.ts`); rate limits (10 checks/day, 10 wrong codes/h,
  5 SOS/h, 5 test alerts/h); App Check (wrapper `functions/src/lib/callable.ts`,
  `ENFORCE_APP_CHECK`).

### Cloud Functions
| Function | Type | Purpose |
|---|---|---|
| healthCheck | HTTPS | liveness |
| createCircle, createInvite, joinCircle, leaveCircle, removeMember | callable | family circle |
| analyzeCheck | callable (secret GEMINI_API_KEY) | AI risk check |
| onCheckCreated | Firestore trigger | push guardians |
| respondToCheck | callable | first guardian reply wins |
| deleteCheck | callable | owner deletes a check |
| checkIn, saveCheckinSettings | callable | daily "I'm OK" |
| checkMissedCheckins | scheduled, every 30 min | one missed-check-in alert per day |
| sendSos | callable | urgent push to guardians |
| weeklyFeedPush | scheduled, Mon/Thu 10:00 IST | new scam alert push (max 2 a week) |
| deleteMyAccount, updateRoles, sendTestAlert | callable | account and settings |

## Repo layout
```
lib/
  main.dart, app.dart
  core/        theme, router, constants, utils, widgets
  l10n/        ARB files (app_en.arb, app_hi.arb, app_mr.arb) → generated via gen-l10n
  features/    auth, onboarding, profile, home, circle, check, guardian, checkin, sos, history, feed, settings
  services/    firebase, notifications, ...
  core/router/startup_guard.dart   pure first-run/sign-in redirect logic (unit-tested)
functions/     Cloud Functions v2 (TypeScript, asia-south1)
firestore.rules
firebase.json, .firebaserc
```

## Navigation flow
Language → Onboarding (3 slides, Skip) → Privacy consent → Phone login → OTP →
Profile setup → Home. `startupStepProvider` decides the step; go_router's redirect
enforces it. `/language` stays reachable later (from Home) to change the language.

## Data model
**Local prefs** (`core/storage/preferences.dart`): `language_code`, `large_text_enabled`,
`onboarding_done`, `consent_version`, `consent_accepted_at_ms`.

**Firestore `users/{uid}`** (owner-only read/write; type-checked in `firestore.rules`):
| field | type | notes |
|---|---|---|
| name | string | 1–50 chars |
| phone | string | must equal the auth token's phone number; immutable |
| roles | list | subset of `protected`, `guardian` (1–2 items) |
| language | string | `en` / `hi` / `mr` |
| largeText | bool | |
| consentVersion | int | `AppConstants.privacyConsentVersion` (bump when the privacy text changes) |
| consentAcceptedAt | timestamp | |
| fcmToken | string or null | placeholder until the notifications step |
| createdAt | timestamp | server time; immutable |
Deleting the doc is denied from clients (future Cloud Function).

**Family Circle.** Clients only *read*. Every write goes through callable functions
(`functions/src/circles/circles.ts`, asia-south1):

| collection | fields | client access |
|---|---|---|
| `circles/{circleId}` | name (1–40), ownerUid, memberUids[] (≤5), createdAt | read if `uid in memberUids` |
| `circles/{id}/members/{uid}` | name, roles[], phone (copied from users/{uid} at join; phone powers "Call now"), joinedAt | read if member of the circle |
| `invites/{code}` | circleId, createdBy, expiresAt (+7 days), usesLeft (4), createdAt | none |
| `memberships/{uid}` | circleId, joinedAt. Server-side "1 circle per user" lock | none |
| `joinAttempts/{uid}` | count, windowStart. Wrong-code rate limit (10/hour) | none |

Callables, each returning `HttpsError` with `details.reason`:
- `createCircle({name})` → `{circleId}`: ALREADY_IN_CIRCLE, INVALID_NAME, PROFILE_MISSING
- `createInvite()` → `{code, expiresAt}`: NOT_IN_CIRCLE, CIRCLE_FULL. Any member can invite.
  Re-uses the circle's invite while ≥24h remain, and deletes dead invites.
- `joinCircle({code})` → `{circleId}`: INVALID_CODE, CODE_EXPIRED, CODE_USED_UP, CIRCLE_FULL,
  ALREADY_IN_CIRCLE, ALREADY_MEMBER, TOO_MANY_ATTEMPTS
- `leaveCircle()` → `{circleDeleted, newOwnerUid}`: NOT_IN_CIRCLE
- `removeMember({uid})`: NOT_OWNER, CANNOT_REMOVE_SELF, MEMBER_NOT_FOUND

Invite codes: 6 chars from `ABCDEFGHJKMNPQRSTUVWXYZ23456789` (no 0/O/1/I/L). Input is
case-insensitive and ignores spaces and dashes. They are shared as text via WhatsApp
(`whatsapp://send`) or the share sheet. Firebase Dynamic Links is shut down, so v1 is
code-only.

**Owner leaves:** ownership passes to the member who joined earliest. **Last member
leaves:** the circle, its members and its invites are deleted. Owners can't remove
themselves; they use Leave instead.

**AI checks.** Written only by Cloud Functions. Readable by the asker and by current members
of the check's circle (rules use `get(circles/{circleId}).memberUids`). Clients can never write.

| collection | fields |
|---|---|
| `checks/{checkId}` | uid, circleId (or null), maskedText, source (`share`/`image`/`voice`/`typed`), language, result {riskLevel, scamType, redFlags[≤5], whatToDo[3], summary}, aiStatus (`ok` / `fallback:not_json\|schema\|safe_verdict\|error`), createdAt, expireAt (createdAt + 30 days, TTL), guardianResponse (null, or {byUid, byName, type: STOP\|OK\|CALL, at}, set by respondToCheck; first wins), alert {guardianCount, sentCount, at} (set by onCheckCreated) |
| `users/{uid}.checkin` | enabled, time "HH:MM", alertAfterHours (1–24), timezone (IANA), lastCheckinAt, lastMissedAlertDate (local "yyyy-mm-dd"), updatedAt. **Functions only** (rules forbid client writes); copied to `circles/{id}/members/{uid}.checkin` for guardians |
| `sosUsage/{uid}` | count, windowStart (5 SOS / hour) |
| `scamFeed/{id}` | title{en,hi,mr}, body{en,hi,mr}, scamType, countryCodes[] ("IN"/"ALL"…), publishedAt, active, pushedAt (set by weeklyFeedPush). Read: signed-in; write: console/Admin only |
| `usage/{uid}_{yyyymmdd}` | uid, day (Asia/Kolkata), count (≤10), updatedAt, expireAt (+2 days, TTL) |

## AI check pipeline (`functions/src/checks/`, `functions/src/llm/`)
`analyzeCheck({text ≤4000, source, language})` → `{checkId, result}`. Errors:
UNAUTHENTICATED, INVALID_TEXT, TEXT_TOO_LONG, INVALID_ARGUMENT, DAILY_LIMIT_REACHED.
1. Validate the input, then count the check against today's IST quota in a
   transaction. Rejected input doesn't count.
2. `lib/masking.ts` replaces private data with [PHONE] [CODE] [ACCOUNT] [UPI] [EMAIL].
   URLs keep their domain but lose the query string and fragment. Money amounts
   (₹5000) are kept.
3. `LlmProvider` is chosen by the `LLM_PROVIDER` param: `gemini` (default; model from
   `GEMINI_MODEL`), `anthropic` (stub), or `fake` (emulator only, used by
   `.env.demo-pauseask`).
4. The prompt (`checks/prompt.ts`) asks for strict JSON in the user's language, adds
   India and global scam patterns, and treats the message as untrusted data.
5. `checks/checkResult.ts`: zod validation plus a guard against "safe/genuine/not a
   scam" verdicts in en/hi/mr. Any failure becomes a localized BE_CAREFUL fallback.
   **There is no SAFE level, by design.**
6. Logs hold metadata only (uid, length, riskLevel, aiStatus, latency), never text.

Config: `functions/.env` (committed, non-secret) holds `LLM_PROVIDER` and
`GEMINI_MODEL`. `GEMINI_API_KEY` lives **only** in Secret Manager
(`firebase functions:secrets:set GEMINI_API_KEY`). For local real-AI runs it goes in
`functions/.secret.local`, which is git-ignored.

TTL: enable Firestore TTL on `checks.expireAt` (required, 30-day deletion) and on
`usage.expireAt` (housekeeping). Deletion runs within ~24h after expiry, not instantly.

## Tests
- `flutter analyze && flutter test`
- `cd functions && npm run test:unit`: masking, JSON validation, invite codes.
- `cd functions && npm run test:emulator` runs callables and rules end-to-end in the
  Auth, Firestore and Functions emulators with the fake LLM (needs JDK 21+).
- `cd functions && node scripts/try-analyze.mjs <projectId>`: the 7 ticket cases in
  en/hi/mr against a running emulator. Use real Gemini with your project ID and
  `.secret.local`.

## Guardian alerts (Step 6)
- **Device registration:** `services/notifications/notification_service.dart`
  (`NotificationsBootstrap` wraps the app). Once the user is ready it:
  - creates the Android channels `alerts` (max importance) and `general`;
  - asks for notification permission (Android 13+);
  - calls `FirebaseMessaging.register()` and saves the **Firebase Installation ID** from
    `onRegistered` into `users/{uid}.fcmToken`. firebase_messaging 17 deprecated
    getToken; the server sends with `fid`.
  - On logout the field is set to null and the app calls `unregister()`.
- **`onCheckCreated`** (Firestore trigger on `checks/{id}`) pushes every OTHER circle member
  with the guardian role, using `alerts` and each receiver's language
  (`functions/src/notifications/texts.ts`). Data is only {type: check_alert, checkId,
  riskLevel, fromName}: **never message text**. It writes `alert` on the check, and dead
  tokens are cleared.
- **`respondToCheck({checkId, type})`** → `{accepted, response}`:
  - Only guardian members of the check's circle, not the asker (NOT_GUARDIAN,
    CHECK_NOT_FOUND).
  - The first reply wins, in a transaction. Later callers get accepted=false and the
    winning reply.
  - Pushes `guardian_response` to the asker and `check_answered` (general) to other guardians.
- **Push types and screens:**
  - `check_alert` / `check_answered` open `/guardian/check/:id`: who asked, time, masked
    text, AI result, STOP / OK / Call now. Call now records CALL, then opens the dialer with
    the member's phone. Once answered: "Already answered by X", and only Call remains.
  - `guardian_response` opens `/check/response/:id`: a full-screen colour (red STOP, green OK,
    blue CALL), read aloud automatically once.
  - The result screen also listens to the check live and opens the same screen.
    `shownResponsesProvider` stops it opening twice.
- **Result screen family card:** alerting → alerted / no guardian in circle / "Add family to
  get help" (no circle) / "X replied: …".
- **Guardian Home** (`features/guardian/guardian_home_section.dart`) lists unanswered circle
  checks, newest first (index: checks circleId ASC + createdAt DESC), with a member-status
  placeholder.
- **Emulator:** `PUSH_MODE=log` (in `.env.demo-pauseask`) writes pushes to `_pushLog` instead
  of FCM, so the tests can assert recipients, language and payload.

## SOS and daily check-in (Step 7)
- **SOS** (`features/sos/`): a red hold-to-confirm button on Protected Home. It must be held
  2 s; a quick tap only shows the hint. Screen readers use the long-press action.
  - `sendSos()` → `{guardianCount, sentCount, firstGuardian{name, phone}}`. It pushes `sos`
    on the `alerts` channel and also counts as a check-in. SOS_LIMIT = 5 per hour.
  - The SOS sent screen has "Call {first guardian}". The **1930** cyber-crime helpline
    button shows only when the user's phone is +91.
  - A guardian tapping the push opens `/guardian/sos/:uid` (red, big Call).
- **Check-in** (`features/checkin/`):
  - Settings go through `saveCheckinSettings` (validated; the time zone is the device's IANA
    zone from flutter_timezone). Defaults are ON, 09:00, 12 h, and are saved
    automatically for Protected users on first launch.
  - `checkIn()` sets lastCheckinAt. These count as a check-in:
    - tapping the daily reminder;
    - opening or resuming the app (at most once an hour, `PrefKeys.lastAppCheckinMs`);
    - running a scam check or pressing SOS (server-side).
  - **Daily reminder:** a local `zonedSchedule` with DateTimeComponents.time and
    **inexact** alarms (may be a few minutes late; exact alarms need a Play-restricted
    permission). Rescheduled on every launch and on save.
  - **`checkMissedCheckins`:** runs every 30 min (Cloud Scheduler), and the logic lives in
    `runCheckinSweep(now)` + `dueMissedDay()`.
    - A day is missed when time + alertAfterHours has passed, there was no check-in since
      local midnight, no alert has been sent for that day, and the settings were not
      changed that day (changes apply from the next day).
    - Yesterday is also checked, for deadlines after midnight.
    - The day is claimed in a transaction before pushing, so it gives exactly one
      `missed_checkin` (general channel) per day.
- **Guardian Home member cards:** 🟢 "OK today at 9:12" / ⚪ "Not yet today" / 🔴 "Missed" /
  "check-in off". They are judged in the member's own time zone (`checkinStatus`) and
  include a call button.
- **Battery guide** (`features/settings/battery_guide_screen.dart`): shown once
  (`PrefKeys.batteryGuideShown`) on Xiaomi/Redmi/Poco/Oppo/Vivo/iQOO/Realme/OnePlus/Samsung/
  Huawei/Honor/Tecno/Infinix/itel. It opens the app notification settings, the battery
  optimization list, and app details (fallback). It can be reopened from Home →
  "Notification help".

## History, scam feed, home (Step 8)
- **History** (`features/history/`, `/history`, `/history/:checkId`):
  - Guardians in a circle see the circle's checks; everyone else sees their own
    (`where uid == me`, index uid + createdAt desc).
  - Each item shows the risk colour, date, summary and the guardian reply.
  - **Delete:** a button or swipe, then `deleteCheck({checkId})`. Owner only (NOT_OWNER,
    CHECK_NOT_FOUND); clients can't delete directly.
  - Shows the note "deleted after 30 days" and a friendly empty state.
- **Scam feed** (`features/feed/`): `scamFeed/{id}`. Any signed-in user can read; clients can
  never write.
  - The app shows active items with `publishedAt <= now` whose `countryCodes` contain "ALL"
    or the user's country. The country comes from the phone prefix (`core/utils/country.dart`,
    mirrored in `functions/src/lib/country.ts`).
  - Titles and bodies fall back to English. The home card shows the newest; `/feed` lists all
    of them.
  - **Share this alert:** WhatsApp, or the share sheet when WhatsApp isn't installed. The text
    is the alert, then "Protect your family with PauseAsk" and `AppConstants.playStoreUrl`.
  - **`weeklyFeedPush`:** Mon and Thu 10:00 IST. Pushes ONE active, un-pushed item from the
    last 7 days (so max 2 a week), sets `pushedAt`, and sends in each user's language and
    country on the `general` channel. The push opens `/feed`.
- **Seed:** `cd functions && node scripts/seedFeed.ts <projectId>` writes 8 en/hi/mr alerts with
  fixed ids `seed-*`, so it's safe to re-run. Use Node 22.18+, or `npx tsx`. For the real
  project, run `gcloud auth application-default login` first. For the emulator, set
  `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080`.
- **Home** (`features/home/home_screen.dart`):
  - Time-of-day greeting with the user's name.
  - Protected users see the check-in card (✓ OK today, or an "I'm OK 👍" button), Pause & Ask
    actions and SOS. Guardians see family requests and member status. Both roles see the
    feed card, History and Circle.
  - Settings (large text, language, check-in, notification help, logout) are behind the gear
    icon at `/settings`.

### How to add a scam-feed item (Firebase console)
1. Firestore → `scamFeed` → **Add document** (auto-ID is fine).
2. Add these fields:
   - `title` (map): `en`, `hi`, `mr` (strings). Keep it short, in plain words.
   - `body` (map): `en`, `hi`, `mr` (strings). 2–4 short sentences: what happens, why it's a
     scam, what to do.
   - `scamType` (string), e.g. `kyc_update`.
   - `countryCodes` (array of strings): `IN`, or `ALL` for everyone.
   - `publishedAt` (timestamp): when it should appear. A future time schedules it.
   - `active` (boolean): `true`. Set it to `false` to hide the item later instead of deleting it.
3. Save. The item appears in the app at once (live listener; no app update).
   The next Mon/Thu push picks it up if it's from the last 7 days.
Never say a type of message is "safe" in feed text. Same golden rule as the AI.

## Settings, account deletion, legal (Step 9)
- **Settings** (`features/settings/settings_screen.dart`, gear icon on Home):
  - language, large text, **role** (via the `updateRoles` callable; rules forbid client
    role edits so the circle copy used for alerts stays in sync);
  - circle, check-in, **"Send me a test alert"** (`sendTestAlert`, own phone, alerts
    channel), battery guide;
  - FAQ / privacy / terms, contact support (mailto, **hidden until
    `AppConstants.supportEmail` is set**), version (package_info_plus);
  - logout and Delete account;
  - in debug builds only, "Crash test".
- **Logout** (`PhoneAuthController.signOut`) unregisters the device, cancels local
  notifications (the reminder), and clears per-user prefs. `signOut(forgetDevice: true)`
  (after deletion) clears all prefs, so the app restarts from the language screen.
- **`deleteMyAccount`:** leaves the circle via `leaveCircleFor` (ownership to the oldest member;
  an empty circle and its invites are deleted). It also:
  - deletes the user's checks, usage, sosUsage, joinAttempts, membership and users doc;
  - **anonymises** `guardianResponse.byName/byUid` on others' checks;
  - deletes the Auth user.
  It is idempotent. The screen requires typing exactly `DELETE` (in every language).
- **Legal:**
  - The in-app plain-language privacy / terms / FAQ (8 Q&As) are in
    `features/legal/legal_content.dart` (en/hi/mr, `{email}` and `{company}` filled at display).
  - The full public versions are `docs/privacy-policy.md`, `docs/terms.md` and
    `docs/delete-account.md`. Keep both in sync.
  - Company: `AppConstants.legalEntity` (**Multisarv**); date: `legalEffectiveDate`.
- **Website (Firebase Hosting):** `node tools/build_site.mjs` turns `/docs` into
  `site/{privacy,terms,delete-account,index}.html`, served with cleanUrls at `/privacy`,
  `/terms` and `/delete-account`.
  - It reads the email, company and date from `app_constants.dart`.
  - It **refuses to build while `supportEmail` is empty**.
  - It runs automatically as the hosting predeploy. `site/` is git-ignored.
  - After the first deploy, set `AppConstants.websiteBaseUrl` (e.g.
    `https://<projectId>.web.app`) so the app links to the full versions.
- **Errors** (`core/errors/app_errors.dart`): no third-party crash reporting in v1.
  `installErrorHandlers()` (main) logs Flutter, platform and async errors to the console and
  replaces the red error box with `FriendlyErrorView`. GoRouter's `errorBuilder` shows the
  same view for unknown routes.

## Protected check flow (app, `lib/features/check/`)
Home (Protected/Both) has a big **Pause & Ask** button (a sheet with voice / paste / screenshot),
plus a mic button, paste/type, pick screenshot, and a share tip. Routes: `/check` (compose or
confirm), `/check/voice`, `/check/ocr`, `/check/run` (calls `analyzeCheck`), `/check/result`.
- **Share intents** (`services/share/share_intent_listener.dart`, Android SEND text/* and image/*,
  `launchMode=singleTask`): text goes straight to checking (≤4000 chars, otherwise compose to
  trim); an image goes to OCR, then confirm. A share received before login is held until the
  user is ready.
- **OCR:** ML Kit Latin + Devanagari on-device (`pickOcrText` prefers Devanagari when ≥5% of the
  text is Devanagari). The Android dependency `text-recognition-devanagari` is in
  `android/app/build.gradle.kts`. Images are never uploaded.
- **Voice:** `speech_to_text` with `onDevice: true` and locale `{lang}_IN`. If the offline
  language pack is missing, the user is told how to install it.
- **Read aloud:** `flutter_tts` with `hi-IN` / `mr-IN` / `en-IN`. It never reads with a
  wrong-language voice; if a voice is missing, the user is told to install it.
- **Errors:** connectivity is checked first, so airplane mode gives an instant "no internet".
  DAILY_LIMIT_REACHED, too long or empty input, and failures each get a friendly message.
  The "don't send money / OTP" reminder stays on screen.
- The family-alert card is an honest placeholder ("coming soon" / "join a circle") until the
  guardian alerts step.

## Release (Step 10)
- Android: applicationId `com.multisarv.pauseask`, **minSdk 24, targetSdk 36** (Play
  requirement since 31 Aug 2026), **compileSdk 37** (needed by receive_sharing_intent;
  doesn't change runtime behaviour), versionName 1.0.0 / versionCode 1. Release signing
  comes from `android/key.properties` (git-ignored; falls back to debug keys with a warning).
  R8 is on, with `android/app/proguard-rules.pro`.
- Icons: `flutter_launcher_icons` config in pubspec. Source files go in `assets/branding/`
  (see its README); run `dart run flutter_launcher_icons`.
- E2E: `docs/test-plan.md`. The app talks to the emulators with
  `--dart-define=USE_EMULATORS=true [--dart-define=EMULATOR_HOST=<LAN IP>]`; debug builds
  allow cleartext for that.
- Store: `docs/play-store.md` (listing en/hi/mr, Data safety, content rating, permissions,
  signing, App Check rollout, testing tracks).

## Known limitations (v1)
- Android only in practice. The iOS folders exist but Share Extension, APNs and App Attest
  setup are not done.
- The daily reminder uses **inexact** alarms (may be minutes late). Some OEM phones still
  delay pushes despite the battery guide.
- Missed-check-in alerts can be up to 30 min late (sweep interval). The sweep scans all
  enabled users, which is fine for thousands but should be sharded later.
- Country for the feed comes from the phone prefix; there is no in-app country choice.
- The feed is managed in the Firebase console (no admin panel). Translations are entered by
  hand.
- No offline queue: checks need internet. No analytics or crash reporting (console logs
  only).
- Hindi and Marathi texts (UI, AI prompt output, feed, legal) still need native-speaker
  review. The legal texts need a lawyer's review.
- Real Gemini output quality is only verified through the try script, not at scale.
- The support email is unset (`AppConstants.supportEmail`); the website build refuses to
  run until it is set.

## v2 ideas
- **iOS** (Share Extension, APNs, App Attest)
- **Passive check-in:** count phone unlock or step activity as "I'm OK", opt-in.
- **Paid family plan:** more members and checks, multiple circles, priority AI.
- **More languages:** Gujarati, Tamil, Telugu, Kannada, Bengali, Punjabi (ARB + legal + feed +
  AI prompt).
- **Deep links** for invites (App Links, `/join/<code>`) instead of typing the code.
- **Admin panel** for the scam feed: editing, translation help, scheduling, analytics.
- Guardian "trusted numbers" list and a call-back verification helper.
- Report-to-1930 / cybercrime.gov.in helper that prefills the details.
- Optional privacy-preserving analytics and crash reporting.

## Working rules for the agent
- Do **only** the current step; don't start later features.
- Keep code clean and modular (feature-first folders).
- No secrets in git (`google-services.json`, `GoogleService-Info.plist`,
  `firebase_options.dart`, `.env`, service-account keys are git-ignored by default).
- Explain any manual step the developer must do.
- Never invent the Firebase project ID — ask the developer.

## Progress log
- **Step 1 — Base project:** Flutter app scaffold, theme (Material 3, risk colours,
  large-text option), en/hi/mr localisation, splash/home placeholder, Firebase core
  wiring (awaiting `flutterfire configure`), `functions/` with `healthCheck`,
  deny-all `firestore.rules`.
  - Firebase project ID: _not created yet — fill in `.firebaserc` once known._
  - Flutter SDK is installed at `~/development/flutter` (git clone, stable channel).
- **Step 2 — First-run flow:** language picker, 3 onboarding slides, privacy consent,
  phone OTP login (+91 default, Android auto-fill), profile setup (name + role), router
  guards, role-specific Home placeholder, owner-only `users/{uid}` rules.
  - Rules are tested in the Firestore emulator (17 cases). The emulator needs JDK 21+.
  - Hindi/Marathi strings still need review by a native speaker.
- **Step 3 — Family Circle:** create/join/invite/leave/remove via callables, circle
  screens, WhatsApp + share-sheet invites, member-read-only rules. 23 emulator tests.
  The Play Store link is a placeholder (`AppConstants.playStoreUrl`).
- **Step 4 — analyzeCheck (backend only):** masking, IST daily quota, Gemini behind
  `LlmProvider`, zod and safe-verdict guard with localized fallback, 30-day checks with
  TTL. 93 unit and emulator tests pass with the fake LLM. Real Gemini output is not
  verified yet: it needs the key and the try script.
- **Step 5 — Protected check flow (app):** Home actions, share intents, on-device OCR and
  voice, compose/confirm, checking screen, coloured result with TTS, error states; 45 Flutter
  tests. **Not tested on a real phone yet**: no Android SDK or device here, and
  analyzeCheck isn't deployed.
- **Step 6 — Guardian alerts:** onCheckCreated and respondToCheck, FCM registration (FID),
  channels, guardian alert screen, full-screen reply, live result, Guardian Home list, member
  phone, check read rules. 101 functions tests and 60 Flutter tests. Real push delivery
  (open / background / killed) and the delay are **untested**: they need deployment and
  2 phones.
- **Step 7 — SOS + daily check-in:** sendSos (5/h), checkIn, saveCheckinSettings, a
  scheduled sweep (one missed alert per day, time-zone aware), reminder notification, member
  status cards, battery guide. 124 functions tests and 73 Flutter tests. Real scheduling,
  reminders on OEM phones and Cloud Scheduler are **untested** until deploy and devices.
- **Step 10 — Release readiness:** rules unit tests (18), zod validation on all callables,
  App Check wrapper and switch, test-alert rate limit, concurrency and validation tests (157
  functions tests in total), App Check client + emulator switch, release signing / R8 /
  targetSdk 36, icon config, docs/test-plan.md, docs/play-store.md. Flutter: 101 tests.
- **Step 9 — Settings, delete account, legal, hosting, errors:** deleteMyAccount,
  updateRoles, sendTestAlert, full settings, DELETE confirmation, in-app and /docs policies,
  site builder + hosting config, friendly error view. 135 functions tests and 101 Flutter
  tests. **Support email still unset** (owner decides later).
- **Step 8 — History, feed, home polish:** deleteCheck, scamFeed rules and indexes, seed
  script (8 items), weeklyFeedPush, history list and detail, feed card and list with WhatsApp
  share, polished home and settings. 129 functions tests and 85 Flutter tests.
