import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riftwarden/features/boot/view/boot_screen.dart';
import 'package:riftwarden/features/orientation_gate/view/orientation_gate_screen.dart';

/// Rota adlari.
///
/// Ekranlar `context.goNamed(AppRoute.mainMenu)` seklinde isimle gezinir,
/// yola elle string yazmaz. Boylece yol degisirse tek yer degisir.
abstract final class AppRoute {
  static const String orientationGate = 'orientationGate';
  static const String boot = 'boot';
  static const String mainMenu = 'mainMenu';
  static const String levelSelect = 'levelSelect';
  static const String battle = 'battle';
  static const String result = 'result';
  static const String settings = 'settings';
  static const String store = 'store';
  static const String metaUpgrades = 'metaUpgrades';
}

/// Uygulama yonlendiricisi.
///
/// TODO(adim 16): Diger ekranlar eklendiginde rotalar burada tanimlanacak.
/// Savas ekrani gecisi animasyonsuz (NoTransitionPage) olmali — Flame
/// yuklenirken ust uste iki oyun ornegi calismasin.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: AppRoute.orientationGate,
        builder: (context, state) => OrientationGateScreen(
          onReady: () => GoRouter.of(context).goNamed(AppRoute.boot),
        ),
      ),
      GoRoute(
        path: '/boot',
        name: AppRoute.boot,
        builder: (context, state) => const BootScreen(),
      ),
    ],
  );
});
