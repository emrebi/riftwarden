import 'dart:math' as math;

import 'package:riftwarden/domain/rules/rules.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';

/// Mermi hizi (normalize birim/saniye). Icerik `units.json`da mermi icin
/// fiziksel bir deger tasimaz (`projectile` alani sadece bir gorsel id'dir,
/// bkz. `UnitConfig.projectile` yorumu); bu yuzden motor sabiti kullanilir.
/// Ileride `projectiles.json` eklenirse bu sabit oradan cozulecek sekilde
/// degistirilecek.
const double kProjectileSpeed = 0.7;

/// Mermi carpisma yaricapi (normalize birim). Kucuk tutulur: mermiler
/// nokta gibi davranmali, gorsel buyuklukleri sprite'ta olur.
const double kProjectileRadius = 0.015;

/// Mermi guvenlik omru (saniye). Hedefi olurse mermi iskalar (asagida
/// gerekce yazili) ve duz ucusuna devam eder; bu omur olmasa sonsuza kadar
/// alanda kalip havuzu tuketebilirdi.
const double kProjectileLifetime = 3.0;

/// Saldiri (birlik ates/vurus), mermi carpismasi ve dusman olumu.
///
/// [SystemPhase.combat]: hareketten SONRA calisir ki menzil/carpisma
/// kontrolleri o adimin GUNCEL konumuna gore yapilsin.
///
/// Kapsam disi (bkz. TASK 10B brief'i): zincirleme, delme, olumde patlama,
/// yakma/dondurma gibi davranis bayraklari. Sadece kritik vurus (bkz.
/// `BehaviorFlag.criticalHits`) burada islenir, cunku `DamageCalculator`
/// zaten destekliyor.
class CombatSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.combat;

  @override
  void onBattleStart(BattleSimulation sim) {}

  @override
  void step(BattleSimulation sim, double dt) {
    _stepUnitAttacks(sim, dt);
    _stepProjectileImpacts(sim);
  }

  /// Birlik saldirisi: cooldown dolunca ve hedef menzildeyse ates eder.
  /// Menzil disindaysa saldirmaz (MovementSystem zaten yaklastirmaya
  /// calisir; bu sistem hareket etmez, sadece kontrol eder).
  void _stepUnitAttacks(BattleSimulation sim, double dt) {
    final world = sim.world;
    final units = world.units;
    final enemies = world.enemies;

    for (var i = 0; i < units.activeCount; i++) {
      final unit = units[i];
      if (unit.pendingRemove) continue;

      unit.attackCooldown -= dt;
      if (unit.attackCooldown > 0) continue;
      if (unit.targetId == 0) continue;

      final hint = unit.targetIndexHint;
      if (!(hint >= 0 && hint < enemies.activeCount && enemies[hint].id == unit.targetId)) {
        // Ipucu tutmuyor: hedef olmus/kaybolmus. Bir sonraki TargetingSystem
        // dongusune kadar bekle, burada yeniden arama YAPILMAZ (bu ise
        // TargetingSystem'e ait, bkz. faz ayrimi).
        continue;
      }

      final enemy = enemies[hint];
      final stats = world.resolvedUnitStats[unit.statsIndex];
      final range = stats.stats[StatId.range];
      final dx = enemy.x - unit.x;
      final dy = enemy.y - unit.y;
      if (dx * dx + dy * dy > range * range) continue;

      final attackSpeed = stats.stats[StatId.attackSpeed];
      unit.attackCooldown += attackSpeed > 0 ? 1 / attackSpeed : 0;

      final config = world.content.unit(unit.configId);
      if (config.projectile == null) {
        // Yakin dovus: hasar aninda uygulanir.
        final result = DamageCalculator.compute(
          baseDamage: stats.stats[StatId.damage],
          stats: stats.stats,
          behaviorMask: stats.behaviorMask,
          rng: world.rng,
        );
        enemy.hp -= result.amount;
        if (enemy.hp <= 0) enemy.pendingRemove = true;
        continue;
      }

      // Menzilli: mermi uret. Havuz doluysa spawn() null doner, saldiri
      // sessizce israf olur (cooldown zaten tuketildi) — exception yok.
      final projectile = world.projectiles.spawn();
      if (projectile == null) continue;

      final dist = math.sqrt(dx * dx + dy * dy);
      final invDist = dist > 0 ? 1 / dist : 0.0;
      projectile
        ..x = unit.x
        ..y = unit.y
        ..prevX = unit.x
        ..prevY = unit.y
        ..vx = dx * invDist * kProjectileSpeed
        ..vy = dy * invDist * kProjectileSpeed
        ..speed = kProjectileSpeed
        ..radius = kProjectileRadius
        ..lifetime = kProjectileLifetime
        ..damage = stats.stats[StatId.damage]
        ..behaviorMask = stats.behaviorMask
        ..statsIndex = unit.statsIndex
        ..targetId = enemy.id
        ..targetIndexHint = hint
        ..ownerUnitId = unit.id;
    }
  }

  /// Mermi carpismasi: hedefine [ProjectileEntity.radius] kadar yaklasinca
  /// hasar uygular ve mermiyi isaretler.
  ///
  /// Hedef mermi havadayken olmusse (bir baska birlik oldurmustur) mermi
  /// ISKALAR: yeni bir hedef aramak icin ekstra spatial sorgu ve yon
  /// degisikligi gerekirdi, bu da "guduml mermi hedefini kaybedince duz
  /// ucusuna devam eder" ilkesini bozardi. Iskalayan mermi MovementSystem'in
  /// isledigi `lifetime` dolunca kendiliginden yok olur.
  void _stepProjectileImpacts(BattleSimulation sim) {
    final world = sim.world;
    final projectiles = world.projectiles;
    final enemies = world.enemies;

    for (var i = 0; i < projectiles.activeCount; i++) {
      final projectile = projectiles[i];
      if (projectile.pendingRemove) continue;
      if (projectile.targetId == 0) continue;

      final hint = projectile.targetIndexHint;
      if (!(hint >= 0 && hint < enemies.activeCount && enemies[hint].id == projectile.targetId)) {
        // Hedef gecersiz: iskala (yukaridaki gerekce). targetId'yi
        // sifirlamak MovementSystem'in bir sonraki karede duz ucusa
        // devam etmesini saglar (yon tazelemeyi tekrar denemez).
        projectile.targetId = 0;
        continue;
      }

      final enemy = enemies[hint];
      final dx = enemy.x - projectile.x;
      final dy = enemy.y - projectile.y;
      final r = projectile.radius;
      if (dx * dx + dy * dy > r * r) continue;

      final stats = world.resolvedUnitStats[projectile.statsIndex];
      final result = DamageCalculator.compute(
        baseDamage: projectile.damage,
        stats: stats.stats,
        behaviorMask: projectile.behaviorMask,
        rng: world.rng,
      );
      enemy.hp -= result.amount;
      if (enemy.hp <= 0) enemy.pendingRemove = true;

      // Delme kapsam disi (bkz. dosya basi yorumu): her carpisma mermiyi
      // tuketir.
      projectile.pendingRemove = true;
    }
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
