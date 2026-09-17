import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';
import 'package:riftwarden/shared/widgets/rw_ornament.dart';

/// Kart gorsel turu (DESIGN §9). Anatomi hepsinde aynidir (cerceve -> art
/// zone -> baslik -> aciklama -> badge -> action); tur sadece art zone
/// vurgusunu ve govde oranlarini degistirir.
enum RwCardKind {
  /// Genel amacli secim/liste karti; art zone kompakt.
  standard,

  /// Portre baskin savunmaci karti (DESIGN §9 "portrait-dominant").
  defender,

  /// Ilustrasyon ustte baskin upgrade secim karti (DESIGN §13).
  upgrade,
}

/// Kart etkilesim durumu (DESIGN §9).
enum RwCardState {
  standard,
  selected,
  locked,
  disabled,
}

/// Gelistirme, savunmaci ve genel secim karti.
///
/// Govde `RwMaterialSurface` uzerine kurulur (DESIGN §9): dolgu + kalin dis
/// hat, neon gradyan/glow yoktur. Rarity ikincil bir vurgudur (ince ust
/// serit); asil ayrisma durum (secili/kilitli/pasif) ve tur (standard/
/// defender/upgrade) uzerinden olur.
class RwCard extends StatefulWidget {
  const RwCard({
    required this.title,
    required this.rarity,
    super.key,
    this.description,
    this.icon,
    this.badge,
    this.child,
    this.onTap,
    this.isSelected = false,
    this.kind = RwCardKind.standard,
    this.state,
    this.art,
    this.action,
    this.lockReason,
    this.showOrnaments = true,
  });

  final String title;
  final String rarity;
  final String? description;
  final Widget? icon;
  final String? badge;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isSelected;

  /// Kompakt/yogun yerlesimde susleme kapatilabilir.
  final bool showOrnaments;

  /// Kart gorsel turu (DESIGN §9). Varsayilan `standard`.
  final RwCardKind kind;

  /// Acik durum override'i. `null` ise [isSelected]'tan turetilir: true ->
  /// `selected`, aksi `standard`. `onTap == null` olmasi TEK BASINA
  /// `disabled` yapmaz; disabled sadece acikca istenirse uygulanir.
  final RwCardState? state;

  /// Ust art zone icerigi (ileride `RwArt`). `null` ise (varsa) [icon] art
  /// zone'da gosterilir; ikisi de yoksa `standard` turde zone atlanir.
  final Widget? art;

  /// Alt aksiyon/durum bolgesi (fiyat, buton, secim ipucu).
  final Widget? action;

  /// `locked` durumunda art zone uzerinde gosterilen kisa neden; ayrica
  /// semantics etiketine eklenir.
  final String? lockReason;

  @override
  State<RwCard> createState() => _RwCardState();
}

class _RwCardState extends State<RwCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  double _artZoneHeight() => switch (widget.kind) {
        RwCardKind.upgrade => 88.0,
        RwCardKind.defender => 120.0,
        RwCardKind.standard => 56.0,
      };

  bool get _hasArtZone =>
      widget.art != null ||
      widget.icon != null ||
      widget.kind != RwCardKind.standard;

  Widget _buildArtZone(bool isLocked) {
    final Widget content = widget.art ??
        (widget.icon != null ? Center(child: widget.icon) : const SizedBox.shrink());

    return SizedBox(
      height: _artZoneHeight(),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ColoredBox(
            color: AppColors.parchmentEdge.withValues(alpha: 0.4),
            child: content,
          ),
          if (isLocked)
            ColoredBox(
              color: AppColors.outlineInk.withValues(alpha: 0.55),
              child: Center(
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const RwIcon(
                        RwIconId.lock,
                        size: 28.0,
                        color: AppColors.textOnDark,
                      ),
                      if (widget.lockReason != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.lockReason!,
                          style: AppTypography.smallLabel.copyWith(
                            color: AppColors.textOnDark,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnatomy(Color rarityColor, bool isLocked, bool isSelected) {
    final List<Widget> children = <Widget>[
      // Rarity ikincil vurgu: ince ust serit (DESIGN §9 "kept secondary").
      Container(height: 3.0, color: rarityColor),
      if (_hasArtZone) _buildArtZone(isLocked),
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          0.0,
        ),
        child: Text(
          widget.title,
          style: AppTypography.onMaterial(
            AppTypography.sectionTitle,
            AppMaterial.parchment,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (widget.description != null)
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            widget.description!,
            style: AppTypography.onMaterialSecondary(
              AppTypography.bodyMedium,
              AppMaterial.parchment,
            ),
            maxLines: widget.kind == RwCardKind.upgrade ? 3 : 4,
            overflow: TextOverflow.ellipsis,
          ),
        )
      else
        const SizedBox(height: AppSpacing.xs),
      if (widget.action != null)
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: widget.action,
        )
      else
        const SizedBox(height: AppSpacing.sm),
    ];

    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
        if (widget.badge != null)
          PositionedDirectional(
            top: AppSpacing.sm,
            end: AppSpacing.sm,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.parchmentEdge,
                borderRadius: AppBorderRadii.sm,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2.0,
                ),
                child: Text(
                  widget.badge!,
                  style: AppTypography.onMaterialSecondary(
                    AppTypography.smallLabel,
                    AppMaterial.parchment,
                  ),
                ),
              ),
            ),
          ),
        if (isSelected)
          // Secim isareti sadece renkle degil, ayri bir kose glifiyle de
          // okunur (DESIGN §9 "never color alone").
          const PositionedDirectional(
            top: AppSpacing.sm,
            start: AppSpacing.sm,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final RwCardState effectiveState = widget.state ??
        (widget.isSelected ? RwCardState.selected : RwCardState.standard);
    final bool isLocked = effectiveState == RwCardState.locked;
    final bool isDisabled = effectiveState == RwCardState.disabled;
    final bool isSelected = effectiveState == RwCardState.selected;
    final bool isInteractive = widget.onTap != null && !isLocked && !isDisabled;

    final Color rarityColor = AppColors.rarity(widget.rarity);
    final RwSurfaceDepth depth =
        isInteractive && _isPressed ? RwSurfaceDepth.pressed : RwSurfaceDepth.raised;

    final Widget body = widget.child ??
        _buildAnatomy(rarityColor, isLocked, isSelected);

    final Widget surface = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: RwMaterialSurface(
        material: AppMaterial.parchment,
        depth: depth,
        isSelected: isSelected,
        isDisabled: isDisabled,
        padding: EdgeInsetsDirectional.zero,
        decoration: widget.showOrnaments
            ? RwSurfaceOrnaments(
                material: AppMaterial.parchment,
                isSelected: isSelected,
                compact: widget.kind == RwCardKind.upgrade,
              )
            : null,
        child: body,
      ),
    );

    return Semantics(
      container: true,
      button: widget.onTap != null,
      enabled: !isDisabled && !isLocked,
      selected: isSelected,
      child: GestureDetector(
        onTapDown: isInteractive ? (_) => _setPressed(true) : null,
        onTapUp: isInteractive ? (_) => _setPressed(false) : null,
        onTapCancel: isInteractive ? () => _setPressed(false) : null,
        onTap: isInteractive ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: surface,
      ),
    );
  }
}
