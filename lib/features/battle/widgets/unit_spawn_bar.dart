import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

/// Birlik uretim butonlarini barindiran alt serit bileseni.
///
/// Pulse Guard, Arc Ranger ve Titan Frame uretim kartlarini sunar.
/// Aether yetersiz oldugunda butonlar pasiflesir ancak gizlenmez.
class UnitSpawnBar extends StatelessWidget {
  const UnitSpawnBar({
    required this.aether,
    required this.unitCosts,
    required this.onSpawnUnit,
    this.abilityButton,
    super.key,
  });

  /// Guncel Aether bakiyesi sinyali.
  final ValueListenable<int> aether;

  /// Birlik guncel maliyet haritasi sinyali (unitId -> maliyet).
  final ValueListenable<Map<String, int>> unitCosts;

  /// Birlik uretim komutunu tetikleyen gericagirim.
  final void Function(String unitId) onSpawnUnit;

  /// Seridin sonuna eklenebilecek aktif yetenek butonu.
  final Widget? abilityButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _UnitSpawnCard(
              unitId: 'pulse_guard',
              defaultCost: 25,
              name: l10n.unitPulseGuard,
              icon: Icons.shield_rounded,
              aether: aether,
              unitCosts: unitCosts,
              onSpawn: onSpawnUnit,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _UnitSpawnCard(
              unitId: 'arc_ranger',
              defaultCost: 45,
              name: l10n.unitArcRanger,
              icon: Icons.gps_fixed_rounded,
              aether: aether,
              unitCosts: unitCosts,
              onSpawn: onSpawnUnit,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _UnitSpawnCard(
              unitId: 'titan_frame',
              defaultCost: 90,
              name: l10n.unitTitanFrame,
              icon: Icons.view_in_ar_rounded,
              aether: aether,
              unitCosts: unitCosts,
              onSpawn: onSpawnUnit,
            ),
          ),
          if (abilityButton != null) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            abilityButton!,
          ],
        ],
      ),
    );
  }
}

/// Tek bir birik uretim karti.
///
/// Maliyet veya Aether degistiginde yalnizca bu kart yeniden cizilir.
class _UnitSpawnCard extends StatefulWidget {
  const _UnitSpawnCard({
    required this.unitId,
    required this.defaultCost,
    required this.name,
    required this.icon,
    required this.aether,
    required this.unitCosts,
    required this.onSpawn,
  });

  final String unitId;
  final int defaultCost;
  final String name;
  final IconData icon;
  final ValueListenable<int> aether;
  final ValueListenable<Map<String, int>> unitCosts;
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
            final canAfford = currentAether >= cost;

            return ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              child: GestureDetector(
                onTap: canAfford ? () => widget.onSpawn(widget.unitId) : null,
                onTapDown: canAfford ? _handleTapDown : null,
                onTapUp: canAfford ? _handleTapUp : null,
                onTapCancel: canAfford ? _handleTapCancel : null,
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0,
                  duration: AppDuration.instant,
                  child: Container(
                    // SABIT yukseklik DEGIL, minimum yukseklik: icerik
                    // (ikon + ad + maliyet) yazi olcegine gore buyuyebilir.
                    // Sabit 64 dp verildiginde %100 olcekte bile 9 px tasiyor,
                    // buyuk yazi ayarinda daha da kotulesirdi.
                    constraints: const BoxConstraints(
                      minHeight: AppSpacing.minTouchTarget + AppSpacing.lg,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? AppColors.surfaceRaised
                          : AppColors.surface.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.md),
                      ),
                      border: Border.all(
                        color: canAfford
                            ? AppColors.aetherCyanDim
                            : AppColors.surfaceRaised,
                        width: 1.0,
                      ),
                      boxShadow: canAfford
                          ? AppShadows.glow(
                              AppColors.aetherCyan,
                              blurRadius: 4.0,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          widget.icon,
                          size: 18.0,
                          color: canAfford
                              ? AppColors.aetherCyan
                              : AppColors.textDisabled,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTypography.label.copyWith(
                            color: canAfford
                                ? AppColors.textPrimary
                                : AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.bolt_rounded,
                              size: 14.0,
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
  }
}
