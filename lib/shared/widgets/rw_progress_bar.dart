import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Dolgu renginin nasil belirlenecegini secen anlam (DESIGN §10, §12).
///
/// - `neutral`: dolgu rengi tamamen `color` parametresinden gelir (dalga,
///   ozel panel gostergeleri).
/// - `health`: dolgu `AppColors.health`; deger %25'in altina duserse
///   otomatik `AppColors.danger`'a gecer (Core HP, boss HP).
/// - `cooldown`: dolgu `color` ama iz rengine dogru dusuk doygunlukta
///   (Rift Collapse bekleme suresi — "desaturated icon" DESIGN §12).
enum RwProgressVariant { neutral, health, cooldown }

/// Ilerleme ve can cubugu (Core HP, boss HP, dalga ilerlemesi).
///
/// Hasar alindiginda arkada gecikmeli eriyen ikinci bir dolgu (hasar izi)
/// gosterebilir. Iz el yapimi malzeme dilini takip eder: malzeme dolgusu +
/// koyu keyline + dolgu ustunde ince acik derz (DESIGN §3, §21); neon
/// glow YOKTUR.
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
    this.variant = RwProgressVariant.neutral,
    this.trackMaterial = AppMaterial.hud,
  });

  final double value;
  final Color color;
  final Color? backgroundColor;
  final Color? trailColor;
  final double height;
  final bool showDamageTrail;
  final double? trailValue;

  /// Dolgu renginin anlami. Bkz. `RwProgressVariant`.
  final RwProgressVariant variant;

  /// Track (iz) dolgusunun malzemesi. `backgroundColor` verilirse bu
  /// gorsel olarak override edilir, sadece keyline/derz rengi icin
  /// malzeme kullanilmaya devam eder.
  final AppMaterial trackMaterial;

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

  /// Varyanta gore dolgu rengi (DESIGN §10, §12). `health` deger/tehlike
  /// esigini kendi belirler; `cooldown` sakinlestirilmis renk kullanir.
  Color _resolveFillColor(double clampedValue, Color trackFace) {
    switch (widget.variant) {
      case RwProgressVariant.neutral:
        return widget.color;
      case RwProgressVariant.health:
        return clampedValue < 0.25 ? AppColors.danger : AppColors.health;
      case RwProgressVariant.cooldown:
        return Color.lerp(widget.color, trackFace, 0.35) ?? widget.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clampedValue = widget.value.clamp(0.0, 1.0);
    final trackFace =
        widget.backgroundColor ?? AppMaterials.face(widget.trackMaterial);
    final keylineColor = AppMaterials.keyline(widget.trackMaterial);
    final fillColor = _resolveFillColor(clampedValue, trackFace);
    final effectiveTrailColor = widget.trailColor ??
        (fillColor == AppColors.danger
            ? AppColors.warning
            : AppColors.danger.withValues(alpha: 0.6));

    // Kucuk yukseklikte (can barinda 4 dp gibi) kalin keyline/derz
    // okunurlugu bozar; ince keyline'a dus, derz cizilmez.
    final bool isCompact = widget.height < 8.0;
    final double keylineWidth = isCompact ? 1.0 : 1.5;

    return Semantics(
      value: '${(clampedValue * 100).round()}%',
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: trackFace,
          borderRadius: AppBorderRadii.pill,
          border: Border.all(
            color: keylineColor,
            width: keylineWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: AppBorderRadii.pill,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final maxWidth = constraints.maxWidth;
              final primaryWidth =
                  (maxWidth * clampedValue).clamp(0.0, maxWidth);
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
                      color: fillColor,
                    ),
                  ),

                  // Dolgu ustunde ince acik ust derz (el yapimi highlight);
                  // kucuk yukseklikte okunurlugu bozdugu icin cizilmez.
                  if (!isCompact)
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: AnimatedContainer(
                        duration: AppDuration.fast,
                        width: primaryWidth,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: AppColors.textOnDark.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
