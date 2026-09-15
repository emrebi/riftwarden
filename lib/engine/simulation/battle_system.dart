import 'package:riftwarden/engine/simulation/battle_simulation.dart';

/// Simulasyonun bir asamasi.
///
/// Sistemler **sirasi onemli** olacak sekilde calisir; sira
/// [SystemPhase] ile sabitlenmistir. Yeni bir sistem eklerken hangi
/// faza girdigine karar vermek, kodu nereye koydugundan daha onemlidir.
abstract class BattleSystem {
  /// Bu sistemin hangi fazda kosacagi.
  SystemPhase get phase;

  /// Savas basladiginda bir kez. Scratch tamponlari burada ayrilir —
  /// [step] icinde allocation yapilmamalidir.
  void onBattleStart(BattleSimulation sim) {}

  /// Sabit adim. [dt] her zaman `kFixedTimeStep`tir (yavaslatma zaten
  /// adim SAYISINI degistirir, adim SURESINI degil — determinizm icin).
  void step(BattleSimulation sim, double dt);

  /// Savas bittiginde bir kez.
  void onBattleEnd(BattleSimulation sim) {}
}

/// Sistem calisma sirasi. Enum sirasi = calisma sirasi.
///
/// Bu siralamayi degistirmek oyun davranisini degistirir; her fazin
/// neden orada oldugu asagida yazili.
enum SystemPhase {
  /// Dalga zamanlayicisi: sirada ne var, ne zaman spawn edilecek.
  wave,

  /// Varliklarin havuzdan alinip alana konmasi.
  /// Grid'den ONCE olmali ki yeni dogan dusman ayni adimda gorulebilsin.
  spawn,

  /// Spatial grid'lerin yeniden kurulmasi.
  /// Spawn'dan SONRA, hedefleme/hareketten ONCE. Bu fazda grid disinda
  /// hicbir sey degismemeli.
  spatialIndex,

  /// Hedef secimi. Grid kurulduktan sonra, hareketten once — birlik
  /// hedefine dogru ayni adimda donebilsin.
  targeting,

  /// Konum guncellemeleri (dusman hareketi, separation, mermi ucusu).
  movement,

  /// Saldiri, hasar, olum isaretleme. Hareketten SONRA: menzil kontrolu
  /// guncel konuma gore yapilsin.
  combat,

  /// Oyuncunun aktif yetenegi.
  ability,

  /// Boss faz makinesi ve ozel mekanikleri.
  boss,

  /// Aether kazanci, upgrade esikleri, XP.
  /// Combat'tan SONRA: bu adimda olenlerin odulu ayni adimda islensin.
  economy,

  /// Parcacik, hasar sayisi, ekran sarsintisi, haptic tetikleri.
  /// Gorsel; simulasyon sonucunu DEGISTIRMEMELI.
  effects,

  /// Havuz sikistirma (`pendingRemove` isaretlilerin cikarilmasi).
  /// **Her zaman en sonda.** Bu kural sayesinde tum ust fazlar dizinlerin
  /// kaymayacagina guvenebilir.
  compaction,
}
