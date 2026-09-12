import 'dart:convert';

import 'package:riftwarden/core/services/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `SharedPreferences` anahtar adlari.
///
/// Neden ayri sinifta topluyoruz: anahtar stringleri kod icinde dagilirsa
/// yazim hatasi (typo) sessizce yeni bir kayit yaratir, eskisi okunmaz olur.
/// Tek yerden sabit tutmak bunu derleme zamaninda engeller.
abstract final class StorageKeys {
  static const String soundEnabled = 'sound_enabled';
  static const String musicEnabled = 'music_enabled';
  static const String hapticsEnabled = 'haptics_enabled';
  static const String localeCode = 'locale_code';
  static const String saveBlob = 'save_blob';
  static const String saveVersion = 'save_version';
}

/// `SharedPreferences` uzerine tipli, hataya dayanikli sarmalayici.
///
/// Neden dogrudan `SharedPreferences` kullanilmiyor: yazma hatasinda
/// (disk dolu, platform kanal sorunu vb.) exception firlamasi kayit
/// kaybindan cok daha kotu bir kullanici deneyimine yol acar. Bu sinif
/// hatayi yutup `false` doner; oyun kaydetmeden devam eder.
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, {required bool value}) => _guard(
        () => _prefs.setBool(key, value),
        key: key,
      );

  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> setInt(String key, {required int value}) => _guard(
        () => _prefs.setInt(key, value),
        key: key,
      );

  double? getDouble(String key) => _prefs.getDouble(key);

  Future<bool> setDouble(String key, {required double value}) => _guard(
        () => _prefs.setDouble(key, value),
        key: key,
      );

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, {required String value}) => _guard(
        () => _prefs.setString(key, value),
        key: key,
      );

  /// JSON okurken bozuk/eski formatli veri varsa `null` doner; exception
  /// firlatmaz. Kayit dosyasi bozulmus olsa bile uygulama acilmali.
  Map<String, Object?>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
      Log.w('StorageService: "$key" beklenen Map formatinda degil');
      return null;
    } on FormatException catch (error, st) {
      Log.e('StorageService: "$key" JSON decode hatasi', error, st);
      return null;
    }
  }

  Future<bool> setJson(String key, Map<String, Object?> value) => _guard(
        () => _prefs.setString(key, jsonEncode(value)),
        key: key,
      );

  Future<bool> _guard(Future<bool> Function() write, {required String key}) async {
    try {
      return await write();
    } on Exception catch (error, st) {
      Log.e('StorageService: "$key" yazma hatasi', error, st);
      return false;
    }
  }
}
