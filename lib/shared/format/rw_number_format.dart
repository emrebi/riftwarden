import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

/// HUD ve maliyet metinleri icin locale'e duyarli sayi bicimlendirme.
///
/// Sadece yardimci fonksiyonlar barindirir; hicbir cagri yeri henuz bunu
/// kullanmiyor (UI-15/UI-16/BATTLE-* bunu ekleyecek).
abstract final class RwNumberFormat {
  // NumberFormat kurulumu locale verisini parse eder; HUD sayaclari ~100 ms'de
  // bir guncellenir, bu yuzden her cagrida yeni NumberFormat olusturmak yerine
  // (locale etiketi + tur) anahtariyla tek seferlik olusturup onbellekte tutuyoruz.
  static final Map<String, NumberFormat> _cache = <String, NumberFormat>{};

  static NumberFormat _cached(String kind, String localeTag, NumberFormat Function() create) {
    final key = '$kind:$localeTag';
    return _cache.putIfAbsent(key, create);
  }

  // `Locale('ar')` (ulke kodsuz) intl'de Bati (Latin) rakamlarini uretiyor;
  // gercek Arapca-Hint rakamlarini almak icin CLDR'da 'ar_EG' gibi ulke
  // etiketli bir varyant gerekiyor. Uygulama ARB'lerinde bolge kodu olmadan
  // sade 'ar' kullanildigindan, burada rakam bicimi icin ozel olarak 'ar_EG'ye
  // yonlendiriyoruz; bu yalnizca sayi sembol tablosunu etkiler, tarih/metin
  // yerellestirmesini degistirmez.
  static String _numberLocaleTag(Locale locale) {
    if (locale.languageCode == 'ar' && (locale.countryCode == null || locale.countryCode!.isEmpty)) {
      return 'ar_EG';
    }
    return locale.toLanguageTag();
  }

  /// Gruplu tam sayi (orn. 1.250 / 1,250 / ١٬٢٥٠).
  static String integer(int value, Locale locale) {
    final tag = _numberLocaleTag(locale);
    final format = _cached('integer', tag, () => NumberFormat.decimalPattern(tag));
    return format.format(value);
  }

  /// Kisa (sikistirilmis) gosterim, orn. 12K — dar HUD alani icin.
  static String compact(int value, Locale locale) {
    final tag = _numberLocaleTag(locale);
    final format = _cached('compact', tag, () => NumberFormat.compact(locale: tag));
    return format.format(value);
  }

  /// Tek ondalikli saniye gosterimi (orn. 2.5) — bekleme suresi etiketleri icin.
  static String seconds(double value, Locale locale) {
    final tag = _numberLocaleTag(locale);
    final format = _cached('seconds', tag, () => NumberFormat.decimalPatternDigits(locale: tag, decimalDigits: 1));
    return format.format(value);
  }
}
