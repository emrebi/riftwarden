/// Bir savas alani modifier'inin tek bir etkisi (stat carpani/toplami).
///
/// `upgrade_config.dart` > `StatModifier` ile ayni sekle sahip ama ayri
/// tutuluyor: modifier `target` alani yok, dogrudan global stat'a uygulanir.
class ModifierEffect {
  const ModifierEffect({
    required this.stat,
    required this.op,
    required this.value,
  });

  factory ModifierEffect.fromJson(String modifierId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'ModifierEffect ($modifierId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    return ModifierEffect(
      stat: require('stat') as String,
      op: require('op') as String,
      value: (require('value') as num).toDouble(),
    );
  }

  final String stat;
  final String op;
  final double value;
}

/// Savas alani modifier'i (ornek: `dense_fog`).
///
/// `modifiers.json` icindeki her girdi bu sinifa parse edilir. Level
/// dosyalarindaki `modifiers` listesi buradaki id'lere referans verir.
class ModifierConfig {
  const ModifierConfig({
    required this.id,
    required this.name,
    required this.effects,
  });

  factory ModifierConfig.fromJson(String id, Map<String, Object?> json) {
    final value = json['name'];
    if (value == null) {
      throw FormatException('ModifierConfig "$id": zorunlu alan eksik: "name"');
    }
    final effectsJson = (json['effects'] as List<Object?>?) ?? const <Object?>[];

    return ModifierConfig(
      id: id,
      name: value as String,
      effects: effectsJson
          .map((e) => ModifierEffect.fromJson(id, e! as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  final String id;
  final String name;
  final List<ModifierEffect> effects;
}
