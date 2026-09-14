import 'package:riftwarden/domain/rules/rules.dart';

/// Ekran sarsintisi: sonumlu (damped) rastgele yer degistirme.
///
/// Normalize alan uzayinda calisir (0..1, bkz. `game_constants.dart`
/// `kFieldWidth`), TUM diger simulasyon degerleriyle ayni birim sistemi.
/// Piksele cevirme render katmaninda `FieldProjection.toScreenSize` ile
/// yapilir (bkz. `RiftwardenGame.render`) — boylece bu sinif tamamen saf
/// Dart kalir ve `BattleWorld` icinde diger simulasyon durumuyla birlikte
/// yasayabilir.
///
/// ## Neden ayri RngSource
/// `BattleWorld.rng` savas mantigi (kritik vurus, dalga planlama) icin
/// kullanilan PAYLASIMLI akistir. Sarsinti her simulasyon adiminda
/// (aktifken) rastgele sayi tuketir; bunu ayni akistan cekmek sarsinti
/// davranisi degistiginde (ornegin siddeti ayarlaninca) mevcut
/// tohumlarla alinmis kritik vurus/dalga sonuclarini KAYDIRIRDI. Ayri bir
/// tohumlu kaynak bu iki kaygiyi birbirinden yalitir; sarsinti yine de
/// deterministiktir (ayni tohumla ayni desen).
class ScreenShake {
  ScreenShake(this._rng);

  final RngSource _rng;

  /// Maksimum yer degistirme, alan genisliginin orani olarak.
  ///
  /// Tasarim kurali "abartma": sarsinti swarm'i takip eden goze rehberlik
  /// eden okunabilirligi bozmamali. %2 ekran genisligi, hissedilir ama
  /// hedefleme/tiklama hassasiyetini bozmayan bir tavan olarak secildi.
  static const double kMaxOffset = 0.02;

  double _intensity = 0;
  double _duration = 0;
  double _elapsed = 0;

  /// Bu karede uygulanacak normalize kaydirma. Render `toScreenSize` ile
  /// piksele cevirir.
  double offsetX = 0;
  double offsetY = 0;

  /// Sarsintiyi tetikler/yeniler.
  ///
  /// Halihazirda daha guclu bir sarsinti suruyorsa yeni (daha zayif) istek
  /// yok sayilir — ust uste tetiklenen kucuk sarsintilar buyugunu
  /// KESMEMELI (ornegin arka arkaya vurus efektleri Core hasarinin
  /// sarsintisini erken bitirmesin).
  void trigger(double intensity, double duration) {
    final stillShaking = _elapsed < _duration;
    if (stillShaking && intensity < _intensity) return;
    _intensity = intensity;
    _duration = duration;
    _elapsed = 0;
  }

  /// [EffectSystem] tarafindan her sabit adimda cagrilir (bkz. o dosyanin
  /// dosya basi yorumu). Sarsinti bitmisse rng TUKETILMEZ — boylece
  /// sarsinti hic tetiklenmemis bir savasta rng akisina hicbir etkisi
  /// olmaz.
  void update(double dt) {
    if (_elapsed >= _duration) {
      offsetX = 0;
      offsetY = 0;
      return;
    }
    _elapsed += dt;
    final decay = 1 - (_elapsed / _duration).clamp(0.0, 1.0);
    final magnitude = (_intensity > kMaxOffset ? kMaxOffset : _intensity) * decay;
    offsetX = (_rng.nextDouble() * 2 - 1) * magnitude;
    offsetY = (_rng.nextDouble() * 2 - 1) * magnitude;
  }
}
