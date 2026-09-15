import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/content/schema/schema.dart';

/// `assets/content/` altindaki JSON dosyalarini okuyup [ContentRegistry]
/// olusturur.
///
/// Neden burada sessizce yutmuyoruz: icerik bozuksa oyun zaten oynanamaz.
/// Her hata hangi dosyada oldugunu soyler; boylece bootstrap asamasinda
/// erken ve net patlar, oyun icinde belirsiz bir crash yerine.
class ContentLoader {
  const ContentLoader({this.basePath = 'assets/content'});

  final String basePath;

  Future<ContentRegistry> load() async {
    final unitsJson = await _readJsonMap('units.json');
    final enemiesJson = await _readJsonMap('enemies.json');
    final upgradesJson = await _readJsonMap('upgrades.json');
    final abilitiesJson = await _readJsonMap('abilities.json');
    final bossesJson = await _readJsonMap('bosses.json');
    final modifiersJson = await _readJsonMap('modifiers.json');
    final sectorsJson = await _readJsonMap('sectors.json');
    final castlesJson = await _readJsonMap('castles.json');
    final environmentsJson = await _readJsonMap('environments.json');

    final units = _parseMap(unitsJson, 'units.json', UnitConfig.fromJson);
    final enemies = _parseMap(enemiesJson, 'enemies.json', EnemyConfig.fromJson);
    final upgrades = _parseMap(upgradesJson, 'upgrades.json', UpgradeConfig.fromJson);
    final abilities = _parseMap(abilitiesJson, 'abilities.json', AbilityConfig.fromJson);
    final bosses = _parseMap(bossesJson, 'bosses.json', BossConfig.fromJson);
    final modifiers = _parseMap(modifiersJson, 'modifiers.json', ModifierConfig.fromJson);
    final castles = _parseMap(castlesJson, 'castles.json', CastleConfig.fromJson);
    final environments =
        _parseMap(environmentsJson, 'environments.json', EnvironmentConfig.fromJson);

    final sectors = <int, SectorConfig>{};
    for (final entry in sectorsJson.entries) {
      final sectorId = int.tryParse(entry.key);
      if (sectorId == null) {
        throw FormatException(
          'sectors.json: sektor anahtari sayi olmali: "${entry.key}"',
        );
      }
      try {
        sectors[sectorId] = SectorConfig.fromJson(
          sectorId,
          entry.value! as Map<String, Object?>,
        );
      } on FormatException catch (error) {
        throw FormatException('sectors.json: ${error.message}');
      }
    }

    // Hangi sektorlerin var oldugunu sectors.json'dan ogren, dosya listesi
    // TAHMIN ETME (brief kurali) -- sectors.json'daki her id icin
    // levels/sector_NN.json okunur.
    final levels = <int, LevelConfig>{};
    for (final sectorId in sectors.keys) {
      final fileName = 'sector_${sectorId.toString().padLeft(2, '0')}.json';
      final path = '$basePath/levels/$fileName';
      final json = await _readJsonMapAt(path);
      final rawLevels = json['levels'];
      if (rawLevels is! List) {
        throw FormatException('$path: "levels" alani liste olmali');
      }
      for (final rawLevel in rawLevels) {
        try {
          final level = LevelConfig.fromJson(rawLevel! as Map<String, Object?>);
          levels[level.levelId] = level;
        } on FormatException catch (error) {
          throw FormatException('$path: ${error.message}');
        }
      }
    }

    return ContentRegistry(
      units: units,
      enemies: enemies,
      upgrades: upgrades,
      abilities: abilities,
      bosses: bosses,
      modifiers: modifiers,
      sectors: sectors,
      levels: levels,
      castles: castles,
      environments: environments,
    );
  }

  Map<String, T> _parseMap<T>(
    Map<String, Object?> json,
    String fileName,
    T Function(String id, Map<String, Object?> json) fromJson,
  ) {
    final result = <String, T>{};
    for (final entry in json.entries) {
      try {
        result[entry.key] = fromJson(entry.key, entry.value! as Map<String, Object?>);
      } on FormatException catch (error) {
        throw FormatException('$fileName: ${error.message}');
      }
    }
    return result;
  }

  Future<Map<String, Object?>> _readJsonMap(String relativeFileName) =>
      _readJsonMapAt('$basePath/$relativeFileName');

  Future<Map<String, Object?>> _readJsonMapAt(String path) async {
    final String raw;
    try {
      raw = await rootBundle.loadString(path);
    } on Exception catch (error) {
      throw FormatException('$path okunamadi: $error');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw FormatException('$path: JSON parse hatasi: ${error.message}');
    }

    if (decoded is! Map<String, Object?>) {
      throw FormatException('$path: kok eleman bir JSON objesi olmali');
    }
    return decoded;
  }
}
