import 'package:riftwarden/engine/simulation/pools/entity_pool.dart';

/// Birlik rolu. Hedefleme ve davranis sistemleri role gore dallanir.
enum UnitRole { swarm, ranged, tank, support }

/// Havuzlanmis savunma birligi varligi.
///
/// Tum alanlar mutable ve varsayilan degerle baslar; [reset] her spawn
/// oncesi hepsini bu varsayilanlara dondurur. `PooledEntity.id` ve
/// `pendingRemove` [EntityPool] tarafindan yonetilir, burada dokunulmaz.
class UnitEntity extends PooledEntity {
  double x = 0;
  double y = 0;

  /// Render'in `prev` -> guncel arasini lerp'lemesi icin (bkz. EnemyEntity).
  double prevX = 0;
  double prevY = 0;

  /// `units.json` icindeki id.
  String configId = '';

  /// Sprite atlas karesi.
  int spriteIndex = 0;

  UnitRole role = UnitRole.swarm;

  double hp = 0;
  double maxHp = 0;

  /// Su an kilitlenilen dusmanin kararli id'si. 0 = hedef yok.
  int targetId = 0;

  /// [targetId]'nin havuzdaki son bilinen dizini.
  ///
  /// Neden gerekli: havuz dizinleri swap-remove ile kayar (bkz.
  /// `entity_pool.dart` dosya basi yorumu). Hedefi her karede id ile
  /// aramak `EntityPool.indexOfId` uzerinden O(n) tarama demektir. Bunun
  /// yerine son bilinen dizin burada saklanir; kullanmadan once
  /// `pool[targetIndexHint].id == targetId` diye dogrulanir. Tutuyorsa
  /// O(1) erisim, tutmuyorsa (dizin kaymis veya hedef olmus) sistem yeniden
  /// hedef arar.
  int targetIndexHint = -1;

  /// Bir sonraki saldiriya kalan sure (saniye).
  double attackCooldown = 0;

  /// Bir sonraki hedef yenilemeye kalan sure (saniye). `kRetargetInterval`
  /// ile stagger edilir; her birlik ayni karede hedef aramaz.
  double retargetCooldown = 0;

  /// [BattleWorld.resolvedUnitStats] listesindeki indeks.
  ///
  /// Neden indeks: ayni tipteki tum birlikler upgrade'lerle cozulmus tek
  /// bir `ResolvedStats` blogunu paylasir; her birlik kendi kopyasini
  /// tasimaz. Upgrade alindiginda sadece o tek blok yeniden hesaplanir,
  /// tum birlikler otomatik guncel stat okur.
  int statsIndex = 0;

  @override
  void reset() {
    x = 0;
    y = 0;
    prevX = 0;
    prevY = 0;
    configId = '';
    spriteIndex = 0;
    role = UnitRole.swarm;
    hp = 0;
    maxHp = 0;
    targetId = 0;
    targetIndexHint = -1;
    attackCooldown = 0;
    retargetCooldown = 0;
    statsIndex = 0;
  }
}
