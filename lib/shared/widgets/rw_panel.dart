import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Yukseltilmis panel yuzeyi.
///
/// Moduler pencereler, detay panelleri ve gruplanmis icerikler icin kullanilir.
class RwPanel extends StatelessWidget {
  const RwPanel({
    required this.child,
    super.key,
    this.title,
    this.trailing,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        const EdgeInsetsDirectional.all(AppSpacing.lg);

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null || trailing != null) ...<Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.lg,
              end: AppSpacing.lg,
              top: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ?trailing,
              ],
            ),
          ),
          const Divider(
            height: 1.0,
            thickness: 1.0,
            color: AppColors.surfaceRaised,
          ),
        ],
        Padding(
          padding: effectivePadding,
          child: child,
        ),
      ],
    );

    Widget container = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradients.panel,
        borderRadius: AppBorderRadii.lg,
        border: AppBorders.subtle,
        boxShadow: AppShadows.panel,
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadii.lg,
        child: content,
      ),
    );

    if (onTap != null) {
      container = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }

    return container;
  }
}
