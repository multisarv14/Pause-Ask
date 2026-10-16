import 'package:firebase_auth/firebase_auth.dart';

import '../../l10n/app_localizations.dart';

/// Auth failures the user can understand and act on.
enum AuthError {
  invalidPhone,
  wrongCode,
  codeExpired,
  tooManyAttempts,
  network,
  generic;

  static AuthError from(Object error) {
    if (error is! FirebaseAuthException) return generic;
    return switch (error.code) {
      'invalid-phone-number' || 'missing-phone-number' => invalidPhone,
      'invalid-verification-code' || 'missing-verification-code' => wrongCode,
      'session-expired' ||
      'code-expired' ||
      'invalid-verification-id' => codeExpired,
      'too-many-requests' || 'quota-exceeded' => tooManyAttempts,
      'network-request-failed' => network,
      _ => generic,
    };
  }

  String message(AppLocalizations l10n) => switch (this) {
    invalidPhone => l10n.errorInvalidPhone,
    wrongCode => l10n.errorWrongCode,
    codeExpired => l10n.errorCodeExpired,
    tooManyAttempts => l10n.errorTooManyAttempts,
    network => l10n.errorNetwork,
    generic => l10n.errorGeneric,
  };
}
