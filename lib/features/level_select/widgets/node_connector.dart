import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Iki ardil level dugumu arasindaki ip/murekkep izi baglanti hatti.
///
/// Parsomen malzemesi uzerinde okunmasi icin sicak murekkep tonu (acik) ve
/// soluk parsomen kenar tonu (kapali) kullanilir; parlama (glow) yoktur.
class NodeConnector extends StatelessWidget {
  const NodeConnector({
    required this.isActive,
    super.key,
  });

  /// Baglantinin acik veya aktif olup olmadigi.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.outlineInk : AppColors.parchmentEdge;

    return SizedBox(
      height: AppSpacing.minTouchTarget,
      child: Center(
        child: Container(
          height: 3.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppBorderRadii.pill,
          ),
        ),
      ),
    );
  }
}
