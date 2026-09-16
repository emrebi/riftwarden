import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/features/battle/viewmodel/upgrade_text.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';

/// Savas ekraninda secilen savascinin yetenek dukkani tekliflerini gosteren
/// kompakt panel.
///
/// Savas alanini kapatmamak icin kucuk tutulur. Sahiplik durumunu, guncel
/// maliyeti ve satin alma butonunu barindirir.
class AbilityShopPanel extends StatelessWidget {
  const AbilityShopPanel({
    required this.unitId,
    required this.unitName,
    required this.abilityShop,
    required this.upgrades,
    required this.onBuyAbility,
    required this.onClose,
    super.key,
  });

  /// Yetenekleri gosterilen savascinin kimligi.
  final String unitId;

  /// Savascinin yerellestirilmis adi.
  final String unitName;

  /// Dukkan teklifleri sinyali.
  final ValueListenable<Map<String, ShopOffer>> abilityShop;

  /// Baslik/aciklama metnini cozmek icin `upgradeId` -> [UpgradeConfig].
  /// `ContentRegistry.upgrades` savas basinda bir kez okunur (bkz.
  /// `battle_screen.dart`); bu widget Riverpod'a dogrudan erismez.
  final Map<String, UpgradeConfig> upgrades;

  /// Yetenek satin alma komutunu tetikleyen gericagirim.
  final void Function(String upgradeId) onBuyAbility;

  /// Paneli kapatma eylemi.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: 320.0,
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppRadius.lg),
        ),
        border: Border.all(
          color: AppColors.aetherCyanDim,
          width: 1.0,
        ),
        boxShadow: AppShadows.panel,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Baslik satiri: Savasci adi + yetenekler etiketi ve kapat butonu
          Row(
            children: <Widget>[
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16.0,
                color: AppColors.aetherCyan,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '$unitName — ${l10n.hudAbilities}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              RwIconButton(
                icon: Icons.close_rounded,
                size: AppSpacing.minTouchTarget,
                iconSize: 18.0,
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Teklifler listesi (her savasci icin iki teklif yan yana)
          ValueListenableBuilder<Map<String, ShopOffer>>(
            valueListenable: abilityShop,
            builder: (
              BuildContext context,
              Map<String, ShopOffer> offers,
              _,
            ) {
              final unitOffers = offers.values
                  .where((ShopOffer o) => o.unitId == unitId)
                  .toList(growable: false);

              if (unitOffers.isEmpty) {
                return const SizedBox.shrink();
              }

              return Row(
                children: <Widget>[
                  for (var i = 0; i < unitOffers.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _OfferCard(
                        offer: unitOffers[i],
                        title: switch (upgrades[unitOffers[i].upgradeId]) {
                          final UpgradeConfig u => upgradeTitle(l10n, u),
                          null => unitOffers[i].upgradeId,
                        },
                        description: switch (upgrades[unitOffers[i].upgradeId]) {
                          final UpgradeConfig u => upgradeDescription(l10n, u),
                          null => '',
                        },
                        onBuy: onBuyAbility,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tek bir yetenek teklif karti.
class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.title,
    required this.description,
    required this.onBuy,
  });

  final ShopOffer offer;
  final String title;
  final String description;
  final void Function(String upgradeId) onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOwned = offer.owned;
    final canBuy = offer.canBuy && !isOwned;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isOwned
            ? AppColors.surfaceRaised
            : AppColors.surface.withValues(alpha: 0.7),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppRadius.md),
        ),
        border: Border.all(
          color: isOwned
              ? AppColors.coreTeal
              : (canBuy ? AppColors.aetherCyanDim : AppColors.surfaceRaised),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(
              color: isOwned ? AppColors.coreTeal : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (isOwned)
            Container(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              alignment: AlignmentDirectional.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14.0,
                    color: AppColors.coreTeal,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.hudOwned,
                    style: AppTypography.label.copyWith(
                      color: AppColors.coreTeal,
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              child: GestureDetector(
                onTap: canBuy ? () => onBuy(offer.upgradeId) : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: AlignmentDirectional.center,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: canBuy
                        ? AppColors.surfaceRaised
                        : AppColors.surface.withValues(alpha: 0.4),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.sm),
                    ),
                    border: Border.all(
                      color: canBuy ? AppColors.cta : AppColors.surfaceRaised,
                      width: 1.0,
                    ),
                    boxShadow: canBuy
                        ? AppShadows.glow(AppColors.cta, blurRadius: 4.0)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.bolt_rounded,
                        size: 14.0,
                        color: canBuy
                            ? AppColors.aether
                            : AppColors.textDisabled,
                      ),
                      Text(
                        offer.cost.toString(),
                        style: AppTypography.numeric.copyWith(
                          color: canBuy
                              ? AppColors.aether
                              : AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.hudBuy,
                        style: AppTypography.label.copyWith(
                          color: canBuy
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
