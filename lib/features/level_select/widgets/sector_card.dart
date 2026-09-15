import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';
import 'package:riftwarden/features/level_select/widgets/level_node.dart';
import 'package:riftwarden/features/level_select/widgets/node_connector.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

/// Harita listesindeki tek bir sektor blogu.
///
/// Yatay haritada boyutlar arasi bir bolgeyi temsil eder.
/// Kilitli sektorlerde karartilmis zemin ve kilitli dugumler,
/// acik sektorlerde ise sektor adi, ilerleme ve 5 adet level dugumu gosterir.
class SectorCard extends StatelessWidget {
  const SectorCard({
    required this.sector,
    required this.onLevelTap,
    super.key,
  });

  /// Yatay duzende sektor kartinin sabit genisligi.
  static const double cardWidth = 380.0;

  final SectorData sector;
  final void Function(int levelId) onLevelTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (sector.isLocked) {
      return _buildLockedCard(context, l10n);
    }

    return _buildActiveCard(context, l10n);
  }

  Widget _buildLockedCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: AppBorderRadii.lg,
        border: Border.all(
          color: AppColors.surfaceRaised,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Sektor basligi ve kilit rozeti
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.sectorLabel(sector.sectorId),
                style: AppTypography.label.copyWith(
                  color: AppColors.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised.withValues(alpha: 0.5),
                  borderRadius: AppBorderRadii.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.lock_rounded,
                      size: 14.0,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.levelLocked,
                      style: AppTypography.label.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            sector.name,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textDisabled,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),

          // Dugumler ve baglanti hatti (kilitli)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < sector.levels.length; i++) ...<Widget>[
                if (i > 0)
                  const Expanded(
                    child: NodeConnector(
                      isActive: false,
                    ),
                  ),
                LevelNode(
                  node: sector.levels[i],
                  onTap: null,
                ),
              ],
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context, AppLocalizations l10n) {
    final hasCurrentLevel =
        sector.levels.any((LevelNodeData node) => node.state == LevelNodeState.current);
    final isCompleted = sector.completedCount >= sector.levels.length;
    final progressText = '${sector.completedCount}/${sector.levels.length}';

    final List<BoxShadow> shadows;
    final BoxBorder border;

    if (hasCurrentLevel) {
      shadows = AppShadows.glow(AppColors.aetherCyanDim, blurRadius: 10.0);
      border = Border.all(
        color: AppColors.aetherCyanDim,
        width: 1.5,
      );
    } else if (isCompleted) {
      shadows = AppShadows.panel;
      border = Border.all(
        color: AppColors.coreTeal.withValues(alpha: 0.3),
        width: 1.0,
      );
    } else {
      shadows = AppShadows.panel;
      border = AppBorders.subtle;
    }

    final Color sectorLabelColor;
    if (hasCurrentLevel) {
      sectorLabelColor = AppColors.aetherCyan;
    } else if (isCompleted) {
      sectorLabelColor = AppColors.coreTeal;
    } else {
      sectorLabelColor = AppColors.textSecondary;
    }

    return Container(
      width: cardWidth,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.panel,
        borderRadius: AppBorderRadii.lg,
        border: border,
        boxShadow: shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Sektor basligi ve tamamlanma durumu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.sectorLabel(sector.sectorId),
                style: AppTypography.label.copyWith(
                  color: sectorLabelColor,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isCompleted) ...<Widget>[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14.0,
                      color: AppColors.coreTeal,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    progressText,
                    style: AppTypography.label.copyWith(
                      color: isCompleted
                          ? AppColors.coreTeal
                          : (hasCurrentLevel
                              ? AppColors.aetherCyan
                              : AppColors.textSecondary),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            sector.name,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),

          // Dugumler ve baglanti hatti
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < sector.levels.length; i++) ...<Widget>[
                if (i > 0)
                  Expanded(
                    child: NodeConnector(
                      isActive: sector.levels[i].state != LevelNodeState.locked,
                    ),
                  ),
                LevelNode(
                  node: sector.levels[i],
                  onTap: sector.levels[i].state != LevelNodeState.locked
                      ? () => onLevelTap(sector.levels[i].levelId)
                      : null,
                ),
              ],
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
