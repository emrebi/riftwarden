import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';
import 'package:riftwarden/shared/widgets/rw_ornament.dart';

/// Panel gorsel turleri (DESIGN §8 "PANEL SYSTEM").
enum RwPanelVariant {
  /// Yeniden kullanilabilir icerik grubu.
  standard,

  /// Ekran seviyesi icerik bolgesi: ayni anatomi, daha fazla dolgu.
  large,

  /// En guclu derinlik, belirgin baslik alani.
  modal,

  /// Ipucu/etiket/gecici durum icin kompakt tag/plaket.
  smallInfo,
}

/// Yukseltilmis panel yuzeyi.
///
/// Moduler pencereler, detay panelleri ve gruplanmis icerikler icin
/// kullanilir. Govde `RwMaterialSurface` uzerine kurulur (DESIGN §8):
/// dolgu + kalin dis hat (keyline) + ic derz (seam), neon gradyan/glow
/// yoktur.
class RwPanel extends StatefulWidget {
  const RwPanel({
    required this.child,
    super.key,
    this.title,
    this.trailing,
    this.padding,
    this.onTap,
    this.variant = RwPanelVariant.standard,
    this.material = AppMaterial.parchment,
    this.showOrnaments = true,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// Panel gorsel turu (DESIGN §8). Varsayilan `standard`.
  final RwPanelVariant variant;

  /// Panel yuzeyinin malzemesi (parchment/wood/stone/hud). Varsayilan
  /// `parchment` (okuma agirlikli icerik).
  final AppMaterial material;

  /// Kompakt/yogun yerlesimde susleme kapatilabilir.
  final bool showOrnaments;

  @override
  State<RwPanel> createState() => _RwPanelState();
}

class _RwPanelState extends State<RwPanel> {
  bool _isPressed = false;

  bool get _isTappable => widget.onTap != null;

  void _setPressed(bool value) {
    if (_isTappable && _isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  /// Varyanta gore govde dolgusu. `padding` verilirse bu deger yerine gecer.
  EdgeInsetsGeometry get _variantPadding => switch (widget.variant) {
        RwPanelVariant.standard => const EdgeInsetsDirectional.all(AppSpacing.lg),
        RwPanelVariant.large => const EdgeInsetsDirectional.all(AppSpacing.xl),
        RwPanelVariant.modal => const EdgeInsetsDirectional.all(AppSpacing.lg),
        RwPanelVariant.smallInfo => const EdgeInsetsDirectional.all(AppSpacing.sm),
      };

  RwSurfaceDepth get _restingDepth =>
      widget.variant == RwPanelVariant.smallInfo ? RwSurfaceDepth.flat : RwSurfaceDepth.raised;

  TextStyle _titleStyle() {
    final TextStyle base = widget.variant == RwPanelVariant.smallInfo
        ? AppTypography.smallLabel
        : AppTypography.sectionTitle;
    return AppTypography.onMaterial(base, widget.material);
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry effectivePadding = widget.padding ?? _variantPadding;
    final bool hasHeader = widget.title != null || widget.trailing != null;
    final RwSurfaceDepth depth =
        _isTappable && _isPressed ? RwSurfaceDepth.pressed : _restingDepth;

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (hasHeader) ...<Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.md,
              end: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: widget.variant == RwPanelVariant.modal ? AppSpacing.sm : AppSpacing.xs,
            ),
            child: Row(
              children: <Widget>[
                if (widget.title != null)
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: _titleStyle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ?widget.trailing,
              ],
            ),
          ),
          if (widget.variant == RwPanelVariant.modal)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppMaterials.edge(widget.material), width: 1.0),
                  ),
                ),
                child: const SizedBox(height: 1.0, width: double.infinity),
              ),
            ),
        ],
        Padding(
          padding: effectivePadding,
          child: widget.child,
        ),
      ],
    );

    final Widget decorated = DefaultTextStyle.merge(
      style: TextStyle(color: AppMaterials.text(widget.material)),
      child: IconTheme.merge(
        data: IconThemeData(color: AppMaterials.text(widget.material)),
        child: RwMaterialSurface(
          material: widget.material,
          depth: depth,
          padding: EdgeInsetsDirectional.zero,
          decoration: widget.showOrnaments &&
                  widget.variant != RwPanelVariant.smallInfo
              ? RwSurfaceOrnaments(material: widget.material)
              : null,
          child: content,
        ),
      ),
    );

    if (!_isTappable) {
      return decorated;
    }

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: decorated,
      ),
    );
  }
}
