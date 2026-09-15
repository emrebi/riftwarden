import 'package:riftwarden/content/schema/upgrade_config.dart';
import 'package:riftwarden/domain/rules/rng_source.dart';

/// Upgrade teklif havuzu: ne teklif edilecegini agirlikli rastgele secer.
///
/// Bir kart alindiginda o ailenin (`family`) sonraki tekliflerdeki agirligi
/// artar ("family synergy"). Amac: oyuncunun bilincli bir build kurabilmesi
/// (tamamen sansa birakmamak) ama yine de her teklifin garanti olmamasi
/// (tamamen oyuncu secimine de birakmamak). Bu yuzden carpan sinirli bir
/// tavana kadar buyur, sonra durur.
class UpgradePool {
  UpgradePool(List<UpgradeConfig> allUpgrades)
      : _all = List<UpgradeConfig>.unmodifiable(allUpgrades);

  final List<UpgradeConfig> _all;

  /// upgradeId -> kac kez alindi.
  final Map<String, int> _stacksTaken = {};

  /// family -> o aileden kac uye alindi (synergy carpani bunu kullanir).
  final Map<String, int> _familyTakenCount = {};

  /// Bir aile icin her alinan uyede agirlik carpani bu kadar buyur.
  ///
  /// 1.5 secildi: iki-uc kart sonra build'in belirginlesmesini saglayacak
  /// kadar guclu, ama ilk karttan sonra havuzu tek aileye kilitleyecek kadar
  /// agresif degil.
  static const double _familySynergyStep = 1.5;

  /// Carpanin tavani. Sinirsiz buyume, ust seviyelerde havuzu tamamen tek
  /// aileye indirger ve "secim" hissini yok eder; bu yuzden sabit bir tavan
  /// var.
  static const double _familySynergyCap = 4.0;

  /// `count` kadar agirlikli, tekrarsiz upgrade secer.
  ///
  /// Havuzda yeterli uygun aday yoksa (requires/maxStacks nedeniyle
  /// eleniyorsa) exception firlatmadan bulunan kadarini doner; upgrade
  /// teklif ekraninin bos/az secenekle de calisabilmesi gerekir.
  List<UpgradeConfig> roll(int count, RngSource rng) {
    final candidates = _eligibleCandidates();
    final result = <UpgradeConfig>[];

    while (result.length < count && candidates.isNotEmpty) {
      final weights = candidates.map(_weightOf).toList(growable: false);
      final totalWeight = weights.fold<double>(0, (sum, w) => sum + w);
      if (totalWeight <= 0) break;

      final roll = rng.nextDouble() * totalWeight;
      var cursor = 0.0;
      var pickedIndex = candidates.length - 1;
      for (var i = 0; i < candidates.length; i++) {
        cursor += weights[i];
        if (roll < cursor) {
          pickedIndex = i;
          break;
        }
      }

      result.add(candidates.removeAt(pickedIndex));
    }

    return result;
  }

  /// Alinan upgrade'i kaydeder ve ailesinin synergy agirligini gunceller.
  void take(UpgradeConfig upgrade) {
    _stacksTaken[upgrade.id] = (_stacksTaken[upgrade.id] ?? 0) + 1;
    _familyTakenCount[upgrade.family] = (_familyTakenCount[upgrade.family] ?? 0) + 1;
  }

  List<UpgradeConfig> _eligibleCandidates() {
    return _all.where((upgrade) {
      // Dukkan (Aether ile satin alinan savasci yetenegi) kart havuzuna
      // GIRMEZ (bkz. `docs/CONTENT_SCHEMA.md` > "upgrades.json"); esik
      // karti teklifi sadece `source: card` olanlardan secilir.
      if (upgrade.source == UpgradeSource.shop) return false;

      final stacksSoFar = _stacksTaken[upgrade.id] ?? 0;
      if (stacksSoFar >= upgrade.maxStacks) return false;

      for (final requiredId in upgrade.requires) {
        if ((_stacksTaken[requiredId] ?? 0) <= 0) return false;
      }

      return true;
    }).toList();
  }

  double _weightOf(UpgradeConfig upgrade) {
    final familyCount = _familyTakenCount[upgrade.family] ?? 0;
    final rawMultiplier = 1.0 + familyCount * (_familySynergyStep - 1.0);
    final synergyMultiplier = rawMultiplier > _familySynergyCap ? _familySynergyCap : rawMultiplier;
    return upgrade.weight * synergyMultiplier;
  }
}
