import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../check/check_actions.dart';
import '../checkin/my_checkin_card.dart';
import '../feed/feed_widgets.dart';
import '../guardian/guardian_home_section.dart';
import '../history/history_repository.dart';
import '../profile/profile_repository.dart';
import '../sos/sos_button.dart';

/// Time-of-day greeting with the user's name.
String homeGreeting(AppLocalizations l10n, String name, {DateTime? now}) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 12) return l10n.greetingMorning(name);
  if (hour < 17) return l10n.greetingAfternoon(name);
  return l10n.greetingEvening(name);
}

/// Home for both roles: greeting, check-in status, main actions, family
/// requests (guardians), today's scam alert, history and circle.
/// Settings live behind the gear icon.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(userProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final family = ref.watch(historyShowsFamilyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            iconSize: 30,
            constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Semantics(
              header: true,
              child: Text(
                homeGreeting(l10n, profile.name),
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (profile.isGuardian && !profile.isProtected) ...[
              const SizedBox(height: 6),
              Text(l10n.homeGuardianText, style: textTheme.bodyLarge),
            ],
            const SizedBox(height: 16),
            if (profile.isProtected) ...[
              const MyCheckinCard(),
              const SizedBox(height: 16),
              const ProtectedActions(),
              const SizedBox(height: 20),
              const SosButton(),
              const SizedBox(height: 28),
            ],
            if (profile.isGuardian) ...[
              const GuardianHomeSection(),
              const SizedBox(height: 20),
            ],
            const FeedCard(),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.history),
              icon: const Icon(Icons.history),
              label: Text(
                family ? l10n.historyTitleFamily : l10n.historyTitleMine,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.circle),
              icon: const Icon(Icons.family_restroom),
              label: Text(l10n.myCircle),
            ),
          ],
        ),
      ),
    );
  }
}
