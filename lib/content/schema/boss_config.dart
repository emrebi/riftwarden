/// Bir boss fazi. HP esigi altina dusunce mekanikler degisir.
///
/// `mechanics` degerleri `lib/engine/simulation/systems/boss_system.dart`
/// icinde kayitlidir. Boss sadece buyuk HP barindan ibaret olmamali; her
/// fazda en az bir mekanik degismeli (denge kurali, brief'te belirtildi).
class BossPhaseConfig {
  const BossPhaseConfig({
    required this.hpThreshold,
    required this.mechanics,
  });

  factory BossPhaseConfig.fromJson(String bossId, Map<String, Object?> json) {
    final threshold = json['hpThreshold'];
    if (threshold == null) {
      throw FormatException(
        'BossPhaseConfig ($bossId): zorunlu alan eksik: "hpThreshold"',
      );
    }
    final mechanicsJson = (json['mechanics'] as List<Object?>?) ?? const <Object?>[];

    return BossPhaseConfig(
      hpThreshold: (threshold as num).toDouble(),
      mechanics: mechanicsJson.cast<String>(),
    );
  }

  final double hpThreshold;
  final List<String> mechanics;
}

/// Bir boss tanimi.
///
/// `bosses.json` icindeki her girdi bu sinifa parse edilir. Adim 15'e
/// kadar dosya bos ({}) kalabilir; sema hazir tutulur.
class BossConfig {
  const BossConfig({
    required this.id,
    required this.name,
    required this.sprite,
    required this.hp,
    required this.radius,
    required this.phases,
  });

  factory BossConfig.fromJson(String id, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException('BossConfig "$id": zorunlu alan eksik: "$field"');
      }
      return value;
    }

    final phasesJson = (json['phases'] as List<Object?>?) ?? const <Object?>[];

    return BossConfig(
      id: id,
      name: require('name') as String,
      sprite: require('sprite') as String,
      hp: (require('hp') as num).toDouble(),
      radius: (require('radius') as num).toDouble(),
      phases: phasesJson
          .map((e) => BossPhaseConfig.fromJson(id, e! as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  final String id;
  final String name;
  final String sprite;
  final double hp;
  final double radius;
  final List<BossPhaseConfig> phases;
}
