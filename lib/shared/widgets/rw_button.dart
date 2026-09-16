import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Buton gorsel turleri.
enum RwButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}

/// Standart oyun butonu.
///
/// Gorsel govde `RwMaterialSurface` uzerine kurulur (DESIGN.md §7): dolgu +
/// kalin dis hat + derinlik durumu. Dokunma hedefi en az
/// [AppSpacing.minTouchTarget] (48 dp) yuksekligindedir. Basildiginda yuzey
/// `pressed` derinligine gecer; veri veya saglayici baglantisi yoktur.
class RwButton extends StatefulWidget {
  const RwButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = RwButtonVariant.primary,
    this.icon,
    this.isExpanded = false,
    this.height = AppSpacing.minTouchTarget,
    this.isSelected = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final RwButtonVariant variant;
  final IconData? icon;
  final bool isExpanded;
  final double height;

  /// Secili durum (DESIGN §7 "selected/emphasized"): `RwMaterialSurface`e
  /// amber kenar + marker olarak iletilir.
  final bool isSelected;

  @override
  State<RwButton> createState() => _RwButtonState();
}

class _RwButtonState extends State<RwButton> {
  /// Ikon glif olcusu. `AppSpacing`'te ayri bir ikon token'i yok; tek
  /// kullanim yeri burasi oldugundan tek noktada tanimlanir.
  static const double _iconSize = 20.0;

  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_isEnabled && _isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double effectiveHeight = widget.height < AppSpacing.minTouchTarget
        ? AppSpacing.minTouchTarget
        : widget.height;

    // Malzeme + renk secimi (DESIGN §7).
    final AppMaterial material;
    final Color? faceColor;
    final Color textColor;
    final RwSurfaceDepth restingDepth;

    switch (widget.variant) {
      case RwButtonVariant.primary:
        // Kehribar CTA tahta: dominant tek eylem.
        material = AppMaterial.wood;
        faceColor = AppColors.cta;
        textColor = AppColors.textOnLight;
        restingDepth = RwSurfaceDepth.raised;
      case RwButtonVariant.secondary:
        // Parchment yuz: navigasyon/destekleyici eylemler.
        material = AppMaterial.parchment;
        faceColor = null;
        textColor = AppMaterials.text(material);
        restingDepth = RwSurfaceDepth.raised;
      case RwButtonVariant.ghost:
        // Sessiz timber: dolgu yok, sadece kenar/derz + metin gorunur.
        material = AppMaterial.wood;
        faceColor = Colors.transparent;
        textColor = AppMaterials.text(material);
        restingDepth = RwSurfaceDepth.flat;
      case RwButtonVariant.danger:
        // Kirmizi kil: sadece yikici onay.
        material = AppMaterial.stone;
        faceColor = AppColors.danger;
        textColor = AppColors.textOnDark;
        restingDepth = RwSurfaceDepth.raised;
    }

    final RwSurfaceDepth depth =
        _isEnabled && _isPressed ? RwSurfaceDepth.pressed : restingDepth;

    final TextStyle textStyle =
        AppTypography.button.copyWith(color: textColor);

    final Widget content = Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          Icon(
            widget.icon,
            size: _iconSize,
            color: textColor,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: textStyle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final Widget surface = SizedBox(
      height: effectiveHeight,
      width: widget.isExpanded ? double.infinity : null,
      child: RwMaterialSurface(
        material: material,
        faceColor: faceColor,
        depth: depth,
        isSelected: widget.isSelected,
        isDisabled: !_isEnabled,
        // Etiketten deterministik tohum: ayni etiket her build'de ayni
        // duzensiz siluete sahip olur (RwMaterialSurface sozlesmesi).
        seed: widget.label.hashCode,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.xl,
        ),
        child: Center(child: content),
      ),
    );

    // Basili/serbest gecisi aninda olur (DESIGN §7 "begins immediately"):
    // RwMaterialSurface derinligi dogrudan degisir, ekstra capraz gecis
    // katmani (cift golge/gereksiz rebuild) eklenmez.
    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: surface,
      ),
    );
  }
}
