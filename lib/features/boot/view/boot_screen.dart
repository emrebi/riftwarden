import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

/// Acilis ekrani.
///
/// GECICI ISKELET. Adim 21'de Gemini tasarimiyla degistirilecek; buradaki
/// amac yalnizca iskeletin ayakta oldugunu ve l10n/tema zincirinin
/// calistigini gostermek.
class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.1,
            colors: <Color>[
              AppColors.surface,
              AppColors.voidBase,
              AppColors.voidDeep,
            ],
            stops: <double>[0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.aetherCyan,
                    shadows: const <Shadow>[
                      Shadow(color: AppColors.aetherCyanDim, blurRadius: 24),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.commonLoading,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
