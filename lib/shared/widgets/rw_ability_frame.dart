import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/format/rw_number_format.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Yetenek cercevesinin gorsel durumu (DESIGN §12 "RIFT COLLAPSE / ABILITY
/// SYSTEM"). Renk disinda ikon/maske/reticle/isaret ile de ayrisir.
enum RwAbilityState {
  /// Hazir: canli ikon + ince hazir cemberi + tek seferlik pulse.
  ready,

  /// Bekleme: desature ikon + radyal maske + ilerleme halkasi + kalan sure.
  cooldown,

  /// Hedefleme: ikonun ustunde reticle, yuzey kalkik.
  targeting,

  /// Kullanilamaz: duz/soluk yuzey + engel isareti, dokunma kapali.
  unavailable,
}

// Olcu token'lari (brief: "olculer static const").
const double _minSize = 48.0;
const double _ringInset = 4.0;
const double _ringStrokeWidth = 2.0;
const double _reticleStrokeWidth = 1.5;
const double _reticleTickLength = 5.0;
const double _blockedBadgeSize = 18.0;
const double _blockedBadgePadding = 2.0;
const double _blockedIconSize = 12.0;
const double _defaultIconSizeRatio = 0.42;
const double _cooldownIconOpacity = 0.6;
const double _unavailableIconOpacity = 0.5;

/// Gri tonlama matrisi (cooldown/unavailable ikon desaturasyonu). `static
/// const` -> `ColorFilter.matrix` her build'de ayni sabit listeyi kullanir,
/// yeni liste olusturmaz.
const List<double> _grayscaleMatrix = <double>[
  0.21, 0.72, 0.07, 0, 0, //
  0.21, 0.72, 0.07, 0, 0, //
  0.21, 0.72, 0.07, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// Dairesel yetenek cercevesi: hazir/bekleme/hedefleme/kullanilamaz
/// durumlarini stone `RwMaterialSurface` govdesi uzerinde gosterir.
///
/// ## Neden ayri bir primitive
/// `AbilityButton` (lib/features/battle/widgets/ability_button.dart) bugun
/// `BattleSignals`e baglanan eski neon govdeyi kullanir; bu widget saf
/// parametre gudumludur (provider/signal YOK), boylece hem savas HUD'u hem
/// ileride gelecek defender/loadout yuzeyleri ayni cerceveyi paylasabilir.
/// Baglama BATTLE-* gorevinde yapilir, bu gorevin kapsami degildir.
class RwAbilityFrame extends StatefulWidget {
  const RwAbilityFrame({
    required this.state,
    super.key,
    this.icon,
    this.cooldownProgress = 0.0,
    this.remainingSeconds,
    this.onTap,
    this.size = 64.0,
    this.semanticLabel,
  });

  /// Gorsel durum (DESIGN §12).
  final RwAbilityState state;

  /// Yetenek glifi. `null` ise `RwIcon(RwIconId.rift)`.
  final Widget? icon;

  /// Bekleme ilerlemesi, 0..1. **1 = bekleme yeni basladi (tam dolu maske),
  /// 0 = hazir (maske bosalmis)** — `cooldown` disinda kullanilmaz.
  final double cooldownProgress;

  /// Kalan saniye. `cooldown` durumunda verilirse merkeze
  /// `RwNumberFormat.seconds` ile yazilir.
  final double? remainingSeconds;

  /// Dokunma gericagirimi. `unavailable` durumunda -- verilse bile --
  /// etkilesim kapalidir. `targeting` durumunda tekrar dokunma da yine
  /// bunu cagirir; hedeflemeden cikisi cagiran taraf yonetir.
  final VoidCallback? onTap;

  /// Cerceve kenar uzunlugu. `_minSize` (48) altina inmez.
  final double size;

  final String? semanticLabel;

  @override
  State<RwAbilityFrame> createState() => _RwAbilityFrameState();
}

class _RwAbilityFrameState extends State<RwAbilityFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDuration.slow,
    );
    _pulseScale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(RwAbilityFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sadece "birine gecince" tetiklenir; ready'de kalirken tekrar build
    // pulse'u yeniden baslatmaz (brief kosulu).
    if (oldWidget.state != RwAbilityState.ready &&
        widget.state == RwAbilityState.ready) {
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _resolveGlyph(double effectiveSize) {
    return widget.icon ??
        RwIcon(RwIconId.rift, size: effectiveSize * _defaultIconSizeRatio);
  }

  Widget _buildReady(double effectiveSize) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(child: _resolveGlyph(effectiveSize)),
        Positioned.fill(
          child: CustomPaint(painter: _ReadyRingPainter(color: AppColors.cta)),
        ),
      ],
    );
  }

  Widget _buildCooldown(BuildContext context, double effectiveSize) {
    final double progress = widget.cooldownProgress.clamp(0.0, 1.0);
    final Widget desaturated = ColorFiltered(
      colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
      child: Opacity(
        opacity: _cooldownIconOpacity,
        child: _resolveGlyph(effectiveSize),
      ),
    );
    final double? remaining = widget.remainingSeconds;
    final String? label = remaining == null
        ? null
        : RwNumberFormat.seconds(remaining, Localizations.localeOf(context));

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(child: desaturated),
        Positioned.fill(
          child: CustomPaint(
            painter: _CooldownPainter(
              progress: progress,
              maskColor: AppColors.outlineInk,
              ringColor: AppColors.aether,
            ),
          ),
        ),
        if (label != null)
          Text(
            label,
            style: AppTypography.numeric.copyWith(color: AppColors.textOnDark),
          ),
      ],
    );
  }

  Widget _buildTargeting(double effectiveSize) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(child: _resolveGlyph(effectiveSize)),
        Positioned.fill(
          child: CustomPaint(
            painter: _ReticlePainter(color: AppColors.selection),
          ),
        ),
      ],
    );
  }

  Widget _buildUnavailable(double effectiveSize) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
            child: Opacity(
              opacity: _unavailableIconOpacity,
              child: _resolveGlyph(effectiveSize),
            ),
          ),
        ),
        const PositionedDirectional(
          bottom: 0.0,
          end: 0.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.outlineInk,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.all(_blockedBadgePadding),
              child: SizedBox(
                width: _blockedBadgeSize - _blockedBadgePadding * 2,
                height: _blockedBadgeSize - _blockedBadgePadding * 2,
                child: Center(
                  child: RwIcon(
                    RwIconId.close,
                    size: _blockedIconSize,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, double effectiveSize) {
    switch (widget.state) {
      case RwAbilityState.ready:
        return _buildReady(effectiveSize);
      case RwAbilityState.cooldown:
        return _buildCooldown(context, effectiveSize);
      case RwAbilityState.targeting:
        return _buildTargeting(effectiveSize);
      case RwAbilityState.unavailable:
        return _buildUnavailable(effectiveSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double effectiveSize = math.max(widget.size, _minSize);
    final bool isUnavailable = widget.state == RwAbilityState.unavailable;
    final bool isInteractive = widget.onTap != null && !isUnavailable;

    final RwSurfaceDepth depth = switch (widget.state) {
      RwAbilityState.unavailable => RwSurfaceDepth.flat,
      RwAbilityState.targeting => RwSurfaceDepth.raised,
      RwAbilityState.ready => RwSurfaceDepth.raised,
      RwAbilityState.cooldown => RwSurfaceDepth.raised,
    };

    Widget frame = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: RwMaterialSurface(
        material: AppMaterial.stone,
        shape: RwSurfaceShape.circle,
        depth: depth,
        isDisabled: isUnavailable,
        padding: EdgeInsetsDirectional.zero,
        child: _buildContent(context, effectiveSize),
      ),
    );

    frame = AnimatedBuilder(
      animation: _pulseScale,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(scale: _pulseScale.value, child: child);
      },
      child: frame,
    );

    final String? cooldownValue =
        widget.state == RwAbilityState.cooldown && widget.remainingSeconds != null
            ? RwNumberFormat.seconds(
                widget.remainingSeconds!,
                Localizations.localeOf(context),
              )
            : null;

    return Semantics(
      container: true,
      button: isInteractive,
      enabled: !isUnavailable,
      label: widget.semanticLabel,
      value: cooldownValue,
      child: GestureDetector(
        onTap: isInteractive ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: frame,
      ),
    );
  }
}

/// Hazir durumunda ince kisitli hazir cemberi (DESIGN §12 "restrained
/// amber/blue ready rim"). Glow YOK, sadece ince stroke.
class _ReadyRingPainter extends CustomPainter {
  _ReadyRingPainter({required this.color})
      : _paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringStrokeWidth
          ..color = color;

  final Color color;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = (Offset.zero & size).deflate(_ringInset);
    canvas.drawArc(rect, 0.0, math.pi * 2, false, _paint);
  }

  @override
  bool shouldRepaint(covariant _ReadyRingPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Bekleme maskesi + ilerleme halkasi (DESIGN §12 "radial mask or ring").
/// `progress` saat yonunde tepeden baslar; 1 = tam maskeli (yeni basladi),
/// 0 = maskesiz (hazir).
class _CooldownPainter extends CustomPainter {
  _CooldownPainter({
    required this.progress,
    required this.maskColor,
    required this.ringColor,
  })  : _maskPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor.withValues(alpha: 0.55),
        _ringTrackPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringStrokeWidth
          ..color = ringColor.withValues(alpha: 0.25),
        _ringFillPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringStrokeWidth
          ..strokeCap = StrokeCap.round
          ..color = ringColor;

  static const double _startAngle = -math.pi / 2;

  final double progress;
  final Color maskColor;
  final Color ringColor;
  final Paint _maskPaint;
  final Paint _ringTrackPaint;
  final Paint _ringFillPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect fullRect = Offset.zero & size;
    final double sweep = progress * math.pi * 2;
    if (sweep > 0.0) {
      canvas.drawArc(fullRect, _startAngle, sweep, true, _maskPaint);
    }
    final Rect ringRect = fullRect.deflate(_ringInset);
    canvas.drawArc(ringRect, 0.0, math.pi * 2, false, _ringTrackPaint);
    if (sweep > 0.0) {
      canvas.drawArc(ringRect, _startAngle, sweep, false, _ringFillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CooldownPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.maskColor != maskColor ||
      oldDelegate.ringColor != ringColor;
}

/// Hedefleme reticle'i: ince daire + 4 tik (DESIGN §12 "reticle replaces or
/// overlays the ready icon").
class _ReticlePainter extends CustomPainter {
  _ReticlePainter({required this.color})
      : _paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _reticleStrokeWidth
          ..color = color;

  final Color color;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 - _ringInset;
    canvas.drawCircle(center, radius, _paint);
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - _reticleTickLength),
      Offset(center.dx, center.dy - radius + 1.0),
      _paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + radius - 1.0),
      Offset(center.dx, center.dy + radius + _reticleTickLength),
      _paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius - _reticleTickLength, center.dy),
      Offset(center.dx - radius + 1.0, center.dy),
      _paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius - 1.0, center.dy),
      Offset(center.dx + radius + _reticleTickLength, center.dy),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) =>
      oldDelegate.color != color;
}
