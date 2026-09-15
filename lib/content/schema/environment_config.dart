/// Bir cevre (decor) ogesi: gorsel amaclidir, oynanisi ETKILEMEZ (alan
/// etkisi `TerrainZoneConfig` uzerinden ayrica tanimlanir).
class DecorConfig {
  const DecorConfig({
    required this.sprite,
    required this.x,
    required this.y,
    required this.scale,
  });

  factory DecorConfig.fromJson(String environmentId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'DecorConfig (environment $environmentId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    return DecorConfig(
      sprite: require('sprite') as String,
      x: (require('x') as num).toDouble(),
      y: (require('y') as num).toDouble(),
      scale: ((json['scale'] as num?) ?? 1.0).toDouble(),
    );
  }

  final String sprite;
  final double x;
  final double y;
  final double scale;
}

/// Bir sektorun gorsel zemini ve dekor ogeleri (bkz. `docs/CONTENT_SCHEMA.md`).
class EnvironmentConfig {
  const EnvironmentConfig({
    required this.id,
    required this.background,
    required this.decor,
  });

  factory EnvironmentConfig.fromJson(String id, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException('EnvironmentConfig "$id": zorunlu alan eksik: "$field"');
      }
      return value;
    }

    final decorJson = (json['decor'] as List<Object?>?) ?? const <Object?>[];

    return EnvironmentConfig(
      id: id,
      background: require('background') as String,
      decor: decorJson
          .map((e) => DecorConfig.fromJson(id, e! as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  final String id;
  final String background;
  final List<DecorConfig> decor;
}
