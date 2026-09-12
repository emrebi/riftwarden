import 'dart:typed_data';

/// Havuzlanabilir varlik.
///
/// Savas sirasinda ASLA `new` ile uretilmez. Havuz acilista sabit sayida
/// nesne yaratir, `spawn()` bunlardan birini [reset] edip verir.
abstract class PooledEntity {
  /// Kararli kimlik. Havuzdaki dizin degisir, bu degismez.
  /// Hedefleme, referansi bu id uzerinden dogrular.
  int id = 0;

  /// Bu adimin sonunda havuzdan cikarilacagini isaretler.
  ///
  /// Sistemler iterasyon sirasinda varlik SILMEZ; sadece bu bayragi
  /// kaldirir. Gercek cikarma adim sonunda [EntityPool.compact] ile olur.
  /// Bu kural olmadan hem iterasyon hem spatial grid dizinleri bozulur.
  bool pendingRemove = false;

  /// Havuzdan verilmeden once cagrilir. Tum alanlar varsayilana donmeli.
  void reset();
}

/// Sabit kapasiteli, yogun (dense) varlik havuzu.
///
/// ## Neden boyle
/// `[0, activeCount)` araligindaki tum slotlar canlidir; iterasyon dalsiz
/// ve cache-dostu tek dongudur. Cikarma "swap-remove"dur: son canli eleman
/// bosalan yere tasinir.
///
/// ## Dikkat: dizinler kararsizdir
/// Swap-remove yuzunden bir varligin dizini degisebilir. Bu yuzden
/// varliklar arasi referans **dizinle degil [PooledEntity.id] ile** tutulur
/// ve kullanmadan once `pool[idx].id == hedefId` diye dogrulanir.
/// Spatial grid dizin tutar ama her adimda yeniden kuruldugu ve ayni adim
/// icinde kullanildigi icin gecerlidir (cikarmalar adim sonunda olur).
class EntityPool<T extends PooledEntity> {
  EntityPool(this.capacity, T Function() create)
      : _items = List<T>.generate(capacity, (_) => create(), growable: false),
        _removeQueue = Int32List(capacity);

  /// Sabit kapasite. Savas basinda level config'den gelir.
  final int capacity;

  final List<T> _items;
  final Int32List _removeQueue;

  int _activeCount = 0;
  int _nextId = 1;

  /// Canli varlik sayisi. Iterasyon siniri.
  int get activeCount => _activeCount;

  /// Havuz doluysa true. Doluyken [spawn] null doner.
  bool get isFull => _activeCount >= capacity;

  /// Canli varliga dizinle erisim. `0 <= index < activeCount` olmali.
  T operator [](int index) => _items[index];

  /// Havuzdan bir varlik alir, [PooledEntity.reset] eder ve kimlik atar.
  ///
  /// Havuz doluysa **null** doner — bu bir hata degil, tasarlanmis
  /// davranistir: swarm tavana vurdugunda spawn sessizce atlanir,
  /// kare suresi patlamaz.
  T? spawn() {
    if (_activeCount >= capacity) return null;
    final entity = _items[_activeCount++];
    entity
      ..reset()
      ..id = _nextId++
      ..pendingRemove = false;
    return entity;
  }

  /// Adim sonunda cagrilir: `pendingRemove` isaretli varliklari cikarir.
  ///
  /// Sondan basa taranir; boylece swap ile one tasinan eleman tekrar
  /// incelenmez ve tek gecis yeterlidir.
  /// [onRemoved] cikarilan varlik icin, henuz slot yeniden kullanilmadan
  /// cagrilir (olum efekti, odul verme vb.).
  int compact([void Function(T entity)? onRemoved]) {
    var removed = 0;
    for (var i = _activeCount - 1; i >= 0; i--) {
      final entity = _items[i];
      if (!entity.pendingRemove) continue;

      onRemoved?.call(entity);
      _removeQueue[removed++] = entity.id;

      final last = _activeCount - 1;
      if (i != last) {
        _items[i] = _items[last];
        _items[last] = entity;
      }
      _activeCount = last;
    }
    return removed;
  }

  /// [compact] sirasinda cikarilan varliklarin kimlikleri.
  /// Sadece o cagriya kadar gecerlidir; kopyalanmadan saklanmamali.
  Int32List get lastRemovedIds => _removeQueue;

  /// Tum varliklari havuza iade eder. Savas baslangicinda cagrilir.
  void clear() {
    _activeCount = 0;
    _nextId = 1;
  }

  /// Verilen kimlige sahip canli varligin dizinini bulur, yoksa -1.
  ///
  /// O(n)'dir; **sicak yolda kullanilmamalidir**. Hedefleme bunun yerine
  /// "son bilinen dizini dogrula, tutmuyorsa yeniden hedef ara" yapar.
  int indexOfId(int id) {
    for (var i = 0; i < _activeCount; i++) {
      if (_items[i].id == id) return i;
    }
    return -1;
  }
}
