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
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_card.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';

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

  // 640x360 en dar ekranda alt seridin ustune sigmasi icin panel ve kart
  // olculeri sabit tutulur; teklif sayisi artarsa yatay/dikey kaydirma
  // devreye girer (bkz. build icindeki cift ScrollView).
  static const double _panelWidth = 272.0;
  static const double _panelMaxHeight = 176.0;
  static const double _cardWidth = 140.0;
  static const double _closeIconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: _panelWidth,
      child: RwPanel(
        variant: RwPanelVariant.smallInfo,
        title: '$unitName — ${l10n.hudAbilities}',
        trailing: RwIconButton(
          icon: Icons.close_rounded,
          tooltip: l10n.commonClose,
          size: AppSpacing.minTouchTarget,
          iconSize: _closeIconSize,
          onPressed: onClose,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _panelMaxHeight),
          child: ValueListenableBuilder<Map<String, ShopOffer>>(
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

              return SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for (var i = 0; i < unitOffers.length; i++) ...<Widget>[
                        if (i > 0) const SizedBox(width: AppSpacing.xs),
                        SizedBox(
                          width: _cardWidth,
                          child: _OfferCard(
                            offer: unitOffers[i],
                            title: switch (upgrades[unitOffers[i].upgradeId]) {
                              final UpgradeConfig u => upgradeTitle(l10n, u),
                              null => unitOffers[i].upgradeId,
                            },
                            description: switch (
                              upgrades[unitOffers[i].upgradeId]
                            ) {
                              final UpgradeConfig u =>
                                upgradeDescription(l10n, u),
                              null => '',
                            },
                            onBuy: onBuyAbility,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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

  static const double _ownedIconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOwned = offer.owned;
    final canBuy = offer.canBuy && !isOwned;

    return RwCard(
      title: title,
      description: description.isEmpty ? null : description,
      // Yetenek tekliflerinde nadirlik ayrimi yok; kart durumu (sahip/
      // alinabilir/pasif) tek anlamli sinyal oldugundan notr bir deger
      // kullanilir.
      rarity: 'common',
      isSelected: isOwned,
      state: (!canBuy && !isOwned) ? RwCardState.disabled : null,
      action: isOwned
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const RwIcon(
                  RwIconId.check,
                  size: _ownedIconSize,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.hudOwned,
                  style: AppTypography.onMaterialSecondary(
                    AppTypography.smallLabel,
                    AppMaterial.parchment,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RwCurrencyChip(
                  currency: RwCurrency.aether,
                  amount: offer.cost,
                  compact: true,
                ),
                const SizedBox(height: AppSpacing.xs),
                RwButton(
                  label: l10n.hudBuy,
                  onPressed: canBuy ? () => onBuy(offer.upgradeId) : null,
                  isExpanded: true,
                ),
              ],
            ),
    );
  }
}
