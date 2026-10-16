import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../storage/preferences.dart';

/// "Large text" mode: [AppConstants.textScaleNormal] or
/// [AppConstants.textScaleLarge], persisted in local prefs.
final largeTextProvider = NotifierProvider<LargeTextNotifier, bool>(
  LargeTextNotifier.new,
);

class LargeTextNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(PrefKeys.largeText) ?? false;

  Future<void> set(bool enabled) async {
    state = enabled;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(PrefKeys.largeText, enabled);
  }
}

final textScaleProvider = Provider<double>(
  (ref) => ref.watch(largeTextProvider)
      ? AppConstants.textScaleLarge
      : AppConstants.textScaleNormal,
);
