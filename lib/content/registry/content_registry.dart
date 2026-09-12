import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riftwarden/content/schema/schema.dart';

/// Icerige TEK erisim noktasi. Yuklendikten sonra immutable'dir.
///
/// Neden tek registry: `switch (levelId)` gibi kod-gomulu icerik yasak
/// (bkz. CLAUDE.md kural 8). Tum sistemler dusman/birlik/level bilgisini
/// buradan id ile ister; bilinmeyen id sessizce null donmez, acikca patlar
/// (icerik bozuksa oyun zaten oynanamaz, erken patlama tercih edilir).
class ContentRegistry {
  const ContentRegistry({
    required this.units,
    required this.enemies,
    required this.upgrades,
    required this.abilities,
    required this.bosses,
    required this.modifiers,
    required this.sectors,
    required this.levels,
  });

  final Map<String, UnitConfig> units;
  final Map<String, EnemyConfig> enemies;
  final Map<String, UpgradeConfig> upgrades;
  final Map<String, AbilityConfig> abilities;
  final Map<String, BossConfig> bosses;
  final Map<String, ModifierConfig> modifiers;
  final Map<int, SectorConfig> sectors;
  final Map<int, LevelConfig> levels;

  UnitConfig unit(String id) {
    final config = units[id];
    if (config == null) {
      throw StateError('ContentRegistry: bilinmeyen unit id: "$id"');
    }
    return config;
  }

  EnemyConfig enemy(String id) {
    final config = enemies[id];
    if (config == null) {
      throw StateError('ContentRegistry: bilinmeyen enemy id: "$id"');
    }
    return config;
  }

  UpgradeConfig upgrade(String id) {
    final config = upgrades[id];
    if (config == null) {
      throw StateError('ContentRegistry: bilinmeyen upgrade id: "$id"');
    }
    return config;
  }

  AbilityConfig ability(String id) {
    final config = abilities[id];
    if (config == null) {
      throw StateError('ContentRegistry: bilinmeyen ability id: "$id"');
    }
    return config;
  }

  BossConfig boss(String id) {
    final config = bosses[id];
    if (config == null) {
      throw StateError('ContentRegistry: bilinmeyen boss id: "$id"');
    }
    return config;
  }

  ModifierConfig modifier(String id) {
    final config = modifiers[id];
    if (config == null) {
      throw StateError('ContentRegistry: bilinmeyen modifier id: "$id"');
    }
    return config;
  }

  SectorConfig sector(int id) {
    final config = sectors[id];
    if (config == null) {
      throw StateError('ContentRegistry: bilinmeyen sector id: $id');
    }
    return config;
  }

  LevelConfig level(int id) {
    final config = levels[id];
    if (config == null) {
      throw StateError('ContentRegistry: bilinmeyen level id: $id');
    }
    return config;
  }

  /// Bir sektorun tum level'lari, `levelId`'ye gore sirali.
  List<LevelConfig> levelsOfSector(int sectorId) {
    final result = levels.values
        .where((level) => level.levelId > (sectorId - 1) * 5 && level.levelId <= sectorId * 5)
        .toList()
      ..sort((a, b) => a.levelId.compareTo(b.levelId));
    return result;
  }
}

/// Icerik registry provider'i.
///
/// Gercek ornek burada degil, `bootstrap()` ile `main()` icinde olusturulur
/// ve `ProviderScope.overrides` ile enjekte edilir. Buradaki govde asla
/// calismamali; calisirsa bootstrap'in override etmedigini gosterir.
final Provider<ContentRegistry> contentRegistryProvider = Provider<ContentRegistry>(
  (ref) => throw UnimplementedError('bootstrap tarafindan override edilmeli'),
);
