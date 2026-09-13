import 'dart:typed_data';

/// Birim ve global statlarin kimligi.
///
/// Enum index'i dogrudan [StatBlock] icindeki depolama slotudur; bu yuzden
/// siralama onemlidir ama disaridan hicbir kod index'e guvenmemeli, hep
/// bu enum uzerinden erisilmeli.
enum StatId {
  damage,
  attackSpeed,
  range,
  hp,
  moveSpeed,
  cost,
  costGrowth,
  critChance,
  critDamage,
  chainTargets,
  pierceCount,
  explosionRadius,
  explosionDamage,
  aetherGain,
  spawnCooldown,
  coreMaxHp,
  coreRegen,
  abilityCooldown;

  /// Icerik JSON'undaki stat adini (`upgrades.json` > `stats[].stat`) enum
  /// degerine cevirir. Bilinmeyen adda hata firlatir; sessiz gecmek bir
  /// upgrade'in yazim hatasi yuzunden fark edilmeden etkisiz kalmasina yol
  /// acar.
  static StatId parse(String name) => switch (name) {
        'damage' => StatId.damage,
        'attackSpeed' => StatId.attackSpeed,
        'range' => StatId.range,
        'hp' => StatId.hp,
        'moveSpeed' => StatId.moveSpeed,
        'cost' => StatId.cost,
        'costGrowth' => StatId.costGrowth,
        'critChance' => StatId.critChance,
        'critDamage' => StatId.critDamage,
        'chainTargets' => StatId.chainTargets,
        'pierceCount' => StatId.pierceCount,
        'explosionRadius' => StatId.explosionRadius,
        'explosionDamage' => StatId.explosionDamage,
        'aetherGain' => StatId.aetherGain,
        'spawnCooldown' => StatId.spawnCooldown,
        'coreMaxHp' => StatId.coreMaxHp,
        'coreRegen' => StatId.coreRegen,
        'abilityCooldown' => StatId.abilityCooldown,
        _ => throw ArgumentError('StatId: bilinmeyen stat adi: "$name"'),
      };
}

/// Sabit boyutlu stat deposu.
///
/// Neden `Float64List` ve neden `Map<StatId, double>` degil: bu deger
/// savas sicak yolunda (her kare, her birlik, her vurus) okunur.
/// `Map` her erisimde hash hesabi ve olasi allocation getirir; `Float64List`
/// ise sabit boyutlu, index'li, GC baskisi olmayan duz bir bellek bloguDur.
class StatBlock {
  StatBlock() : _values = Float64List(StatId.values.length);

  StatBlock._fromValues(this._values);

  final Float64List _values;

  double operator [](StatId id) => _values[id.index];

  void operator []=(StatId id, double value) {
    _values[id.index] = value;
  }

  /// Bagimsiz bir kopya dondurur (kaynak degistiginde kopya etkilenmez).
  StatBlock copy() => StatBlock._fromValues(Float64List.fromList(_values));

  /// Tum slotlari sifirlar (yeniden kullanim icin, ornegin havuzdan cikan
  /// bir kayit).
  void reset() {
    _values.fillRange(0, _values.length, 0);
  }
}
