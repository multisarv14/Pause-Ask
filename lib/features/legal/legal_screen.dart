import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'legal_content.dart';

/// Fills `{email}` and `{company}`; an unset email shows a dash.
String fillLegal(String text) => text
    .replaceAll(
      '{email}',
      AppConstants.supportEmail.isEmpty ? '—' : AppConstants.supportEmail,
    )
    .replaceAll('{company}', AppConstants.legalEntity);

/// Privacy policy / terms / FAQ in the app language (plain-language version).
class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  static const _webPaths = {
    LegalDoc.privacy: '/privacy',
    LegalDoc.terms: '/terms',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final lang = ref.watch(languageProvider) ?? 'en';
    final sections = legalContent[doc]![lang] ?? legalContent[doc]!['en']!;
    final title = switch (doc) {
      LegalDoc.privacy => l10n.privacyPolicy,
      LegalDoc.terms => l10n.termsTitle,
      LegalDoc.faq => l10n.helpFaq,
    };
    final webPath = _webPaths[doc];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (doc != LegalDoc.faq)
              Text(
                '${AppConstants.legalEntity} · ${AppConstants.legalEffectiveDate}',
                style: textTheme.bodyMedium,
              ),
            for (final s in sections) ...[
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  s.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(fillLegal(s.body), style: textTheme.bodyLarge),
            ],
            if (webPath != null && AppConstants.websiteBaseUrl.isNotEmpty) ...[
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('${AppConstants.websiteBaseUrl}$webPath'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.readFullOnline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
