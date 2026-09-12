import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Ayarlar, magaza ve menulerde grup basligi.
class RwSectionHeader extends StatelessWidget {
  const RwSectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.accentColor,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.aetherCyan;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Sol dikey vurgu cubugu
              Container(
                width: 3.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: effectiveAccent,
                  borderRadius: AppBorderRadii.sm,
                  boxShadow: AppShadows.glow(
                    effectiveAccent,
                    blurRadius: 4.0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.md,
              ),
              child: Text(
                subtitle!,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
