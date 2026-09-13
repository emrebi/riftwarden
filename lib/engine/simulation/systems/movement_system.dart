import 'dart:math' as math;

import 'package:riftwarden/domain/rules/rules.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';
import 'package:riftwarden/engine/simulation/entities/entities.dart';

/// Yavaslama (slow) durum efektindeyken uygulanan hiz carpani. Deger
/// tasarimsal baslangic noktasidir; status effect sistemi (ileride)
/// `slowTimer`'i dolduracak, buradaki carpan ise motor sabitidir.
const double kSlowSpeedMultiplier = 0.5;

/// Core'un carpisma yaricapi (normalize birim). Core konumu sabit oldugu
/// icin bu deger de sabit tutulur; icerik JSON'unda Core geometrisi yok.
const double kCoreRadius = 0.03;

/// Separation (boids-lite) sorgu yaricapi. `kSpatialCellSize`'dan kucuk
/// tutulur ki sorgu tek hucreye yakin kalsin.
const double kSeparationRadius = 0.03;

/// Separation kuvvet katsayisi. **Dusuk tutulur**: amac dusmanlarin ust
/// uste tam binmesini azaltmak, birbirini itip duzenli bir formasyon
/// kurmak degil — swarm'in "kalabalik" hissi tasarimin bir parcasi.
const double kSeparationStrength = 0.15;

/// Birlikler arasi separation yaricapi. Dusman separation'indan biraz
/// genistir: birlikler dusmanlardan buyuk radius'a sahip olabilir
/// (bkz. UnitConfig.radius, tank icin 0.032'ye kadar cikar).
const double kUnitSeparationRadius = 0.05;

/// Birlik separation kuvveti. Dusmandakiyle ayni buyuklukte tutulur:
/// amac formasyonun ust uste binmesini hafifce azaltmak, sert bir itme
/// hissi yaratmak degil.
const double kUnitSeparationStrength = 0.15;

/// Her rolun Core'a tercih ettigi mesafe (normalize birim, Core'dan
/// dusman yonune dogru = Y ekseninde yukari, cunku Core sabit olarak
/// alanin altinda durur ve dusmanlar yukaridan asagi yururur, bkz.
/// `BattleWorld.coreY` = 0.86).
///
/// Bu degerler sadece HEDEFSIZ (idle) veya menzil disi durumda gecerli
/// "varsayilan formasyon hatti"dir: bir birlik hedefine kilitlendiginde
/// ve o hedef menzil disindaysa hedefe dogru yaklasir. Tank'in menzili
/// zaten kisa (yakin dovus) oldugu icin pratikte on hatta yigilir; bu
/// sabitler esas olarak HENUZ hedef yokken (dalga henuz gelmemisken)
/// birliklerin nerede bekleyecegini belirler.
const double kTankFrontDistance = 0.55;
const double kSwarmFrontDistance = 0.35;
const double kRangedFrontDistance = 0.15;
const double kSupportFrontDistance = 0.05;

/// Dusman lane takibi, Core'a varis ve hafif ayrisma (separation).
///
/// 10a kapsaminda SADECE dusmanlar hareket ediyordu; 10b ile birlik ve
/// mermi hareketi asagida eklendi (dusman bolumune dokunulmadi).
class MovementSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.movement;

  @override
  void onBattleStart(BattleSimulation sim) {}

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;
    final enemies = world.enemies;
    final grid = world.enemyGrid;
    final scratch = world.queryScratch;

    for (var i = 0; i < enemies.activeCount; i++) {
      final enemy = enemies[i];
      if (enemy.pendingRemove) continue;

      // Render interpolasyonu prev -> guncel arasini lerp eder; bu yuzden
      // prev, konum degismeden ONCE alinmis olmali.
      enemy.prevX = enemy.x;
      enemy.prevY = enemy.y;

      var speed = enemy.speed;
      if (enemy.slowTimer > 0) {
        enemy.slowTimer -= dt;
        speed *= kSlowSpeedMultiplier;
      }

      final waypointCount = world.laneWaypointCount(enemy.laneIndex);
      var headingToCore = enemy.waypointIndex >= waypointCount;
      var targetX = headingToCore
          ? world.coreX
          : world.laneWaypointX(enemy.laneIndex, enemy.waypointIndex);
      var targetY = headingToCore
          ? world.coreY
          : world.laneWaypointY(enemy.laneIndex, enemy.waypointIndex);

      var dx = targetX - enemy.x;
      var dy = targetY - enemy.y;
      var distSq = dx * dx + dy * dy;

      // Mesafe karsilastirmalari kare mesafeyle yapilir; sqrt sadece
      // asagida gercek normalizasyon gerektiginde cagrilir.
      final arriveRadius = headingToCore ? enemy.radius + kCoreRadius : enemy.radius;
      if (distSq <= arriveRadius * arriveRadius) {
        if (headingToCore) {
          enemy.reachedCore = true;
          world.coreHp -= enemy.coreDamage;
          enemy.pendingRemove = true;
          _pushCoreHpImmediately(sim);
          continue;
        }

        enemy.waypointIndex++;
        headingToCore = enemy.waypointIndex >= waypointCount;
        targetX = headingToCore
            ? world.coreX
            : world.laneWaypointX(enemy.laneIndex, enemy.waypointIndex);
        targetY = headingToCore
            ? world.coreY
            : world.laneWaypointY(enemy.laneIndex, enemy.waypointIndex);
        dx = targetX - enemy.x;
        dy = targetY - enemy.y;
        distSq = dx * dx + dy * dy;
      }

      if (distSq > 0) {
        final dist = math.sqrt(distSq);
        final step = speed * dt;
        enemy.x += dx / dist * step;
        enemy.y += dy / dist * step;
      }

      // Separation: ayni bolgedeki cok yakin komsulardan hafifce uzaklas.
      // Scratch tampon kullanilir, yeni liste yaratilmaz.
      final neighborCount = grid.queryCircle(enemy.x, enemy.y, kSeparationRadius, scratch);
      var pushX = 0.0;
      var pushY = 0.0;
      for (var n = 0; n < neighborCount; n++) {
        final otherIndex = scratch[n];
        if (otherIndex == i) continue;
        final other = enemies[otherIndex];
        final ox = enemy.x - other.x;
        final oy = enemy.y - other.y;
        final oDistSq = ox * ox + oy * oy;
        if (oDistSq <= 0 || oDistSq >= kSeparationRadius * kSeparationRadius) {
          continue;
        }
        final oDist = math.sqrt(oDistSq);
        pushX += ox / oDist;
        pushY += oy / oDist;
      }
      if (pushX != 0 || pushY != 0) {
        enemy.x += pushX * kSeparationStrength * dt;
        enemy.y += pushY * kSeparationStrength * dt;
      }
    }

    _stepUnits(sim, dt);
    _stepProjectiles(sim, dt);
  }

  /// Birlik konumlanmasi. Pathfinding YOK: her birlik rolune gore ya
  /// hedefine dogru yurur ya da Core'a gore sabit bir formasyon hattinda
  /// bekler. Menzile giren birlik saldirmak icin durur (ilerlemeye devam
  /// etmesi hedefin ustune yurumesi demek olurdu).
  void _stepUnits(BattleSimulation sim, double dt) {
    final world = sim.world;
    final units = world.units;
    final enemies = world.enemies;
    final grid = world.unitGrid;
    final scratch = world.queryScratch;

    for (var i = 0; i < units.activeCount; i++) {
      final unit = units[i];
      if (unit.pendingRemove) continue;

      unit.prevX = unit.x;
      unit.prevY = unit.y;

      final stats = world.resolvedUnitStats[unit.statsIndex];
      final moveSpeed = stats.stats[StatId.moveSpeed];
      final range = stats.stats[StatId.range];

      // Hedef ipucunu dogrula (bkz. UnitEntity.targetIndexHint sozlesmesi).
      // Bu sistem yeniden ARAMAZ (o TargetingSystem'in isi); sadece elindeki
      // ipucunun hala gecerli olup olmadigina bakar.
      EnemyEntity? target;
      if (unit.targetId != 0) {
        final hint = unit.targetIndexHint;
        if (hint >= 0 && hint < enemies.activeCount && enemies[hint].id == unit.targetId) {
          target = enemies[hint];
        }
      }

      final frontDistance = _frontDistanceFor(unit.role);
      final formationY = (world.coreY - frontDistance).clamp(0.0, world.coreY);

      double desiredX;
      double desiredY;
      var shouldHold = false;

      if (unit.role == UnitRole.support || target == null) {
        // Support hicbir zaman dusmana yaklasmaz; hedefsiz birlik ise
        // formasyon hattinda bekler.
        desiredX = world.coreX;
        desiredY = formationY;
      } else {
        final dx = target.x - unit.x;
        final dy = target.y - unit.y;
        if (dx * dx + dy * dy <= range * range) {
          // Menzildeyken ilerlemeye devam etmek hedefin ustune yurumek
          // demektir; bu yuzden TUM roller (ozellikle ranged, brief'te
          // acikca istenen davranis) menzildeyken yerinde kalir.
          shouldHold = true;
          desiredX = unit.x;
          desiredY = unit.y;
        } else {
          desiredX = target.x;
          desiredY = target.y;
        }
      }

      if (!shouldHold) {
        final dx = desiredX - unit.x;
        final dy = desiredY - unit.y;
        final distSq = dx * dx + dy * dy;
        if (distSq > 0) {
          final dist = math.sqrt(distSq);
          final step = math.min(moveSpeed * dt, dist);
          unit.x += dx / dist * step;
          unit.y += dy / dist * step;
        }
      }

      // Separation: dusmandaki ile ayni desen, formasyonun ust uste
      // binmesini hafifce azaltir.
      final neighborCount = grid.queryCircle(unit.x, unit.y, kUnitSeparationRadius, scratch);
      var pushX = 0.0;
      var pushY = 0.0;
      for (var n = 0; n < neighborCount; n++) {
        final otherIndex = scratch[n];
        if (otherIndex == i) continue;
        final other = units[otherIndex];
        final ox = unit.x - other.x;
        final oy = unit.y - other.y;
        final oDistSq = ox * ox + oy * oy;
        if (oDistSq <= 0 || oDistSq >= kUnitSeparationRadius * kUnitSeparationRadius) {
          continue;
        }
        final oDist = math.sqrt(oDistSq);
        pushX += ox / oDist;
        pushY += oy / oDist;
      }
      if (pushX != 0 || pushY != 0) {
        unit.x += pushX * kUnitSeparationStrength * dt;
        unit.y += pushY * kUnitSeparationStrength * dt;
      }
    }
  }

  double _frontDistanceFor(UnitRole role) => switch (role) {
        UnitRole.tank => kTankFrontDistance,
        UnitRole.swarm => kSwarmFrontDistance,
        UnitRole.ranged => kRangedFrontDistance,
        UnitRole.support => kSupportFrontDistance,
      };

  /// Mermi ucusu: duz mermi vx/vy yonunde ilerler; guduml mermi
  /// (targetId dolu) hedefine gore yonunu her karede tazeler. Carpisma
  /// tespiti burada YAPILMAZ (bkz. CombatSystem, hareketten SONRA calisir
  /// ki carpisma kontrolu guncel konuma gore olsun).
  void _stepProjectiles(BattleSimulation sim, double dt) {
    final world = sim.world;
    final projectiles = world.projectiles;
    final enemies = world.enemies;

    for (var i = 0; i < projectiles.activeCount; i++) {
      final projectile = projectiles[i];
      if (projectile.pendingRemove) continue;

      projectile.prevX = projectile.x;
      projectile.prevY = projectile.y;

      if (projectile.targetId != 0) {
        final hint = projectile.targetIndexHint;
        if (hint >= 0 && hint < enemies.activeCount && enemies[hint].id == projectile.targetId) {
          final target = enemies[hint];
          final dx = target.x - projectile.x;
          final dy = target.y - projectile.y;
          final distSq = dx * dx + dy * dy;
          if (distSq > 0) {
            final dist = math.sqrt(distSq);
            projectile.vx = dx / dist * projectile.speed;
            projectile.vy = dy / dist * projectile.speed;
          }
        }
        // Ipucu tutmuyorsa hedef olmus/kaybolmus demektir: mermi son bilinen
        // vx/vy ile duz ucusuna devam eder (bkz. CombatSystem "iskalasin"
        // karari) — burada targetId'ye dokunmuyoruz, CombatSystem carpisma
        // kontrolunde ayni dogrulamayi yapip hedefi temizleyecek.
      }

      projectile.x += projectile.vx * dt;
      projectile.y += projectile.vy * dt;

      projectile.lifetime -= dt;
      if (projectile.lifetime <= 0) {
        projectile.pendingRemove = true;
      }
    }
  }

  /// Core hasar aldigi an HUD'a aninda yansir; `kHudThrottleInterval`
  /// beklenmez (oyuncu Core'un can kaybini gecikmeli gormemeli, bkz.
  /// BattleSignals dosya basi "Throttle kurali").
  void _pushCoreHpImmediately(BattleSimulation sim) {
    final world = sim.world;
    final clampedHp = world.coreHp.clamp(0.0, world.coreMaxHp);
    sim.signals.coreHp.value = clampedHp.round();
    sim.signals.coreHpRatio.value =
        world.coreMaxHp <= 0 ? 0 : clampedHp / world.coreMaxHp;
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
