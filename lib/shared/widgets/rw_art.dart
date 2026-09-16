import 'package:flutter/material.dart';

/// Raster sanat gruplari. Isimler klasor adlariyla birebir eslesir
/// (`assets/images/ui_art/GRUP/ID.webp`, AQ-2 sozlesmesi):
/// portraits/unitId, illustrations/upgrade.icon, icons/RwIconId adi,
/// ornaments/ornament id, logo/ad, scenes/ad.
enum RwArtGroup { portraits, illustrations, icons, ornaments, logo, scenes }

/// Flutter widget'larinin motor atlaslarina dokunmadan per-file WebP sanat
/// gosterebilmesi icin tek yol (AQ-1). Atlaslar sadece Flame render'i icindir;
/// UI sanati per-file olarak yuklenir ki sanat gelene kadar kodlama beklemesin
/// ve dosya eksikken sessizce fallback gosterilsin (hata firlatilmaz).
///
/// `lib/engine` veya `lib/features` import etmez.
class RwArt extends StatelessWidget {
  const RwArt({
    required this.group,
    required this.id,
    this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel,
    super.key,
  });

  final RwArtGroup group;
  final String id;
  final Widget? fallback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;

  static String pathFor(RwArtGroup group, String id) =>
      'assets/images/ui_art/${group.name}/$id.webp';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      pathFor(group, id),
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      errorBuilder: (context, error, stackTrace) =>
          fallback ?? SizedBox(width: width, height: height),
    );
  }
}
