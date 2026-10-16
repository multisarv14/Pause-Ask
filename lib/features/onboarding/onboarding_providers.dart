import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/preferences.dart';

/// True once the user has finished or skipped the onboarding slides.
final onboardingDoneProvider = NotifierProvider<OnboardingDoneNotifier, bool>(
  OnboardingDoneNotifier.new,
);

class OnboardingDoneNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(PrefKeys.onboardingDone) ??
      false;

  Future<void> complete() async {
    state = true;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(PrefKeys.onboardingDone, true);
  }
}

class ConsentRecord {
  const ConsentRecord({required this.version, required this.acceptedAt});

  final int version;
  final DateTime acceptedAt;

  bool get isCurrent => version == AppConstants.privacyConsentVersion;
}

/// Privacy consent, stored locally before login and copied into the
/// Firestore profile at profile setup.
final consentProvider = NotifierProvider<ConsentNotifier, ConsentRecord?>(
  ConsentNotifier.new,
);

class ConsentNotifier extends Notifier<ConsentRecord?> {
  @override
  ConsentRecord? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final version = prefs.getInt(PrefKeys.consentVersion);
    final acceptedAtMs = prefs.getInt(PrefKeys.consentAcceptedAt);
    if (version == null || acceptedAtMs == null) return null;
    return ConsentRecord(
      version: version,
      acceptedAt: DateTime.fromMillisecondsSinceEpoch(acceptedAtMs),
    );
  }

  Future<void> accept() async {
    final record = ConsentRecord(
      version: AppConstants.privacyConsentVersion,
      acceptedAt: DateTime.now(),
    );
    state = record;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(PrefKeys.consentVersion, record.version);
    await prefs.setInt(
      PrefKeys.consentAcceptedAt,
      record.acceptedAt.millisecondsSinceEpoch,
    );
  }
}
