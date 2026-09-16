import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Uygulama temasi.
///
/// Zemin acik (gokyuzu `background`); paneller parchment, HUD gibi baglamlar koyu-notr
/// malzeme kullanir. Sistem acik/koyu tercihi takip EDILMEZ — tema
/// sabittir. `textTheme` burada LEGACY ekranlarin acik metin rengine
/// (`AppColors.textPrimary`) guvenmesi nedeniyle KORUNUR; ekranlar kendi
/// zeminlerini kendi boyar, rol bazli metin renklendirmesi ekran
/// gorevlerine kadar bu sekilde kalir.
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
      brightness: Brightness.light,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.cta,
        onPrimary: AppColors.textOnLight,
        secondary: AppColors.aether,
        onSecondary: AppColors.textOnLight,
        tertiary: AppColors.rift,
        onTertiary: AppColors.textOnDark,
        surface: AppColors.parchmentBase,
        onSurface: AppColors.textOnLight,
        onSurfaceVariant: AppColors.textOnLightSecondary,
        outline: AppColors.outlineInk,
        outlineVariant: AppColors.parchmentEdge,
        error: AppColors.danger,
        onError: AppColors.textOnDark,
        shadow: AppColors.shadowWarm,
      ),
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      dialogTheme: DialogThemeData(
        backgroundColor: AppMaterials.face(AppMaterial.parchment),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: AppMaterials.keyline(AppMaterial.parchment),
            width: AppMaterials.keylineWidth,
          ),
        ),
        titleTextStyle: AppTypography.onMaterial(
          AppTypography.sectionTitle,
          AppMaterial.parchment,
        ),
        contentTextStyle: AppTypography.onMaterial(
          AppTypography.bodyMedium,
          AppMaterial.parchment,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppMaterials.face(AppMaterial.hud),
        contentTextStyle: AppTypography.onMaterial(
          AppTypography.bodyMedium,
          AppMaterial.hud,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppMaterials.face(AppMaterial.hud),
          borderRadius: AppBorderRadii.sm,
          border: Border.all(
            color: AppMaterials.keyline(AppMaterial.hud),
            width: AppMaterials.keylineWidth,
          ),
        ),
        textStyle: AppTypography.onMaterial(
          AppTypography.smallLabel,
          AppMaterial.hud,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.health,
        linearTrackColor: AppColors.hudEdge,
        circularTrackColor: AppColors.hudEdge,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.outlineInk,
        selectionColor: AppColors.selection.withValues(alpha: 0.4),
        selectionHandleColor: AppColors.selection,
      ),
    );
  }
}
