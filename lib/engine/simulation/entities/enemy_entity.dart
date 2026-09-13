import 'package:riftwarden/engine/simulation/pools/entity_pool.dart';

/// Havuzlanmis dusman varligi.
///
/// Tum alanlar mutable ve varsayilan degerle baslar; [reset] her spawn
/// oncesi hepsini bu varsayilanlara dondurur. `PooledEntity.id` ve
/// `pendingRemove` [EntityPool] tarafindan yonetilir, burada dokunulmaz.
class EnemyEntity extends PooledEntity {
  /// Guncel konum (normalize 0..1).
  double x = 0;
  double y = 0;

  /// Bir onceki simulasyon adimindaki konum. Render [BattleSimulation.alpha]
  /// ile `prev` -> guncel arasini lerp eder; bu kopya olmadan dusuk fps'te
  /// hareket kasar (stutter) gorunur.
  double prevX = 0;
  double prevY = 0;

  /// `enemies.json` icindeki id. Icerige geri donup bakmak icin saklanir
  /// (olum odulu, davranis lookup'i vb.).
  String configId = '';

  /// Sprite atlas karesi. Render batch'i string karsilastirmasi yapmasin
  /// diye int index kullanilir.
  int spriteIndex = 0;

  double hp = 0;
  double maxHp = 0;
  double speed = 0;
  double radius = 0;
  double coreDamage = 0;
  double aetherReward = 0;

  /// Hangi lane'i takip ettigi ve o lane'deki bir sonraki hedef waypoint.
  int laneIndex = 0;
  int waypointIndex = 0;

  bool isElite = false;

  /// Upgrade/behavior sisteminden gelen bayrak birlesimi (bkz. BehaviorFlag).
  int behaviorMask = 0;

  /// Durum efekti zamanlayicilari (saniye). Ileride status effect sistemleri
  /// bunlari kullanacak; simdilik sadece alan olarak ayrilir.
  double phaseTimer = 0;
  double slowTimer = 0;
  double burnTimer = 0;
  double stunTimer = 0;

  /// Core'a ulasip hasar verdiyse true; ayni adimda iki kez hasar
  /// vermemesi icin compaction'a kadar bu bayrakla korunur.
  bool reachedCore = false;

  @override
  void reset() {
    x = 0;
    y = 0;
    prevX = 0;
    prevY = 0;
    configId = '';
    spriteIndex = 0;
    hp = 0;
    maxHp = 0;
    speed = 0;
    radius = 0;
    coreDamage = 0;
    aetherReward = 0;
    laneIndex = 0;
    waypointIndex = 0;
    isElite = false;
    behaviorMask = 0;
    phaseTimer = 0;
    slowTimer = 0;
    burnTimer = 0;
    stunTimer = 0;
    reachedCore = false;
  }
}
