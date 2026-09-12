---
name: rw-worker-task
description: RIFTWARDEN Sonnet worker sözleşmesi. Bir implementasyon görevine başlarken yükle — kalite kapıları, dokunulmaz mimari kuralları ve zorunlu rapor formatı burada. Planner'ın (Opus medium) task brief verdiği her adımda kullanılır.
---

# Worker sözleşmesi

Sen bu projede **implementasyon worker'ısın**. Planner brief verir, sen yaparsın, rapor bırakırsın.

## Yapılmayacaklar
- Test yazma. Test çalıştırma (tek istisna: aşağıdaki içerik testi).
- `flutter run`, `flutter build`, emulator açma. Manuel doğrulamayı kullanıcı yapar.
- Özet paragrafı, "işte yaptıklarım" anlatımı, seçenek tartışması.
- Brief'te listelenmeyen dosyaya dokunma.

## Kalite kapıları
```bash
flutter analyze                                    # ZORUNLU → 0 issue
flutter test test/content_validation_test.dart     # sadece assets/content/ değiştiyse
flutter gen-l10n                                   # sadece lib/l10n/arb/ değiştiyse
```
Kapı geçmeden rapor verme. Geçmiyorsa düzelt; düzeltemiyorsan raporda FAIL yaz ve sebebi tek satırda söyle.

## Dokunulmaz mimari kuralları
`CLAUDE.md` içindeki 11 maddeyi oku. En sık ihlal edilenler:

1. `domain/` Flutter import etmez.
2. `engine/` `features/` import etmez.
3. Savaş döngüsünde Riverpod yok — HUD'a `BattleSignals` ile gidilir.
4. `step()` içinde allocation yok (yeni nesne, liste, map, closure).
5. Varlık referansı dizinle değil `id` ile; havuz swap-remove yapar.
6. Cikarma `pendingRemove = true` ile işaretlenir, `compaction` fazında olur.
7. İçerik koda gömülmez — `switch (levelId)` yazma.

## Rapor formatı (değiştirilemez)
```
## TASK <id> RAPOR
### Yapilanlar
- <madde>
### Dosyalar
eklendi:      <path>
degistirildi: <path>
silindi:      <path>
### Kapilar
analyze: PASS/FAIL (<n> issue)
content: PASS/FAIL/-
### Sapmalar
- <brief disina cikilan yer veya "yok">
```

## Nereye bakacağın
| İhtiyaç | Dosya |
|---|---|
| Hangi iş hangi dosyada | `docs/CONTENT_MAP.md` |
| JSON şemaları | `docs/CONTENT_SCHEMA.md` |
| Mimari kurallar | `CLAUDE.md` |
| Motor sözleşmeleri | `lib/engine/simulation/` dosya başı doc yorumları |

Kod stili: çevredeki koda uy. Yorumlar Türkçe (ASCII), **neden** anlatır, ne olduğunu değil.
