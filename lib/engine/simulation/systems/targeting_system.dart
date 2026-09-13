import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/domain/rules/rules.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';

/// Birliklerin hedef secimi.
///
/// [SystemPhase.targeting]: spatial grid kurulduktan (spawn + spatialIndex)
/// hemen sonra, hareketten ONCE calisir ki bir birlik o adim icinde yeni
/// hedefine dogru donebilsin.
///
/// Her birlik HER KAREDE hedef aramaz — bu pahali olur ve gereksizdir.
/// `UnitEntity.retargetCooldown` [kRetargetInterval] ile geri sayar; sifira
/// inince tazelenir. Baslangic degeri (uretim aninda, bkz. EconomySystem)
/// `unit.id % kTargetingStagger` ile kaydirilir; boylece TUM birlikler ayni
/// karede degil, farkli karelere yayilarak hedef arar ve is yuku duzlesir.
class TargetingSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.targeting;

  @override
  void onBattleStart(BattleSimulation sim) {}

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;
    final units = world.units;
    final enemies = world.enemies;
    final grid = world.enemyGrid;

    for (var i = 0; i < units.activeCount; i++) {
      final unit = units[i];
      if (unit.pendingRemove) continue;

      unit.retargetCooldown -= dt;
      if (unit.retargetCooldown > 0) continue;
      // Sabit `=` yerine `+=` kullaniliyor: dt'nin kRetargetInterval'i tam
      // bolmedigi durumlarda birikmis fazla/eksik sure zamanla telafi
      // edilir, uzun vadede surunme (drift) olusmaz.
      unit.retargetCooldown += kRetargetInterval;

      final range = world.resolvedUnitStats[unit.statsIndex].stats[StatId.range];

      // Mevcut hedef hala gecerli mi? Sicak yolda ucuz kontrol: dizin
      // ipucunu dogrula (id eslesirse), tutuyorsa ve menzildeyse yeniden
      // ARAMA YAPMA (bkz. UnitEntity.targetIndexHint sozlesmesi).
      if (unit.targetId != 0) {
        final hint = unit.targetIndexHint;
        if (hint >= 0 && hint < enemies.activeCount && enemies[hint].id == unit.targetId) {
          final enemy = enemies[hint];
          final dx = enemy.x - unit.x;
          final dy = enemy.y - unit.y;
          if (dx * dx + dy * dy <= range * range) continue;
        }
      }

      final found = grid.queryNearest(unit.x, unit.y, range);
      if (found < 0) {
        unit.targetId = 0;
        unit.targetIndexHint = -1;
      } else {
        unit.targetId = enemies[found].id;
        unit.targetIndexHint = found;
      }
    }
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
