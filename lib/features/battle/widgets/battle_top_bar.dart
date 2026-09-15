import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';

/// Savas ekraninin ust bilgi seridi.
///
/// Duraklatma butonu, dalga ilerlemesi ve Aether sayacini barindirir.
/// Savas alanini kapatmamak icin ince ve yari seffaf tutulur.
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: startPadding + AppSpacing.md,
        end: endPadding + AppSpacing.md,
        top: topPadding + AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceOverlay,
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceRaised,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RwIconButton(
            icon: Icons.pause_rounded,
            onPressed: onPause,
          ),
          ValueListenableBuilder<WaveProgress>(
            valueListenable: waveProgress,
            builder: (BuildContext context, WaveProgress wave, _) {
              final l10n = AppLocalizations.of(context);
              final isBoss = wave.isBossWave;
              return Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isBoss
                      ? AppColors.surfaceRaised
                      : AppColors.surface.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.pill),
                  ),
                  border: Border.all(
                    color: isBoss
                        ? AppColors.riftMagenta
                        : AppColors.surfaceRaised,
                    width: 1.0,
                  ),
                  boxShadow: isBoss
                      ? AppShadows.glow(
                          AppColors.riftMagenta,
                          blurRadius: 8.0,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (isBoss) ...<Widget>[
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16.0,
                        color: AppColors.riftMagenta,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      l10n.hudWave(wave.current, wave.total),
                      style: AppTypography.titleMedium.copyWith(
                        color: isBoss
                            ? AppColors.riftGlow
                            : AppColors.textPrimary,
                        fontWeight:
                            isBoss ? FontWeight.bold : FontWeight.w600,
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
              return Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.pill),
                  ),
                  border: Border.all(
                    color: AppColors.surfaceRaised,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.bolt_rounded,
                      size: 18.0,
                      color: AppColors.aether,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      aetherValue.toString(),
                      style: AppTypography.numeric.copyWith(
                        color: AppColors.aether,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
