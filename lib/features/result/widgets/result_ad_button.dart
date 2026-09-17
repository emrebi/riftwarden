import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Odullu reklam butonu.
///
/// Oyuncuya zaferde odulu katlama, yenilgide ise canlanarak devam etme
/// imkani sunar. Birincil eylem butonundan (DEVAM / TEKRAR DENE) net bir
/// sekilde ayrismasi icin acik parsomen govde uzerinde kehribar kaynak
/// rengi ve video oynatma simgesi kullanir (DESIGN §7, §8). Govde
/// `RwMaterialSurface` uzerine kurulur, kandirmaca veya sahte kapatma
/// deseni icermez.
class ResultAdButton extends StatefulWidget {
  const ResultAdButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Buton uzerinde gorunecek acik metin.
  final String label;

  /// Reklam izleme eylemi.
  final VoidCallback? onPressed;

  @override
  State<ResultAdButton> createState() => _ResultAdButtonState();
}

class _ResultAdButtonState extends State<ResultAdButton> {
  /// Ikon glif olcusu. Tek kullanim yeri burasi oldugundan tek noktada
  /// tanimlanir (bkz. `RwButton._iconSize` deseni).
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
    const material = AppMaterial.parchment;
    const accentColor = AppColors.cta;
    final RwSurfaceDepth depth =
        _isEnabled && _isPressed ? RwSurfaceDepth.pressed : RwSurfaceDepth.raised;

    final TextStyle textStyle =
        AppTypography.onMaterial(AppTypography.button, material)
            .copyWith(color: accentColor);

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.play_circle_filled_rounded,
          size: _iconSize,
          color: accentColor,
        ),
        const SizedBox(width: AppSpacing.sm),
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
      height: AppSpacing.minTouchTarget,
      width: double.infinity,
      child: RwMaterialSurface(
        material: material,
        depth: depth,
        isDisabled: !_isEnabled,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.lg,
        ),
        child: Center(child: content),
      ),
    );

    // Basili/serbest gecisi aninda olur (DESIGN §7 "begins immediately"):
    // RwMaterialSurface derinligi dogrudan degisir, ekstra gecis katmani
    // eklenmez.
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
