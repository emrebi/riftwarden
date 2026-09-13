import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/boot/view/widget_gallery.dart';
import 'package:riftwarden/features/main_menu/view/main_menu_screen.dart';
import 'package:riftwarden/features/settings/view/settings_screen.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';

/// Acilis ekrani.
///
/// GECICI ISKELET. Adim 21'de Gemini tasarimiyla degistirilecek; buradaki
/// amac yalnizca iskeletin ayakta oldugunu ve l10n/tema zincirinin
/// calistigini gostermek.
class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  static void _noop() {}

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
                const SizedBox(height: AppSpacing.xxl),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    RwButton(
                      label: 'UI Gallery', // ui-lint: ignore gecici galeri butonu
                      icon: Icons.palette_rounded,
                      variant: RwButtonVariant.secondary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const WidgetGallery(),
                          ),
                        );
                      },
                    ),
                    RwButton(
                      label: 'Main Menu', // ui-lint: ignore gecici menu butonu
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const MainMenuScreen(
                              sectorNumber: 1,
                              levelNumber: 3,
                              sectorProgress: 0.45,
                              shards: 120,
                              cells: 5,
                              onPlay: _noop,
                              onStore: _noop,
                              onUpgrades: _noop,
                              onSettings: _noop,
                            ),
                          ),
                        );
                      },
                    ),
                    RwButton(
                      label: 'Settings', // ui-lint: ignore gecici ayarlar butonu
                      icon: Icons.settings_rounded,
                      variant: RwButtonVariant.secondary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => SettingsScreen(
                              soundEnabled: true,
                              musicEnabled: true,
                              hapticsEnabled: false,
                              currentLanguageLabel: 'Turkce',
                              versionLabel: 'v1.0.0',
                              onSoundChanged: (bool value) {},
                              onMusicChanged: (bool value) {},
                              onHapticsChanged: (bool value) {},
                              onLanguageTap: _noop,
                              onRestorePurchases: _noop,
                              onPrivacyTap: _noop,
                              onBack: () => Navigator.of(context).pop(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

