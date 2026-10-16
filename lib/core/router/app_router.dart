import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/phone_login_screen.dart';
import '../../features/circle/circle_screen.dart';
import '../../features/circle/create_circle_screen.dart';
import '../../features/circle/invite_screen.dart';
import '../../features/circle/join_circle_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/language_screen.dart';
import '../../features/onboarding/onboarding_providers.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/privacy_screen.dart';
import '../../features/profile/profile_repository.dart';
import '../../features/profile/profile_setup_screen.dart';
import '../l10n/language_provider.dart';
import '../widgets/splash_screen.dart';
import 'app_routes.dart';
import 'startup_guard.dart';

export 'app_routes.dart';

final startupStepProvider = Provider<StartupStep>((ref) {
  final consent = ref.watch(consentProvider);
  final auth = ref.watch(authStateProvider);
  final profile = ref.watch(userProfileProvider);
  return resolveStartupStep(
    languageChosen: ref.watch(languageProvider) != null,
    onboardingDone: ref.watch(onboardingDoneProvider),
    consentAccepted: consent?.isCurrent ?? false,
    authLoading: auth.isLoading,
    signedIn: auth.value != null,
    // A profile load error is shown on the splash screen.
    profileLoading: profile.isLoading || profile.hasError,
    hasProfile: profile.value != null,
  );
});

final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-run the redirect whenever the startup step changes.
  final refresh = ValueNotifier<StartupStep>(ref.read(startupStepProvider));
  ref.listen(startupStepProvider, (_, step) => refresh.value = step);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) =>
        redirectForStep(ref.read(startupStepProvider), state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const PhoneLoginScreen(),
        routes: [
          GoRoute(path: 'otp', builder: (context, state) => const OtpScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.circle,
        builder: (context, state) => const CircleScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateCircleScreen(),
          ),
          GoRoute(
            path: 'join',
            builder: (context, state) => const JoinCircleScreen(),
          ),
          GoRoute(
            path: 'invite',
            builder: (context, state) => const InviteScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
