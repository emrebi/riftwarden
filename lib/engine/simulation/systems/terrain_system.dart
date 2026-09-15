import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Arazi alan etkilerini (slow, cover) her dusman icin yeniden hesaplar.
///
/// [SystemPhase.terrain]: targeting'den sonra, hareket/hasar hesabindan
/// once (bkz. `SystemPhase.terrain` dosya basi yorumu). Pathfinding YOKTUR
/// — sadece [EnemyEntity.slowFactor]/[EnemyEntity.damageTakenMul] yazilir,
/// `MovementSystem`/`CombatSystem`/`AbilitySystem` bunlari OKUR.
///
/// Alan sayisi kucuk (`docs/CONTENT_SCHEMA.md`: level basina <= 8 kabul
/// edilir), bu yuzden dusman x alan O(n*k) taramasi kabul edilebilir;
/// allocation yoktur, sadece skaler karsilastirma.
class TerrainSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.terrain;

  @override
  void onBattleStart(BattleSimulation sim) {}

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;
    final enemies = world.enemies;
    final terrainCount = world.terrainType.length;

    for (var i = 0; i < enemies.activeCount; i++) {
      final enemy = enemies[i];
      if (enemy.pendingRemove) continue;

      var slowFactor = 1.0;
      var damageTakenMul = 1.0;

      for (var t = 0; t < terrainCount; t++) {
        final dx = enemy.x - world.terrainX[t];
        final dy = enemy.y - world.terrainY[t];
        final radius = world.terrainRadius[t];
        if (dx * dx + dy * dy > radius * radius) continue;

        final value = world.terrainValue[t];
        if (world.terrainType[t] == kTerrainTypeSlow) {
          if (value < slowFactor) slowFactor = value;
        } else {
          if (value < damageTakenMul) damageTakenMul = value;
        }
      }

      enemy.slowFactor = slowFactor;
      enemy.damageTakenMul = damageTakenMul;
    }
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
