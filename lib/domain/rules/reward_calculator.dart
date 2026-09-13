import 'package:riftwarden/content/schema/level_config.dart';

/// Bir level tamamlaninca verilecek odul.
class LevelReward {
  const LevelReward({
    required this.shards,
    required this.cells,
    required this.isFirstClear,
  });

  final int shards;
  final int cells;
  final bool isFirstClear;
}

/// Level odul hesabi.
abstract final class RewardCalculator {
  const RewardCalculator._();

  /// `firstClearCells`, sadece level bu oyuncu tarafindan ilk kez
  /// bitiriliyorsa verilir; tekrar oynamalarda `cells` hep 0'dir.
  static LevelReward forLevel(LevelConfig level, {required bool isFirstClear}) {
    return LevelReward(
      shards: level.rewards.shards,
      cells: isFirstClear ? level.rewards.firstClearCells : 0,
      isFirstClear: isFirstClear,
    );
  }
}
