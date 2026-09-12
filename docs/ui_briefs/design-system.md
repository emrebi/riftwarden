# GOREV: TASARIM SISTEMI

Once `AGENTS.md` dosyasini oku. Oradaki arayuz kurallari baglayicidir.

## Amac

RIFTWARDEN'in tum ekranlarinda kullanilacak ortak bilesen kutuphanesini kur.
Ekranlar henuz yok; bu gorev ekranlardan **bagimsiz** temeli atiyor. Ekranlar
sonraki gorevlerde bu bilesenleri kullanarak kurulacak.

Kalite hedefi: modern App Store / Google Play oyunu. Ucuz hyper-casual gorunum
degil; ama gosterisli de degil -- oyun icinde okunabilirlik her seyden onemli.

## Mevcut durum: once bunlari oku

```
lib/app/theme/app_colors.dart       AppColors
lib/app/theme/app_spacing.dart      AppSpacing, AppRadius, AppDuration
lib/app/theme/app_typography.dart   AppFonts, AppTypography
lib/app/theme/app_theme.dart        AppTheme.build(Locale)
lib/features/boot/view/boot_screen.dart   kod stili ornegi
```

Mevcut token'lari **DEGISTIRME**. Ihtiyacin olan yeni token'i ekle (ornegin
gradient, golge, kenarlik tanimlari). Var olan bir rengin degerini veya adini
degistirirsen baska yerler bozulur.

## Yapilacaklar

### 1. `lib/app/theme/app_decorations.dart` (YENI)

Tekrar eden gorsel dokular icin token'lar. En az sunlar:
- `AppGradients.screenBackground` -- sayfa arka plani (radyal, void tonlari)
- `AppGradients.panel` -- panel yuzeyi
- `AppGradients.primaryButton` / `dangerButton`
- `AppShadows.glow(Color)` -- enerji parlamasi (savas alani disi da kullanilir)
- `AppShadows.panel` -- yukseltilmis yuzey golgesi
- `AppBorders.subtle` / `AppBorders.accent(Color)`

Hepsi `AppColors` ve `AppRadius` uzerinden kurulmali; ham deger yok.

### 2. `lib/shared/widgets/` bilesenleri

Her biri **stateless** ve **veri-bagimsiz**: parametre alir, provider okumaz,
`AppLocalizations` cagirmaz (metin disaridan `String` olarak gelir). Veri
baglantisini baska bir worker sonradan yapacak; bu yuzden bunlarin hicbiri
sonradan degismemeli.

| Dosya | Bilesen | Notlar |
|---|---|---|
| `rw_screen_scaffold.dart` | `RwScreenScaffold` | Tum sayfalarin tabani. Arka plan gradyani `SafeArea`'nin DISINDA (centigin altina uzansin), icerik icinde. Istege bagli baslik + geri butonu. |
| `rw_button.dart` | `RwButton` | `RwButtonVariant` enum: primary / secondary / ghost / danger. Basili tutunca hafif kuculme animasyonu. `onPressed: null` iken pasif gorunum. Yukseklik >= `AppSpacing.minTouchTarget`. |
| `rw_icon_button.dart` | `RwIconButton` | Pause, ayar, kapat icin. Dairesel, >= 48 dp. |
| `rw_panel.dart` | `RwPanel` | Yukseltilmis yuzey. Istege bagli baslik seridi. |
| `rw_card.dart` | `RwCard` | Upgrade kartlari icin. `rarity` parametresi alir (String) ve kenarlik rengini `AppColors.rarity(rarity)` ile belirler. Legendary'de hafif parlama. |
| `rw_currency_chip.dart` | `RwCurrencyChip` | Aether / Shard / Cell gostergesi. `RwCurrency` enum + miktar. Ikon yerine simdilik renkli bir sekil kullan (sprite'lar henuz yok). Rakamlar `AppTypography.numeric` (tabular) -- deger degisince yazi ziplamasin. |
| `rw_progress_bar.dart` | `RwProgressBar` | Core HP / wave / boss HP. 0..1 arasi `value`, renk parametresi, istege bagli "hasar izi" (gecikmeli ikinci dolgu). |
| `rw_dialog.dart` | `RwDialog` | Onay / hata / satin alma. Baslik, govde, 1-2 aksiyon butonu. |
| `rw_section_header.dart` | `RwSectionHeader` | Ayarlar ve magazada grup basligi. |

### 3. `lib/features/boot/view/widget_gallery.dart` (YENI, GECICI)

Tum bilesenleri tek sayfada gosteren kaydirilabilir galeri. Amac: `flutter run`
ile acip gozle kontrol edebilmek. Her bilesenin her varyantini goster
(butonun 4 varyanti + pasif hali, kartin 4 rarity'si, progress bar'in dolu/bos
halleri vb.).

Dosyanin basina su yorumu koy:
`// GECICI: gorsel kontrol galerisi. Ekranlar tamamlaninca silinecek (M5).`

Bu dosya galeri oldugu icin **metin literali kullanabilir** (bilesen adlari,
ornek degerler). Diger tum dosyalarda metin literali yasak.

### 4. `lib/features/boot/view/boot_screen.dart` (DEGISTIR)

Mevcut basligin altina, galeriyi acan bir `RwButton` ekle. Buton metni icin
mevcut l10n anahtarlarindan uygun olani kullan; yoksa galeri gecici oldugu icin
bu tek yerde literal serbest.

## Dokunulacak dosyalarin tam listesi

```
YENI:  lib/app/theme/app_decorations.dart
YENI:  lib/shared/widgets/rw_screen_scaffold.dart
YENI:  lib/shared/widgets/rw_button.dart
YENI:  lib/shared/widgets/rw_icon_button.dart
YENI:  lib/shared/widgets/rw_panel.dart
YENI:  lib/shared/widgets/rw_card.dart
YENI:  lib/shared/widgets/rw_currency_chip.dart
YENI:  lib/shared/widgets/rw_progress_bar.dart
YENI:  lib/shared/widgets/rw_dialog.dart
YENI:  lib/shared/widgets/rw_section_header.dart
YENI:  lib/features/boot/view/widget_gallery.dart
DEGIS: lib/features/boot/view/boot_screen.dart
```

Baska hicbir dosyaya dokunma.

## Kabul kriterleri

**Bu komutlari SEN calistirmayacaksin** -- terminal kullanma. Planner isin
bitince kendisi kosturacak. Sen sadece bunlardan gececek kodu yaz:

```
flutter analyze          # 0 issue olmali
python tools/ui_lint.py  # TEMIZ olmali
```

`analysis_options.yaml` siki: `prefer_const_constructors`,
`require_trailing_commas`, `always_declare_return_types`, `prefer_single_quotes`,
`prefer_final_locals`, `strict-casts` acik.

360 x 640 dp ekranda galeri tasmadan kaydirilabilmeli.

## Rapor

`AGENTS.md`'deki rapor formatini kullan. Yeni l10n anahtari gerekirse
ARB dosyalarini duzenleme, sadece raporda bildir.
