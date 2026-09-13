import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';

/// Spatial grid'leri her adim yeniden kurar.
///
/// Baska hicbir sey yapmaz: `world.rebuildSpatialIndex()` cagirisini
/// [SystemPhase.spatialIndex] fazina baglamak bu sistemin tek gorevi.
/// Spawn'dan SONRA, hedefleme/hareketten ONCE calisir ki ayni adimda
/// dogan bir dusman da o adimin hedeflemesinde gorulebilsin.
class SpatialIndexSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.spatialIndex;

  @override
  void onBattleStart(BattleSimulation sim) {}

  @override
  void step(BattleSimulation sim, double dt) {
    sim.world.rebuildSpatialIndex();
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
