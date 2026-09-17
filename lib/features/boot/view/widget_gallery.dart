// GECICI: gorsel kontrol galerisi. Ekranlar tamamlaninca silinecek (M5).

import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/features/battle/widgets/upgrade_choice_overlay.dart';
import 'package:riftwarden/shared/widgets/rw_ability_frame.dart';
import 'package:riftwarden/shared/widgets/rw_art.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_card.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_defender_slot.dart';
import 'package:riftwarden/shared/widgets/rw_dialog.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';
import 'package:riftwarden/shared/widgets/rw_progress_bar.dart';
import 'package:riftwarden/shared/widgets/rw_screen_scaffold.dart';
import 'package:riftwarden/shared/widgets/rw_section_header.dart';
import 'package:riftwarden/shared/widgets/rw_segmented_progress.dart';
import 'package:riftwarden/shared/widgets/rw_toggle.dart';
import 'package:riftwarden/shared/widgets/rw_veil.dart';

/// Galeri icin ornek upgrade konfigurasyonu. Icerik registry'sine
/// bagimli olmamak icin alanlar elle doldurulur (bkz. brief BATTLE-01).
UpgradeConfig _sampleUpgrade({
  required String id,
  required String family,
  required UpgradeRarity rarity,
}) {
  return UpgradeConfig(
    id: id,
    name: id,
    description: id,
    icon: 'placeholder',
    family: family,
    rarity: rarity,
    requires: const <String>[],
    maxStacks: 1,
    weight: 1.0,
    stats: const <StatModifier>[],
    flags: const <String>[],
    source: UpgradeSource.card,
    cost: null,
    unit: null,
  );
}

/// Tasarim sistemi bilesenlerini gorsel olarak test etmek icin galeri ekrani.
class WidgetGallery extends StatefulWidget {
  const WidgetGallery({super.key});

  @override
  State<WidgetGallery> createState() => _WidgetGalleryState();
}

class _WidgetGalleryState extends State<WidgetGallery> {
  double _animatedHp = 0.85;
  bool _abilityReady = false;
  bool _toggleInteractive = true;

  // UpgradeChoiceOverlay galeri ornegi: id'ler upgrade_text.dart'taki
  // eslemeyle ayni ki basliklar l10n uzerinden dogru gorunsun.
  static final Map<String, UpgradeConfig> _sampleUpgrades = <String, UpgradeConfig>{
    'arc_chain_1': _sampleUpgrade(
      id: 'arc_chain_1',
      family: 'chain',
      rarity: UpgradeRarity.common,
    ),
    'pulse_pierce_1': _sampleUpgrade(
      id: 'pulse_pierce_1',
      family: 'pierce',
      rarity: UpgradeRarity.rare,
    ),
    'arc_crit_1': _sampleUpgrade(
      id: 'arc_crit_1',
      family: 'crit',
      rarity: UpgradeRarity.epic,
    ),
    'aether_economy_1': _sampleUpgrade(
      id: 'aether_economy_1',
      family: 'economy',
      rarity: UpgradeRarity.legendary,
    ),
  };

  final ValueNotifier<UpgradeOffer?> _demoOfferThree =
      ValueNotifier<UpgradeOffer?>(
    const UpgradeOffer(
      upgradeIds: <String>['arc_chain_1', 'pulse_pierce_1', 'arc_crit_1'],
      rerollsLeft: 1,
    ),
  );

  final ValueNotifier<UpgradeOffer?> _demoOfferOne =
      ValueNotifier<UpgradeOffer?>(
    const UpgradeOffer(
      upgradeIds: <String>['aether_economy_1'],
      rerollsLeft: 0,
    ),
  );

  @override
  void dispose() {
    _demoOfferThree.dispose();
    _demoOfferOne.dispose();
    super.dispose();
  }

  void _toggleAbilityReady() {
    setState(() {
      _abilityReady = !_abilityReady;
    });
  }

  void _damageTest() {
    setState(() {
      _animatedHp = _animatedHp <= 0.3 ? 0.95 : _animatedHp - 0.25;
    });
  }

  Widget _buildGalleryText(
    String text, {
    TextStyle? style,
    TextAlign? align,
  }) {
    return Text(
      text,
      style: style ?? AppTypography.bodyMedium,
      textAlign: align,
    );
  }

  Widget _materialSurfaceDemo(
    AppMaterial material,
    String label, {
    RwSurfaceDepth depth = RwSurfaceDepth.raised,
    bool isSelected = false,
    bool isDisabled = false,
    int seed = 0,
  }) {
    return RwMaterialSurface(
      material: material,
      depth: depth,
      isSelected: isSelected,
      isDisabled: isDisabled,
      seed: seed,
      child: SizedBox(
        width: 120.0,
        height: 56.0,
        child: Center(
          child: Text(
            label,
            style: AppTypography.onMaterial(AppTypography.smallLabel, material),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RwScreenScaffold(
      title: 'GALLERY',
      onBack: () => Navigator.of(context).pop(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsetsDirectional.only(
          bottom: AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- SECTION: SECTION HEADER (onDark) ---
            const RwSectionHeader(
              title: 'Section Header (RwSectionHeader)',
              subtitle: 'onDark: true ornegi bir HUD panelde',
            ),
            const SizedBox(height: AppSpacing.sm),
            const SizedBox(
              width: 260.0,
              child: RwPanel(
                material: AppMaterial.hud,
                child: RwSectionHeader(
                  title: 'HUD ICINDE BASLIK',
                  subtitle: 'Koyu zeminde okunur kalir',
                  onDark: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: BUTTONS ---
            const RwSectionHeader(
              title: 'Buttons (RwButton)',
              subtitle: '4 varyant x (normal/pasif/secili), uzun etiket ve simge',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                for (final RwButtonVariant variant in RwButtonVariant.values) ...<Widget>[
                  RwButton(
                    label: '${variant.name} Action',
                    variant: variant,
                    onPressed: () {},
                  ),
                  RwButton(
                    label: '${variant.name} Disabled',
                    variant: variant,
                    onPressed: null,
                  ),
                  RwButton(
                    label: '${variant.name} Selected',
                    variant: variant,
                    isSelected: true,
                    onPressed: () {},
                  ),
                ],
                RwButton(
                  label: 'With Icon Action',
                  icon: Icons.bolt_rounded,
                  variant: RwButtonVariant.primary,
                  onPressed: () {},
                ),
                RwButton(
                  label: 'A Very Long Button Label That Should Not Wrap Oddly',
                  variant: RwButtonVariant.secondary,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: ICON BUTTONS ---
            const RwSectionHeader(
              title: 'Icon Buttons (RwIconButton)',
              subtitle:
                  'stone/wood/hud x (normal/pasif/secili/aktif), semantik ikon ve RTL',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                for (final AppMaterial material in <AppMaterial>[
                  AppMaterial.stone,
                  AppMaterial.wood,
                  AppMaterial.hud,
                ]) ...<Widget>[
                  RwIconButton(
                    icon: Icons.pause_rounded,
                    tooltip: '${material.name} normal',
                    material: material,
                    onPressed: () {},
                  ),
                  RwIconButton(
                    icon: Icons.pause_rounded,
                    tooltip: '${material.name} disabled',
                    material: material,
                    onPressed: null,
                  ),
                  RwIconButton(
                    icon: Icons.pause_rounded,
                    tooltip: '${material.name} selected',
                    material: material,
                    isSelected: true,
                    onPressed: () {},
                  ),
                  RwIconButton(
                    icon: Icons.pause_rounded,
                    tooltip: '${material.name} active',
                    material: material,
                    isActive: true,
                    onPressed: () {},
                  ),
                ],
                RwIconButton(
                  rwIcon: RwIconId.settings,
                  tooltip: 'rwIcon settings',
                  onPressed: () {},
                ),
                RwIconButton(
                  rwIcon: RwIconId.back,
                  tooltip: 'rwIcon back (RTL aynalanir)',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: MATERIAL SURFACES ---
            const RwSectionHeader(
              title: 'Material Surfaces (RwMaterialSurface)',
              subtitle: '4 malzeme x 5 durum, pill/circle ve RTL ornegi',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                for (final AppMaterial material in AppMaterial.values) ...<Widget>[
                  _materialSurfaceDemo(
                    material,
                    '${material.name}\nflat',
                    depth: RwSurfaceDepth.flat,
                    seed: 1,
                  ),
                  _materialSurfaceDemo(
                    material,
                    '${material.name}\nraised',
                    seed: 2,
                  ),
                  _materialSurfaceDemo(
                    material,
                    '${material.name}\npressed',
                    depth: RwSurfaceDepth.pressed,
                    seed: 3,
                  ),
                  _materialSurfaceDemo(
                    material,
                    '${material.name}\nselected',
                    isSelected: true,
                    seed: 4,
                  ),
                  _materialSurfaceDemo(
                    material,
                    '${material.name}\ndisabled',
                    isDisabled: true,
                    seed: 5,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                RwMaterialSurface(
                  material: AppMaterial.hud,
                  shape: RwSurfaceShape.pill,
                  seed: 6,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    '12 / 20',
                    style: AppTypography.onMaterial(
                      AppTypography.numeric,
                      AppMaterial.hud,
                    ),
                  ),
                ),
                const RwMaterialSurface(
                  material: AppMaterial.stone,
                  shape: RwSurfaceShape.circle,
                  seed: 7,
                  child: SizedBox(width: 40.0, height: 40.0),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('RTL ornegi (asimetrik detaylar aynalanir):'),
            const SizedBox(height: AppSpacing.xs),
            Directionality(
              textDirection: TextDirection.rtl,
              child: _materialSurfaceDemo(AppMaterial.wood, 'RTL', seed: 8),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: SEMANTIC ICONS ---
            const RwSectionHeader(
              title: 'Icons (RwIcon)',
              subtitle: '19 semantik id, 24/48 dp ve RTL back ornegi',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              children: RwIconId.values
                  .map(
                    (id) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RwIcon(id, size: 24.0),
                        const SizedBox(height: AppSpacing.xs),
                        RwIcon(id, size: 48.0),
                        const SizedBox(height: AppSpacing.xs),
                        _buildGalleryText(
                          id.name,
                          style: AppTypography.smallLabel,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('RTL back ornegi (yon aynalanir):'),
            const SizedBox(height: AppSpacing.xs),
            const Directionality(
              textDirection: TextDirection.rtl,
              child: RwIcon(RwIconId.back, size: 32.0),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: RASTER ART SLOTS ---
            const RwSectionHeader(
              title: 'Art Slots (RwArt)',
              subtitle: 'Dosya henuz yok; her grup fallback gosteriyor',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              children: RwArtGroup.values
                  .map(
                    (group) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RwArt(
                          group: group,
                          id: 'gallery_preview',
                          width: 64.0,
                          height: 64.0,
                          fallback: Container(
                            width: 64.0,
                            height: 64.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textOnDark),
                            ),
                            child: _buildGalleryText(
                              'fallback',
                              style: AppTypography.smallLabel,
                              align: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildGalleryText(
                          group.name,
                          style: AppTypography.smallLabel,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: CURRENCY CHIPS ---
            const RwSectionHeader(
              title: 'Currencies (RwCurrencyChip)',
              subtitle: 'Aether, Shard ve Cell gostergeleri',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                const RwCurrencyChip(
                  currency: RwCurrency.aether,
                  amount: 1450,
                ),
                const RwCurrencyChip(
                  currency: RwCurrency.shard,
                  amount: 85,
                ),
                const RwCurrencyChip(
                  currency: RwCurrency.cell,
                  amount: 12,
                ),
                const RwCurrencyChip(
                  currency: RwCurrency.aether,
                  amount: 340,
                  material: AppMaterial.parchment,
                ),
                const RwCurrencyChip(
                  currency: RwCurrency.shard,
                  amount: 1234567,
                ),
                const RwCurrencyChip(
                  currency: RwCurrency.shard,
                  amount: 1234567,
                  compact: true,
                ),
                RwCurrencyChip(
                  currency: RwCurrency.cell,
                  amount: 12,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: PROGRESS BARS ---
            const RwSectionHeader(
              title: 'Progress Bars (RwProgressBar)',
              subtitle: 'El yapimi iz, health/cooldown varyantlari ve hasar izi',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildGalleryText('Neutral, hud track (%50)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 0.5,
              color: AppColors.aetherCyan,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Neutral, parchment track (%50)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 0.5,
              color: AppColors.riftViolet,
              trackMaterial: AppMaterial.parchment,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Health, hud track (%80)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 0.8,
              color: AppColors.health,
              variant: RwProgressVariant.health,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Health, parchment track (%20 - danger otomatik)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 0.2,
              color: AppColors.health,
              variant: RwProgressVariant.health,
              trackMaterial: AppMaterial.parchment,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Cooldown, hud track (%50 - sakin doygunluk)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 0.5,
              color: AppColors.rift,
              variant: RwProgressVariant.cooldown,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Kompakt can barı (4 dp, Core HP olcegi)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 0.8,
              color: AppColors.health,
              variant: RwProgressVariant.health,
              height: 4.0,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Damage Trail Test (Tiklayarak dene)'),
            const SizedBox(height: AppSpacing.xs),
            RwProgressBar(
              value: _animatedHp,
              color: AppColors.health,
              variant: RwProgressVariant.health,
              showDamageTrail: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            RwButton(
              label: 'Simulate Damage',
              variant: RwButtonVariant.secondary,
              onPressed: _damageTest,
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: SEGMENTED PROGRESS ---
            const RwSectionHeader(
              title: 'Segmented Progress (RwSegmentedProgress)',
              subtitle: 'Dalga/asama gostergesi, esit parcalar',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildGalleryText('5 segment, %50 ilerleme, mevcut segment 2'),
            const SizedBox(height: AppSpacing.xs),
            const RwSegmentedProgress(
              segments: 5,
              value: 0.5,
              currentSegment: 2,
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: PANELS ---
            const RwSectionHeader(
              title: 'Panels (RwPanel)',
              subtitle: '4 varyant x parchment, hud/wood ornekleri ve tiklanabilir panel',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                SizedBox(
                  width: 220.0,
                  child: RwPanel(
                    title: 'STANDARD PANEL',
                    trailing: const Icon(
                      Icons.radar_rounded,
                      size: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildGalleryText(
                          'Panel iceriginde bilesenler ve istatistikler yer alabilir.',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const RwProgressBar(
                          value: 0.75,
                          color: AppColors.riftViolet,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 220.0,
                  child: RwPanel(
                    variant: RwPanelVariant.large,
                    title: 'LARGE PANEL',
                    child: _buildGalleryText(
                      'Ekran seviyesi icerik bolgesi, daha genis dolgu.',
                    ),
                  ),
                ),
                SizedBox(
                  width: 220.0,
                  child: RwPanel(
                    variant: RwPanelVariant.modal,
                    title: 'MODAL PANEL',
                    child: _buildGalleryText(
                      'Belirgin baslik ayirici cizgisi ile en guclu derinlik.',
                    ),
                  ),
                ),
                SizedBox(
                  width: 220.0,
                  child: RwPanel(
                    variant: RwPanelVariant.smallInfo,
                    title: 'SMALL INFO',
                    child: _buildGalleryText('Kompakt ipucu/etiket plaketi.'),
                  ),
                ),
                SizedBox(
                  width: 220.0,
                  child: RwPanel(
                    material: AppMaterial.hud,
                    title: 'HUD PANEL',
                    child: _buildGalleryText(
                      'Savas sanati uzerinde kontrast koruyan koyu-notr yuzey.',
                    ),
                  ),
                ),
                SizedBox(
                  width: 220.0,
                  child: RwPanel(
                    material: AppMaterial.wood,
                    title: 'WOOD PANEL',
                    child: _buildGalleryText(
                      'Yapisal/navigasyon vurgulu tahta cerceve.',
                    ),
                  ),
                ),
                SizedBox(
                  width: 220.0,
                  child: RwPanel(
                    title: 'TIKLANABILIR PANEL',
                    onTap: () {},
                    child: _buildGalleryText(
                      'onTap ile basili derinlik geri bildirimi verir.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: CARDS ---
            const RwSectionHeader(
              title: 'Cards (RwCard)',
              subtitle: 'Anatomi + durumlar (DESIGN §9, §13)',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildGalleryText(
              'Upgrade choice satiri — 640x360 genislikte tek satirda sigar.',
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: RwCard(
                    kind: RwCardKind.upgrade,
                    title: 'Plasma Overcharge',
                    rarity: 'common',
                    badge: 'LVL 1',
                    description: 'Attacks pierce through 1 additional enemy.',
                    icon: const RwIcon(RwIconId.attack, size: 32.0),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RwCard(
                    kind: RwCardKind.upgrade,
                    title: 'Aether Siphon',
                    rarity: 'rare',
                    badge: 'LVL 2',
                    description:
                        'Defeated swarm units yield 25% more Aether.',
                    icon: const RwIcon(RwIconId.aether, size: 32.0),
                    isSelected: true,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RwCard(
                    kind: RwCardKind.upgrade,
                    title: 'Dimensional Surge',
                    rarity: 'epic',
                    badge: 'LVL 3',
                    description:
                        'Discharge an electric nova every 12 seconds.',
                    icon: const RwIcon(RwIconId.magic, size: 32.0),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Standard / locked / disabled / defender'),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 180.0,
                    child: RwCard(
                      title: 'Rift Shard',
                      rarity: 'common',
                      description: 'Genel amacli secim karti ornegi.',
                      icon: const RwIcon(RwIconId.shard, size: 28.0),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const SizedBox(
                    width: 180.0,
                    child: RwCard(
                      title: 'Titan Frame',
                      rarity: 'epic',
                      state: RwCardState.locked,
                      lockReason: 'Level 8 gerekir',
                      icon: RwIcon(RwIconId.utility, size: 28.0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const SizedBox(
                    width: 180.0,
                    child: RwCard(
                      title: 'Void Singularity',
                      rarity: 'legendary',
                      state: RwCardState.disabled,
                      description: 'Yetersiz kaynak.',
                      icon: RwIcon(RwIconId.rift, size: 28.0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 160.0,
                    child: RwCard(
                      kind: RwCardKind.defender,
                      title: 'Arc Ranger',
                      rarity: 'rare',
                      description: 'Uzun menzilli destek',
                      art: const ColoredBox(
                        color: AppColors.woodFace,
                        child: Center(
                          child: RwIcon(RwIconId.attack, size: 36.0),
                        ),
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: DEFENDER SLOTS ---
            const RwSectionHeader(
              title: 'Defender Slots (RwDefenderSlot)',
              subtitle: '7 durum (DESIGN §11), size 64; ayrica size 48 ornegi',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: <Widget>[
                RwDefenderSlot(
                  state: RwDefenderSlotState.empty,
                  onTap: () {},
                ),
                RwDefenderSlot(
                  state: RwDefenderSlotState.available,
                  unitId: 'pulse_guard',
                  name: 'Pulse Guard',
                  onTap: () {},
                ),
                RwDefenderSlot(
                  state: RwDefenderSlotState.selected,
                  unitId: 'arc_ranger',
                  name: 'Arc Ranger',
                  onTap: () {},
                ),
                const RwDefenderSlot(
                  state: RwDefenderSlotState.locked,
                  name: 'Titan Frame',
                ),
                RwDefenderSlot(
                  state: RwDefenderSlotState.purchaseable,
                  unitId: 'pulse_guard',
                  name: 'Pulse Guard',
                  cost: 25,
                  onTap: () {},
                ),
                const RwDefenderSlot(
                  state: RwDefenderSlotState.unaffordable,
                  unitId: 'titan_frame',
                  name: 'Titan Frame',
                  cost: 90,
                  onTap: null,
                ),
                RwDefenderSlot(
                  state: RwDefenderSlotState.occupied,
                  unitId: 'arc_ranger',
                  name: 'Arc Ranger',
                  count: 3,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText(
              'size: 48, unitId olmayan bir asset (fallback yolu):',
            ),
            const SizedBox(height: AppSpacing.xs),
            RwDefenderSlot(
              state: RwDefenderSlotState.purchaseable,
              unitId: 'unknown_scout_unit',
              name: 'Void Scout',
              cost: 60,
              size: 48.0,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: ABILITY FRAME ---
            const RwSectionHeader(
              title: 'Ability Frame (RwAbilityFrame)',
              subtitle: '4 durum (DESIGN §12), cooldown %30/%75 ve toggle ile pulse',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: <Widget>[
                RwAbilityFrame(
                  state: RwAbilityState.ready,
                  semanticLabel: 'Rift Collapse hazir',
                  onTap: () {},
                ),
                const RwAbilityFrame(
                  state: RwAbilityState.cooldown,
                  cooldownProgress: 0.75,
                  remainingSeconds: 7.9,
                  semanticLabel: 'Rift Collapse beklemede',
                ),
                const RwAbilityFrame(
                  state: RwAbilityState.cooldown,
                  cooldownProgress: 0.30,
                  remainingSeconds: 2.4,
                  semanticLabel: 'Rift Collapse beklemede',
                ),
                RwAbilityFrame(
                  state: RwAbilityState.targeting,
                  semanticLabel: 'Rift Collapse hedefleniyor',
                  onTap: () {},
                ),
                const RwAbilityFrame(
                  state: RwAbilityState.unavailable,
                  semanticLabel: 'Rift Collapse kullanilamaz',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Pulse tetikleyici (cooldown -> ready gecisi):'),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RwAbilityFrame(
                  state: _abilityReady
                      ? RwAbilityState.ready
                      : RwAbilityState.cooldown,
                  cooldownProgress: 0.5,
                  remainingSeconds: 4.0,
                  semanticLabel: 'Rift Collapse toggle ornegi',
                  onTap: () {},
                ),
                const SizedBox(width: AppSpacing.md),
                RwButton(
                  label: _abilityReady ? 'Set Cooldown' : 'Set Ready',
                  variant: RwButtonVariant.secondary,
                  onPressed: _toggleAbilityReady,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: TOGGLE ---
            const RwSectionHeader(
              title: 'Toggle (RwToggle)',
              subtitle: 'Etkilesimli ornek, sabit acik/kapali, pasif ve hud malzeme',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RwToggle(
                      value: _toggleInteractive,
                      onChanged: (value) =>
                          setState(() => _toggleInteractive = value),
                      semanticLabel: 'Etkilesimli ornek',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildGalleryText('interactive', style: AppTypography.smallLabel),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RwToggle(
                      value: true,
                      onChanged: (_) {},
                      semanticLabel: 'Sabit acik',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildGalleryText('acik', style: AppTypography.smallLabel),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RwToggle(
                      value: false,
                      onChanged: (_) {},
                      semanticLabel: 'Sabit kapali',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildGalleryText('kapali', style: AppTypography.smallLabel),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const RwToggle(
                      value: true,
                      onChanged: null,
                      semanticLabel: 'Pasif acik',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildGalleryText('disabled acik', style: AppTypography.smallLabel),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const RwToggle(
                      value: false,
                      onChanged: null,
                      semanticLabel: 'Pasif kapali',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildGalleryText('disabled kapali', style: AppTypography.smallLabel),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RwToggle(
                      value: true,
                      onChanged: (_) {},
                      material: AppMaterial.hud,
                      semanticLabel: 'Hud malzeme',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildGalleryText('hud', style: AppTypography.smallLabel),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: DIALOG TRIGGER ---
            const RwSectionHeader(
              title: 'Dialogs (RwDialog)',
              subtitle: 'Onay, hata ve satin alma iletisim pencereleri',
            ),
            const SizedBox(height: AppSpacing.sm),
            RwButton(
              label: 'Open Sample Dialog',
              variant: RwButtonVariant.primary,
              onPressed: () {
                RwDialog.show<void>(
                  context: context,
                  title: 'PURCHASE UPGRADE',
                  message:
                      'Do you wish to spend 500 Aether to reinforce Core defenses?',
                  primaryActionLabel: 'Confirm',
                  primaryActionOnPressed: () => Navigator.of(context).pop(),
                  secondaryActionLabel: 'Cancel',
                  secondaryActionOnPressed: () => Navigator.of(context).pop(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            RwButton(
              label: 'Open Long Text Dialog',
              variant: RwButtonVariant.secondary,
              onPressed: () {
                RwDialog.show<void>(
                  context: context,
                  title:
                      'A VERY LONG DIALOG TITLE THAT MAY WRAP ACROSS MULTIPLE LINES ON NARROW SCREENS',
                  message:
                      'This is a deliberately long body message meant to exercise the '
                      'scrollable modal body at the 640x360 landscape baseline. It '
                      'should never overflow the render tree, and the action row '
                      'should wrap to a new line when the localized labels are long '
                      'enough to no longer fit side by side within the panel width. '
                      'Rift energy destabilizes the fortress perimeter, and reserves '
                      'must be committed carefully before the next wave arrives.',
                  primaryActionLabel: 'Acknowledge And Proceed',
                  primaryActionOnPressed: () => Navigator.of(context).pop(),
                  secondaryActionLabel: 'Cancel For Now',
                  secondaryActionOnPressed: () => Navigator.of(context).pop(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: VEIL (RwVeil) ---
            const RwSectionHeader(
              title: 'Veil (RwVeil)',
              subtitle: 'Sahne ustu karartma + doygunluk dusurme katmani',
            ),
            const SizedBox(height: AppSpacing.sm),
            const SizedBox(
              width: 220.0,
              height: 120.0,
              child: ClipRRect(
                borderRadius: AppBorderRadii.md,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: ColoredBox(color: AppColors.aether)),
                        Expanded(child: ColoredBox(color: AppColors.riftViolet)),
                        Expanded(child: ColoredBox(color: AppColors.cta)),
                      ],
                    ),
                    RwVeil(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: UPGRADE CHOICE OVERLAY ---
            const RwSectionHeader(
              title: 'Upgrade Choice Overlay (UpgradeChoiceOverlay)',
              subtitle: 'Esik karti secim katmani (DESIGN §13), 3 kart ve 1 kart',
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: 592.0,
              height: 260.0,
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const ColoredBox(color: AppColors.voidDeep),
                    UpgradeChoiceOverlay(
                      offer: _demoOfferThree,
                      upgrades: _sampleUpgrades,
                      onChoose: (_) {},
                      onReroll: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: 592.0,
              height: 260.0,
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const ColoredBox(color: AppColors.voidDeep),
                    UpgradeChoiceOverlay(
                      offer: _demoOfferOne,
                      upgrades: _sampleUpgrades,
                      onChoose: (_) {},
                      onReroll: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
