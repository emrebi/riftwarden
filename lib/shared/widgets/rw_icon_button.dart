import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Dairesel simge butonu (ayarlar, duraklatma, kapatma vb.).
///
/// Dokunma hedefi her zaman en az [AppSpacing.minTouchTarget] (48 dp) genisligindedir.
class RwIconButton extends StatefulWidget {
  const RwIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.size = AppSpacing.minTouchTarget,
    this.iconSize = 22.0,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;

  @override
  State<RwIconButton> createState() => _RwIconButtonState();
}

class _RwIconButtonState extends State<RwIconButton> {
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
    final effectiveBg = _isEnabled
        ? (widget.backgroundColor ?? AppColors.surfaceRaised)
        : AppColors.surface;

    final effectiveIconColor = _isEnabled
        ? (widget.iconColor ?? AppColors.textPrimary)
        : AppColors.textDisabled;

    final effectiveBorder = widget.borderColor != null
        ? Border.all(
            color: _isEnabled ? widget.borderColor! : AppColors.surfaceRaised,
            width: 1.0,
          )
        : Border.all(
            color: AppColors.surfaceRaised,
            width: 1.0,
          );

    final actualSize = widget.size < AppSpacing.minTouchTarget
        ? AppSpacing.minTouchTarget
        : widget.size;

    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: AppDuration.instant,
        curve: Curves.easeOutCubic,
        child: Container(
          width: actualSize,
          height: actualSize,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: effectiveBg,
            shape: BoxShape.circle,
            border: effectiveBorder,
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: effectiveIconColor,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
