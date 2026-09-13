/// Savas sonucu turu.
enum BattleResultKind {
  /// Zafer: Rift muhurlendi.
  victory,

  /// Yenilgi: Cekirdek coktu.
  defeat,
}

/// Savas sonucu verisi.
///
/// Ekran durumunu belirler (zafer/yenilgi, kazanilan oduller,
/// dalga ilerlemesi ve reklam izleme hakki).
class BattleResultData {
  const BattleResultData({
    required this.kind,
    required this.levelNumber,
    required this.shardsEarned,
    required this.cellsEarned,
    required this.wavesCleared,
    required this.totalWaves,
    required this.canWatchAd,
  });

  /// Sonuc turu: zafer veya yenilgi.
  final BattleResultKind kind;

  /// Oynanan seviyenin numarasi.
  final int levelNumber;

  /// Bu savasta kazanilan Rift Shard miktari.
  final int shardsEarned;

  /// Bu savasta kazanilan Aether Cell miktari (0 ise arayuzde gosterilmez).
  final int cellsEarned;

  /// Temizlenen dalga sayisi (ozellikle yenilgide moral gostergesi).
  final int wavesCleared;

  /// Seviyedeki toplam dalga sayisi.
  final int totalWaves;

  /// Reklam izleyerek devam etme veya odul katlama hakki var mi.
  final bool canWatchAd;
}
