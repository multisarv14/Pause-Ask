import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../check/check_models.dart';
import '../check/result_screen.dart';
import '../circle/circle_models.dart';
import '../circle/circle_repository.dart';
import 'guardian_repository.dart';

String formatCheckTime(BuildContext context, DateTime time) => DateFormat(
  'd MMM, h:mm a',
  Localizations.localeOf(context).toString(),
).format(time);

/// A family member's check, opened from the push or Guardian Home:
/// who asked, when, the masked text, the AI result and three big replies.
class GuardianAlertScreen extends ConsumerStatefulWidget {
  const GuardianAlertScreen({super.key, required this.checkId});

  final String checkId;

  @override
  ConsumerState<GuardianAlertScreen> createState() =>
      _GuardianAlertScreenState();
}

class _GuardianAlertScreenState extends ConsumerState<GuardianAlertScreen> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _reply(
    CheckRecord check,
    CircleMember? asker,
    GuardianReply reply,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      if (check.guardianResponse == null) {
        final result = await ref
            .read(guardianRepositoryProvider)
            .respond(check.id, reply);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result.accepted
                  ? l10n.replySent(asker?.name ?? '')
                  : l10n.alreadyAnswered(
                      result.response.byName,
                      result.response.reply.label(l10n),
                    ),
            ),
          ),
        );
      }
      if (reply == GuardianReply.call) await _dial(asker);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _dial(CircleMember? asker) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final phone = asker?.phone ?? '';
    final opened =
        phone.isNotEmpty &&
        await launchUrl(Uri(scheme: 'tel', path: phone))
            .catchError((_) => false);
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(l10n.noPhone)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final record = ref.watch(checkRecordProvider(widget.checkId));
    final check = record.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guardianAlertTitle)),
      body: SafeArea(
        child: switch (record) {
          AsyncValue(hasError: true) || AsyncData(value: null) => ListView(
            padding: const EdgeInsets.all(24),
            children: [ErrorText(l10n.errorGeneric)],
          ),
          _ when check == null => const Center(
            child: CircularProgressIndicator(),
          ),
          _ => _body(context, l10n, textTheme, check),
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
    CheckRecord check,
  ) {
    final myUid = ref.watch(authStateProvider).value?.uid;
    final members = check.circleId == null
        ? const <CircleMember>[]
        : ref.watch(circleMembersProvider(check.circleId!)).value ?? const [];
    final asker = members.where((m) => m.uid == check.uid).firstOrNull;
    final answered = check.guardianResponse;
    final r = check.result;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        RiskBanner(result: r),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.askedBy(
                  asker?.name ?? '…',
                  formatCheckTime(context, check.createdAt),
                ),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(r.summary, style: textTheme.titleMedium),
              for (final flag in r.redFlags)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('• $flag', style: textTheme.bodyLarge),
                ),
              const SizedBox(height: 16),
              Text(l10n.maskedMessageTitle, style: textTheme.labelLarge),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
                child: SelectableText(
                  check.maskedText,
                  style: textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 24),
              if (answered != null)
                _AnsweredCard(
                  text: answered.byUid == myUid
                      ? l10n.replySent(asker?.name ?? '')
                      : l10n.alreadyAnswered(
                          answered.byName,
                          answered.reply.label(l10n),
                        ),
                  reply: answered.reply,
                )
              else ...[
                _ReplyButton(
                  reply: GuardianReply.stop,
                  label: l10n.respondStop,
                  onPressed: _busy
                      ? null
                      : () => _reply(check, asker, GuardianReply.stop),
                ),
                const SizedBox(height: 14),
                _ReplyButton(
                  reply: GuardianReply.ok,
                  label: l10n.respondOk,
                  onPressed: _busy
                      ? null
                      : () => _reply(check, asker, GuardianReply.ok),
                ),
              ],
              const SizedBox(height: 14),
              // Calling is always possible, answered or not.
              _ReplyButton(
                reply: GuardianReply.call,
                label: l10n.respondCall,
                onPressed: _busy
                    ? null
                    : () => _reply(check, asker, GuardianReply.call),
              ),
              if (_failed) ...[
                const SizedBox(height: 16),
                ErrorText(l10n.errorGeneric),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyButton extends StatelessWidget {
  const _ReplyButton({
    required this.reply,
    required this.label,
    required this.onPressed,
  });

  final GuardianReply reply;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 80),
    child: FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: reply.color,
        foregroundColor: reply.onColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
      onPressed: onPressed,
      icon: Icon(reply.icon, size: 32),
      label: Text(label, textAlign: TextAlign.center),
    ),
  );
}

class _AnsweredCard extends StatelessWidget {
  const _AnsweredCard({required this.text, required this.reply});

  final String text;
  final GuardianReply reply;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: reply.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: reply.color, width: 2),
    ),
    child: Row(
      children: [
        Icon(
          reply.icon,
          color: reply == GuardianReply.call ? AppColors.primary : reply.color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(text, style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
      ],
    ),
  );
}
