import 'dart:math';

/// Tohumlanabilir (seeded) rastgelelik sarmalayicisi.
///
/// Savas deterministik olmali: ayni tohum ile baslatilan bir savas her
/// zaman ayni sonucu vermeli. Bu, hata ayiklamada bir kosuyu birebir
/// tekrar uretebilmek icin sarttir (rapor edilen bir bug'i "tohum X ile
/// tekrar oynat" diyerek yeniden gorebilmek). Dogrudan `Random()`
/// (tohumsuz) kullanmak bunu imkansiz kilar.
class RngSource {
  RngSource(int seed) : _random = Random(seed);

  final Random _random;

  double nextDouble() => _random.nextDouble();

  int nextInt(int max) => _random.nextInt(max);

  /// `probability` (0..1) ihtimalle true doner.
  bool chance(double probability) => _random.nextDouble() < probability;
}
