import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';

/// v1 has no third-party crash reporting: errors are logged to the console
/// and the user sees a friendly screen instead of a red error box.
void installErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('PauseAsk error: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PauseAsk uncaught error: $error\n$stack');
    return true; // handled: don't crash the app
  };
  ErrorWidget.builder = (details) => const FriendlyErrorView();
}

/// Shown when a screen fails to build, or for an unknown route.
class FriendlyErrorView extends StatelessWidget {
  const FriendlyErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    // May be built where localizations aren't available yet.
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sentiment_dissatisfied_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.errorScreenTitle ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.errorScreenBody ??
                      'Sorry, this part of PauseAsk had a problem. '
                          'Please go back and try again.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    final router = GoRouter.maybeOf(context);
                    if (router != null) router.go(AppRoutes.home);
                  },
                  child: Text(l10n?.goHome ?? 'Go to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Debug-only screen that throws while building, to see the error screen.
class CrashTestScreen extends StatelessWidget {
  const CrashTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) throw StateError('Crash test (debug only)');
    return const FriendlyErrorView();
  }
}
