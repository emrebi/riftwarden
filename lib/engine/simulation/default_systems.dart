import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/systems/systems.dart';

/// Bir savasin varsayilan sistem setini kurar.
///
/// [BattleSimulation.registerSystems] ekleme sirasini degil [SystemPhase]
/// enum sirasini baglayici sayar; buradaki sira sadece okunabilirlik
/// icindir. 10b ile birlik/mermi/combat/ekonomi sistemleri eklendi (bkz.
/// TargetingSystem, CombatSystem, EconomySystem).
void registerDefaultSystems(BattleSimulation sim) {
  sim.registerSystems([
    WaveSystem(),
    SpawnSystem(),
    SpatialIndexSystem(),
    TargetingSystem(),
    MovementSystem(),
    CombatSystem(),
    EconomySystem(),
    CompactionSystem(),
  ]);
}
