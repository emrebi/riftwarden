import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Odullu reklam butonu.
///
/// Oyuncuya zaferde odulu katlama, yenilgide ise canlanarak devam etme
/// imkani sunar. Birincil eylem butonundan (DEVAM / TEKRAR DENE) net bir
/// sekilde ayrismasi icin kehribar kaynak rengi ve video oynatma
/// simgesi kullanir. Kandirmaca veya sahte kapatma deseni icermez.
class ResultAdButton extends StatefulWidget {
  const ResultAdButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Buton uzerinde gorunecek acik metin.
  final String label;

  /// Reklam izleme eylemi.
  final VoidCallback? onPressed;

  @override
  State<ResultAdButton> createState() => _ResultAdButtonState();
}

class _ResultAdButtonState extends State<ResultAdButton> {
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
    final textColor = _isEnabled ? AppColors.aether : AppColors.textDisabled;
    final borderColor = _isEnabled
        ? AppColors.aether.withValues(alpha: 0.6)
        : AppColors.surfaceRaised;

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.play_circle_filled_rounded,
          size: 20.0,
          color: textColor,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            widget.label,
            style: AppTypography.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: AppDuration.instant,
        curve: Curves.easeOutCubic,
        child: Container(
          height: AppSpacing.minTouchTarget,
          width: double.infinity,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: AppBorderRadii.md,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: _isEnabled
                ? AppShadows.glow(
                    AppColors.aether,
                    blurRadius: 8.0,
                  )
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
