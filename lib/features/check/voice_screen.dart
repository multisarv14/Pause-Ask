import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/l10n/language_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import 'check_models.dart';

enum _VoiceProblem { notAvailable, permission, nothingHeard }

/// "Tell us what happened": on-device speech-to-text in the app language.
class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  final _speech = SpeechToText();
  bool _ready = false;
  bool _listening = false;
  String _transcript = '';
  _VoiceProblem? _problem;
  String? _localeId;

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  Future<bool> _init() async {
    if (_ready) return true;
    final ok = await _speech.initialize(
      onError: _onError,
      onStatus: (status) {
        if (status == SpeechToText.doneStatus ||
            status == SpeechToText.notListeningStatus) {
          if (mounted) setState(() => _listening = false);
        }
      },
    );
    if (!ok) {
      setState(() => _problem = _VoiceProblem.permission);
      return false;
    }
    // Find hi_IN / mr_IN / en_IN (ids differ: "mr_IN" or "mr-IN").
    final lang = ref.read(languageProvider) ?? 'en';
    final locales = await _speech.locales();
    String? match(String prefix) => locales
        .map((l) => l.localeId)
        .where((id) => id.toLowerCase().replaceAll('-', '_').startsWith(prefix))
        .firstOrNull;
    _localeId = match('${lang}_in') ?? match(lang);
    if (_localeId == null) {
      setState(() => _problem = _VoiceProblem.notAvailable);
      return false;
    }
    _ready = true;
    return true;
  }

  void _onError(SpeechRecognitionError error) {
    if (!mounted) return;
    final msg = error.errorMsg;
    setState(() {
      _listening = false;
      _problem = switch (msg) {
        'error_no_match' || 'error_speech_timeout' =>
          _transcript.isEmpty ? _VoiceProblem.nothingHeard : null,
        'error_permission' ||
        'error_insufficient_permissions' => _VoiceProblem.permission,
        // Language pack missing for on-device recognition, or no recognizer.
        _ => _VoiceProblem.notAvailable,
      };
    });
  }

  Future<void> _toggle() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _problem = null);
    if (!await _init()) return;
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (r) {
        if (mounted) setState(() => _transcript = r.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        onDevice: true, // privacy: audio stays on the phone
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 6),
      ),
    );
  }

  void _useText() {
    context.pushReplacement(
      AppRoutes.check,
      extra: CheckDraft(text: _transcript, source: CheckSource.voice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final problem = switch (_problem) {
      _VoiceProblem.notAvailable => l10n.voiceNotAvailable,
      _VoiceProblem.permission => l10n.micPermissionDenied,
      _VoiceProblem.nothingHeard => l10n.voiceNothingHeard,
      null => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tellUsWhatHappened)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.voiceIntro,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            Center(
              child: Semantics(
                button: true,
                label: _listening ? l10n.voiceTapToStop : l10n.voiceTapToStart,
                excludeSemantics: true,
                child: Material(
                  color: _listening ? AppColors.riskHigh : AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _toggle,
                    child: SizedBox.square(
                      dimension: 140,
                      child: Icon(
                        _listening ? Icons.stop : Icons.mic,
                        size: 72,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _listening ? l10n.voiceListening : l10n.voiceTapToStart,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            if (problem != null) ...[
              const SizedBox(height: 24),
              ErrorText(problem),
            ],
            if (_transcript.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(_transcript, style: textTheme.titleMedium),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _listening ? null : _useText,
                icon: const Icon(Icons.check),
                label: Text(l10n.voiceUseText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
