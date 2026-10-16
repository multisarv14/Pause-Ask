import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/language_provider.dart';
import '../../core/router/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_repository.dart';

/// First-run language picker; also opened later from Home to change it.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  Future<void> _choose(BuildContext context, WidgetRef ref, String code) async {
    await ref.read(languageProvider.notifier).set(code);

    final profile = ref.read(userProfileProvider).value;
    if (profile != null && profile.language != code) {
      // Best effort; the local choice already took effect.
      ref
          .read(profileRepositoryProvider)
          .updatePreferences(profile.uid, language: code)
          .ignore();
    }

    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      // The router redirect sends the user to the right next step.
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = ref.watch(languageProvider);

    return Scaffold(
      appBar: context.canPop()
          ? AppBar(title: Text(l10n.changeLanguage))
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.translate, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.languageTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.languageSubtitle, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            for (final MapEntry(key: code, value: name)
                in supportedLanguages.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 72,
                  child: code == current
                      ? FilledButton.icon(
                          onPressed: () => _choose(context, ref, code),
                          icon: const Icon(Icons.check),
                          label: Text(
                            name,
                            style: const TextStyle(fontSize: 24),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: () => _choose(context, ref, code),
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
