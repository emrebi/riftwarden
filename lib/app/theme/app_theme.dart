import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Uygulama temasi.
///
/// Oyun tek temalidir (koyu). Sistem acik/koyu tercihi takip EDILMEZ:
/// savas alani her zaman koyu zeminde okunur ve arayuzun oyunla ayni
/// atmosferde kalmasi gerekir.
abstract final class AppTheme {
  static ThemeData build(Locale locale) {
    final fontFamily = AppFonts.bodyFamilyFor(locale);

    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      labelSmall: AppTypography.label,
    ).apply(fontFamily: fontFamily);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.voidBase,
      canvasColor: AppColors.voidBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.aetherCyan,
        onPrimary: AppColors.voidDeep,
        secondary: AppColors.riftViolet,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}
