import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/features/battle/viewmodel/upgrade_text.dart';
import 'package:riftwarden/l10n/gen/app_localizations.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_card.dart';
import 'package:riftwarden/shared/widgets/rw_veil.dart';

/// Esik karti (upgrade) secim katmani (DESIGN §13).
///
/// Veri-bagimsiz: sadece [offer] sinyalini dinler, secim/reroll komutlarini
/// callback ile disariya iletir. `offer` null oldugunda hicbir sey cizmez.
class UpgradeChoiceOverlay extends StatefulWidget {
  const UpgradeChoiceOverlay({
    required this.offer,
    required this.upgrades,
    required this.onChoose,
    required this.onReroll,
    super.key,
  });

  /// Motordan gelen aktif teklif; null ise katman gorunmez.
  final ValueListenable<UpgradeOffer?> offer;

  /// Teklif id'lerini icerik konfigurasyonuna cozmek icin id -> config haritasi.
  final Map<String, UpgradeConfig> upgrades;

  /// Bir kart secildiginde upgrade id'si ile cagrilir.
  final ValueChanged<String> onChoose;

  /// Reroll butonuna basildiginda cagrilir.
  final VoidCallback onReroll;

  @override
  State<UpgradeChoiceOverlay> createState() => _UpgradeChoiceOverlayState();
}

class _UpgradeChoiceOverlayState extends State<UpgradeChoiceOverlay> {
  /// Kart genisligi: 640 dp genislikte 3 kart + araliklar rahat sigsin diye
  /// tek noktada sabitlenir (DESIGN §13 "fixed card width").
  static const double _cardWidth = 168.0;

  /// Aile ikonu glif olcusu; tek kullanim yeri burasi oldugundan tek
  /// noktada tanimlanir (bkz. `RwButton._iconSize` deseni).
  static const double _familyIconSize = 32.0;

  /// Her yeni teklifte (ilk acilis veya reroll) artan sayac. `build`
  /// icinde deger karsilastirip mutasyon yapmak yerine [_handleOfferChanged]
  /// listener'inda guncellenir — boylece "ayni id'lerle gelen SONRAKI bir
  /// teklif" build zamanlamasina bagli kalmadan da dogru sekilde yeni bir
  /// jenerasyon sayilir ve kilit/acilis animasyonu sifirlanir (bkz.
  /// BATTLE-01 softlock duzeltmesi).
  int _generation = 0;
  bool _choiceLocked = false;

  @override
  void initState() {
    super.initState();
    widget.offer.addListener(_handleOfferChanged);
  }

  @override
  void didUpdateWidget(covariant UpgradeChoiceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer != widget.offer) {
      oldWidget.offer.removeListener(_handleOfferChanged);
      widget.offer.addListener(_handleOfferChanged);
    }
  }

  @override
  void dispose() {
    widget.offer.removeListener(_handleOfferChanged);
    super.dispose();
  }

  /// `offer` gercekten degistiginde (null->teklif veya teklif->farkli
  /// teklif) cagrilir; sadece bu durumda yeni bir jenerasyon baslar.
  void _handleOfferChanged() {
    if (widget.offer.value == null) {
      return;
    }
    _generation++;
    _choiceLocked = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<UpgradeOffer?>(
      valueListenable: widget.offer,
      builder: (BuildContext context, UpgradeOffer? offer, _) {
        if (offer == null) {
          return const SizedBox.shrink();
        }

        final configs = offer.upgradeIds
            .map((id) => widget.upgrades[id])
            .whereType<UpgradeConfig>()
            .toList(growable: false);

        return RwVeil(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Dar yukseklikli yuzeylerde (640x360, dis padding, buyuk
                // metin olcegi) icerik satir yuksekligini asabilir; tasma
                // yerine kaydirilabilir govdeye duser (DESIGN §13, RwDialog
                // ile ayni desen), sigdiginda ise dikeyde ortalanir.
                return SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - AppSpacing.md * 2,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            l10n.upgradeChooseTitle,
                            style: AppTypography.sectionTitle
                                .copyWith(color: AppColors.textOnDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var i = 0; i < configs.length; i++) ...<Widget>[
                                if (i > 0) const SizedBox(width: AppSpacing.md),
                                _RevealCard(
                                  // Jenerasyon anahtara dahil: ayni id'lerle
                                  // gelen bir SONRAKI teklifte (reroll veya
                                  // yeni esik) widget yeniden olusturulur ve
                                  // acilis animasyonu yeniden baslar.
                                  key: ValueKey<String>(
                                    '$_generation-${configs[i].id}',
                                  ),
                                  index: i,
                                  width: _cardWidth,
                                  iconSize: _familyIconSize,
                                  config: configs[i],
                                  l10n: l10n,
                                  onTap: () => _handleChoose(configs[i].id),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          RwButton(
                            label: offer.rerollsLeft > 0
                                ? '${l10n.upgradeReroll} '
                                    '(${l10n.upgradeRerollsLeft(offer.rerollsLeft)})'
                                : l10n.upgradeReroll,
                            variant: RwButtonVariant.secondary,
                            onPressed:
                                offer.rerollsLeft > 0 ? widget.onReroll : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleChoose(String id) {
    // Motor `chooseUpgrade` sonrasi `offer`i null yapar, ama o guncelleme
    // bu build ile ayni frame'de gelmeyebilir; ikinci dokunuslari burada
    // sessizce yok sayariz.
    if (_choiceLocked) {
      return;
    }
    _choiceLocked = true;
    widget.onChoose(id);
  }
}

/// Tek bir aile icin gorsel vurgu ikonu. Sadece bu overlaye ozel bir
/// esleme oldugu icin `RwIconId`e degil dogrudan `IconData`ya baglanir.
IconData _familyIcon(String family) => switch (family) {
      'chain' => Icons.link_rounded,
      'crit' => Icons.bolt_rounded,
      'explosion' => Icons.flare_rounded,
      'pierce' => Icons.arrow_forward_rounded,
      'swarm' => Icons.hive_rounded,
      'core' => Icons.favorite_rounded,
      'economy' => Icons.water_drop_rounded,
      _ => Icons.auto_awesome_rounded,
    };

/// Alttan yukselerek beliren tek bir upgrade karti.
///
/// Kartlar sirayla (index'e gore gecikmeli) belirir ama gecikme sadece
/// GORSELDIR: `IgnorePointer` yoktur, kart animasyon bitmeden de tiklanabilir
/// (DESIGN §13 "interaction not blocked").
class _RevealCard extends StatefulWidget {
  const _RevealCard({
    required this.index,
    required this.width,
    required this.iconSize,
    required this.config,
    required this.l10n,
    required this.onTap,
    super.key,
  });

  final int index;
  final double width;
  final double iconSize;
  final UpgradeConfig config;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  State<_RevealCard> createState() => _RevealCardState();
}

class _RevealCardState extends State<_RevealCard>
    with SingleTickerProviderStateMixin {
  /// Kartlar arasi acilis gecikmesi, controller sureside oran olarak
  /// (`Interval` 0..1 uzayinda). 3. kart bile `start = 2 * 0.15 = 0.3`
  /// ile baslar ve YINE AYNI controller'in 1.0 noktasinda (dolayisiyla
  /// tam olarak `AppDuration.cardReveal` sonunda) tamamlanir — ayri bir
  /// `Future.delayed` (izlenmeyen zamanlayici) kullanilmaz.
  static const double _staggerPerCard = 0.15;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDuration.cardReveal,
    );

    final double start = (widget.index * _staggerPerCard).clamp(0.0, 0.9);
    final Interval interval = Interval(start, 1.0, curve: Curves.easeOut);
    _fade = CurvedAnimation(parent: _controller, curve: interval);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: interval));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final l10n = widget.l10n;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SizedBox(
          width: widget.width,
          child: RwCard(
            kind: RwCardKind.upgrade,
            title: upgradeTitle(l10n, config),
            description: upgradeDescription(l10n, config),
            rarity: config.rarity.name,
            badge: rarityLabel(l10n, config.rarity),
            // Art zone acik parsomen zemin (bkz. RwCard._buildArtZone); ikon
            // koyu murekkep tonunda olmali, aksi halde acik zeminde kaybolur.
            icon: Icon(
              _familyIcon(config.family),
              size: widget.iconSize,
              color: AppColors.outlineInk,
            ),
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
