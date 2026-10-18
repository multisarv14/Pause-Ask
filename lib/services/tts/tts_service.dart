import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

final ttsServiceProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  ref.onDispose(tts.stop);
  return tts;
});

/// "Read aloud" in the user's language (needs the phone's TTS voices).
class TtsService {
  final FlutterTts _tts = FlutterTts();

  static const _voices = {
    'en': ['en-IN', 'en-GB', 'en-US'],
    'hi': ['hi-IN'],
    'mr': ['mr-IN'],
  };

  /// Returns false when no voice for [languageCode] is installed; we never
  /// fall back to reading Hindi/Marathi with an English voice.
  Future<bool> speak(
    String text, {
    required String languageCode,
    VoidCallback? onDone,
  }) async {
    String? locale;
    for (final candidate in _voices[languageCode] ?? const <String>[]) {
      if (await _tts.isLanguageAvailable(candidate) == true) {
        locale = candidate;
        break;
      }
    }
    if (locale == null) return false;

    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.42); // slower for older listeners
    _tts.setCompletionHandler(() => onDone?.call());
    _tts.setCancelHandler(() => onDone?.call());
    await _tts.speak(text);
    return true;
  }

  Future<void> stop() => _tts.stop();
}
