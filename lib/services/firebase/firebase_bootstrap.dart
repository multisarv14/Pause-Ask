import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initialises Firebase from the native config files that
/// `flutterfire configure` writes (android/app/google-services.json,
/// ios/Runner/GoogleService-Info.plist). Those files are git-ignored.
///
/// Returns false instead of crashing when Firebase isn't configured yet,
/// so the app still runs before the developer has done the manual setup.
Future<bool> initFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } catch (e) {
    debugPrint(
      'Firebase not configured yet — run `flutterfire configure`. ($e)',
    );
    return false;
  }
}
