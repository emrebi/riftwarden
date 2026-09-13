import 'package:riftwarden/content/schema/unit_config.dart';
import 'package:riftwarden/content/schema/upgrade_config.dart';
import 'package:riftwarden/domain/rules/behavior_flags.dart';
import 'package:riftwarden/domain/rules/stat_block.dart';

/// DIKKAT: bu dosyadaki cozumleme her kare CAGRILMAZ.
///
/// [StatResolver] sadece oyuncu bir upgrade aldiginda (yani alinan upgrade
/// seti degistiginde) calisir; sonuc ([ResolvedStats]) o birlik tipi icin
/// bir sonraki upgrade'e kadar onbellege alinip savas dongusunde dogrudan
/// okunur. Sicak yolda (her kare/her vurus) bu sinifi cagirmak, "savas
/// sirasinda allocation yok" kuralini ihlal eder ve gereksiz yere upgrade
/// listesini tekrar tekrar tarar.

/// Bir birlik tipi (veya global hedef) icin cozulmus stat + davranis seti.
class ResolvedStats {
  const ResolvedStats({required this.stats, required this.behaviorMask});

  final StatBlock stats;
  final int behaviorMask;
}

/// Upgrade seti + taban degerlerden [ResolvedStats] ureten kurallar.
abstract final class StatResolver {
  const StatResolver._();

  static const String _targetAll = 'all';

  /// Bir birlik icin taban degerleri (`UnitConfig`) alinan upgrade'lerle
  /// birlestirip nihai stat blogunu ve davranis maskesini uretir.
  static ResolvedStats resolveUnit(UnitConfig base, List<UpgradeConfig> taken) {
    final stats = StatBlock();
    stats[StatId.damage] = base.damage;
    stats[StatId.attackSpeed] = base.attackSpeed;
    stats[StatId.range] = base.range;
    stats[StatId.hp] = base.hp;
    stats[StatId.moveSpeed] = base.moveSpeed;
    stats[StatId.cost] = base.cost;
    stats[StatId.costGrowth] = base.costGrowth;

    return _resolve(stats, taken, (target) => target == base.id || target == _targetAll);
  }

  /// `core` / `economy` / `ability` gibi birim disi hedefler icin cozumleme.
  /// Bu hedeflerin taban degeri yoktur (icerikte ayrica tanimli, ornegin
  /// `LevelConfig.coreHp`); burada sadece upgrade katkilari birikir.
  static ResolvedStats resolveGlobal(List<UpgradeConfig> taken, String target) {
    final stats = StatBlock();
    return _resolve(stats, taken, (t) => t == target);
  }

  static ResolvedStats _resolve(
    StatBlock stats,
    List<UpgradeConfig> taken,
    bool Function(String target) matches,
  ) {
    // Once TUM add'ler, sonra TUM mul'ler uygulanir. Sira karisirsa ayni
    // upgrade seti farkli sonuc uretir (ornegin +10 sonra x2 ile x2 sonra
    // +10 farklidir); deterministik build sonucu icin sira sabitlenir.
    for (final upgrade in taken) {
      for (final modifier in upgrade.stats) {
        if (!matches(modifier.target)) continue;
        if (modifier.op != StatOp.add) continue;
        final id = StatId.parse(modifier.stat);
        stats[id] = stats[id] + modifier.value;
      }
    }

    for (final upgrade in taken) {
      for (final modifier in upgrade.stats) {
        if (!matches(modifier.target)) continue;
        if (modifier.op != StatOp.mul) continue;
        final id = StatId.parse(modifier.stat);
        stats[id] = stats[id] * modifier.value;
      }
    }

    // Bir upgrade'in bayraklari, o upgrade'in stat hedefiyle ayni hedefe
    // uygulanir (ornegin "chainLightning" sadece "arc_ranger"i etkilemeli,
    // "healer"a sizmamali). Stat listesi bos olan salt-davranissal bir
    // upgrade icin hedef bilgisi olmadigindan bayrak dogrudan uygulanir.
    var behaviorMask = 0;
    for (final upgrade in taken) {
      final applies = upgrade.stats.isEmpty ||
          upgrade.stats.any((modifier) => matches(modifier.target));
      if (!applies) continue;
      for (final flag in upgrade.flags) {
        behaviorMask |= BehaviorFlag.parse(flag);
      }
    }

    return ResolvedStats(stats: stats, behaviorMask: behaviorMask);
  }
}
