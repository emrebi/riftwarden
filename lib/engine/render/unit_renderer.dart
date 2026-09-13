import 'dart:ui';

import 'package:flame/components.dart' show Component;
import 'package:flame/sprite.dart' show SpriteBatch;
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Savunma birlikleri render'i.
///
/// [BattleWorld]'u SADECE OKUR; simulasyon durumunu degistirmez.
class UnitRenderer extends Component {
  UnitRenderer({
    required this.world,
    required this.sim,
    required this.atlas,
    required this.projection,
  });

  final BattleWorld world;
  final BattleSimulation sim;
  final AtlasRegistry atlas;
  final FieldProjection projection;

  /// Bkz. `SwarmRenderer._spriteRadiusFactor` ile ayni gerekce: gorsel
  /// boyut carpisma yaricapinin sabit bir katidir.
  static const double _spriteRadiusFactor = 3.2;
  static const double _frameSize = 128;

  /// Tek batch ornegi; component omru boyunca yeniden kullanilir.
  late final SpriteBatch _batch = SpriteBatch(atlas.imageOf('units'));

  @override
  void render(Canvas canvas) {
    _batch.clear();

    final units = world.units;
    final alpha = sim.alpha;

    for (var i = 0; i < units.activeCount; i++) {
      final unit = units[i];

      final screenX = projection.toScreenX(projection.lerp(unit.prevX, unit.x, alpha));
      final screenY = projection.toScreenY(projection.lerp(unit.prevY, unit.y, alpha));

      // Birlik yaricapi icerikte tutulmaz (bkz. UnitConfig — savunma
      // birliklerinin gorsel boyutu dengeleme parametresi degildir); sabit
      // bir taban yaricap kullanilir.
      const baseRadius = 0.028;
      final visualSize = projection.toScreenSize(baseRadius * _spriteRadiusFactor);
      final scale = visualSize / _frameSize;

      final source = atlas.rectOf('units', unit.spriteIndex);

      _batch.addTransform(
        source: source,
        transform: RSTransform.fromComponents(
          rotation: 0,
          scale: scale,
          anchorX: source.width / 2,
          anchorY: source.height / 2,
          translateX: screenX,
          translateY: screenY,
        ),
      );
    }

    // Hicbir batch ogesine renk verilmedigi icin (bkz. yukarida `color`
    // parametresinin atlanmasi) blend modu GEREKMEZ — `SpriteBatch.render`
    // bunu zorunlu kilmaz (bkz. kaynak: `hasNoColors` kisayolu).
    _batch.render(canvas);
  }
}
