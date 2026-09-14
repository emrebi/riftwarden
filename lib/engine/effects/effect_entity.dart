import 'package:riftwarden/engine/simulation/pools/entity_pool.dart';

/// Bir gorsel efektin turu. Sadece render/his katmanini ilgilendirir;
/// simulasyon sonucunu ASLA etkilemez (bkz. `SystemPhase.effects` yorumu:
/// "Gorsel; simulasyon sonucunu DEGISTIRMEMELI").
enum EffectKind {
  /// Mermi/yakin dovus vurusu. Genelde bir hasar sayisi (`value`) tasir.
  hitSpark,

  /// Dusman oldugunde patlayan kucuk duman/kirinti.
  deathPuff,

  /// Olen dusmandan yukari suzulen Aether zerresi.
  aetherMote,

  /// Core hasar aldiginda Core'un ustunde beliren carpma efekti.
  coreImpact,

  /// Yetenegin (Rift Collapse) uyari halkasi VE patlamasi. Ikisi de bu
  /// turle temsil edilir; aralarindaki fark `scale`/`lifetime`
  /// degerlerindedir (bkz. `AbilitySystem._beginCast`/`_resolveBlast`).
  abilityBlast,
}

/// Havuzlanmis gorsel efekt varligi (parcacik, hasar sayisi, patlama vb.).
///
/// Tum alanlar mutable ve varsayilan degerle baslar; [reset] her spawn
/// oncesi hepsini bu varsayilanlara dondurur. `PooledEntity.id` ve
/// `pendingRemove` [EntityPool] tarafindan yonetilir, burada dokunulmaz.
class EffectEntity extends PooledEntity {
  double x = 0;
  double y = 0;

  /// Render'in `prev` -> guncel arasini lerp'lemesi icin (bkz. EnemyEntity).
  double prevX = 0;
  double prevY = 0;

  /// Saniyedeki konum degisimi. Cogu efekt icin 0'dir (yerinde patlar);
  /// `aetherMote` yukari suzulmek icin negatif `vy` tasir (bkz.
  /// `EffectSystem` dosya basi yorumu, Y ekseni asagi buyur).
  double vx = 0;
  double vy = 0;

  /// Atlas `fx` grubundaki kare indeksi. `BattleWorld.effectSpriteIndex`
  /// tablosundan cozulur (bkz. `enemySpriteIndex`/`unitSpriteIndex` ile
  /// ayni desen); render sicak yolunda string arama yapilmaz.
  int spriteIndex = 0;

  /// Dogumundan beri gecen sure (saniye). [lifetime]'a ulasinca
  /// `pendingRemove = true` olur.
  double age = 0;
  double lifetime = 0;

  /// Normalize (0..1 alan uzayi) taban boyut. Render bunu buyutup
  /// soldurarak (bkz. `EffectRenderer`) yasi ilerledikce animasyon uygular.
  double scale = 0;

  /// Radyan cinsinden donme. Sadece `abilityBlast` icin kullanilir
  /// (patlamaya gorsel donus hissi katmak icin); digerlerinde 0 kalir.
  double rotation = 0;

  EffectKind kind = EffectKind.hitSpark;

  /// Hasar sayisi. 0 ise render katmani sayi CIZMEZ (bkz. brief).
  int value = 0;

  /// Kritik vurus mu? Sayinin buyuklugunu/rengini degistirir.
  bool isCritical = false;

  @override
  void reset() {
    x = 0;
    y = 0;
    prevX = 0;
    prevY = 0;
    vx = 0;
    vy = 0;
    spriteIndex = 0;
    age = 0;
    lifetime = 0;
    scale = 0;
    rotation = 0;
    kind = EffectKind.hitSpark;
    value = 0;
    isCritical = false;
  }
}
