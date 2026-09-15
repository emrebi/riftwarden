import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';

/// Zafer durumunda odul panelinde tek bir para birimi satirini gosterir.
class ResultRewardRow extends StatelessWidget {
  const ResultRewardRow({
    required this.currency,
    required this.label,
    required this.amount,
    super.key,
  });

  /// Gosterilecek para birimi turu (Aether, Shard veya Cell).
  final RwCurrency currency;

  /// Para biriminin ekrandaki gorunen adi.
  final String label;

  /// Kazanilan miktar.
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          RwCurrencyChip(
            currency: currency,
            amount: amount,
          ),
        ],
      ),
    );
  }
}
