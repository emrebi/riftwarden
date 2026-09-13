import 'package:flame/components.dart' show Vector2;
import 'package:flame/game.dart' show FlameGame;
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_background.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/render/projectile_renderer.dart';
import 'package:riftwarden/engine/render/swarm_renderer.dart';
import 'package:riftwarden/engine/render/unit_renderer.dart';
import 'package:riftwarden/engine/simulation/battle_controller.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';
import 'package:riftwarden/engine/simulation/default_systems.dart';

/// Riftwarden savas ekraninin Flame kokü.
///
/// Bu sinif motor (`engine/simulation`) ile render (`engine/render`)
/// katmanlarini birbirine baglayan TEK yerdir. `features/` bu sinifi
/// kurar (bkz. `battle_screen.dart`) ve sadece [signals]/[commands]
/// uzerinden etkilesir — HUD widget'lari asla [battleWorld] veya
/// [simulation]'a dogrudan erismez (bkz. CLAUDE.md kural 3).
///
/// Flame'in kendi carpisma sistemi (`HasCollisionDetection`) KULLANILMAZ:
/// `engine/simulation/spatial` altindaki spatial hash grid zaten bu isi
/// yapiyor, ikinci bir sistem hem gereksiz hem de simulasyonun tek
/// gercek kaynak olma ilkesini (bkz. `battle_simulation.dart` dosya basi
/// yorumu) bozar.
class RiftwardenGame extends FlameGame {
  RiftwardenGame({
    required this.level,
    required this.content,
    required this.seed,
    required this.initialUpgrades,
  });

  final LevelConfig level;
  final ContentRegistry content;
  final int seed;
  final List<UpgradeConfig> initialUpgrades;

  /// Motordan HUD'a giden koprü (bkz. `battle_signals.dart` dosya basi
  /// yorumu). UI bunu dinler, asla yazmaz.
  late final BattleSignals signals;

  /// HUD'dan motora giden komutlar. UI bunu cagirir, asla dogrudan
  /// [battleWorld]/[simulation] durumuna dokunmaz.
  late final BattleCommands commands;

  /// Savasin tum degisken durumu. Ad `battleWorld`: `FlameGame.world`
  /// zaten Flame'in kendi `World` component'i icin ayrilmis, ayni isim
  /// bunu golgeler (override hatasi verir).
  late final BattleWorld battleWorld;
  late final BattleSimulation simulation;
  late final AtlasRegistry atlas;
  late final FieldProjection projection;

  /// [projection]'in paylastigi boyut vektoru. [onGameResize] `onLoad`'dan
  /// ONCE tetiklenebildigi icin (Flame ilk yerlesimi widget kurulur
  /// kurulmaz bildirir) `projection` (`late final`) henuz yokken bu deger
  /// GUVENLE guncellenebilsin diye ayri tutulur; `projection` kuruldugunda
  /// AYNI nesneyi (kopya degil) verir, boylece [onGameResize] sonrasi
  /// hicbir ek senkronizasyon gerekmez.
  final Vector2 _fieldSize = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _fieldSize.setFrom(size);

    atlas = AtlasRegistry();
    await atlas.load();

    battleWorld = BattleWorld.create(
      level: level,
      content: content,
      initialUpgrades: initialUpgrades,
      seed: seed,
    );
    _resolveSpriteIndices();

    signals = BattleSignals();
    simulation = BattleSimulation(signals: signals)..attachWorld(battleWorld);
    registerDefaultSystems(simulation);
    commands = BattleController(simulation);

    projection = FieldProjection(_fieldSize);

    // Z-sirasi eklenme sirasidir: zemin en altta, sonra birlikler/dusmanlar,
    // en ustte mermiler. Bu render bilesenleri Flame'in kendi `world`
    // (World component'i) icine DEGIL, dogrudan oyuna eklenir — boylece
    // kamera pan/zoom donusumune tabi olmadan `FieldProjection`in urettigi
    // mutlak ekran pikselinde cizilir (bu oyunda kamera hareketi yok,
    // bkz. brief).
    add(FieldBackground(world: battleWorld, atlas: atlas, projection: projection));
    add(
      SwarmRenderer(world: battleWorld, sim: simulation, atlas: atlas, projection: projection),
    );
    add(
      UnitRenderer(world: battleWorld, sim: simulation, atlas: atlas, projection: projection),
    );
    add(
      ProjectileRenderer(
        world: battleWorld,
        sim: simulation,
        atlas: atlas,
        projection: projection,
      ),
    );

    simulation.start();
  }

  /// `configId` -> atlas indeksi tablolarini savas kurulumunda BIR KEZ
  /// doldurur (bkz. `BattleWorld.enemySpriteIndex`/`unitSpriteIndex` dosya
  /// basi yorumu). Sistemler sicak yolda sadece bu tabloyu okur.
  void _resolveSpriteIndices() {
    final enemyIndices = <String, int>{
      for (final id in content.enemies.keys)
        id: atlas.indexOf('enemies', content.enemy(id).sprite),
    };
    battleWorld.setEnemySpriteIndices(enemyIndices);

    final unitIndices = <String, int>{
      for (final id in content.units.keys) id: atlas.indexOf('units', content.unit(id).sprite),
    };
    battleWorld.setUnitSpriteIndices(unitIndices);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // `_fieldSize` yerinde (in-place) guncellenir; `projection` henuz
    // kurulmamis olsa bile (bkz. [_fieldSize] dosya basi yorumu) bu
    // guvenlidir.
    _fieldSize.setFrom(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    simulation.advance(dt);
  }

  @override
  void onDispose() {
    signals.dispose();
    super.onDispose();
  }
}
