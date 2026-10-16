import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/phone_auth_controller.dart';
import '../../features/profile/profile_repository.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Shown while auth/profile load, and when the profile can't be loaded.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 96,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appName,
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tagline,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                if (profile.hasError) ...[
                  Text(l10n.profileLoadError, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(userProfileProvider),
                    child: Text(l10n.tryAgain),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(phoneAuthControllerProvider.notifier)
                        .signOut(),
                    child: Text(l10n.logout),
                  ),
                ] else
                  Semantics(
                    label: l10n.loading,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
