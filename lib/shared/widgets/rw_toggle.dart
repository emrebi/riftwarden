import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Yatay pill acma/kapama anahtari.
///
/// API'si `value` + `onChanged` ile Material `Switch`'e birebir takilir;
/// SEC-02'de `SettingsSwitchRow` icindeki `Switch` bu bilesenle
/// degistirildi (bkz. `lib/features/settings/widgets/settings_switch_row.dart`).
/// `onChanged == null` pasif durumu ifade eder.
class RwToggle extends StatefulWidget {
  const RwToggle({
    required this.value,
    required this.onChanged,
    super.key,
    this.semanticLabel,
    this.material = AppMaterial.wood,
  });

  /// Acik/kapali durum.
  final bool value;

  /// `null` verilirse anahtar pasiftir ve dokunma kapanir.
  final ValueChanged<bool>? onChanged;

  final String? semanticLabel;

  /// Track yuzeyinin malzemesi. Knob her zaman `stone` kullanir (DESIGN §11
  /// "durability" hissi), track cagiran taraf baglamina gore secilir.
  final AppMaterial material;

  @override
  State<RwToggle> createState() => _RwToggleState();
}

class _RwToggleState extends State<RwToggle> {
  bool _isPressed = false;

  static const double _trackWidth = 64.0;
  static const double _trackHeight = 32.0;
  static const double _knobPadding = 4.0;
  static const double _knobSize = _trackHeight - _knobPadding * 2;
  static const double _iconSize = 14.0;

  bool get _isEnabled => widget.onChanged != null;

  void _setPressed(bool value) {
    if (_isEnabled && _isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final RwSurfaceDepth knobDepth =
        _isEnabled && _isPressed ? RwSurfaceDepth.pressed : RwSurfaceDepth.raised;

    // Durum sadece renkle degil ikonla da tasinir (DESIGN §24): acikken
    // track AppColors.health'e (guvenli/aktif anlami) doner ve knob check
    // ikonu gosterir; kapaliyken track malzemenin normal yuzunde kalir ve
    // knob close ikonu gosterir.
    final Color? trackFace = widget.value ? AppColors.health : null;

    final Widget track = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppSpacing.minTouchTarget,
        minHeight: AppSpacing.minTouchTarget,
      ),
      child: Center(
        child: SizedBox(
          width: _trackWidth,
          height: _trackHeight,
          child: RwMaterialSurface(
            material: widget.material,
            shape: RwSurfaceShape.pill,
            depth: RwSurfaceDepth.flat,
            isDisabled: !_isEnabled,
            faceColor: trackFace,
            padding: const EdgeInsetsDirectional.all(_knobPadding),
            child: AnimatedAlign(
              duration: AppDuration.fast,
              alignment: widget.value
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: SizedBox(
                width: _knobSize,
                height: _knobSize,
                child: RwMaterialSurface(
                  material: AppMaterial.stone,
                  shape: RwSurfaceShape.circle,
                  depth: knobDepth,
                  isDisabled: !_isEnabled,
                  padding: EdgeInsetsDirectional.zero,
                  child: Center(
                    child: RwIcon(
                      widget.value ? RwIconId.check : RwIconId.close,
                      size: _iconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      toggled: widget.value,
      enabled: _isEnabled,
      label: widget.semanticLabel,
      container: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _isEnabled ? () => widget.onChanged!(!widget.value) : null,
        behavior: HitTestBehavior.opaque,
        child: track,
      ),
    );
  }
}
