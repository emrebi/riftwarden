import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Ayarlar ekraninda alt sayfaya veya harici aksiyona yonlendiren satir.
///
/// `RwButton`in ikincil (secondary/parchment) yuzey diliyle ayni malzeme +
/// derinlik gecisini kullanir (SEC-02); `RwButton`in kendisi tek satirlik
/// etiket + opsiyonel ikonla sinirli oldugundan (satir sonu deger + ok
/// glifini tasiyamaz), ayni gorsel dil `RwMaterialSurface` uzerinde burada
/// yeniden kurulur. RTL destege gore ok yonu dinamik ayarlanir; dokunma
/// hedefi min 48 dp kuralina uygun sekilde genisletildi.
class SettingsActionRow extends StatefulWidget {
  const SettingsActionRow({
    required this.label,
    required this.onTap,
    super.key,
    this.value,
    this.showArrow = true,
    this.material = AppMaterial.parchment,
  });

  final String label;
  final VoidCallback onTap;
  final String? value;
  final bool showArrow;

  /// Satirin yuzey malzemesi. Varsayilan `parchment` (RwButton secondary
  /// varyantiyla ayni malzeme).
  final AppMaterial material;

  @override
  State<SettingsActionRow> createState() => _SettingsActionRowState();
}

class _SettingsActionRowState extends State<SettingsActionRow> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final arrowIcon =
        isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
    final RwSurfaceDepth depth =
        _isPressed ? RwSurfaceDepth.pressed : RwSurfaceDepth.raised;
    final String semanticLabel =
        widget.value == null ? widget.label : '${widget.label}: ${widget.value}';

    return Semantics(
      button: true,
      label: semanticLabel,
      // excludeSemantics cocuk GestureDetector'in eylemini de sildigi icin
      // ekran okuyucu etkinlestirmesi burada ayrica baglanir.
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          child: RwMaterialSurface(
            material: widget.material,
            depth: depth,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTypography.onMaterial(
                      AppTypography.bodyLarge,
                      widget.material,
                    ),
                  ),
                ),
                if (widget.value != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.value!,
                    style: AppTypography.onMaterialSecondary(
                      AppTypography.bodyMedium,
                      widget.material,
                    ),
                  ),
                ],
                if (widget.showArrow) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    arrowIcon,
                    color: AppMaterials.textSecondary(widget.material),
                    size: AppSpacing.screenGutter,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
