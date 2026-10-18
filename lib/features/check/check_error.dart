import 'package:cloud_functions/cloud_functions.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

/// Failures of a check the user can understand.
enum CheckError implements Exception {
  dailyLimit,
  network,
  empty,
  tooLong,
  generic;

  static CheckError from(Object error) {
    if (error is CheckError) return error;
    if (error is! FirebaseFunctionsException) return generic;
    final details = error.details;
    final reason = details is Map ? details['reason'] : null;
    return switch (reason ?? error.message) {
      'DAILY_LIMIT_REACHED' => dailyLimit,
      'INVALID_TEXT' => empty,
      'TEXT_TOO_LONG' => tooLong,
      _ when error.code == 'unavailable' => network,
      _ => generic,
    };
  }

  String message(AppLocalizations l10n) => switch (this) {
    dailyLimit => l10n.checkErrorDailyLimit,
    network => l10n.checkErrorNetwork,
    empty => l10n.textEmpty,
    tooLong => l10n.textTooLong(AppConstants.maxCheckTextLength),
    generic => l10n.checkErrorGeneric,
  };
}
