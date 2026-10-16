# PauseAsk – Family Scam Check

**Pause. Ask family. Stay safe.**

A Protected user shares a suspicious message, the AI explains the risk in their
language (never "safe"), and their family Circle replies with one tap.
Full product context: [CLAUDE.md](CLAUDE.md).

Flutter · Riverpod · go_router · Firebase (Auth, Firestore, Functions v2, FCM) · asia-south1
· Android first · English / हिन्दी / मराठी

## Prerequisites
- Flutter SDK (stable), so `flutter doctor` passes for Android
- Android Studio + an Android emulator
- Node.js 20+ and Firebase CLI: `npm i -g firebase-tools && firebase login`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

## One-time Firebase setup
1. Put your Firebase project ID in `.firebaserc` (replace `REPLACE_WITH_YOUR_FIREBASE_PROJECT_ID`),
   or run `firebase use --add`.
2. From the repo root, run:
   ```sh
   flutterfire configure --project=<your-project-id> --platforms=android,ios \
     --android-package-name=com.multisarv.pauseask --ios-bundle-id=com.multisarv.pauseask
   ```
   This writes `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`
   and `lib/firebase_options.dart`, and adds the Google Services Gradle plugin.
   All three files are **git-ignored**. Every developer runs this command on their own machine.
3. The app calls `Firebase.initializeApp()` on startup and reads the native config.
   Until you configure Firebase, it logs a warning and keeps running.

## Run the app
```sh
flutter pub get        # also generates localizations (lib/l10n/app_localizations*.dart)
flutter run            # with an Android emulator running
```
To check the translations, set the emulator's language to हिन्दी or मराठी.
The tagline changes to match.

## Quality checks
```sh
flutter analyze
flutter test
```

## Cloud Functions (`functions/`)
```sh
cd functions
npm install
npm run build                      # TypeScript → lib/
firebase deploy --only functions   # needs the Blaze plan
```
`healthCheck` is an HTTPS function in `asia-south1`. It returns `{"status":"ok", ...}`.
To try it locally, run `npm run serve`.

## Firestore rules
`firestore.rules` denies all reads and writes for now. To deploy them, run
`firebase deploy --only firestore:rules`.

## Localization
To change the text, edit `lib/l10n/app_en.arb` (the template), `app_hi.arb` and `app_mr.arb`,
then run `flutter gen-l10n` or `flutter pub get`.
