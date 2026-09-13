# GOREV: ANA MENU EKRANI

Once `AGENTS.md` dosyasini oku. Oradaki arayuz kurallari baglayicidir.

Tasarim sistemi onceki gorevde kuruldu ve calisiyor. Bu ekrani **sifirdan
bilesen yazarak degil, mevcut bilesenleri kullanarak** kur.

## Amac

Oyunun ilk izlenimi. Oyuncu uygulamayi acinca burayi gorur; App Store /
Google Play'de basarili bir mobil oyunun ana menusu kalitesinde olmali.

Iki sey ayni anda dogru olmali:
- **Atmosfer**: boyutlar arasi bosluk, enerji, gizem. Oyuncu daha oynamadan
  oyunun ne oldugunu hissetmeli.
- **Netlik**: PLAY butonu tartismasiz en baskin oge olmali. Oyuncu dusunmeden
  parmagini oraya goturmeli.

## Once oku

```
lib/shared/widgets/          kurdugun bilesenler -- hepsini yeniden kullan
lib/app/theme/               token'lar (AppColors, AppSpacing, AppDecorations, AppTypography)
lib/features/boot/view/boot_screen.dart    mevcut ekran orugu
lib/l10n/gen/app_localizations.dart        mevcut metin anahtarlari
```

## Ekran yerlesimi (portrait, 360x640 dp'de tasmasin)

```
┌─────────────────────────────┐
│  [Shard: 120]  [Cell: 5]    │  ust serit: para gostergeleri (RwCurrencyChip)
│                             │
│                             │
│        R I F T W A R D E N  │  logo alani -- ekranin gorsel agirlik merkezi
│         (alt baslik)        │
│                             │
│    ─────────────────────    │
│     SEKTOR 1  ·  LEVEL 3    │  ilerleme gostergesi
│     [████████░░░░░░░░]      │  RwProgressBar
│    ─────────────────────    │
│                             │
│    ┌───────────────────┐    │
│    │       PLAY        │    │  RwButton primary, buyuk, baskin
│    └───────────────────┘    │
│                             │
│   [STORE] [UPGRADES] [SET]  │  ikincil satir
│                             │
└─────────────────────────────┘
```

Bu bir kaba taslak, birebir uygulaman gerekmiyor. Oranlari ve bosluklari
sen kur; onemli olan PLAY'in baskinligi ve ust/orta/alt ritmi.

## Dosya: `lib/features/main_menu/view/main_menu_screen.dart`

`MainMenuScreen` **stateless** ve **veri-bagimsiz**. Su parametreleri alir:

```dart
const MainMenuScreen({
  required this.sectorNumber,      // int
  required this.levelNumber,       // int
  required this.sectorProgress,    // double 0..1
  required this.shards,            // int
  required this.cells,             // int
  required this.onPlay,            // VoidCallback
  required this.onStore,           // VoidCallback
  required this.onUpgrades,        // VoidCallback
  required this.onSettings,        // VoidCallback
  super.key,
});
```

Neden boyle: yonlendirmeyi ve veriyi baska bir worker baglayacak. Ekran
provider okumaz, `Navigator` cagirmaz -- sadece callback tetikler.

## Metinler

Mevcut l10n anahtarlarini kullan: `appTitle`, `menuPlay`, `menuStore`,
`menuUpgrades`, `menuSettings`, `sectorLabel`, `levelLabel`.

Yeni metin gerekiyorsa (ornegin alt baslik) **ARB dosyalarini duzenleme** --
raporunda anahtar adi + Ingilizce karsiligi olarak bildir, ben eklerim.
Gecici olarak mevcut bir anahtari kullan ya da o ogeyi atla.

## Logo

Font ve sprite henuz yok. Logoyu **tipografiyle** kur: `AppTypography` +
`AppColors.aetherCyan` + `AppDecorations` parlamasi. Harf araligi ve katmanli
golge ile "enerji" hissi ver. Resim dosyasi bekleme.

## Animasyon

Olculu tut. Girişte logonun yumusakca belirmesi ve PLAY butonunun hafif
nabiz atmasi yeterli. Surekli donen/kayan ogeler koyma -- pil yakar ve
dikkat dagitir.

## Galeri baglantisi

`lib/features/boot/view/boot_screen.dart` icindeki galeri butonunun YANINA
ana menuyu acan ikinci bir buton ekle (gecici, gorsel kontrol icin).
Orasi zaten gecici alan, literal metin serbest.

## Dokunulacak dosyalarin tam listesi

```
YENI:  lib/features/main_menu/view/main_menu_screen.dart
YENI:  lib/features/main_menu/widgets/  (gerekirse ekrana ozel parcalar)
DEGIS: lib/features/boot/view/boot_screen.dart
```

Baska hicbir dosyaya dokunma. `lib/shared/widgets/` ve `lib/app/theme/`
icinde **degisiklik yapma** -- oradaki bilesenler artik sabit; eksik bir sey
varsa raporunda bildir.

## Kabul kriterleri

Bu komutlari SEN calistirmayacaksin, terminal kullanma. Planner kosturacak.
Sen bunlardan gececek kodu yaz:

```
flutter analyze          # 0 issue
python tools/ui_lint.py  # TEMIZ
```

Hatirlatma: ham renk yok, ham olcu yok, elde `TextStyle` yok, metin literali
yok (galeri/boot butonu haric), `EdgeInsetsDirectional` kullan.

## Rapor

`AGENTS.md`'deki rapor formatini kullan.
