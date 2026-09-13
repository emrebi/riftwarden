import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/battle/view/battle_screen.dart';
import 'package:riftwarden/features/boot/view/widget_gallery.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';
import 'package:riftwarden/features/level_select/view/level_select_screen.dart';
import 'package:riftwarden/features/main_menu/view/main_menu_screen.dart';
import 'package:riftwarden/features/result/view/result_data.dart';
import 'package:riftwarden/features/result/view/result_screen.dart';
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
                    // Savas ekrani: ilk gercek oynanis dogrulamasi.
                    // Digerleri ikincil; bu yuzden primary varyant.
                    RwButton(
                      label: 'BATTLE (Level 1)', // ui-lint: ignore gecici savas butonu
                      icon: Icons.bolt_rounded,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => BattleScreen(
                              levelId: 1,
                              onBack: () => Navigator.of(context).pop(),
                            ),
                          ),
                        );
                      },
                    ),
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
                    RwButton(
                      label: 'Level Select', // ui-lint: ignore gecici level select butonu
                      icon: Icons.map_rounded,
                      variant: RwButtonVariant.secondary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                LevelSelectScreen(
                              sectors: _sampleSectors,
                              shards: 120,
                              onLevelTap: (int levelId) {},
                              onBack: () => Navigator.of(context).pop(),
                            ),
                          ),
                        );
                      },
                    ),
                    RwButton(
                      label: 'Result (Victory)', // ui-lint: ignore gecici zafer butonu
                      icon: Icons.emoji_events_rounded,
                      variant: RwButtonVariant.secondary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => ResultScreen(
                              data: const BattleResultData(
                                kind: BattleResultKind.victory,
                                levelNumber: 3,
                                shardsEarned: 25,
                                cellsEarned: 3,
                                wavesCleared: 8,
                                totalWaves: 8,
                                canWatchAd: true,
                              ),
                              onPrimary: () => Navigator.of(context).pop(),
                              onWatchAd: _noop,
                              onMainMenu: () => Navigator.of(context).pop(),
                            ),
                          ),
                        );
                      },
                    ),
                    RwButton(
                      label: 'Result (Defeat)', // ui-lint: ignore gecici yenilgi butonu
                      icon: Icons.cancel_rounded,
                      variant: RwButtonVariant.secondary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => ResultScreen(
                              data: const BattleResultData(
                                kind: BattleResultKind.defeat,
                                levelNumber: 3,
                                shardsEarned: 0,
                                cellsEarned: 0,
                                wavesCleared: 6,
                                totalWaves: 8,
                                canWatchAd: true,
                              ),
                              onPrimary: () => Navigator.of(context).pop(),
                              onWatchAd: _noop,
                              onMainMenu: () => Navigator.of(context).pop(),
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

  static const List<SectorData> _sampleSectors = <SectorData>[
    SectorData(
      sectorId: 1,
      name: 'Fractured Edge',
      isLocked: false,
      completedCount: 5,
      levels: <LevelNodeData>[
        LevelNodeData(
          levelId: 1,
          state: LevelNodeState.completed,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 2,
          state: LevelNodeState.completed,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 3,
          state: LevelNodeState.completed,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 4,
          state: LevelNodeState.completed,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 5,
          state: LevelNodeState.completed,
          isBoss: true,
        ),
      ],
    ),
    SectorData(
      sectorId: 2,
      name: 'Aether Chasm',
      isLocked: false,
      completedCount: 2,
      levels: <LevelNodeData>[
        LevelNodeData(
          levelId: 6,
          state: LevelNodeState.completed,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 7,
          state: LevelNodeState.completed,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 8,
          state: LevelNodeState.current,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 9,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 10,
          state: LevelNodeState.locked,
          isBoss: true,
        ),
      ],
    ),
    SectorData(
      sectorId: 3,
      name: 'Rift Convergence',
      isLocked: true,
      completedCount: 0,
      levels: <LevelNodeData>[
        LevelNodeData(
          levelId: 11,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 12,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 13,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 14,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 15,
          state: LevelNodeState.locked,
          isBoss: true,
        ),
      ],
    ),
    SectorData(
      sectorId: 4,
      name: 'Null Sanctum',
      isLocked: true,
      completedCount: 0,
      levels: <LevelNodeData>[
        LevelNodeData(
          levelId: 16,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 17,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 18,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 19,
          state: LevelNodeState.locked,
          isBoss: false,
        ),
        LevelNodeData(
          levelId: 20,
          state: LevelNodeState.locked,
          isBoss: true,
        ),
      ],
    ),
  ];
}

