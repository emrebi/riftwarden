/// Bir level'in kale referansi: hangi `castles.json` girdisi kullanilacagi
/// ve o level'a ozel can puani (kale gorseli/yuvalari `castles.json`da
/// paylasilir, can puani level'a gore olcekler).
class CastleRef {
  const CastleRef({
    required this.id,
    required this.hp,
  });

  factory CastleRef.fromJson(String levelId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'CastleRef (level $levelId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    return CastleRef(
      id: require('id') as String,
      hp: (require('hp') as num).toDouble(),
    );
  }

  final String id;
  final double hp;
}

/// Dusman spawn bandi: sag kenarin hemen disinda, bu Y araliginda rastgele
/// yukseklikte dogar (bkz. `docs/CONTENT_SCHEMA.md`).
class SpawnConfig {
  const SpawnConfig({
    required this.yMin,
    required this.yMax,
    required this.riftSkin,
    required this.riftCount,
  });

  factory SpawnConfig.fromJson(String levelId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'SpawnConfig (level $levelId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    return SpawnConfig(
      yMin: (require('yMin') as num).toDouble(),
      yMax: (require('yMax') as num).toDouble(),
      riftSkin: require('riftSkin') as String,
      riftCount: (require('riftCount') as num).toInt(),
    );
  }

  final double yMin;
  final double yMax;
  final String riftSkin;
  final int riftCount;
}

/// Bir arazi alani. Pathfinding YOKTUR; sadece alan icindeki dusmana
/// `slowFactor` veya `damageTakenMul` uygulanir (bkz. `docs/CONTENT_SCHEMA.md`).
class TerrainZoneConfig {
  const TerrainZoneConfig({
    required this.type,
    required this.x,
    required this.y,
    required this.radius,
    this.factor,
    this.damageTakenMul,
  });

  factory TerrainZoneConfig.fromJson(String levelId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'TerrainZoneConfig (level $levelId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    final type = require('type') as String;
    if (type != 'slow' && type != 'cover') {
      throw FormatException(
        'TerrainZoneConfig (level $levelId): bilinmeyen type: "$type"',
      );
    }

    return TerrainZoneConfig(
      type: type,
      x: (require('x') as num).toDouble(),
      y: (require('y') as num).toDouble(),
      radius: (require('radius') as num).toDouble(),
      factor: type == 'slow' ? (require('factor') as num).toDouble() : null,
      damageTakenMul:
          type == 'cover' ? (require('damageTakenMul') as num).toDouble() : null,
    );
  }

  final String type;
  final double x;
  final double y;
  final double radius;

  /// Sadece `type == 'slow'` icin dolu: hiz carpani (0..1).
  final double? factor;

  /// Sadece `type == 'cover'` icin dolu: alinan hasar carpani (0..1).
  final double? damageTakenMul;
}

/// Bir dalga (wave) icindeki tek bir dusman grubu.
class WaveGroupConfig {
  const WaveGroupConfig({
    required this.enemy,
    required this.count,
    required this.interval,
    required this.delay,
    required this.eliteChance,
    required this.band,
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

    final bandJson = json['band'] as List<Object?>?;
    (double, double)? band;
    if (bandJson != null) {
      if (bandJson.length != 2) {
        throw FormatException(
          'WaveGroupConfig (level $levelId): band [yMin,yMax] cifti olmali: $bandJson',
        );
      }
      band = (
        (bandJson[0]! as num).toDouble(),
        (bandJson[1]! as num).toDouble(),
      );
    }

    return WaveGroupConfig(
      enemy: require('enemy') as String,
      count: (require('count') as num).toInt(),
      interval: (require('interval') as num).toDouble(),
      // grup ici ek gecikme; cogu grup icin 0.
      delay: ((json['delay'] as num?) ?? 0.0).toDouble(),
      eliteChance: ((json['eliteChance'] as num?) ?? 0.0).toDouble(),
      // opsiyonel: grubun kendi spawn bandi. Yoksa level.spawn kullanilir
      // (bkz. WavePlanner).
      band: band,
    );
  }

  final String enemy;
  final int count;
  final double interval;
  final double delay;
  final double eliteChance;
  final (double, double)? band;
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
    required this.castle,
    required this.startingAether,
    required this.difficultyMultiplier,
    required this.maxEnemies,
    required this.maxProjectiles,
    required this.spawn,
    required this.defenseLineX,
    required this.terrain,
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

    final castleJson = require('castle') as Map<String, Object?>;
    final spawnJson = require('spawn') as Map<String, Object?>;
    final terrainJson = (json['terrain'] as List<Object?>?) ?? const <Object?>[];
    final wavesJson = require('waves') as List<Object?>;
    final rewardsJson = require('rewards') as Map<String, Object?>;

    return LevelConfig(
      levelId: levelId,
      environmentId: require('environmentId') as String,
      castle: CastleRef.fromJson(levelIdStr, castleJson),
      startingAether: (require('startingAether') as num).toDouble(),
      difficultyMultiplier: (require('difficultyMultiplier') as num).toDouble(),
      maxEnemies: (require('maxEnemies') as num).toInt(),
      maxProjectiles: (require('maxProjectiles') as num).toInt(),
      spawn: SpawnConfig.fromJson(levelIdStr, spawnJson),
      defenseLineX: (require('defenseLineX') as num).toDouble(),
      terrain: terrainJson
          .map((e) => TerrainZoneConfig.fromJson(levelIdStr, e! as Map<String, Object?>))
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
  final CastleRef castle;
  final double startingAether;
  final double difficultyMultiplier;
  final int maxEnemies;
  final int maxProjectiles;
  final SpawnConfig spawn;
  final double defenseLineX;
  final List<TerrainZoneConfig> terrain;
  final List<String> modifiers;
  final List<WaveConfig> waves;
  final String? boss;
  final LevelRewards rewards;

  /// Motor tarihsel ismini korur (bkz. `docs/CONTENT_SCHEMA.md` basi):
  /// `core*` adlari kale yapisini ifade eder.
  double get coreHp => castle.hp;
}
