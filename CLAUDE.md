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
| `circles/{id}/members/{uid}` | name, roles[] (copied from users/{uid} at join), joinedAt | read if member of the circle |
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

**AI checks.** Written only by `analyzeCheck`. No client access yet; guardian and
history reads come in later steps.

| collection | fields |
|---|---|
| `checks/{checkId}` | uid, circleId (or null), maskedText, source (`share`/`image`/`voice`/`typed`), language, result {riskLevel, scamType, redFlags[≤5], whatToDo[3], summary}, aiStatus (`ok` / `fallback:not_json\|schema\|safe_verdict\|error`), createdAt, expireAt (createdAt + 30 days, TTL), guardianResponse (null) |
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
