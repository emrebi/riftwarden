import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Iki ardil level dugumu arasindaki enerji baglanti hatti.
class NodeConnector extends StatelessWidget {
  const NodeConnector({
    required this.isActive,
    super.key,
  });

  /// Baglantinin acik veya aktif olup olmadigi.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.coreTeal : AppColors.surfaceRaised;

    return SizedBox(
      height: AppSpacing.minTouchTarget,
      child: Center(
        child: Container(
          height: 2.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppBorderRadii.pill,
            boxShadow: isActive
                ? AppShadows.glow(AppColors.coreTeal, blurRadius: 4.0)
                : null,
          ),
        ),
      ),
    );
  }
}
