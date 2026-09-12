import 'dart:math' as math;
import 'dart:typed_data';

/// Yakinlik sorgulari icin duzgun (uniform) hucre izgarasi.
///
/// Flame'in carpisma sistemi bilerek KULLANILMAZ: yuzlerce dusmanla
/// component tabanli broadphase hem allocation hem update maliyeti getirir.
/// Bunun yerine her simulasyon adiminda bu izgara sifirdan kurulur.
///
/// ## Nasil calisir
/// Counting sort: once hucre basina eleman sayilir, sonra prefix-sum ile
/// her hucrenin baslangic ofseti bulunur, sonra elemanlar yerlestirilir.
/// Iki gecis, O(n), **kurulum sonrasi sifir allocation**.
///
/// ## Dizin gecerliligi
/// Izgara [EntityPool] dizinlerini saklar. Bu dizinler sadece kuruldugu
/// simulasyon adimi icinde gecerlidir. Varliklar adim SONUNDA cikarildigi
/// icin adim ortasinda dizinler kaymaz.
class SpatialHashGrid {
  SpatialHashGrid({
    required this.cellSize,
    required this.capacity,
    this.width = 1.0,
    this.height = 1.0,
  })  : cols = math.max(1, (width / cellSize).ceil()),
        rows = math.max(1, (height / cellSize).ceil()) {
    _cellStart = Int32List(cols * rows + 1);
    _cellCount = Int32List(cols * rows);
    _entries = Int32List(capacity);
    _entryX = Float32List(capacity);
    _entryY = Float32List(capacity);
  }

  /// Hucre kenar uzunlugu (normalize birim). En uzun menzilin ~2 kati olmali.
  final double cellSize;

  /// Izgaranin tutabilecegi maksimum eleman (= ilgili havuzun kapasitesi).
  final int capacity;

  final double width;
  final double height;
  final int cols;
  final int rows;

  late final Int32List _cellStart;
  late final Int32List _cellCount;
  late final Int32List _entries;
  late final Float32List _entryX;
  late final Float32List _entryY;

  int _count = 0;

  /// Izgarayi bosaltir. Her adimda doldurmadan once cagrilir.
  void clear() {
    _count = 0;
    _cellCount.fillRange(0, _cellCount.length, 0);
  }

  /// Kurulum 1. asama: eleman kaydet ve hucresini say.
  ///
  /// Havuzdaki TUM canli varliklar icin sirayla cagrilir, ardindan
  /// [build] gelir. Kapasite asilirsa fazlasi sessizce atilir.
  void add(int index, double x, double y) {
    if (_count >= capacity) return;
    final slot = _count++;
    _entries[slot] = index;
    _entryX[slot] = x;
    _entryY[slot] = y;
    _cellCount[_cellOf(x, y)]++;
  }

  /// Kurulum 2. asama: prefix-sum + yerlestirme.
  void build() {
    // Prefix sum -> her hucrenin baslangic ofseti.
    var running = 0;
    for (var c = 0; c < _cellCount.length; c++) {
      _cellStart[c] = running;
      running += _cellCount[c];
    }
    _cellStart[_cellCount.length] = running;

    // Yerlestirme sirasinda cursor olarak _cellCount'u yeniden kullaniyoruz.
    final cursor = _cellCount..fillRange(0, _cellCount.length, 0);

    // Gecici siralama tamponu yerine entries'i yerinde yeniden duzenlemek
    // icin ikinci bir gecis gerekir; basitlik ve hiz icin scratch kullaniyoruz.
    final sortedIndex = _sortedIndex ??= Int32List(capacity);
    final sortedX = _sortedX ??= Float32List(capacity);
    final sortedY = _sortedY ??= Float32List(capacity);

    for (var i = 0; i < _count; i++) {
      final cell = _cellOf(_entryX[i], _entryY[i]);
      final slot = _cellStart[cell] + cursor[cell]++;
      sortedIndex[slot] = _entries[i];
      sortedX[slot] = _entryX[i];
      sortedY[slot] = _entryY[i];
    }

    _entries.setRange(0, _count, sortedIndex);
    _entryX.setRange(0, _count, sortedX);
    _entryY.setRange(0, _count, sortedY);
  }

  Int32List? _sortedIndex;
  Float32List? _sortedX;
  Float32List? _sortedY;

  /// ([x], [y]) merkezli [radius] yaricapli daire icindeki elemanlarin
  /// havuz dizinlerini [out] icine yazar ve kac tane yazdigini doner.
  ///
  /// [out] cagiran tarafindan onceden ayrilir (scratch buffer) — bu yuzden
  /// sorgu **sifir allocation**dir. [out] dolarsa sonuc kirpilir; bu kabul
  /// edilebilir, cunku cok yogun bolgede fazladan aday zaten gereksizdir.
  int queryCircle(double x, double y, double radius, Int32List out) {
    final r2 = radius * radius;
    final minCol = _clampCol(((x - radius) / cellSize).floor());
    final maxCol = _clampCol(((x + radius) / cellSize).floor());
    final minRow = _clampRow(((y - radius) / cellSize).floor());
    final maxRow = _clampRow(((y + radius) / cellSize).floor());

    var found = 0;
    for (var row = minRow; row <= maxRow; row++) {
      final rowOffset = row * cols;
      for (var col = minCol; col <= maxCol; col++) {
        final cell = rowOffset + col;
        final start = _cellStart[cell];
        final end = _cellStart[cell + 1];
        for (var i = start; i < end; i++) {
          final dx = _entryX[i] - x;
          final dy = _entryY[i] - y;
          if (dx * dx + dy * dy > r2) continue;
          if (found >= out.length) return found;
          out[found++] = _entries[i];
        }
      }
    }
    return found;
  }

  /// Daire icindeki EN YAKIN elemanin havuz dizinini doner, yoksa -1.
  ///
  /// Hedefleme icin [queryCircle]'dan daha ucuzdur: liste doldurmaz,
  /// tek gecise en yakini secer.
  int queryNearest(double x, double y, double radius) {
    var bestDist = radius * radius;
    var best = -1;
    final minCol = _clampCol(((x - radius) / cellSize).floor());
    final maxCol = _clampCol(((x + radius) / cellSize).floor());
    final minRow = _clampRow(((y - radius) / cellSize).floor());
    final maxRow = _clampRow(((y + radius) / cellSize).floor());

    for (var row = minRow; row <= maxRow; row++) {
      final rowOffset = row * cols;
      for (var col = minCol; col <= maxCol; col++) {
        final cell = rowOffset + col;
        final start = _cellStart[cell];
        final end = _cellStart[cell + 1];
        for (var i = start; i < end; i++) {
          final dx = _entryX[i] - x;
          final dy = _entryY[i] - y;
          final d2 = dx * dx + dy * dy;
          if (d2 >= bestDist) continue;
          bestDist = d2;
          best = _entries[i];
        }
      }
    }
    return best;
  }

  int _cellOf(double x, double y) =>
      _clampRow((y / cellSize).floor()) * cols + _clampCol((x / cellSize).floor());

  int _clampCol(int c) => c < 0 ? 0 : (c >= cols ? cols - 1 : c);
  int _clampRow(int r) => r < 0 ? 0 : (r >= rows ? rows - 1 : r);
}
