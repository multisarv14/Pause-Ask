import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/language_provider.dart';
import '../../core/router/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../services/tts/tts_service.dart';
import '../guardian/guardian_repository.dart';
import 'check_models.dart';

/// Full-screen guardian reply on the Protected user's phone:
/// red STOP, green OK, blue "calling you". Read aloud automatically once.
class GuardianResponseScreen extends ConsumerStatefulWidget {
  const GuardianResponseScreen({super.key, required this.checkId});

  final String checkId;

  @override
  ConsumerState<GuardianResponseScreen> createState() =>
      _GuardianResponseScreenState();
}

class _GuardianResponseScreenState
    extends ConsumerState<GuardianResponseScreen> {
  // Cached: `ref` can't be used in dispose().
  late final TtsService _tts = ref.read(ttsServiceProvider);
  bool _autoRead = false;
  bool _speaking = false;

  @override
  void dispose() {
    if (_speaking) _tts.stop();
    super.dispose();
  }

  static String title(AppLocalizations l10n, GuardianReply reply) =>
      switch (reply) {
        GuardianReply.stop => l10n.responseLabelStop,
        GuardianReply.ok => l10n.responseLabelOk,
        GuardianReply.call => l10n.responseCallTitle,
      };

  static String body(AppLocalizations l10n, GuardianResponse r) =>
      switch (r.reply) {
        GuardianReply.stop => l10n.responseStopBody(r.byName),
        GuardianReply.ok => l10n.responseOkBody(r.byName),
        GuardianReply.call => l10n.responseCallBody(r.byName),
      };

  Future<void> _read(GuardianResponse r) async {
    final l10n = AppLocalizations.of(context);
    final tts = _tts;
    if (_speaking) {
      await tts.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    final ok = await tts.speak(
      '${title(l10n, r.reply)}. ${body(l10n, r)}',
      languageCode: ref.read(languageProvider) ?? 'en',
      onDone: () {
        if (mounted) setState(() => _speaking = false);
      },
    );
    if (mounted) setState(() => _speaking = ok);
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final response = ref
        .watch(checkRecordProvider(widget.checkId))
        .value
        ?.guardianResponse;

    if (response == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_autoRead) {
      _autoRead = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _read(response));
    }

    final reply = response.reply;
    final onColor = reply.onColor;
    return Scaffold(
      backgroundColor: reply.color,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 24),
            Icon(reply.icon, size: 120, color: onColor),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                title(l10n, reply),
                textAlign: TextAlign.center,
                style: textTheme.displayMedium?.copyWith(
                  color: onColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              body(l10n, response),
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: onColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: onColor,
                foregroundColor: reply.color,
              ),
              onPressed: () => _read(response),
              icon: Icon(_speaking ? Icons.stop : Icons.volume_up),
              label: Text(_speaking ? l10n.stopReading : l10n.readAloud),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: onColor,
                side: BorderSide(color: onColor, width: 2),
              ),
              onPressed: _close,
              child: Text(l10n.closeButton),
            ),
          ],
        ),
      ),
    );
  }
}
