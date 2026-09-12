import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';

/// Oyun ici para birimleri.
enum RwCurrency {
  aether,
  shard,
  cell,
}

/// Para birimi ve miktar gostergesi.
///
/// Henuz sprite'lar bulunmadigi icin renkli geometrik sekil kullanir.
/// Rakamlar deger degisiminde kaymayi onlemek icin tabular font ozelligine sahiptir.
class RwCurrencyChip extends StatelessWidget {
  const RwCurrencyChip({
    required this.currency,
    required this.amount,
    super.key,
    this.onTap,
  });

  final RwCurrency currency;
  final int amount;
  final VoidCallback? onTap;

  Color get _currencyColor => switch (currency) {
        RwCurrency.aether => AppColors.aether,
        RwCurrency.shard => AppColors.shard,
        RwCurrency.cell => AppColors.cell,
      };

  @override
  Widget build(BuildContext context) {
    final color = _currencyColor;

    Widget chip = Container(
      constraints: BoxConstraints(
        minHeight: onTap != null ? AppSpacing.minTouchTarget : 32.0,
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: AppBorderRadii.pill,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Gecici renkli elmas gostergesi
          Transform.rotate(
            angle: 0.785398, // 45 derece
            child: Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1.0),
                boxShadow: AppShadows.glow(color, blurRadius: 4.0),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            amount.toString(),
            style: AppTypography.numeric.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      chip = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: chip,
      );
    }

    return chip;
  }
}
