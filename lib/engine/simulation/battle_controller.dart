import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';

/// `BattleCommands` sozlesmesinin motor tarafi uygulamasi.
///
/// UI ile simulasyon arasindaki TEK giris kapisi. Simulasyon durumu sadece
/// `step()` icinde degismeli (bkz. `BattleWorld` uretim kuyrugu yorumu);
/// bu yuzden `requestUnit` gibi durum degistiren komutlar dogrudan
/// `BattleWorld`e yazmaz, onceden ayrilmis bir kuyruga ekler ve gercek
/// islemi `EconomySystem.step()`e birakir. `pause`/`resume` ise zaten
/// `BattleSimulation` tarafinda adim disi guvenli oldugu icin dogrudan
/// devredilir.
class BattleController implements BattleCommands {
  BattleController(this._sim);

  final BattleSimulation _sim;

  @override
  void requestUnit(String unitId) {
    _sim.world.enqueueUnitRequest(unitId);
  }

  // Yetenek dukkani satin alma: `requestUnit` ile AYNI kuyruk deseni —
  // gercek islem `EconomySystem.step()` icinde olur.
  @override
  void buyAbility(String upgradeId) {
    _sim.world.enqueueAbilityPurchase(upgradeId);
  }

  @override
  void pause() => _sim.pause();

  // Esik karti teklifi aciksa (bkz. `BattleWorld.activeOfferIds`) HICBIR SEY
  // yapmaz: aksi halde pause menusunden "devam" tiklamasi, teklif secilmeden
  // savasi kaldigi yerden baslatir ve oyuncu kartini secmeden kacirmis olur.
  @override
  void resume() {
    if (_sim.world.activeOfferIds != null) return;
    _sim.resume();
  }

  // Yetenek nisan alma / kullanma: `requestUnit` ile AYNI kuyruk/bayrak
  // deseni (bkz. `BattleWorld` "Yetenek komut kuyugu" yorumu) — durumu
  // buradan DEGIL, `AbilitySystem.step()` icinde degistiriyoruz.
  @override
  void toggleAbilityAiming() {
    _sim.world.requestAbilityAimToggle();
  }

  @override
  void castAbilityAt(double x, double y) {
    _sim.world.requestAbilityCast(x, y);
  }

  // Esik karti secimi / reroll: teklif SADECE simulasyon durmusken
  // (pause/slowing) acik olabilir, bu yuzden `UpgradeSystem.step()` ile
  // AYNI ANDA calisamazlar (bkz. `UpgradeSystem` dosya basi "guvenlidir"
  // yorumu) — kuyruk deseni DEGIL, dogrudan uygulanir.
  @override
  void chooseUpgrade(String upgradeId) {
    final world = _sim.world;
    final activeIds = world.activeOfferIds;
    if (activeIds == null || !activeIds.contains(upgradeId)) return;

    final upgrade = world.content.upgrades[upgradeId];
    if (upgrade == null) return;

    world.upgradePool.take(upgrade);
    world.takenUpgrades.add(upgrade);
    world.rebuildUnitStats(world.takenUpgrades);
    world.pendingOfferCount--;
    world.activeOfferIds = null;
    _sim.signals.upgradeOffer.value = null;
    // Siradaki teklif varsa (`pendingOfferCount > 0`) bir sonraki adimda
    // `UpgradeSystem` acar; burada ek is yok.
    _sim.resume();
  }

  @override
  void rerollUpgrades() {
    final world = _sim.world;
    if (world.activeOfferIds == null || world.rerollsLeft <= 0) return;

    final offer = world.upgradePool.roll(3, world.cardRng);
    // Havuz bosaldiysa (nadir) mevcut teklif SESSIZCE korunur; reroll hakki
    // harcanmaz — bos bir kart ekrani gostermek yerine.
    if (offer.isEmpty) return;

    world.rerollsLeft--;
    final ids = offer.map((u) => u.id).toList(growable: false);
    world.activeOfferIds = ids;
    _sim.signals.upgradeOffer.value =
        UpgradeOffer(upgradeIds: ids, rerollsLeft: world.rerollsLeft);
  }
}
