import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/core/services/service_providers.dart';
import 'package:riftwarden/features/orientation_gate/viewmodel/orientation_gate_controller.dart';
import 'package:riftwarden/features/orientation_gate/widgets/rotating_phone_indicator.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

/// Acilis yon kapisi: cihaz dikeyken gorunur, yatay olunca ya da dokununca
/// oyun acilir.
class OrientationGateScreen extends ConsumerStatefulWidget {
  const OrientationGateScreen({required this.onReady, super.key});

  final VoidCallback onReady;

  @override
  ConsumerState<OrientationGateScreen> createState() =>
      _OrientationGateScreenState();
}

class _OrientationGateScreenState
    extends ConsumerState<OrientationGateScreen>
    with SingleTickerProviderStateMixin {
  late final OrientationGateController _controller;
  late final AnimationController _animController;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = OrientationGateController(
      service: ref.read(orientationServiceProvider),
      onReady: widget.onReady,
    );
    _controller.start();

    // Yataya cevirme animasyonu: dikeyden saga 90 derece donup yatay olur,
    // kisa bir duraksama yapar, basa doner ve donguyu tekrarlar.
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rotationAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      // Dikey durustan saga 90 derece donus (~800 ms)
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: math.pi / 2)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40.0,
      ),
      // Yatay konumda kisa duraksama (~500 ms)
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(math.pi / 2),
        weight: 25.0,
      ),
      // Basa (dikey konuma) geri donus (~500 ms)
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: math.pi / 2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 25.0,
      ),
      // Dongu yenilenmeden once dikey durusta bekleme (~200 ms)
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0),
        weight: 10.0,
      ),
    ]).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

    if (isLandscape) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.onOrientationChanged(isLandscape: true);
        }
      });
    }

    // Dairesel ilerleme halkasi ve geri sayim metni bileseni
    final countdownWidget = ValueListenableBuilder<int>(
      valueListenable: _controller.secondsLeft,
      builder: (context, seconds, _) {
        final progress = (seconds / 10.0).clamp(0.0, 1.0);
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox.square(
              dimension: AppSpacing.xl,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.5,
                backgroundColor: AppColors.surfaceRaised,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.aetherCyan,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              l10n.rotateAutoIn(seconds),
              style: AppTypography.bodyMedium,
            ),
          ],
        );
      },
    );

    // En alttaki soluk devam etme ipucu
    final tapToContinueWidget = Text(
      l10n.rotateTapToContinue,
      textAlign: TextAlign.center,
      style: AppTypography.label.copyWith(
        color: AppColors.textDisabled,
      ),
    );

    // Animasyonlu telefon silueti
    final phoneIndicator = RotatingPhoneIndicator(
      animation: _rotationAnimation,
    );

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _controller.onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.35),
              radius: 1.1,
              colors: <Color>[
                AppColors.surface,
                AppColors.voidBase,
                AppColors.voidDeep,
              ],
              stops: <double>[0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.screenGutter),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: isLandscape
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            phoneIndicator,
                            const SizedBox(width: AppSpacing.xxl),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  l10n.rotateTitle,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.titleLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  l10n.rotateHint,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                countdownWidget,
                                const SizedBox(height: AppSpacing.md),
                                tapToContinueWidget,
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            phoneIndicator,
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              l10n.rotateTitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.rotateHint,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            countdownWidget,
                            const SizedBox(height: AppSpacing.xl),
                            tapToContinueWidget,
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
