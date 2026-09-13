import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

/// Ana menu baslik ve logo alani.
///
/// Ekran acilisinda yumusak belirme (fade + scale) animasyonu uygular.
/// Harf araligi ve katmanli golge ile boyut enerjisi hissi verir.
class MenuLogo extends StatefulWidget {
  const MenuLogo({super.key});

  @override
  State<MenuLogo> createState() => _MenuLogoState();
}

class _MenuLogoState extends State<MenuLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDuration.slow,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.aetherCyan,
                  letterSpacing: 4.0,
                  shadows: const <Shadow>[
                    Shadow(
                      color: AppColors.aetherCyanDim,
                      blurRadius: 28.0,
                    ),
                    Shadow(
                      color: AppColors.aetherCyan,
                      blurRadius: 14.0,
                    ),
                    Shadow(
                      color: AppColors.voidDeep,
                      blurRadius: 4.0,
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: AppSpacing.xxxl * 2,
              height: AppSpacing.xs / 2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Colors.transparent,
                    AppColors.aetherCyan,
                    AppColors.riftGlow,
                    Colors.transparent,
                  ],
                  stops: <double>[0.0, 0.35, 0.65, 1.0],
                ),
                borderRadius: AppBorderRadii.pill,
                boxShadow: AppShadows.glow(
                  AppColors.aetherCyan,
                  blurRadius: 8.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
