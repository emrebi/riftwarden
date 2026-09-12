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

/// Savasin nasil bittigi.
enum BattleOutcome { running, victory, defeat }

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

  /// Doluysa oyun pause'dadir ve upgrade karti gosterilir.
  /// Oyuncu sectiginde UI `BattleCommands.chooseUpgrade` cagirir ve
  /// motor bunu tekrar null yapar.
  final ValueNotifier<List<String>?> upgradeOffer =
      ValueNotifier<List<String>?>(null);

  /// Boss girisi tetiklendiginde boss id'si; bittiginde null.
  final ValueNotifier<String?> bossIntro = ValueNotifier<String?>(null);

  final ValueNotifier<BattleOutcome> outcome =
      ValueNotifier<BattleOutcome>(BattleOutcome.running);

  /// Savas basinda tum sinyalleri varsayilana dondurur.
  void reset() {
    aether.value = 0;
    coreHpRatio.value = 1;
    coreHp.value = 0;
    wave.value = WaveProgress.empty;
    ability.value = AbilityState.empty;
    enemyCount.value = 0;
    unitCosts.value = const <String, int>{};
    upgradeOffer.value = null;
    bossIntro.value = null;
    outcome.value = BattleOutcome.running;
  }

  void dispose() {
    aether.dispose();
    coreHpRatio.dispose();
    coreHp.dispose();
    wave.dispose();
    ability.dispose();
    enemyCount.dispose();
    unitCosts.dispose();
    upgradeOffer.dispose();
    bossIntro.dispose();
    outcome.dispose();
  }
}

/// UI'dan motora giden komutlar.
///
/// [BattleSignals]'in tersi yonu. Motor bunu implemente eder, UI cagirir.
/// Arayuz olmasinin sebebi: `features/battle` katmani `engine` sinifina
/// dogrudan bagimli olmasin, test edilebilir kalsin.
abstract interface class BattleCommands {
  /// Takviye uret. Yetersiz Aether'da sessizce yok sayilir.
  void requestUnit(String unitId);

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
