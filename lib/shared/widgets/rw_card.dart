import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Gelistirme ve secim karti.
///
/// Rarity seviyesine gore kenarlik rengi degisir; legendary derecesinde
/// dis parlama efekti uygulanir.
class RwCard extends StatefulWidget {
  const RwCard({
    required this.title,
    required this.rarity,
    super.key,
    this.description,
    this.icon,
    this.badge,
    this.child,
    this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String rarity;
  final String? description;
  final Widget? icon;
  final String? badge;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  State<RwCard> createState() => _RwCardState();
}

class _RwCardState extends State<RwCard> {
  bool _isPressed = false;

  bool get _isLegendary => widget.rarity.toLowerCase() == 'legendary';

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppColors.rarity(widget.rarity);

    final List<BoxShadow> shadows = _isLegendary
        ? AppShadows.glow(AppColors.rarityLegendary, blurRadius: 18.0)
        : (widget.isSelected
            ? AppShadows.glow(rarityColor, blurRadius: 12.0)
            : AppShadows.panel);

    final Widget innerContent = widget.child ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.15),
                    borderRadius: AppBorderRadii.sm,
                    border: Border.all(
                      color: rarityColor.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    widget.rarity.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      color: rarityColor,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                if (widget.badge != null)
                  Text(
                    widget.badge!,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (widget.icon != null) ...<Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.md,
                  ),
                  child: widget.icon!,
                ),
              ),
            ],
            Text(
              widget.title,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.description != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.description!,
                style: AppTypography.bodyMedium,
              ),
            ],
          ],
        );

    Widget cardWidget = Container(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.minTouchTarget,
      ),
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.panel,
        borderRadius: AppBorderRadii.md,
        border: Border.all(
          color: widget.isSelected ? AppColors.textPrimary : rarityColor,
          width: widget.isSelected ? 2.0 : 1.5,
        ),
        boxShadow: shadows,
      ),
      child: innerContent,
    );

    if (widget.onTap != null) {
      cardWidget = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: AppDuration.instant,
          curve: Curves.easeOutCubic,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}
