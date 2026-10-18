/// App-wide constants. Server-side limits are mirrored here for display
/// only — they are always enforced by Cloud Functions.
abstract final class AppConstants {
  static const String packageName = 'com.multisarv.pauseask';
  static const String firebaseRegion = 'asia-south1';

  // Legal / support. Single source of truth: the website build
  // (tools/build_site.mjs) reads these too.
  // TODO(owner): set the support email before publishing; until then the
  // app hides "Contact support" and the website build refuses to run.
  static const String supportEmail = '';
  static const String legalEntity = 'Multisarv';
  static const String legalEffectiveDate = '17 October 2026';

  // Public pages (Firebase Hosting). Fill in once hosting is live,
  // e.g. 'https://pauseask.web.app'.
  static const String websiteBaseUrl = '';

  // Placeholder until the app is published on Play.
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageName';

  // Accessibility
  static const double minButtonHeight = 56;
  static const double baseFontSize = 18;
  static const double textScaleNormal = 1.0;
  static const double textScaleLarge = 1.3;

  // Free-plan limits (enforced server-side).
  static const int maxCirclesPerUser = 1;
  static const int maxCircleMembers = 5;
  static const int maxAiChecksPerDay = 10;
  static const int maxCheckTextLength = 4000;
  static const int historyRetentionDays = 30;

  // Bump when the privacy text changes; users are asked to agree again.
  static const int privacyConsentVersion = 1;
}
