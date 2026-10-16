import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/preferences.dart';

/// Language names are always shown in their own script, never translated.
const Map<String, String> supportedLanguages = {
  'en': 'English',
  'hi': 'हिंदी',
  'mr': 'मराठी',
};

/// The language the user picked (null until the first-run picker is done).
final languageProvider = NotifierProvider<LanguageNotifier, String?>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<String?> {
  @override
  String? build() {
    final code = ref
        .watch(sharedPreferencesProvider)
        .getString(PrefKeys.languageCode);
    return supportedLanguages.containsKey(code) ? code : null;
  }

  Future<void> set(String code) async {
    assert(supportedLanguages.containsKey(code));
    state = code;
    await ref
        .read(sharedPreferencesProvider)
        .setString(PrefKeys.languageCode, code);
  }
}

/// Locale for MaterialApp; null falls back to the device language.
final localeProvider = Provider<Locale?>((ref) {
  final code = ref.watch(languageProvider);
  return code == null ? null : Locale(code);
});
