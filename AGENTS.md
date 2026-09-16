# RIFTWARDEN — Arayuz/asset agent sozlesmesi

Bu dosya Sonnet UI worker'ina ve Codex gorsel-uretim agent'ina uygulanir.
Landscape-only (yatay) iOS/Android oyunu. Flutter + Flame. Paket adi `riftwarden`.

Oyun: boyut yariklarindan gelen dusman surulerini, otomatik savasan bir orduyla
durduran auto-battle / swarm defense oyunu. Sicak, elle cizilmis 2D cizgi film
dunyasi; kucuk savunucular dogaclama kurulmus kadim bir kaleyi tuhaf boyutsal
yaratiklardan korur. Tek gorsel otorite: `docs/DESIGN.md`; is sirasi:
`docs/UI_MIGRATION_PLAN.md`.

---

## Dokunabilecegin dosyalar

**SADECE bunlar:**
```
lib/app/theme/          renk, olcu, tipografi, tema token'lari
lib/shared/widgets/     ekranlar arasi ortak bilesenler
lib/features/*/view/    ekran sayfalari
lib/features/*/widgets/ ekrana ozel bilesenler
```

**Kesinlikle dokunma** — bunlar baska bir worker'in:
```
lib/engine/  lib/domain/  lib/content/  lib/data/  lib/core/
lib/features/*/viewmodel/   assets/content/
pubspec.yaml   analysis_options.yaml   l10n.yaml   android/   ios/
```

Paket EKLEME. Gereken her sey zaten kurulu.
Test YAZMA.

**git komutu calistirma** (add/commit/reset/stash/checkout); kalite kapilari
CLAUDE.md'deki gibi calistirilir.

Brief'te adi gecmeyen dosyaya dokunma. Gerekiyorsa raporunda "sapma" olarak bildir.
Task prompt'undaki dosya listesi bu listeden onceliklidir.

---

## Arayuz kurallari (BAGLAYICI)

Bunlari ihlal eden kod, calissa bile reddedilir. Otomatik denetleniyor:
`python tools/ui_lint.py`

1. **Ham renk yasak.** `Color(0xFF...)` yazma. Her renk `AppColors`'tan
   (`lib/app/theme/app_colors.dart`).
2. **Ham olcu yasak.** `EdgeInsets.all(13)`, `SizedBox(height: 17)` yazma.
   `AppSpacing` / `AppRadius` kullan (`lib/app/theme/app_spacing.dart`).
3. **Elde TextStyle yasak.** `fontSize:` doğrudan verme. `AppTypography`'den al
   (`lib/app/theme/app_typography.dart`).
4. **Metin literali yasak.** Kullaniciya gorunen her metin
   `AppLocalizations.of(context)` uzerinden gelir.

   Yeni metin gerekiyorsa **`lib/l10n/arb/app_en.arb`** dosyasina ekle:
   anahtar + Ingilizce deger + `"@anahtar": {"description": "..."}` aciklamasi.
   Turkce metin `tools/l10n_sync.py` icindeki `TR_OVERRIDES` tablosuna eklenir.
   Ayni gorev icinde `python tools/l10n_sync.py` ve `flutter gen-l10n` calistir.

   Raporunda eklediğin anahtarlari listele.
5. **RTL.** `EdgeInsets.only(left:/right:)` yerine
   `EdgeInsetsDirectional.only(start:/end:)`. `Alignment.centerLeft` yerine
   `AlignmentDirectional.centerStart`. Arapca destekleniyor.
6. **Safe area.** Tam ekran sayfalar `SafeArea` icinde. Arka plan gradyani
   `SafeArea`'nin DISINDA kalir (centigin altina uzansin), butonlar icinde.
7. **Dokunma hedefi** `AppSpacing.minTouchTarget` (48 dp) altina inmez.
8. **Savas HUD'unda Riverpod yok.** `lib/features/battle/` icinde `ref.watch` /
   `ref.read` kullanma — savas verisi `BattleSignals`'tan `ValueListenableBuilder`
   ile okunur (`lib/engine/bridge/battle_signals.dart`). 60 fps'te widget agacini
   yeniden kurmak kare suresini catlatir.
9. **Bilesenler veri-bagimsiz.** `lib/shared/widgets/` icindeki her sey stateless
   olmali ve parametre almalidir; provider okumamalidir. Veri baglantisini baska
   bir worker sonradan yapacak.

---

## Ekran duzeni kisitlari

- **Sadece yatay.** Dikey duzen tasarlama. Iki yatay yon de (sola/saga donuk) desteklenir.
  Tek istisna: `lib/features/orientation_gate/` ekrani acilista dikey gorunur; hem dikey
  (360x640) hem yatay (640x360) dogru cizilmelidir.
- Hedef en dar ekran: **640 x 360 dp yatay**. Bu boyutta tasma olmamali.
- Savas HUD'u savas alanini kapatmamali: alt serit ekran yuksekliginin
  **%20'sini gecmesin**.
- Yatay centik icin `MediaQuery.viewPadding.left/right` uygulanmali.
- Ekranlarin public constructor imzalari degistirilmez (boot ekrani onlara bagli).
- Modern App Store / Google Play oyun kalitesi hedefleniyor. Ucuz hyper-casual
  gorunumden kacin, ama gameplay arayuzunu sade tut — oyuncuya sadece gerekli
  bilgi gosterilsin.

---

## Calisma bicimi

1. Brief'i oku (`docs/ui_briefs/<gorev>.md`). Dokunulacak dosyalar orada listeli.
2. Once `lib/app/theme/` icindeki mevcut token'lari oku — hangi renk/olcu var gor.
   Mevcut token'lari **degistirme**, gerekiyorsa yenisini ekle.
3. Kodu yaz.
4. Raporunu ver.

## Rapor formati

Rapor formati icin `CLAUDE.md` -> "Rapor formati (degistirilemez)" bolumune bak.
Ayrica "### Gereken l10n anahtarlari" basligi altinda eklenen anahtarlari listele.

Ozet paragrafi, "iste yaptiklarim" anlatimi, secenek tartismasi yazma.

---

## Kod stili

- Cevredeki koda uy. Ornek icin `lib/features/boot/view/boot_screen.dart` ve
  `lib/app/theme/*.dart` dosyalarina bak.
- Yorumlar **Turkce ve ASCII** (s/g/i/o/u — sapkali karakter kullanma).
  Yorum **neden**i anlatsin, ne oldugunu degil.
- `const` kullanabildigin her yerde kullan (lint zorunlu tutuyor).
- Sondaki virgul zorunlu (`require_trailing_commas`).
- Tek tirnak (`prefer_single_quotes`).
