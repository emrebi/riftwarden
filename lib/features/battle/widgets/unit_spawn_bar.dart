import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

/// Birlik uretim ve yetenek butonlarini barindiran alt serit bileseni.
///
/// Pulse Guard, Arc Ranger ve Titan Frame icin uretim karti ve yetenek
/// paneli butonlarini sunar. Sag ucunda ise Rift Collapse aktif yetenek
/// butonu yer alir.
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
          child: _UnitControlGroup(
            unitId: 'pulse_guard',
            defaultCost: 25,
            name: l10n.unitPulseGuard,
            icon: Icons.shield_rounded,
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
          child: _UnitControlGroup(
            unitId: 'arc_ranger',
            defaultCost: 45,
            name: l10n.unitArcRanger,
            icon: Icons.gps_fixed_rounded,
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
          child: _UnitControlGroup(
            unitId: 'titan_frame',
            defaultCost: 90,
            name: l10n.unitTitanFrame,
            icon: Icons.view_in_ar_rounded,
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
        abilityButton,
      ],
    );
  }
}

/// Tek bir savasci tipi icin uretim karti ve yetenek butonunu birlestiren grup.
class _UnitControlGroup extends StatelessWidget {
  const _UnitControlGroup({
    required this.unitId,
    required this.defaultCost,
    required this.name,
    required this.icon,
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
  final IconData icon;
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
          child: _UnitSpawnCard(
            unitId: unitId,
            defaultCost: defaultCost,
            name: name,
            icon: icon,
            aether: aether,
            unitCosts: unitCosts,
            slots: slots,
            onSpawn: onSpawn,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        _UnitAbilitiesButton(
          unitId: unitId,
          abilityShop: abilityShop,
          isOpen: isShopOpen,
          onTap: () => onToggleAbilities(unitId),
        ),
      ],
    );
  }
}

/// Birlik uretim karti.
///
/// Maliyet veya Aether degistiginde yalnizca bu kart yeniden cizilir.
/// Aether yetmezse veya bos yuva yoksa buton pasif gorunur ama gizlenmez.
class _UnitSpawnCard extends StatefulWidget {
  const _UnitSpawnCard({
    required this.unitId,
    required this.defaultCost,
    required this.name,
    required this.icon,
    required this.aether,
    required this.unitCosts,
    required this.slots,
    required this.onSpawn,
  });

  final String unitId;
  final int defaultCost;
  final String name;
  final IconData icon;
  final ValueListenable<int> aether;
  final ValueListenable<Map<String, int>> unitCosts;
  final ValueListenable<List<SlotState>> slots;
  final void Function(String unitId) onSpawn;

  @override
  State<_UnitSpawnCard> createState() => _UnitSpawnCardState();
}

class _UnitSpawnCardState extends State<_UnitSpawnCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: widget.unitCosts,
      builder: (BuildContext context, Map<String, int> costs, _) {
        final cost = costs[widget.unitId] ?? widget.defaultCost;

        return ValueListenableBuilder<int>(
          valueListenable: widget.aether,
          builder: (BuildContext context, int currentAether, _) {
            return ValueListenableBuilder<List<SlotState>>(
              valueListenable: widget.slots,
              builder: (BuildContext context, List<SlotState> slotStates, _) {
                final totalSlots = slotStates.length;
                final occupiedSlots =
                    slotStates.where((SlotState s) => s.unitId != null).length;
                final hasFreeSlot = slotStates.isEmpty ||
                    slotStates.any((SlotState s) => s.unitId == null);
                final canAfford = currentAether >= cost;
                final canSpawn = canAfford && hasFreeSlot;

                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.minTouchTarget,
                  ),
                  child: GestureDetector(
                    onTap: canSpawn ? () => widget.onSpawn(widget.unitId) : null,
                    onTapDown: canSpawn ? _handleTapDown : null,
                    onTapUp: canSpawn ? _handleTapUp : null,
                    onTapCancel: canSpawn ? _handleTapCancel : null,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedScale(
                      scale: _isPressed ? 0.95 : 1.0,
                      duration: AppDuration.instant,
                      child: Container(
                        height: 52.0,
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: canSpawn
                              ? AppColors.surfaceRaised
                              : AppColors.surface.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(AppRadius.md),
                          ),
                          border: Border.all(
                            color: canSpawn
                                ? AppColors.aetherCyanDim
                                : AppColors.surfaceRaised,
                            width: 1.0,
                          ),
                          boxShadow: canSpawn
                              ? AppShadows.glow(
                                  AppColors.aetherCyan,
                                  blurRadius: 4.0,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Ust satir: Simge ve savasci adi
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  widget.icon,
                                  size: 14.0,
                                  color: canSpawn
                                      ? AppColors.aetherCyan
                                      : AppColors.textDisabled,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: Text(
                                    widget.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.label.copyWith(
                                      color: canSpawn
                                          ? AppColors.textPrimary
                                          : AppColors.textDisabled,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            // Alt satir: Maliyet ve yuva doluluk gostergesi (4/6)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.bolt_rounded,
                                      size: 12.0,
                                      color: canAfford
                                          ? AppColors.aether
                                          : AppColors.textDisabled,
                                    ),
                                    Text(
                                      cost.toString(),
                                      style: AppTypography.numeric.copyWith(
                                        color: canAfford
                                            ? AppColors.aether
                                            : AppColors.textDisabled,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.crop_square_rounded,
                                      size: 11.0,
                                      color: hasFreeSlot
                                          ? (canSpawn
                                              ? AppColors.textSecondary
                                              : AppColors.textDisabled)
                                          : AppColors.danger,
                                    ),
                                    const SizedBox(width: 2.0),
                                    Text(
                                      totalSlots > 0
                                          ? '$occupiedSlots/$totalSlots'
                                          : '-',
                                      style: AppTypography.numeric.copyWith(
                                        color: hasFreeSlot
                                            ? (canSpawn
                                                ? AppColors.textSecondary
                                                : AppColors.textDisabled)
                                            : AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Savascinin yanindaki kucuk yetenekler dokunma alani.
///
/// Dokunuldugunda savascinin yetenek dukkani panelini acar.
/// Alinabilir bir yetenek varsa kehribar rengiyle vurgulanir.
class _UnitAbilitiesButton extends StatelessWidget {
  const _UnitAbilitiesButton({
    required this.unitId,
    required this.abilityShop,
    required this.isOpen,
    required this.onTap,
  });

  final String unitId;
  final ValueListenable<Map<String, ShopOffer>> abilityShop;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<Map<String, ShopOffer>>(
      valueListenable: abilityShop,
      builder: (BuildContext context, Map<String, ShopOffer> offers, _) {
        final hasAffordable = offers.values.any(
          (ShopOffer o) => o.unitId == unitId && o.canBuy && !o.owned,
        );

        final Color borderColor = isOpen
            ? AppColors.aetherCyan
            : (hasAffordable ? AppColors.aether : AppColors.surfaceRaised);

        final Color iconColor = isOpen
            ? AppColors.aetherCyan
            : (hasAffordable ? AppColors.aether : AppColors.textSecondary);

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: AppSpacing.minTouchTarget,
          ),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Tooltip(
              message: l10n.hudAbilities,
              child: Container(
                width: AppSpacing.minTouchTarget,
                height: 52.0,
                padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isOpen
                      ? AppColors.surfaceRaised
                      : AppColors.surface.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.md),
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: isOpen ? 1.5 : 1.0,
                  ),
                  boxShadow: isOpen
                      ? AppShadows.glow(AppColors.aetherCyan, blurRadius: 6.0)
                      : (hasAffordable
                          ? AppShadows.glow(AppColors.aether, blurRadius: 4.0)
                          : null),
                ),
                child: Center(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 18.0,
                        color: iconColor,
                      ),
                      if (hasAffordable && !isOpen)
                        PositionedDirectional(
                          top: 0.0,
                          end: 0.0,
                          child: Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: const BoxDecoration(
                              color: AppColors.aether,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
