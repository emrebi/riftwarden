import 'dart:convert';
import 'dart:ui';

import 'package:flame/cache.dart' show Images;
import 'package:flutter/services.dart' show rootBundle;

/// `assets/images/atlas/` altindaki bilinen atlas gruplari.
///
/// Dosya adlari `<grup>.webp` ve `<grup>.json` seklindedir (bkz.
/// `tools/assetkit`). WebP lossless: PNG'den kucuk, sprite/atlas'ta lossy
/// kenar halesi ve renk sizmasi olmaz. Yeni bir grup eklendiginde sadece
/// bu listeye eklenir; yukleme ve cozumleme kodu degismez.
const List<String> kAtlasGroups = <String>[
  'enemies',
  'units',
  'fx',
  'world',
  'ui',
];

/// Bir atlas grubunun yuklenmis hali: resim + kare dikdortgenleri + isim
/// tablosu. Sadece [AtlasRegistry] icinde tutulur.
class _AtlasGroup {
  _AtlasGroup(this.image, this.rects, this.indexByName);

  final Image image;

  /// Indekse gore kare dikdortgeni. Sira JSON'daki `frames` anahtar sirasidir
  /// (bkz. [AtlasRegistry] dosya basi yorumu — bu sira ayni dosya icin HER
  /// ZAMAN aynidir, bu yuzden "kararli" sayilir).
  final List<Rect> rects;

  final Map<String, int> indexByName;
}

/// `assets/images/atlas/*.json` + `.webp` ciftlerini yukler ve sprite
/// adlarindan KARARLI SAYISAL INDEKS uretir.
///
/// ## Neden indeks, string degil
/// Render sicak yolu (bkz. `swarm_renderer.dart`, `unit_renderer.dart`,
/// `projectile_renderer.dart`) her karede yuzlerce entity gezer. Bu
/// dongude `Map<String, Rect>` ile string arama yapmak (hash'leme +
/// karsilastirma) kabul edilemez maliyettir. Bunun yerine her entity
/// kurulumda cozulmus bir `int spriteIndex` tasir (bkz.
/// `EnemyEntity.spriteIndex`, `UnitEntity.spriteIndex`); render katmani
/// bu indeksi dogrudan [rectOf] ile kaynak dikdortgenine cevirir.
///
/// [load] savas/uygulama basinda BIR KEZ cagrilir (allocation, JSON
/// okuma, IO burada serbesttir); sonrasinda [indexOf], [rectOf], [imageOf]
/// salt-okunur ve ucuzdur.
class AtlasRegistry {
  final Map<String, _AtlasGroup> _groups = <String, _AtlasGroup>{};

  /// Flame'in resim onbellegi. Prefix atlas klasorune sabitlenir; boylece
  /// cagiran taraf sadece dosya adini verir (`enemies.webp`).
  final Images _images = Images(prefix: 'assets/images/atlas/');

  /// [kAtlasGroups] icindeki tum atlaslari yukler.
  ///
  /// WebP'ler Flame'in `Images` onbellegi uzerinden (bellek paylasimi ve
  /// tekrar yuklemeyi onlemek icin), JSON'lar `rootBundle` ile okunur.
  Future<void> load() async {
    for (final group in kAtlasGroups) {
      final image = await _images.load('$group.webp');
      final jsonString = await rootBundle.loadString('assets/images/atlas/$group.json');
      final decoded = jsonDecode(jsonString) as Map<String, Object?>;
      final framesJson = decoded['frames']! as Map<String, Object?>;

      final rects = <Rect>[];
      final indexByName = <String, int>{};
      for (final entry in framesJson.entries) {
        final frame = entry.value! as Map<String, Object?>;
        final x = (frame['x']! as num).toDouble();
        final y = (frame['y']! as num).toDouble();
        final w = (frame['w']! as num).toDouble();
        final h = (frame['h']! as num).toDouble();
        indexByName[entry.key] = rects.length;
        rects.add(Rect.fromLTWH(x, y, w, h));
      }

      _groups[group] = _AtlasGroup(image, rects, indexByName);
    }
  }

  _AtlasGroup _groupOf(String group) {
    final data = _groups[group];
    if (data == null) {
      throw StateError(
        'AtlasRegistry: bilinmeyen veya henuz yuklenmemis grup: "$group"',
      );
    }
    return data;
  }

  /// `frameName`'den kararli sayisal indeks cozer.
  ///
  /// Sadece savas KURULUMUNDA (bkz. `BattleWorld.enemySpriteIndex` /
  /// `unitSpriteIndex` tablolari) cagrilir; render sicak yolunda DEGIL.
  int indexOf(String group, String frameName) {
    final data = _groupOf(group);
    final index = data.indexByName[frameName];
    if (index == null) {
      throw StateError(
        'AtlasRegistry: "$group" grubunda bilinmeyen kare: "$frameName"',
      );
    }
    return index;
  }

  /// Bir grubun [index]. karesinin atlas resmi uzerindeki kaynak
  /// dikdortgeni. `SpriteBatch.addTransform`'un `source` parametresi.
  Rect rectOf(String group, int index) => _groupOf(group).rects[index];

  /// Bir grubun atlas resmi. `SpriteBatch` bu resim uzerinde calisir.
  Image imageOf(String group) => _groupOf(group).image;
}
