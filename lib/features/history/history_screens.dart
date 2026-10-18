import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../check/check_models.dart';
import '../check/result_screen.dart';
import '../circle/circle_models.dart';
import '../circle/circle_repository.dart';
import '../guardian/guardian_alert_screen.dart';
import '../guardian/guardian_repository.dart';
import '../profile/profile_repository.dart';
import 'history_repository.dart';

/// Asks, then deletes via the `deleteCheck` function. True if deleted.
Future<bool> confirmAndDeleteCheck(
  BuildContext context,
  WidgetRef ref,
  String checkId,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l10n.deleteCheckConfirm),
      content: Text(l10n.deleteCheckBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.riskHigh),
          onPressed: () => Navigator.pop(c, true),
          child: Text(l10n.deleteButton),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  try {
    await ref.read(historyRepositoryProvider).deleteCheck(checkId);
    messenger.showSnackBar(SnackBar(content: Text(l10n.deletedMessage)));
    return true;
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    return false;
  }
}

String _replyLine(AppLocalizations l10n, CheckRecord c) {
  final r = c.guardianResponse;
  return r == null
      ? l10n.noReplyYet
      : l10n.familyReplied(r.byName, r.reply.label(l10n));
}

/// Own checks (Protected) or the circle's checks (Guardian), newest first.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final family = ref.watch(historyShowsFamilyProvider);
    final checks = ref.watch(historyChecksProvider);
    final myUid = ref.watch(currentUidProvider);
    final circle = ref.watch(myCircleProvider).value;
    final members = circle == null
        ? const <CircleMember>[]
        : ref.watch(circleMembersProvider(circle.id)).value ?? const [];
    String? nameOf(String uid) =>
        family ? members.where((m) => m.uid == uid).firstOrNull?.name : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(family ? l10n.historyTitleFamily : l10n.historyTitleMine),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Icon(Icons.auto_delete_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.historyAutoDelete,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...switch (checks) {
              AsyncData(value: final list) when list.isEmpty => [
                _EmptyHistory(family: family),
              ],
              AsyncData(value: final list) => [
                for (final c in list)
                  _HistoryTile(
                    check: c,
                    askerName: nameOf(c.uid),
                    canDelete: c.uid == myUid,
                  ),
              ],
              AsyncError() => [Text(l10n.errorGeneric)],
              _ => [const Center(child: CircularProgressIndicator())],
            },
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.family});

  final bool family;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            l10n.historyEmptyTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            family ? l10n.historyEmptyFamily : l10n.historyEmptyBody,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({
    required this.check,
    required this.askerName,
    required this.canDelete,
  });

  final CheckRecord check;
  final String? askerName;
  final bool canDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final level = check.result.riskLevel;
    final reply = check.guardianResponse;

    final tile = Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.historyDetail(check.id)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 12, color: level.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [
                          level.label(l10n),
                          formatCheckTime(context, check.createdAt),
                          ?askerName,
                        ].join(' · '),
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        check.result.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            reply?.reply.icon ?? Icons.hourglass_empty,
                            size: 20,
                            color: reply?.reply == GuardianReply.ok
                                ? AppColors.guardianOk
                                : reply?.reply == GuardianReply.stop
                                ? AppColors.riskHigh
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _replyLine(l10n, check),
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (canDelete)
                IconButton(
                  tooltip: l10n.deleteButton,
                  constraints: const BoxConstraints(
                    minWidth: 56,
                    minHeight: 56,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      confirmAndDeleteCheck(context, ref, check.id),
                ),
            ],
          ),
        ),
      ),
    );

    if (!canDelete) return tile;
    return Dismissible(
      key: ValueKey(check.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        color: AppColors.riskHigh,
        child: const Icon(Icons.delete, color: AppColors.onRiskHigh, size: 32),
      ),
      confirmDismiss: (_) => confirmAndDeleteCheck(context, ref, check.id),
      child: tile,
    );
  }
}

/// One check in full (from History).
class CheckDetailScreen extends ConsumerWidget {
  const CheckDetailScreen({super.key, required this.checkId});

  final String checkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final check = ref.watch(checkRecordProvider(checkId)).value;
    final myUid = ref.watch(currentUidProvider);
    final isGuardian =
        ref.watch(userProfileProvider).value?.isGuardian ?? false;

    if (check == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.checkDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final r = check.result;
    final mine = check.uid == myUid;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkDetailTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            RiskBanner(result: r),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    formatCheckTime(context, check.createdAt),
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(r.summary, style: textTheme.titleLarge),
                  if (r.redFlags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.redFlagsTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    for (final f in r.redFlags)
                      Text('• $f', style: textTheme.bodyLarge),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l10n.whatToDoTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  for (var i = 0; i < r.whatToDo.length; i++)
                    Text(
                      '${i + 1}. ${r.whatToDo[i]}',
                      style: textTheme.bodyLarge,
                    ),
                  const SizedBox(height: 16),
                  Text(l10n.maskedMessageTitle, style: textTheme.labelLarge),
                  const SizedBox(height: 4),
                  SelectableText(check.maskedText, style: textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text(_replyLine(l10n, check), style: textTheme.titleMedium),
                  const SizedBox(height: 24),
                  if (!mine && isGuardian && check.guardianResponse == null)
                    FilledButton(
                      onPressed: () =>
                          context.push(AppRoutes.guardianCheck(check.id)),
                      child: Text(l10n.replyButton),
                    ),
                  if (mine)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.riskHigh,
                        side: const BorderSide(
                          color: AppColors.riskHigh,
                          width: 2,
                        ),
                      ),
                      onPressed: () async {
                        final router = GoRouter.of(context);
                        if (await confirmAndDeleteCheck(
                          context,
                          ref,
                          check.id,
                        )) {
                          router.pop();
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.deleteButton),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
