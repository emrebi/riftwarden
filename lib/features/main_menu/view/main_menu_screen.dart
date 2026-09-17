import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_actions_row.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_logo.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_play_button.dart';
import 'package:riftwarden/features/main_menu/widgets/menu_progress_panel.dart';

/// Ana menu sayfasi.
///
/// Yatay duzende oyun acilisinda ilk izlenimi veren merkez ekran (DESIGN
/// §15). Sol yarimda boyut kimligi (tabela benzeri logo bandi) ve
/// ilerleme paneli, sag yarimda ise en baskin oge olan PLAY tahtasi ve
/// altinda bagli tek ikincil akis (Ayarlar) yer alir. Magaza, Kalici
/// Gelistirmeler ve Shard/Cell cuzdan gostergeleri backend'i olmadigi
/// icin gizlidir (AQ-3).
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

  /// AQ-3: backend akisi yok, gizli; parametre uyumluluk icin korunur.
  final int shards;

  /// AQ-3: backend akisi yok, gizli; parametre uyumluluk icin korunur.
  final int cells;

  final VoidCallback onPlay;

  /// AQ-3: backend akisi yok, gizli; parametre uyumluluk icin korunur.
  final VoidCallback onStore;

  /// AQ-3: backend akisi yok, gizli; parametre uyumluluk icin korunur.
  final VoidCallback onUpgrades;

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final notchStart = isRtl ? viewPadding.right : viewPadding.left;
    final notchEnd = isRtl ? viewPadding.left : viewPadding.right;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Zemin rengi SafeArea disinda tam ekrana yayilir; dunya sahnesi
          // (fortress/rift illustrasyonu) ileride RwArt(group: scenes, ...)
          // ile bu katmana eklenir (ARTINT-09).
          const ColoredBox(color: AppColors.background),
          SafeArea(
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
                  // Sol yarim: logo tabelasi ve sektor/level ilerleme paneli.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Spacer(),
                        const MenuLogo(),
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
                  // Sag yarim: en baskin oge PLAY tahtasi; altinda tek bagli
                  // ikincil akis olan Ayarlar dugmesi.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Spacer(),
                        MenuPlayButton(
                          onPressed: onPlay,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        MenuActionsRow(
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
        ],
      ),
    );
  }
}
