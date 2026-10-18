import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/phone_login_screen.dart';
import '../../features/check/check_models.dart';
import '../../features/check/checking_screen.dart';
import '../../features/check/compose_screen.dart';
import '../../features/check/ocr_screen.dart';
import '../../features/check/result_screen.dart';
import '../../features/check/voice_screen.dart';
import '../../features/check/guardian_response_screen.dart';
import '../../features/checkin/checkin_settings_screen.dart';
import '../../features/circle/circle_screen.dart';
import '../../features/legal/legal_content.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/settings/delete_account_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../errors/app_errors.dart';
import '../../features/feed/feed_widgets.dart';
import '../../features/history/history_screens.dart';
import '../../features/settings/battery_guide_screen.dart';
import '../../features/sos/sos_repository.dart';
import '../../features/sos/sos_screens.dart';
import '../../features/guardian/guardian_alert_screen.dart';
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
    // Unknown links (e.g. an old notification) get the friendly screen.
    errorBuilder: (context, state) => const FriendlyErrorView(),
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
        path: AppRoutes.check,
        builder: (context, state) =>
            ComposeScreen(draft: state.extra as CheckDraft?),
        routes: [
          GoRoute(
            path: 'voice',
            builder: (context, state) => const VoiceScreen(),
          ),
          GoRoute(
            path: 'ocr',
            builder: (context, state) =>
                OcrScreen(imagePath: state.extra! as String),
          ),
          GoRoute(
            path: 'run',
            builder: (context, state) =>
                CheckingScreen(draft: state.extra! as CheckDraft),
          ),
          GoRoute(
            path: 'response/:checkId',
            builder: (context, state) => GuardianResponseScreen(
              checkId: state.pathParameters['checkId']!,
            ),
          ),
          GoRoute(
            path: 'result',
            builder: (context, state) =>
                ResultScreen(outcome: state.extra! as CheckOutcome),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'delete-account',
            builder: (context, state) => const DeleteAccountScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/legal/:doc',
        builder: (context, state) => LegalScreen(
          doc: LegalDoc.values.byName(state.pathParameters['doc']!),
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.crashTest,
          builder: (context, state) => const CrashTestScreen(),
        ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
        routes: [
          GoRoute(
            path: ':checkId',
            builder: (context, state) =>
                CheckDetailScreen(checkId: state.pathParameters['checkId']!),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.feed,
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: AppRoutes.sosSent,
        builder: (context, state) =>
            SosSentScreen(result: state.extra! as SosResult),
      ),
      GoRoute(
        path: '/guardian/sos/:uid',
        builder: (context, state) =>
            SosAlertScreen(memberUid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: AppRoutes.checkinSettings,
        builder: (context, state) => const CheckinSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.batteryGuide,
        builder: (context, state) => const BatteryGuideScreen(),
      ),
      GoRoute(
        path: '/guardian/check/:checkId',
        builder: (context, state) =>
            GuardianAlertScreen(checkId: state.pathParameters['checkId']!),
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
