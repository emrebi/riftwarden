import 'dart:ui' show Canvas;

import 'package:flame/components.dart' show Vector2;
import 'package:flame/game.dart' show FlameGame;
import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/engine/bridge/battle_signals.dart';
import 'package:riftwarden/engine/effects/effect_entity.dart';
import 'package:riftwarden/engine/effects/effect_renderer.dart';
import 'package:riftwarden/engine/render/atlas_registry.dart';
import 'package:riftwarden/engine/render/field_projection.dart';
import 'package:riftwarden/engine/render/map_renderer.dart';
import 'package:riftwarden/engine/render/projectile_renderer.dart';
import 'package:riftwarden/engine/render/swarm_renderer.dart';
import 'package:riftwarden/engine/render/unit_renderer.dart';
import 'package:riftwarden/engine/simulation/battle_controller.dart';
import 'package:riftwarden/engine/simulation/battle_simulation.dart';
import 'package:riftwarden/engine/simulation/battle_world.dart';
import 'package:riftwarden/engine/simulation/default_systems.dart';

/// `EffectKind` -> atlas `fx` grubundaki kare adi.
///
/// ## Sapma: bazi turler icin ozel kare henuz yok
/// `assets/images/atlas/fx.json` su an sadece `hit_spark`, `aether_mote`,
/// `arc_lance`, `enemy_spit`, `pulse_bolt` kareleri iceriyor (bkz. asset
/// uretimi `rw-assets` skill'inin isi, bu worker gorevinin kapsami DISINDA
/// — CLAUDE.md rol tablosu: sprite/ikon Gemini + assetkit'in isi). Bu
/// yuzden `deathPuff` ve `coreImpact` GECICI olarak `hit_spark`'i (farkli
/// olcek/omurle) yeniden kullanir. Ozel kareler eklendiginde tek yapilacak
/// sey bu tablodaki karsiliklari degistirmektir.
const Map<EffectKind, String> _effectFrameNames = <EffectKind, String>{
  EffectKind.hitSpark: 'hit_spark',
  EffectKind.deathPuff: 'death_puff',
  EffectKind.aetherMote: 'aether_mote',
  EffectKind.coreImpact: 'core_impact',
  EffectKind.abilityBlast: 'ability_blast',
};

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
  /// ## Neden simulasyon `onLoad`'da DEGIL burada kuruluyor
  /// HUD, oyun yuklenmeden once `signals`/`commands`'e baglanabilmeli.
  /// Bunlar `onLoad` icinde kurulursa UI onlari beklemek zorunda kalir ve
  /// atlas yuklemesi herhangi bir sebeple takilirsa ekranda HIC BIR SEY
  /// gorunmez (ne oyun, ne HUD, ne hata) — sessiz siyah ekran.
  /// Simulasyonun hicbir parcasi atlas'a ihtiyac duymadigi icin hepsi
  /// burada kurulur; `onLoad`'a yalnizca gorsel isler kalir.
  RiftwardenGame({
    required this.level,
    required this.content,
    required this.seed,
    required this.initialUpgrades,
  })  : battleWorld = BattleWorld.create(
          level: level,
          content: content,
          initialUpgrades: initialUpgrades,
          seed: seed,
        ),
        signals = BattleSignals() {
    simulation = BattleSimulation(signals: signals)..attachWorld(battleWorld);
    registerDefaultSystems(simulation);
    // `BattleController` calisir DUNYA (izotropik motor) koordinatinda;
    // UI'dan gelen dokunma ise EKRAN-normalize (0..1, ekranin kendi
    // genislik/yuksekligine gore) koordinattir (bkz. `battle_screen.dart`
    // `onTapDown`). Bu ikisi arasindaki cevrim `FieldProjection`e (letterbox
    // `offsetX` + `scale`) ihtiyac duyar; `BattleController`
    // (`engine/simulation`) render katmanini TANIMAMALI (bkz. CLAUDE.md
    // kural 2). Bu yuzden cevrim, simulasyon ile render'i zaten birbirine
    // baglayan TEK yer olan bu sinifta (`RiftwardenGame`, bkz. dosya basi
    // yorumu) `_ProjectionAwareCommands` sarmalayicisiyla yapilir.
    commands = _ProjectionAwareCommands(BattleController(simulation), this);
  }

  final LevelConfig level;
  final ContentRegistry content;
  final int seed;
  final List<UpgradeConfig> initialUpgrades;

  /// Motordan HUD'a giden koprü (bkz. `battle_signals.dart` dosya basi
  /// yorumu). UI bunu dinler, asla yazmaz.
  final BattleSignals signals;

  /// Savasin tum degisken durumu. Ad `battleWorld`: `FlameGame.world`
  /// zaten Flame'in kendi `World` component'i icin ayrilmis, ayni isim
  /// bunu golgeler (override hatasi verir).
  final BattleWorld battleWorld;

  /// HUD'dan motora giden komutlar. UI bunu cagirir, asla dogrudan
  /// [battleWorld]/[simulation] durumuna dokunmaz.
  /// Constructor GOVDESINDE atanir (initializer list `this`'e erisemez).
  late final BattleCommands commands;
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

    // Simulasyon constructor'da kuruldu; burada yalnizca gorsel baglama
    // kaldi (sprite indeksleri atlas'a, renderer'lar projeksiyona bagli).
    _resolveSpriteIndices();

    projection = FieldProjection(_fieldSize);

    // Z-sirasi eklenme sirasidir: zemin en altta, sonra birlikler/dusmanlar,
    // en ustte mermiler. Bu render bilesenleri Flame'in kendi `world`
    // (World component'i) icine DEGIL, dogrudan oyuna eklenir — boylece
    // kamera pan/zoom donusumune tabi olmadan `FieldProjection`in urettigi
    // mutlak ekran pikselinde cizilir (bu oyunda kamera hareketi yok,
    // bkz. brief).
    add(MapRenderer(world: battleWorld, atlas: atlas, projection: projection));
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
    // Efektler EN USTTE: vurus kivilcimi/hasar sayisi altindaki
    // birlik/dusman/mermiyi gizlememeli ama kendisi de gizlenmemeli.
    add(
      EffectRenderer(world: battleWorld, sim: simulation, atlas: atlas, projection: projection),
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

    final effectIndices = <EffectKind, int>{
      for (final entry in _effectFrameNames.entries)
        entry.key: atlas.indexOf('fx', entry.value),
    };
    battleWorld.setEffectSpriteIndices(effectIndices);
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

  /// Ekran sarsintisini TUM render agacinin ustune uygular (bkz.
  /// `ScreenShake` dosya basi yorumu). `canvas.translate` component
  /// agacini SARMALAR — tek bir yerde uygulanir, her render bileseninin
  /// kendi offsetini eklemesi gerekmez.
  @override
  void render(Canvas canvas) {
    final shake = battleWorld.screenShake;
    final dx = projection.toScreenSize(shake.offsetX);
    final dy = projection.toScreenSize(shake.offsetY);

    canvas.save();
    canvas.translate(dx, dy);
    super.render(canvas);
    canvas.restore();
  }

  @override
  void onDispose() {
    signals.dispose();
    super.onDispose();
  }
}

/// [BattleCommands] sarmalayicisi: `castAbilityAt` disindaki tum komutlari
/// oldugu gibi devreder, sadece nisan koordinatini EKRAN-normalize'den
/// DUNYA'ya cevirir (bkz. `RiftwardenGame` constructor'indaki yorum).
///
/// `_game.projection` `late final` oldugu ve `RiftwardenGame.onLoad`de
/// kuruldugu icin bu sarmalayici sadece oyun yuklendikten SONRA (yani UI
/// yetenek nisanini gosterebildikten sonra) cagrilabilir; erken cagri
/// olmaz cunku nisan alma UI'i zaten `signals.ability.isAiming` uzerinden
/// acilir ve bu sinyal ancak savas basladiktan sonra true olabilir.
class _ProjectionAwareCommands implements BattleCommands {
  _ProjectionAwareCommands(this._inner, this._game);

  final BattleCommands _inner;
  final RiftwardenGame _game;

  @override
  void requestUnit(String unitId) => _inner.requestUnit(unitId);

  @override
  void buyAbility(String upgradeId) => _inner.buyAbility(upgradeId);

  @override
  void toggleAbilityAiming() => _inner.toggleAbilityAiming();

  @override
  void castAbilityAt(double x, double y) {
    final projection = _game.projection;
    _inner.castAbilityAt(projection.toWorldX(x), projection.toWorldY(y));
  }

  @override
  void chooseUpgrade(String upgradeId) => _inner.chooseUpgrade(upgradeId);

  @override
  void rerollUpgrades() => _inner.rerollUpgrades();

  @override
  void pause() => _inner.pause();

  @override
  void resume() => _inner.resume();
}
