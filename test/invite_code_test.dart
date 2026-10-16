import 'package:flutter_test/flutter_test.dart';
import 'package:pauseask/features/circle/invite_code.dart';

void main() {
  test('alphabet has no look-alike characters', () {
    for (final ch in ['0', 'O', '1', 'I', 'L']) {
      expect(inviteAlphabet.contains(ch), isFalse, reason: ch);
    }
  });

  test('normalizes lowercase, spaces and dashes', () {
    expect(normalizeInviteCode(' abc-dEf '), 'ABCDEF');
    expect(normalizeInviteCode('AB CD 23'), 'ABCD23');
  });

  test('rejects bad codes', () {
    expect(normalizeInviteCode('ABC'), isNull);
    expect(normalizeInviteCode('ABCDE0'), isNull);
    expect(normalizeInviteCode(''), isNull);
  });
}
