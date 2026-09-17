import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/format/rw_number_format.dart';
import 'package:riftwarden/shared/widgets/rw_art.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Savunmaci yuvasi gorsel durumu (DESIGN §11).
enum RwDefenderSlotState {
  /// Bos yuva: sessiz cerceve + yerlesim isareti, portre/cost yok.
  empty,

  /// Doldurulabilir, mevcut: portre + normal cerceve.
  available,

  /// Secili: portre okunur, kose isareti + secim halkasi.
  selected,

  /// Kalici kilit: siluet + kilit isareti, dokunma kapali.
  locked,

  /// Satin alinabilir: portre + Aether maliyeti, kalkik cerceve.
  purchaseable,

  /// Yetersiz kaynak: portre + maliyet gorunur ama duz/soluk, dokunma kapali.
  unaffordable,

  /// Dolu: portre + kose sayac rozeti (veya count yoksa kucuk isaret).
  occupied,
}

/// Kale slotlarindaki tek bir savunmaci yuvasi.
///
/// ## Neden ayri bir primitive
/// `UnitSpawnBar` (savas HUD'unun kendi cizimi) ile roster/loadout gibi
/// savas-disi yuzeyler ayni yuva gorselini paylasir. Bu widget tamamen
/// parametre gudumludur: veri kaynagi, Riverpod, `BattleSignals`
/// baglantisi YOKTUR — cagiran taraf hangi durumu gosterecegini kendi
/// karar verir.
///
/// ## Malzeme
/// Govde `RwMaterialSurface(material: stone)` uzerine kurulur (DESIGN §3
/// "Kale bagli slotlar ... stone"). Sadece basili derinlik gecisi icin
/// yerel `State` tutar.
class RwDefenderSlot extends StatefulWidget {
  const RwDefenderSlot({
    required this.state,
    super.key,
    this.unitId,
    this.name,
    this.cost,
    this.count,
    this.onTap,
    this.size = 64.0,
    this.semanticLabel,
    this.accentColor,
  });

  /// Gorsel durum (DESIGN §11).
  final RwDefenderSlotState state;

  /// Portre kimligi (`RwArt(group: portraits, id: unitId)`). `null`/bos ise
  /// [name] baz alinarak dusen bir siluet gosterilir; ikisi de yoksa
  /// portre alani bos kalir.
  final String? unitId;

  /// Savasci adi. Verilirse portrenin altinda tek satir ellipsis etiket
  /// olarak gosterilir; dusen portre harfinin de kaynagidir.
  final String? name;

  /// Aether maliyeti (`purchaseable`/`unaffordable` durumlarinda gosterilir).
  final int? cost;

  /// Doluluk sayaci (`occupied` durumunda kose rozetinde gosterilir).
  final int? count;

  /// Dokunma gericagirimi. `locked`/`unaffordable` durumlarinda -- verilse
  /// bile -- etkilesim kapalidir (DESIGN §11).
  final VoidCallback? onTap;

  /// Kare portre alani kenar uzunlugu. Dokunma hedefi bundan bagimsiz en az
  /// [AppSpacing.minTouchTarget] olarak garanti edilir.
  final double size;

  /// Semantics etiketi. Verilirse `Semantics.label` olarak eklenir
  /// (excludeSemantics YOK, alt agac birlesmeye devam eder).
  final String? semanticLabel;

  /// Dusen portre siluetinin vurgu rengi. `null` ise `AppColors.aether`.
  final Color? accentColor;

  @override
  State<RwDefenderSlot> createState() => _RwDefenderSlotState();
}

class _RwDefenderSlotState extends State<RwDefenderSlot> {
  // Olcu/tokenlar tek yerde toplanir (brief "olculer static const tek yerde").
  static const double _lockIconSize = 22.0;
  static const double _plusIconSize = 26.0;
  static const double _costIconSize = 12.0;
  static const double _cornerBadgeSize = 20.0;
  static const double _cornerBadgePadding = 3.0;
  static const double _cornerBadgeInset = 2.0;
  static const double _nameGap = 2.0;
  static const List<double> _grayscaleMatrix = <double>[
    0.21, 0.72, 0.07, 0, 0, //
    0.21, 0.72, 0.07, 0, 0, //
    0.21, 0.72, 0.07, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  bool get _hasIdentity =>
      (widget.unitId != null && widget.unitId!.isNotEmpty) ||
      (widget.name != null && widget.name!.isNotEmpty);

  String? get _initial {
    final String? source = (widget.name != null && widget.name!.isNotEmpty)
        ? widget.name
        : widget.unitId;
    if (source == null || source.isEmpty) {
      return null;
    }
    return String.fromCharCode(source.runes.first).toUpperCase();
  }

  /// Dosya henuz yoksa (veya `unitId` verilmemisse) gosterilen dusen siluet:
  /// vurgu tonlu yuvarlak/kalkan sekli + bas harf.
  Widget _buildFallbackShape() {
    final Color accent = widget.accentColor ?? AppColors.aether;
    final String? initial = _initial;
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 2.0),
        ),
        child: initial == null
            ? null
            : Center(
                child: Text(
                  initial,
                  style: AppTypography.sectionTitle.copyWith(color: accent),
                ),
              ),
      ),
    );
  }

  Widget _buildPortrait() {
    if (!_hasIdentity) {
      return const SizedBox.shrink();
    }
    final Widget fallback = _buildFallbackShape();
    final String? unitId = widget.unitId;
    if (unitId == null || unitId.isEmpty) {
      return fallback;
    }
    return Center(
      child: RwArt(
        group: RwArtGroup.portraits,
        id: unitId,
        fit: BoxFit.contain,
        fallback: fallback,
      ),
    );
  }

  /// Kilitli portre: koyulastirilmis/gri tonlu siluet + kose disi kilit
  /// isareti (DESIGN §11 "lock and silhouette, never a fabricated level
  /// requirement").
  Widget _buildLockedContent() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
          child: Opacity(opacity: 0.5, child: _buildPortrait()),
        ),
        ColoredBox(color: AppColors.outlineInk.withValues(alpha: 0.45)),
        const Center(
          child: RwIcon(
            RwIconId.lock,
            size: _lockIconSize,
            color: AppColors.textOnDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(BuildContext context, {required bool muted}) {
    if (widget.cost == null) {
      return const SizedBox.shrink();
    }
    final Locale locale = Localizations.localeOf(context);
    final String text = RwNumberFormat.integer(widget.cost!, locale);
    final Color textColor =
        muted ? AppColors.textOnDarkSecondary : AppColors.textOnDark;
    final Color iconColor = muted ? AppColors.textOnDarkSecondary : AppColors.aether;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.outlineInk.withValues(alpha: 0.75),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RwIcon(RwIconId.aether, size: _costIconSize, color: iconColor),
            const SizedBox(width: 2.0),
            Text(
              text,
              style: AppTypography.smallLabel.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBadge(Widget child) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.outlineInk,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(_cornerBadgePadding),
        child: child,
      ),
    );
  }

  Widget _buildCountBadge(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String text = RwNumberFormat.integer(widget.count!, locale);
    return _buildCornerBadge(
      Text(
        text,
        style: AppTypography.smallLabel.copyWith(color: AppColors.textOnDark),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.state) {
      case RwDefenderSlotState.empty:
        return Center(
          child: RwIcon(
            RwIconId.plus,
            size: _plusIconSize,
            color: AppMaterials.textSecondary(AppMaterial.stone),
          ),
        );
      case RwDefenderSlotState.locked:
        return _buildLockedContent();
      case RwDefenderSlotState.available:
        return _buildPortrait();
      case RwDefenderSlotState.selected:
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildPortrait(),
            const PositionedDirectional(
              top: _cornerBadgeInset,
              start: _cornerBadgeInset,
              child: SizedBox(
                width: _cornerBadgeSize,
                height: _cornerBadgeSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.selection,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.all(3.0),
                    child: RwIcon(
                      RwIconId.check,
                      size: 14.0,
                      color: AppColors.textOnLight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case RwDefenderSlotState.purchaseable:
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildPortrait(),
            PositionedDirectional(
              start: 0.0,
              end: 0.0,
              bottom: 0.0,
              child: _buildCostRow(context, muted: false),
            ),
          ],
        );
      case RwDefenderSlotState.unaffordable:
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildPortrait(),
            PositionedDirectional(
              start: 0.0,
              end: 0.0,
              bottom: 0.0,
              child: _buildCostRow(context, muted: true),
            ),
          ],
        );
      case RwDefenderSlotState.occupied:
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildPortrait(),
            PositionedDirectional(
              top: _cornerBadgeInset,
              end: _cornerBadgeInset,
              child: SizedBox(
                width: _cornerBadgeSize,
                height: _cornerBadgeSize,
                child: widget.count != null
                    ? _buildCountBadge(context)
                    : _buildCornerBadge(
                        const RwIcon(
                          RwIconId.check,
                          size: 12.0,
                          color: AppColors.textOnDark,
                        ),
                      ),
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = widget.state == RwDefenderSlotState.locked;
    final bool isUnaffordable = widget.state == RwDefenderSlotState.unaffordable;
    final bool isSelected = widget.state == RwDefenderSlotState.selected;
    final bool isDisabledVisual = isLocked || isUnaffordable;
    final bool isInteractive =
        widget.onTap != null && !isLocked && !isUnaffordable;

    final RwSurfaceDepth restingDepth = switch (widget.state) {
      RwDefenderSlotState.purchaseable => RwSurfaceDepth.raised,
      RwDefenderSlotState.available => RwSurfaceDepth.raised,
      RwDefenderSlotState.selected => RwSurfaceDepth.raised,
      RwDefenderSlotState.occupied => RwSurfaceDepth.raised,
      RwDefenderSlotState.empty => RwSurfaceDepth.flat,
      RwDefenderSlotState.locked => RwSurfaceDepth.flat,
      RwDefenderSlotState.unaffordable => RwSurfaceDepth.flat,
    };
    final RwSurfaceDepth depth =
        isInteractive && _isPressed ? RwSurfaceDepth.pressed : restingDepth;

    Widget slot = SizedBox(
      width: widget.size,
      height: widget.size,
      child: RwMaterialSurface(
        material: AppMaterial.stone,
        depth: depth,
        isSelected: isSelected,
        isDisabled: isDisabledVisual,
        padding: EdgeInsetsDirectional.zero,
        // Kimlikten deterministik tohum: ayni yuva her build'de ayni
        // duzensiz siluete sahip olur (RwMaterialSurface sozlesmesi).
        seed: (widget.unitId ?? widget.name ?? widget.state.name).hashCode,
        child: _buildContent(context),
      ),
    );

    if (widget.name != null && widget.name!.isNotEmpty) {
      slot = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          slot,
          const SizedBox(height: _nameGap),
          SizedBox(
            width: widget.size,
            child: Text(
              widget.name!,
              style: AppTypography.smallLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final double touchSize = math.max(widget.size, AppSpacing.minTouchTarget);

    return Semantics(
      container: true,
      button: isInteractive,
      enabled: !isDisabledVisual,
      selected: isSelected,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: isInteractive ? (_) => _setPressed(true) : null,
        onTapUp: isInteractive ? (_) => _setPressed(false) : null,
        onTapCancel: isInteractive ? () => _setPressed(false) : null,
        onTap: isInteractive ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: touchSize,
            minHeight: touchSize,
          ),
          child: Center(child: slot),
        ),
      ),
    );
  }
}
