# RIFTWARDEN — Ortak agent sozlesmesi

> `CLAUDE.md` ve `AGENTS.md` BIREBIR AYNI dosyadir (Claude Code `CLAUDE.md`,
> Codex `AGENTS.md` okur). Birini degistiren digerine de ayni icerigi yazar.

Landscape-only (yatay) iOS/Android oyunu. Tur: auto-battle + swarm defense + roguelite upgrade.
Flutter + Flame. Paket adi `riftwarden`, bundle id `com.riftwarden.game`.

Oyun: boyut yariklarindan gelen dusman surulerini, otomatik savasan bir orduyla
durduran auto-battle / swarm defense oyunu. Sicak, elle cizilmis 2D cizgi film
dunyasi; kucuk savunucular dogaclama kurulmus kadim bir kaleyi tuhaf boyutsal
yaratiklardan korur.

| Dokuman | Icerik |
|---|---|
| `docs/ARCHITECTURE.md` | Mimari planin tamami |
| `docs/DESIGN.md` | Tek gorsel otorite |
| `docs/UI_MIGRATION_PLAN.md` | UI gecis plani, gorev tanimlari, §0 ilerleme tablosu ve commit gruplari |
| `docs/KNOWN_GAPS.md` | Bilerek ertelenmis isler |
| `docs/CONTENT_MAP.md` | "Hangi is icin hangi dosya" indeksi |
| `docs/ASSET_PROMPTS.md` | Gorsel uretim prompt'lari |

---

## Calisma protokolu

Proje donusumlu olarak **Claude Code** ve **Codex** ile yurutulur. Hangi arac
kullanilirsa kullanilsin roller ve kurallar aynidir.

| Rol | Tipik model | Gorev |
|---|---|---|
| Planner / reviewer | Opus (veya Codex planner oturumu) | Siradaki gorevi secer, brief yazar, diff'i denetler, kapilari yeniden kosar, commit atar/onerir |
| Worker | Sonnet 5 (veya Codex worker oturumu) | Tek gorevi uygular (UI dahil), rapor birakir |
| Asset | Web ChatGPT gorsel uretimi | Sprite/ikon uretir, `tools/assetkit` ile islenir (bkz. `docs/ASSET_PROMPTS.md`) |

Yeni bir oturum (Claude veya Codex) ise baslarken: `git log --oneline -5` + `git status`,
sonra `docs/UI_MIGRATION_PLAN.md` §0 ilerleme tablosundaki siradaki READY gorev.

### Worker kurallari (BAGLAYICI)
1. **Test yazma** (gorev tanimi acikca izin vermedikce). **`flutter run` deneme. Emulator acma.** Manuel dogrulamayi kullanici yapar.
2. Tek kalite kapisi: `flutter analyze` -> **0 issue**. Gecmeden rapor verme.
3. UI dosyasi degistiyse ek kapilar: `python tools/ui_lint.py` -> TEMIZ, `flutter test test/ui_smoke_test.dart` -> PASS.
4. Icerik JSON'u degistiyse ek kapi: `flutter test test/content_validation_test.dart`.
5. Brief'te listelenmeyen dosyaya dokunma. Gerekti ise raporda "Sapmalar" altinda bildir.
6. **git komutu calistirma** (add/commit/reset/stash/checkout/restore). Agacta onayli ama
   commit edilmemis baska degisiklik olabilir; onlara dokunma.
7. Paket EKLEME. Gereken her sey zaten kurulu.
8. Ozet paragraf, aciklama metni, "iste yaptiklarim" anlatimi yazma. Sadece asagidaki rapor.

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
UI gorevlerinde `Kapilar` altina `ui_lint` ve `smoke` satirlari da eklenir.
Yeni l10n anahtari eklendiyse `### Gereken l10n anahtarlari` basligi altinda listelenir.

### Token ekonomisi (BAGLAYICI)
1. Her tur tek gorev. Worker her yeni gorevde temiz sohbetle baslar; duzeltme turunda ayni sohbette kalir.
2. Worker prompt'u kendi icinde yeterlidir: sadece gereken dosyalari okutur, plani bastan anlatmaz.
3. Planner tum dosyalari degil `git diff`'i ve hedefli kontrolleri okur; worker'in PASS iddiasini kapilari yeniden kosarak dogrular.
4. Kozmetik dokuman eksikleri ayri tur acmaz; bir sonraki dokuman gorevine eklenir.
5. "Bu is hangi dosyada" icin repo taranmaz; once `docs/CONTENT_MAP.md` okunur.

### Commit protokolu (BAGLAYICI)
Genel sira:

1. Worker raporu gelir, kalite kapilari gecmis olur.
2. Planner raporu ve `git diff`'i denetler, kapilari kendisi yeniden kosar.
3. Planner kullaniciya **manuel kontrol listesi** verir (cihazda neye bakilacak).
4. Planner **commit basligini** onerir.
5. Kullanici manuel kontrolu yapar ve onay verir.
6. Ancak o zaman commit atilir, sonraki adima gecilir.

UI gecisinde gecerli istisna (kullanici karari, ayrintisi `docs/UI_MIGRATION_PLAN.md` §0):
gorevler tek tek denetlenir ama commit'ler **gruplar halinde** (C1, C2, ...) atilir;
planner grubu kendisi commitler, ilerleme tablosunu ayni commit'te gunceller ve
**grup bitince durur**.

Commit mesaji: Turkce, tek satir, duz, ne yapildigini soyler. Ornek:
`simulasyon cekirdegi ve entity havuzu eklendi`

---

## Dosya kapsami

UI gorevlerinde varsayilan olarak dokunulabilir:
```
lib/app/theme/          renk, olcu, tipografi, tema token'lari
lib/shared/widgets/     ekranlar arasi ortak bilesenler
lib/features/*/view/    ekran sayfalari
lib/features/*/widgets/ ekrana ozel bilesenler
lib/features/boot/view/widget_gallery.dart   gorsel QA galerisi
```

UI gorevlerinde varsayilan olarak dokunulmaz:
```
lib/engine/  lib/domain/  lib/content/  lib/data/  lib/core/
lib/features/*/viewmodel/   assets/content/
pubspec.yaml   analysis_options.yaml   l10n.yaml   android/   ios/
```

**Task prompt'undaki dosya listesi bu listelerden onceliklidir.**

---

## Degismez mimari kurallar

Bunlari ihlal eden bir degisiklik, calissa bile reddedilir.

1. **`domain/` Flutter bilmez.** `package:flutter/*` import'u yasak. Saf Dart.
2. **`engine/` widget bilmez.** `features/` import'u yasak. Sadece `domain/` ve `content/`.
3. **Riverpod savas dongusune girmez.** Savas state'i duz Dart'tir; HUD'a
   `engine/bridge/battle_signals.dart` uzerinden `ValueNotifier` ile akar.
   `lib/features/battle/` icinde `ref.read` / `ref.watch` yok; savas verisi
   `ValueListenableBuilder` ile okunur (60 fps'te agaci yeniden kurmak kare suresini catlatir).
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

## Arayuz kurallari (BAGLAYICI)

Otomatik denetlenir: `python tools/ui_lint.py`

1. **Ham renk yasak.** `Color(0xFF...)` / `Colors.*` yazma. Her renk `AppColors`'tan
   (`lib/app/theme/app_colors.dart`); malzeme renkleri `AppMaterials` (`app_decorations.dart`).
2. **Ham olcu yasak.** `EdgeInsets.all(13)`, `SizedBox(height: 17)` yazma.
   `AppSpacing` / `AppRadius` / `AppDuration` kullan (`lib/app/theme/app_spacing.dart`).
   Bilesene ozel sabit olcu gerekiyorsa dosyada tek yerde `static const` olarak tanimla.
3. **Elde TextStyle yasak.** `fontSize:` dogrudan verme. `AppTypography`'den al
   (`screenTitle`, `sectionTitle`, `button`, `smallLabel`, `numeric`, `onMaterial`).
4. **Metin literali yasak.** Kullaniciya gorunen her metin
   `AppLocalizations.of(context)` uzerinden gelir.
   Yeni metin: **`lib/l10n/arb/app_en.arb`** dosyasina anahtar + Ingilizce deger +
   `"@anahtar": {"description": "..."}`. Turkce metin `tools/l10n_sync.py` icindeki
   `TR_OVERRIDES` tablosuna. Ayni gorevde `python tools/l10n_sync.py` ve `flutter gen-l10n` calistir.
   Sayi/para/sure bicimi `lib/shared/format/rw_number_format.dart` ile (Arapca rakamlar).
5. **RTL.** `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`. Arapca destekleniyor.
6. **Safe area.** Tam ekran sayfalar `SafeArea` icinde. Arka plan `SafeArea`'nin
   DISINDA kalir (centigin altina uzansin), butonlar icinde.
7. **Dokunma hedefi** `AppSpacing.minTouchTarget` (48 dp) altina inmez.
8. **Bilesenler veri-bagimsiz.** `lib/shared/widgets/` icindeki her sey parametre alir,
   provider okumaz. Yerel state sadece gorsel durum icin (basili, animasyon) kullanilir.
9. **Tek bilesen kutuphanesi.** Yeni gorunum mevcut `Rw*` bilesenleri ve
   `RwMaterialSurface` uzerine kurulur; paralel tema/bilesen seti yazilmaz.
   Neon/glow token'lari kaldirildi; `tools/ui_lint.py` yeniden eklenmesini engeller.
10. **Durum sadece renkle anlatilmaz.** Secili/kilitli/pasif durumlar ikon, derinlik
    veya sekil ile de ayrisir (DESIGN §24).
11. Bilesen ekleyen/degistiren gorev galeriyi (`widget_gallery.dart`) ve
    `docs/CONTENT_MAP.md` satirini ayni gorevde gunceller.

---

## Ekran duzeni kisitlari

- **Sadece yatay.** Dikey duzen tasarlama. Iki yatay yon de desteklenir.
  Tek istisna: `lib/features/orientation_gate/` acilista dikey gorunur; hem dikey
  (360x640) hem yatay (640x360) dogru cizilmelidir.
- Hedef en dar ekran: **640 x 360 dp yatay**. Bu boyutta tasma olmamali.
- Savas HUD'u savas alanini kapatmamali: alt serit ekran yuksekliginin **%20'sini gecmesin**.
- Yatay centik icin `MediaQuery.viewPadding.left/right` uygulanmali.
- Ekranlarin ve ortak bilesenlerin public constructor imzalari degistirilmez;
  yeni parametreler yalniz opsiyonel eklenir.
- Modern App Store / Google Play oyun kalitesi hedefleniyor. Ucuz hyper-casual
  gorunumden kacin, ama gameplay arayuzunu sade tut.

---

## Kod stili

- Cevredeki koda uy. Ornek: `lib/shared/widgets/rw_button.dart`, `lib/app/theme/*.dart`.
- Yorumlar **Turkce ve ASCII** (s/g/i/o/u — sapkali karakter kullanma).
  Yorum **neden**i anlatsin, ne oldugunu degil.
- `const` kullanabildigin her yerde kullan (lint zorunlu tutuyor).
- Sondaki virgul zorunlu (`require_trailing_commas`).
- Tek tirnak (`prefer_single_quotes`).

---

## Komutlar

```bash
flutter analyze                                   # kalite kapisi
python tools/ui_lint.py                           # arayuz kurallari
flutter test test/ui_smoke_test.dart              # UI smoke
flutter test                                      # tum testler
flutter gen-l10n                                  # ARB degisince
python tools/l10n_sync.py                         # yeni en anahtarlarini diger locale'lere yayar
flutter test test/content_validation_test.dart    # icerik JSON degisince
flutter run --release                             # kullanici calistirir, worker degil

python tools/assetkit/assetkit.py ingest <zip> --recipe <ad>
python tools/assetkit/assetkit.py pack --group <ad>
python tools/assetkit/assetkit.py verify
```

---

## Dikkat edilecek tuzaklar

- **`Stack`'in tum cocuklari `Positioned*` ise `fit: StackFit.expand` olmadan
  `0x0`'a coker.** Ekran sessizce bos gorunur, hata firlamaz.
- **Release'de R8, reflection ile bulunan `androidx.work`/`Room` siniflarini siler.**
  Keep kurallari `android/app/proguard-rules.pro` icinde, silinmemeli.
- **Motor koordinati izotropiktir:** y 0..1, x 0..`kFieldAspect` (16/9).
  JSON'daki x yine 0..1 yazilir, motor kurulumunda `kFieldAspect` ile carpilir.
- **`Override` tipi Riverpod 3'te public degil.** `ProviderScope(overrides: [...])`
  listesine acik tip argumani yazma; cikarima birak.
- **`pt_BR` icin `app_pt.arb` sart.** gen-l10n script/country kodlu locale'lerde
  taban locale ister. Yeni bolgesel locale eklerken tabanini da ekle.
- **Havuz dolunca `spawn()` null doner.** Bu hata degil, tasarim. Null kontrolu
  yap ve sessizce atla; exception firlatma.
- **Fontlar:** RwDisplay (Lilita One, sadece Latin), govde Nunito; Arapca/Thai Noto bundle; CJK bilincli olarak sistem fontu (boyut). Kaynak/lisans: design/art_intake/FONT-01/SOURCES.md, assets/fonts/LICENSES/.
- **Gorseller WebP.** Sprite/atlas lossless (lossy alfa kenarinda hale ve atlas
  sizmasi yapar); arka plan lossy q85. `ios/Runner/Assets.xcassets` PNG kalir.
- **UI smoke testinde `pumpAndSettle` kullanma.** Sonsuz animasyonlar var; sabit sureli `pump` yeterli.
- **Semantics:** tek etiketli kontrollerde (buton) `excludeSemantics: true` uygundur;
  icinde baska metin/buton tasiyan kapsayicilarda (kart, panel) KULLANMA — icerik
  ekran okuyucudan gizlenir.
- **`agy mcp disable` ISE YARAMIYOR.** Devre disi birakilan MCP sunucusuna yine de
  baglanmaya calisir ve her cagriyi **3 dakika** bloklar. Gercekten engellemek icin
  `agy mcp remove <ad>` gerekir. Bu projede `unity-mcp` kaldirildi. Unity gerekirse geri ekle:
  `agy mcp add unity-mcp -- "C:\Users\ASUS\.unity\relay\relay_win.exe" --mcp`
- **Reklam/IAP kimlikleri TEST kimlikleridir.** `AndroidManifest.xml`, `Info.plist`
  ve `AdConfig` icinde TODO ile isaretli. Yayin oncesi degistirilecek.
- **Yon kapisi:** uygulama acilista dikeyi de destekler (manifest `fullUser`,
  plist portrait+landscape); yataya kilidi `OrientationService` yapar. Manifest/plist'i
  tekrar landscape-only yapma — kapi dikeyde hic gorunmez olur.
- **Gorsel intake:** ChatGPT'den gelen zip `design/art_intake/<ART-ID>.zip` (gitignored)
  olarak kaydedilir, repo kokune konmaz.
