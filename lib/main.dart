import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/errors/app_errors.dart';
import 'core/storage/preferences.dart';
import 'features/auth/auth_providers.dart';
import 'features/checkin/checkin_repository.dart';
import 'services/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandlers();
  final firebaseReady = await initFirebase();
  // Time-zone data for check-in reminders and member status.
  await initDeviceTimeZone();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseReadyProvider.overrideWithValue(firebaseReady),
      ],
      child: const PauseAskApp(),
    ),
  );
}
