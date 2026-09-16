import 'package:flutter/foundation.dart';

/// Dalga ilerlemesi ozeti. HUD'da "Wave 3 / 8" gostermek icin.
@immutable
class WaveProgress {
  const WaveProgress({
    required this.current,
    required this.total,
    required this.isBossWave,
  });

  static const WaveProgress empty =
      WaveProgress(current: 0, total: 0, isBossWave: false);

  final int current;
  final int total;
  final bool isBossWave;

  @override
  bool operator ==(Object other) =>
      other is WaveProgress &&
      other.current == current &&
      other.total == total &&
      other.isBossWave == isBossWave;

  @override
  int get hashCode => Object.hash(current, total, isBossWave);
}

/// Aktif yetenegin HUD'a yansiyan durumu.
@immutable
class AbilityState {
  const AbilityState({
    required this.abilityId,
    required this.cooldownRemaining,
    required this.cooldownTotal,
    required this.isAiming,
  });

  static const AbilityState empty = AbilityState(
    abilityId: '',
    cooldownRemaining: 0,
    cooldownTotal: 0,
    isAiming: false,
  );

  final String abilityId;
  final double cooldownRemaining;
  final double cooldownTotal;
  final bool isAiming;

  bool get isReady => cooldownRemaining <= 0;

  /// 0 = hazir, 1 = yeni kullanildi.
  double get cooldownRatio =>
      cooldownTotal <= 0 ? 0 : (cooldownRemaining / cooldownTotal).clamp(0, 1);

  @override
  bool operator ==(Object other) =>
      other is AbilityState &&
      other.abilityId == abilityId &&
      other.cooldownRemaining == cooldownRemaining &&
      other.cooldownTotal == cooldownTotal &&
      other.isAiming == isAiming;

  @override
  int get hashCode =>
      Object.hash(abilityId, cooldownRemaining, cooldownTotal, isAiming);
}

/// Bir kale yuvasinin HUD'a yansiyan durumu.
///
/// `unitId` burada `int` degil `String?`dir — HUD'un ilgilendigi savasci
/// TIPI degil (motor ici `UnitEntity.id` HUD'a anlamsizdir), sadece
/// "yuva dolu mu" ve doluysa gorsel amacli hangi ikon gosterilecegi. Bu
/// yuzden motor bu sinyali ureten sistem (`EconomySystem`) icerik id'sini
/// degil, doluluk bilgisini tasir; HUD sadece dolu/bos ayrimini kullanir.
@immutable
class SlotState {
  const SlotState({required this.slotIndex, required this.unitId});

  final int slotIndex;

  /// null = yuva bos.
  final int? unitId;

  @override
  bool operator ==(Object other) =>
      other is SlotState && other.slotIndex == slotIndex && other.unitId == unitId;

  @override
  int get hashCode => Object.hash(slotIndex, unitId);
}

/// Aether yetenek dukkanindaki tek bir teklifin HUD'a yansiyan durumu.
@immutable
class ShopOffer {
  const ShopOffer({
    required this.upgradeId,
    required this.unitId,
    required this.cost,
    required this.canBuy,
    required this.owned,
  });

  final String upgradeId;

  /// Bu yetenegin ait oldugu savasci tipi (`upgrades.json > unit`).
  final String unitId;

  final int cost;

  /// Sartlar (requires, maxStacks) karsilanmis VE Aether yeterli.
  final bool canBuy;

  /// En az bir kez alinmis mi (maxStacks 1'i asan yeteneklerde bile
  /// "sahipsin" gostergesi icin kullanilir; tam doluluk icin `canBuy` de
  /// kontrol edilmeli).
  final bool owned;

  @override
  bool operator ==(Object other) =>
      other is ShopOffer &&
      other.upgradeId == upgradeId &&
      other.unitId == unitId &&
      other.cost == cost &&
      other.canBuy == canBuy &&
      other.owned == owned;

  @override
  int get hashCode => Object.hash(upgradeId, unitId, cost, canBuy, owned);
}

/// Acik bir esik karti teklifinin HUD'a yansiyan durumu.
@immutable
class UpgradeOffer {
  const UpgradeOffer({required this.upgradeIds, required this.rerollsLeft});

  /// Teklif edilen upgrade id'leri (1-3 arasi; havuz bosaldiysa daha az).
  final List<String> upgradeIds;

  /// Bu savasta kalan ucretsiz reroll hakki.
  final int rerollsLeft;

  @override
  bool operator ==(Object other) =>
      other is UpgradeOffer &&
      other.rerollsLeft == rerollsLeft &&
      _listEquals(other.upgradeIds, upgradeIds);

  @override
  int get hashCode => Object.hash(Object.hashAll(upgradeIds), rerollsLeft);

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Savasin nasil bittigi.
enum BattleOutcome { running, victory, defeat }

/// Titresim siddeti. Isimler platform haptic API'lerinin (bkz.
/// `HapticFeedback` / `core/services`) siddet kademeleriyle birebir
/// eslesecek sekilde secildi; motor bu API'yi DOGRUDAN cagirmaz (bkz.
/// [HapticCue] dosya basi yorumu).
enum HapticCueKind { light, medium, heavy, selection }

/// Motordan HUD'a giden TEK titresim bildirimi.
///
/// ## Neden bu sinif, neden dogrudan HapticFeedback.vibrate() degil
/// `engine/` katmani `lib/core/services/` import EDEMEZ (bkz. CLAUDE.md
/// kural 2: engine sadece `domain/` ve `content/` bilir). Titresim ise
/// platforma ozel bir servistir (`core/services/haptic_service.dart`).
/// Bu yuzden motor SADECE "bir titresim olayi oldu, turu bu" der;
/// `features/battle` katmani bu sinyali dinleyip gercek platform cagrisini
/// yapar.
///
/// ## Neden sayac, neden dogrudan `ValueNotifier<HapticCueKind>`
/// Ayni tur art arda (ornegin iki kritik vurus ayni HUD throttle
/// penceresinde) gelirse `ValueNotifier<HapticCueKind>` deger DEGISMEDIGI
/// icin ikinci bildirimi DUSURUR (Flutter `ValueNotifier` sadece deger
/// gercekten degisince dinleyicileri uyarir). Sayac her tetiklemede
/// artar; deger (kind, sayac) ciftinden olustugu icin ayni tur ust uste
/// gelse bile her tetikleme ayri bir bildirim olarak gorulur.
@immutable
class HapticCue {
  const HapticCue({required this.kind, required this.sequence});

  static const HapticCue none = HapticCue(kind: HapticCueKind.selection, sequence: 0);

  final HapticCueKind kind;
  final int sequence;

  @override
  bool operator ==(Object other) =>
      other is HapticCue && other.kind == kind && other.sequence == sequence;

  @override
  int get hashCode => Object.hash(kind, sequence);
}

/// Motordan HUD'a giden **tek** koprü.
///
/// ## Neden ValueNotifier, neden Riverpod degil
/// Savas dongusu 60 Hz kosar. Her adimda Riverpod provider'i guncellemek
/// widget agacini yeniden kurar ve kare suresini catlatir. Bunun yerine
/// her deger kendi [ValueNotifier]'inda durur; HUD'da sadece o degeri
/// gosteren widget `ValueListenableBuilder` ile dinler. Boylece Aether
/// degistiginde SADECE Aether yazisi yeniden cizilir.
///
/// ## Throttle kurali
/// Surekli degisen degerler ([aether], [coreHpRatio], [ability]) motorda
/// `kHudThrottleInterval` (100 ms) araliginda push edilir.
/// Kesikli olaylar ([upgradeOffer], [outcome], [bossIntro]) throttle'a
/// TABI DEGILDIR; olustugu an push edilir.
///
/// ## Yon kurali
/// Bu sinif tek yonludur: motor yazar, UI okur. UI'dan motora komut
/// (birlik uret, yetenek kullan) `BattleCommands` uzerinden gider —
/// boylece iki yonlu bagimlilik olusmaz.
class BattleSignals {
  final ValueNotifier<int> aether = ValueNotifier<int>(0);
  final ValueNotifier<double> coreHpRatio = ValueNotifier<double>(1);
  final ValueNotifier<int> coreHp = ValueNotifier<int>(0);
  final ValueNotifier<WaveProgress> wave =
      ValueNotifier<WaveProgress>(WaveProgress.empty);
  final ValueNotifier<AbilityState> ability =
      ValueNotifier<AbilityState>(AbilityState.empty);

  /// Ekranda su an kac dusman var. Sadece debug/HUD gostergesi.
  final ValueNotifier<int> enemyCount = ValueNotifier<int>(0);

  /// Uretilebilir birliklerin guncel maliyeti (unitId -> Aether).
  /// Maliyet upgrade ile degisebildigi icin sinyal olarak akar; HUD
  /// butonlari bunu okuyup yetersiz bakiyede kendini pasiflestirir.
  final ValueNotifier<Map<String, int>> unitCosts =
      ValueNotifier<Map<String, int>>(const <String, int>{});

  /// Kale yuvalarinin doluluk durumu, sirayla `castles.json > slots` ile
  /// eslesir. SADECE doluluk gercekten degisince yeni liste push edilir
  /// (bkz. `EconomySystem._maybePushSlots`).
  final ValueNotifier<List<SlotState>> slots =
      ValueNotifier<List<SlotState>>(const <SlotState>[]);

  /// Aether yetenek dukkanindaki tum teklifler, `upgradeId` ile anahtarli.
  /// Aether veya sahiplik degistiginde, throttle edilerek push edilir
  /// (bkz. `EconomySystem._maybePushShopOffers`).
  final ValueNotifier<Map<String, ShopOffer>> abilityShop =
      ValueNotifier<Map<String, ShopOffer>>(const <String, ShopOffer>{});

  /// Doluysa oyun pause'dadir ve upgrade karti gosterilir.
  /// Oyuncu sectiginde UI `BattleCommands.chooseUpgrade` cagirir ve
  /// motor bunu tekrar null yapar.
  final ValueNotifier<UpgradeOffer?> upgradeOffer =
      ValueNotifier<UpgradeOffer?>(null);

  /// Boss girisi tetiklendiginde boss id'si; bittiginde null.
  final ValueNotifier<String?> bossIntro = ValueNotifier<String?>(null);

  final ValueNotifier<BattleOutcome> outcome =
      ValueNotifier<BattleOutcome>(BattleOutcome.running);

  /// Her tetiklemede sayaci artar (bkz. [HapticCue] dosya basi yorumu);
  /// UI degisimi dinleyip `core/services` altindaki gercek HapticService'i
  /// cagirir. Motor titresim API'sini DOGRUDAN cagirmaz.
  final ValueNotifier<HapticCue> hapticCue = ValueNotifier<HapticCue>(HapticCue.none);
  int _hapticSequence = 0;

  /// Yeni bir titresim olayi bildirir. Kesikli bir olaydir (bkz. dosya basi
  /// "Throttle kurali"), throttle'a TABI DEGILDIR.
  void triggerHaptic(HapticCueKind kind) {
    _hapticSequence++;
    hapticCue.value = HapticCue(kind: kind, sequence: _hapticSequence);
  }

  /// Savas basinda tum sinyalleri varsayilana dondurur.
  void reset() {
    aether.value = 0;
    coreHpRatio.value = 1;
    coreHp.value = 0;
    wave.value = WaveProgress.empty;
    ability.value = AbilityState.empty;
    enemyCount.value = 0;
    unitCosts.value = const <String, int>{};
    slots.value = const <SlotState>[];
    abilityShop.value = const <String, ShopOffer>{};
    upgradeOffer.value = null;
    bossIntro.value = null;
    outcome.value = BattleOutcome.running;
    hapticCue.value = HapticCue.none;
    _hapticSequence = 0;
  }

  void dispose() {
    aether.dispose();
    coreHpRatio.dispose();
    coreHp.dispose();
    wave.dispose();
    ability.dispose();
    enemyCount.dispose();
    unitCosts.dispose();
    slots.dispose();
    abilityShop.dispose();
    upgradeOffer.dispose();
    bossIntro.dispose();
    outcome.dispose();
    hapticCue.dispose();
  }
}

/// UI'dan motora giden komutlar.
///
/// [BattleSignals]'in tersi yonu. Motor bunu implemente eder, UI cagirir.
/// Arayuz olmasinin sebebi: `features/battle` katmani `engine` sinifina
/// dogrudan bagimli olmasin, test edilebilir kalsin.
abstract interface class BattleCommands {
  /// Takviye uret. Yetersiz Aether'da veya bos yuva yoksa sessizce yok sayilir.
  void requestUnit(String unitId);

  /// Aether yetenek dukkanindan bir yetenek satin al. Sartlar
  /// karsilanmiyorsa (Aether yetersiz, requires/maxStacks) sessizce yok
  /// sayilir.
  void buyAbility(String upgradeId);

  /// Yetenek nisan alma moduna gec / cik.
  void toggleAbilityAiming();

  /// Normalize (0..1) savas alani koordinatinda yetenegi kullan.
  void castAbilityAt(double x, double y);

  /// Upgrade teklifinden birini sec. Oyun pause'dan cikar.
  void chooseUpgrade(String upgradeId);

  /// Upgrade tekliflerini yeniden cek (odullu reklam / Cell karsiligi).
  void rerollUpgrades();

  void pause();
  void resume();
}
