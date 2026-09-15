import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/result/view/result_data.dart';
import 'package:riftwarden/features/result/widgets/result_ad_button.dart';
import 'package:riftwarden/features/result/widgets/result_reward_row.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';
import 'package:riftwarden/shared/widgets/rw_progress_bar.dart';

/// Seviye sonu ekrani (zafer ve yenilgi durumlari).
///
/// Yatay duzende iki sutunlu yapi:
/// - Sol yarim: zafer/yenilgi basligi, seviye etiketi ve odul paneli / dalga ilerlemesi.
/// - Sag yarim: dikey siralanmis reklam butonu (varsa), primary buton ve ana menu butonu.
///
/// Hiz odakli tasarim: oyuncuyu gereksiz bekletmez. Zaferde kazanilan
/// kaynaklari kisa bir sayacla gosterir (dokunarak aninda atlanabilir),
/// yenilgide ise tek baskin butonla derhal yeniden deneme imkani tanir.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.data,
    required this.onPrimary,
    required this.onWatchAd,
    required this.onMainMenu,
    super.key,
  });

  /// Savas sonucu verisi.
  final BattleResultData data;

  /// Birincil eylem: Zaferde DEVAM, yenilgide TEKRAR DENE.
  final VoidCallback onPrimary;

  /// Reklam izleme eylemi (odulu katla veya canlan).
  final VoidCallback onWatchAd;

  /// Ana menuye donus eylemi.
  final VoidCallback onMainMenu;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countController;
  late final Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    // Odul artis sayaci 700 ms ile sinirlidir; 1 saniyeyi asla gecmez.
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );

    if (widget.data.kind == BattleResultKind.victory) {
      _countController.forward();
    } else {
      _countController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  /// Ekrana dokunuldugunda sayac animasyonunu hemen tamamlar.
  void _skipAnimation() {
    if (_countController.isAnimating) {
      _countController.stop();
      _countController.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isVictory = widget.data.kind == BattleResultKind.victory;

    final primaryActionLabel =
        isVictory ? l10n.resultNextLevel : l10n.resultRetry;
    final adActionLabel =
        isVictory ? l10n.resultDoubleReward : l10n.resultWatchAdContinue;

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final notchStart = isRtl ? viewPadding.right : viewPadding.left;
    final notchEnd = isRtl ? viewPadding.left : viewPadding.right;

    return Scaffold(
      backgroundColor: AppColors.voidDeep,
      body: GestureDetector(
        onTap: _skipAnimation,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            left: false,
            right: false,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.screenGutter + notchStart,
                end: AppSpacing.screenGutter + notchEnd,
                top: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  // Sol yarim: zafer veya yenilgi basligi, level etiketi,
                  // (yenilgide) dalga ilerlemesi, (zaferde) odul paneli.
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _buildHeaderIcon(isVictory),
                            const SizedBox(height: AppSpacing.xs),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _buildTitle(l10n, isVictory),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _buildLevelSubtitle(l10n),
                            const SizedBox(height: AppSpacing.md),
                            if (isVictory)
                              _buildVictoryRewardsPanel(l10n)
                            else
                              _buildDefeatProgressPanel(l10n),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Sag yarim: aksiyon butonlari dikey sirada:
                  // varsa reklam butonu, primary buton (DEVAM / TEKRAR DENE), ana menu.
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Reklam butonu yalnizca hak varsa cizilir; pasif buton birakilmaz.
                            if (widget.data.canWatchAd) ...<Widget>[
                              ResultAdButton(
                                label: adActionLabel,
                                onPressed: widget.onWatchAd,
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            RwButton(
                              label: primaryActionLabel,
                              variant: RwButtonVariant.primary,
                              isExpanded: true,
                              onPressed: widget.onPrimary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            RwButton(
                              label: l10n.resultMainMenu,
                              variant: RwButtonVariant.ghost,
                              isExpanded: true,
                              onPressed: widget.onMainMenu,
                            ),
                          ],
                        ),
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
  }

  Widget _buildHeaderIcon(bool isVictory) {
    final color = isVictory ? AppColors.aetherCyan : AppColors.danger;
    final icon = isVictory
        ? Icons.auto_awesome_rounded
        : Icons.shield_outlined;

    return Center(
      child: Container(
        width: AppSpacing.xxxl,
        height: AppSpacing.xxxl,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: AppShadows.glow(color, blurRadius: 16.0),
        ),
        alignment: AlignmentDirectional.center,
        child: Icon(
          icon,
          color: color,
          size: 24.0,
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n, bool isVictory) {
    final color = isVictory ? AppColors.aetherCyan : AppColors.danger;
    final titleText =
        isVictory ? l10n.resultVictoryTitle : l10n.resultDefeatTitle;

    return Text(
      titleText,
      textAlign: TextAlign.center,
      style: AppTypography.displayMedium.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
        shadows: AppShadows.glow(color, blurRadius: 20.0),
      ),
    );
  }

  Widget _buildLevelSubtitle(AppLocalizations l10n) {
    return Text(
      l10n.levelLabel(widget.data.levelNumber),
      textAlign: TextAlign.center,
      style: AppTypography.label.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.8,
      ),
    );
  }

  Widget _buildVictoryRewardsPanel(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (BuildContext context, Widget? child) {
        final currentShards =
            (_countAnimation.value * widget.data.shardsEarned).round();
        final currentCells =
            (_countAnimation.value * widget.data.cellsEarned).round();

        return RwPanel(
          title: l10n.resultRewardsTitle,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ResultRewardRow(
                currency: RwCurrency.shard,
                label: l10n.resultRewardShards,
                amount: currentShards,
              ),
              // Ilk gecis bonusu olan Cell yalnizca kazanildiysa gosterilir.
              if (widget.data.cellsEarned > 0) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                const Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: AppColors.surfaceRaised,
                ),
                const SizedBox(height: AppSpacing.xs),
                ResultRewardRow(
                  currency: RwCurrency.cell,
                  label: l10n.resultRewardCells,
                  amount: currentCells,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefeatProgressPanel(AppLocalizations l10n) {
    final progress = widget.data.totalWaves > 0
        ? (widget.data.wavesCleared / widget.data.totalWaves).clamp(0.0, 1.0)
        : 0.0;

    return RwPanel(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Icon(
                Icons.flag_rounded,
                size: 16.0,
                color: AppColors.riftViolet,
              ),
              Text(
                l10n.hudWave(
                  widget.data.wavesCleared,
                  widget.data.totalWaves,
                ),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RwProgressBar(
            value: progress,
            color: AppColors.riftViolet,
            backgroundColor: AppColors.surfaceRaised,
          ),
        ],
      ),
    );
  }
}
