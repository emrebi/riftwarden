/// Bir birligin hedef secerken izledigi oncelik.
///
/// Savasci yuvada sabit durur; sinira giren dusmanlardan hangisini
/// hedefleyecegini bu deger belirler (bkz. `TargetingSystem`).
enum TargetPriority {
  /// Sinira (`defenseLineX`) en yakin dusman — sur'u ilk vurani onceler.
  nearestWall,

  /// Savascinin kendisine en yakin dusman.
  nearest,

  /// En yuksek can'a sahip dusman.
  strongest;

  static TargetPriority fromJson(String value) => switch (value) {
        'nearestWall' => TargetPriority.nearestWall,
        'nearest' => TargetPriority.nearest,
        'strongest' => TargetPriority.strongest,
        _ => throw FormatException('TargetPriority: bilinmeyen deger: "$value"'),
      };
}

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
    required this.radius,
    required this.projectile,
    required this.targetPriority,
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
      radius: (require('radius') as num).toDouble(),
      // null = yakin dovus; projectile atlas/id bilgisi tasimaz, sadece id.
      projectile: json['projectile'] as String?,
      targetPriority: TargetPriority.fromJson(require('targetPriority') as String),
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
  final double radius;
  final String? projectile;
  final TargetPriority targetPriority;
}
