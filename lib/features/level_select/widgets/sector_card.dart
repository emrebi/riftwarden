import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';
import 'package:riftwarden/features/level_select/widgets/level_node.dart';
import 'package:riftwarden/features/level_select/widgets/node_connector.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Harita listesindeki tek bir sektor blogu.
///
/// Yatay yolculuk haritasinda bir boyutu temsil eden parsomen levha
/// (DESIGN §8, §3). Govde `RwMaterialSurface` uzerine kurulur: dolgu + kalin
/// dis hat, neon gradyan/glow yoktur. Kilitli sektorlerde yuzey pasif
/// (soluk + duz golge) davranir, siradaki seviyeyi barindiran sektorde
/// secim halkasi belirir.
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
    final bool isLocked = sector.isLocked;
    final bool hasCurrentLevel = !isLocked &&
        sector.levels.any((LevelNodeData node) => node.state == LevelNodeState.current);
    final bool isCompleted = !isLocked && sector.completedCount >= sector.levels.length;
    final String progressText = '${sector.completedCount}/${sector.levels.length}';

    final Color accentColor;
    if (isLocked) {
      accentColor = AppColors.textOnLightDisabled;
    } else if (hasCurrentLevel) {
      accentColor = AppColors.cta;
    } else if (isCompleted) {
      accentColor = AppColors.success;
    } else {
      accentColor = AppColors.textOnLightSecondary;
    }

    return SizedBox(
      width: cardWidth,
      child: RwMaterialSurface(
        material: AppMaterial.parchment,
        isDisabled: isLocked,
        isSelected: hasCurrentLevel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Sektor basligi ve durum rozeti (kilit veya ilerleme).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.sectorLabel(sector.sectorId),
                  style: AppTypography.smallLabel.copyWith(
                    color: accentColor,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isLocked)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RwIcon(RwIconId.lock, size: 14.0, color: accentColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.levelLocked,
                        style: AppTypography.smallLabel.copyWith(color: accentColor),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (isCompleted) ...<Widget>[
                        RwIcon(RwIconId.check, size: 14.0, color: accentColor),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        progressText,
                        style: AppTypography.smallLabel.copyWith(
                          color: accentColor,
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
              style: AppTypography.onMaterial(
                AppTypography.titleMedium,
                AppMaterial.parchment,
              ).copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                        isActive: !isLocked &&
                            sector.levels[i].state != LevelNodeState.locked,
                      ),
                    ),
                  LevelNode(
                    node: sector.levels[i],
                    onTap: !isLocked && sector.levels[i].state != LevelNodeState.locked
                        ? () => onLevelTap(sector.levels[i].levelId)
                        : null,
                  ),
                ],
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
