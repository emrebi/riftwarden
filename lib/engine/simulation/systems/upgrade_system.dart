import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';

/// Oldurme esigi tetikleyicisi: toplam oldurme sayisi
/// `level.upgradeKillThresholds`'ten birine ulasinca esik karti teklifi acar.
///
/// [SystemPhase.upgrade]: `economy`'den SONRA calisir ki bu adimda
/// `CompactionSystem`in bir onceki adimda biriktirdigi `killsThisStep`
/// (bkz. o alanin dosya basi yorumu — `aetherEarnedThisStep` ile ayni
/// bir-adim gecikme deseni) burada da tutarli okunsun; `effects`'ten
/// ONCE calisir ki bu adimda baslayan slow-mo, gorsel/haptic
/// sistemlerinden once tetiklenmis olsun.
///
/// Secim ve reroll bu sistemde DEGIL, `BattleController`de islenir: onlar
/// simulasyon DURMUSKEN (pause/slowing) UI thread'inden gelir, `step()`
/// icinde degil. Bu GUVENLIDIR cunku pause/slowing sirasinda `step()`
/// (dolayisiyla bu sistem de) hic CALISMAZ (bkz. `BattleSimulation.advance`
/// — mode paused ise erken doner); `activeOfferIds`/`pendingOfferCount`
/// gibi paylasilan durumu ayni anda degistiren iki taraf olmaz.
class UpgradeSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.upgrade;

  @override
  void onBattleStart(BattleSimulation sim) {}

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;

    // Bir onceki adimin compaction'inda biriken oldurme sayisi (bkz. sinif
    // dosya basi yorumu).
    world.totalKills += world.killsThisStep;

    // UI hazir olana kadar teklif/pause mantigi gecici kapali (bkz.
    // kUpgradeCardsEnabled yorumu); totalKills birikimi yine de surer.
    if (!kUpgradeCardsEnabled) return;

    final thresholds = world.level.upgradeKillThresholds;
    while (world.nextThresholdIndex < thresholds.length &&
        world.totalKills >= thresholds[world.nextThresholdIndex]) {
      world.pendingOfferCount++;
      world.nextThresholdIndex++;
    }

    if (world.activeOfferIds == null &&
        world.pendingOfferCount > 0 &&
        sim.mode == SimulationMode.running) {
      _openNextOffer(sim);
    }
  }

  /// Siradaki bekleyen teklifi acar. Havuz bos donerse (adayin kalmadigi
  /// nadir durum) bu esik SESSIZCE ATLANIR — brief kurali: bos teklif
  /// ekrani gostermek yerine bir sonraki esige gecilir.
  void _openNextOffer(BattleSimulation sim) {
    final world = sim.world;
    final offer = world.upgradePool.roll(3, world.cardRng);

    if (offer.isEmpty) {
      world.pendingOfferCount--;
      return;
    }

    final ids = offer.map((u) => u.id).toList(growable: false);
    world.activeOfferIds = ids;
    sim.signals.upgradeOffer.value =
        UpgradeOffer(upgradeIds: ids, rerollsLeft: world.rerollsLeft);
    sim.beginSlowMotionPause();
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
