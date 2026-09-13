import 'dart:math' as math;

import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';

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

/// Dusman lane takibi, Core'a varis ve hafif ayrisma (separation).
///
/// 10a kapsaminda SADECE dusmanlar hareket eder; birlikler ve mermiler
/// 10b'nin isidir (bu sistem onlara dokunmaz).
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
