import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';

/// Dalga ilerlemesini HUD'a bildirir ve zafer kosulunu denetler.
///
/// [SystemPhase.wave] en ilk fazdir: bu sistem calistiginda bir onceki
/// adimin [SystemPhase.compaction]'i zaten bitmis olur, yani "sahada
/// canli dusman var mi" sorusu bu adim icin guvenilir bir cevaba sahiptir.
/// Zafer kontrolunu buraya koymamizin sebebi budur — spawn/movement'tan
/// once, temiz bir baslangic noktasinda.
class WaveSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.wave;

  /// Son HUD'a yazilan dalga indeksi. Ayni degeri tekrar tekrar
  /// [WaveProgress] nesnesi olusturup yazmamak icin (adim 10a kurali:
  /// gereksiz nesne uretme).
  int _lastReportedWaveIndex = -1;

  @override
  void onBattleStart(BattleSimulation sim) {
    _lastReportedWaveIndex = -1;
  }

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;
    final schedule = world.spawnSchedule;
    final totalWaves = world.level.waves.length;

    if (sim.isHudPushDue && totalWaves > 0) {
      final currentWaveIndex = world.nextSpawnIndex < schedule.length
          ? schedule[world.nextSpawnIndex].waveIndex
          : totalWaves - 1;

      if (currentWaveIndex != _lastReportedWaveIndex) {
        _lastReportedWaveIndex = currentWaveIndex;
        // Sema'da dalga basina "bu bir boss dalgasi" alani yok. Makul
        // yaklasim: level'in bir boss'u varsa, o boss son dalgada cikar
        // (tasarim kurallarinin geri kalaninda da boyle varsayiliyor).
        final isBossWave =
            world.level.boss != null && currentWaveIndex == totalWaves - 1;
        sim.signals.wave.value = WaveProgress(
          current: currentWaveIndex + 1,
          total: totalWaves,
          isBossWave: isBossWave,
        );
      }
    }

    final scheduleExhausted = world.nextSpawnIndex >= schedule.length;
    if (scheduleExhausted && world.enemies.activeCount == 0) {
      sim.finish(BattleOutcome.victory);
    }
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
