import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_scale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../auth/phone_auth_controller.dart';
import '../profile/profile_repository.dart';
import '../profile/user_profile.dart';

/// Placeholder Home: text depends on the user's roles.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _roleText(AppLocalizations l10n, UserProfile p) {
    if (p.isProtected && p.isGuardian) return l10n.homeBothText;
    if (p.isGuardian) return l10n.homeGuardianText;
    return l10n.homeProtectedText;
  }

  void _setLargeText(WidgetRef ref, UserProfile profile, bool enabled) {
    ref.read(largeTextProvider.notifier).set(enabled);
    ref
        .read(profileRepositoryProvider)
        .updatePreferences(profile.uid, largeText: enabled)
        .ignore();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(userProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.homeGreeting(profile.name),
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(_roleText(l10n, profile), style: textTheme.titleMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.circle),
              icon: const Icon(Icons.family_restroom),
              label: Text(l10n.myCircle),
            ),
            const SizedBox(height: 16),
            Text(l10n.homeComingSoon, style: textTheme.bodyMedium),
            const Divider(height: 48),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: ref.watch(largeTextProvider),
              onChanged: (v) => _setLargeText(ref, profile, v),
              title: Text(l10n.largeText),
              subtitle: Text(l10n.largeTextHint),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.language),
              icon: const Icon(Icons.translate),
              label: Text(l10n.changeLanguage),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(phoneAuthControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}
