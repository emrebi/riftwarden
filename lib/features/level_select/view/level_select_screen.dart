import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';
import 'package:riftwarden/features/level_select/widgets/sector_card.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_screen_scaffold.dart';

/// Level secim ve ilerleme haritasi sayfasi.
///
/// Oyuncunun 10 sektor ve 50 seviye uzerindeki durumunu gosterir.
/// Tamamen stateless ve veri-bagimsizdir; tum durumlar ve tiklama
/// eylemleri disaridan iletilir.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({
    required this.sectors,
    required this.shards,
    required this.onLevelTap,
    required this.onBack,
    super.key,
  });

  /// Gosterilecek sektor listesi.
  final List<SectorData> sectors;

  /// Guncel Aether Shard miktari.
  final int shards;

  /// Bir level dugumune dokunuldugunda cagrilan geri arama.
  final void Function(int levelId) onLevelTap;

  /// Geri donus butonu eylemi.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return RwScreenScaffold(
      onBack: onBack,
      trailing: RwCurrencyChip(
        currency: RwCurrency.shard,
        amount: shards,
      ),
      contentPadding: EdgeInsetsDirectional.zero,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.screenGutter,
          end: AppSpacing.screenGutter,
          top: AppSpacing.sm,
          bottom: AppSpacing.xl,
        ),
        itemCount: sectors.length,
        itemBuilder: (BuildContext context, int index) {
          final sector = sectors[index];
          return Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: AppSpacing.md,
            ),
            child: SectorCard(
              sector: sector,
              onLevelTap: onLevelTap,
            ),
          );
        },
      ),
    );
  }
}
