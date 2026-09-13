/// Upgrade'lerin actigi davranislar icin bit maskesi.
///
/// Neden bit maskesi: bir birligin/global'in davranisi birden fazla upgrade
/// tarafindan ayni anda acilabilir (ornegin hem "chainLightning" hem
/// "criticalHits"). Bunu tek bir `int` uzerinde OR ile tasimak, savas
/// sicak yolunda (her vurus, her kare) `List<String>` gezmekten veya
/// `Set<String>.contains` cagirmaktan kat kat ucuz ve allocation'siz.
abstract final class BehaviorFlag {
  const BehaviorFlag._();

  static const int chainLightning = 1 << 0;
  static const int piercingShots = 1 << 1;
  static const int criticalHits = 1 << 2;
  static const int explosiveImpact = 1 << 3;
  static const int swarmFrenzy = 1 << 4;
  static const int regeneratingShield = 1 << 5;
  static const int overflowStorage = 1 << 6;

  // Ileride gelecek upgrade aileleri icin ayrilmis bayraklar.
  static const int burn = 1 << 7;
  static const int freeze = 1 << 8;
  static const int slow = 1 << 9;
  static const int stun = 1 << 10;
  static const int knockback = 1 << 11;
  static const int bonusAether = 1 << 12;
  static const int coreShield = 1 << 13;

  /// Icerik JSON'undaki bayrak adini bit degerine cevirir.
  ///
  /// Bilinmeyen adda sessizce 0 donmek yerine hata firlatilir: aksi halde
  /// icerikteki bir yazim hatasi, upgrade'i fark edilmeden etkisiz birakir.
  static int parse(String name) => switch (name) {
        'chainLightning' => chainLightning,
        'piercingShots' => piercingShots,
        'criticalHits' => criticalHits,
        'explosiveImpact' => explosiveImpact,
        'swarmFrenzy' => swarmFrenzy,
        'regeneratingShield' => regeneratingShield,
        'overflowStorage' => overflowStorage,
        'burn' => burn,
        'freeze' => freeze,
        'slow' => slow,
        'stun' => stun,
        'knockback' => knockback,
        'bonusAether' => bonusAether,
        'coreShield' => coreShield,
        _ => throw ArgumentError('BehaviorFlag: bilinmeyen bayrak adi: "$name"'),
      };

  /// Sicak yolda kullanilacak tek bit testi.
  static bool has(int mask, int flag) => (mask & flag) != 0;
}
