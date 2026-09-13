/// Level dugumunun erisim ve tamamlanma durumu.
enum LevelNodeState {
  /// Seviye basariyla gecildi.
  completed,

  /// Siradaki oynanabilir aktif seviye.
  current,

  /// Henuz acilmamis kilitli seviye.
  locked,
}

/// Tek bir level dugumunun salt veri modeli.
class LevelNodeData {
  const LevelNodeData({
    required this.levelId,
    required this.state,
    required this.isBoss,
  });

  /// Seviye numarasi (1..50).
  final int levelId;

  /// Dugumun gorsel ve etkilesim durumu.
  final LevelNodeState state;

  /// Sektor sonu boss seviyesi olup olmadigi.
  final bool isBoss;
}

/// Sektor bloklarinin salt veri modeli.
class SectorData {
  const SectorData({
    required this.sectorId,
    required this.name,
    required this.levels,
    required this.isLocked,
    required this.completedCount,
  });

  /// Sektor numarasi (1..10).
  final int sectorId;

  /// Sektor adi (l10n uzerinden disarida cozulur).
  final String name;

  /// Sektor altindaki 5 adet seviye dugumu.
  final List<LevelNodeData> levels;

  /// Sektorun kilitli olup olmadigi.
  final bool isLocked;

  /// Sektor icinde tamamlanan seviye adedi.
  final int completedCount;
}
