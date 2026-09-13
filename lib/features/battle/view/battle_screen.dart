// GECICI: sadece render dogrulamasi icin. Gercek savas HUD'u arayuz worker'i tarafindan yazilacak.

import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riftwarden/app/theme/app_spacing.dart';
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/engine/riftwarden_game.dart';
import 'package:riftwarden/shared/widgets/rw_icon_button.dart';

/// Savas ekraninin GECICI iskeleti.
///
/// Amac: atlas yukleme -> `BattleWorld` kurulumu -> sistemler -> render
/// zincirinin (bkz. `engine/riftwarden_game.dart`) ekranda gercekten
/// calistigini dogrulamak. HUD, uretim butonlari, upgrade paneli, pause
/// menusu buraya EKLENMEZ — bunlar arayuz worker'inin isidir; bu ekran
/// o is bitince tamamen degistirilecektir.
class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({
    required this.levelId,
    required this.onBack,
    super.key,
  });

  /// Yuklenecek level. Gecici dogrulama icin genelde 1.
  final int levelId;

  /// Geri donus eylemi (rota gecisi disaridan yonetilir).
  final VoidCallback onBack;

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  late final RiftwardenGame _game;

  @override
  void initState() {
    super.initState();
    // `ContentRegistry` `contentRegistryProvider` uzerinden okunur (bkz.
    // brief); savas Riverpod'un kendisine bagimli DEGILDIR — sadece
    // kurulum verisini buradan bir kez cekeriz (bkz. CLAUDE.md kural 3,
    // "Riverpod savas dongusune girmez").
    final content = ref.read(contentRegistryProvider);
    _game = RiftwardenGame(
      level: content.level(widget.levelId),
      content: content,
      // Gecici dogrulama ekrani: her acilista farkli bir dalga dizilimi
      // gormek icin duvar saatinden tohumlanir. Gercek akista seed
      // level secimi/run baslangicinda belirlenecek (bu ekranin isi degil).
      seed: DateTime.now().millisecondsSinceEpoch,
      initialUpgrades: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: GameWidget(game: _game)),
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            end: AppSpacing.sm,
            child: RwIconButton(
              icon: Icons.close_rounded,
              onPressed: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }
}
