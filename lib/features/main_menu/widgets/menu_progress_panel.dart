import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_progress_bar.dart';

/// Ana menu sektor ve seviye ilerleme paneli.
///
/// Mevcut bolgeyi ve ilerleme yuzdesini gosterir.
class MenuProgressPanel extends StatelessWidget {
  const MenuProgressPanel({
    required this.sectorNumber,
    required this.levelNumber,
    required this.sectorProgress,
    super.key,
  });

  final int sectorNumber;
  final int levelNumber;
  final double sectorProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: AppBorderRadii.lg,
        border: AppBorders.subtle,
        boxShadow: AppShadows.panel,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                l10n.sectorLabel(sectorNumber),
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                margin: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                width: AppSpacing.xs,
                height: AppSpacing.xs,
                decoration: const BoxDecoration(
                  color: AppColors.textDisabled,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                l10n.levelLabel(levelNumber),
                style: AppTypography.label.copyWith(
                  color: AppColors.aetherCyan,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RwProgressBar(
            value: sectorProgress,
            color: AppColors.aetherCyan,
            backgroundColor: AppColors.surfaceRaised,
          ),
        ],
      ),
    );
  }
}
