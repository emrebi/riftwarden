# GOREV: LEVEL SECIM EKRANI

Once `AGENTS.md` dosyasini oku. Oradaki arayuz kurallari baglayicidir.

Tasarim sistemi, ana menu ve ayarlar ekrani onceki gorevlerde kuruldu. Bu
ekrani **mevcut bilesenleri kullanarak** kur, yeni ortak bilesen yazma.

## Amac

Oyuncu PLAY'e bastiginda buraya gelir. Iki isi ayni anda yapmali:

1. **Ilerleme hissi vermek.** Oyuncu nereye kadar geldigini ve onunde ne
   oldugunu gormeli. 50 level, 10 sektor halinde gruplu. Gecilen sektorler
   arkada birikmis bir basari olarak durmali.
2. **Tek dokunusla oyuna sokmak.** Siradaki oynanabilir level acik sekilde
   one cikmali; oyuncu listeyi taramak zorunda kalmamali.

Bu bir menu degil, bir **harita** hissi vermeli. Oyuncu boyutlar arasinda
ilerliyor.

## Once oku
```
lib/shared/widgets/                                 kullanacagin bilesenler
lib/features/main_menu/view/main_menu_screen.dart   ekran kurulum orugu
lib/features/settings/view/settings_screen.dart     panel/satir orugu
lib/app/theme/                                      token'lar
lib/l10n/gen/app_localizations.dart                 mevcut metin anahtarlari
```

## Yerlesim (portrait, 360x640 dp'de tasmasin)

Dikey kaydirilabilir liste. Her sektor bir blok:

```
┌─────────────────────────────┐
│  ←   [Shard: 120]           │
│                             │
│  ╭───────────────────────╮  │
│  │ SEKTOR 1              │  │  sektor basligi + tamamlanma
│  │ FRACTURED EDGE   5/5  │  │
│  │  ①─②─③─④─⑤           │  │  5 level dugumu, aralarinda baglanti
│  ╰───────────────────────╯  │
│                             │
│  ╭───────────────────────╮  │
│  │ SEKTOR 2              │  │
│  │ ...              2/5  │  │
│  │  ⑥─⑦─⑧─⑨─⑩           │  │  ⑧ = siradaki (vurgulu, nabiz)
│  ╰───────────────────────╯  │  ⑨⑩ = kilitli (sonuk)
│                             │
│  ╭───────────────────────╮  │
│  │ SEKTOR 3      KILITLI │  │  kilitli sektor: kapali gorunum
│  ╰───────────────────────╯  │
└─────────────────────────────┘
```

Kaba taslak; dugum bicimini, baglanti cizgilerini ve oranlari sen kur.

## Level dugumu durumlari

Uc durum gorsel olarak **aninda ayirt edilebilmeli**:

| Durum | Gorunum |
|---|---|
| `completed` | Tamamlandi isareti, sonuk ama olumlu ton |
| `current` | En baskin oge. Vurgu rengi + hafif nabiz animasyonu |
| `locked` | Sonuk, kilit isareti, dokunulamaz |

Boss level'lari (her sektorun 5.'si) digerlerinden **gorsel olarak farkli**
olmali — daha buyuk dugum, farkli cerceve, tehdit hissi.

## Dosya: `lib/features/level_select/view/level_select_screen.dart`

`LevelSelectScreen` **stateless** ve **veri-bagimsiz**.

Once `lib/features/level_select/view/level_select_data.dart` icinde su saf
veri tiplerini tanimla (widget degil, sadece veri):

```dart
enum LevelNodeState { completed, current, locked }

class LevelNodeData {
  const LevelNodeData({
    required this.levelId,     // int, 1..50
    required this.state,       // LevelNodeState
    required this.isBoss,      // bool
  });
}

class SectorData {
  const SectorData({
    required this.sectorId,    // int, 1..10
    required this.name,        // String -- l10n'dan cozulmus gelir
    required this.levels,      // List<LevelNodeData>, 5 adet
    required this.isLocked,    // bool
    required this.completedCount, // int
  });
}
```

Ekran:
```dart
const LevelSelectScreen({
  required this.sectors,        // List<SectorData>
  required this.shards,         // int
  required this.onLevelTap,     // void Function(int levelId)
  required this.onBack,         // VoidCallback
  super.key,
});
```

Kilitli level'a dokunma `onLevelTap` tetiklememeli.

Neden veri-bagimsiz: gercek ilerleme verisini baska bir worker baglayacak.
Provider okuma, `Navigator` cagirma.

## Ekrana ozel parcalar
`lib/features/level_select/widgets/` altina sektor karti ve level dugumu
parcalarini yaz. `lib/shared/widgets/` icine KOYMA.

## Metinler
Mevcut anahtarlar: `sectorLabel` (`SECTOR {number}`), `levelLabel`
(`LEVEL {number}`), `levelLocked`.

Sektor ADLARI disaridan `SectorData.name` olarak geliyor -- sen cozmeyeceksin.

Yeni metin gerekiyorsa **ARB dosyalarini duzenleme**, raporunda anahtar adi +
Ingilizce karsiligi olarak bildir.

## Performans
50 dugum var. Sektor listesini `ListView.builder` ile kur, hepsini birden
insa etme. Nabiz animasyonu SADECE `current` dugumde calissin -- 50 tane
surekli animasyon pil yakar.

## Boot baglantisi
`lib/features/boot/view/boot_screen.dart` icindeki gecici butonlarin yanina
bu ekrani acan bir tane daha ekle. Ornek veriyi (3-4 sektor, karisik
durumlar, en az bir boss dugumu) orada uydur.

## Dokunulacak dosyalarin tam listesi

```
YENI:  lib/features/level_select/view/level_select_screen.dart
YENI:  lib/features/level_select/view/level_select_data.dart
YENI:  lib/features/level_select/widgets/   (sektor karti, level dugumu)
DEGIS: lib/features/boot/view/boot_screen.dart   (gecici buton + ornek veri)
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
yok (boot ekranindaki gecici alan haric), `EdgeInsetsDirectional` kullan,
dokunma hedefi >= 48 dp.

## Rapor

`AGENTS.md`'deki rapor formatini kullan.
