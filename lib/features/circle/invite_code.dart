import 'package:flutter/services.dart';

/// Must match functions/src/lib/inviteCode.ts (no 0/O, 1/I/L).
const inviteAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
const inviteCodeLength = 6;

/// Uppercases and strips spaces/dashes; null if it can't be a valid code.
String? normalizeInviteCode(String raw) {
  final code = raw.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  if (code.length != inviteCodeLength) return null;
  if (!code.split('').every(inviteAlphabet.contains)) return null;
  return code;
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
