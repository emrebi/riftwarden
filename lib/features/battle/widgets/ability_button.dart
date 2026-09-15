import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';

/// Savas ekraninda Rift Collapse aktif yetenek butonu.
///
/// Yetenek hazir degilken dairesel dolgu ile bekleme suresini (cooldown) gosterir.
/// Hazirken dokunuldugunda nisan alma modunu acar veya kapatir.
class AbilityButton extends StatelessWidget {
  const AbilityButton({
    required this.ability,
    required this.onToggleAiming,
    super.key,
    this.height = 52.0,
  });

  /// Yetenek durumu sinyali (cooldown, hazirlik, nisan durumu).
  final ValueListenable<AbilityState> ability;

  /// Nisan modunu acip kapatan eylem.
  final VoidCallback onToggleAiming;

  /// Buton yuksekligi.
  final double height;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AbilityState>(
      valueListenable: ability,
      builder: (BuildContext context, AbilityState state, _) {
        final isReady = state.isReady;
        final isAiming = state.isAiming;

        final Color borderColor = isAiming
            ? AppColors.warning
            : isReady
                ? AppColors.aetherCyan
                : AppColors.surfaceRaised;

        final Color iconColor = isAiming
            ? AppColors.warning
            : isReady
                ? AppColors.aetherCyan
                : AppColors.textDisabled;

        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: height,
          ),
          child: GestureDetector(
            onTap: isReady ? onToggleAiming : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: AppDuration.fast,
              width: height,
              height: height,
              padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: isAiming
                    ? AppColors.surfaceRaised
                    : isReady
                        ? AppColors.surfaceRaised
                        : AppColors.surface.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.md),
                ),
                border: Border.all(
                  color: borderColor,
                  width: isAiming ? 2.0 : 1.0,
                ),
                boxShadow: isAiming
                    ? AppShadows.glow(AppColors.warning, blurRadius: 10.0)
                    : isReady
                        ? AppShadows.glow(
                            AppColors.aetherCyan,
                            blurRadius: 8.0,
                          )
                        : null,
              ),
              child: Center(
                child: isReady
                    ? Icon(
                        isAiming
                            ? Icons.crisis_alert_rounded
                            : Icons.flare_rounded,
                        size: 24.0,
                        color: iconColor,
                      )
                    : SizedBox(
                        width: 28.0,
                        height: 28.0,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              value: state.cooldownRatio,
                              strokeWidth: 2.5,
                              backgroundColor: AppColors.surface,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.aetherCyanDim,
                              ),
                            ),
                            Icon(
                              Icons.flare_rounded,
                              size: 14.0,
                              color: iconColor,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
