# RIFTWARDEN

Portrait-only iOS/Android oyunu. Tur: auto-battle + swarm defense + roguelite upgrade.
Flutter + Flame. Paket adi `riftwarden`, bundle id `com.riftwarden.game`.

Mimari planin tamami: `docs/ARCHITECTURE.md`
"Hangi is icin hangi dosya" indeksi: `docs/CONTENT_MAP.md`

---

## Calisma protokolu

| Rol | Model | Gorev |
|---|---|---|
| Planner / reviewer | Opus medium | Task brief yazar, raporu okur, commit mesajini verir |
| Worker | Sonnet 5 | Implementasyon yapar, rapor birakir |
| UI tasarim | Gemini | Ekran tasarimlari uretir |
| Asset | Gemini web | Sprite/ikon uretir, `tools/assetkit` ile islenir |

### Worker kurallari (BAGLAYICI)
1. **Test yazma. `flutter run` deneme. Emulator acma.** Manuel dogrulamayi kullanici yapar.
2. Tek kalite kapisi: `flutter analyze` -> **0 issue**. Gecmeden rapor verme.
3. Icerik JSON'u degistiysen ek kapi: `flutter test test/content_validation_test.dart`.
4. Brief'te listelenmeyen dosyaya dokunma. Gerekti ise raporda "Sapmalar" altinda bildir.
5. Ozet paragraf, aciklama metni, "iste yaptiklarim" anlatimi yazma. Sadece asagidaki rapor.

### Rapor formati (degistirilemez)
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

### Commit protokolu (BAGLAYICI)
Her adim bittiginde **dur**. Sira:

1. Worker raporu gelir, kalite kapilari gecmis olur.
2. Planner raporu ve `git diff`'i denetler.
3. Planner kullaniciya **manuel kontrol listesi** verir (cihazda neye bakilacak).
4. Planner **commit basligini** onerir.
5. Kullanici manuel kontrolu yapar ve onay verir.
6. Ancak o zaman commit atilir, sonraki adima gecilir.

Onay alinmadan commit atilmaz ve sonraki adim baslatilmaz.

Commit mesaji: Turkce, tek satir, duz, ne yapildigini soyler. Ornek:
`simulasyon cekirdegi ve entity havuzu eklendi`

---

## Degismez mimari kurallar

Bunlari ihlal eden bir degisiklik, calissa bile reddedilir.

1. **`domain/` Flutter bilmez.** `package:flutter/*` import'u yasak. Saf Dart.
2. **`engine/` widget bilmez.** `features/` import'u yasak. Sadece `domain/` ve `content/`.
3. **Riverpod savas dongusune girmez.** Savas state'i duz Dart'tir; HUD'a
   `engine/bridge/battle_signals.dart` uzerinden `ValueNotifier` ile akar.
   Savas icinde `ref.read` / `ref.watch` gormek istemiyoruz.
4. **Savas sirasinda allocation yok.** Dusman/mermi/efekt `EntityPool`dan gelir.
   `step()` icinde `new`, liste/map olusturma, closure yaratma yapilmaz.
5. **Varliklar dizinle degil `id` ile referanslanir.** Havuz swap-remove yapar,
   dizinler kayar. Bkz. `engine/simulation/pools/entity_pool.dart`.
6. **Cikarma adim sonunda.** Sistemler `pendingRemove = true` isaretler;
   gercek cikarma `SystemPhase.compaction` fazinda olur.
7. **Sistem sirasi `SystemPhase` enum sirasidir.** Yeni sistem eklerken once
   hangi faza girdigine karar ver (`engine/simulation/battle_system.dart`).
8. **Icerik koda gomulmez.** Level, dusman, birlik, upgrade, boss, magaza
   `assets/content/*.json` icindedir. `switch (levelId)` yazma.
9. **Ekranlar ham deger kullanmaz.** Renk/olcu/tipografi `app/theme/` token'larindan.
10. **RTL.** `EdgeInsets.only(left:)` degil `EdgeInsetsDirectional.only(start:)`.
11. **Sadece iOS + Android.** `web/`, `windows/`, `linux/`, `macos/` yok, geri eklenmez.

---

## Komutlar

```bash
flutter analyze                                   # kalite kapisi
flutter gen-l10n                                  # ARB degisince
flutter test test/content_validation_test.dart    # icerik JSON degisince
flutter run --release                             # kullanici calistirir, worker degil

python tools/assetkit/assetkit.py ingest <zip> --recipe <ad>
python tools/assetkit/assetkit.py pack --group <ad>
python tools/assetkit/assetkit.py verify
```

---

## Dikkat edilecek tuzaklar

- **`Override` tipi Riverpod 3'te public degil.** `ProviderScope(overrides: [...])`
  listesine acik tip argumani yazma; cikarima birak.
- **`pt_BR` icin `app_pt.arb` sart.** gen-l10n script/country kodlu locale'lerde
  taban locale ister. Yeni bolgesel locale eklerken tabanini da ekle.
- **Havuz dolunca `spawn()` null doner.** Bu hata degil, tasarim. Null kontrolu
  yap ve sessizce atla; exception firlatma.
- **Fonts henuz bundle degil.** `AppFonts.bodyFamilyFor` null doner (sistem fontu).
  CJK/Tayca/Arapca fontlari M5'te eklenecek.
- **`agy mcp disable` ISE YARAMIYOR.** Devre disi birakilan MCP sunucusuna yine de
  baglanmaya calisir ve her cagriyi **3 dakika** bloklar. Gercekten engellemek icin
  `agy mcp remove <ad>` gerekir. Bu projede `unity-mcp` kaldirildi; cagri suresi
  206 sn'den 8 sn'ye dustu. Unity gerekirse geri ekle:
  `agy mcp add unity-mcp -- "C:\Users\ASUS\.unity\relay\relay_win.exe" --mcp`
- **Reklam/IAP kimlikleri TEST kimlikleridir.** `AndroidManifest.xml`, `Info.plist`
  ve `AdConfig` icinde TODO ile isaretli. Yayin oncesi degistirilecek.
