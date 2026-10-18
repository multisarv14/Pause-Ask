import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauseask/features/check/check_error.dart';
import 'package:pauseask/features/check/check_models.dart';
import 'package:pauseask/services/ocr/ocr_service.dart';
import 'package:pauseask/services/share/share_intent_listener.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

FirebaseFunctionsException fnError(String code, [String? reason]) =>
    FirebaseFunctionsException(
      message: reason ?? code,
      code: code,
      details: reason == null ? null : {'reason': reason},
    );

void main() {
  group('RiskLevel', () {
    test('maps wire values', () {
      expect(RiskLevel.fromWire('HIGH'), RiskLevel.high);
      expect(RiskLevel.fromWire('SUSPICIOUS'), RiskLevel.suspicious);
      expect(RiskLevel.fromWire('BE_CAREFUL'), RiskLevel.beCareful);
    });

    test('unknown or "SAFE" never becomes anything safer than BE_CAREFUL', () {
      expect(RiskLevel.fromWire('SAFE'), RiskLevel.beCareful);
      expect(RiskLevel.fromWire(null), RiskLevel.beCareful);
    });
  });

  group('CheckError.from', () {
    test('maps function reasons', () {
      expect(
        CheckError.from(fnError('resource-exhausted', 'DAILY_LIMIT_REACHED')),
        CheckError.dailyLimit,
      );
      expect(
        CheckError.from(fnError('invalid-argument', 'TEXT_TOO_LONG')),
        CheckError.tooLong,
      );
      expect(
        CheckError.from(fnError('invalid-argument', 'INVALID_TEXT')),
        CheckError.empty,
      );
      expect(CheckError.from(fnError('unavailable')), CheckError.network);
      expect(CheckError.from(fnError('internal')), CheckError.generic);
      expect(CheckError.from(Exception('x')), CheckError.generic);
    });
  });

  group('pickOcrText', () {
    test('prefers the Devanagari model for Hindi/Marathi screenshots', () {
      expect(
        pickOcrText(
          latin: 'ah ah',
          devanagari: 'आपका बिजली कनेक्शन आज रात कट जाएगा',
        ),
        'आपका बिजली कनेक्शन आज रात कट जाएगा',
      );
    });

    test('keeps Latin text for English screenshots', () {
      expect(
        pickOcrText(
          latin: 'Your KYC is expired',
          devanagari: 'Your KYC is expired',
        ),
        'Your KYC is expired',
      );
      expect(pickOcrText(latin: 'Hello', devanagari: ''), 'Hello');
    });

    test('mixed message with some Hindi uses the Devanagari result', () {
      expect(
        pickOcrText(
          latin: 'Dear customer KYC',
          devanagari: 'Dear customer, आपका KYC update करें',
        ),
        'Dear customer, आपका KYC update करें',
      );
    });
  });

  group('payloadFrom (share intents)', () {
    test('text share', () {
      final p = payloadFrom([
        SharedMediaFile(
          path: ' Your account is blocked ',
          type: SharedMediaType.text,
        ),
      ]);
      expect(p, isA<SharedText>());
      expect((p! as SharedText).text, 'Your account is blocked');
    });

    test('image wins over text', () {
      final p = payloadFrom([
        SharedMediaFile(path: 'caption', type: SharedMediaType.text),
        SharedMediaFile(path: '/tmp/x.jpg', type: SharedMediaType.image),
      ]);
      expect((p! as SharedImage).path, '/tmp/x.jpg');
    });

    test('videos/files are ignored', () {
      expect(
        payloadFrom([
          SharedMediaFile(path: '/v.mp4', type: SharedMediaType.video),
        ]),
        isNull,
      );
    });
  });
}
