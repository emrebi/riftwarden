/// Bir sektor tanimi (tema, ortam, kilit acma kosulu).
///
/// `sectors.json` icindeki her girdi bu sinifa parse edilir. Anahtar
/// sektor numarasidir (string "1", "2", ...); [id] olarak int'e cevrilir.
class SectorConfig {
  const SectorConfig({
    required this.id,
    required this.name,
    required this.environmentId,
    required this.background,
    required this.riftSkin,
    required this.paletteAccent,
    required this.paletteFog,
    required this.unlockAfterLevel,
  });

  factory SectorConfig.fromJson(int id, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException('SectorConfig "$id": zorunlu alan eksik: "$field"');
      }
      return value;
    }

    final palette = require('palette') as Map<String, Object?>;
    Object? requirePalette(String field) {
      final value = palette[field];
      if (value == null) {
        throw FormatException(
          'SectorConfig "$id": zorunlu alan eksik: "palette.$field"',
        );
      }
      return value;
    }

    return SectorConfig(
      id: id,
      name: require('name') as String,
      environmentId: require('environmentId') as String,
      background: require('background') as String,
      riftSkin: require('riftSkin') as String,
      paletteAccent: requirePalette('accent') as String,
      paletteFog: requirePalette('fog') as String,
      unlockAfterLevel: (require('unlockAfterLevel') as num).toInt(),
    );
  }

  final int id;
  final String name;
  final String environmentId;
  final String background;
  final String riftSkin;
  final String paletteAccent;
  final String paletteFog;
  final int unlockAfterLevel;
}
