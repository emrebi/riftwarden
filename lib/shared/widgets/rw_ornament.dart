import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/shared/widgets/rw_art.dart';

/// Raster susleme bilesenleri (DESIGN §2 "small reusable raster decoration",
/// DESIGN §4 "decoration may overhang layout bounds but not reduce padding/hit targets").
///
/// Raster suslemeler yalnizca gorsel atmosfer katar; semantik disidir
/// (ekran okuyuculardan gizlenir) ve icerik payini ya da dokunma hedeflerini
/// kisitlamaz veya engellemez. Siluet sinirlarindan disa tasabilir.
enum RwOrnamentId {
  boardEndCap,
  peg,
  parchmentCorner,
  parchmentEdge,
  stoneCorner,
  bannerTail,
  selectionMarker;

  String get assetId => switch (this) {
    RwOrnamentId.boardEndCap => 'board_end_cap',
    RwOrnamentId.peg => 'peg',
    RwOrnamentId.parchmentCorner => 'parchment_corner',
    RwOrnamentId.parchmentEdge => 'parchment_edge',
    RwOrnamentId.stoneCorner => 'stone_corner',
    RwOrnamentId.bannerTail => 'banner_tail',
    RwOrnamentId.selectionMarker => 'selection_marker',
  };
}

/// Tekil raster susleme parcasi.
///
/// Semantik etiket tasimaz; yonlu parcalar (L koseler vb.) RTL duzenlerde
/// otomatik olarak yatayda aynalanir.
class RwOrnament extends StatelessWidget {
  const RwOrnament({
    required this.id,
    required this.size,
    this.flipX = false,
    super.key,
  });

  final RwOrnamentId id;
  final double size;
  final bool flipX;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool mirror = flipX != rtl;

    Widget art = RwArt(
      group: RwArtGroup.ornaments,
      id: id.assetId,
      width: size,
      height: size,
      fallback: SizedBox(width: size, height: size),
    );

    if (mirror) {
      art = Transform.flip(flipX: true, child: art);
    }

    return ExcludeSemantics(child: art);
  }
}

/// `RwMaterialSurface` bileseninin `decoration:` slotu icin malzeme bazli
/// hazir susleme katmani.
class RwSurfaceOrnaments extends StatelessWidget {
  const RwSurfaceOrnaments({
    required this.material,
    this.isSelected = false,
    this.compact = false,
    super.key,
  });

  final AppMaterial material;
  final bool isSelected;
  final bool compact;

  static const double _cornerSize = 22.0;
  static const double _pegSize = 14.0;
  static const double _markerSize = 22.0;
  static const double _overhang = -6.0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    if (!compact) {
      switch (material) {
        case AppMaterial.parchment:
          children.add(
            const PositionedDirectional(
              top: _overhang,
              start: _overhang,
              child: RwOrnament(
                id: RwOrnamentId.parchmentCorner,
                size: _cornerSize,
              ),
            ),
          );
        case AppMaterial.wood:
          children.addAll(const <Widget>[
            PositionedDirectional(
              top: AppSpacing.xs,
              start: AppSpacing.xs,
              child: RwOrnament(id: RwOrnamentId.peg, size: _pegSize),
            ),
            PositionedDirectional(
              top: AppSpacing.xs,
              end: AppSpacing.xs,
              child: RwOrnament(
                id: RwOrnamentId.peg,
                size: _pegSize,
                flipX: true,
              ),
            ),
          ]);
        case AppMaterial.stone:
          children.add(
            const PositionedDirectional(
              top: _overhang,
              start: _overhang,
              child: RwOrnament(
                id: RwOrnamentId.stoneCorner,
                size: _cornerSize,
              ),
            ),
          );
        case AppMaterial.hud:
          break;
      }
    }

    if (isSelected) {
      children.add(
        const PositionedDirectional(
          top: _overhang,
          end: _overhang,
          child: RwOrnament(
            id: RwOrnamentId.selectionMarker,
            size: _markerSize,
          ),
        ),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: children,
    );
  }
}
