import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';
import 'package:riftwarden/engine/simulation/entities/entities.dart';

/// Havuz sikistirma: `pendingRemove` isaretli varliklari cikarir.
///
/// **Her zaman en son fazda calisir** ([SystemPhase.compaction] enum'un
/// son degeridir). Sebep: swap-remove dizinleri kaydirir; bu adim
/// icindeki UST fazlarin (targeting, movement, combat...) hepsi "bu adim
/// boyunca dizinler sabit kalir" varsayimiyla yazildi. Cikarma daha erken
/// olsaydi ayni adimda calisan bir sonraki sistem yanlis varlik dizinine
/// erisebilirdi.
///
/// Core yenilgi kontrolu de burada yapilir: bu fazdan once calisan
/// [MovementSystem] Core hasarini uygulamis olur, yani `world.coreHp` bu
/// adim icin nihai degerindedir. Burada kontrol etmek, hasarin uygulandigi
/// adimda ayni karede yenilgiye gecilmesini saglar (bir adim gecikmeden).
class CompactionSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.compaction;

  // onRemoved kapatmasi burada BIR KEZ olusturulur (onBattleStart), step()
  // icinde degil — step() icinde closure yaratmak allocation yasagini
  // ihlal eder (bkz. CLAUDE.md kural 4).
  late final BattleWorld _world;
  late final void Function(EnemyEntity) _onEnemyRemoved;

  @override
  void onBattleStart(BattleSimulation sim) {
    _world = sim.world;
    _onEnemyRemoved = (enemy) {
      // Core'a ulasmadan cikan dusman "oldurulmus" demektir. Odulu de
      // burada biriktiriyoruz (bkz. BattleWorld.aetherEarnedThisStep):
      // varlik havuzdan cikmadan hemen once son alan degerlerine (burada
      // `aetherReward`) erismenin tek guvenli yeri bu callback'tir.
      if (!enemy.reachedCore) {
        _world.killsThisStep++;
        _world.aetherEarnedThisStep += enemy.aetherReward;
      }
    };
  }

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;
    world.killsThisStep = 0;
    world.aetherEarnedThisStep = 0;

    world.enemies.compact(_onEnemyRemoved);
    world.units.compact();
    world.projectiles.compact();
    world.effects.compact();

    if (world.coreHp <= 0) {
      sim.finish(BattleOutcome.defeat);
    }

    if (sim.isHudPushDue) {
      sim.signals.enemyCount.value = world.enemies.activeCount;
      final clampedHp = world.coreHp.clamp(0.0, world.coreMaxHp);
      sim.signals.coreHp.value = clampedHp.round();
      sim.signals.coreHpRatio.value =
          world.coreMaxHp <= 0 ? 0 : clampedHp / world.coreMaxHp;
    }
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
