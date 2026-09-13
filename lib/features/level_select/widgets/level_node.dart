import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';

/// Harita uzerindeki tek bir seviye dugumu bileseni.
///
/// Uc farkli durumu (completed, current, locked) ve boss seviyelerini
/// gorsel olarak ayristirir. Dokunma hedefi en az [AppSpacing.minTouchTarget]
/// genisligindedir.
class LevelNode extends StatefulWidget {
  const LevelNode({
    required this.node,
    required this.onTap,
    super.key,
  });

  final LevelNodeData node;
  final VoidCallback? onTap;

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode> {
  bool _isPressed = false;

  bool get _isInteractive =>
      widget.node.state != LevelNodeState.locked && widget.onTap != null;

  void _handleTapDown(TapDownDetails details) {
    if (_isInteractive) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isInteractive) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isInteractive) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final isBoss = node.isBoss;
    final isCurrent = node.state == LevelNodeState.current;
    final isCompleted = node.state == LevelNodeState.completed;

    // Dugum gorsel boyutlari: Boss dugumu daha heybetli tutulur
    final double nodeSize = isBoss ? 46.0 : 40.0;

    // Renk ve dekorasyon kurallari
    final BoxDecoration decoration;
    final Widget iconOrContent;
    final Color labelColor;

    if (isBoss) {
      if (isCurrent) {
        labelColor = AppColors.riftMagenta;
        decoration = BoxDecoration(
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topCenter,
            end: AlignmentDirectional.bottomCenter,
            colors: <Color>[
              AppColors.riftViolet,
              AppColors.riftMagenta,
            ],
          ),
          borderRadius: AppBorderRadii.md,
          border: Border.all(
            color: AppColors.danger,
            width: 2.0,
          ),
          boxShadow: AppShadows.glow(
            AppColors.riftMagenta,
            blurRadius: 16.0,
          ),
        );
        final levelIdText = node.levelId.toString();
        iconOrContent = Text(
          levelIdText,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        );
      } else if (isCompleted) {
        labelColor = AppColors.textSecondary;
        decoration = BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: AppBorderRadii.md,
          border: Border.all(
            color: AppColors.coreTeal,
            width: 2.0,
          ),
          boxShadow: AppShadows.glow(
            AppColors.coreTeal.withValues(alpha: 0.4),
            blurRadius: 6.0,
          ),
        );
        iconOrContent = const Icon(
          Icons.check_rounded,
          size: 22.0,
          color: AppColors.coreTeal,
        );
      } else {
        // Boss kilitli: Tehdit hissi veren menekse cerceve
        labelColor = AppColors.riftViolet.withValues(alpha: 0.6);
        decoration = BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.6),
          borderRadius: AppBorderRadii.md,
          border: Border.all(
            color: AppColors.riftViolet.withValues(alpha: 0.4),
            width: 1.5,
          ),
        );
        iconOrContent = const Icon(
          Icons.lock_rounded,
          size: 18.0,
          color: AppColors.textDisabled,
        );
      }
    } else {
      // Normal seviye dugumleri: Dairesel bicim
      if (isCurrent) {
        labelColor = AppColors.aetherCyan;
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.primaryButton,
          border: Border.all(
            color: AppColors.aetherCyan,
            width: 2.0,
          ),
          boxShadow: AppShadows.glow(
            AppColors.aetherCyan,
            blurRadius: 14.0,
          ),
        );
        final levelIdText = node.levelId.toString();
        iconOrContent = Text(
          levelIdText,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.voidDeep,
            fontWeight: FontWeight.w800,
          ),
        );
      } else if (isCompleted) {
        labelColor = AppColors.textSecondary;
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceRaised,
          border: Border.all(
            color: AppColors.coreTeal.withValues(alpha: 0.5),
            width: 1.5,
          ),
        );
        iconOrContent = const Icon(
          Icons.check_rounded,
          size: 20.0,
          color: AppColors.coreTeal,
        );
      } else {
        // Kilitli normal seviye
        labelColor = AppColors.textDisabled;
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface.withValues(alpha: 0.5),
          border: Border.all(
            color: AppColors.surfaceRaised,
            width: 1.0,
          ),
        );
        iconOrContent = const Icon(
          Icons.lock_rounded,
          size: 16.0,
          color: AppColors.textDisabled,
        );
      }
    }

    Widget visualNode = Container(
      width: nodeSize,
      height: nodeSize,
      alignment: AlignmentDirectional.center,
      decoration: decoration,
      child: iconOrContent,
    );

    // Pil tuketimini engellemek icin nabiz animasyonu yalnizca current dugumde calisir
    if (isCurrent) {
      visualNode = _PulsingCurrentNode(
        child: visualNode,
      );
    }

    final levelNumberText = node.levelId.toString();

    return SizedBox(
      width: AppSpacing.minTouchTarget,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _isInteractive ? widget.onTap : null,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: AppSpacing.minTouchTarget,
              height: AppSpacing.minTouchTarget,
              child: Center(
                child: AnimatedScale(
                  scale: _isPressed ? 0.94 : 1.0,
                  duration: AppDuration.instant,
                  curve: Curves.easeOutCubic,
                  child: visualNode,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isBoss) ...<Widget>[
                Icon(
                  Icons.whatshot_rounded,
                  size: 10.0,
                  color: labelColor,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                levelNumberText,
                style: AppTypography.label.copyWith(
                  color: labelColor,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Yalnizca siradaki aktif dugumde calisan hafif nabiz animasyonu bileseni.
class _PulsingCurrentNode extends StatefulWidget {
  const _PulsingCurrentNode({
    required this.child,
  });

  final Widget child;

  @override
  State<_PulsingCurrentNode> createState() => _PulsingCurrentNodeState();
}

class _PulsingCurrentNodeState extends State<_PulsingCurrentNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
