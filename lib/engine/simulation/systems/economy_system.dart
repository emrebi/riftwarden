import 'dart:math' as math;

import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/domain/rules/rules.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';
import 'package:riftwarden/engine/simulation/entities/entities.dart';
import 'package:riftwarden/engine/simulation/systems/movement_system.dart'
    show
        kRangedFrontDistance,
        kSupportFrontDistance,
        kSwarmFrontDistance,
        kTankFrontDistance;

/// Aether kazanci ve birlik uretimi.
///
/// [SystemPhase.economy]: combat'tan SONRA calisir ki bu adimda olen
/// dusmanlarin odulu ayni adimda islensin; compaction'dan ONCE calisir ki
/// bir onceki adimda biriken `BattleWorld.aetherEarnedThisStep` tuketilsin
/// (bkz. o alanin dosya basi yorumu — `killsThisStep` ile ayni desen).
class EconomySystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.economy;

  /// Guncel maliyet onbellegi. `signals.unitCosts`e her kare DEGIL, sadece
  /// bir uretim maliyeti degistiginde (yani bir uretim basarili oldugunda)
  /// yeni bir kopyasi push edilir (bkz. [_pushUnitCosts]).
  late final Map<String, int> _costs;

  @override
  void onBattleStart(BattleSimulation sim) {
    final world = sim.world;
    _costs = <String, int>{};
    for (final id in world.content.units.keys) {
      _costs[id] = world.content.unit(id).cost.round();
    }
    sim.signals.unitCosts.value = Map<String, int>.of(_costs);
  }

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;

    // 1. Bir onceki adimin compaction'inda biriken oldurme odulu.
    if (world.aetherEarnedThisStep > 0) {
      world.aether += world.aetherEarnedThisStep.round();
    }

    // 2. Uretim kuyrugu: UI'dan `requestUnit` ile biriken talepler.
    // Kuyruk sabit kapasiteli oldugu icin bu dongu sinirlidir (allocation
    // yok, sadece kuyruktaki kadar tekrar).
    String? unitId;
    while ((unitId = world.dequeueUnitRequest()) != null) {
      _tryProduceUnit(sim, unitId!);
    }

    // 3. HUD'a surekli deger push'u throttle'a tabidir.
    if (sim.isHudPushDue) {
      sim.signals.aether.value = world.aether;
    }
  }

  void _tryProduceUnit(BattleSimulation sim, String unitId) {
    final world = sim.world;
    final statsIndex = world.unitStatsIndex[unitId];
    if (statsIndex == null) return; // bilinmeyen id (UI hatasi), sessizce dus

    final produced = world.unitProducedCount[unitId] ?? 0;
    final config = world.content.unit(unitId);
    final cost = (config.cost * math.pow(config.costGrowth, produced)).round();
    if (world.aether < cost) return; // yetersiz bakiye, sessizce dus

    final unit = world.units.spawn();
    if (unit == null) return; // birlik havuzu dolu, sessizce dus

    world.aether -= cost;
    world.unitProducedCount[unitId] = produced + 1;

    final role = _parseUnitRole(config.role);
    final frontDistance = _frontDistanceFor(role);
    final spawnY = (world.coreY - frontDistance).clamp(0.0, world.coreY);
    final spawnX = world.coreX;

    unit
      ..configId = unitId
      // Bkz. `SpawnSystem`'daki ayni desen: tablo kurulumda bir kez
      // doldurulur, burasi sicak yolda sadece okur.
      ..spriteIndex = world.unitSpriteIndex[unitId] ?? 0
      ..role = role
      ..statsIndex = statsIndex
      ..x = spawnX
      ..y = spawnY
      // prevX/prevY spawn konumuyla ayni: aksi halde ilk render karesinde
      // birlik (0,0)'dan suzulerek gelir (bkz. SpawnSystem enemy yorumu,
      // ayni render-interpolasyon sorunu).
      ..prevX = spawnX
      ..prevY = spawnY
      // Yeni uretilen birlik hedef aramaya HEMEN degil, stagger sirasina
      // gore baslar (bkz. TargetingSystem dosya basi yorumu ve
      // kTargetingStagger). Boylece toplu uretim (ornegin oyuncu ust uste
      // butona basarsa) tum yeni birlikleri ayni karede hedef aratmaz.
      ..retargetCooldown = (unit.id % kTargetingStagger) * (kRetargetInterval / kTargetingStagger);

    final maxHp = world.resolvedUnitStats[statsIndex].stats[StatId.hp];
    unit
      ..maxHp = maxHp
      ..hp = maxHp;

    _refreshUnitCost(sim, unitId, produced + 1, config);
  }

  void _refreshUnitCost(
    BattleSimulation sim,
    String unitId,
    int newProducedCount,
    UnitConfig config,
  ) {
    final newCost = config.cost * math.pow(config.costGrowth, newProducedCount);
    _costs[unitId] = newCost.round();
    // Yeni Map SADECE burada, bir maliyet gercekten degistiginde
    // olusturulur (bkz. brief kurali: her karede yeni Map yaratma).
    sim.signals.unitCosts.value = Map<String, int>.of(_costs);
  }

  UnitRole _parseUnitRole(String value) => switch (value) {
        'swarm' => UnitRole.swarm,
        'ranged' => UnitRole.ranged,
        'tank' => UnitRole.tank,
        'support' => UnitRole.support,
        _ => throw ArgumentError('EconomySystem: bilinmeyen unit rolu: "$value"'),
      };

  double _frontDistanceFor(UnitRole role) => switch (role) {
        UnitRole.tank => kTankFrontDistance,
        UnitRole.swarm => kSwarmFrontDistance,
        UnitRole.ranged => kRangedFrontDistance,
        UnitRole.support => kSupportFrontDistance,
      };

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
