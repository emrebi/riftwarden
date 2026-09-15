import 'dart:typed_data';

import 'package:riftwarden/content/registry/content_registry.dart';
import 'package:riftwarden/content/schema/schema.dart';
import 'package:riftwarden/core/constants/game_constants.dart';
import 'package:riftwarden/domain/rules/rules.dart';
import 'package:riftwarden/engine/effects/effect_entity.dart';
import 'package:riftwarden/engine/effects/screen_shake.dart';
import 'package:riftwarden/engine/simulation/entities/entities.dart';
import 'package:riftwarden/engine/simulation/pools/entity_pool.dart';
import 'package:riftwarden/engine/simulation/spatial/spatial_hash_grid.dart';

/// Sabit tohum kaymasi: gorsel efekt (ekran sarsintisi) rastgeleligi oyun
/// mantigi RNG akisindan (`BattleWorld.rng`) YALITILIR (bkz.
/// `ScreenShake` dosya basi "Neden ayri RngSource" yorumu). Sabit bir asal
/// sayi kullanmak, ayni tohumla her savasta ayni sarsinti deseninin
/// tekrarlanmasini (determinizm) saglarken savas mantigi tohumuyla
/// CAKISMAMASINI garanti eder.
const int _kScreenShakeSeedOffset = 104729;

/// Ayni anda alanda bulunabilecek maksimum birlik sayisi.
///
/// Bir savasin tum degisken durumunu tutan kap.
///
/// Sistemler ([BattleSystem] implementasyonlari) bu sinifa
/// [BattleSimulation] uzerinden erisir, kendi ozel durumlarini tasimaz.
/// Boylece tum savas durumu tek yerde toplanir ve save/replay/debug
/// (ilerideki adimlar) tek noktadan okuyabilir.
class BattleWorld {
  BattleWorld._({
    required this.enemies,
    required this.units,
    required this.projectiles,
    required this.enemyGrid,
    required this.unitGrid,
    required this.level,
    required this.content,
    required this.coreHp,
    required this.coreMaxHp,
    required this.coreX,
    required this.coreY,
    required this.wallX,
    required this.defenseLineX,
    required this.spawnYMin,
    required this.spawnYMax,
    required this.riftCount,
    required this.aether,
    required this.rng,
    required this.resolvedUnitStats,
    required this.unitStatsIndex,
    required this.spawnSchedule,
    required this.queryScratch,
    required this.unitProducedCount,
    required this.effects,
    required this.screenShake,
  });

  /// Level'i, icerigi ve baslangic upgrade'lerini kullanarak yeni bir
  /// savas durumu kurar. Bu sadece savas basinda bir kez cagrilir; kurulum
  /// maliyeti (allocation, JSON okuma) burada serbesttir.
  factory BattleWorld.create({
    required LevelConfig level,
    required ContentRegistry content,
    required List<UpgradeConfig> initialUpgrades,
    required int seed,
  }) {
    final rng = RngSource(seed);
    final spawnSchedule = WavePlanner.plan(level, rng);

    // Kale konumu ve sinir X'leri izotropik dunyaya cevrilir: JSON'da 0..1
    // yazilir, motor kurulumunda `kFieldAspect` ile carpilir (bkz.
    // `docs/CONTENT_SCHEMA.md` basi "Birim kurali"). Y degismez.
    final castle = content.castle(level.castle.id);

    // Birlik stat cozumlemesi: her unit tipi icin tek bir ResolvedStats
    // blogu, indeksle referanslanir (bkz. UnitEntity.statsIndex yorumu).
    final unitIds = content.units.keys.toList(growable: false);
    final unitStatsIndex = <String, int>{};
    for (var i = 0; i < unitIds.length; i++) {
      unitStatsIndex[unitIds[i]] = i;
    }
    final resolvedUnitStats = List<ResolvedStats>.generate(
      unitIds.length,
      (i) => StatResolver.resolveUnit(content.unit(unitIds[i]), initialUpgrades),
      growable: false,
    );

    return BattleWorld._(
      enemies: EntityPool<EnemyEntity>(level.maxEnemies, EnemyEntity.new),
      units: EntityPool<UnitEntity>(kUnitPoolCapacity, UnitEntity.new),
      projectiles:
          EntityPool<ProjectileEntity>(level.maxProjectiles, ProjectileEntity.new),
      enemyGrid: SpatialHashGrid(
        cellSize: kSpatialCellSize,
        capacity: level.maxEnemies,
        width: kFieldWidth,
      ),
      unitGrid: SpatialHashGrid(
        cellSize: kSpatialCellSize,
        capacity: kUnitPoolCapacity,
        width: kFieldWidth,
      ),
      level: level,
      content: content,
      coreHp: level.coreHp,
      coreMaxHp: level.coreHp,
      // Kale konumu castles.json'dan gelir; sadece x izotropik dunyaya
      // cevrilir (bkz. yukaridaki yorum).
      coreX: castle.x * kFieldAspect,
      coreY: castle.y,
      wallX: castle.wallX * kFieldAspect,
      defenseLineX: level.defenseLineX * kFieldAspect,
      spawnYMin: level.spawn.yMin,
      spawnYMax: level.spawn.yMax,
      riftCount: level.spawn.riftCount,
      aether: level.startingAether.toInt(),
      rng: rng,
      resolvedUnitStats: resolvedUnitStats,
      unitStatsIndex: unitStatsIndex,
      spawnSchedule: spawnSchedule,
      queryScratch: Int32List(kMaxQueryResults),
      // Uretim sayaci kurulumda bos baslar; EconomySystem her uretimde
      // artirir (bkz. asagidaki yorum).
      unitProducedCount: <String, int>{},
      effects: EntityPool<EffectEntity>(kEffectPoolCapacity, EffectEntity.new),
      screenShake: ScreenShake(RngSource(seed + _kScreenShakeSeedOffset)),
    );
  }

  final EntityPool<EnemyEntity> enemies;
  final EntityPool<UnitEntity> units;
  final EntityPool<ProjectileEntity> projectiles;

  /// Gorsel efekt (parcacik, hasar sayisi, patlama) havuzu. [emitEffect]
  /// uzerinden doldurulur, [EffectSystem] tarafindan yaslandirilir.
  final EntityPool<EffectEntity> effects;

  /// Ekran sarsintisi durumu. Tetikleme sistemlerden (`MovementSystem`
  /// Core hasari, `AbilitySystem` patlama), sonumleme [EffectSystem]'den
  /// gelir; render bunu SADECE okur (bkz. `ScreenShake` dosya basi yorumu).
  final ScreenShake screenShake;

  final SpatialHashGrid enemyGrid;
  final SpatialHashGrid unitGrid;

  final LevelConfig level;

  /// Unit config'lerine ve stat cozumlemesine erismek icin. Sadece
  /// kurulumda ve upgrade alindiginda ([rebuildUnitStats]) kullanilir,
  /// savas sicak yolunda degil.
  final ContentRegistry content;

  double coreHp;
  double coreMaxHp;
  final double coreX;
  final double coreY;

  /// Dusmanin durup sur'a saldirdigi sinir (izotropik dunya X'i, kFieldAspect
  /// ile carpilmis). `castles.json > wallX`.
  final double wallX;

  /// Bu cizgiyi gecmeden dusman hedeflenemez (izotropik dunya X'i).
  /// `level.defenseLineX`.
  final double defenseLineX;

  /// Dusman spawn bandinin Y araligi. X ekseninde carpim gerekmez (Y zaten
  /// izotropik dunyada da 0..1).
  final double spawnYMin;
  final double spawnYMax;

  /// Sag kenarda gorsel olarak cizilecek rift portali sayisi (bkz.
  /// `FieldBackground`; spawn burada DEGIL, rastgele Y'de olur).
  final int riftCount;

  int aether;

  final RngSource rng;

  /// Unit tipi basina cozulmus stat + davranis bloklari. Indeks
  /// [unitStatsIndex] uzerinden bulunur (bkz. UnitEntity.statsIndex).
  final List<ResolvedStats> resolvedUnitStats;

  /// `configId` -> [resolvedUnitStats] indeksi.
  final Map<String, int> unitStatsIndex;

  /// Zaman sirali spawn takvimi. [nextSpawnIndex] motorun nereye kadar
  /// tukettigini isaretler.
  final List<SpawnEvent> spawnSchedule;
  int nextSpawnIndex = 0;

  /// Spatial sorgu sonuclarinin yazildigi paylasilan tampon. Sorgu basina
  /// liste olusturmamak icin kurulumda bir kez ayrilir; cagiran sonucu
  /// kullanir kullanmaz (ayni adim icinde) bir sonraki sorgu ustune yazar.
  final Int32List queryScratch;

  /// Bu adimda Core'a ULASMADAN havuzdan cikan (yani "oldurulen") dusman
  /// sayisi. [CompactionSystem] her adim basinda sifirlar ve compact
  /// callback'inde artirir. Sapma (10a brief disina cikilan tek nokta):
  /// ekonomi sistemi henuz yok, bu sayac sadece ileride "oldurulen dusman
  /// basina Aether/XP" hesaplayacak sisteme veri saglamak icin burada.
  int killsThisStep = 0;

  /// Bu adimda Core'a ULASMADAN olen dusmanlarin toplam `aetherReward`'i.
  ///
  /// [killsThisStep] ile AYNI VERI AKISI: [CompactionSystem] adim basinda
  /// sifirlar, `compact` callback'inde biriktirir. [EconomySystem] kendi
  /// fazinda (compaction'dan ONCE calisir, bkz. `SystemPhase` sirasi) bu
  /// degeri okuyup `aether`e ekler — yani her zaman BIR ONCEKI adimin
  /// compaction'inda biriken odulu isler. Bu, mevcut `killsThisStep`
  /// deseniyle birebir aynidir (o da ayni gecikmeyle okunur), bu yuzden
  /// yeni bir senkronizasyon sorunu eklemez; sadece "kac dusman oldu"
  /// sayisina ek olarak "ne kadar odul" bilgisini tasir.
  double aetherEarnedThisStep = 0;

  /// `unitId` -> o tipten simdiye kadar uretilmis birlik sayisi.
  /// Maliyet buyumesi (`UnitConfig.costGrowth`) bu sayaca gore hesaplanir.
  /// EconomySystem disinda yazilmaz.
  final Map<String, int> unitProducedCount;

  /// `EnemyConfig.id` -> atlas `enemies` grubundaki sprite indeksi.
  ///
  /// Bos baslar; `RiftwardenGame.onLoad` atlas yuklendikten SONRA
  /// [setEnemySpriteIndices] ile BIR KEZ doldurur. `engine/simulation`
  /// `engine/render`i (dolayisiyla `AtlasRegistry`'yi) TANIMAZ — bu yuzden
  /// cozumleme disaridan yapilir, burasi sadece sonucu tasir. [SpawnSystem]
  /// sicak yolda bu tabloyu SADECE okur, string arama yapmaz.
  final Map<String, int> enemySpriteIndex = <String, int>{};

  /// `UnitConfig.id` -> atlas `units` grubundaki sprite indeksi. [enemySpriteIndex]
  /// ile ayni gerekce ve doldurulma deseni (bkz. [setUnitSpriteIndices]).
  final Map<String, int> unitSpriteIndex = <String, int>{};

  /// [enemySpriteIndex] tablosunu doldurur. Savas kurulumunda bir kez
  /// cagrilir (bkz. dosya basi yorumu).
  void setEnemySpriteIndices(Map<String, int> indices) {
    enemySpriteIndex
      ..clear()
      ..addAll(indices);
  }

  /// [unitSpriteIndex] tablosunu doldurur. Savas kurulumunda bir kez
  /// cagrilir (bkz. dosya basi yorumu).
  void setUnitSpriteIndices(Map<String, int> indices) {
    unitSpriteIndex
      ..clear()
      ..addAll(indices);
  }

  /// `EffectKind` -> atlas `fx` grubundaki sprite indeksi. [enemySpriteIndex]
  /// ile ayni gerekce: efekt icerik JSON'undan degil motor sabitinden
  /// (`RiftwardenGame._effectFrameNames`) gelir, cunku efektler icerik
  /// degil motorun gorsel "his" katmanidir. Bos baslar; `RiftwardenGame
  /// .onLoad` atlas yuklendikten sonra [setEffectSpriteIndices] ile bir
  /// kez doldurur.
  final Map<EffectKind, int> effectSpriteIndex = <EffectKind, int>{};

  /// [effectSpriteIndex] tablosunu doldurur. Savas kurulumunda bir kez
  /// cagrilir (bkz. dosya basi yorumu).
  void setEffectSpriteIndices(Map<EffectKind, int> indices) {
    effectSpriteIndex
      ..clear()
      ..addAll(indices);
  }

  /// Efekt basina varsayilan omur (saniye). `emitEffect` bunu kullanir;
  /// cagiran taraf (ornegin `AbilitySystem`) gerekirse spawn sonrasi
  /// donen varligin `lifetime`/`scale` alanlarini ELLE override edebilir
  /// (bkz. Rift Collapse uyari halkasi/patlama ayrimi).
  static const Map<EffectKind, double> _defaultEffectLifetime = <EffectKind, double>{
    EffectKind.hitSpark: 0.22,
    EffectKind.deathPuff: 0.4,
    EffectKind.aetherMote: 0.7,
    EffectKind.coreImpact: 0.3,
    EffectKind.abilityBlast: 0.5,
  };

  /// Efekt basina varsayilan taban boyut (normalize alan uzayinda).
  static const Map<EffectKind, double> _defaultEffectScale = <EffectKind, double>{
    EffectKind.hitSpark: 0.02,
    EffectKind.deathPuff: 0.05,
    EffectKind.aetherMote: 0.02,
    EffectKind.coreImpact: 0.06,
    EffectKind.abilityBlast: 0.18,
  };

  /// Bir gorsel efekt talep eder. Havuz doluysa **sessizce atlar** (bkz.
  /// `EntityPool.spawn` sozlesmesi) — gorsel bir kivilcimin kaybolmasi
  /// oynanisi etkilemez, exception firlatmaya degmez.
  ///
  /// Donen varlik (varsa) cagiran tarafindan ek olarak ozellestirilebilir
  /// (ornegin `AbilitySystem` patlama yaricapini `scale`'e yazar). `step()`
  /// icinde cagrilir, bu yuzden allocation YOKTUR — sadece havuzdan bir
  /// nesne cekilir.
  EffectEntity? emitEffect(
    EffectKind kind,
    double x,
    double y, {
    int value = 0,
    bool isCritical = false,
  }) {
    final effect = effects.spawn();
    if (effect == null) return null;

    effect
      ..kind = kind
      ..x = x
      ..y = y
      ..prevX = x
      ..prevY = y
      ..vx = 0
      // aetherMote yukari suzulmeye BURADA degil `EffectSystem.step`'te
      // baslar (kAetherMoteLift); baslangicta vy=0 yeterli, ilk adimda ivme
      // hemen isler.
      ..vy = 0
      ..spriteIndex = effectSpriteIndex[kind] ?? 0
      ..age = 0
      ..lifetime = _defaultEffectLifetime[kind] ?? 0.3
      ..scale = _defaultEffectScale[kind] ?? 0.02
      ..rotation = 0
      ..value = value
      ..isCritical = isCritical;
    return effect;
  }

  // --- Yetenek (Rift Collapse) komut kuyugu ---
  //
  // `BattleController.toggleAbilityAiming`/`castAbilityAt` UI thread'inden
  // herhangi bir anda cagrilabilir; `enqueueUnitRequest` ile AYNI gerekce
  // (bkz. yukaridaki dosya basi yorumu) geregi durum degisikligi burada
  // BAYRAKLANIR, gercek isleme `AbilitySystem.step()`e birakilir.
  bool _abilityAimToggleRequested = false;
  bool _abilityCastRequested = false;
  double _abilityCastX = 0;
  double _abilityCastY = 0;

  /// UI'dan gelen nisan alma modu acma/kapama talebini isaretler.
  void requestAbilityAimToggle() {
    _abilityAimToggleRequested = true;
  }

  /// UI'dan gelen yetenek kullanim talebini isaretler.
  void requestAbilityCast(double x, double y) {
    _abilityCastRequested = true;
    _abilityCastX = x;
    _abilityCastY = y;
  }

  /// Bekleyen nisan alma bayragini tuketir. Sadece [AbilitySystem]
  /// tarafindan, adim icinde tuketilir.
  bool consumeAbilityAimToggle() {
    final requested = _abilityAimToggleRequested;
    _abilityAimToggleRequested = false;
    return requested;
  }

  /// Bekleyen yetenek kullanim talebini tuketir; varsa true doner ve
  /// [pendingCastX]/[pendingCastY] o talebin koordinatlarini tasir.
  bool tryConsumeAbilityCast() {
    if (!_abilityCastRequested) return false;
    _abilityCastRequested = false;
    return true;
  }

  double get pendingCastX => _abilityCastX;
  double get pendingCastY => _abilityCastY;

  /// Sabit kapasiteli birlik uretim talebi kuyrugu (halka tampon).
  ///
  /// UI (`BattleController.requestUnit`) herhangi bir anda cagirabilir, ama
  /// simulasyon durumu SADECE `step()` icinde degismeli — aksi halde adim
  /// ortasinda entity eklenir ve o adimin spatial grid/dizin varsayimlari
  /// bozulur. Bu yuzden talep burada bekletilir, [EconomySystem] adimin
  /// economy fazinda kuyrugu bosaltir. Sabit boyutlu List: her cagrida
  /// buyume/allocation yok.
  static const int _productionQueueCapacity = 16;
  final List<String> _productionQueue =
      List<String>.filled(_productionQueueCapacity, '', growable: false);
  int _productionQueueHead = 0;
  int _productionQueueCount = 0;

  /// UI'dan gelen birlik uretim talebini kuyruga ekler.
  ///
  /// Kuyruk doluysa talep sessizce dusurulur: oyuncu pratikte ayni anda
  /// bu kadar cok butona basamaz, kapasite fiilen hicbir zaman dolmaz;
  /// dolsa bile patlamak yerine bir talebi kaybetmek tercih edilir.
  void enqueueUnitRequest(String unitId) {
    if (_productionQueueCount >= _productionQueueCapacity) return;
    final tail = (_productionQueueHead + _productionQueueCount) % _productionQueueCapacity;
    _productionQueue[tail] = unitId;
    _productionQueueCount++;
  }

  /// Kuyruktaki bir sonraki talebi cikarir, yoksa null doner.
  /// Sadece [EconomySystem] tarafindan, adim icinde tuketilir.
  String? dequeueUnitRequest() {
    if (_productionQueueCount == 0) return null;
    final id = _productionQueue[_productionQueueHead];
    _productionQueueHead = (_productionQueueHead + 1) % _productionQueueCapacity;
    _productionQueueCount--;
    return id;
  }

  /// Bir upgrade alindiginda cagrilir; [resolvedUnitStats] listesini
  /// yeniden hesaplar. **Kare basina DEGIL** — sadece upgrade seti
  /// degistiginde (bkz. StatResolver dosya basi yorumu).
  void rebuildUnitStats(List<UpgradeConfig> taken) {
    for (final entry in unitStatsIndex.entries) {
      resolvedUnitStats[entry.value] =
          StatResolver.resolveUnit(content.unit(entry.key), taken);
    }
  }

  /// Spatial grid'leri bu adimin guncel konumlariyla yeniden kurar.
  ///
  /// [SystemPhase.spatialIndex] fazinda, spawn'dan sonra hedefleme ve
  /// hareketten once cagrilir. Grid dizinleri sadece bu adim icinde
  /// gecerlidir (bkz. SpatialHashGrid dosya basi yorumu).
  void rebuildSpatialIndex() {
    enemyGrid.clear();
    for (var i = 0; i < enemies.activeCount; i++) {
      final enemy = enemies[i];
      enemyGrid.add(i, enemy.x, enemy.y);
    }
    enemyGrid.build();

    unitGrid.clear();
    for (var i = 0; i < units.activeCount; i++) {
      final unit = units[i];
      unitGrid.add(i, unit.x, unit.y);
    }
    unitGrid.build();
  }
}
