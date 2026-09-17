import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/riftwarden_game.dart';
import 'package:riftwarden/features/battle/widgets/ability_button.dart';
import 'package:riftwarden/features/battle/widgets/ability_shop_panel.dart';
import 'package:riftwarden/features/battle/widgets/battle_pause_overlay.dart';
import 'package:riftwarden/features/battle/widgets/battle_top_bar.dart';
import 'package:riftwarden/features/battle/widgets/core_health_bar.dart';
import 'package:riftwarden/features/battle/widgets/unit_spawn_bar.dart';
import 'package:riftwarden/features/battle/widgets/upgrade_choice_overlay.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';

/// Savas ekrani.
///
/// Oyun alani uzerinde sade ve savas alanini kapatmayan bir HUD sunar.
/// Savas verisi Riverpod yerine BattleSignals uzerinden okunur.
class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({
    required this.levelId,
    this.onExit,
    this.onBack,
    super.key,
  });

  /// Yuklenecek seviye kimligi.
  final int levelId;

  /// Ana menuye donus eylemi.
  final VoidCallback? onExit;

  /// Geri donus eylemi (geriye uyumluluk).
  final VoidCallback? onBack;

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  late final RiftwardenGame _game;
  late final ContentRegistry _content;
  bool _isPaused = false;
  String? _selectedShopUnitId;

  /// Ust seridin toplam yuksekligi (xs ust pay + 48 govde + xs alt pay);
  /// Core HP bari bu seridin altina, aralarinda ek bosluk birakarak oturur.
  static const double _topBarHeight = AppSpacing.xs + 48.0 + AppSpacing.xs;
  static const double _coreHealthBarWidth = 180.0;
  static const double _aimHintIconSize = 20.0;

  VoidCallback get _handleExit => widget.onExit ?? widget.onBack ?? () {};

  @override
  void initState() {
    super.initState();
    // ContentRegistry tek seferlik okunur; savas dongusunde Riverpod kullanilmaz
    _content = ref.read(contentRegistryProvider);
    _game = RiftwardenGame(
      level: _content.level(widget.levelId),
      content: _content,
      seed: DateTime.now().millisecondsSinceEpoch,
      initialUpgrades: const [],
    );
  }

  void _pause() {
    _game.commands.pause();
    setState(() => _isPaused = true);
  }

  void _resume() {
    _game.commands.resume();
    setState(() => _isPaused = false);
  }

  void _exit() {
    _game.commands.pause();
    _handleExit();
  }

  String _unitName(AppLocalizations l10n, String unitId) => switch (unitId) {
        'pulse_guard' => l10n.unitPulseGuard,
        'arc_ranger' => l10n.unitArcRanger,
        'titan_frame' => l10n.unitTitanFrame,
        _ => unitId,
      };

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final startPadding = isRtl ? viewPadding.right : viewPadding.left;
    final endPadding = isRtl ? viewPadding.left : viewPadding.right;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }
        if (_isPaused) {
          _resume();
        } else {
          _pause();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.voidDeep,
        body: Stack(
          // ZORUNLU: Stack kendini POZISYONLANMAMIS cocuklarina gore
          // boyutlandirir. Buradaki cocuklarin hepsi Positioned* ya da
          // (nisan modu kapaliyken) SizedBox.shrink oldugu icin Stack
          // 0x0'a coker, Positioned.fill de sifiri doldurur ve TUM EKRAN
          // bos gorunur. `expand` ile Stack kendisine verilen alani kaplar.
          fit: StackFit.expand,
          children: <Widget>[
            // Savas alani tam ekrani kaplar ve centigin altina uzanir
            Positioned.fill(
              child: GameWidget(
                game: _game,
                // Hata yutulmasin: onLoad patlarsa siyah ekran yerine
                // sebebini goster. Bu olmadan yukleme hatasini teshis
                // etmek cihazda neredeyse imkansiz.
                errorBuilder: (BuildContext context, Object error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      '$error',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.danger),
                    ),
                  ),
                ),
                loadingBuilder: (BuildContext context) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.aetherCyan,
                  ),
                ),
              ),
            ),

            // Yetenek nisan alma modu katmani
            ValueListenableBuilder<AbilityState>(
              valueListenable: _game.signals.ability,
              builder: (BuildContext context, AbilityState ability, _) {
                if (!ability.isAiming) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (TapDownDetails details) {
                          final width = constraints.maxWidth;
                          final height = constraints.maxHeight;
                          if (width > 0 && height > 0) {
                            final nx = (details.localPosition.dx / width)
                                .clamp(0.0, 1.0);
                            final ny = (details.localPosition.dy / height)
                                .clamp(0.0, 1.0);
                            _game.commands.castAbilityAt(nx, ny);
                          }
                        },
                        child: Container(
                          color: AppColors.hudEdge.withValues(alpha: 0.35),
                          child: Center(
                            child: RwMaterialSurface(
                              material: AppMaterial.hud,
                              shape: RwSurfaceShape.pill,
                              depth: RwSurfaceDepth.raised,
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  RwIcon(
                                    RwIconId.rift,
                                    size: _aimHintIconSize,
                                    color: AppMaterials.text(AppMaterial.hud),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    l10n.battleAimHint,
                                    style: AppTypography.onMaterial(
                                      AppTypography.label,
                                      AppMaterial.hud,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Ust ince serit: Duraklatma, dalga ilerlemesi, Aether sayaci
            PositionedDirectional(
              top: 0.0,
              start: 0.0,
              end: 0.0,
              child: BattleTopBar(
                waveProgress: _game.signals.wave,
                aether: _game.signals.aether,
                onPause: _pause,
                topPadding: viewPadding.top,
                startPadding: startPadding,
                endPadding: endPadding,
              ),
            ),

            // Kale HP bari: Ust seridin altinda, sol tarafta (kalenin ustu)
            PositionedDirectional(
              top: viewPadding.top + _topBarHeight + AppSpacing.xs,
              start: startPadding + AppSpacing.md,
              child: SizedBox(
                width: _coreHealthBarWidth,
                child: CoreHealthBar(
                  coreHpRatio: _game.signals.coreHpRatio,
                  coreHp: _game.signals.coreHp,
                ),
              ),
            ),

            // Yetenek dukkani acikken arkaya tiklamayla kapatma katmani
            if (_selectedShopUnitId != null)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedShopUnitId = null),
                ),
              ),

            // Secilen savascinin yetenek dukkani paneli
            if (_selectedShopUnitId != null)
              PositionedDirectional(
                bottom: viewPadding.bottom + 64.0,
                start: startPadding + AppSpacing.md,
                child: AbilityShopPanel(
                  unitId: _selectedShopUnitId!,
                  unitName: _unitName(l10n, _selectedShopUnitId!),
                  abilityShop: _game.signals.abilityShop,
                  upgrades: _content.upgrades,
                  onBuyAbility: _game.commands.buyAbility,
                  onClose: () => setState(() => _selectedShopUnitId = null),
                ),
              ),

            // Alt serit: Savasci uretim butonlari, yetenek alanlari ve Rift Collapse
            PositionedDirectional(
              bottom: 0.0,
              start: 0.0,
              end: 0.0,
              child: Container(
                padding: EdgeInsetsDirectional.only(
                  start: startPadding + AppSpacing.md,
                  end: endPadding + AppSpacing.md,
                  top: AppSpacing.xs,
                  bottom: viewPadding.bottom + AppSpacing.xs,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topCenter,
                    end: AlignmentDirectional.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      AppColors.surfaceOverlay,
                    ],
                  ),
                ),
                child: UnitSpawnBar(
                  aether: _game.signals.aether,
                  unitCosts: _game.signals.unitCosts,
                  slots: _game.signals.slots,
                  abilityShop: _game.signals.abilityShop,
                  selectedShopUnitId: _selectedShopUnitId,
                  onSpawnUnit: _game.commands.requestUnit,
                  onToggleAbilities: (String unitId) {
                    setState(() {
                      if (_selectedShopUnitId == unitId) {
                        _selectedShopUnitId = null;
                      } else {
                        _selectedShopUnitId = unitId;
                      }
                    });
                  },
                  abilityButton: AbilityButton(
                    ability: _game.signals.ability,
                    onToggleAiming: _game.commands.toggleAbilityAiming,
                  ),
                ),
              ),
            ),

            // Esik karti (upgrade) secim katmani: teklif aciksa savas zaten
            // motor tarafinda slow-mo/pause'da, katman bunu sadece gosterir
            Positioned.fill(
              child: UpgradeChoiceOverlay(
                offer: _game.signals.upgradeOffer,
                upgrades: _content.upgrades,
                onChoose: _game.commands.chooseUpgrade,
                onReroll: _game.commands.rerollUpgrades,
              ),
            ),

            // Duraklatma ekrani
            if (_isPaused)
              Positioned.fill(
                child: BattlePauseOverlay(
                  onResume: _resume,
                  onExit: _exit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
