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
import 'package:riftwarden/features/battle/widgets/battle_pause_overlay.dart';
import 'package:riftwarden/features/battle/widgets/battle_top_bar.dart';
import 'package:riftwarden/features/battle/widgets/core_health_bar.dart';
import 'package:riftwarden/features/battle/widgets/unit_spawn_bar.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';

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
  bool _isPaused = false;

  VoidCallback get _handleExit => widget.onExit ?? widget.onBack ?? () {};

  @override
  void initState() {
    super.initState();
    // ContentRegistry tek seferlik okunur; savas dongusunde Riverpod kullanilmaz
    final content = ref.read(contentRegistryProvider);
    _game = RiftwardenGame(
      level: content.level(widget.levelId),
      content: content,
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

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

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
                        final l10n = AppLocalizations.of(context);
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
                            color: AppColors.voidDeep.withValues(alpha: 0.35),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceOverlay,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(AppRadius.pill),
                                  ),
                                  border: Border.all(
                                    color: AppColors.aetherCyan,
                                    width: 1.0,
                                  ),
                                  boxShadow: AppShadows.glow(
                                    AppColors.aetherCyan,
                                    blurRadius: 12.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.crisis_alert_rounded,
                                      size: 20.0,
                                      color: AppColors.aetherCyan,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      l10n.battleAimHint,
                                      style: AppTypography.label.copyWith(
                                        color: AppColors.aetherCyan,
                                        letterSpacing: 1.2,
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

            // Ust serit: Duraklatma, dalga ilerlemesi, Aether sayaci
              PositionedDirectional(
                top: 0.0,
                start: 0.0,
                end: 0.0,
                child: BattleTopBar(
                  waveProgress: _game.signals.wave,
                  aether: _game.signals.aether,
                  onPause: _pause,
                  topPadding: viewPadding.top,
                ),
              ),

            // Alt serit: Core HP ve birlik uretim / yetenek butonlari
              PositionedDirectional(
                bottom: 0.0,
                start: 0.0,
                end: 0.0,
                child: Container(
                  padding: EdgeInsetsDirectional.only(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CoreHealthBar(
                        coreHpRatio: _game.signals.coreHpRatio,
                        coreHp: _game.signals.coreHp,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      UnitSpawnBar(
                        aether: _game.signals.aether,
                        unitCosts: _game.signals.unitCosts,
                        onSpawnUnit: _game.commands.requestUnit,
                        abilityButton: AbilityButton(
                          ability: _game.signals.ability,
                          onToggleAiming: _game.commands.toggleAbilityAiming,
                        ),
                      ),
                    ],
                  ),
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
