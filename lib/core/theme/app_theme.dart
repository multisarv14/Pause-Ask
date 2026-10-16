import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';

/// Calm, high-contrast Material 3 theme with large tap targets.
abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      error: AppColors.riskHigh,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      contrastLevel: 1.0, // maximum contrast
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final textTheme = _scaledTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

    const buttonSize = Size(88, AppConstants.minButtonHeight);
    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    );
    final buttonText = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
          side: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          textStyle: buttonText,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  /// Material's body text is 14–16 sp; lift everything so the base
  /// body size is [AppConstants.baseFontSize].
  static TextTheme _scaledTextTheme(TextTheme t) {
    const factor = AppConstants.baseFontSize / 16;
    TextStyle? s(TextStyle? style) =>
        style?.copyWith(fontSize: (style.fontSize ?? 16) * factor);
    return t.copyWith(
      displayLarge: s(t.displayLarge),
      displayMedium: s(t.displayMedium),
      displaySmall: s(t.displaySmall),
      headlineLarge: s(t.headlineLarge),
      headlineMedium: s(t.headlineMedium),
      headlineSmall: s(t.headlineSmall),
      titleLarge: s(t.titleLarge),
      titleMedium: s(t.titleMedium),
      titleSmall: s(t.titleSmall),
      bodyLarge: s(t.bodyLarge)?.copyWith(fontSize: AppConstants.baseFontSize),
      bodyMedium: s(t.bodyMedium),
      bodySmall: s(t.bodySmall),
      labelLarge: s(t.labelLarge),
      labelMedium: s(t.labelMedium),
      labelSmall: s(t.labelSmall),
    );
  }
}
