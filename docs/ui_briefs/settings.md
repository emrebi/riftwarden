# GOREV: AYARLAR EKRANI

Once `AGENTS.md` dosyasini oku. Oradaki arayuz kurallari baglayicidir.

Tasarim sistemi ve ana menu onceki gorevlerde kuruldu. Bu ekrani **mevcut
bilesenleri kullanarak** kur, yeni ortak bilesen yazma.

## Amac

Oyuncunun ses, titresim ve dil tercihlerini degistirdigi yer. Sade ve hizli
olmali -- ayarlar ekrani gosteris yeri degil. Ama ucuz de gorunmemeli;
oyunun gorsel dili burada da surmeli.

### Once oku
```
lib/shared/widgets/                          kullanacagin bilesenler
lib/features/main_menu/view/main_menu_screen.dart   ekran kurulum orugu
lib/app/theme/                               token'lar
lib/l10n/gen/app_localizations.dart          mevcut metin anahtarlari
```

### Yerlesim (portrait, 360x640 dp'de tasmasin)

```
┌─────────────────────────────┐
│  ←   AYARLAR                │  RwScreenScaffold basligi + geri butonu
│                             │
│  ── SES ──────────────      │  RwSectionHeader
│  ┌───────────────────────┐  │
│  │ Ses efektleri    [ o] │  │  RwPanel icinde satirlar
│  │ Muzik            [ o] │  │  her satir: etiket + anahtar (Switch)
│  │ Titresim         [o ] │  │
│  └───────────────────────┘  │
│                             │
│  ── DIL ──────────────      │
│  ┌───────────────────────┐  │
│  │ Dil          Turkce > │  │  dokununca secim listesi acar
│  └───────────────────────┘  │
│                             │
│  ── HESAP ────────────      │
│  ┌───────────────────────┐  │
│  │ Satin Alimlari Geri.. │  │
│  │ Gizlilik Politikasi > │  │
│  └───────────────────────┘  │
│                             │
│              v1.0.0         │  surum -- literal degil, parametre
└─────────────────────────────┘
```

Kaba taslak; oranlari sen kur.

### Dosya: `lib/features/settings/view/settings_screen.dart`

`SettingsScreen` **stateless** ve **veri-bagimsiz**:

```dart
const SettingsScreen({
  required this.soundEnabled,        // bool
  required this.musicEnabled,        // bool
  required this.hapticsEnabled,      // bool
  required this.currentLanguageLabel,// String  ornek: "Turkce"
  required this.versionLabel,        // String  ornek: "1.0.0"
  required this.onSoundChanged,      // ValueChanged<bool>
  required this.onMusicChanged,      // ValueChanged<bool>
  required this.onHapticsChanged,    // ValueChanged<bool>
  required this.onLanguageTap,       // VoidCallback
  required this.onRestorePurchases,  // VoidCallback
  required this.onPrivacyTap,        // VoidCallback
  required this.onBack,              // VoidCallback
  super.key,
});
```

Dil SECIM LISTESINI bu gorevde yapma -- `onLanguageTap` tetiklemesi yeterli.

### Ekrana ozel parcalar
Tekrar eden "etiket + anahtar" ve "etiket + ok" satirlari icin
`lib/features/settings/widgets/` altinda kucuk parcalar yaz. Bunlari
`lib/shared/widgets/` icine KOYMA -- su an sadece bu ekranda kullaniliyorlar.

### Metinler
Mevcut anahtarlar: `menuSettings`, `settingsSound`, `settingsMusic`,
`settingsHaptics`, `settingsLanguage`, `settingsRestorePurchases`,
`settingsPrivacy`, `commonClose`.

Yeni metin gerekiyorsa (ornegin "SES" / "DIL" / "HESAP" grup basliklari)
**ARB dosyalarini duzenleme** -- raporunda anahtar adi + Ingilizce karsiligi
olarak bildir. Gecici olarak o grup basligini atlayabilirsin.

### Boot baglantisi
`lib/features/boot/view/boot_screen.dart` icindeki gecici butonlarin yanina
ayarlar ekranini acan bir tane daha ekle.

## Dokunulacak dosyalarin tam listesi

```
YENI:  lib/features/settings/view/settings_screen.dart
YENI:  lib/features/settings/widgets/   (ekrana ozel satir parcalari)
DEGIS: lib/features/boot/view/boot_screen.dart          (gecici buton)
```

`lib/shared/widgets/` ve `lib/app/theme/` icinde **degisiklik yapma** --
tasarim sistemi sabit. Eksik bir sey varsa raporunda bildir.

## Kabul kriterleri

Bu komutlari SEN calistirmayacaksin, terminal kullanma. Planner kosturacak.
Sen bunlardan gececek kodu yaz:

```
flutter analyze          # 0 issue
python tools/ui_lint.py  # TEMIZ
```

Hatirlatma: ham renk yok, ham olcu yok, elde `TextStyle` yok, metin literali
yok (boot ekranindaki gecici butonlar haric), `EdgeInsetsDirectional` kullan,
dokunma hedefi >= 48 dp.

## Rapor

`AGENTS.md`'deki rapor formatini kullan.
