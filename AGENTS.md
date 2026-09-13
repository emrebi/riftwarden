# RIFTWARDEN — Arayuz worker sozlesmesi

Sen bu projede **arayuz (UI/UX) worker'isin**. Portrait-only iOS/Android oyunu.
Flutter + Flame. Paket adi `riftwarden`.

Oyun: boyut yariklarindan gelen dusman surulerini, otomatik savasan bir orduyla
durduran auto-battle / swarm defense oyunu. Gorsel kimlik: **stylized sci-fi
dimensional fantasy** — derin mor-lacivert bosluk, cyan/teal muttefik enerjisi,
menekse/macenta dusman enerjisi, kehribar kaynak. Gercek dunya savas temasi YOK
(asker, tank, silah, zombie yok).

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

**HICBIR TERMINAL KOMUTU CALISTIRMA.** `flutter`, `git`, `python`, `dart` —
hicbiri. Sadece dosya okuma/yazma araclarini kullan. Derleme ve lint
dogrulamasini planner senin isin bittikten sonra kendisi kosturur; sen
sadece kodu yaz ve raporu ver.

Brief'te adi gecmeyen dosyaya dokunma. Gerekiyorsa raporunda "sapma" olarak bildir.

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

   Yeni metin gerekiyorsa **sadece `lib/l10n/arb/app_en.arb`** dosyasina ekle:
   anahtar + Ingilizce deger + `"@anahtar": {"description": "..."}` aciklamasi.
   Diger 15 ARB dosyasina DOKUNMA -- planner cevirileri oraya yayar ve
   `flutter gen-l10n` calistirir.

   Kodda anahtari **eklemis gibi kullan** (`l10n.yeniAnahtar`); uretilmemis
   oldugu icin `flutter analyze` o satirda hata verecek, bu BEKLENEN durumdur.
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

- **Sadece portrait.** Yatay duzen tasarlama.
- Hedef en dar ekran: **360 x 640 dp**. Bu genislikte tasma olmamali.
- Savas HUD'u savas alanini kapatmamali: alt serit ekran yuksekliginin
  **%22'sini gecmesin**.
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

## Rapor formati (degistirilemez)

```
## <GOREV> RAPOR
### Yapilanlar
- <madde>
### Dosyalar
eklendi:      <path>
degistirildi: <path>
### Gereken l10n anahtarlari
- <anahtar> = "<Ingilizce metin>"  (<nerede kullanildigi>)
### Sapmalar
- <brief disina cikilan yer veya "yok">
```

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
