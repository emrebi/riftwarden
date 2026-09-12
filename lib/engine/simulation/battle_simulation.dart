import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';

/// Simulasyonun calisma durumu.
enum SimulationMode {
  /// Normal hizda kosuyor.
  running,

  /// Upgrade karti aciliyor — zaman olcegi rampa ile dusuyor.
  slowing,

  /// Tamamen durdu (upgrade secimi, pause menusu, sonuc ekrani).
  paused,

  /// Savas bitti; artik adim atilmiyor.
  finished,
}

/// Savasin sabit adimli kalbi.
///
/// ## Tasarim kurali: simulasyon Flame'i bilmez
/// Bu sinif ve altindaki her sey duz Dart'tir. `flame`, `flutter` veya
/// widget import'u YOKTUR. Render katmani ([engine/render]) bu durumu
/// sadece OKUR. Bu ayrim sayesinde:
///   * yuzlerce dusman component maliyeti odemeden simule edilir,
///   * simulasyon deterministiktir ve testte cihazsiz kosturulabilir,
///   * gorsel degisiklikler oynanisi bozamaz.
///
/// ## Sabit adim (fixed timestep)
/// Render fps'i ne olursa olsun simulasyon [kFixedTimeStep] adimlariyla
/// ilerler. Artan zaman [_accumulator]'de birikir. Render iki adim arasini
/// [alpha] ile interpole eder, bu yuzden 60'in altinda da akici gorunur.
///
/// Cihaz takilirsa bir karede en fazla [kMaxStepsPerFrame] adim kapatilir;
/// fazlasi ATILIR. Bu bilincli bir tercihtir: birikmis zamani kovalamak
/// "olum sarmali"na (her kare daha cok is -> daha yavas -> daha cok is)
/// yol acar. Oyun yavaslar ama donmaz.
class BattleSimulation {
  BattleSimulation({required this.signals});

  /// Motordan HUD'a giden koprü. Simulasyon buraya YAZAR, okumaz.
  final BattleSignals signals;

  final List<BattleSystem> _systems = <BattleSystem>[];

  double _accumulator = 0;
  double _timeScale = 1;
  double _slowMoElapsed = 0;
  SimulationMode _mode = SimulationMode.paused;

  /// Savas basindan beri gecen simule edilmis sure (saniye).
  /// Duvar saati DEGILDIR; pause ve yavaslatma bunu etkiler.
  double elapsed = 0;

  /// Kapatilan toplam sabit adim sayisi. Deterministik rastgelelik
  /// (seeded RNG) ve zamanlama testleri bunu kullanir.
  int tick = 0;

  SimulationMode get mode => _mode;

  /// Son adim ile bir sonraki adim arasindaki ilerleme (0..1).
  /// Render `lerp(prev, current, alpha)` icin bunu kullanir.
  double get alpha => (_accumulator / kFixedTimeStep).clamp(0.0, 1.0);

  /// HUD throttle sayaci; [kHudThrottleInterval] doldugunda true doner
  /// ve sifirlanir. Sistemler surekli degerleri sadece bu true iken push eder.
  double _hudTimer = 0;
  bool _hudDue = false;
  bool get isHudPushDue => _hudDue;

  /// Sistemleri faz sirasina gore kaydeder.
  ///
  /// Ekleme sirasi onemsizdir; [SystemPhase] enum sirasi baglayicidir.
  /// Ayni fazda birden fazla sistem varsa ekleme sirasi korunur.
  void registerSystems(Iterable<BattleSystem> systems) {
    _systems
      ..addAll(systems)
      ..sort((a, b) => a.phase.index.compareTo(b.phase.index));
  }

  /// Savasi baslatir. [registerSystems] bundan once cagrilmis olmali.
  void start() {
    elapsed = 0;
    tick = 0;
    _accumulator = 0;
    _timeScale = 1;
    _slowMoElapsed = 0;
    _hudTimer = 0;
    signals.reset();
    for (final system in _systems) {
      system.onBattleStart(this);
    }
    _mode = SimulationMode.running;
  }

  /// Flame'in `update(dt)`'inden cagrilir. [rawDt] gercek kare suresidir.
  void advance(double rawDt) {
    if (_mode == SimulationMode.paused || _mode == SimulationMode.finished) {
      return;
    }

    if (_mode == SimulationMode.slowing) {
      _slowMoElapsed += rawDt;
      final t = (_slowMoElapsed / kUpgradeSlowMoRamp).clamp(0.0, 1.0);
      _timeScale = 1 - (1 - kUpgradeSlowMoScale) * t;
      if (t >= 1) {
        _mode = SimulationMode.paused;
        return;
      }
    }

    _accumulator += rawDt * _timeScale;

    var steps = 0;
    while (_accumulator >= kFixedTimeStep && steps < kMaxStepsPerFrame) {
      _stepOnce();
      _accumulator -= kFixedTimeStep;
      steps++;
    }

    // Tavana vurduysak birikmis fazla zamani at (olum sarmali korumasi).
    if (steps >= kMaxStepsPerFrame && _accumulator > kFixedTimeStep) {
      _accumulator = 0;
    }
  }

  void _stepOnce() {
    _hudTimer += kFixedTimeStep;
    _hudDue = _hudTimer >= kHudThrottleInterval;
    if (_hudDue) _hudTimer = 0;

    for (var i = 0; i < _systems.length; i++) {
      _systems[i].step(this, kFixedTimeStep);
    }

    elapsed += kFixedTimeStep;
    tick++;
  }

  /// Upgrade karti icin yavaslatma rampasini baslatir; rampa bitince
  /// [SimulationMode.paused]'a gecer.
  void beginSlowMotionPause() {
    if (_mode != SimulationMode.running) return;
    _mode = SimulationMode.slowing;
    _slowMoElapsed = 0;
  }

  /// Menu pause'u — rampasiz, aninda durur.
  void pause() {
    if (_mode == SimulationMode.finished) return;
    _mode = SimulationMode.paused;
  }

  void resume() {
    if (_mode == SimulationMode.finished) return;
    _mode = SimulationMode.running;
    _timeScale = 1;
    _slowMoElapsed = 0;
    // Pause suresince birikmis zamani atiyoruz; aksi halde devam eder
    // etmez birkac adim birden kosar ve oyuncu "isinlanma" gorur.
    _accumulator = 0;
  }

  /// Savasi sonlandirir ve sonucu HUD'a bildirir.
  void finish(BattleOutcome outcome) {
    if (_mode == SimulationMode.finished) return;
    _mode = SimulationMode.finished;
    for (final system in _systems) {
      system.onBattleEnd(this);
    }
    signals.outcome.value = outcome;
  }
}
