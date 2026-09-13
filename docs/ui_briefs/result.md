# GOREV: SONUC EKRANI (zafer / yenilgi)

Once `AGENTS.md` dosyasini oku. Oradaki arayuz kurallari baglayicidir.

Tasarim sistemi, ana menu, ayarlar ve level secim ekrani onceki gorevlerde
kuruldu. Bu ekrani **mevcut bilesenleri kullanarak** kur.

## Amac

Level bitince cikan ekran. Iki durumu da ayni bilesen karsilar: **zafer** ve
**yenilgi**.

Bu ekranin en onemli ozelligi **hiz**. Oyuncu burada oyalanmamali:
- Yenilgide tek baskin buton TEKRAR DENE olmali; oyuncu dusunmeden tekrar
  girebilmeli. Basarisizlik cezalandirici hissettirilmemeli.
- Zaferde odul gosterilmeli ama uzun bir toren olmamali; DEVAM butonu hemen
  erisilebilir olmali.

Uzun animasyon, uzun sayac, zorunlu bekleme KOYMA. Odul sayilari kisa bir
artis animasyonuyla dolabilir ama 1 saniyeyi gecmesin ve dokununca aninda
tamamlansin.

## Once oku
```
lib/shared/widgets/                                 kullanacagin bilesenler
lib/features/level_select/view/level_select_screen.dart   son ekran orugu
lib/app/theme/                                      token'lar
lib/l10n/gen/app_localizations.dart                 mevcut metin anahtarlari
```

## Iki durum, tek bilesen

### ZAFER
```
┌─────────────────────────────┐
│                             │
│      ✦ RIFT SEALED ✦        │  resultVictoryTitle, kutlama tonu (cyan/teal)
│         LEVEL 3             │
│                             │
│  ╭───────────────────────╮  │
│  │  ODULLER              │  │  RwPanel
│  │  Rift Shard      +25  │  │  RwCurrencyChip
│  │  Aether Cell      +3  │  │  (ilk gecis ise)
│  ╰───────────────────────╯  │
│                             │
│  ┌───────────────────────┐  │
│  │ ▶ ODULU IKIYE KATLA   │  │  reklam butonu -- belirgin ama PLAY'den
│  └───────────────────────┘  │  daha az baskin
│                             │
│  ┌───────────────────────┐  │
│  │        DEVAM          │  │  primary, en baskin
│  └───────────────────────┘  │
│        [ ANA MENU ]         │  ghost
└─────────────────────────────┘
```

### YENILGI
```
┌─────────────────────────────┐
│                             │
│    CORE DESTABILIZED        │  resultDefeatTitle, tehlike tonu (kirmizi)
│         LEVEL 3             │
│                             │
│     Dalga 6 / 8             │  ne kadar ilerledigi -- moral, ceza degil
│                             │
│  ┌───────────────────────┐  │
│  │ ▶ REKLAM IZLE, DEVAM  │  │  sadece hak varsa gorunur
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │     TEKRAR DENE       │  │  primary, en baskin
│  └───────────────────────┘  │
│        [ ANA MENU ]         │  ghost
└─────────────────────────────┘
```

Kaba taslak; oranlari sen kur.

## Reklam butonu tasarimi

Bu buton gelir modelinin merkezinde ama **kandirmaca gibi gorunmemeli**:
- Ne oldugu acik olmali (video oynatma isareti + net metin).
- Baskin butondan (DEVAM / TEKRAR DENE) gorsel olarak ayrilmali ki oyuncu
  yanlislikla basmasin.
- Karanlik desen YOK: sahte kapatma butonu, gizlenmis X, yaniltici yerlesim
  kullanma. Oyuncu ne aldigini bilerek bassin.

## Dosya: `lib/features/result/view/result_screen.dart`

Once `lib/features/result/view/result_data.dart`:

```dart
enum BattleResultKind { victory, defeat }

class BattleResultData {
  const BattleResultData({
    required this.kind,            // BattleResultKind
    required this.levelNumber,     // int
    required this.shardsEarned,    // int
    required this.cellsEarned,     // int   0 ise satiri gosterme
    required this.wavesCleared,    // int   yenilgide gosterilir
    required this.totalWaves,      // int
    required this.canWatchAd,      // bool  reklam butonu gorunsun mu
  });
}
```

Ekran:
```dart
const ResultScreen({
  required this.data,            // BattleResultData
  required this.onPrimary,       // VoidCallback  DEVAM veya TEKRAR DENE
  required this.onWatchAd,       // VoidCallback
  required this.onMainMenu,      // VoidCallback
  super.key,
});
```

`canWatchAd` false ise reklam butonu **hic cizilmemeli** (gri pasif buton
birakma -- oyuncuya alamayacagi seyi gosterme).

## Metinler
Mevcut anahtarlar: `resultVictoryTitle`, `resultDefeatTitle`, `resultRetry`,
`resultNextLevel`, `resultMainMenu`, `resultWatchAdContinue`,
`resultDoubleReward`, `levelLabel`, `hudWave`.

Yeni metin gerekiyorsa **ARB dosyalarini duzenleme**, raporunda anahtar adi +
Ingilizce karsiligi olarak bildir.

## Boot baglantisi
`lib/features/boot/view/boot_screen.dart` icindeki gecici butonlarin yanina
**iki** buton ekle: biri zafer, biri yenilgi ornegi acsin. Ornek verileri
orada uydur (zafer: odullu + ilk gecis; yenilgi: reklam hakki var).

## Dokunulacak dosyalarin tam listesi

```
YENI:  lib/features/result/view/result_screen.dart
YENI:  lib/features/result/view/result_data.dart
YENI:  lib/features/result/widgets/   (odul satiri, reklam butonu)
DEGIS: lib/features/boot/view/boot_screen.dart   (iki gecici buton)
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
