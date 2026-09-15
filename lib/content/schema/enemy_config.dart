/// Bir dusman turu tanimi.
///
/// `enemies.json` icindeki her girdi bu sinifa parse edilir. `behavior`
/// degerleri `docs/CONTENT_SCHEMA.md` > "enemies.json" tablosunda listelidir;
/// karsilik gelen davranis `lib/engine/simulation/behaviors/` altinda kayitlidir.
class EnemyConfig {
  const EnemyConfig({
    required this.id,
    required this.name,
    required this.sprite,
    required this.hp,
    required this.speed,
    required this.coreDamage,
    required this.wallAttackInterval,
    required this.aetherReward,
    required this.radius,
    required this.behavior,
    required this.flags,
  });

  factory EnemyConfig.fromJson(String id, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException('EnemyConfig "$id": zorunlu alan eksik: "$field"');
      }
      return value;
    }

    return EnemyConfig(
      id: id,
      name: require('name') as String,
      sprite: require('sprite') as String,
      hp: (require('hp') as num).toDouble(),
      speed: (require('speed') as num).toDouble(),
      coreDamage: (require('coreDamage') as num).toDouble(),
      // sur'a vurus araligi (saniye); eksikse 1.0.
      wallAttackInterval: ((json['wallAttackInterval'] as num?) ?? 1.0).toDouble(),
      aetherReward: (require('aetherReward') as num).toDouble(),
      radius: (require('radius') as num).toDouble(),
      // varsayilan davranis "march" (sola ilerle, sur'da dur, kaleye hasar ver).
      behavior: (json['behavior'] as String?) ?? 'march',
      flags: (json['flags'] as List<Object?>?)?.cast<String>() ?? const <String>[],
    );
  }

  final String id;
  final String name;
  final String sprite;
  final double hp;
  final double speed;
  final double coreDamage;
  final double wallAttackInterval;
  final double aetherReward;
  final double radius;
  final String behavior;
  final List<String> flags;
}
