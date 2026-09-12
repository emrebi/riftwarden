import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Buton gorsel turleri.
enum RwButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}

/// Standart oyun butonu.
///
/// Dokunma hedefi en az [AppSpacing.minTouchTarget] (48 dp) yuksekligindedir.
/// Basildiginda kuculme animasyonu uygular; veri veya saglayici baglantisi yoktur.
class RwButton extends StatefulWidget {
  const RwButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = RwButtonVariant.primary,
    this.icon,
    this.isExpanded = false,
    this.height = AppSpacing.minTouchTarget,
  });

  final String label;
  final VoidCallback? onPressed;
  final RwButtonVariant variant;
  final IconData? icon;
  final bool isExpanded;
  final double height;

  @override
  State<RwButton> createState() => _RwButtonState();
}

class _RwButtonState extends State<RwButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isEnabled) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = widget.height < AppSpacing.minTouchTarget
        ? AppSpacing.minTouchTarget
        : widget.height;

    // Renk ve dekorasyon secimi
    final Color textColor;
    final Gradient? gradient;
    final Color? solidColor;
    final BoxBorder border;
    final List<BoxShadow>? shadows;

    if (!_isEnabled) {
      textColor = AppColors.textDisabled;
      gradient = null;
      solidColor = AppColors.surface;
      border = Border.all(
        color: AppColors.surfaceRaised,
        width: 1.0,
      );
      shadows = null;
    } else {
      switch (widget.variant) {
        case RwButtonVariant.primary:
          textColor = AppColors.voidDeep;
          gradient = AppGradients.primaryButton;
          solidColor = null;
          border = Border.all(
            color: AppColors.aetherCyan,
            width: 1.0,
          );
          shadows = AppShadows.glow(
            AppColors.aetherCyan,
            blurRadius: 12.0,
          );
        case RwButtonVariant.secondary:
          textColor = AppColors.textPrimary;
          gradient = null;
          solidColor = AppColors.surfaceRaised;
          border = AppBorders.subtle;
          shadows = null;
        case RwButtonVariant.ghost:
          textColor = AppColors.aetherCyan;
          gradient = null;
          solidColor = Colors.transparent;
          border = AppBorders.subtle;
          shadows = null;
        case RwButtonVariant.danger:
          textColor = AppColors.textPrimary;
          gradient = AppGradients.dangerButton;
          solidColor = null;
          border = Border.all(
            color: AppColors.danger,
            width: 1.0,
          );
          shadows = AppShadows.glow(
            AppColors.danger,
            blurRadius: 12.0,
          );
      }
    }

    final TextStyle textStyle = AppTypography.titleMedium.copyWith(
      color: textColor,
      fontWeight: FontWeight.w700,
    );

    final Widget content = Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          Icon(
            widget.icon,
            size: 20.0,
            color: textColor,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.label,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );

    final Widget button = AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: AppDuration.instant,
      curve: Curves.easeOutCubic,
      child: Container(
        height: effectiveHeight,
        width: widget.isExpanded ? double.infinity : null,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          color: solidColor,
          gradient: gradient,
          borderRadius: AppBorderRadii.md,
          border: border,
          boxShadow: shadows,
        ),
        child: content,
      ),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: button,
    );
  }
}
