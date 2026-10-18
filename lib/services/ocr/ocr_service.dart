import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final ocrServiceProvider = Provider<OcrService>((ref) => OcrService());

/// On-device OCR (ML Kit). The image is never uploaded anywhere.
class OcrService {
  /// Runs the Latin and Devanagari recognisers and keeps the better text.
  Future<String> readText(String imagePath) async {
    final image = InputImage.fromFilePath(imagePath);
    final latin = TextRecognizer(script: TextRecognitionScript.latin);
    final devanagari = TextRecognizer(script: TextRecognitionScript.devanagiri);
    try {
      final results = await Future.wait([
        latin.processImage(image),
        devanagari.processImage(image),
      ]);
      return pickOcrText(latin: results[0].text, devanagari: results[1].text);
    } finally {
      await latin.close();
      await devanagari.close();
    }
  }
}

final _devanagariChar = RegExp(r'[ऀ-ॿ]');

/// The Devanagari model also reads Latin letters, so prefer it whenever the
/// picture has a meaningful amount of Hindi/Marathi text.
String pickOcrText({required String latin, required String devanagari}) {
  final deva = devanagari.trim();
  final lat = latin.trim();
  final letters = deva.replaceAll(RegExp(r'\s'), '').length;
  if (letters == 0) return lat;
  final devaShare = _devanagariChar.allMatches(deva).length / letters;
  return devaShare >= 0.05 ? deva : lat;
}
