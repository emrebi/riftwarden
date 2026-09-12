import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:riftwarden/core/services/log.dart';
import 'package:riftwarden/core/services/storage_service.dart';

/// SFX/muzik oynatma sarmalayicisi.
///
/// KRITIK: `assets/audio/` su an bos. Dosya bulunamadiginda `flame_audio`
/// exception firlatir; bu servis o hatayi yutar ve loglar, boylece eksik
/// ses dosyasi oyunun acilisini veya akisini asla durdurmaz.
class AudioService {
  StorageService? _storage;
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> init(StorageService storage) async {
    _storage = storage;
    _soundEnabled = storage.getBool(StorageKeys.soundEnabled) ?? true;
    _musicEnabled = storage.getBool(StorageKeys.musicEnabled) ?? true;
  }

  Future<void> playSfx(String name) async {
    if (!_soundEnabled) {
      return;
    }
    try {
      await FlameAudio.play(name);
    } on Exception catch (error, st) {
      Log.e('AudioService: sfx "$name" oynatilamadi', error, st);
    }
  }

  Future<void> playMusic(String name) async {
    if (!_musicEnabled) {
      return;
    }
    try {
      await FlameAudio.bgm.play(name);
    } on Exception catch (error, st) {
      Log.e('AudioService: muzik "$name" oynatilamadi', error, st);
    }
  }

  Future<void> stopMusic() async {
    try {
      await FlameAudio.bgm.stop();
    } on Exception catch (error, st) {
      Log.e('AudioService: muzik durdurulamadi', error, st);
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _persist(StorageKeys.soundEnabled, enabled);
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    _persist(StorageKeys.musicEnabled, enabled);
    if (!enabled) {
      // Kapatinca calan muzigi de kesmemiz gerek, yoksa "kapali" durum
      // gorsel/ses tutarsizligina yol acar.
      unawaited(stopMusic());
    }
  }

  /// Tercihi diske yazar. Beklemiyoruz: ayar anahtari cevrildiginde
  /// arayuz diski beklememeli. Yazma hatasi StorageService icinde
  /// loglanip yutuluyor, en kotu ihtimalle tercih bir sonraki aciliste
  /// varsayilana doner.
  void _persist(String key, bool value) {
    final storage = _storage;
    if (storage == null) {
      return;
    }
    unawaited(storage.setBool(key, value: value));
  }
}
