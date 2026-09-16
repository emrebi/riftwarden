import 'package:riftwarden/engine/effects/effect_pool_system.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/systems/systems.dart';

/// Bir savasin varsayilan sistem setini kurar.
///
/// [BattleSimulation.registerSystems] ekleme sirasini degil [SystemPhase]
/// enum sirasini baglayici sayar; buradaki sira sadece okunabilirlik
/// icindir. 10b ile birlik/mermi/combat/ekonomi sistemleri eklendi (bkz.
/// TargetingSystem, CombatSystem, EconomySystem). 12-13 ile yetenek ve
/// gorsel efekt/sarsinti sistemleri eklendi (AbilitySystem, EffectSystem).
void registerDefaultSystems(BattleSimulation sim) {
  sim.registerSystems([
    WaveSystem(),
    SpawnSystem(),
    SpatialIndexSystem(),
    TargetingSystem(),
    TerrainSystem(),
    MovementSystem(),
    CombatSystem(),
    AbilitySystem(),
    EconomySystem(),
    UpgradeSystem(),
    EffectSystem(),
    CompactionSystem(),
  ]);
}
