import 'dart:math' as math;
import 'dart:typed_data';

import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/domain/rules/rules.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Aether kazanci, birlik uretimi (kale yuvasina yerlestirme) ve Aether
/// yetenek dukkani satin almasi.
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
  /// yeni bir kopyasi push edilir (bkz. [_refreshUnitCost]).
  late final Map<String, int> _costs;

  /// Yuva doluluk snapshot'i. `signals.slots`'a sadece bu tablo bir
  /// oncekinden FARKLIYSA yeni liste push edilir (bkz. [_maybePushSlots]).
  /// Farkli olabilir cunku yuva bosaltma [CompactionSystem]'de olur — bu
  /// yuzden bir yuva bosaldiktan sonraki degisiklik EN ERKEN bir sonraki
  /// adimin economy fazinda fark edilir (killsThisStep ile ayni bir-adim
  /// gecikme deseni).
  late Int32List _lastSlotUnitId;

  /// Son yetenek dukkani push'unda kullanilan Aether ve alinan upgrade
  /// sayisi. Ikisi de degismediyse dukkan haritasi yeniden kurulmaz (bkz.
  /// [_maybePushShopOffers]).
  int _lastShopAether = -1;
  int _lastShopTakenCount = -1;

  @override
  void onBattleStart(BattleSimulation sim) {
    final world = sim.world;
    _costs = <String, int>{};
    for (final id in world.content.units.keys) {
      _costs[id] = world.content.unit(id).cost.round();
    }
    sim.signals.unitCosts.value = Map<String, int>.of(_costs);

    _lastSlotUnitId = Int32List(world.slotUnitId.length);
    sim.signals.slots.value = _buildSlotStates(world);

    _lastShopAether = world.aether;
    _lastShopTakenCount = world.takenUpgrades.length;
    sim.signals.abilityShop.value = _buildShopOffers(world);
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

    // 3. Aether yetenek dukkani kuyrugu: UI'dan `buyAbility` ile biriken
    // talepler. Ayni desen (2) ile.
    String? upgradeId;
    while ((upgradeId = world.dequeueAbilityPurchase()) != null) {
      _tryBuyAbility(sim, upgradeId!);
    }

    // 4. Yuva doluluk degisikligi (event) — throttle'a TABI DEGIL, sadece
    // gercekten degisince push edilir.
    _maybePushSlots(sim);

    // 5. HUD'a surekli deger push'u throttle'a tabidir.
    if (sim.isHudPushDue) {
      sim.signals.aether.value = world.aether;
    }
    _maybePushShopOffers(sim);
  }

  void _tryProduceUnit(BattleSimulation sim, String unitId) {
    final world = sim.world;
    final statsIndex = world.unitStatsIndex[unitId];
    if (statsIndex == null) return; // bilinmeyen id (UI hatasi), sessizce dus

    final slotIndex = world.findFreeSlot();
    if (slotIndex < 0) return; // bos yuva yok

    final produced = world.unitProducedCount[unitId] ?? 0;
    final config = world.content.unit(unitId);
    final cost = (config.cost * math.pow(config.costGrowth, produced)).round();
    if (world.aether < cost) return; // yetersiz bakiye, sessizce dus

    final unit = world.units.spawn();
    if (unit == null) return; // birlik havuzu dolu, sessizce dus

    world.aether -= cost;
    world.unitProducedCount[unitId] = produced + 1;
    world.slotUnitId[slotIndex] = unit.id;

    final slotX = world.slotX[slotIndex];
    final slotY = world.slotY[slotIndex];

    unit
      ..configId = unitId
      // Bkz. `SpawnSystem`'daki ayni desen: tablo kurulumda bir kez
      // doldurulur, burasi sicak yolda sadece okur.
      ..spriteIndex = world.unitSpriteIndex[unitId] ?? 0
      ..slotIndex = slotIndex
      ..targetPriority = config.targetPriority
      ..statsIndex = statsIndex
      // Savasci yuvada SABIT durur (bkz. `MovementSystem` P10 yorumu) —
      // x/y bir daha degismez, bu yuzden prevX/prevY de ayni deger.
      ..x = slotX
      ..y = slotY
      ..prevX = slotX
      ..prevY = slotY
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

  /// Bir Aether yetenek dukkani satin alma talebini isler.
  ///
  /// **Alinabilirlik kurali (tasarim karari):** yetenek, oyuncunun o an
  /// sahada o tipten canli bir savascisi olup olmadigina BAKMADAN her
  /// zaman alinabilir. Gerekce: tum ayni tipteki birlikler tek bir
  /// `ResolvedStats` blogunu paylasir (bkz. `UnitEntity.statsIndex`
  /// yorumu) — yetenek o bloga islenir, dolayisiyla hem sahadaki mevcut
  /// hem ileride uretilecek birliklere aninda uygulanir. "En az bir birlik
  /// sahipsen alabilirsin" kurali ekstra bir havuz taramasi ve oyuncuya
  /// "once birlik al, sonra yetenek al" seklinde gereksiz bir sira
  /// dayatmasi getirirdi; hicbir oynanis faydasi yok.
  void _tryBuyAbility(BattleSimulation sim, String upgradeId) {
    final world = sim.world;
    final upgrade = world.content.upgrades[upgradeId];
    // Bilinmeyen id veya kart kaynakli bir upgrade (UI hatasi): sessizce dus.
    if (upgrade == null || upgrade.source != UpgradeSource.shop) return;

    var stacksSoFar = 0;
    for (final taken in world.takenUpgrades) {
      if (taken.id == upgradeId) stacksSoFar++;
    }
    if (stacksSoFar >= upgrade.maxStacks) return;

    for (final requiredId in upgrade.requires) {
      var satisfied = false;
      for (final taken in world.takenUpgrades) {
        if (taken.id == requiredId) {
          satisfied = true;
          break;
        }
      }
      if (!satisfied) return;
    }

    final cost = upgrade.cost ?? 0;
    if (world.aether < cost) return;

    world.aether -= cost;
    world.takenUpgrades.add(upgrade);
    world.rebuildUnitStats(world.takenUpgrades);
  }

  /// Yuva doluluk tablosu degistiyse (uretim veya bir onceki adimin
  /// compaction'inda bosalan yuva) yeni bir liste push eder.
  void _maybePushSlots(BattleSimulation sim) {
    final world = sim.world;
    final slotUnitId = world.slotUnitId;

    var changed = false;
    for (var i = 0; i < slotUnitId.length; i++) {
      if (slotUnitId[i] != _lastSlotUnitId[i]) {
        changed = true;
        break;
      }
    }
    if (!changed) return;

    _lastSlotUnitId.setAll(0, slotUnitId);
    sim.signals.slots.value = _buildSlotStates(world);
  }

  List<SlotState> _buildSlotStates(BattleWorld world) {
    final slotUnitId = world.slotUnitId;
    return List<SlotState>.generate(
      slotUnitId.length,
      (i) => SlotState(
        slotIndex: i,
        unitId: slotUnitId[i] == 0 ? null : slotUnitId[i],
      ),
      growable: false,
    );
  }

  /// Aether bakiyesi veya alinan yetenek sayisi degistiyse (dolayisiyla
  /// `canBuy`/`owned` degismis olabilir) dukkan haritasini yeniden kurar.
  /// `isHudPushDue` ile throttle edilir (bkz. brief kurali).
  void _maybePushShopOffers(BattleSimulation sim) {
    if (!sim.isHudPushDue) return;
    final world = sim.world;
    if (world.aether == _lastShopAether &&
        world.takenUpgrades.length == _lastShopTakenCount) {
      return;
    }
    _lastShopAether = world.aether;
    _lastShopTakenCount = world.takenUpgrades.length;
    sim.signals.abilityShop.value = _buildShopOffers(world);
  }

  Map<String, ShopOffer> _buildShopOffers(BattleWorld world) {
    final offers = <String, ShopOffer>{};
    for (final upgrade in world.content.upgrades.values) {
      if (upgrade.source != UpgradeSource.shop) continue;

      var stacksSoFar = 0;
      for (final taken in world.takenUpgrades) {
        if (taken.id == upgrade.id) stacksSoFar++;
      }

      var requiresMet = true;
      for (final requiredId in upgrade.requires) {
        var satisfied = false;
        for (final taken in world.takenUpgrades) {
          if (taken.id == requiredId) {
            satisfied = true;
            break;
          }
        }
        if (!satisfied) {
          requiresMet = false;
          break;
        }
      }

      final cost = upgrade.cost ?? 0;
      offers[upgrade.id] = ShopOffer(
        upgradeId: upgrade.id,
        unitId: upgrade.unit ?? '',
        cost: cost,
        canBuy: requiresMet && stacksSoFar < upgrade.maxStacks && world.aether >= cost,
        owned: stacksSoFar > 0,
      );
    }
    return offers;
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
