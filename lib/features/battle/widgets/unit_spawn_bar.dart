import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/format/rw_number_format.dart';
import 'package:riftwarden/shared/widgets/rw_defender_slot.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Birlik uretim ve yetenek butonlarini barindiran alt serit bileseni.
///
/// Pulse Guard, Arc Ranger ve Titan Frame icin `RwDefenderSlot` uretim
/// yuvasi ve yetenek dukkani acma butonunu sunar. Sag ucunda ise Rift
/// Collapse aktif yetenek butonu yer alir.
class UnitSpawnBar extends StatelessWidget {
  const UnitSpawnBar({
    required this.aether,
    required this.unitCosts,
    required this.slots,
    required this.abilityShop,
    required this.onSpawnUnit,
    required this.onToggleAbilities,
    required this.abilityButton,
    this.selectedShopUnitId,
    super.key,
  });

  /// Guncel Aether bakiyesi sinyali.
  final ValueListenable<int> aether;

  /// Birlik guncel maliyet haritasi sinyali (unitId -> maliyet).
  final ValueListenable<Map<String, int>> unitCosts;

  /// Kale yuvalarinin doluluk durumu sinyali.
  final ValueListenable<List<SlotState>> slots;

  /// Yetenek dukkani teklifleri sinyali.
  final ValueListenable<Map<String, ShopOffer>> abilityShop;

  /// Birlik uretim komutunu tetikleyen gericagirim.
  final void Function(String unitId) onSpawnUnit;

  /// Yetenek panelini acip kapatan gericagirim.
  final void Function(String unitId) onToggleAbilities;

  /// Seridin sag ucundaki Rift Collapse butonu.
  final Widget abilityButton;

  /// Yetenek paneli acik olan savasci kimligi (yoksa null).
  final String? selectedShopUnitId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: _UnitPurchaseRow(
            unitId: 'pulse_guard',
            defaultCost: 25,
            name: l10n.unitPulseGuard,
            aether: aether,
            unitCosts: unitCosts,
            slots: slots,
            abilityShop: abilityShop,
            isShopOpen: selectedShopUnitId == 'pulse_guard',
            onSpawn: onSpawnUnit,
            onToggleAbilities: onToggleAbilities,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _UnitPurchaseRow(
            unitId: 'arc_ranger',
            defaultCost: 45,
            name: l10n.unitArcRanger,
            aether: aether,
            unitCosts: unitCosts,
            slots: slots,
            abilityShop: abilityShop,
            isShopOpen: selectedShopUnitId == 'arc_ranger',
            onSpawn: onSpawnUnit,
            onToggleAbilities: onToggleAbilities,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _UnitPurchaseRow(
            unitId: 'titan_frame',
            defaultCost: 90,
            name: l10n.unitTitanFrame,
            aether: aether,
            unitCosts: unitCosts,
            slots: slots,
            abilityShop: abilityShop,
            isShopOpen: selectedShopUnitId == 'titan_frame',
            onSpawn: onSpawnUnit,
            onToggleAbilities: onToggleAbilities,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        _CapacityIndicator(slots: slots),
        const SizedBox(width: AppSpacing.xs),
        abilityButton,
      ],
    );
  }
}

/// Tek bir savasci tipi icin uretim yuvasi ve yetenek butonunu birlestiren satir.
class _UnitPurchaseRow extends StatelessWidget {
  const _UnitPurchaseRow({
    required this.unitId,
    required this.defaultCost,
    required this.name,
    required this.aether,
    required this.unitCosts,
    required this.slots,
    required this.abilityShop,
    required this.isShopOpen,
    required this.onSpawn,
    required this.onToggleAbilities,
  });

  final String unitId;
  final int defaultCost;
  final String name;
  final ValueListenable<int> aether;
  final ValueListenable<Map<String, int>> unitCosts;
  final ValueListenable<List<SlotState>> slots;
  final ValueListenable<Map<String, ShopOffer>> abilityShop;
  final bool isShopOpen;
  final void Function(String unitId) onSpawn;
  final void Function(String unitId) onToggleAbilities;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: _DefenderPurchaseSlot(
              unitId: unitId,
              defaultCost: defaultCost,
              name: name,
              aether: aether,
              unitCosts: unitCosts,
              slots: slots,
              onSpawn: onSpawn,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        _AbilityToggleButton(
          unitId: unitId,
          abilityShop: abilityShop,
          isOpen: isShopOpen,
          onTap: () => onToggleAbilities(unitId),
        ),
      ],
    );
  }
}

/// Birlik uretim yuvasi (`RwDefenderSlot`).
///
/// Maliyet, Aether veya yuva doluluğu degistiginde yalnizca bu yuva
/// yeniden cizilir. Yuva boyutu alt seridin %20 yukseklik sinirina
/// (DESIGN §10) sigmasi icin dokunma hedefiyle ayni tutulur.
class _DefenderPurchaseSlot extends StatelessWidget {
  const _DefenderPurchaseSlot({
    required this.unitId,
    required this.defaultCost,
    required this.name,
    required this.aether,
    required this.unitCosts,
    required this.slots,
    required this.onSpawn,
  });

  final String unitId;
  final int defaultCost;
  final String name;
  final ValueListenable<int> aether;
  final ValueListenable<Map<String, int>> unitCosts;
  final ValueListenable<List<SlotState>> slots;
  final void Function(String unitId) onSpawn;

  // Alt serit yuksekligi butceli oldugundan yuva boyutu dokunma hedefiyle
  // ayni tutulur (brief: "pick slot size via a static const so it fits").
  static const double _slotSize = AppSpacing.minTouchTarget;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: unitCosts,
      builder: (BuildContext context, Map<String, int> costs, _) {
        final cost = costs[unitId] ?? defaultCost;

        return ValueListenableBuilder<int>(
          valueListenable: aether,
          builder: (BuildContext context, int currentAether, _) {
            return ValueListenableBuilder<List<SlotState>>(
              valueListenable: slots,
              builder: (BuildContext context, List<SlotState> slotStates, _) {
                final hasFreeSlot = slotStates.isEmpty ||
                    slotStates.any((SlotState s) => s.unitId == null);
                final canAfford = currentAether >= cost;

                RwDefenderSlotState state;
                int? slotCost;
                VoidCallback? onTap;
                if (!hasFreeSlot) {
                  // Kale kapasitesi dolu: bu birligi satin almak imkansiz.
                  // Doluluk sayisi artik paylasilan _CapacityIndicator'da
                  // gosterildiginden burada ayrica rozet basilmaz.
                  state = RwDefenderSlotState.occupied;
                } else if (!canAfford) {
                  state = RwDefenderSlotState.unaffordable;
                  slotCost = cost;
                } else {
                  state = RwDefenderSlotState.purchaseable;
                  slotCost = cost;
                  onTap = () => onSpawn(unitId);
                }

                return RwDefenderSlot(
                  state: state,
                  unitId: unitId,
                  cost: slotCost,
                  onTap: onTap,
                  size: _slotSize,
                  semanticLabel: name,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Savascinin yanindaki yetenek dukkani acma butonu.
///
/// Dokunuldugunda savascinin yetenek dukkani panelini acar. Alinabilir bir
/// yetenek varsa kose rozetinde ayri bir simge (renkten bagimsiz sekil
/// farki, DESIGN §24) ile vurgulanir.
class _AbilityToggleButton extends StatelessWidget {
  const _AbilityToggleButton({
    required this.unitId,
    required this.abilityShop,
    required this.isOpen,
    required this.onTap,
  });

  final String unitId;
  final ValueListenable<Map<String, ShopOffer>> abilityShop;
  final bool isOpen;
  final VoidCallback onTap;

  static const double _badgeIconSize = 10.0;
  static const double _badgePadding = 2.0;
  static const double _badgeInset = -2.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<Map<String, ShopOffer>>(
      valueListenable: abilityShop,
      builder: (BuildContext context, Map<String, ShopOffer> offers, _) {
        final hasAffordable = offers.values.any(
          (ShopOffer o) => o.unitId == unitId && o.canBuy && !o.owned,
        );

        return Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            RwIconButton(
              rwIcon: RwIconId.magic,
              onPressed: onTap,
              tooltip: l10n.hudAbilities,
              isSelected: isOpen,
            ),
            if (hasAffordable && !isOpen)
              const PositionedDirectional(
                top: _badgeInset,
                end: _badgeInset,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.cta,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.all(_badgePadding),
                    child: RwIcon(
                      RwIconId.level,
                      size: _badgeIconSize,
                      color: AppColors.textOnLight,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Kale genelindeki paylasilan yuva kapasitesi gostergesi.
///
/// Yuva havuzu tum savasci tiplerinde ortak oldugundan tek bir kompakt
/// kapsul yeterlidir; yuva basina tekrarlanan "x/6" etiketi yerine burada
/// bir kez gosterilir. Dolulukta simge kilide doner (renkten bagimsiz
/// uyari, DESIGN §24).
class _CapacityIndicator extends StatelessWidget {
  const _CapacityIndicator({required this.slots});

  final ValueListenable<List<SlotState>> slots;

  static const double _iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SlotState>>(
      valueListenable: slots,
      builder: (BuildContext context, List<SlotState> slotStates, _) {
        final total = slotStates.length;
        final occupied =
            slotStates.where((SlotState s) => s.unitId != null).length;
        final isFull = total > 0 && occupied >= total;
        final locale = Localizations.localeOf(context);
        final capacityText =
            '${RwNumberFormat.integer(occupied, locale)}/${RwNumberFormat.integer(total, locale)}';
        final textColor = isFull
            ? AppColors.danger
            : AppMaterials.text(AppMaterial.hud);

        return RwMaterialSurface(
          material: AppMaterial.hud,
          shape: RwSurfaceShape.pill,
          depth: RwSurfaceDepth.flat,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RwIcon(
                isFull ? RwIconId.lock : RwIconId.support,
                size: _iconSize,
                color: textColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                capacityText,
                style: AppTypography.onMaterial(
                  AppTypography.smallLabel,
                  AppMaterial.hud,
                ).copyWith(color: textColor),
              ),
            ],
          ),
        );
      },
    );
  }
}
