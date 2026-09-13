import 'package:riftwarden/engine/simulation/pools/entity_pool.dart';

/// Havuzlanmis mermi varligi.
///
/// Tum alanlar mutable ve varsayilan degerle baslar; [reset] her spawn
/// oncesi hepsini bu varsayilanlara dondurur. `PooledEntity.id` ve
/// `pendingRemove` [EntityPool] tarafindan yonetilir, burada dokunulmaz.
class ProjectileEntity extends PooledEntity {
  double x = 0;
  double y = 0;

  /// Render'in `prev` -> guncel arasini lerp'lemesi icin (bkz. EnemyEntity).
  double prevX = 0;
  double prevY = 0;

  /// Saniyedeki konum degisimi. Guduml mermiler her karede hedefe gore
  /// yeniden hesaplar, duz mermiler sabit tutar.
  double vx = 0;
  double vy = 0;

  double damage = 0;
  double radius = 0;
  double speed = 0;

  /// Kalan omur (saniye). Sifira inince `pendingRemove = true` olur.
  double lifetime = 0;

  int spriteIndex = 0;

  /// Upgrade'lerden gelen davranis bayraklari (chainLightning, piercingShots
  /// vb.) — bkz. `BehaviorFlag`.
  int behaviorMask = 0;

  /// Guduml mermilerin kilitlendigi dusmanin kararli id'si. 0 = hedef yok
  /// (duz cizgi ucan mermi).
  int targetId = 0;

  /// [targetId]'nin havuzdaki son bilinen dizini (bkz. `UnitEntity.targetIndexHint`
  /// ile ayni gerekce: dizinler swap-remove ile kayar, id ile O(n) arama
  /// yerine son bilinen dizin dogrulanip kullanilir).
  int targetIndexHint = -1;

  /// Kalan delme sayisi (piercingShots). Her carpismada bir azalir, 0
  /// olunca mermi yok olur.
  int pierceRemaining = 0;

  /// Kalan zincirleme sayisi (chainLightning). Her sicramada bir azalir.
  int chainRemaining = 0;

  /// Bu mermiyi ateşleyen birligin kararli id'si. Oldurme sayaci ve
  /// kaynak atfi (hangi birlik ne kadar hasar verdi) icin kullanilir.
  int ownerUnitId = 0;

  /// [BattleWorld.resolvedUnitStats] listesindeki indeks (bkz.
  /// `UnitEntity.statsIndex` ile ayni gerekce). Carpma aninda
  /// `DamageCalculator.compute` icin kritik sans/hasar statlarina buradan
  /// erisilir — mermi kendi StatBlock kopyasini tasimaz.
  int statsIndex = 0;

  @override
  void reset() {
    x = 0;
    y = 0;
    prevX = 0;
    prevY = 0;
    vx = 0;
    vy = 0;
    damage = 0;
    radius = 0;
    speed = 0;
    lifetime = 0;
    spriteIndex = 0;
    behaviorMask = 0;
    targetId = 0;
    targetIndexHint = -1;
    pierceRemaining = 0;
    chainRemaining = 0;
    ownerUnitId = 0;
    statsIndex = 0;
  }
}
