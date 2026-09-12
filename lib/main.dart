import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riftwarden/app/app.dart';
import 'package:riftwarden/app/bootstrap.dart';

/// Uygulama girisi.
///
/// Burada IS YAPILMAZ. Tum baslatma sirasi [bootstrap] icindedir; burasi
/// sadece sonucu provider override'larina baglar.
Future<void> main() async {
  // ignore: unused_local_variable
  final boot = await bootstrap();

  runApp(
    const ProviderScope(
      // Servisler eklendikce override'lar buraya yazilir, ornegin:
      //   sharedPreferencesProvider.overrideWithValue(boot.preferences),
      // Not: Riverpod 3'te `Override` tipi public API'da degildir; liste
      // tipi parametreden cikarilir, bu yuzden acik tip argumani YAZILMAZ.
      overrides: [
        // TODO(adim 3): storage
        // TODO(adim 6): icerik
      ],
      child: RiftwardenApp(),
    ),
  );
}
