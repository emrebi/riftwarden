import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart' show Component, Vector2;
import 'package:flame/sprite.dart' show SpriteBatch;
import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';

/// Savas alani zemini: prosedurel gradyan, cevre dekoru, arazi alani
/// gostergeleri, savunma siniri, kale ve rift portallari.
///
/// [BattleWorld]'u SADECE OKUR.
///
/// ## Renkler hakkinda
/// `engine/` katmani `features`/`app` import EDEMEZ (bkz. CLAUDE.md kural
/// 2), bu yuzden `app/theme/app_colors.dart` degerleri buraya sabit olarak
/// KOPYALANIR. Bu degerler tema paletiyle ESLESMELI; tema degisirse bu
/// sabitler de elle guncellenmelidir.
///
/// ## Z-sira
/// a) zemin gradyani (kenar bosluklari dahil TUM canvas), b) cevre dekoru
/// (tek `SpriteBatch`, `_decorBatch`), c) arazi alani gostergeleri,
/// d) kesikli savunma siniri, e) kale, f) rift portallari (e+f ayni
/// `_worldBatch`). Kale/portal/dekor konumlari NORMALIZE (izotropik dunya)
/// uzayda savas boyunca degismez, ama batch'lere yazilan deger EKRAN
/// PIKSELIDIR (`FieldProjection` sonucu) — bu yuzden [onLoad]'da bir kez
/// doldurulduklari gibi, ekran boyutu degistiginde (donme, katlanabilir
/// cihaz) de `_layoutSize` kontroluyle YENIDEN doldurulurlar (bkz.
/// [_rebuildForSize]); aksi halde arazi/savunma sinirini "canli" cizen
/// diger render cagrilariyla piksel bazinda kayarlar. Boyut DEGISMEDIGI
/// surece render sicak yolu sadece `render(canvas)` cagirir, `clear`/
/// `addTransform` TEKRARLANMAZ (yalnizca Core HP halkasi her karede
/// degisebildigi icin ayrica `drawArc` ile cizilir).
class MapRenderer extends Component {
  MapRenderer({
    required this.world,
    required this.atlas,
    required this.projection,
  });

  final BattleWorld world;
  final AtlasRegistry atlas;
  final FieldProjection projection;

  static const Color _bgTop = Color(0xFF0B0B14);
  static const Color _bgBottom = Color(0xFF181830);
  static const Color _defenseLineColor = Color(0x55FFFFFF);
  static const Color _hpRingTrack = Color(0x40FFFFFF);
  static const Color _hpRingFill = Color(0xFF6FE3C8);

  /// Arazi gostergeleri: soluk (dusuk alfa) doldurulmus daireler — bir
  /// engel degil, bir "burada farkli bir sey var" ipucu (bkz.
  /// `docs/CONTENT_SCHEMA.md > terrain`).
  static const Color _slowZoneColor = Color(0x333FE0FF);
  static const Color _coverZoneColor = Color(0x339B5CFF);

  static const double _coreVisualRadius = 0.09;
  static const double _riftVisualRadius = 0.045;
  static const double _decorBaseRadius = 0.05;
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
  final Paint _slowZonePaint = Paint()..color = _slowZoneColor;
  final Paint _coverZonePaint = Paint()..color = _coverZoneColor;

  /// Cevre dekoru: `environments.json > decor`, y'ye gore siralanmis
  /// (asagida bicilir). Icerik (hangi sprite, sira) savas boyunca sabit
  /// ama ekran pikseli konumlari [projection]'a bagli oldugu icin boyut
  /// degisince (donme, katlanabilir cihaz) [_layoutSize] ile birlikte
  /// yeniden doldurulur.
  late final SpriteBatch _decorBatch = SpriteBatch(atlas.imageOf('world'));

  /// Kale + rift portallari: [_decorBatch] ile ayni gerekce ve yeniden
  /// kurulma kurali gecerlidir.
  late final SpriteBatch _worldBatch = SpriteBatch(atlas.imageOf('world'));

  /// Zemin gradyani ve iki sprite batch'i hangi ekran boyutu icin kuruldu.
  /// Boyut degisirse (donme, katlanabilir cihaz) uculu de bu boyutla
  /// yeniden kurulur. Render sicak yolunda HER karede DEGIL, sadece boyut
  /// degistiginde yeniden hesaplanir.
  Vector2? _layoutSize;

  @override
  Future<void> onLoad() async {
    _rebuildForSize(projection.size);
  }

  /// Boyuta bagli TUM statik durumu (gradyan + iki batch) yeniden kurar.
  /// [onLoad]'da bir kez, [render]'da boyut degistiginde cagrilir.
  void _rebuildForSize(Vector2 size) {
    _layoutSize = size.clone();
    _rebuildBackgroundGradient(size);

    _decorBatch.clear();
    _buildDecorBatch();

    _worldBatch.clear();
    _buildWorldBatch();
  }

  void _rebuildBackgroundGradient(Vector2 size) {
    _bgPaint.shader = Gradient.linear(
      Offset.zero,
      Offset(0, size.y),
      const <Color>[_bgTop, _bgBottom],
    );
  }

  /// Cevre dekorunu y'ye gore siralayip [_decorBatch]'e BIR KEZ ekler
  /// (bkz. sinif basi "Z-sira" yorumu — siralama burada yapilir, render'da
  /// degil).
  void _buildDecorBatch() {
    final environment = world.content.environment(world.level.environmentId);
    final decor = environment.decor.toList()..sort((a, b) => a.y.compareTo(b.y));

    for (final item in decor) {
      final index = atlas.indexOf('world', item.sprite);
      final source = atlas.rectOf('world', index);
      final visualSize = projection.toScreenSize(_decorBaseRadius * 2 * item.scale);
      final scale = visualSize / _frameSize;

      _decorBatch.addTransform(
        source: source,
        transform: RSTransform.fromComponents(
          rotation: 0,
          scale: scale,
          anchorX: source.width / 2,
          anchorY: source.height / 2,
          translateX: projection.toScreenX(item.x * kFieldAspect),
          translateY: projection.toScreenY(item.y),
        ),
      );
    }
  }

  /// Kale ve rift portallarini [_worldBatch]'e BIR KEZ ekler.
  void _buildWorldBatch() {
    // riftCount kadar rift portali sag kenarda, spawn bandina esit
    // araliklarla dizilir (bkz. `docs/CONTENT_SCHEMA.md > spawn.riftCount`).
    // Spawn'in kendisi BURADAN degil, rastgele Y'de olur (bkz. WavePlanner);
    // bu portallar sadece gorseldir.
    final riftCount = world.riftCount;
    for (var i = 0; i < riftCount; i++) {
      final t = riftCount == 1 ? 0.5 : i / (riftCount - 1);
      final normalizedY = world.spawnYMin + (world.spawnYMax - world.spawnYMin) * t;
      _addWorldSprite(
        frameName: 'rift_portal',
        normalizedX: _riftFieldX,
        normalizedY: normalizedY,
        normalizedRadius: _riftVisualRadius,
      );
    }

    _addWorldSprite(
      frameName: 'castle_citadel',
      normalizedX: world.coreX,
      normalizedY: world.coreY,
      normalizedRadius: _coreVisualRadius,
    );
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

  @override
  void render(Canvas canvas) {
    final size = projection.size;
    if (_layoutSize == null || _layoutSize!.x != size.x || _layoutSize!.y != size.y) {
      _rebuildForSize(size);
    }

    _drawBackground(canvas, size);
    _decorBatch.render(canvas);
    _drawTerrainZones(canvas);
    _drawDefenseLine(canvas, size);
    _worldBatch.render(canvas);
    _drawCoreHpRing(canvas);
  }

  void _drawBackground(Canvas canvas, Vector2 size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _bgPaint);
  }

  /// Oynanisi etkileyen arazi alanlari (bkz. `TerrainSystem`): `slow` soluk
  /// cyan, `cover` soluk menekse daire. Izotropik dunyada daire kalmasi
  /// icin yaricap [FieldProjection.toScreenSize] ile TEK eksende cevrilir.
  void _drawTerrainZones(Canvas canvas) {
    final terrainX = world.terrainX;
    for (var i = 0; i < terrainX.length; i++) {
      final center = Offset(
        projection.toScreenX(terrainX[i]),
        projection.toScreenY(world.terrainY[i]),
      );
      final radius = projection.toScreenSize(world.terrainRadius[i]);
      final paint =
          world.terrainType[i] == kTerrainTypeSlow ? _slowZonePaint : _coverZonePaint;
      canvas.drawCircle(center, radius, paint);
    }
  }

  /// Kesikli dikey sinir cizgisi: bu cizgiyi gecmeden dusman hedeflenemez
  /// (bkz. `TargetingSystem`).
  void _drawDefenseLine(Canvas canvas, Vector2 size) {
    final x = projection.toScreenX(world.defenseLineX);
    var y = 0.0;
    while (y < size.y) {
      final segmentEnd = math.min(y + _defenseLineDashLength, size.y);
      canvas.drawLine(Offset(x, y), Offset(x, segmentEnd), _defenseLinePaint);
      y += _defenseLineDashLength + _defenseLineGapLength;
    }
  }

  /// Kale'nin altinda HP halkasi. `world.coreHp`/`coreMaxHp` her karede
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
