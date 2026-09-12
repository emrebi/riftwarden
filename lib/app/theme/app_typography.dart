import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';

/// Locale'e gore govde fontu secimi.
///
/// ## Neden gerekli
/// Tek bir font dosyasi Latin + CJK + Tayca + Arapca'yi birden kapsamaz;
/// kapsayanlar (Noto Sans CJK gibi) tek basina 10-20 MB'dir. 15 dil icin
/// hepsini bundle'lamak APK'yi kabul edilemez sisirir.
///
/// ## Cozum
/// Sadece **gosterim** (logo, rakam, baslik) icin tek bir Latin teknoloji
/// fontu bundle'lanir; govde metni icin locale'e gore uygun Noto alt
/// kumesi secilir. Bir locale icin font bundle'lanmadiysa `null` doner ve
/// Flutter sistem fontuna duser — bu KABUL EDILEBILIR bir sonuctur,
/// tofu (kutu karakter) gorunmez.
///
/// ## Eklerken
/// 1. Font dosyasini `assets/fonts/` altina koy.
/// 2. `pubspec.yaml` -> `flutter: fonts:` altina family olarak tanit.
/// 3. Asagidaki [bodyFamilyFor] esleme tablosuna satir ekle.
abstract final class AppFonts {
  /// Gosterim fontu: logo, buyuk rakamlar, ekran basliklari.
  /// Sadece Latin karakter gerektiren yerlerde kullanilir.
  /// TODO(m5): Font bundle'landiginda 'RwDisplay' yapilacak.
  static const String? display = null;

  /// Locale'in yazi sistemine uygun govde fontu.
  /// null = sistem fontu (gecerli ve guvenli varsayilan).
  static String? bodyFamilyFor(Locale locale) {
    // TODO(m5): Noto alt kumeleri bundle'landiginda doldurulacak.
    // Ornek hedef esleme:
    //   ja            -> 'NotoSansJP'
    //   ko            -> 'NotoSansKR'
    //   zh (Hans)     -> 'NotoSansSC'
    //   zh_Hant       -> 'NotoSansTC'
    //   th            -> 'NotoSansThai'
    //   ar            -> 'NotoSansArabic'
    //   digerleri     -> 'NotoSans'
    return null;
  }

  /// Bu locale saga-sola (RTL) mi akiyor.
  /// Flutter bunu kendisi de belirler; burasi UI mantiginda acik kontrol
  /// gerektigi yerler icindir (ornegin ok yonu ceviren animasyonlar).
  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}

/// Tipografi olcegi.
///
/// Gemini UI tasarimi bu olcegi degistirebilir; ekranlar `TextStyle`'i
/// elle kurmaz, buradan okur.
abstract final class AppTypography {
  static const TextStyle _base = TextStyle(
    color: AppColors.textPrimary,
    height: 1.25,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.4,
      );

  static TextStyle get displayMedium => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      );

  static TextStyle get titleLarge =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700);

  static TextStyle get titleMedium =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get bodyLarge => _base.copyWith(fontSize: 15);

  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 13, color: AppColors.textSecondary);

  static TextStyle get label => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      );

  /// HUD sayaclari (Aether, Core HP). Rakam genisligi sabit olmali ki
  /// deger degistikce yazi zipla­masin.
  static TextStyle get numeric => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      );
}
