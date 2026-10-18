import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/language_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import 'check_error.dart';
import 'check_models.dart';
import 'check_repository.dart';

/// Calls `analyzeCheck` and shows a calm waiting screen, then the result.
class CheckingScreen extends ConsumerStatefulWidget {
  const CheckingScreen({super.key, required this.draft});

  final CheckDraft draft;

  @override
  ConsumerState<CheckingScreen> createState() => _CheckingScreenState();
}

class _CheckingScreenState extends ConsumerState<CheckingScreen> {
  CheckError? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() => _error = null);
    try {
      final outcome = await ref
          .read(checkRepositoryProvider)
          .analyze(widget.draft, language: ref.read(languageProvider) ?? 'en');
      if (mounted) {
        context.pushReplacement(AppRoutes.checkResult, extra: outcome);
      }
    } catch (e) {
      if (mounted) setState(() => _error = CheckError.from(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkingTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            if (error == null) ...[
              const Center(
                child: SizedBox.square(
                  dimension: 72,
                  child: CircularProgressIndicator(strokeWidth: 6),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.checkingTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
            ] else
              ErrorText(error.message(l10n)),
            const SizedBox(height: 32),
            // The reminder stays visible while waiting and on errors.
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.riskBeCareful.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.riskBeCareful, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pan_tool_outlined, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.checkingReminder,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 24),
              if (error == CheckError.network || error == CheckError.generic)
                FilledButton(onPressed: _run, child: Text(l10n.tryAgain)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.goBack),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
