import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Dairesel simge butonu (ayarlar, duraklatma, kapatma vb.).
///
/// Gorsel govde `RwMaterialSurface(shape: RwSurfaceShape.circle)` uzerine
/// kurulur (DESIGN.md §7 "Icon": "Compact stone/dark-neutral or wood-framed
/// control with readable glyph"). Dokunma hedefi her zaman en az
/// [AppSpacing.minTouchTarget] (48 dp) genisligindedir.
class RwIconButton extends StatefulWidget {
  const RwIconButton({
    required this.onPressed,
    super.key,
    this.icon,
    this.rwIcon,
    this.tooltip,
    this.size = AppSpacing.minTouchTarget,
    this.iconSize = 22.0,
    this.material = AppMaterial.stone,
    this.isSelected = false,
    this.isActive = false,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
  }) : assert(
          (icon == null) != (rwIcon == null),
          'icon veya rwIcon\'dan tam olarak biri verilmeli.',
        );

  /// Code-native glif. `rwIcon` ile birlikte kullanilamaz.
  final IconData? icon;

  /// Semantik glif kimligi (`RwIcon`). `icon` ile birlikte kullanilamaz.
  final RwIconId? rwIcon;

  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;

  /// Yuzey malzemesi (DESIGN §7 "stone/dark-neutral or wood-framed").
  /// Varsayilan `stone`; `wood` ve `hud` de desteklenir.
  final AppMaterial material;

  /// Secili durum (DESIGN §7 "selected/emphasized"): `RwMaterialSurface`e
  /// amber halka + marker olarak iletilir.
  final bool isSelected;

  /// Hedefleme/aktif mod isareti (DESIGN §12 "Targeting"). `isSelected`den
  /// kasitli olarak ayri tutulur: secili durum kalici bir secim halkasidir,
  /// `isActive` ise gecici bir mod (orn. Rift Collapse hedefleme) gosterir.
  /// Bu yuzden halka eklemez — yuzey rengi `AppColors.selection` tonuna
  /// lerp edilir ve glif koyu metin rengine gecer, boylece iki durum ayni
  /// anda okunsa bile (secili + aktif) gorsel olarak ayrisirlar.
  final bool isActive;

  /// Dolgu rengini gecersiz kilar (malzemenin varsayilan yuzu yerine).
  final Color? backgroundColor;

  /// Glif rengini gecersiz kilar. Varsayilan `AppMaterials.text(material)`.
  final Color? iconColor;

  /// Verildiginde yuzeyin disina ince ek bir daire kenarligi ekler.
  /// `RwMaterialSurface`in kendi keyline'inin yerine gecmez (malzeme
  /// kimligini bozmamak icin), sadece cagiran taraf ek bir vurgu istedigi
  /// zaman uygulanir.
  final Color? borderColor;

  @override
  State<RwIconButton> createState() => _RwIconButtonState();
}

class _RwIconButtonState extends State<RwIconButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_isEnabled && _isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double actualSize = widget.size < AppSpacing.minTouchTarget
        ? AppSpacing.minTouchTarget
        : widget.size;

    final RwSurfaceDepth depth =
        _isEnabled && _isPressed ? RwSurfaceDepth.pressed : RwSurfaceDepth.raised;

    final Color? faceOverride = widget.backgroundColor ??
        (widget.isActive
            ? Color.lerp(
                AppMaterials.face(widget.material),
                AppColors.selection,
                0.55,
              )
            : null);

    final Color glyphColor = widget.iconColor ??
        (widget.isActive
            ? AppColors.textOnLight
            : AppMaterials.text(widget.material));

    final Widget glyph = widget.rwIcon != null
        ? RwIcon(widget.rwIcon!, size: widget.iconSize, color: glyphColor)
        : Icon(widget.icon, size: widget.iconSize, color: glyphColor);

    Widget surface = SizedBox(
      width: actualSize,
      height: actualSize,
      child: RwMaterialSurface(
        material: widget.material,
        shape: RwSurfaceShape.circle,
        depth: depth,
        isSelected: widget.isSelected,
        isDisabled: !_isEnabled,
        faceColor: faceOverride,
        padding: EdgeInsetsDirectional.zero,
        child: Center(child: glyph),
      ),
    );

    if (widget.borderColor != null) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: widget.borderColor!, width: 1.0),
        ),
        child: surface,
      );
    }

    // Basili/serbest gecisi aninda olur (DESIGN §7 "begins immediately"):
    // RwMaterialSurface derinligi dogrudan degisir, ekstra gecis katmani
    // eklenmez (RwButton'daki UI-10 deseniyle ayni yaklasim).
    Widget button = Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.tooltip,
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

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
