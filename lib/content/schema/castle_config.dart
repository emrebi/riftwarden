/// Bir kale (motor icinde `core`) tanimi.
///
/// `castles.json` icindeki her girdi bu sinifa parse edilir. Kale sabit
/// konumda durur, ustunde savasci yuvalari ([slots]) tasir; dusman
/// [wallX]'e varinca durup sur'a saldirir (bkz. `docs/CONTENT_SCHEMA.md`).
class CastleConfig {
  const CastleConfig({
    required this.id,
    required this.sprite,
    required this.x,
    required this.y,
    required this.wallX,
    required this.slots,
  });

  factory CastleConfig.fromJson(String id, Map<String, Object?> json) {
    Object? require(String field) {
      final value = json[field];
      if (value == null) {
        throw FormatException('CastleConfig "$id": zorunlu alan eksik: "$field"');
      }
      return value;
    }

    final slotsJson = require('slots') as List<Object?>;
    if (slotsJson.isEmpty) {
      throw FormatException('CastleConfig "$id": "slots" en az bir eleman icermeli');
    }

    return CastleConfig(
      id: id,
      sprite: require('sprite') as String,
      x: (require('x') as num).toDouble(),
      y: (require('y') as num).toDouble(),
      wallX: (require('wallX') as num).toDouble(),
      slots: slotsJson.map((point) {
        final pair = point! as List<Object?>;
        if (pair.length != 2) {
          throw FormatException(
            'CastleConfig "$id": slot [x,y] cifti olmali: $point',
          );
        }
        return (
          (pair[0]! as num).toDouble(),
          (pair[1]! as num).toDouble(),
        );
      }).toList(growable: false),
    );
  }

  final String id;
  final String sprite;
  final double x;
  final double y;
  final double wallX;
  final List<(double, double)> slots;
}
