# PauseAsk v1 – End-to-end test plan

Two phones (or Android emulators with Google Play): **A = Protected**, **B = Guardian**.
Run **Part 1** (local emulators, no cost, no real pushes) first, then **Part 2** (deployed
project, real pushes and real AI) before every Play upload.

Record results in the table at the bottom.

---

## 0. Automated checks (run first, must be green)

```sh
flutter analyze && flutter test                  # app: widget + unit tests
cd functions && npm run test:unit                # masking, AI JSON validation, invite codes, check-in maths
cd functions && npm run test:emulator            # callables + Firestore rules end-to-end (needs JDK 21+)
```

## 1. Part 1 – Local emulators

### Setup

1. In `functions/.env.local` (git-ignored) put:
   ```
   LLM_PROVIDER=fake        # or gemini + GEMINI_API_KEY in functions/.secret.local
   PUSH_MODE=log            # pushes are written to the _pushLog collection instead of FCM
   ```
2. Start the emulators with **your real project id** (the app's google-services.json uses it):
   ```sh
   firebase emulators:start --only auth,firestore,functions --project <projectId>
   ```
   Emulator UI: http://localhost:4000
3. Seed the scam feed: `cd functions && FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node scripts/seedFeed.ts <projectId>`
4. Run the app on both devices against the emulators:
   ```sh
   # Android emulators reach the computer at 10.0.2.2 (default)
   flutter run -d <deviceA> --dart-define=USE_EMULATORS=true
   flutter run -d <deviceB> --dart-define=USE_EMULATORS=true
   # Real phones on the same Wi-Fi: add --dart-define=EMULATOR_HOST=<your PC's LAN IP>
   ```
5. Phone login in the emulator: enter any number; the SMS code appears in the
   **Emulator UI → Authentication** (or the emulator log).

In Part 1, "push arrives" means: a document appears in **Firestore → `_pushLog`** with the
right `uid`, `title`/`body` in the receiver's language and **no message text**.

### Script

| # | Step (device) | Expected |
|---|---|---|
| 1 | A: fresh install → language Marathi → onboarding (Skip) → privacy "I agree" → phone login | Every screen in Marathi; "I agree" required |
| 2 | A: profile "Aai", role **I want protection** | Home with big "थांबा आणि विचारा", SOS, "मी ठीक आहे 👍" card |
| 3 | B: language English, profile "Ravi", role **I protect my family** | Guardian home: Family requests (empty), Family status |
| 4 | A: My family circle → Create "Test Family" → Invite family | 6-character code; WhatsApp/share opens with Marathi text containing the code |
| 5 | B: My family circle → Join with code → enter the code | Both phones list both members with role badges |
| 6 | B: try a wrong code 3 times | "That code doesn't match any circle" each time |
| 7 | A: share a scam text from Messages → PauseAsk, e.g. *"This is CBI. Your Aadhaar is linked to money laundering. Transfer ₹50,000 to the safe account."* | Checking screen with "don't send money / OTP" reminder → red **HIGH** result in Marathi; "Read aloud" uses the Marathi voice |
| 8 | Check `_pushLog` (Part 1) / B's phone (Part 2) | One `check_alert` push to B, English, name + risk only, no message text |
| 9 | B: open the alert (Part 2: tap the push; Part 1: Family requests list) | Guardian alert screen: who asked, time, masked text (numbers hidden), result, 3 big buttons |
| 10 | B: tap **STOP** | B: "Your reply was sent to Aai". A: full-screen **red** "थांबा", read aloud automatically; A's result screen card shows "Ravi यांचं उत्तर: थांबा" |
| 11 | B: open the same check again | "Already answered…"; only "Call now" left; Call now opens the dialer with A's number |
| 12 | A: Pick a screenshot with Hindi/Marathi text | OCR text shown for confirm/edit; result after "आता तपासा" |
| 13 | A: Tell us what happened (voice, Marathi) | Transcript in Marathi → confirm → result |
| 14 | A: turn on airplane mode → check a message | Friendly "no internet" message + reminder |
| 15 | A: run checks until the 11th of the day | 11th → "You've used all 10 checks for today" |
| 16 | A: SOS – quick tap | Only the "hold for 2 seconds" hint |
| 17 | A: SOS – hold 2 s | "Your family has been alerted", **Call Ravi**, and (+91 number) the **1930** button; B gets an `sos` push → red SOS screen with Call |
| 18 | A: Settings → Daily "I'm OK" → time = now + 2 min, alert after **1 hour** → Save | Reminder notification arrives (may be a few minutes late: inexact alarm) |
| 19 | A: tap the reminder | "Thank you! Your family knows…"; B's Family status card: 🟢 OK today at hh:mm |
| 20 | Missed check-in: next day, don't open A. (Emulator shortcut: in Firestore set `users/<A>.checkin.lastCheckinAt` to 2 days ago and `checkin.updatedAt` to 2 days ago, then call the sweep – see below) | Exactly **one** `missed_checkin` push to B per day; B's card 🔴 Missed |
| 21 | A & B: Home → Scam alert of the day → Share this alert | WhatsApp opens with the alert + "Protect your family with PauseAsk" + store link |
| 22 | Firebase console / Emulator UI: add a `scamFeed` doc (see CLAUDE.md) | Appears on both phones without restarting |
| 23 | A: History | Own checks with colour, date, summary, Ravi's reply; delete one → gone |
| 24 | B: History | Circle's checks (Family checks); no delete buttons on A's checks |
| 25 | Both: Settings → Large text on; switch language hi ↔ mr ↔ en | Whole app updates at once, nothing cut off |
| 26 | A: Settings → My role → Both | Home shows Protected actions **and** Family requests |
| 27 | A: Settings → Send me a test alert | Part 2: push arrives; Part 1: `_pushLog` entry |
| 28 | B: Settings → Log out | Back to login; B's reminder cancelled; B no longer gets pushes (`fcmToken` null) |
| 29 | A: Settings → Delete account → type "delete" | Button stays disabled |
| 30 | A: type **DELETE** → Delete my account | App returns to the language screen; Firestore: `users/A`, A's checks, usage, membership gone; circle owner is now B; Auth user gone |
| 31 | Debug build: Settings → Crash test (debug) | Friendly "Something went wrong → Go to home" screen |

Running the missed-check-in sweep by hand in the emulator: the scheduled function is
`checkMissedCheckins`; in the Emulator UI → Functions you can trigger scheduled
functions, or run from `functions/`:
```sh
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 PUSH_MODE=log FUNCTIONS_EMULATOR=true \
  node -e 'import("./lib/checkins/checkins.js").then(m => m.runCheckinSweep()).then(console.log)'
```

## 2. Part 2 – Deployed project (real pushes, real AI)

Prerequisites: everything in the setup checklist (Blaze, Phone auth, `GEMINI_API_KEY`
secret, deploy, TTL, Cloud Messaging & Cloud Scheduler APIs, SHA-1/SHA-256 for the build
you install). Install a **release** build on both phones (`flutter run --release` or the
internal-testing build from Play).

Repeat steps 1–31 on real phones and additionally check:

| # | Check | Expected |
|---|---|---|
| P1 | Push delay A → B (steps 7–8), app on B **open / in background / swiped away** | Arrives within ~5 s in all three states |
| P2 | Lock screen on B | Name + risk level only, no message text |
| P3 | Real Gemini answers for the 7 cases in `functions/scripts/try-analyze.mjs` in en/hi/mr | HIGH/SUSPICIOUS/BE_CAREFUL as expected; never "safe"; natural hi/mr |
| P4 | Xiaomi / Oppo / Vivo / Samsung phone | Battery guide shows once; buttons open the right settings |
| P5 | Two guardians tap at the same time | One wins; the other sees "Already answered by …" |
| P6 | App Check (after enabling enforcement) | Release build works; a debug build without a registered debug token is rejected |
| P7 | Firestore usage after a day of testing | No unexpected reads/writes; Cloud Scheduler: 48 runs/day for check-ins |

## Results

| Date | Build | Phones / Android versions | Steps passed | Failed steps & notes |
|---|---|---|---|---|
| | | | | |
