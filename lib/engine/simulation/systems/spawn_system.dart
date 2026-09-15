import 'dart:math' as math;

import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/domain/rules/rules.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_system.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Elite dusman HP carpani. Elite'ler nadir cikar; sıradan bir dusmanin
/// birkac kati dayaniklilik gostermezse "elite" etiketi anlamsizlasir.
/// Deger tasarimsal bir baslangic noktasidir, dengeleme sirasinda
/// `assets/content/*.json` tarafi degil bu sabit ayarlanir (content'te
/// elite HP carpani alani yok).
const double kEliteHpMultiplier = 1.8;

/// Elite dusman Aether odul carpani. HP carpanindan daha dusuk tutulur:
/// elite'i oldurmek zaten daha zor oldugu icin odulu asiri sismek
/// ekonomiyi (upgrade hizini) bozar.
const double kEliteRewardMultiplier = 1.5;

/// Dusmanin sag kenarin ne kadar disinda dogdugu (izotropik dunya birimi).
/// Ekran disinda dogmasi, oyuncunun aniden beliren bir dusman gormesini
/// engeller; `MovementSystem` onu sola dogru ekrana getirir.
const double kSpawnOvershoot = 0.03;

/// Zamanlanmis spawn olaylarini havuza dusman olarak yerlestirir.
///
/// [SystemPhase.spawn], [SystemPhase.wave]'den hemen sonra ve
/// [SystemPhase.spatialIndex]'ten ONCE calisir ki bu adimda dogan bir
/// dusman ayni adimin spatial grid'inde ve hedeflemesinde gorulebilsin.
class SpawnSystem implements BattleSystem {
  @override
  SystemPhase get phase => SystemPhase.spawn;

  @override
  void onBattleStart(BattleSimulation sim) {}

  @override
  void step(BattleSimulation sim, double dt) {
    final world = sim.world;
    final schedule = world.spawnSchedule;

    // Bir adimda birden fazla spawn olayi zamani gelmis olabilir (dusuk
    // fps veya sik araliklarla spawn edildiginde); hepsini tuket.
    while (world.nextSpawnIndex < schedule.length &&
        schedule[world.nextSpawnIndex].time <= sim.elapsed) {
      final event = schedule[world.nextSpawnIndex];
      world.nextSpawnIndex++;
      _spawnOne(world, event);
    }
  }

  void _spawnOne(BattleWorld world, SpawnEvent event) {
    final enemy = world.enemies.spawn();
    // Havuz doluysa spawn() null doner. Bu bir hata degil, tasarlanmis
    // davranistir (bkz. EntityPool.spawn yorumu): olayi sessizce atla,
    // exception firlatma. nextSpawnIndex zaten yukarida ilerletildigi
    // icin bu olay bir daha denenmez.
    if (enemy == null) return;

    final config = world.content.enemy(event.enemyId);

    final hpMultiplier =
        world.level.difficultyMultiplier * (event.isElite ? kEliteHpMultiplier : 1.0);
    final rewardMultiplier = event.isElite ? kEliteRewardMultiplier : 1.0;

    // Sag kenarin hemen disinda dogar; sola dogru MovementSystem ilerletir.
    const startX = kFieldAspect + kSpawnOvershoot;
    final startY = event.y;

    enemy
      ..configId = config.id
      // Tablo `RiftwardenGame.onLoad`'da savas kurulumunda bir kez
      // doldurulur (bkz. `BattleWorld.enemySpriteIndex` dosya basi
      // yorumu); burasi sicak yolda SADECE okur, string arama yapmaz.
      // Eksik girdi (kurulum hatasi) render'i patlatmasin diye 0'a duser.
      ..spriteIndex = world.enemySpriteIndex[config.id] ?? 0
      ..maxHp = config.hp * hpMultiplier
      ..speed = config.speed
      ..radius = config.radius
      ..coreDamage = config.coreDamage
      ..wallAttackInterval = config.wallAttackInterval
      // 0'dan baslar: dusman sur'a VARDIGI anda ilk vurusunu hemen yapar
      // (bkz. MovementSystem "atWall" bolumu); sonraki vuruslar
      // wallAttackInterval'a gore periyodik olur.
      ..wallAttackCooldown = 0
      ..aetherReward = config.aetherReward * rewardMultiplier
      ..isElite = event.isElite
      ..wanderPhase = world.rng.nextDouble() * (2 * math.pi)
      ..atWall = false
      ..x = startX
      ..y = startY
      // prevX/prevY baslangic konumuyla ayni olmali, yoksa dogan dusman
      // ilk render karesinde ekran disindan (0,0'dan) suzulerek gelir
      // (render interpolasyonu prev -> guncel arasini lerp eder).
      ..prevX = startX
      ..prevY = startY;
    enemy.hp = enemy.maxHp;
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
