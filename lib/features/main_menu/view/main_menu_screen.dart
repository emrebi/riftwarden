import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_actions_row.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_logo.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_play_button.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_progress_panel.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';

/// Ana menu sayfasi.
///
/// Yatay duzende oyun acilisinda ilk izlenimi veren merkez ekran.
/// Sol yarimda boyut kimligi (logo, alt baslik) ve ilerleme paneli,
/// sag yarimda ise para gostergeleri, baskin PLAY butonu ve ikincil eylemler
/// yer alir.
///
/// Yonlendirme ve veri baglantisi disaridan verilir; ekran state tutmaz,
/// yalnizca callback tetikler.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    required this.sectorNumber,
    required this.levelNumber,
    required this.sectorProgress,
    required this.shards,
    required this.cells,
    required this.onPlay,
    required this.onStore,
    required this.onUpgrades,
    required this.onSettings,
    super.key,
  });

  final int sectorNumber;
  final int levelNumber;
  final double sectorProgress;
  final int shards;
  final int cells;
  final VoidCallback onPlay;
  final VoidCallback onStore;
  final VoidCallback onUpgrades;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final notchStart = isRtl ? viewPadding.right : viewPadding.left;
    final notchEnd = isRtl ? viewPadding.left : viewPadding.right;

    return Scaffold(
      backgroundColor: AppColors.voidDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: SafeArea(
          left: false,
          right: false,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.screenGutter + notchStart,
              end: AppSpacing.screenGutter + notchEnd,
              top: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Sol yarim: logo, alt baslik (menuSubtitle) ve sektor/level ilerleme paneli.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Spacer(),
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MenuLogo(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      MenuProgressPanel(
                        sectorNumber: sectorNumber,
                        levelNumber: levelNumber,
                        sectorProgress: sectorProgress,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Sag yarim: en baskin oge PLAY butonu; altinda STORE, UPGRADES ve SETTINGS eylemleri.
                // Sag ust: Shard ve Cell para gostergeleri.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Sag ust: Shard ve Cell para gostergeleri
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          RwCurrencyChip(
                            currency: RwCurrency.shard,
                            amount: shards,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          RwCurrencyChip(
                            currency: RwCurrency.cell,
                            amount: cells,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Ana eylem: PLAY butonu (baskin, nabiz animasyonlu)
                      MenuPlayButton(
                        onPressed: onPlay,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Ikincil eylemler: STORE, UPGRADES, SETTINGS
                      MenuActionsRow(
                        onStore: onStore,
                        onUpgrades: onUpgrades,
                        onSettings: onSettings,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
