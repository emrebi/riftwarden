import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/shared/widgets/rw_art.dart';

/// Semantik ikon kimlikleri. Isimler ikon sayfasi dosya id'leriyle
/// birebir eslesir (`assets/images/ui_art/icons/<id>.webp`).
/// Buradaki adlari degistirmek raster yuklemesini kirar.
enum RwIconId {
  aether,
  shard,
  cell,
  rift,
  attack,
  support,
  area,
  utility,
  magic,
  health,
  lock,
  level,
  settings,
  pause,
  back,
  info,
  plus,
  close,
  check,
}

/// Tek semantik ikon API'si.
///
/// Raster varlik birincildir (`assets/images/ui_art/icons/<id>.webp`, RwArt).
/// Dosya bulunamazsa Material IconData glifi fallback olarak sessizce cizilir;
/// cagri yerleri (`RwIcon(RwIconId.x)`) degismez.
///
/// Bu widget bir glif'tir, dokunma hedefi degildir; buton sarmalayicisi
/// (`RwIconButton`) hit-target boyutunu saglar.
class RwIcon extends StatelessWidget {
  const RwIcon(
    this.id, {
    super.key,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  });

  final RwIconId id;
  final double size;

  /// Fallback Material glifine uygulanacak renk. Raster ikonlar kendi
  /// renklerini tasidigi icin bu parametre sadece raster dosya bulunamadiginda
  /// cizilen fallback glifine etki eder.
  final Color? color;
  final String? semanticLabel;

  static const Map<RwIconId, IconData> _glyphs = <RwIconId, IconData>{
    // DESIGN.md 16: mavi/camgobegi damla veya kapali buyulu zerre.
    RwIconId.aether: Icons.water_drop_rounded,
    // Kirilgan kristal parca — kesim yuzeyli, bold silueti.
    RwIconId.shard: Icons.diamond_rounded,
    // Alti kenarli organik/enerji hucresi.
    RwIconId.cell: Icons.hexagon_rounded,
    // DESIGN.md 16: violet spiral/yirtik.
    RwIconId.rift: Icons.cyclone_rounded,
    // Kilic ikonu Material setinde yok; carpma/darbe izi ile okunur.
    RwIconId.attack: Icons.bolt_rounded,
    // Artı/ward birlesimi — koruma haci okur.
    RwIconId.support: Icons.health_and_safety_rounded,
    // Az sayida buyuk isinla patlama.
    RwIconId.area: Icons.flare_rounded,
    // Sanayi degil, tamirci/relik takim izlenimi.
    RwIconId.utility: Icons.build_rounded,
    // DESIGN.md 16: Rift kivrimi/orb.
    RwIconId.magic: Icons.auto_awesome_rounded,
    // DESIGN.md 16: kalp/kalkan/Core isareti.
    RwIconId.health: Icons.favorite_rounded,
    // DESIGN.md 16: agir kilit siluet.
    RwIconId.lock: Icons.lock_rounded,
    // DESIGN.md 16: yildiz/rozet.
    RwIconId.level: Icons.star_rounded,
    // DESIGN.md 16: okunakli disli.
    RwIconId.settings: Icons.settings_rounded,
    // DESIGN.md 16: iki genis cubuk.
    RwIconId.pause: Icons.pause_rounded,
    // DESIGN.md 16: genis yonlu ok, RTL'de aynalanir (asagida).
    RwIconId.back: Icons.arrow_back_rounded,
    // DESIGN.md 16: kapali bilgi isareti.
    RwIconId.info: Icons.info_rounded,
    RwIconId.plus: Icons.add_rounded,
    RwIconId.close: Icons.close_rounded,
    RwIconId.check: Icons.check_rounded,
  };

  static Color _defaultColor(RwIconId id) => switch (id) {
        RwIconId.aether => AppColors.aether,
        RwIconId.rift => AppColors.rift,
        RwIconId.magic => AppColors.rift,
        RwIconId.health => AppColors.health,
        RwIconId.level => AppColors.reward,
        RwIconId.close => AppColors.danger,
        RwIconId.check => AppColors.success,
        _ => AppColors.textOnDark,
      };

  @override
  Widget build(BuildContext context) {
    final glyph = _glyphs[id]!;
    final effectiveColor = color ?? _defaultColor(id);

    final fallbackIcon = Icon(
      glyph,
      size: size,
      color: effectiveColor,
      semanticLabel: null,
    );
    final fallback = semanticLabel == null
        ? fallbackIcon
        : Semantics(
            label: semanticLabel,
            child: fallbackIcon,
          );

    final icon = RwArt(
      group: RwArtGroup.icons,
      id: id.name,
      width: size,
      height: size,
      semanticLabel: semanticLabel,
      fallback: fallback,
    );

    if (id != RwIconId.back) {
      return icon;
    }

    // `back` her zaman "basa dogru" gostermeli; sanat SOLA bakar; RTL'de
    // yatayda aynalanir. Aynalama raster+fallback butunune uygulanir.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    if (!isRtl) {
      return icon;
    }
    // arrow_back_rounded'in kendi matchTextDirection:true ozelligi RTL'de
    // Material tarafindan zaten aynalaniyor; disaridaki Transform.flip ile
    // ust uste binip yon geri donmesin diye ikonu burada LTR'ye sabitleyip
    // aynalamayi sadece bu widget yapsin.
    return Transform.flip(
      flipX: true,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: icon,
      ),
    );
  }
}
