import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart' show Component, Vector2;
import 'package:flame/sprite.dart' show SpriteBatch;
import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Savas alani zemini: gradyan arka plan, savunma sinir cizgisi, rift
/// portallari ve kale.
///
/// GECICI RENDER: bu sinif P13'te `MapRenderer`e donusecek (bkz. plan
/// bolum 5). Simdilik kale ve rift'ler icin ozel sprite yok; kale
/// `aether_core` karesiyle, rift portallari `riftSkin` karesiyle
/// (genelde `rift_violet`) cizilir.
///
/// [BattleWorld]'u SADECE OKUR.
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
  static const Color _defenseLineColor = Color(0x55FFFFFF);
  static const Color _hpRingTrack = Color(0x40FFFFFF);
  static const Color _hpRingFill = Color(0xFF6FE3C8);

  static const double _coreVisualRadius = 0.055;
  static const double _riftVisualRadius = 0.035;
  static const double _frameSize = 128;
  static const double _hpRingStrokeWidth = 4;
  static const double _hpRingGap = 0.014;

  /// Rift portallarinin sag kenarda cizildigi sabit X (izotropik dunya).
  /// Dusman spawn overshoot'undan (`kSpawnOvershoot`) biraz iceride durur
  /// ki portal ekranin hemen disina tasmasin ama yine de kenara yakin
  /// gorunsun.
  static const double _riftFieldX = kFieldAspect - 0.06;

  /// Sinir cizgisi kesikli (dashed): "gecmeden ates yok" cizgisinin bir
  /// duvar degil, GORULEBILIR bir esik oldugunu vurgular.
  static const double _defenseLineDashLength = 10;
  static const double _defenseLineGapLength = 8;
  static const double _defenseLineStrokeWidth = 2;

  final Paint _bgPaint = Paint();
  final Paint _defenseLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _defenseLineStrokeWidth
    ..color = _defenseLineColor;
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

  /// Arka plan gradyani hangi ekran boyutu icin kuruldu; boyut degisirse
  /// (donme, katlanabilir cihaz) yeniden kurulur. Render sicak yolunda
  /// HER karede DEGIL, sadece boyut degistiginde yeniden hesaplanir.
  Vector2? _bgSize;

  @override
  Future<void> onLoad() async {
    _rebuildBackgroundGradient(projection.size);
  }

  void _rebuildBackgroundGradient(Vector2 size) {
    _bgSize = size.clone();
    _bgPaint.shader = Gradient.linear(
      Offset.zero,
      Offset(0, size.y),
      const <Color>[_bgTop, _bgBottom],
    );
  }

  @override
  void render(Canvas canvas) {
    final size = projection.size;
    if (_bgSize == null || _bgSize!.x != size.x || _bgSize!.y != size.y) {
      _rebuildBackgroundGradient(size);
    }

    _drawBackground(canvas, size);
    _drawDefenseLine(canvas, size);
    _drawRiftsAndCastle(canvas);
  }

  void _drawBackground(Canvas canvas, Vector2 size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _bgPaint);
  }

  /// Kesikli dikey sinir cizgisi: bu cizgiyi gecmeden dusman hedeflenemez
  /// (bkz. `TargetingSystem`, P10'da eklenecek filtre).
  void _drawDefenseLine(Canvas canvas, Vector2 size) {
    final x = projection.toScreenX(world.defenseLineX);
    var y = 0.0;
    while (y < size.y) {
      final segmentEnd = math.min(y + _defenseLineDashLength, size.y);
      canvas.drawLine(Offset(x, y), Offset(x, segmentEnd), _defenseLinePaint);
      y += _defenseLineDashLength + _defenseLineGapLength;
    }
  }

  void _drawRiftsAndCastle(Canvas canvas) {
    _worldBatch.clear();

    // riftCount kadar rift portali sag kenarda, spawn bandina esit
    // araliklarla dizilir (bkz. `docs/CONTENT_SCHEMA.md` > spawn.riftCount).
    // Spawn'in kendisi BURADAN degil, rastgele Y'de olur (bkz. WavePlanner);
    // bu portallar sadece gorseldir.
    final riftCount = world.riftCount;
    final riftSkin = world.level.spawn.riftSkin;
    for (var i = 0; i < riftCount; i++) {
      final t = riftCount == 1 ? 0.5 : i / (riftCount - 1);
      final normalizedY = world.spawnYMin + (world.spawnYMax - world.spawnYMin) * t;
      _addWorldSprite(
        frameName: riftSkin,
        normalizedX: _riftFieldX,
        normalizedY: normalizedY,
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
