import 'package:flutter/material.dart';
import 'package:riftwarden/app/theme/app_colors.dart';
import 'package:riftwarden/app/theme/app_decorations.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/features/level_select/view/level_select_data.dart';
import 'package:riftwarden/features/level_select/widgets/sector_card.dart';
import 'package:riftwarden/shared/widgets/rw_currency_chip.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';

/// Level secim ve ilerleme haritasi sayfasi.
///
/// Oyuncunun boyutlar arasinda soldan saga ilerledigi yatay harita ekrani.
/// 10 sektor ve 50 seviye uzerindeki durumu gosterir.
/// Acilista `current` seviyenin bulundugu sektor gorunur alana konumlanir.
class LevelSelectScreen extends StatefulWidget {
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
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final initialIndex = _findCurrentSectorIndex();
    // Kart genisligi ve kartlar arasi bosluk adimi
    const itemExtent = SectorCard.cardWidth + AppSpacing.md;
    final initialOffset = initialIndex * itemExtent;
    _scrollController = ScrollController(
      initialScrollOffset: initialOffset,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _findCurrentSectorIndex() {
    final currentIndex = widget.sectors.indexWhere(
      (SectorData sector) => sector.levels
          .any((LevelNodeData node) => node.state == LevelNodeState.current),
    );
    if (currentIndex != -1) {
      return currentIndex;
    }
    // Eger aktif seviye bulunamazsa ilk kilitli olmayan ve tamamlanmamis sektore konumlan
    final incompleteIndex = widget.sectors.indexWhere(
      (SectorData sector) =>
          !sector.isLocked && sector.completedCount < sector.levels.length,
    );
    if (incompleteIndex != -1) {
      return incompleteIndex;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final notchStart = isRtl ? viewPadding.right : viewPadding.left;
    final notchEnd = isRtl ? viewPadding.left : viewPadding.right;

    return Scaffold(
      backgroundColor: AppColors.voidDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: SafeArea(
          left: false,
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Ust ince serit: Geri butonu ve Shard gostergesi
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: AppSpacing.screenGutter + notchStart,
                  end: AppSpacing.screenGutter + notchEnd,
                  top: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                ),
                child: SizedBox(
                  height: AppSpacing.minTouchTarget,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RwIconButton(
                        icon: isRtl
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        onPressed: widget.onBack,
                      ),
                      RwCurrencyChip(
                        currency: RwCurrency.shard,
                        amount: widget.shards,
                      ),
                    ],
                  ),
                ),
              ),

              // Sektor kartlari yatay harita seridi
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsetsDirectional.only(
                    start: AppSpacing.screenGutter + notchStart,
                    end: AppSpacing.screenGutter + notchEnd,
                    top: AppSpacing.xs,
                    bottom: AppSpacing.md,
                  ),
                  itemCount: widget.sectors.length,
                  itemBuilder: (BuildContext context, int index) {
                    final sector = widget.sectors[index];
                    final isLast = index == widget.sectors.length - 1;
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: isLast ? 0.0 : AppSpacing.md,
                      ),
                      child: SectorCard(
                        sector: sector,
                        onLevelTap: widget.onLevelTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
