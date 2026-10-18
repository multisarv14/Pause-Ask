import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/share_text.dart';
import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import 'circle_error.dart';
import 'circle_models.dart';
import 'circle_repository.dart';

/// Asks the server for the circle's invite code (re-used while valid).
final _inviteProvider = FutureProvider.autoDispose<CircleInvite>(
  (ref) => ref.watch(circleRepositoryProvider).createInvite(),
);

class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  String _message(AppLocalizations l10n, String circleName, String code) =>
      l10n.inviteMessage(circleName, code, AppConstants.playStoreUrl);

  Future<void> _shareOnWhatsApp(BuildContext context, String text) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await shareOnWhatsApp(text)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.whatsappNotInstalled)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final invite = ref.watch(_inviteProvider);
    final circleName = ref.watch(myCircleProvider).value?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inviteFamily)),
      body: SafeArea(
        child: invite.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ErrorText(CircleError.from(e).message(l10n)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(_inviteProvider),
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
          data: (invite) {
            final message = _message(l10n, circleName, invite.code);
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.inviteCodeTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: SelectableText(
                    invite.code,
                    textAlign: TextAlign.center,
                    semanticsLabel: invite.code.split('').join(' '),
                    style: textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.inviteCodeExplain,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF1B7F3B,
                    ), // WhatsApp-ish green, AA contrast
                  ),
                  onPressed: () => _shareOnWhatsApp(context, message),
                  icon: const Icon(Icons.chat),
                  label: Text(l10n.inviteViaWhatsApp),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      SharePlus.instance.share(ShareParams(text: message)),
                  icon: const Icon(Icons.share),
                  label: Text(l10n.shareOtherWay),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(ClipboardData(text: invite.code));
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.codeCopied)),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.copyCode),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
