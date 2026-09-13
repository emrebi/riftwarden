import 'dart:typed_data';

import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/domain/rules/rules.dart';
import 'package:riftwarden/engine/simulation/entities/entities.dart';
import 'package:riftwarden/engine/simulation/pools/entity_pool.dart';
import 'package:riftwarden/engine/simulation/spatial/spatial_hash_grid.dart';

/// Ayni anda alanda bulunabilecek maksimum birlik sayisi.
///
/// Bir savasin tum degisken durumunu tutan kap.
///
/// Sistemler ([BattleSystem] implementasyonlari) bu sinifa
/// [BattleSimulation] uzerinden erisir, kendi ozel durumlarini tasimaz.
/// Boylece tum savas durumu tek yerde toplanir ve save/replay/debug
/// (ilerideki adimlar) tek noktadan okuyabilir.
class BattleWorld {
  BattleWorld._({
    required this.enemies,
    required this.units,
    required this.projectiles,
    required this.enemyGrid,
    required this.unitGrid,
    required this.level,
    required this.content,
    required this.coreHp,
    required this.coreMaxHp,
    required this.coreX,
    required this.coreY,
    required this.aether,
    required this.rng,
    required this.resolvedUnitStats,
    required this.unitStatsIndex,
    required this.spawnSchedule,
    required this._laneOffsets,
    required this._laneWaypointX,
    required this._laneWaypointY,
    required this._laneIndexOfId,
    required this.queryScratch,
  });

  /// Level'i, icerigi ve baslangic upgrade'lerini kullanarak yeni bir
  /// savas durumu kurar. Bu sadece savas basinda bir kez cagrilir; kurulum
  /// maliyeti (allocation, JSON okuma) burada serbesttir.
  factory BattleWorld.create({
    required LevelConfig level,
    required ContentRegistry content,
    required List<UpgradeConfig> initialUpgrades,
    required int seed,
  }) {
    final rng = RngSource(seed);
    final spawnSchedule = WavePlanner.plan(level, rng);

    // Lane waypoint'leri tek duz Float64List'te tutulur (X ve Y ayri
    // dizilerde). Neden: her karede yuzlerce dusman icin lane bilgisine
    // erisilir; `List<LaneConfig>` + `List<(double,double)>` gezmek her
    // erisimde nesne dereferansi ve olasi kutu (boxing) demektir. Duz
    // dizi + offset tablosu ise index'li, cache-dostu, allocation'siz
    // erisim saglar. `laneOffsets[i]..laneOffsets[i+1]` o lane'in
    // waypoint araligini verir.
    var totalWaypoints = 0;
    for (final lane in level.lanes) {
      totalWaypoints += lane.waypoints.length;
    }
    final laneOffsets = Int32List(level.lanes.length + 1);
    final laneWaypointX = Float64List(totalWaypoints);
    final laneWaypointY = Float64List(totalWaypoints);
    final laneIndexOfId = <String, int>{};

    var cursor = 0;
    for (var i = 0; i < level.lanes.length; i++) {
      final lane = level.lanes[i];
      laneIndexOfId[lane.id] = i;
      laneOffsets[i] = cursor;
      for (final point in lane.waypoints) {
        laneWaypointX[cursor] = point.$1;
        laneWaypointY[cursor] = point.$2;
        cursor++;
      }
    }
    laneOffsets[level.lanes.length] = cursor;

    // Birlik stat cozumlemesi: her unit tipi icin tek bir ResolvedStats
    // blogu, indeksle referanslanir (bkz. UnitEntity.statsIndex yorumu).
    final unitIds = content.units.keys.toList(growable: false);
    final unitStatsIndex = <String, int>{};
    for (var i = 0; i < unitIds.length; i++) {
      unitStatsIndex[unitIds[i]] = i;
    }
    final resolvedUnitStats = List<ResolvedStats>.generate(
      unitIds.length,
      (i) => StatResolver.resolveUnit(content.unit(unitIds[i]), initialUpgrades),
      growable: false,
    );

    return BattleWorld._(
      enemies: EntityPool<EnemyEntity>(level.maxEnemies, EnemyEntity.new),
      units: EntityPool<UnitEntity>(kUnitPoolCapacity, UnitEntity.new),
      projectiles:
          EntityPool<ProjectileEntity>(level.maxProjectiles, ProjectileEntity.new),
      enemyGrid: SpatialHashGrid(cellSize: kSpatialCellSize, capacity: level.maxEnemies),
      unitGrid: SpatialHashGrid(cellSize: kSpatialCellSize, capacity: kUnitPoolCapacity),
      level: level,
      content: content,
      coreHp: level.coreHp,
      coreMaxHp: level.coreHp,
      // Core konumu sabittir: tum level'larda savunulan yapi ayni yerde
      // durur, sadece dusman lane'leri farklilasir.
      coreX: 0.5,
      coreY: 0.86,
      aether: level.startingAether.toInt(),
      rng: rng,
      resolvedUnitStats: resolvedUnitStats,
      unitStatsIndex: unitStatsIndex,
      spawnSchedule: spawnSchedule,
      // `this._alan` initializing formal'inin cagri sitesindeki adi hala
      // public isimdir (Dart kurali); ozel alan sadece sinif govdesinde
      // ozeldir.
      laneOffsets: laneOffsets,
      laneWaypointX: laneWaypointX,
      laneWaypointY: laneWaypointY,
      laneIndexOfId: laneIndexOfId,
      queryScratch: Int32List(kMaxQueryResults),
    );
  }

  final EntityPool<EnemyEntity> enemies;
  final EntityPool<UnitEntity> units;
  final EntityPool<ProjectileEntity> projectiles;

  final SpatialHashGrid enemyGrid;
  final SpatialHashGrid unitGrid;

  final LevelConfig level;

  /// Unit config'lerine ve stat cozumlemesine erismek icin. Sadece
  /// kurulumda ve upgrade alindiginda ([rebuildUnitStats]) kullanilir,
  /// savas sicak yolunda degil.
  final ContentRegistry content;

  double coreHp;
  double coreMaxHp;
  final double coreX;
  final double coreY;

  int aether;

  final RngSource rng;

  /// Unit tipi basina cozulmus stat + davranis bloklari. Indeks
  /// [unitStatsIndex] uzerinden bulunur (bkz. UnitEntity.statsIndex).
  final List<ResolvedStats> resolvedUnitStats;

  /// `configId` -> [resolvedUnitStats] indeksi.
  final Map<String, int> unitStatsIndex;

  /// Zaman sirali spawn takvimi. [nextSpawnIndex] motorun nereye kadar
  /// tukettigini isaretler.
  final List<SpawnEvent> spawnSchedule;
  int nextSpawnIndex = 0;

  final Int32List _laneOffsets;
  final Float64List _laneWaypointX;
  final Float64List _laneWaypointY;
  final Map<String, int> _laneIndexOfId;

  /// Spatial sorgu sonuclarinin yazildigi paylasilan tampon. Sorgu basina
  /// liste olusturmamak icin kurulumda bir kez ayrilir; cagiran sonucu
  /// kullanir kullanmaz (ayni adim icinde) bir sonraki sorgu ustune yazar.
  final Int32List queryScratch;

  /// Bu adimda Core'a ULASMADAN havuzdan cikan (yani "oldurulen") dusman
  /// sayisi. [CompactionSystem] her adim basinda sifirlar ve compact
  /// callback'inde artirir. Sapma (10a brief disina cikilan tek nokta):
  /// ekonomi sistemi henuz yok, bu sayac sadece ileride "oldurulen dusman
  /// basina Aether/XP" hesaplayacak sisteme veri saglamak icin burada.
  int killsThisStep = 0;

  /// Bir lane'in kac waypoint'i oldugu.
  int laneWaypointCount(int laneIndex) =>
      _laneOffsets[laneIndex + 1] - _laneOffsets[laneIndex];

  /// Bir lane'in [waypointIndex]. waypoint'inin X koordinati.
  double laneWaypointX(int laneIndex, int waypointIndex) =>
      _laneWaypointX[_laneOffsets[laneIndex] + waypointIndex];

  /// Bir lane'in [waypointIndex]. waypoint'inin Y koordinati.
  double laneWaypointY(int laneIndex, int waypointIndex) =>
      _laneWaypointY[_laneOffsets[laneIndex] + waypointIndex];

  /// `LaneConfig.id` -> lane indeksi. Spawn sistemi (adim 10) `SpawnEvent
  /// .laneId` degerini bu indekse cevirip `EnemyEntity.laneIndex`'e yazar.
  int laneIndexOfId(String id) {
    final index = _laneIndexOfId[id];
    if (index == null) {
      throw StateError('BattleWorld: bilinmeyen lane id: "$id"');
    }
    return index;
  }

  /// Bir upgrade alindiginda cagrilir; [resolvedUnitStats] listesini
  /// yeniden hesaplar. **Kare basina DEGIL** — sadece upgrade seti
  /// degistiginde (bkz. StatResolver dosya basi yorumu).
  void rebuildUnitStats(List<UpgradeConfig> taken) {
    for (final entry in unitStatsIndex.entries) {
      resolvedUnitStats[entry.value] =
          StatResolver.resolveUnit(content.unit(entry.key), taken);
    }
  }

  /// Spatial grid'leri bu adimin guncel konumlariyla yeniden kurar.
  ///
  /// [SystemPhase.spatialIndex] fazinda, spawn'dan sonra hedefleme ve
  /// hareketten once cagrilir. Grid dizinleri sadece bu adim icinde
  /// gecerlidir (bkz. SpatialHashGrid dosya basi yorumu).
  void rebuildSpatialIndex() {
    enemyGrid.clear();
    for (var i = 0; i < enemies.activeCount; i++) {
      final enemy = enemies[i];
      enemyGrid.add(i, enemy.x, enemy.y);
    }
    enemyGrid.build();

    unitGrid.clear();
    for (var i = 0; i < units.activeCount; i++) {
      final unit = units[i];
      unitGrid.add(i, unit.x, unit.y);
    }
    unitGrid.build();
  }
}
