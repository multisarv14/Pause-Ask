import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loaded once in `main()` and injected via a provider override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main() with an instance.'),
);

/// Keys for everything PauseAsk stores locally on the device.
abstract final class PrefKeys {
  static const languageCode = 'language_code';
  static const largeText = 'large_text_enabled';
  static const onboardingDone = 'onboarding_done';
  static const consentVersion = 'consent_version';
  static const consentAcceptedAt = 'consent_accepted_at_ms';
}
