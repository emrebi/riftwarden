import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_actions_row.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_logo.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_play_button.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_progress_panel.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_screen_scaffold.dart';

/// Ana menu sayfasi.
///
/// Oyun acilisinda ilk izlenimi veren merkez ekran. Boyutlar arasi
/// atmosferi ve baskin PLAY eylemini dengeler.
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
    return RwScreenScaffold(
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Ust serit: Para gostergeleri (Aether Shard ve Cell)
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

          // Logo alani (ekranin gorsel agirlik merkezi)
          const Spacer(flex: 2),
          const MenuLogo(),
          const Spacer(flex: 3),

          // Ilerleme gostergesi (Sektor ve Seviye)
          MenuProgressPanel(
            sectorNumber: sectorNumber,
            levelNumber: levelNumber,
            sectorProgress: sectorProgress,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Ana eylem: PLAY butonu (hafif nabiz animasyonlu, buyuk, baskin)
          MenuPlayButton(
            onPressed: onPlay,
          ),
          const SizedBox(height: AppSpacing.md),

          // Ikincil eylemler: Magaza, Gelistirmeler ve Ayarlar
          MenuActionsRow(
            onStore: onStore,
            onUpgrades: onUpgrades,
            onSettings: onSettings,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
