import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import '../auth/phone_auth_controller.dart';
import 'account_repository.dart';

/// The exact word to type, in every language (Play Store-style confirmation).
const deleteConfirmWord = 'DELETE';

/// Explains what is deleted; only typing DELETE enables the button.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _failed = false;

  bool get _confirmed => _confirm.text.trim() == deleteConfirmWord;

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_confirmed || _busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref.read(accountRepositoryProvider).deleteMyAccount();
      // The router sends the user back to the very start.
      await ref
          .read(phoneAuthControllerProvider.notifier)
          .signOut(forgetDevice: true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final items = [
      l10n.deleteItemProfile,
      l10n.deleteItemChecks,
      l10n.deleteItemCheckins,
      l10n.deleteItemCircle,
      l10n.deleteItemLogin,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccount)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.delete_forever,
              size: 72,
              color: AppColors.riskHigh,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.deleteAccountIntro,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.close, color: AppColors.riskHigh),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: textTheme.bodyLarge)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(l10n.deleteKeptNote, style: textTheme.bodyMedium),
            const SizedBox(height: 24),
            TextField(
              controller: _confirm,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              style: textTheme.titleLarge?.copyWith(letterSpacing: 4),
              decoration: InputDecoration(
                labelText: l10n.deleteTypeHint,
                hintText: deleteConfirmWord,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _delete(),
            ),
            if (_failed) ...[
              const SizedBox(height: 12),
              ErrorText(l10n.deleteFailed),
            ],
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.riskHigh,
              ),
              onPressed: _confirmed && !_busy ? _delete : null,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(l10n.deleteForever),
            ),
          ],
        ),
      ),
    );
  }
}
