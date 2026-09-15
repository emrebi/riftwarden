import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_progress_bar.dart';

/// Kalenin canini gosteren kompakt bar bileseni.
///
/// Ust seridin altinda, sol tarafta kalenin uzerinde konumlanir.
/// Can %25 altina indiginde tehlike rengine doner ve hafif nabiz uygular.
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
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Dusuk canda uyari icin hafif nabiz efekti
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDuration.slow,
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
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
        final isLow = ratio < 0.25;
        _syncPulse(isLow);
        final barColor = isLow ? AppColors.danger : AppColors.coreTeal;

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: isLow ? _pulseAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOverlay,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.md),
                  ),
                  border: Border.all(
                    color: isLow
                        ? AppColors.danger.withValues(alpha: 0.8)
                        : AppColors.surfaceRaised,
                    width: 1.0,
                  ),
                  boxShadow: isLow
                      ? AppShadows.glow(
                          AppColors.danger,
                          blurRadius: 10.0,
                        )
                      : null,
                ),
                child: child,
              ),
            );
          },
          child: Row(
            children: <Widget>[
              Icon(
                Icons.shield_rounded,
                size: 14.0,
                color: isLow ? AppColors.danger : AppColors.coreTeal,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.hudCastle,
                style: AppTypography.label.copyWith(
                  color: isLow ? AppColors.danger : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: RwProgressBar(
                  value: ratio,
                  color: barColor,
                  showDamageTrail: true,
                  height: AppSpacing.xs,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              ValueListenableBuilder<int>(
                valueListenable: widget.coreHp,
                builder: (BuildContext context, int hpValue, _) {
                  return Text(
                    hpValue.toString(),
                    style: AppTypography.numeric.copyWith(
                      color: isLow
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
