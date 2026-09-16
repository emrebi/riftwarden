// GECICI: gorsel kontrol galerisi. Ekranlar tamamlaninca silinecek (M5).

import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/app/theme/app_typography.dart';
import 'package:riftwarden/shared/widgets/rw_art.dart';
import 'package:riftwarden/shared/widgets/rw_button.dart';
import 'package:riftwarden/shared/widgets/rw_card.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_dialog.dart';
import 'package:riftwarden/shared/widgets/rw_icon.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';
import 'package:riftwarden/shared/widgets/rw_material_surface.dart';
import 'package:riftwarden/shared/widgets/rw_panel.dart';
import 'package:riftwarden/shared/widgets/rw_progress_bar.dart';
import 'package:riftwarden/shared/widgets/rw_screen_scaffold.dart';
import 'package:riftwarden/shared/widgets/rw_section_header.dart';

/// Tasarim sistemi bilesenlerini gorsel olarak test etmek icin galeri ekrani.
class WidgetGallery extends StatefulWidget {
  const WidgetGallery({super.key});

  @override
  State<WidgetGallery> createState() => _WidgetGalleryState();
}

class _WidgetGalleryState extends State<WidgetGallery> {
  double _animatedHp = 0.85;

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
            // --- SECTION: BUTTONS ---
            const RwSectionHeader(
              title: 'Buttons (RwButton)',
              subtitle: '4 varyant, pasif durum ve simgeli kullanim',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                RwButton(
                  label: 'Primary Action',
                  variant: RwButtonVariant.primary,
                  onPressed: () {},
                ),
                RwButton(
                  label: 'Secondary Action',
                  variant: RwButtonVariant.secondary,
                  onPressed: () {},
                ),
                RwButton(
                  label: 'Ghost Action',
                  variant: RwButtonVariant.ghost,
                  onPressed: () {},
                ),
                RwButton(
                  label: 'Danger Action',
                  variant: RwButtonVariant.danger,
                  onPressed: () {},
                ),
                const RwButton(
                  label: 'Disabled Action',
                  variant: RwButtonVariant.primary,
                  onPressed: null,
                ),
                RwButton(
                  label: 'With Icon',
                  icon: Icons.bolt_rounded,
                  variant: RwButtonVariant.primary,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: ICON BUTTONS ---
            const RwSectionHeader(
              title: 'Icon Buttons (RwIconButton)',
              subtitle: 'Pause, ayarlar, kapatma ve pasif durumu',
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                RwIconButton(
                  icon: Icons.pause_rounded,
                  tooltip: 'Pause',
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.md),
                RwIconButton(
                  icon: Icons.settings_rounded,
                  tooltip: 'Settings',
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.md),
                RwIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Close',
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.md),
                const RwIconButton(
                  icon: Icons.lock_rounded,
                  tooltip: 'Locked',
                  onPressed: null,
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
            const Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                RwCurrencyChip(
                  currency: RwCurrency.aether,
                  amount: 1450,
                ),
                RwCurrencyChip(
                  currency: RwCurrency.shard,
                  amount: 85,
                ),
                RwCurrencyChip(
                  currency: RwCurrency.cell,
                  amount: 12,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: PROGRESS BARS ---
            const RwSectionHeader(
              title: 'Progress Bars (RwProgressBar)',
              subtitle: 'Can, dalga ve hasar izi animasyonlari',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildGalleryText('Core HP (Full - 100%)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 1.0,
              color: AppColors.coreTeal,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Wave Progress (Half - 50%)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 0.5,
              color: AppColors.aetherCyan,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Boss HP (Low Danger - 20%)'),
            const SizedBox(height: AppSpacing.xs),
            const RwProgressBar(
              value: 0.2,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGalleryText('Damage Trail Test (Tiklayarak dene)'),
            const SizedBox(height: AppSpacing.xs),
            RwProgressBar(
              value: _animatedHp,
              color: AppColors.coreTeal,
              showDamageTrail: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            RwButton(
              label: 'Simulate Damage',
              variant: RwButtonVariant.secondary,
              onPressed: _damageTest,
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: PANELS ---
            const RwSectionHeader(
              title: 'Panels (RwPanel)',
              subtitle: 'Baslikli ve seritsiz yukseltilmis yuzeyler',
            ),
            const SizedBox(height: AppSpacing.sm),
            RwPanel(
              title: 'TACTICAL RADAR',
              trailing: const Icon(
                Icons.radar_rounded,
                color: AppColors.aetherCyan,
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
            const SizedBox(height: AppSpacing.xl),

            // --- SECTION: CARDS ---
            const RwSectionHeader(
              title: 'Upgrade Cards (RwCard)',
              subtitle: '4 rarity duzeyi ve legendary parlamasi',
            ),
            const SizedBox(height: AppSpacing.sm),
            RwCard(
              title: 'Plasma Overcharge',
              rarity: 'common',
              badge: 'LVL 1',
              description: 'Attacks pierce through 1 additional enemy.',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            RwCard(
              title: 'Aether Siphon',
              rarity: 'rare',
              badge: 'LVL 2',
              description: 'Defeated swarm units yield 25% more Aether.',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            RwCard(
              title: 'Dimensional Surge',
              rarity: 'epic',
              badge: 'LVL 3',
              description: 'Discharge an electric nova every 12 seconds.',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            RwCard(
              title: 'Void Singularity',
              rarity: 'legendary',
              badge: 'MAX',
              description:
                  'Collapses the nearest rift portal, stunning all enemies.',
              onTap: () {},
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
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
