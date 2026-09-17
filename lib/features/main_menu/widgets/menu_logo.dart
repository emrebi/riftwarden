import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_art.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Ana menu baslik ve logo alani.
///
/// Kaleye monte edilmis ahsap bir tabela gibi okunsun diye
/// `RwMaterialSurface` (wood) uzerine kurulur (DESIGN §15 "mounted to
/// architecture... boards, signs, banners"). Uretim logosu geldiginde
/// `RwArt(group: logo, id: 'main_menu')` dogrudan onu gosterir; sanat
/// eksikken (bugun) `fallback` tabela metnini cizer (ARTINT-09'da
/// degistirilecek). Baslik metni sabit `AppTypography.screenTitle`
/// kullanir, per-frame olcekleme (FittedBox) uygulanmaz.
/// Ekran acilisinda yumusak belirme (fade + scale) animasyonu uygular.
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
        child: RwArt(
          group: RwArtGroup.logo,
          id: 'main_menu',
          semanticLabel: l10n.appTitle,
          fallback: RwMaterialSurface(
            material: AppMaterial.wood,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.onMaterial(
                    AppTypography.screenTitle,
                    AppMaterial.wood,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Alt baslik logoyla yarismamali: belirgin sekilde kucuk,
                // sonuk renkte -- logonun altinda bir tur etiketi gibi okunsun.
                Text(
                  l10n.menuSubtitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTypography.onMaterialSecondary(
                    AppTypography.smallLabel,
                    AppMaterial.wood,
                  ).copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
