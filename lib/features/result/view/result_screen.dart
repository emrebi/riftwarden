import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/features/result/view/result_data.dart';
import 'package:riftwarden/features/result/widgets/result_ad_button.dart';
import 'package:riftwarden/features/result/widgets/result_reward_row.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_art.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';
import 'package:riftwarden/shared/widgets/rw_progress_bar.dart';

/// Seviye sonu ekrani (zafer ve yenilgi durumlari).
///
/// Yatay duzende iki sutunlu yapi:
/// - Sol yarim: zafer/yenilgi basligi (malzeme yuzeyi ustunde), seviye
///   etiketi ve odul paneli / dalga ilerlemesi.
/// - Sag yarim: dikey siralanmis reklam butonu (varsa), primary buton ve
///   ana menu butonu.
///
/// Hiz odakli tasarim: oyuncuyu gereksiz bekletmez. Zaferde kazanilan
/// kaynaklari kisa bir sayacla gosterir (dokunarak aninda atlanabilir),
/// yenilgide ise tek baskin butonla derhal yeniden deneme imkani tanir.
/// Birincil eylem giris animasyonuyla ASLA engellenmez (DESIGN §20
/// "Victory/defeat ... primary action remains immediately available").
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
  /// Sonuc rozeti sanat/ikon alani karesi.
  static const double _badgeSize = 72.0;
  static const double _badgeIconSize = 36.0;

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
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: _skipAnimation,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Zemin rengi SafeArea disinda tam ekrana yayilir; savas
            // sonucuna gore ileride RwArt(group: scenes, ...) buraya eklenir.
            const ColoredBox(color: AppColors.background),
            SafeArea(
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
                              _buildOutcomeBanner(l10n, isVictory),
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
                    // varsa reklam butonu, primary buton (DEVAM / TEKRAR
                    // DENE), ana menu.
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              // Reklam butonu yalnizca hak varsa cizilir;
                              // pasif buton birakilmaz.
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
          ],
        ),
      ),
    );
  }

  /// Rozet alani: onceligi ART-13 sanat varligindadir; dosya gelene kadar
  /// zafer/yenilgiyi hem renk hem sekil/ikonla ayiran kod tabanli rozete
  /// duser (DESIGN §10 "durum sadece renkle anlatilmaz").
  Widget _buildOutcomeBadge(bool isVictory) {
    final material = isVictory ? AppMaterial.wood : AppMaterial.stone;
    final faceColor = isVictory ? AppColors.cta : AppColors.danger;
    final icon =
        isVictory ? Icons.emoji_events_rounded : Icons.heart_broken_rounded;

    return RwArt(
      group: RwArtGroup.illustrations,
      id: isVictory ? 'result.victory' : 'result.defeat',
      width: _badgeSize,
      height: _badgeSize,
      fallback: SizedBox(
        width: _badgeSize,
        height: _badgeSize,
        child: RwMaterialSurface(
          material: material,
          shape: RwSurfaceShape.circle,
          faceColor: faceColor,
          padding: EdgeInsetsDirectional.zero,
          child: Center(
            child: Icon(
              icon,
              size: _badgeIconSize,
              color: AppColors.textOnDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeBanner(AppLocalizations l10n, bool isVictory) {
    final material = isVictory ? AppMaterial.wood : AppMaterial.stone;
    final titleText =
        isVictory ? l10n.resultVictoryTitle : l10n.resultDefeatTitle;

    return RwPanel(
      material: material,
      variant: RwPanelVariant.large,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildOutcomeBadge(isVictory),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              titleText,
              textAlign: TextAlign.center,
              style: AppTypography.onMaterial(
                AppTypography.displayMedium,
                material,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.levelLabel(widget.data.levelNumber),
            textAlign: TextAlign.center,
            style: AppTypography.onMaterialSecondary(
              AppTypography.smallLabel,
              material,
            ).copyWith(letterSpacing: 1.8),
          ),
        ],
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
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: AppMaterials.edge(AppMaterial.parchment),
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
                style: AppTypography.onMaterial(
                  AppTypography.titleMedium,
                  AppMaterial.parchment,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RwProgressBar(
            value: progress,
            color: AppColors.riftViolet,
            backgroundColor: AppMaterials.edge(AppMaterial.parchment),
          ),
        ],
      ),
    );
  }
}
