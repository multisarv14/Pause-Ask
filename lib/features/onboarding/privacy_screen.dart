import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_providers.dart';

/// Plain-language privacy summary. "I agree" is the only way forward.
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final points = [
      (Icons.person_outline, l10n.privacyPointData),
      (Icons.text_snippet_outlined, l10n.privacyPointChecks),
      (Icons.auto_delete_outlined, l10n.privacyPointDelete),
      (Icons.warning_amber_rounded, l10n.privacyPointAi),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(l10n.privacyIntro, style: textTheme.titleMedium),
                  const SizedBox(height: 24),
                  for (final (icon, text) in points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, size: 32, color: AppColors.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(text, style: textTheme.bodyLarge),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.privacyAgreeHint,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    // The router moves on to login once consent is saved.
                    onPressed: () =>
                        ref.read(consentProvider.notifier).accept(),
                    child: Text(l10n.privacyAgree),
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
