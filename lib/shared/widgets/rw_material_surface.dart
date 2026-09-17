import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';

/// Yuzeyin derinlik durumu (DESIGN §21). `flat` = temas golgesi, `raised` =
/// 2-4 dp kalkis, `pressed` = golge azalir + govde 1-2 dp asagi kayar.
enum RwSurfaceDepth { flat, raised, pressed }

/// Yuzeyin geometrik ailesi (DESIGN §3). `pill` sadece sayac/track,
/// `circle` sadece yetenek/ikon cercevesi icin kullanilir — govde disinda
/// serbest kullanim malzeme dilini bozar.
enum RwSurfaceShape { standard, pill, circle }

/// El yapimi malzeme yuzeyi: dolgu + kalin dis hat (keyline) + ic derz
/// (seam) + kontrollu duzensiz siluet + derinlik durumu.
///
/// ## Neden ayri bir primitive
/// UI-04'ten sonraki her bilesen (buton, panel, kart, slot) bu yuzeyin
/// uzerine kurulur; API kucuk ve sabit kalmali. Icerik alani her zaman duz
/// bir dikdortgendir — duzensizlik sadece dis siluette gorunur, `child`
/// `Padding` ile sabit bir dikdortgen icine yerlestirilir, siluete gore
/// kirpilmaz.
///
/// ## Deterministik duzensizlik
/// `seed` aksi belirtilmedikce sifirdir ve `RwMaterialBorder` icinde
/// `math.Random(seed)` ile SABIT bir dizi uretir; boylece ayni `seed` +
/// `size` + `textDirection` kombinasyonu her build'de birebir ayni yolu
/// (Path) uretir — rastgelelik "frame'e gore" degil "kimlige gore"dir.
class RwMaterialSurface extends StatelessWidget {
  const RwMaterialSurface({
    required this.material,
    required this.child,
    this.depth = RwSurfaceDepth.raised,
    this.shape = RwSurfaceShape.standard,
    this.isSelected = false,
    this.isDisabled = false,
    this.padding,
    this.seed = 0,
    this.decoration,
    this.faceColor,
    super.key,
  });

  /// Yuzeyin malzemesi (parchment/wood/stone/hud). Dolgu/kenar/keyline/metin
  /// renklerini `AppMaterials` uzerinden belirler.
  final AppMaterial material;

  /// Sabit dikdortgen icerik alanina yerlesen govde.
  final Widget child;

  /// Derinlik durumu. `isDisabled` true ise gorsel olarak her zaman `flat`
  /// davranir (kaldirilmis golge yaniltici olur).
  final RwSurfaceDepth depth;

  /// Geometrik aile.
  final RwSurfaceShape shape;

  /// Secili durum: dis hat disina 2 dp `AppColors.selection` halkasi +
  /// biraz daha kalin keyline (sadece renkle degil, kalinlikla da ayrisir).
  final bool isSelected;

  /// Pasif durum: `flat` derinlik, dolgu/derz `AppColors.stoneFace`'e dogru
  /// %40 lerp edilir, govde `Opacity(0.6)` ile soluklastirilir.
  final bool isDisabled;

  /// Icerik payi. Verilmezse `AppSpacing.md` tum yonlerde uygulanir.
  final EdgeInsetsDirectional? padding;

  /// Duzensiz siluetin deterministik tohumu. Ayni tohum + boyut + yon her
  /// zaman ayni Path'i uretir (bkz. sinif dokumantasyonu).
  final int seed;

  /// Raster susleme katmani (ornek `RwSurfaceOrnaments`); dokunmayi
  /// engellemez, siluet disina tasabilir.
  final Widget? decoration;

  /// Dolgu rengini `AppMaterials.face(material)` yerine gecersiz kilar
  /// (ornegin RwButton'un kehribar CTA yuzu). `null` = malzemenin varsayilan
  /// yuzu. `isDisabled` lerp'i de bu deger baz alinarak hesaplanir, boylece
  /// override'li yuzeyler de pasif durumda tutarli soner.
  final Color? faceColor;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    // Pasifken raised/pressed golgesi yaniltici olur; her zaman duz temas
    // golgesine dus.
    final RwSurfaceDepth effectiveDepth =
        isDisabled ? RwSurfaceDepth.flat : depth;
    final List<BoxShadow> shadows = switch (effectiveDepth) {
      RwSurfaceDepth.flat => AppShadows.contact,
      RwSurfaceDepth.raised => AppShadows.raised,
      RwSurfaceDepth.pressed => AppShadows.pressed,
    };

    final Color baseFaceColor = faceColor ?? AppMaterials.face(material);
    final Color resolvedFaceColor = isDisabled
        ? Color.lerp(baseFaceColor, AppColors.stoneFace, 0.4)!
        : baseFaceColor;

    final RwMaterialBorder border = RwMaterialBorder(
      material: material,
      shape: shape,
      seed: seed,
      textDirection: direction,
      isSelected: isSelected,
      isDisabled: isDisabled,
    );

    Widget content = Padding(
      padding: padding ?? const EdgeInsetsDirectional.all(AppSpacing.md),
      child: child,
    );

    if (isDisabled) {
      content = Opacity(opacity: 0.6, child: content);
    }

    if (effectiveDepth == RwSurfaceDepth.pressed) {
      // Basili durum: yerlesim degismez (Transform layout'u etkilemez),
      // sadece gorsel olarak 1-2 dp asagi cekilir (DESIGN §21).
      content = Transform.translate(
        offset: const Offset(0.0, 2.0),
        child: content,
      );
    }

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: resolvedFaceColor,
        shape: border,
        shadows: shadows,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          content,
          if (decoration != null)
            Positioned.fill(
              child: IgnorePointer(child: decoration!),
            ),
        ],
      ),
    );
  }
}

/// Deterministik geometri onbellegi anahtari. `inset` ayni tohumdan
/// keyline/seam/selection halkasi gibi ic ice varyantlar uretmek icin
/// kullanilir; onbellek olmasa her paint'te `math.Random` + kose hesabi
/// yeniden calisirdi.
@immutable
class _GeometryKey {
  const _GeometryKey(
    this.size,
    this.direction,
    this.shape,
    this.material,
    this.seed,
    this.inset,
  );

  final Size size;
  final TextDirection direction;
  final RwSurfaceShape shape;
  final AppMaterial material;
  final int seed;
  final double inset;

  @override
  bool operator ==(Object other) =>
      other is _GeometryKey &&
      other.size == size &&
      other.direction == direction &&
      other.shape == shape &&
      other.material == material &&
      other.seed == seed &&
      other.inset == inset;

  @override
  int get hashCode =>
      Object.hash(size, direction, shape, material, seed, inset);
}

/// `RwMaterialSurface`'in ciziminden sorumlu `ShapeBorder`. Ayri bir sinif
/// olmasinin nedeni: ileride `ClipPath`/`Material(shape:)` gibi yerlerde
/// dogrudan yeniden kullanilabilsin (brief UI-04).
class RwMaterialBorder extends ShapeBorder {
  const RwMaterialBorder({
    required this.material,
    this.shape = RwSurfaceShape.standard,
    this.seed = 0,
    this.textDirection,
    this.isSelected = false,
    this.isDisabled = false,
  });

  final AppMaterial material;
  final RwSurfaceShape shape;
  final int seed;
  final TextDirection? textDirection;
  final bool isSelected;
  final bool isDisabled;

  /// Boyut basina Path onbellegi. `static` cunku ayni (boyut, tohum, ...)
  /// kombinasyonu farkli widget ornekleri arasinda da paylasilabilir —
  /// ornegin ayni 120x56 buton birden fazla yerde varsa jitter hesabi bir
  /// kez yapilir.
  static final Map<_GeometryKey, Path> _pathCache = <_GeometryKey, Path>{};

  /// Onbellek boyut sinirlandirmasi. Panel/progress gibi surekli boyut
  /// degistiren yuzeyler (yeniden boyutlanma, text scale) her yeni boyut
  /// icin farkli bir anahtar uretir; sinir olmasa `_pathCache` sinirsiz
  /// buyur ve sizinti olur. Dart `Map` ekleme sirasini korudugu icin en
  /// eski anahtar (LRU degil ama FIFO) ucuz sekilde atilabilir.
  static const int _maxCachedPaths = 128;

  static const double _selectionInset = 2.0;
  static const double _seamGap = 3.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  Path _geometryPath(Size size, TextDirection direction, double inset) {
    final _GeometryKey key =
        _GeometryKey(size, direction, shape, material, seed, inset);
    final Path? cached = _pathCache[key];
    if (cached != null) {
      return cached;
    }
    final Path built = _buildGeometryPath(size, direction, inset);
    if (_pathCache.length >= _maxCachedPaths) {
      _pathCache.remove(_pathCache.keys.first);
    }
    _pathCache[key] = built;
    return built;
  }

  Path _buildGeometryPath(Size size, TextDirection direction, double inset) {
    final Rect full = Offset.zero & size;
    final Rect rect = full.deflate(inset);
    if (rect.shortestSide <= 0) {
      return Path()..addRect(full);
    }
    // Ayni tohumdan her zaman ayni dizi: keyline/seam/selection gibi ic ice
    // varyantlar (farkli inset) gorsel olarak tutarli/orantili kalir.
    final math.Random rng = math.Random(seed);

    switch (shape) {
      case RwSurfaceShape.pill:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide / 2)),
          );
      case RwSurfaceShape.circle:
        final double side = rect.shortestSide;
        final Rect circleRect = Rect.fromCenter(
          center: rect.center,
          width: side,
          height: side,
        );
        return Path()..addOval(circleRect);
      case RwSurfaceShape.standard:
        final bool softened =
            material == AppMaterial.parchment || material == AppMaterial.wood;
        return softened
            ? _softenedPath(rect, rng, direction)
            : _chamferedShapePath(rect, rng, direction);
    }
  }

  /// Parchment/wood: hafif duzensiz kose yaricaplari + en fazla bir hafif
  /// kabarik kenar (DESIGN §3 "softened, slightly uneven corners").
  Path _softenedPath(Rect r, math.Random rng, TextDirection direction) {
    final double shortSide = r.shortestSide;
    // Kucuk widget'larda (48 dp) duzensizlik goze batmasin diye tavan.
    final double baseRadius = math.min(AppRadius.lg, shortSide * 0.30);
    final double maxDelta = baseRadius * 0.25;
    final List<double> startEnd = List<double>.generate(4, (_) {
      final double delta = (rng.nextDouble() * 2 - 1) * maxDelta;
      return (baseRadius + delta).clamp(baseRadius * 0.6, shortSide * 0.45);
    });
    final List<double> corners = _resolveForDirection(startEnd, direction);

    final bool hasBow = rng.nextDouble() < 0.6;
    final bool bowTop = rng.nextBool();
    final double bowAmplitude = 1.5 + rng.nextDouble() * 2.5;

    return _roundedRectPath(
      r,
      corners,
      bowTop: hasBow ? bowTop : null,
      bowAmplitude: bowAmplitude,
    );
  }

  /// Stone/hud: kalin, kesilmis (chamfer) koseler; seed'e gore boyut
  /// degisir ama her zaman "chunkier clipped" hissi korunur.
  Path _chamferedShapePath(Rect r, math.Random rng, TextDirection direction) {
    final double shortSide = r.shortestSide;
    final double baseChamfer = math.min(AppRadius.md, shortSide * 0.26);
    final double maxDelta = baseChamfer * 0.3;
    final List<double> startEnd = List<double>.generate(4, (_) {
      final double delta = (rng.nextDouble() * 2 - 1) * maxDelta;
      return (baseChamfer + delta).clamp(baseChamfer * 0.6, shortSide * 0.4);
    });
    final List<double> corners = _resolveForDirection(startEnd, direction);
    return _chamferedRectPath(r, corners);
  }

  /// `[topStart, topEnd, bottomEnd, bottomStart]` -> RTL'de start=sag,
  /// end=sol oldugundan asimetrik detaylar yatayda aynalanir (DESIGN §22).
  List<double> _resolveForDirection(List<double> se, TextDirection direction) {
    final double topStart = se[0];
    final double topEnd = se[1];
    final double bottomEnd = se[2];
    final double bottomStart = se[3];
    if (direction == TextDirection.rtl) {
      return <double>[topEnd, topStart, bottomStart, bottomEnd];
    }
    return <double>[topStart, topEnd, bottomEnd, bottomStart];
  }

  Path _roundedRectPath(
    Rect r,
    List<double> corners, {
    bool? bowTop,
    double bowAmplitude = 0.0,
  }) {
    final double tl = corners[0];
    final double tr = corners[1];
    final double br = corners[2];
    final double bl = corners[3];
    final Path path = Path()..moveTo(r.left + tl, r.top);

    if (bowTop == true) {
      final double midX = (r.left + tl + r.right - tr) / 2;
      path.quadraticBezierTo(midX, r.top - bowAmplitude, r.right - tr, r.top);
    } else {
      path.lineTo(r.right - tr, r.top);
    }
    path.arcToPoint(Offset(r.right, r.top + tr), radius: Radius.circular(tr));
    path.lineTo(r.right, r.bottom - br);
    path.arcToPoint(Offset(r.right - br, r.bottom), radius: Radius.circular(br));

    if (bowTop == false) {
      final double midX = (r.left + bl + r.right - br) / 2;
      path.quadraticBezierTo(midX, r.bottom + bowAmplitude, r.left + bl, r.bottom);
    } else {
      path.lineTo(r.left + bl, r.bottom);
    }
    path.arcToPoint(Offset(r.left, r.bottom - bl), radius: Radius.circular(bl));
    path.lineTo(r.left, r.top + tl);
    path.arcToPoint(Offset(r.left + tl, r.top), radius: Radius.circular(tl));
    path.close();
    return path;
  }

  Path _chamferedRectPath(Rect r, List<double> corners) {
    final double tl = corners[0];
    final double tr = corners[1];
    final double br = corners[2];
    final double bl = corners[3];
    return Path()
      ..moveTo(r.left + tl, r.top)
      ..lineTo(r.right - tr, r.top)
      ..lineTo(r.right, r.top + tr)
      ..lineTo(r.right, r.bottom - br)
      ..lineTo(r.right - br, r.bottom)
      ..lineTo(r.left + bl, r.bottom)
      ..lineTo(r.left, r.bottom - bl)
      ..lineTo(r.left, r.top + tl)
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final TextDirection direction =
        textDirection ?? this.textDirection ?? TextDirection.ltr;
    final double inset = isSelected ? _selectionInset : 0.0;
    return _geometryPath(rect.size, direction, inset).shift(rect.topLeft);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final TextDirection direction =
        textDirection ?? this.textDirection ?? TextDirection.ltr;
    final double inset = (isSelected ? _selectionInset : 0.0) +
        AppMaterials.keylineWidth +
        AppMaterials.seamWidth;
    return _geometryPath(rect.size, direction, inset).shift(rect.topLeft);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final TextDirection direction =
        textDirection ?? this.textDirection ?? TextDirection.ltr;

    // Onbellekteki Path (0,0) tabanli; her paint'te yeniden hesaplamak
    // yerine tuvali kaydirip ayni Path'i ciziyoruz (allocation-free).
    canvas.save();
    canvas.translate(rect.left, rect.top);
    final Size size = rect.size;

    if (isSelected) {
      final Path selectionPath = _geometryPath(size, direction, 0.0);
      final Paint selectionPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _selectionInset
        ..color = AppColors.selection;
      canvas.drawPath(selectionPath, selectionPaint);
    }

    final double keylineInset = isSelected ? _selectionInset : 0.0;
    final Path keylinePath = _geometryPath(size, direction, keylineInset);
    final Color keylineColor = isDisabled
        ? Color.lerp(AppMaterials.keyline(material), AppColors.stoneFace, 0.4)!
        : AppMaterials.keyline(material);
    final Paint keylinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected
          ? AppMaterials.keylineWidth + 0.75
          : AppMaterials.keylineWidth
      ..color = keylineColor;
    canvas.drawPath(keylinePath, keylinePaint);

    final Path seamPath = _geometryPath(size, direction, keylineInset + _seamGap);
    final Color seamColor = isDisabled
        ? Color.lerp(AppMaterials.edge(material), AppColors.stoneFace, 0.4)!
        : AppMaterials.edge(material);
    final Paint seamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppMaterials.seamWidth
      ..color = seamColor;
    canvas.drawPath(seamPath, seamPaint);

    canvas.restore();
  }
}
