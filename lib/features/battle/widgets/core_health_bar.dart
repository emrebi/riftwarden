import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';
import 'package:riftwarden/shared/widgets/rw_progress_bar.dart';

/// Kalenin canini gosteren yuzen kompakt panel bileseni.
///
/// Ust seridin altinda, sol tarafta kalenin uzerinde konumlanir. Can %25
/// altina indiginde uyari ikonu belirir ve panel kenarinda yavas bir nabiz
/// oynar; durum sadece renkle degil ikon+nabiz ile de ayrisir (DESIGN §24).
class CoreHealthBar extends StatefulWidget {
  const CoreHealthBar({
    required this.coreHpRatio,
    required this.coreHp,
    super.key,
  });

  /// 0..1 arasinda Core can orani sinyali.
  final ValueListenable<double> coreHpRatio;

  /// Mutlak Core can degeri sinyali.
  final ValueListenable<int> coreHp;

  @override
  State<CoreHealthBar> createState() => _CoreHealthBarState();
}

class _CoreHealthBarState extends State<CoreHealthBar>
    with SingleTickerProviderStateMixin {
  static const double _iconSize = 14.0;
  static const double _lowHpThreshold = 0.25;
  static const double _pulseMinScale = 0.85;
  static const double _pulseMaxScale = 1.0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Dusuk canda uyari ikonu icin hafif nabiz efekti
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDuration.slow,
    );
    _pulseAnimation = Tween<double>(
      begin: _pulseMinScale,
      end: _pulseMaxScale,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _syncPulse(bool isLow) {
    if (isLow) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<double>(
      valueListenable: widget.coreHpRatio,
      builder: (BuildContext context, double ratio, _) {
        final isLow = ratio < _lowHpThreshold;
        _syncPulse(isLow);
        final textColor = isLow
            ? AppColors.danger
            : AppMaterials.text(AppMaterial.hud);

        return RwMaterialSurface(
          material: AppMaterial.hud,
          depth: RwSurfaceDepth.flat,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.shield_rounded,
                size: _iconSize,
                color: textColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.hudCastle,
                style: AppTypography.onMaterial(
                  AppTypography.smallLabel,
                  AppMaterial.hud,
                ).copyWith(color: textColor),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: RwProgressBar(
                  value: ratio,
                  color: textColor,
                  showDamageTrail: true,
                  height: AppSpacing.xs,
                  variant: RwProgressVariant.health,
                  trackMaterial: AppMaterial.hud,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              ValueListenableBuilder<int>(
                valueListenable: widget.coreHp,
                builder: (BuildContext context, int hpValue, _) {
                  return Text(
                    hpValue.toString(),
                    style: AppTypography.onMaterial(
                      AppTypography.numeric,
                      AppMaterial.hud,
                    ).copyWith(color: textColor),
                  );
                },
              ),
              if (isLow) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: _iconSize,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
