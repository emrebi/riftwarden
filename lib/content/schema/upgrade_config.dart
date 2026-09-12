/// Bir stat degistiricinin uygulama bicimi.
///
/// `add` degerleri once, `mul` degerleri sonra uygulanir (bkz.
/// `docs/CONTENT_SCHEMA.md` > "upgrades.json").
enum StatOp {
  add,
  mul;

  static StatOp fromJson(String value) => switch (value) {
        'add' => StatOp.add,
        'mul' => StatOp.mul,
        _ => throw FormatException('StatOp: bilinmeyen deger: "$value"'),
      };
}

/// Upgrade nadirligi. Havuzdaki agirlik hesaplarinda ve UI renginde kullanilir.
enum UpgradeRarity {
  common,
  rare,
  epic,
  legendary;

  static UpgradeRarity fromJson(String value) => switch (value) {
        'common' => UpgradeRarity.common,
        'rare' => UpgradeRarity.rare,
        'epic' => UpgradeRarity.epic,
        'legendary' => UpgradeRarity.legendary,
        _ => throw FormatException('UpgradeRarity: bilinmeyen deger: "$value"'),
      };
}

/// Tek bir sayisal stat degisikligi.
///
/// `target`: bir unit id'si, veya `all` (tum birlikler), `core`, `economy`,
/// `ability`. Dogrulamasi icerik testinde yapilir, burada serbest string'tir
/// (unit id listesi runtime'da registry'den gelir, burada bilinmez).
class StatModifier {
  const StatModifier({
    required this.target,
    required this.stat,
    required this.op,
    required this.value,
  });

  factory StatModifier.fromJson(String upgradeId, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException(
          'StatModifier ($upgradeId): zorunlu alan eksik: "$field"',
        );
      }
      return value;
    }

    return StatModifier(
      target: require('target') as String,
      stat: require('stat') as String,
      op: StatOp.fromJson(require('op') as String),
      value: (require('value') as num).toDouble(),
    );
  }

  final String target;
  final String stat;
  final StatOp op;
  final double value;
}

/// Bir upgrade karti tanimi.
///
/// Upgrade'ler iki sekilde etki eder: sayisal (`stats`) ve davranissal
/// (`flags`). Sadece sayisal yigin istenmiyor; her aile en az bir davranis
/// degistirici icermeli (bkz. brief). `flags` degerleri
/// `lib/domain/rules/behavior_flags.dart` icinde kayitlidir.
class UpgradeConfig {
  const UpgradeConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.family,
    required this.rarity,
    required this.requires,
    required this.maxStacks,
    required this.weight,
    required this.stats,
    required this.flags,
  });

  factory UpgradeConfig.fromJson(String id, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException('UpgradeConfig "$id": zorunlu alan eksik: "$field"');
      }
      return value;
    }

    final statsJson = (json['stats'] as List<Object?>?) ?? const <Object?>[];

    return UpgradeConfig(
      id: id,
      name: require('name') as String,
      description: require('description') as String,
      icon: require('icon') as String,
      family: require('family') as String,
      rarity: UpgradeRarity.fromJson(require('rarity') as String),
      requires: (json['requires'] as List<Object?>?)?.cast<String>() ??
          const <String>[],
      maxStacks: (json['maxStacks'] as num?)?.toInt() ?? 1,
      weight: (require('weight') as num).toDouble(),
      stats: statsJson
          .map((e) => StatModifier.fromJson(id, e! as Map<String, Object?>))
          .toList(growable: false),
      flags: (json['flags'] as List<Object?>?)?.cast<String>() ?? const <String>[],
    );
  }

  final String id;
  final String name;
  final String description;
  final String icon;
  final String family;
  final UpgradeRarity rarity;
  final List<String> requires;
  final int maxStacks;
  final double weight;
  final List<StatModifier> stats;
  final List<String> flags;
}
