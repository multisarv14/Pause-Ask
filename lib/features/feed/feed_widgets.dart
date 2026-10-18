import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/language_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/share_text.dart';
import '../../l10n/app_localizations.dart';
import 'feed_repository.dart';

/// Alert text + promo + Play Store link, shared via WhatsApp.
String feedShareText(AppLocalizations l10n, FeedItem item, String lang) =>
    '⚠️ ${item.titleFor(lang)}\n\n${item.bodyFor(lang)}\n\n'
    '${l10n.sharePromo(AppConstants.playStoreUrl)}';

class _ShareButton extends ConsumerWidget {
  const _ShareButton({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider) ?? 'en';
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1B7F3B), // WhatsApp-ish, AA contrast
      ),
      onPressed: () => shareViaWhatsAppOrSheet(feedShareText(l10n, item, lang)),
      icon: const Icon(Icons.share),
      label: Text(l10n.shareAlert),
    );
  }
}

/// "Scam alert of the day" on both home screens (latest item).
class FeedCard extends ConsumerWidget {
  const FeedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final lang = ref.watch(languageProvider) ?? 'en';
    final item = ref.watch(feedProvider).value?.firstOrNull;
    if (item == null) return const SizedBox.shrink();

    return Card(
      color: AppColors.riskBeCareful.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.riskSuspicious, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign, color: AppColors.riskSuspicious),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.feedCardTitle,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.titleFor(lang),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.bodyFor(lang),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _ShareButton(item: item),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => context.push(AppRoutes.feed),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
      ),
    );
  }
}

/// "See all": every active alert, newest first, expandable, shareable.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedTitle)),
      body: SafeArea(
        child: items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.errorGeneric)),
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.feedEmpty, textAlign: TextAlign.center),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _FeedTile(item: list[i]),
                ),
        ),
      ),
    );
  }
}

class _FeedTile extends ConsumerStatefulWidget {
  const _FeedTile({required this.item});

  final FeedItem item;

  @override
  ConsumerState<_FeedTile> createState() => _FeedTileState();
}

class _FeedTileState extends ConsumerState<_FeedTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final lang = ref.watch(languageProvider) ?? 'en';
    final item = widget.item;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(item.publishedAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(date, style: textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              item.titleFor(lang),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.bodyFor(lang),
              maxLines: _expanded ? null : 3,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: textTheme.bodyLarge,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? l10n.showLess : l10n.readMore),
              ),
            ),
            _ShareButton(item: item),
          ],
        ),
      ),
    );
  }
}
