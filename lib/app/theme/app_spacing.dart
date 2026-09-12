/// Olcu token'lari. 4 px tabanli olcek.
///
/// Ekranlarda ham sayi (`EdgeInsets.all(13)` gibi) kullanilmaz; boylece
/// dikey ritim tutarli kalir ve tasarim revizyonu tek yerden yayilir.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Ekran kenar payi. Tum tam ekran sayfalar bunu kullanir.
  static const double screenGutter = 20;

  /// Dokunma hedefi alt siniri (Material/HIG ortak tavsiyesi).
  /// Savas HUD'undaki butonlar bunun altina inmemeli.
  static const double minTouchTarget = 48;
}

/// Kose yaricaplari.
abstract final class AppRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// Animasyon sureleri (ms).
abstract final class AppDuration {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 400);

  /// Upgrade kartinin alttan yukselme suresi.
  static const Duration cardReveal = Duration(milliseconds: 320);
}
