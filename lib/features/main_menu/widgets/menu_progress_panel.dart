import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';
import 'package:riftwarden/shared/widgets/rw_progress_bar.dart';

/// Ana menu sektor ve seviye ilerleme paneli.
///
/// Kaleye monte edilmis ahsap bir tabela gibi okunsun diye MenuLogo ile
/// ayni malzeme govdesini (`RwMaterialSurface` wood) paylasir (DESIGN §15
/// "mounted to architecture"). Mevcut bolgeyi ve ilerleme yuzdesini gosterir.
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

    return RwMaterialSurface(
      material: AppMaterial.wood,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                l10n.sectorLabel(sectorNumber),
                style: AppTypography.onMaterialSecondary(
                  AppTypography.smallLabel,
                  AppMaterial.wood,
                ),
              ),
              Container(
                margin: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                width: AppSpacing.xs,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: AppMaterials.textSecondary(AppMaterial.wood),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                l10n.levelLabel(levelNumber),
                style: AppTypography.onMaterial(
                  AppTypography.smallLabel,
                  AppMaterial.wood,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RwProgressBar(
            value: sectorProgress,
            color: AppColors.cta,
          ),
        ],
      ),
    );
  }
}
