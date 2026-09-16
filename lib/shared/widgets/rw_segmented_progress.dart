import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Dalga/asama ilerlemesi icin ayrik segment gostergesi (DESIGN §10 "wave
/// ... simple segmented progress"). `RwProgressBar` ile ayni el yapimi
/// track dilini (malzeme dolgusu + koyu keyline) kucuk, esit parcalar
/// halinde tekrarlar; sureklilik yerine ayrik adim/dalga sayisi onemli
/// oldugunda kullanilir.
class RwSegmentedProgress extends StatelessWidget {
  const RwSegmentedProgress({
    required this.segments,
    required this.value,
    super.key,
    this.currentSegment,
    this.color,
    this.trackMaterial = AppMaterial.hud,
    this.height = 10.0,
  });

  /// Toplam esit parca sayisi. `<= 0` ise gorunmez (bos alan) doner.
  final int segments;

  /// Genel ilerleme, 0..1.
  final double value;

  /// Ince `AppColors.selection` keyline vurgusu alacak segment (0 tabanli).
  final int? currentSegment;

  /// Dolu segment rengi. Verilmezse `AppColors.aether` kullanilir.
  final Color? color;

  /// Bos segmentlerin ve keyline'in malzemesi.
  final AppMaterial trackMaterial;

  final double height;

  @override
  Widget build(BuildContext context) {
    if (segments <= 0) {
      return const SizedBox.shrink();
    }

    final Color fillColor = color ?? AppColors.aether;
    final Color trackFace = AppMaterials.face(trackMaterial);
    final Color keylineColor = AppMaterials.keyline(trackMaterial);
    final bool isCompact = height < 8.0;
    final double keylineWidth = isCompact ? 1.0 : 1.5;

    // Genel ilerlemeyi segment basina doluluk oranina cevir: tamamlanan
    // segmentler tam dolu, mevcut segment kismi dolu, kalanlar bos.
    final double scaled = (value.clamp(0.0, 1.0)) * segments;

    return Row(
      children: List<Widget>.generate(segments, (int index) {
        final double fillFraction = (scaled - index).clamp(0.0, 1.0);
        final bool isHighlighted = currentSegment == index;

        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == segments - 1 ? 0.0 : AppSpacing.xs,
            ),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: trackFace,
                borderRadius: AppBorderRadii.pill,
                border: Border.all(
                  color: isHighlighted ? AppColors.selection : keylineColor,
                  width: isHighlighted ? keylineWidth + 0.5 : keylineWidth,
                ),
              ),
              child: ClipRRect(
                borderRadius: AppBorderRadii.pill,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: fillFraction,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(color: fillColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
