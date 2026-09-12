import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riftwarden/core/services/log.dart';
import 'package:riftwarden/core/services/storage_service.dart';

/// Titresim geri bildirimi sarmalayicisi.
///
/// Neden ek paket eklemiyoruz: Flutter'in kendi `HapticFeedback` API'si
/// tum ihtiyaci karsiliyor; isimler donanim yogunlugu yerine oyun
/// olaylarina gore verildi (`impact`, `selection` gibi) ki cagri
/// yerlerinde "hangi titresim" degil "hangi olay" dusunulsun.
class HapticService {
  StorageService? _storage;
  bool _enabled = true;

  bool get enabled => _enabled;

  Future<void> init(StorageService storage) async {
    _storage = storage;
    _enabled = storage.getBool(StorageKeys.hapticsEnabled) ?? true;
  }

  /// Tercihi diske yazar ama beklemez: ayar anahtari cevrildiginde arayuz
  /// diski beklememeli. Yazma hatasi StorageService icinde yutuluyor.
  void setEnabled(bool enabled) {
    _enabled = enabled;
    final storage = _storage;
    if (storage != null) {
      unawaited(storage.setBool(StorageKeys.hapticsEnabled, value: enabled));
    }
  }

  Future<void> light() => _trigger(HapticFeedback.lightImpact);

  Future<void> medium() => _trigger(HapticFeedback.mediumImpact);

  Future<void> heavy() => _trigger(HapticFeedback.heavyImpact);

  Future<void> selection() => _trigger(HapticFeedback.selectionClick);

  /// Ana oyun olaylari (vurus, hasar alma) icin varsayilan titresim.
  Future<void> impact() => _trigger(HapticFeedback.mediumImpact);

  Future<void> _trigger(Future<void> Function() call) async {
    if (!_enabled) {
      return;
    }
    try {
      await call();
    } on Exception catch (error, st) {
      Log.e('HapticService: titresim tetiklenemedi', error, st);
    }
  }
}
