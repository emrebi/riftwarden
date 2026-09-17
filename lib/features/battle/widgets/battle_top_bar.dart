import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';
import 'package:riftwarden/shared/widgets/rw_segmented_progress.dart';

/// Savas ekraninin ust bilgi seridi.
///
/// Duraklatma butonu, dalga plaketi ve Aether sayacini barindirir.
/// Savas alanini kapatmamak icin ince tutulur (DESIGN §10 "Wave: compact
/// top-center parchment/wood plaque with current/total and simple
/// segmented progress").
class BattleTopBar extends StatelessWidget {
  const BattleTopBar({
    required this.waveProgress,
    required this.aether,
    required this.onPause,
    required this.topPadding,
    this.startPadding = 0.0,
    this.endPadding = 0.0,
    super.key,
  });

  /// Dalga ilerleme durumu sinyali.
  final ValueListenable<WaveProgress> waveProgress;

  /// Oyuncunun guncel Aether bakiyesi sinyali.
  final ValueListenable<int> aether;

  /// Duraklatma butonuna basildiginda tetiklenen eylem.
  final VoidCallback onPause;

  /// Centik guvenli alan ust payi.
  final double topPadding;

  /// Yatay guvenli alan baslangic payi.
  final double startPadding;

  /// Yatay guvenli alan bitis payi.
  final double endPadding;

  /// Dalga plaketindeki segment gostergesinin sabit genisligi. Tek kullanim
  /// yeri burasi oldugundan dosya icinde tek noktada tanimlanir.
  static const double _progressWidth = 72.0;
  static const double _progressHeight = 6.0;
  static const double _bossIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: startPadding + AppSpacing.md,
        end: endPadding + AppSpacing.md,
        top: topPadding + AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RwIconButton(
            icon: Icons.pause_rounded,
            onPressed: onPause,
            tooltip: l10n.battlePauseTitle,
          ),
          ValueListenableBuilder<WaveProgress>(
            valueListenable: waveProgress,
            builder: (BuildContext context, WaveProgress wave, _) {
              final bool isBoss = wave.isBossWave;
              final double ratio =
                  wave.total > 0 ? wave.current / wave.total : 0.0;
              return RwMaterialSurface(
                material: AppMaterial.wood,
                shape: RwSurfaceShape.pill,
                depth: RwSurfaceDepth.flat,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (isBoss) ...<Widget>[
                      Icon(
                        Icons.warning_amber_rounded,
                        size: _bossIconSize,
                        color: AppMaterials.text(AppMaterial.wood),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      l10n.hudWave(wave.current, wave.total),
                      style: AppTypography.onMaterial(
                        AppTypography.titleMedium,
                        AppMaterial.wood,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: _progressWidth,
                      child: RwSegmentedProgress(
                        segments: wave.total,
                        value: ratio,
                        currentSegment:
                            wave.current > 0 ? wave.current - 1 : null,
                        trackMaterial: AppMaterial.wood,
                        height: _progressHeight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: aether,
            builder: (BuildContext context, int aetherValue, _) {
              return RwCurrencyChip(
                currency: RwCurrency.aether,
                amount: aetherValue,
                material: AppMaterial.hud,
              );
            },
          ),
        ],
      ),
    );
  }
}
