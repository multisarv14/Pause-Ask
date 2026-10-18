import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/language_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/tts/tts_service.dart';
import '../../services/notifications/notification_service.dart';
import '../circle/circle_repository.dart';
import '../guardian/guardian_repository.dart';
import 'check_models.dart';

/// Colored, read-aloud risk result.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.outcome});

  final CheckOutcome outcome;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  // Cached: `ref` can't be used in dispose().
  late final TtsService _tts = ref.read(ttsServiceProvider);
  bool _speaking = false;
  bool _voiceMissing = false;

  @override
  void dispose() {
    if (_speaking) _tts.stop();
    super.dispose();
  }

  String _spokenText(AppLocalizations l10n) {
    final r = widget.outcome.result;
    final steps = [
      for (var i = 0; i < r.whatToDo.length; i++) '${i + 1}. ${r.whatToDo[i]}',
    ];
    return [
      '${r.riskLevel.label(l10n)}.',
      r.summary,
      if (r.redFlags.isNotEmpty)
        '${l10n.redFlagsTitle}: ${r.redFlags.join('. ')}.',
      '${l10n.whatToDoTitle}: ${steps.join(' ')}',
    ].join(' ');
  }

  Future<void> _toggleReadAloud() async {
    final tts = _tts;
    if (_speaking) {
      await tts.stop();
      setState(() => _speaking = false);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final ok = await tts.speak(
      _spokenText(l10n),
      languageCode: ref.read(languageProvider) ?? 'en',
      onDone: () {
        if (mounted) setState(() => _speaking = false);
      },
    );
    setState(() {
      _speaking = ok;
      _voiceMissing = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final r = widget.outcome.result;

    // A guardian's reply opens full-screen as soon as it arrives.
    ref.listen(checkRecordProvider(widget.outcome.checkId), (_, next) {
      if (next.value?.guardianResponse == null) return;
      openGuardianResponse(
        ref.read(shownResponsesProvider.notifier),
        GoRouter.of(context),
        widget.outcome.checkId,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            RiskBanner(result: r),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    r.summary,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _toggleReadAloud,
                    icon: Icon(_speaking ? Icons.stop : Icons.volume_up),
                    label: Text(_speaking ? l10n.stopReading : l10n.readAloud),
                  ),
                  if (_voiceMissing) ...[
                    const SizedBox(height: 8),
                    Text(l10n.ttsVoiceMissing, style: textTheme.bodyMedium),
                  ],
                  if (r.redFlags.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionTitle(l10n.redFlagsTitle),
                    for (final flag in r.redFlags)
                      _RedFlagChip(flag, r.riskLevel),
                  ],
                  const SizedBox(height: 28),
                  _SectionTitle(l10n.whatToDoTitle),
                  for (var i = 0; i < r.whatToDo.length; i++)
                    _Step(number: i + 1, text: r.whatToDo[i]),
                  const SizedBox(height: 24),
                  _FamilyStatus(checkId: widget.outcome.checkId),
                  const SizedBox(height: 16),
                  Text(l10n.resultDisclaimer, style: textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(l10n.done),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.pushReplacement(AppRoutes.check),
                    child: Text(l10n.checkAnother),
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

/// Full-width banner in the risk colour: icon, level and scam type.
class RiskBanner extends StatelessWidget {
  const RiskBanner({super.key, required this.result});

  final CheckResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final level = result.riskLevel;
    final label = level.label(l10n);

    return Semantics(
      header: true,
      label: l10n.riskSemantics(label),
      child: Container(
        width: double.infinity,
        color: level.color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ExcludeSemantics(
          child: Row(
            children: [
              Icon(level.icon, size: 56, color: level.onColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.headlineMedium?.copyWith(
                        color: level.onColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (result.scamType.isNotEmpty)
                      Text(
                        result.scamType,
                        style: textTheme.titleMedium?.copyWith(
                          color: level.onColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class _RedFlagChip extends StatelessWidget {
  const _RedFlagChip(this.text, this.level);

  final String text;
  final RiskLevel level;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: level.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: level.color, width: 1.5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.flag,
          color: level.color == AppColors.riskBeCareful
              ? AppColors.text
              : level.color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Text(
              '$number',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text, style: textTheme.titleMedium),
            ),
          ),
        ],
      ),
    );
  }
}

/// What happened with the family alert for this check, live.
class _FamilyStatus extends ConsumerWidget {
  const _FamilyStatus({required this.checkId});

  final String checkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final inCircle = ref.watch(myCircleProvider).value != null;
    final check = ref.watch(checkRecordProvider(checkId)).value;
    final response = check?.guardianResponse;

    final (String text, String? action, VoidCallback? onAction) = switch ((
      inCircle,
      check?.guardianCount,
      response,
    )) {
      (_, _, final GuardianResponse r) => (
        l10n.familyReplied(r.byName, r.reply.label(l10n)),
        l10n.viewReply,
        () => context.push(AppRoutes.checkResponse(checkId)),
      ),
      (false, _, _) => (
        l10n.familyAddToGetHelp,
        l10n.myCircle,
        () => context.push(AppRoutes.circle),
      ),
      (true, null, _) => (l10n.familyAlerting, null, null),
      (true, 0, _) => (
        l10n.familyNoGuardian,
        l10n.myCircle,
        () => context.push(AppRoutes.circle),
      ),
      _ => (l10n.familyAlerted, null, null),
    };

    return Card(
      color: (response?.reply.color ?? AppColors.primary).withValues(
        alpha: 0.10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  response?.reply.icon ?? Icons.family_restroom,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onAction, child: Text(action)),
            ],
          ],
        ),
      ),
    );
  }
}
