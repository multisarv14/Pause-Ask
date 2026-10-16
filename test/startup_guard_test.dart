import 'package:flutter_test/flutter_test.dart';
import 'package:pauseask/core/router/app_routes.dart';
import 'package:pauseask/core/router/startup_guard.dart';
import 'package:pauseask/features/auth/phone_login_screen.dart';

StartupStep step({
  bool language = true,
  bool onboarding = true,
  bool consent = true,
  bool authLoading = false,
  bool signedIn = true,
  bool profileLoading = false,
  bool hasProfile = true,
}) => resolveStartupStep(
  languageChosen: language,
  onboardingDone: onboarding,
  consentAccepted: consent,
  authLoading: authLoading,
  signedIn: signedIn,
  profileLoading: profileLoading,
  hasProfile: hasProfile,
);

void main() {
  group('resolveStartupStep', () {
    test('walks the first-run steps in order', () {
      expect(step(language: false, onboarding: false), StartupStep.language);
      expect(step(onboarding: false, consent: false), StartupStep.onboarding);
      expect(step(consent: false, signedIn: false), StartupStep.privacy);
      expect(step(signedIn: false), StartupStep.login);
      expect(step(hasProfile: false), StartupStep.profile);
      expect(step(), StartupStep.ready);
    });

    test('waits while auth or profile is loading', () {
      expect(step(authLoading: true), StartupStep.loading);
      expect(step(profileLoading: true), StartupStep.loading);
    });
  });

  group('redirectForStep', () {
    test('keeps the user on the login + OTP screens during login', () {
      expect(redirectForStep(StartupStep.login, AppRoutes.login), isNull);
      expect(redirectForStep(StartupStep.login, AppRoutes.otp), isNull);
      expect(
        redirectForStep(StartupStep.login, AppRoutes.home),
        AppRoutes.login,
      );
    });

    test('signed-in users with a profile go straight to Home', () {
      expect(
        redirectForStep(StartupStep.ready, AppRoutes.splash),
        AppRoutes.home,
      );
      expect(
        redirectForStep(StartupStep.ready, AppRoutes.onboarding),
        AppRoutes.home,
      );
      expect(redirectForStep(StartupStep.ready, AppRoutes.home), isNull);
    });

    test('circle screens are reachable once ready', () {
      expect(redirectForStep(StartupStep.ready, AppRoutes.circle), isNull);
      expect(redirectForStep(StartupStep.ready, AppRoutes.circleJoin), isNull);
      expect(
        redirectForStep(StartupStep.login, AppRoutes.circle),
        AppRoutes.login,
      );
    });

    test('language can be changed later', () {
      expect(redirectForStep(StartupStep.ready, AppRoutes.language), isNull);
    });

    test('no profile → profile setup', () {
      expect(
        redirectForStep(StartupStep.profile, AppRoutes.home),
        AppRoutes.profileSetup,
      );
    });
  });

  group('toE164', () {
    test('accepts Indian and other country numbers', () {
      expect(toE164('+91', '98765 43210'), '+919876543210');
      expect(toE164('+1', '415-555-0100'), '+14155550100');
    });

    test('rejects bad input', () {
      expect(toE164('91', '9876543210'), isNull);
      expect(toE164('+91', '123'), isNull);
      expect(toE164('+91', ''), isNull);
    });
  });
}
