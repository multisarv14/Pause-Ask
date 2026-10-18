import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';

/// `flutter run --dart-define=USE_EMULATORS=true` points the app at the local
/// Firebase emulators (docs/test-plan.md). EMULATOR_HOST defaults to the
/// Android emulator's alias for the computer; use your PC's LAN IP on a phone.
const useEmulators = bool.fromEnvironment('USE_EMULATORS');
const emulatorHost = String.fromEnvironment(
  'EMULATOR_HOST',
  defaultValue: '10.0.2.2',
);

FirebaseFunctions? _functions;

/// The one Functions instance (asia-south1), emulator-aware.
FirebaseFunctions appFunctions() {
  if (_functions != null) return _functions!;
  final f = FirebaseFunctions.instanceFor(region: AppConstants.firebaseRegion);
  if (useEmulators) f.useFunctionsEmulator(emulatorHost, 5001);
  return _functions = f;
}

/// Initialises Firebase from the native config files that
/// `flutterfire configure` writes (android/app/google-services.json,
/// ios/Runner/GoogleService-Info.plist). Those files are git-ignored.
///
/// Returns false instead of crashing when Firebase isn't configured yet,
/// so the app still runs before the developer has done the manual setup.
Future<bool> initFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
      'Firebase not configured yet — run `flutterfire configure`. ($e)',
    );
    return false;
  }

  // App Check: Play Integrity in release; the debug provider prints a token
  // to logcat that must be added in Firebase console → App Check → Manage
  // debug tokens. Enforcement is switched on in the console / functions .env.
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
      providerApple: kReleaseMode
          ? const AppleAppAttestProvider()
          : const AppleDebugProvider(),
    );
  } catch (e) {
    debugPrint('App Check activation failed: $e');
  }

  if (useEmulators) {
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    appFunctions();
    debugPrint('Using Firebase emulators at $emulatorHost');
  }
  return true;
}
