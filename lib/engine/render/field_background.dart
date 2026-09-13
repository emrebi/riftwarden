import 'dart:ui';

import 'package:flame/components.dart' show Component, Vector2;
import 'package:flame/sprite.dart' show SpriteBatch;
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Savas alani zemini: gradyan arka plan, lane cizgileri, rift'ler ve Core.
///
/// [BattleWorld]'u SADECE OKUR; sadece Core'un statik konumunu ve
/// level'in lane/rift geometrisini kullanir (bu geometri savas boyunca
/// DEGISMEZ, bu yuzden lane yollari [onLoad]'da bir kez hesaplanip
/// [_lanePaths] icinde onbelleklenir — render sicak yolunda `Path`
/// yaratilmaz).
///
/// ## Renkler hakkinda
/// `engine/` katmani `features`/`app` import EDEMEZ (bkz. CLAUDE.md kural
/// 2), bu yuzden `app/theme/app_colors.dart` degerleri buraya sabit olarak
/// KOPYALANIR. Bu degerler tema paletiyle ESLESMELI; tema degisirse bu
/// sabitler de elle guncellenmelidir.
class FieldBackground extends Component {
  FieldBackground({
    required this.world,
    required this.atlas,
    required this.projection,
  });

  final BattleWorld world;
  final AtlasRegistry atlas;
  final FieldProjection projection;

  // Bkz. dosya basi "Renkler hakkinda" yorumu — `AppColors.voidDeep` /
  // `AppColors.surfaceRaised` / `AppColors.accentTeal` ile eslesmelidir.
  static const Color _bgTop = Color(0xFF0B0B14);
  static const Color _bgBottom = Color(0xFF181830);
  static const Color _laneColor = Color(0x33FFFFFF);
  static const Color _hpRingTrack = Color(0x40FFFFFF);
  static const Color _hpRingFill = Color(0xFF6FE3C8);

  static const double _coreVisualRadius = 0.055;
  static const double _riftVisualRadius = 0.035;
  static const double _frameSize = 128;
  static const double _hpRingStrokeWidth = 4;
  static const double _hpRingGap = 0.014;

  final Paint _bgPaint = Paint();
  final Paint _lanePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = _laneColor;
  final Paint _hpRingTrackPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _hpRingStrokeWidth
    ..color = _hpRingTrack;
  final Paint _hpRingFillPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _hpRingStrokeWidth
    ..strokeCap = StrokeCap.round
    ..color = _hpRingFill;

  late final SpriteBatch _worldBatch = SpriteBatch(atlas.imageOf('world'));

  /// Lane basina onceden hesaplanmis ekran-uzayi yol. Render sicak
  /// yolunda YENIDEN kurulmaz (bkz. dosya basi yorumu).
  late List<Path> _lanePaths;

  /// [_lanePaths] hangi ekran boyutu icin kuruldu; boyut degisirse
  /// (donme, katlanabilir cihaz) yeniden kurulur.
  Vector2? _lanePathsSize;

  @override
  Future<void> onLoad() async {
    _rebuildForSize(projection.size);
  }

  /// Boyuta bagli her seyi (lane yollari + arka plan gradyani) tek yerde
  /// yeniden kurar. Sadece [onLoad]'da ve [render] icinde boyut
  /// degistiginde cagrilir — render sicak yolunda HER karede DEGIL.
  void _rebuildForSize(Vector2 size) {
    _lanePathsSize = size.clone();

    _bgPaint.shader = Gradient.linear(
      Offset.zero,
      Offset(0, size.y),
      const <Color>[_bgTop, _bgBottom],
    );

    _lanePaths = List<Path>.generate(world.level.lanes.length, (laneIndex) {
      final lane = world.level.lanes[laneIndex];
      final path = Path();

      var startX = 0.0;
      var startY = 0.0;
      for (final rift in world.level.rifts) {
        if (rift.id == lane.from) {
          startX = rift.x;
          startY = rift.y;
          break;
        }
      }
      path.moveTo(projection.toScreenX(startX), projection.toScreenY(startY));

      final waypointCount = world.laneWaypointCount(laneIndex);
      for (var w = 0; w < waypointCount; w++) {
        path.lineTo(
          projection.toScreenX(world.laneWaypointX(laneIndex, w)),
          projection.toScreenY(world.laneWaypointY(laneIndex, w)),
        );
      }
      // Son bacak: Core'a kadar. Oyuncu dusmanin nereden gelip nereye
      // gittigini gorsun (bkz. brief: "oyuncu dusmanin nereden gelecegini
      // gorsun").
      path.lineTo(projection.toScreenX(world.coreX), projection.toScreenY(world.coreY));

      return path;
    }, growable: false);
  }

  @override
  void render(Canvas canvas) {
    final size = projection.size;
    if (_lanePathsSize == null || _lanePathsSize!.x != size.x || _lanePathsSize!.y != size.y) {
      _rebuildForSize(size);
    }

    _drawBackground(canvas, size);
    _drawLanes(canvas);
    _drawRiftsAndCore(canvas);
  }

  void _drawBackground(Canvas canvas, Vector2 size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _bgPaint);
  }

  void _drawLanes(Canvas canvas) {
    for (final path in _lanePaths) {
      canvas.drawPath(path, _lanePaint);
    }
  }

  void _drawRiftsAndCore(Canvas canvas) {
    _worldBatch.clear();

    for (final rift in world.level.rifts) {
      _addWorldSprite(
        frameName: rift.skin,
        normalizedX: rift.x,
        normalizedY: rift.y,
        normalizedRadius: _riftVisualRadius,
      );
    }
    _addWorldSprite(
      frameName: 'aether_core',
      normalizedX: world.coreX,
      normalizedY: world.coreY,
      normalizedRadius: _coreVisualRadius,
    );

    _worldBatch.render(canvas);

    _drawCoreHpRing(canvas);
  }

  void _addWorldSprite({
    required String frameName,
    required double normalizedX,
    required double normalizedY,
    required double normalizedRadius,
  }) {
    final index = atlas.indexOf('world', frameName);
    final source = atlas.rectOf('world', index);
    final visualSize = projection.toScreenSize(normalizedRadius * 2);
    final scale = visualSize / _frameSize;

    _worldBatch.addTransform(
      source: source,
      transform: RSTransform.fromComponents(
        rotation: 0,
        scale: scale,
        anchorX: source.width / 2,
        anchorY: source.height / 2,
        translateX: projection.toScreenX(normalizedX),
        translateY: projection.toScreenY(normalizedY),
      ),
    );
  }

  /// Core'un altinda HP halkasi. `world.coreHp`/`coreMaxHp` her karede
  /// degisebilecegi icin (bkz. `MovementSystem` Core hasar yorumu) bu
  /// halka HER karede yeniden cizilir; ama `Path`/`Paint` yeniden
  /// yaratilmaz, sadece `drawArc` cagrisi degisir.
  void _drawCoreHpRing(Canvas canvas) {
    final ratio = world.coreMaxHp <= 0 ? 0.0 : (world.coreHp / world.coreMaxHp).clamp(0.0, 1.0);

    final ringRadius = projection.toScreenSize(_coreVisualRadius + _hpRingGap);
    final center = Offset(
      projection.toScreenX(world.coreX),
      projection.toScreenY(world.coreY),
    );
    final rect = Rect.fromCircle(center: center, radius: ringRadius);

    canvas.drawArc(rect, 0, 6.28319, false, _hpRingTrackPaint);
    if (ratio > 0) {
      canvas.drawArc(rect, -1.5708, 6.28319 * ratio, false, _hpRingFillPaint);
    }
  }
}
