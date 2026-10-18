import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../check/check_models.dart';
import '../checkin/member_status_card.dart';
import '../circle/circle_models.dart';
import '../profile/user_profile.dart';
import '../circle/circle_repository.dart';
import 'guardian_alert_screen.dart';
import 'guardian_repository.dart';

/// Guardian Home: unanswered family checks (newest first) and each
/// Protected member's daily check-in status with a call button.
class GuardianHomeSection extends ConsumerWidget {
  const GuardianHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final checks = ref.watch(openCircleChecksProvider).value ?? const [];
    final myUid = ref.watch(authStateProvider).value?.uid;
    final circle = ref.watch(myCircleProvider).value;
    final members = circle == null
        ? const <CircleMember>[]
        : ref.watch(circleMembersProvider(circle.id)).value ?? const [];
    String nameOf(String uid) =>
        members.where((m) => m.uid == uid).firstOrNull?.name ?? '…';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.openRequestsTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        if (checks.isEmpty)
          Text(l10n.noOpenRequests, style: textTheme.bodyLarge)
        else
          for (final c in checks)
            _CheckTile(
              check: c,
              name: nameOf(c.uid),
              onTap: () => context.push(AppRoutes.guardianCheck(c.id)),
            ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            l10n.memberStatusTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        for (final m in members.where(
          (m) => m.uid != myUid && m.roles.contains(UserRoles.protected),
        ))
          MemberStatusCard(member: m),
      ],
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.check,
    required this.name,
    required this.onTap,
  });

  final CheckRecord check;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final level = check.result.riskLevel;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 10, color: level.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${level.label(l10n)} · ${formatCheckTime(context, check.createdAt)}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
