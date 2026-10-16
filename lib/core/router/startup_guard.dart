import 'app_routes.dart';

/// Where the user is in the first-run / sign-in journey.
enum StartupStep {
  loading,
  language,
  onboarding,
  privacy,
  login,
  profile,
  ready,
}

/// Works out the current step. Pure function so it is easy to test.
StartupStep resolveStartupStep({
  required bool languageChosen,
  required bool onboardingDone,
  required bool consentAccepted,
  required bool authLoading,
  required bool signedIn,
  required bool profileLoading,
  required bool hasProfile,
}) {
  if (!languageChosen) return StartupStep.language;
  if (!onboardingDone) return StartupStep.onboarding;
  if (!consentAccepted) return StartupStep.privacy;
  if (authLoading) return StartupStep.loading;
  if (!signedIn) return StartupStep.login;
  if (profileLoading) return StartupStep.loading;
  if (!hasProfile) return StartupStep.profile;
  return StartupStep.ready;
}

const _firstRunRoutes = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.privacy,
  AppRoutes.login,
  AppRoutes.otp,
  AppRoutes.profileSetup,
};

/// go_router redirect for [step] at [location]; null means "stay".
String? redirectForStep(StartupStep step, String location) {
  // Changing the language is allowed at any point after the first pick.
  if (location == AppRoutes.language && step != StartupStep.loading) {
    return null;
  }

  final String target;
  switch (step) {
    case StartupStep.loading:
      target = AppRoutes.splash;
    case StartupStep.language:
      target = AppRoutes.language;
    case StartupStep.onboarding:
      target = AppRoutes.onboarding;
    case StartupStep.privacy:
      target = AppRoutes.privacy;
    case StartupStep.login:
      // Both the phone and the OTP screens belong to this step.
      if (location.startsWith(AppRoutes.login)) return null;
      target = AppRoutes.login;
    case StartupStep.profile:
      target = AppRoutes.profileSetup;
    case StartupStep.ready:
      // First-run screens are done; every other app route is allowed.
      return _firstRunRoutes.contains(location) ? AppRoutes.home : null;
  }
  return location == target ? null : target;
}
