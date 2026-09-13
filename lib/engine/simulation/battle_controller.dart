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

  @override
  void pause() => _sim.pause();

  @override
  void resume() => _sim.resume();

  // Yetenek nisan alma / kullanma — adim 13'un isi.
  @override
  void toggleAbilityAiming() {
    // TODO(adim 13): yetenek nisan alma modu.
  }

  @override
  void castAbilityAt(double x, double y) {
    // TODO(adim 13): yetenek kullanimi.
  }

  // Upgrade secimi / reroll — adim 14'un isi.
  @override
  void chooseUpgrade(String upgradeId) {
    // TODO(adim 14): upgrade secimi.
  }

  @override
  void rerollUpgrades() {
    // TODO(adim 14): upgrade tekliflerini yeniden cek.
  }
}
