import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Tum sayfalarin ortak tabani.
///
/// Arka plan zemin rengi (`AppColors.background`) SafeArea disinda
/// (ekranin tumune) yayilir. [background] verilirse zemin renginin ustune
/// tam ekran yerlesir (ileride `RwArt(group: scenes, ...)`). Icerik, baslik
/// ve butonlar guvenli alanda (SafeArea) tutulur.
class RwScreenScaffold extends StatelessWidget {
  const RwScreenScaffold({
    required this.child,
    super.key,
    this.title,
    this.onBack,
    this.trailing,
    this.contentPadding,
    this.bottomBar,
    this.background,
  });

  final Widget child;
  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? bottomBar;

  /// Tam ekran arka plan katmani (SafeArea disinda), zemin renginin
  /// ustune yerlesir. `null` ise sadece zemin rengi gorunur.
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || onBack != null || trailing != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const ColoredBox(color: AppColors.background),
          if (background != null) Positioned.fill(child: background!),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (hasHeader) _buildHeader(context),
                Expanded(
                  child: Padding(
                    padding: contentPadding ??
                        const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.screenGutter,
                        ),
                    child: child,
                  ),
                ),
                ?bottomBar,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.xs,
      ),
      child: RwMaterialSurface(
        material: AppMaterial.wood,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            if (onBack != null)
              RwIconButton(
                rwIcon: RwIconId.back,
                material: AppMaterial.stone,
                onPressed: onBack,
              )
            else
              const SizedBox(width: AppSpacing.minTouchTarget),
            Expanded(
              child: title != null
                  ? Text(
                      title!,
                      style: AppTypography.onMaterial(
                        AppTypography.screenTitle,
                        AppMaterial.wood,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
            ),
            if (trailing != null)
              trailing!
            else
              const SizedBox(width: AppSpacing.minTouchTarget),
          ],
        ),
      ),
    );
  }
}
