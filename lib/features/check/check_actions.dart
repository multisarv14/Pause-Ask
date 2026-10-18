import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Opens the system photo picker; the image is only read on the phone.
Future<void> pickScreenshot(BuildContext context) async {
  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (image == null || !context.mounted) return;
  context.push(AppRoutes.checkOcr, extra: image.path);
}

/// The Protected user's main actions on Home.
class ProtectedActions extends StatelessWidget {
  const ProtectedActions({super.key});

  void _openChooser(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        void go(void Function() action) {
          Navigator.pop(sheetContext);
          action();
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.chooseHowTitle,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => go(() => context.push(AppRoutes.checkVoice)),
                  icon: const Icon(Icons.mic),
                  label: Text(l10n.tellUsWhatHappened),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => go(() => context.push(AppRoutes.check)),
                  icon: const Icon(Icons.content_paste),
                  label: Text(l10n.pasteOrType),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => go(() => pickScreenshot(context)),
                  icon: const Icon(Icons.image_outlined),
                  label: Text(l10n.pickScreenshot),
                ),
                const SizedBox(height: 16),
                Text(l10n.shareTip),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The one very large primary action.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 120),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () => _openChooser(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pan_tool_outlined, size: 44),
                const SizedBox(height: 8),
                Text(
                  l10n.pauseAndAsk,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l10n.pauseAndAskHint,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.checkVoice),
            icon: const Icon(Icons.mic, size: 36),
            label: Text(l10n.tellUsWhatHappened),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.check),
          icon: const Icon(Icons.content_paste),
          label: Text(l10n.pasteOrType),
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => pickScreenshot(context),
          icon: const Icon(Icons.image_outlined),
          label: Text(l10n.pickScreenshot),
        ),
        const SizedBox(height: 8),
        Text(l10n.shareTip, style: textTheme.bodyMedium),
      ],
    );
  }
}
