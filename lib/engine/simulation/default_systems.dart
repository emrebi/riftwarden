import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/systems/systems.dart';

/// Bir savasin varsayilan sistem setini kurar.
///
/// [BattleSimulation.registerSystems] ekleme sirasini degil [SystemPhase]
/// enum sirasini baglayici sayar; buradaki sira sadece okunabilirlik
/// icindir. 10a kapsaminda birlik/mermi/combat sistemleri henuz yok
/// (10b'nin isi) — bu yuzden liste su an sadece dusman tarafini kurar.
void registerDefaultSystems(BattleSimulation sim) {
  sim.registerSystems([
    WaveSystem(),
    SpawnSystem(),
    SpatialIndexSystem(),
    MovementSystem(),
    CompactionSystem(),
  ]);
}
