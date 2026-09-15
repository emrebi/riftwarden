import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/effects/effect_entity.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Oyuncunun su anki TEK aktif yetenegi. Icerik JSON'undan gelen bir id
/// oldugu icin `switch (levelId)` tarzi bir ihlal degildir (bkz. CLAUDE.md
/// kural 8) — bu sadece "hangi ability config'i cozulecek" sabiti,
/// dengeleme degerlerinin (cooldown, hasar, yaricap) tumu
/// `assets/content/abilities.json` icindedir. Birden fazla yetenek
/// eklenince (M ilerisi) bu sabit `LevelConfig`/loadout'tan gelen bir
/// alana donusecek.
const String kPlayerAbilityId = 'rift_collapse';

/// Core hasarindan farkli, daha hafif bir sarsinti (brief: "yetenek
/// patlamasi (orta)").
const double kAbilityBlastShakeIntensity = 0.012;
const double kAbilityBlastShakeDuration = 0.18;

/// Oyuncunun aktif yetenegi: nisan alma, uyari suresi, patlama.
///
/// [SystemPhase.ability]: combat'tan SONRA (o adimda kim oldu biliniyor,
/// ama ability'nin kendi hedef secimi bagimsizdir), boss ve economy'den
/// ONCE. Uyari suresi ZORUNLUDUR (bkz. brief: "uyarisiz alan hasari
/// adaletsiz hissettirir") — bu yuzden `castAbilityAt` hasari ANINDA
/// uygulamaz, `_pendingBlastTimer` ile `warningTime` kadar geciktirir.
///
/// Cooldown/nisan alma durumu bu SISTEM ORNEGINDE tutulur (`BattleWorld`e
/// DEGIL) — `EconomySystem._costs` ile ayni desen: sistem orneginin
/// kendisi savas boyunca YASIYOR (bkz. `RiftwardenGame.onLoad`, bir kez
/// kurulur), bu yuzden bu durumu tasimasi `BattleWorld`'un genel yuzeyini
/// sisirmeden gecerlidir. `BattleWorld` sadece UI->motor KOMUT kuyugunu
/// tasir (bkz. `requestAbilityAimToggle`/`requestAbilityCast`), cunku o
/// kisim baska sistemlerin de gorebilecegi genel bir girisim noktasidir.
class AbilitySystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.ability;

  late AbilityConfig _config;

  double _cooldownRemaining = 0;
  bool _aiming = false;

  /// Uyari halkasi suruyorken kalan sure. Negatifse bekleyen patlama yok.
  double _pendingBlastTimer = -1;
  double _pendingBlastX = 0;
  double _pendingBlastY = 0;

  @override
  void onBattleStart(BattleSimulation sim) {
    _config = sim.world.content.ability(kPlayerAbilityId);
    _cooldownRemaining = 0;
    _aiming = false;
    _pendingBlastTimer = -1;
    _pushState(sim);
  }

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;

    if (_cooldownRemaining > 0) {
      _cooldownRemaining -= dt;
      if (_cooldownRemaining < 0) _cooldownRemaining = 0;
    }

    if (world.consumeAbilityAimToggle()) {
      // Uyari asamasindaki bir patlama suruyorken nisan alma modu
      // degistirilemez; yetenek zaten kullanimda.
      if (_pendingBlastTimer < 0) {
        _aiming = !_aiming && _cooldownRemaining <= 0;
        _pushState(sim);
      }
    }

    if (world.tryConsumeAbilityCast() && _aiming && _cooldownRemaining <= 0) {
      _beginCast(world, sim, world.pendingCastX, world.pendingCastY);
    }

    if (_pendingBlastTimer >= 0) {
      _pendingBlastTimer -= dt;
      if (_pendingBlastTimer <= 0) {
        _resolveBlast(world, sim);
      }
    }

    if (sim.isHudPushDue) _pushState(sim);
  }

  /// Nisan alinan noktaya yetenegi baslatir: cooldown HEMEN baslar (ikinci
  /// bir kullanimi engellemek icin), ama hasar `warningTime` sonra
  /// uygulanir (bkz. sinif dosya basi yorumu).
  void _beginCast(BattleWorld world, BattleSimulation sim, double x, double y) {
    _aiming = false;
    _cooldownRemaining = _config.cooldown;
    _pendingBlastTimer = _config.warningTime;
    _pendingBlastX = x;
    _pendingBlastY = y;

    // Uyari halkasi: patlama alanini `_config.radius` boyutunda, tam
    // `warningTime` kadar goster.
    final ring = world.emitEffect(EffectKind.abilityBlast, x, y);
    ring
      ?..lifetime = _config.warningTime
      ..scale = _config.radius;

    sim.signals.triggerHaptic(HapticCueKind.medium);
    _pushState(sim);
  }

  void _resolveBlast(BattleWorld world, BattleSimulation sim) {
    _pendingBlastTimer = -1;

    final grid = world.enemyGrid;
    final scratch = world.queryScratch;
    final count = grid.queryCircle(_pendingBlastX, _pendingBlastY, _config.radius, scratch);
    for (var i = 0; i < count; i++) {
      final enemy = world.enemies[scratch[i]];
      enemy.hp -= _config.damage * enemy.damageTakenMul;
      if (enemy.hp <= 0) enemy.pendingRemove = true;
    }

    // Patlama gorseli: uyari halkasindan daha kisa omurlu, ayni yaricapta.
    final blast = world.emitEffect(EffectKind.abilityBlast, _pendingBlastX, _pendingBlastY);
    blast?.scale = _config.radius;

    world.screenShake.trigger(kAbilityBlastShakeIntensity, kAbilityBlastShakeDuration);
  }

  void _pushState(BattleSimulation sim) {
    sim.signals.ability.value = AbilityState(
      abilityId: kPlayerAbilityId,
      cooldownRemaining: _cooldownRemaining,
      cooldownTotal: _config.cooldown,
      isAiming: _aiming,
    );
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
