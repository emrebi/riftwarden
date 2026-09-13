import 'dart:ui';

import 'package:flame/components.dart' show Component;
import 'package:flame/sprite.dart' show SpriteBatch;
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Dusman kalabalik (swarm) render'i.
///
/// Bu component [BattleWorld]'u SADECE OKUR; simulasyon durumunu asla
/// degistirmez (bkz. CLAUDE.md kural: render katmani salt-okunur).
///
/// Sprite atlas karesi kare (128x128) oldugu icin gorsel boyut, dusmanin
/// carpisma yaricapinin sabit bir katidir — bu katsayi ne kadar "buyuk"
/// gorunecegini belirleyen TEK yerdir.
class SwarmRenderer extends Component {
  SwarmRenderer({
    required this.world,
    required this.sim,
    required this.atlas,
    required this.projection,
  });

  final BattleWorld world;
  final BattleSimulation sim;
  final AtlasRegistry atlas;
  final FieldProjection projection;

  /// Sprite'in gorsel boyutu = yaricap * bu katsayi. Yaricap carpisma
  /// alanindan (genelde gorsel sprite'tan kucuk) kucuk kalmasin diye
  /// yaricapin birkac kati genis cizilir.
  static const double _spriteRadiusFactor = 3.2;

  /// Elite dusmanlarin normal olcege gore buyutulme orani. Oyuncu tehlikeyi
  /// hemen anlamali (bkz. brief: "elite dusmanlar gorsel olarak ayrilsin").
  static const double _eliteScaleMultiplier = 1.35;

  static const Color _healthyTint = Color(0xFFFFFFFF);
  static const Color _lowHpTint = Color(0xFFFF3B30);
  static const Color _eliteTint = Color(0xFFCDA6FF);

  /// Tek batch orneği; component omru boyunca yeniden kullanilir. Her
  /// karede sadece `clear()` edilip yeniden doldurulur (bkz. brief:
  /// "Tek SpriteBatch ornegi component omru boyunca yeniden kullanilir").
  late final SpriteBatch _batch = SpriteBatch(atlas.imageOf('enemies'));

  /// Atlas karesinin piksel boyutu. Tum kareler ayni boyutta (128x128,
  /// bkz. `assets/images/atlas/enemies.json`) oldugu icin tek deger yeter.
  static const double _frameSize = 128;

  @override
  void render(Canvas canvas) {
    _batch.clear();

    final enemies = world.enemies;
    final alpha = sim.alpha;

    for (var i = 0; i < enemies.activeCount; i++) {
      final enemy = enemies[i];

      final screenX = projection.toScreenX(projection.lerp(enemy.prevX, enemy.x, alpha));
      final screenY = projection.toScreenY(projection.lerp(enemy.prevY, enemy.y, alpha));

      final visualSize = projection.toScreenSize(enemy.radius * _spriteRadiusFactor);
      var scale = visualSize / _frameSize;
      if (enemy.isElite) scale *= _eliteScaleMultiplier;

      final source = atlas.rectOf('enemies', enemy.spriteIndex);
      final hpRatio = enemy.maxHp > 0 ? (enemy.hp / enemy.maxHp).clamp(0.0, 1.0) : 1.0;
      final baseTint = enemy.isElite ? _eliteTint : _healthyTint;

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
        color: _tintFor(baseTint, hpRatio),
      );
    }

    // Herhangi bir batch ogesine renk verildigi icin `drawAtlas` bir blend
    // modu ister (bkz. `SpriteBatch.render` kaynak yorumu). `modulate`
    // dokuyu renkle CARPAR: beyaz tint = degisiklik yok, kirmiziya kaydikca
    // dokuyu kirmizilastirir.
    _batch.render(canvas, blendMode: BlendMode.modulate);
  }

  /// HP azaldikca [base] renginden kirmiziya dogru kayan tint. Elite'ler
  /// icin taban renk zaten farkli oldugundan (bkz. [_eliteTint]) ayni
  /// hasar geri bildirimi onun uzerine de uygulanir.
  Color _tintFor(Color base, double hpRatio) {
    if (hpRatio >= 1.0) return base;
    return Color.lerp(base, _lowHpTint, 1 - hpRatio)!;
  }
}
