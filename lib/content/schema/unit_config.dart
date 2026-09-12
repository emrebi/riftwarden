/// Bir birlik (yerlestirilebilir savunma unitesi) tanimi.
///
/// `units.json` icindeki her girdi bu sinifa parse edilir. Alan adlari
/// `docs/CONTENT_SCHEMA.md` > "units.json" bolumu ile birebir eslesir.
class UnitConfig {
  const UnitConfig({
    required this.id,
    required this.name,
    required this.sprite,
    required this.cost,
    required this.costGrowth,
    required this.hp,
    required this.damage,
    required this.range,
    required this.attackSpeed,
    required this.moveSpeed,
    required this.radius,
    required this.projectile,
    required this.role,
  });

  factory UnitConfig.fromJson(String id, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException('UnitConfig "$id": zorunlu alan eksik: "$field"');
      }
      return value;
    }

    return UnitConfig(
      id: id,
      name: require('name') as String,
      sprite: require('sprite') as String,
      cost: (require('cost') as num).toDouble(),
      // Buyume carpani her uretimde maliyete uygulanir; eksikse 1.0 (buyume yok).
      costGrowth: ((json['costGrowth'] as num?) ?? 1.0).toDouble(),
      hp: (require('hp') as num).toDouble(),
      damage: (require('damage') as num).toDouble(),
      range: (require('range') as num).toDouble(),
      attackSpeed: (require('attackSpeed') as num).toDouble(),
      moveSpeed: (require('moveSpeed') as num).toDouble(),
      radius: (require('radius') as num).toDouble(),
      // null = yakin dovus; projectile atlas/id bilgisi tasimaz, sadece id.
      projectile: json['projectile'] as String?,
      role: require('role') as String,
    );
  }

  final String id;
  final String name;
  final String sprite;
  final double cost;
  final double costGrowth;
  final double hp;
  final double damage;
  final double range;
  final double attackSpeed;
  final double moveSpeed;
  final double radius;
  final String? projectile;
  final String role;
}
