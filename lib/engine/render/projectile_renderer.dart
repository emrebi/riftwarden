import 'dart:ui';

import 'package:flame/components.dart' show Component;
import 'package:flame/sprite.dart' show SpriteBatch;
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Mermi render'i.
///
/// [BattleWorld]'u SADECE OKUR; simulasyon durumunu degistirmez.
///
/// Tum mermiler `fx` atlasindaki tek bir kareyi ("pulse_bolt") kullanir:
/// mermi gorseli upgrade davranisina (chain/pierce vb.) gore degil, atisi
/// yapan birlik tipine gore ayrisabilir — bu ayrim adim 13/14'un kapsami
/// (bkz. brief: bu adim SADECE ilk render dogrulamasi). `ProjectileEntity
/// .spriteIndex` zaten var oldugu icin ileride birden fazla kareye
/// gecmek SADECE spawn noktasinda bir satirlik degisiklik gerektirir.
class ProjectileRenderer extends Component {
  ProjectileRenderer({
    required this.world,
    required this.sim,
    required this.atlas,
    required this.projection,
  });

  final BattleWorld world;
  final BattleSimulation sim;
  final AtlasRegistry atlas;
  final FieldProjection projection;

  static const double _spriteRadiusFactor = 4.0;
  static const double _frameSize = 128;

  /// Tek batch ornegi; component omru boyunca yeniden kullanilir.
  late final SpriteBatch _batch = SpriteBatch(atlas.imageOf('fx'));

  @override
  void render(Canvas canvas) {
    _batch.clear();

    final projectiles = world.projectiles;
    final alpha = sim.alpha;

    for (var i = 0; i < projectiles.activeCount; i++) {
      final projectile = projectiles[i];

      final screenX =
          projection.toScreenX(projection.lerp(projectile.prevX, projectile.x, alpha));
      final screenY =
          projection.toScreenY(projection.lerp(projectile.prevY, projectile.y, alpha));

      final visualSize = projection.toScreenSize(projectile.radius * _spriteRadiusFactor);
      final scale = visualSize / _frameSize;

      final source = atlas.rectOf('fx', projectile.spriteIndex);

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

    _batch.render(canvas);
  }
}
