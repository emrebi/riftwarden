/// Bir rift (dusman spawn noktasi).
///
/// Koordinatlar normalize 0..1 uzayindadir (bkz. `docs/CONTENT_SCHEMA.md`).
class RiftConfig {
  const RiftConfig({
    required this.id,
    required this.x,
    required this.y,
    required this.skin,
  });

  factory RiftConfig.fromJson(String levelId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'RiftConfig (level $levelId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    return RiftConfig(
      id: require('id') as String,
      x: (require('x') as num).toDouble(),
      y: (require('y') as num).toDouble(),
      skin: require('skin') as String,
    );
  }

  final String id;
  final double x;
  final double y;
  final String skin;
}

/// Bir lane (dusman yolu). Pathfinding YOKTUR; dusmanlar bu waypoint
/// zincirini birebir takip eder.
class LaneConfig {
  const LaneConfig({
    required this.id,
    required this.from,
    required this.waypoints,
  });

  factory LaneConfig.fromJson(String levelId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'LaneConfig (level $levelId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    final waypointsJson = require('waypoints') as List<Object?>;

    return LaneConfig(
      id: require('id') as String,
      from: require('from') as String,
      waypoints: waypointsJson.map((point) {
        final pair = point! as List<Object?>;
        if (pair.length != 2) {
          throw FormatException(
            'LaneConfig (level $levelId): waypoint [x,y] cifti olmali: $point',
          );
        }
        return (
          (pair[0]! as num).toDouble(),
          (pair[1]! as num).toDouble(),
        );
      }).toList(growable: false),
    );
  }

  final String id;
  final String from;
  final List<(double, double)> waypoints;
}

/// Bir dalga (wave) icindeki tek bir dusman grubu.
class WaveGroupConfig {
  const WaveGroupConfig({
    required this.enemy,
    required this.count,
    required this.interval,
    required this.lane,
    required this.delay,
    required this.eliteChance,
  });

  factory WaveGroupConfig.fromJson(String levelId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'WaveGroupConfig (level $levelId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    return WaveGroupConfig(
      enemy: require('enemy') as String,
      count: (require('count') as num).toInt(),
      interval: (require('interval') as num).toDouble(),
      lane: require('lane') as String,
      // grup ici ek gecikme; cogu grup icin 0.
      delay: ((json['delay'] as num?) ?? 0.0).toDouble(),
      eliteChance: ((json['eliteChance'] as num?) ?? 0.0).toDouble(),
    );
  }

  final String enemy;
  final int count;
  final double interval;
  final String lane;
  final double delay;
  final double eliteChance;
}

/// Bir dalga (wave). Onceki dalga bitince `delay` kadar beklenip baslar.
class WaveConfig {
  const WaveConfig({
    required this.id,
    required this.delay,
    required this.groups,
  });

  factory WaveConfig.fromJson(String levelId, Map<String, Object?> json) {
    final id = json['id'];
    if (id == null) {
      throw FormatException('WaveConfig (level $levelId): zorunlu alan eksik: "id"');
    }
    final groupsJson = json['groups'] as List<Object?>?;
    if (groupsJson == null) {
      throw FormatException(
        'WaveConfig (level $levelId, dalga $id): zorunlu alan eksik: "groups"',
      );
    }

    return WaveConfig(
      id: (id as num).toInt(),
      delay: ((json['delay'] as num?) ?? 0.0).toDouble(),
      groups: groupsJson
          .map((e) => WaveGroupConfig.fromJson(levelId, e! as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  final int id;
  final double delay;
  final List<WaveGroupConfig> groups;
}

/// Level tamamlanma odulleri.
class LevelRewards {
  const LevelRewards({
    required this.shards,
    required this.firstClearCells,
  });

  factory LevelRewards.fromJson(String levelId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'LevelRewards (level $levelId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    return LevelRewards(
      shards: (require('shards') as num).toInt(),
      firstClearCells: (require('firstClearCells') as num).toInt(),
    );
  }

  final int shards;
  final int firstClearCells;
}

/// Bir level tanimi. `levels/sector_NN.json` icindeki `levels` listesinin
/// her elemani bu sinifa parse edilir.
class LevelConfig {
  const LevelConfig({
    required this.levelId,
    required this.environmentId,
    required this.coreHp,
    required this.startingAether,
    required this.difficultyMultiplier,
    required this.maxEnemies,
    required this.maxProjectiles,
    required this.rifts,
    required this.lanes,
    required this.modifiers,
    required this.waves,
    required this.boss,
    required this.rewards,
  });

  factory LevelConfig.fromJson(Map<String, Object?> json) {
    final rawLevelId = json['levelId'];
    if (rawLevelId == null) {
      throw const FormatException('LevelConfig: zorunlu alan eksik: "levelId"');
    }
    final levelId = (rawLevelId as num).toInt();
    final levelIdStr = levelId.toString();

    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'LevelConfig (level $levelIdStr): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    final riftsJson = require('rifts') as List<Object?>;
    final lanesJson = require('lanes') as List<Object?>;
    final wavesJson = require('waves') as List<Object?>;
    final rewardsJson = require('rewards') as Map<String, Object?>;

    return LevelConfig(
      levelId: levelId,
      environmentId: require('environmentId') as String,
      coreHp: (require('coreHp') as num).toDouble(),
      startingAether: (require('startingAether') as num).toDouble(),
      difficultyMultiplier: (require('difficultyMultiplier') as num).toDouble(),
      maxEnemies: (require('maxEnemies') as num).toInt(),
      maxProjectiles: (require('maxProjectiles') as num).toInt(),
      rifts: riftsJson
          .map((e) => RiftConfig.fromJson(levelIdStr, e! as Map<String, Object?>))
          .toList(growable: false),
      lanes: lanesJson
          .map((e) => LaneConfig.fromJson(levelIdStr, e! as Map<String, Object?>))
          .toList(growable: false),
      modifiers: (json['modifiers'] as List<Object?>?)?.cast<String>() ??
          const <String>[],
      waves: wavesJson
          .map((e) => WaveConfig.fromJson(levelIdStr, e! as Map<String, Object?>))
          .toList(growable: false),
      // boss adim 15'e kadar hep null; sema hazir tutulur.
      boss: json['boss'] as String?,
      rewards: LevelRewards.fromJson(levelIdStr, rewardsJson),
    );
  }

  final int levelId;
  final String environmentId;
  final double coreHp;
  final double startingAether;
  final double difficultyMultiplier;
  final int maxEnemies;
  final int maxProjectiles;
  final List<RiftConfig> rifts;
  final List<LaneConfig> lanes;
  final List<String> modifiers;
  final List<WaveConfig> waves;
  final String? boss;
  final LevelRewards rewards;
}
