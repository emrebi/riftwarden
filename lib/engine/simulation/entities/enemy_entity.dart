import 'package:riftwarden/engine/simulation/pools/entity_pool.dart';

/// Havuzlanmis dusman varligi.
///
/// Tum alanlar mutable ve varsayilan degerle baslar; [reset] her spawn
/// oncesi hepsini bu varsayilanlara dondurur. `PooledEntity.id` ve
/// `pendingRemove` [EntityPool] tarafindan yonetilir, burada dokunulmaz.
class EnemyEntity extends PooledEntity {
  /// Guncel konum (izotropik dunya: y 0..1, x 0..kFieldAspect).
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

  /// Sur'a ({@link atWall}) vurus araligi (saniye). `enemies.json ->
  /// wallAttackInterval`.
  double wallAttackInterval = 1.0;

  /// Bir sonraki sur vurusuna kalan sure. `atWall` oldugunda geri sayar;
  /// sifira inince Core'a hasar verir ve tekrar [wallAttackInterval]'a
  /// dolar (bkz. `MovementSystem`).
  double wallAttackCooldown = 0;

  /// `sin` tabanli dikey salinimin faz kaymasi (bkz. `MovementSystem`
  /// dosya basi yorumu). Her dusman farkli fazda salinsin diye spawn
  /// aninda rastgele atanir; sabit olmasaydi TUM dusmanlar ayni anda
  /// yukari/asagi salinir, "swarm" hissi yerine mekanik bir desen olurdu.
  double wanderPhase = 0;

  bool isElite = false;

  /// Upgrade/behavior sisteminden gelen bayrak birlesimi (bkz. BehaviorFlag).
  int behaviorMask = 0;

  /// Durum efekti zamanlayicilari (saniye). Ileride status effect sistemleri
  /// bunlari kullanacak; simdilik sadece alan olarak ayrilir.
  double phaseTimer = 0;
  double slowTimer = 0;
  double burnTimer = 0;
  double stunTimer = 0;

  /// `wallX`'e varip durdu mu. Durunca sola ilerlemeyi birakir, periyodik
  /// olarak sur'a (`Core`) hasar verir. Dusman bu durumda SILINMEZ; oyuncu
  /// onu oldurebilir (bkz. `MovementSystem` dosya basi yorumu).
  bool atWall = false;

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
    wallAttackInterval = 1.0;
    wallAttackCooldown = 0;
    wanderPhase = 0;
    isElite = false;
    behaviorMask = 0;
    phaseTimer = 0;
    slowTimer = 0;
    burnTimer = 0;
    stunTimer = 0;
    atWall = false;
  }
}
