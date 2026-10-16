import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../profile/user_profile.dart';
import 'circle_error.dart';
import 'circle_models.dart';
import 'circle_repository.dart';

/// "My family circle": empty state (create / join) or the member list.
class CircleScreen extends ConsumerWidget {
  const CircleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final circle = ref.watch(myCircleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.circleTitle)),
      body: SafeArea(
        child: circle.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _Message(
            text: l10n.errorGeneric,
            action: l10n.tryAgain,
            onAction: () => ref.invalidate(myCircleProvider),
          ),
          data: (circle) =>
              circle == null ? const _NoCircle() : _CircleView(circle: circle),
        ),
      ),
    );
  }
}

class _NoCircle extends StatelessWidget {
  const _NoCircle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        const Icon(Icons.family_restroom, size: 96, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          l10n.noCircleTitle,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.noCircleBody,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.circleCreate),
          icon: const Icon(Icons.add),
          label: Text(l10n.createCircle),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.circleJoin),
          icon: const Icon(Icons.vpn_key_outlined),
          label: Text(l10n.joinWithCode),
        ),
      ],
    );
  }
}

class _CircleView extends ConsumerStatefulWidget {
  const _CircleView({required this.circle});

  final Circle circle;

  @override
  ConsumerState<_CircleView> createState() => _CircleViewState();
}

class _CircleViewState extends ConsumerState<_CircleView> {
  bool _busy = false;

  Future<bool> _confirm(String title, String body, String action) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.riskHigh),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(CircleError.from(e).message(l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave(bool isOwner) async {
    final l10n = AppLocalizations.of(context);
    final ok = await _confirm(
      l10n.leaveConfirmTitle,
      isOwner ? l10n.leaveConfirmOwnerBody : l10n.leaveConfirmBody,
      l10n.leaveCircle,
    );
    if (ok) await _run(ref.read(circleRepositoryProvider).leaveCircle);
  }

  Future<void> _remove(CircleMember member) async {
    final l10n = AppLocalizations.of(context);
    final ok = await _confirm(
      l10n.removeConfirmTitle(member.name),
      l10n.removeConfirmBody,
      l10n.removeMember,
    );
    if (ok) {
      await _run(
        () => ref.read(circleRepositoryProvider).removeMember(member.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final circle = widget.circle;
    final myUid = ref.watch(authStateProvider).value?.uid;
    final isOwner = circle.ownerUid == myUid;
    final isFull = circle.memberUids.length >= AppConstants.maxCircleMembers;
    final members = ref.watch(circleMembersProvider(circle.id));

    // Owner first, then by join date (the stream is ordered by joinedAt).
    final sorted = [...?members.value]
      ..sort(
        (a, b) =>
            (b.uid == circle.ownerUid ? 1 : 0) -
            (a.uid == circle.ownerUid ? 1 : 0),
      );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          circle.name,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.membersCount(
            circle.memberUids.length,
            AppConstants.maxCircleMembers,
          ),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (members.isLoading && !members.hasValue)
          const Center(child: CircularProgressIndicator()),
        for (final m in sorted)
          _MemberTile(
            member: m,
            isOwner: m.uid == circle.ownerUid,
            isMe: m.uid == myUid,
            onRemove: isOwner && m.uid != myUid && !_busy
                ? () => _remove(m)
                : null,
          ),
        const SizedBox(height: 24),
        if (isFull)
          Text(l10n.circleErrorFull, style: textTheme.bodyLarge)
        else
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => context.push(AppRoutes.circleInvite),
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(l10n.inviteFamily),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.riskHigh,
            side: const BorderSide(color: AppColors.riskHigh, width: 2),
          ),
          onPressed: _busy ? null : () => _leave(isOwner),
          icon: const Icon(Icons.logout),
          label: Text(l10n.leaveCircle),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isOwner,
    required this.isMe,
    this.onRemove,
  });

  final CircleMember member;
  final bool isOwner;
  final bool isMe;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final initial = member.name.isEmpty ? '?' : member.name.characters.first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              child: Text(
                initial,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMe ? '${member.name} (${l10n.badgeYou})' : member.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (isOwner)
                        _Badge(
                          l10n.badgeOwner,
                          AppColors.primary,
                          AppColors.onPrimary,
                        ),
                      if (member.roles.contains(UserRoles.protected))
                        _Badge(
                          l10n.badgeProtected,
                          AppColors.riskBeCareful,
                          AppColors.onRiskBeCareful,
                        ),
                      if (member.roles.contains(UserRoles.guardian))
                        _Badge(
                          l10n.badgeGuardian,
                          AppColors.guardianOk,
                          AppColors.onGuardianOk,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                tooltip: l10n.removeMember,
                iconSize: 28,
                constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                color: AppColors.riskHigh,
                onPressed: onRemove,
                icon: const Icon(Icons.person_remove_outlined),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.action,
    required this.onAction,
  });

  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(text, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      FilledButton(onPressed: onAction, child: Text(action)),
    ],
  );
}
