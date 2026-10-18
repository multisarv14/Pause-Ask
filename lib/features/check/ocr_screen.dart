import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ocr/ocr_service.dart';
import 'check_models.dart';

/// Reads text from a screenshot on the phone, then hands it to the
/// confirm/edit screen. The image itself is never uploaded.
class OcrScreen extends ConsumerStatefulWidget {
  const OcrScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  ConsumerState<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends ConsumerState<OcrScreen> {
  bool _noText = false;

  @override
  void initState() {
    super.initState();
    _read();
  }

  Future<void> _read() async {
    String text;
    try {
      text = await ref.read(ocrServiceProvider).readText(widget.imagePath);
    } catch (_) {
      text = '';
    }
    if (!mounted) return;
    if (text.trim().isEmpty) {
      setState(() => _noText = true);
      return;
    }
    context.pushReplacement(
      AppRoutes.check,
      extra: CheckDraft(text: text, source: CheckSource.image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickScreenshot)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            if (_noText) ...[
              ErrorText(l10n.ocrNoText),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pushReplacement(AppRoutes.check),
                child: Text(l10n.pasteOrType),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.goBack),
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
              Text(
                l10n.readingScreenshot,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.imageStaysOnPhone)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
