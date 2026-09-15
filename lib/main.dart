import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riftwarden/app/app.dart';
import 'package:riftwarden/app/bootstrap.dart';
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/core/services/service_providers.dart';

/// Uygulama girisi.
///
/// Burada IS YAPILMAZ. Tum baslatma sirasi [bootstrap] icindedir; burasi
/// sadece sonucu provider override'larina baglar.
Future<void> main() async {
  final boot = await bootstrap();

  runApp(
    ProviderScope(
      // Riverpod 3'te `Override` tipi public API'da degildir; liste tipi
      // parametreden cikarilir, bu yuzden acik tip argumani YAZILMAZ.
      overrides: [
        storageServiceProvider.overrideWithValue(boot.storage),
        audioServiceProvider.overrideWithValue(boot.audio),
        hapticServiceProvider.overrideWithValue(boot.haptics),
        orientationServiceProvider.overrideWithValue(boot.orientation),
        contentRegistryProvider.overrideWithValue(boot.content),
      ],
      child: const RiftwardenApp(),
    ),
  );
}
