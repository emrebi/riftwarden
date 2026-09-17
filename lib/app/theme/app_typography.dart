import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart' show AppMaterial, AppMaterials;

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
  ///
  /// Dekoratif gosterim fontu hicbir zaman lokalize metnin TEK okunabilir
  /// yolu olamaz (DESIGN §5). Bu alan dolsa bile kritik/govde metni bu fonta
  /// bagimli kalmamalidir.
  /// Lilita One sadece Latin kapsar, eksik glifler platform fontuna duser.
  static const String display = 'RwDisplay';

  /// Locale'in yazi sistemine uygun govde fontu.
  /// null = sistem fontu (gecerli ve guvenli varsayilan).
  /// CJK fontlari boyut karari (47 MB) nedeniyle bundle edilmedi,
  /// sistem fontuna duser (FONT-01).
  static String? bodyFamilyFor(Locale locale) => switch (locale.languageCode) {
        'ar' => 'NotoSansArabic',
        'th' => 'NotoSansThai',
        // CJK dosyalari 47 MB oldugu icin bundle edilmedi; sistem fontuna duser.
        'ja' || 'ko' || 'zh' => null,
        _ => 'Nunito',
      };

  /// Bu locale saga-sola (RTL) mi akiyor.
  /// Flutter bunu kendisi de belirler; burasi UI mantiginda acik kontrol
  /// gerektigi yerler icindir (ornegin ok yonu ceviren animasyonlar).
  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}

/// Tipografi olcegi.
///
/// Gorsel otorite `docs/DESIGN.md` §5 (typography). Ekranlar `TextStyle`'i
/// elle kurmaz, buradan okur. El yapimi cizgi film UI'si icin rol adlari
/// DESIGN §5 ile birebir eslenir: `screenTitle`, `sectionTitle`, `button`,
/// `smallLabel`, `numeric`. Eski `displayLarge`/`displayMedium`/`titleLarge`/
/// `titleMedium`/`label` cagiran yerler bozulmasin diye korunur.
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

  /// LEGACY tracking: genis `letterSpacing` neon-yon kalintisi. Yeni UI
  /// [smallLabel] kullanir; bu getter sadece mevcut cagiricilar icin durur.
  static TextStyle get label => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      );

  /// Number/resource counter (DESIGN §5): HUD sayaclari (Aether, Core HP).
  /// Rakam genisligi sabit olmali ki deger degistikce yazi zipla­masin.
  static TextStyle get numeric => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      );

  /// Screen title (DESIGN §5): kalin, kompakt, yuksek kontrast. `displayMedium`
  /// (28) ile `titleLarge` (20) arasindaki tek ara basamak `displayMedium`
  /// boyutunu paylasir; asil fark agirlikta degil DESIGN'in "compact"
  /// beklentisinde — letterSpacing `displayMedium`'dan dar tutulur ki
  /// ekran basligi govde metniyle ayni ailede ama daha sikisik dursun.
  static TextStyle get screenTitle => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      );

  /// Section title (DESIGN §5): kisa, firm; zorunlu buyuk harf veya genis
  /// tracking YOK (bazi yazi sistemlerinde okunabilirligi bozar). `titleMedium`
  /// ile ayni boyut, biraz daha agir kalinlik ile ayrisir.
  static TextStyle get sectionTitle =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  /// Button (DESIGN §5, §23 "critical controls near 16 dp"): kalin, kompakt,
  /// agresif tracking veya zorlama olcekleme yok.
  static TextStyle get button =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  /// Small label (DESIGN §5): metadata/durum/altyazi icin. Mevcut [label]
  /// boyutunun (11) altina inmez (DESIGN §23 "asagina inme" kurali);
  /// zorunlu buyuk harf veya genis tracking uygulamaz.
  static TextStyle get smallLabel => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  /// Verilen stili [material] yuzeyinin birincil metin rengine tasir.
  /// Allocation `copyWith` ile sinirli; yeni nesne yaratmaz.
  static TextStyle onMaterial(TextStyle style, AppMaterial material) =>
      style.copyWith(color: AppMaterials.text(material));

  /// Verilen stili [material] yuzeyinin ikincil (soluk) metin rengine tasir.
  static TextStyle onMaterialSecondary(TextStyle style, AppMaterial material) =>
      style.copyWith(color: AppMaterials.textSecondary(material));
}
