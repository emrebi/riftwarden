import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riftwarden/core/services/audio_service.dart';
import 'package:riftwarden/core/services/haptic_service.dart';
import 'package:riftwarden/core/services/storage_service.dart';

/// Servis provider'lari.
///
/// Gercek ornekler burada degil, `bootstrap()` ile `main()` icinde
/// olusturulur ve `ProviderScope.overrides` ile enjekte edilir. Buradaki
/// govde asla calismamali; calisirsa bootstrap'in override etmedigini
/// gosterir, bu yuzden acikca `UnimplementedError` firlatir.
final Provider<StorageService> storageServiceProvider = Provider<StorageService>(
  (ref) => throw UnimplementedError('bootstrap tarafindan override edilmeli'),
);

final Provider<AudioService> audioServiceProvider = Provider<AudioService>(
  (ref) => throw UnimplementedError('bootstrap tarafindan override edilmeli'),
);

final Provider<HapticService> hapticServiceProvider = Provider<HapticService>(
  (ref) => throw UnimplementedError('bootstrap tarafindan override edilmeli'),
);
