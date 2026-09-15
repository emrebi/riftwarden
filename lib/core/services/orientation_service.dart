import 'package:flutter/services.dart';

/// Ekran yonu kilidi.
///
/// Uygulama acilista dikey de serbesttir (manifest `fullUser`,
/// plist portrait+landscape); yon kapisi (`orientation_gate`) kullanicinin
/// telefonu yatirmasi ya da 10 saniye dolmasiyla yataya kilitler.
class OrientationService {
  /// Sadece yatay iki yon serbest kalir.
  Future<void> lockLandscape() => SystemChrome.setPreferredOrientations(
        const <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );

  /// Dikey ve yatay serbest. Sadece yon kapisi acikken kullanilir.
  Future<void> allowPortraitAndLandscape() =>
      SystemChrome.setPreferredOrientations(
        const <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
}
