import 'package:flutter/material.dart';

/// Brand and risk-level colours. High-contrast on purpose.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF0D3B66); // deep, trustworthy blue
  static const Color onPrimary = Colors.white;
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF111827);

  // Risk levels. The AI never says "safe" — green is reserved for a
  // guardian's human "OK".
  static const Color riskHigh = Color(0xFFC62828); // red
  static const Color riskSuspicious = Color(0xFFE65100); // amber / deep orange
  static const Color riskBeCareful = Color(0xFFF9A825); // yellow
  static const Color guardianOk = Color(0xFF2E7D32); // green

  // Text colours that keep contrast on top of each risk colour.
  static const Color onRiskHigh = Colors.white;
  static const Color onRiskSuspicious = Colors.white;
  static const Color onRiskBeCareful = Color(0xFF111827);
  static const Color onGuardianOk = Colors.white;
}
