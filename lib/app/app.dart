import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riftwarden/app/router/app_router.dart';
import 'package:riftwarden/app/theme/app_theme.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

/// Secili dil. `null` = sistem dilini takip et (varsayilan).
///
/// Oyuncu Ayarlar'dan acikca bir dil secerse bu deger dolar ve kalici
/// olarak saklanir. Sistem dili desteklenmiyorsa Flutter otomatik olarak
/// [AppLocalizations.supportedLocales] icindeki ilk uyumluya, o da yoksa
/// Ingilizce'ye duser.
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  /// [locale] null verilirse sistem diline geri doner.
  void setLocale(Locale? locale) {
    state = locale;
    // TODO(adim 17): SettingsRepository'ye yaz.
  }
}

class RiftwardenApp extends ConsumerWidget {
  const RiftwardenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // Baslik store'da gorunmez; gorev yoneticisi/son kullanilanlar icin.
      title: 'Riftwarden',
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Tema locale'e bagli: govde fontu yazi sistemine gore secilir.
      theme: AppTheme.build(locale ?? const Locale('en')),

      builder: (context, child) {
        // Sistem yazi boyutu olcegini sinirla. Oyun HUD'u sabit duzenli;
        // %130'un ustunde olcek butonlari tasirir ve savas okunmaz olur.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
