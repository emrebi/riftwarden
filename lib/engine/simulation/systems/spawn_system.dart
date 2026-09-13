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

/// Atlas gelene kadar sprite indeksi icin kullanilan yer tutucu araligi.
/// Deger onemsizdir (render katmani heniz atlas kullanmiyor); sadece
/// ayni configId'nin her zaman ayni indeksi almasini saglar.
const int kSpriteIndexPlaceholderRange = 64;

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
    final laneIndex = world.laneIndexOfId(event.laneId);

    // Baslangic konumu: lane'in ciktigi rift. `LaneConfig.from` bir rift
    // id'sine isaret eder; level basina rift sayisi az oldugu icin
    // dogrusal arama burada kabul edilebilir (spawn, her karede degil
    // sadece zamanlanmis olaylarda calisir).
    final lane = world.level.lanes[laneIndex];
    var startX = world.laneWaypointX(laneIndex, 0);
    var startY = world.laneWaypointY(laneIndex, 0);
    for (var i = 0; i < world.level.rifts.length; i++) {
      final rift = world.level.rifts[i];
      if (rift.id == lane.from) {
        startX = rift.x;
        startY = rift.y;
        break;
      }
    }

    final hpMultiplier =
        world.level.difficultyMultiplier * (event.isElite ? kEliteHpMultiplier : 1.0);
    final rewardMultiplier = event.isElite ? kEliteRewardMultiplier : 1.0;

    enemy
      ..configId = config.id
      ..spriteIndex = _spriteIndexFor(config.id)
      ..maxHp = config.hp * hpMultiplier
      ..speed = config.speed
      ..radius = config.radius
      ..coreDamage = config.coreDamage
      ..aetherReward = config.aetherReward * rewardMultiplier
      ..isElite = event.isElite
      ..laneIndex = laneIndex
      // Lane'in ilk waypoint'i hedeftir; hareket sistemi buradan devam eder.
      ..waypointIndex = 0
      ..x = startX
      ..y = startY
      // prevX/prevY baslangic konumuyla ayni olmali, yoksa dogan dusman
      // ilk render karesinde ekran disindan (0,0'dan) suzulerek gelir
      // (render interpolasyonu prev -> guncel arasini lerp eder).
      ..prevX = startX
      ..prevY = startY;
    enemy.hp = enemy.maxHp;
  }

  /// Atlas henuz yok (bkz. CLAUDE.md tuzaklar). `configId`'nin hash'inden
  /// deterministik bir "kare" indeksi turetiyoruz: ayni configId her
  /// zaman ayni indeksi alir, ama gercek bir atlas sirasina karsilik
  /// gelmez. Atlas eklendiginde bu fonksiyon content siralamasina
  /// (`ContentRegistry.enemies` anahtar sirasi) gore gercek indeks
  /// donecek sekilde degistirilecek.
  int _spriteIndexFor(String configId) {
    return (configId.hashCode & 0x7fffffff) % kSpriteIndexPlaceholderRange;
  }

  @override
  void onBattleEnd(BattleSimulation sim) {}
}
