import 'package:riftwarden/domain/rules/behavior_flags.dart';
import 'package:riftwarden/domain/rules/rng_source.dart';
import 'package:riftwarden/domain/rules/stat_block.dart';

/// Bir hasar hesabinin sonucu.
///
/// Kucuk ve immutable tutuldu (out-parametre deseni yerine): sinif iki
/// `double`/`bool` alanindan ibaret, Dart'ta bu boyutta kisa omurlu bir
/// nesne genc nesil GC'de pratikte bedavaya yakindir. Out-parametre
/// (cagirana yazdirilan mutable bir "sonuc kutusu") burada okunabilirligi
/// dusurur ama olcumsuz bir kazanc getirmez; bu yuzden basit ve degismez
/// deger tercih edildi.
class DamageResult {
  const DamageResult({required this.amount, required this.isCritical});

  final double amount;
  final bool isCritical;
}

/// Hasar hesaplama kurallari.
abstract final class DamageCalculator {
  const DamageCalculator._();

  static DamageResult compute({
    required double baseDamage,
    required StatBlock stats,
    required int behaviorMask,
    required RngSource rng,
  }) {
    // criticalHits bayragi yoksa kritik sansi/hasari hesaba katilmaz, boylece
    // bu bayragi almamis bir birlik icin gereksiz rng cagrisi da yapilmaz.
    if (!BehaviorFlag.has(behaviorMask, BehaviorFlag.criticalHits)) {
      return DamageResult(amount: baseDamage, isCritical: false);
    }

    final critChance = stats[StatId.critChance];
    if (!rng.chance(critChance)) {
      return DamageResult(amount: baseDamage, isCritical: false);
    }

    final critDamage = stats[StatId.critDamage];
    return DamageResult(amount: baseDamage * critDamage, isCritical: true);
  }
}
