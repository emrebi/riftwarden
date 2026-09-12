import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// Cok kucuk log sarmalayicisi.
///
/// Neden dogrudan `debugPrint` kullanmiyoruz: ileride crash reporting
/// (ornegin Sentry/Crashlytics) bu tek noktaya baglanacak; cagri
/// yerlerini o zaman degistirmemek icin simdiden sarmalayici var.
abstract final class Log {
  static void d(String message) {
    if (kDebugMode) {
      debugPrint('[D] $message');
    }
  }

  static void i(String message) {
    if (kDebugMode) {
      debugPrint('[I] $message');
    }
  }

  static void w(String message, [Object? error, StackTrace? st]) {
    if (kDebugMode) {
      debugPrint('[W] $message${error != null ? ' | $error' : ''}');
    }
  }

  static void e(String message, [Object? error, StackTrace? st]) {
    if (kDebugMode) {
      debugPrint('[E] $message${error != null ? ' | $error' : ''}');
      if (st != null) {
        debugPrint(st.toString());
      }
    }
    // TODO(crash-reporting): release'te de en azindan hata seviyesi
    // burada bir crash reporting servisine gonderilecek.
  }
}
