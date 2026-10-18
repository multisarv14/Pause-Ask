import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import 'check_error.dart';
import 'check_models.dart';

/// Paste/type a message, or confirm and correct text from OCR, voice or a
/// share, before it is checked.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, this.draft});

  final CheckDraft? draft;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  late final _text = TextEditingController(text: widget.draft?.text ?? '');
  CheckError? _error;

  CheckSource get _source => widget.draft?.source ?? CheckSource.typed;
  bool get _isConfirm => (widget.draft?.text ?? '').isNotEmpty;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pasted = data?.text?.trim() ?? '';
    if (pasted.isEmpty) return;
    setState(() {
      _text.text = pasted;
      _error = null;
    });
  }

  void _check() {
    final text = _text.text.trim();
    final error = text.isEmpty
        ? CheckError.empty
        : text.length > AppConstants.maxCheckTextLength
        ? CheckError.tooLong
        : null;
    setState(() => _error = error);
    if (error != null) return;
    context.push(
      AppRoutes.checkRun,
      extra: CheckDraft(text: text, source: _source),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.composeTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_isConfirm) ...[
              Text(l10n.composeConfirmHint, style: textTheme.titleMedium),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _text,
              autofocus: !_isConfirm,
              minLines: 6,
              maxLines: 14,
              maxLength: AppConstants.maxCheckTextLength,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              keyboardType: TextInputType.multiline,
              style: textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.composeHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            if (!_isConfirm) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _paste,
                icon: const Icon(Icons.content_paste),
                label: Text(l10n.pasteButton),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              ErrorText(_error!.message(l10n)),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _check,
              icon: const Icon(Icons.shield_outlined),
              label: Text(l10n.checkNow),
            ),
          ],
        ),
      ),
    );
  }
}
