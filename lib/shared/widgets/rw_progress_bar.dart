import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Ilerleme ve can cubugu (Core HP, boss HP, dalga ilerlemesi).
///
/// Hasar alindiginda arkada gecikmeli eriyen ikinci bir dolgu (hasar izi)
/// gosterebilir.
class RwProgressBar extends StatefulWidget {
  const RwProgressBar({
    required this.value,
    required this.color,
    super.key,
    this.backgroundColor,
    this.trailColor,
    this.height = 12.0,
    this.showDamageTrail = false,
    this.trailValue,
  });

  final double value;
  final Color color;
  final Color? backgroundColor;
  final Color? trailColor;
  final double height;
  final bool showDamageTrail;
  final double? trailValue;

  @override
  State<RwProgressBar> createState() => _RwProgressBarState();
}

class _RwProgressBarState extends State<RwProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _trailController;
  late Animation<double> _trailAnimation;
  double _currentTrailValue = 1.0;

  @override
  void initState() {
    super.initState();
    _currentTrailValue = widget.value.clamp(0.0, 1.0);
    _trailController = AnimationController(
      vsync: this,
      duration: AppDuration.slow,
    );
    _trailAnimation = Tween<double>(
      begin: _currentTrailValue,
      end: _currentTrailValue,
    ).animate(
      CurvedAnimation(
        parent: _trailController,
        curve: Curves.easeOutCubic,
      ),
    )..addListener(() {
        setState(() {
          _currentTrailValue = _trailAnimation.value;
        });
      });
  }

  @override
  void didUpdateWidget(RwProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newClamped = widget.value.clamp(0.0, 1.0);
    final oldClamped = oldWidget.value.clamp(0.0, 1.0);

    if (widget.trailValue != null) {
      _currentTrailValue = widget.trailValue!.clamp(0.0, 1.0);
    } else if (widget.showDamageTrail) {
      if (newClamped < oldClamped) {
        // Hasar alindi: asil bar aninda duser, hasar izi arkadan yetisir
        _trailAnimation = Tween<double>(
          begin: _currentTrailValue,
          end: newClamped,
        ).animate(
          CurvedAnimation(
            parent: _trailController,
            curve: Curves.easeOutCubic,
          ),
        );
        _trailController
          ..reset()
          ..forward();
      } else if (newClamped > oldClamped) {
        // Can dolumu: iz de aninda esitlenir
        _currentTrailValue = newClamped;
      }
    } else {
      _currentTrailValue = newClamped;
    }
  }

  @override
  void dispose() {
    _trailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clampedValue = widget.value.clamp(0.0, 1.0);
    final bgColor = widget.backgroundColor ?? AppColors.voidDeep;
    final effectiveTrailColor = widget.trailColor ??
        (widget.color == AppColors.danger
            ? AppColors.warning
            : AppColors.danger.withValues(alpha: 0.6));

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppBorderRadii.pill,
        border: Border.all(
          color: AppColors.surfaceRaised,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadii.pill,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final maxWidth = constraints.maxWidth;
            final primaryWidth = (maxWidth * clampedValue).clamp(0.0, maxWidth);
            final trailWidth = (maxWidth * _currentTrailValue).clamp(
              0.0,
              maxWidth,
            );

            return Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                // Gecikmeli hasar izi dolgusu
                if (widget.showDamageTrail || widget.trailValue != null)
                  AnimatedContainer(
                    duration: AppDuration.fast,
                    width: trailWidth,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: effectiveTrailColor,
                    ),
                  ),

                // Ana ilerleme dolgusu
                AnimatedContainer(
                  duration: AppDuration.fast,
                  width: primaryWidth,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.color,
                    boxShadow: AppShadows.glow(
                      widget.color,
                      blurRadius: 6.0,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
