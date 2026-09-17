import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Harita uzerindeki tek bir seviye dugumu bileseni.
///
/// Uc farkli durumu (completed, current, locked) ve boss seviyelerini
/// sadece renkle degil malzeme, ikon ve siluetle de ayristirir (DESIGN §24):
/// kilitli dugum tas malzeme + kilit ikonu, tamamlanan tas malzeme + onay
/// isareti, siradaki dugum ahsap malzeme + secim halkasi + hafif nabiz.
/// Boss dugumleri kare siluetle (normal dugumler daire) ayri okunur.
/// Dokunma hedefi en az [AppSpacing.minTouchTarget] genisligindedir.
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
    final isLocked = node.state == LevelNodeState.locked;

    // Dugum boyutu: boss dugumu daha heybetli tutulur, kare siluetle ayrisir.
    final double nodeSize = isBoss ? 46.0 : 40.0;
    final RwSurfaceShape shape =
        isBoss ? RwSurfaceShape.standard : RwSurfaceShape.circle;

    final AppMaterial material;
    final Widget iconOrContent;
    final Color labelColor;

    if (isLocked) {
      material = AppMaterial.stone;
      labelColor = AppColors.textOnLightDisabled;
      iconOrContent = RwIcon(
        RwIconId.lock,
        size: isBoss ? 18.0 : 16.0,
        color: AppMaterials.textSecondary(material),
      );
    } else if (isCompleted) {
      material = AppMaterial.stone;
      labelColor = AppColors.success;
      iconOrContent = RwIcon(
        RwIconId.check,
        size: isBoss ? 22.0 : 20.0,
        color: AppColors.success,
      );
    } else {
      // current: siradaki aktif dugum, seviye numarasi govdede gosterilir.
      material = AppMaterial.wood;
      labelColor = AppColors.cta;
      final levelIdText = node.levelId.toString();
      iconOrContent = Text(
        levelIdText,
        style: AppTypography.onMaterial(AppTypography.titleMedium, material)
            .copyWith(fontWeight: FontWeight.w800),
      );
    }

    Widget visualNode = SizedBox(
      width: nodeSize,
      height: nodeSize,
      child: RwMaterialSurface(
        material: material,
        shape: shape,
        depth: isLocked
            ? RwSurfaceDepth.flat
            : (_isPressed ? RwSurfaceDepth.pressed : RwSurfaceDepth.raised),
        // Secim halkasi siradaki dugumu renk disinda da isaretler.
        isSelected: isCurrent,
        isDisabled: isLocked,
        padding: EdgeInsetsDirectional.zero,
        child: Center(child: iconOrContent),
      ),
    );

    // Pil tuketimini engellemek icin nabiz animasyonu yalnizca current dugumde calisir.
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
                style: AppTypography.smallLabel.copyWith(
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
///
/// Genlik dar tutulur (en fazla %6 buyume) ve periyot 1.2-1.6 sn araliginda
/// kalir; boylece dikkat cekici ama rahatsiz etmeyen bir vurgu olusur
/// (DESIGN §24 "restrained pulse").
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
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    // Current durumu widget agacindan cikinca controller da durur; sizinti
    // birakmamak icin explicit dispose sarttir.
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
