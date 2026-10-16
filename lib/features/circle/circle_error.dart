import 'package:cloud_functions/cloud_functions.dart';

import '../../l10n/app_localizations.dart';

/// Error reasons returned by the circle Cloud Functions
/// (`details.reason`, see functions/src/lib/errors.ts).
enum CircleError {
  alreadyInCircle,
  alreadyMember,
  circleFull,
  invalidCode,
  codeExpired,
  codeUsedUp,
  notOwner,
  tooManyAttempts,
  invalidName,
  network,
  generic;

  static CircleError from(Object error) {
    if (error is! FirebaseFunctionsException) return generic;
    final details = error.details;
    final reason = details is Map ? details['reason'] : null;
    return switch (reason ?? error.message) {
      'ALREADY_IN_CIRCLE' => alreadyInCircle,
      'ALREADY_MEMBER' => alreadyMember,
      'CIRCLE_FULL' => circleFull,
      'INVALID_CODE' => invalidCode,
      'CODE_EXPIRED' => codeExpired,
      'CODE_USED_UP' => codeUsedUp,
      'NOT_OWNER' => notOwner,
      'TOO_MANY_ATTEMPTS' => tooManyAttempts,
      'INVALID_NAME' => invalidName,
      _ when error.code == 'unavailable' => network,
      _ => generic,
    };
  }

  String message(AppLocalizations l10n) => switch (this) {
    alreadyInCircle => l10n.circleErrorAlreadyInCircle,
    alreadyMember => l10n.circleErrorAlreadyMember,
    circleFull => l10n.circleErrorFull,
    invalidCode => l10n.circleErrorInvalidCode,
    codeExpired => l10n.circleErrorCodeExpired,
    codeUsedUp => l10n.circleErrorCodeUsedUp,
    notOwner => l10n.circleErrorNotOwner,
    tooManyAttempts => l10n.circleErrorTooManyAttempts,
    invalidName => l10n.circleNameRequired,
    network => l10n.errorNetwork,
    generic => l10n.errorGeneric,
  };
}
