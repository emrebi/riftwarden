/// Bir aktif yetenek (ability) tanimi.
///
/// `abilities.json` icindeki her girdi bu sinifa parse edilir.
class AbilityConfig {
  const AbilityConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.cooldown,
    required this.radius,
    required this.damage,
    required this.warningTime,
  });

  factory AbilityConfig.fromJson(String id, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException('AbilityConfig "$id": zorunlu alan eksik: "$field"');
      }
      return value;
    }

    return AbilityConfig(
      id: id,
      name: require('name') as String,
      icon: require('icon') as String,
      cooldown: (require('cooldown') as num).toDouble(),
      radius: (require('radius') as num).toDouble(),
      damage: (require('damage') as num).toDouble(),
      // uyari suresi olmayabilir (aninda tetiklenen yetenekler icin).
      warningTime: ((json['warningTime'] as num?) ?? 0.0).toDouble(),
    );
  }

  final String id;
  final String name;
  final String icon;
  final double cooldown;
  final double radius;
  final double damage;
  final double warningTime;
}
