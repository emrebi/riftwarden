import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/format/rw_number_format.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Oyun ici para birimleri.
enum RwCurrency {
  aether,
  shard,
  cell,
}

/// Para birimi ve miktar gostergesi.
///
/// Govde `RwMaterialSurface(shape: pill)` uzerine kurulur (DESIGN §10, §16):
/// dokunulamaz gosterge duz (`flat`) derinlikte durur, dokunulabilir
/// (`onTap`) govde `raised` dinlenir ve basildiginda `pressed`e gecer.
/// Rakamlar deger degisiminde kaymayi onlemek icin tabular font ozelligine
/// sahip `AppTypography.numeric` kullanir.
class RwCurrencyChip extends StatefulWidget {
  const RwCurrencyChip({
    required this.currency,
    required this.amount,
    super.key,
    this.onTap,
    this.material = AppMaterial.hud,
    this.compact = false,
  });

  final RwCurrency currency;
  final int amount;
  final VoidCallback? onTap;

  /// Yuzey malzemesi (DESIGN §3, §8). Varsayilan `hud`; savas disi
  /// parchment panellerinde `AppMaterial.parchment` da kullanilabilir.
  final AppMaterial material;

  /// `true` ise `RwNumberFormat.compact` (orn. 12K), aksi halde
  /// `RwNumberFormat.integer` ile gruplu tam sayi gosterilir.
  final bool compact;

  @override
  State<RwCurrencyChip> createState() => _RwCurrencyChipState();
}

class _RwCurrencyChipState extends State<RwCurrencyChip> {
  /// Para birimi ikon boyutu. Tek kullanim yeri burasi oldugundan tek
  /// noktada tanimlanir.
  static const double _iconSize = 16.0;

  /// Dokunulamaz gostergenin kompakt yuksekligi (DESIGN §10 "resource chip").
  static const double _compactHeight = 32.0;

  bool _isPressed = false;

  bool get _isInteractive => widget.onTap != null;

  void _setPressed(bool value) {
    if (_isInteractive && _isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  Color get _currencyColor => switch (widget.currency) {
        RwCurrency.aether => AppColors.aether,
        RwCurrency.shard => AppColors.shard,
        RwCurrency.cell => AppColors.cell,
      };

  RwIconId get _iconId => switch (widget.currency) {
        RwCurrency.aether => RwIconId.aether,
        RwCurrency.shard => RwIconId.shard,
        RwCurrency.cell => RwIconId.cell,
      };

  @override
  Widget build(BuildContext context) {
    final RwSurfaceDepth restingDepth =
        _isInteractive ? RwSurfaceDepth.raised : RwSurfaceDepth.flat;
    final RwSurfaceDepth depth =
        _isInteractive && _isPressed ? RwSurfaceDepth.pressed : restingDepth;

    final String amountText = widget.compact
        ? RwNumberFormat.compact(widget.amount, Localizations.localeOf(context))
        : RwNumberFormat.integer(widget.amount, Localizations.localeOf(context));

    final TextStyle amountStyle =
        AppTypography.onMaterial(AppTypography.numeric, widget.material);

    final double effectiveHeight =
        _isInteractive ? AppSpacing.minTouchTarget : _compactHeight;

    final Widget surface = SizedBox(
      height: effectiveHeight,
      child: RwMaterialSurface(
        material: widget.material,
        shape: RwSurfaceShape.pill,
        depth: depth,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RwIcon(
              _iconId,
              size: _iconSize,
              color: _currencyColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(amountText, style: amountStyle),
          ],
        ),
      ),
    );

    return Semantics(
      label: amountText,
      button: _isInteractive,
      excludeSemantics: true,
      child: _isInteractive
          ? GestureDetector(
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: surface,
            )
          : surface,
    );
  }
}
