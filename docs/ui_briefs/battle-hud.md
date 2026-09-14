# GOREV: SAVAS HUD'U

Once `AGENTS.md` dosyasini oku. Oradaki arayuz kurallari baglayicidir.

Bu, oyunun en cok bakilan ekrani. Oyuncu zamaninin %90'ini burada gecirecek.

## Amac

Savas alanini **kapatmadan** oyuncuya karar vermek icin gereken her seyi ver.

Tasarim dokumanindan kural: gameplay arayuzu SADE tutulur. Oyuncuya yalnizca
gerekli bilgi gosterilir -- onlarca sayi, karmasik panel, debug benzeri bilgi,
okunamayan kucuk ikon ISTEMIYORUZ.

**Alt serit ekran yuksekliginin %22'sini gecmesin.** Ust serit cok daha ince.
Ortadaki savas alani oyuncunun gozunun oldugu yer; orayi bos birak.

## KRITIK: veri nasil okunur

Savas verisi Riverpod'dan DEGIL, `lib/engine/bridge/battle_signals.dart`
icindeki `BattleSignals`'tan gelir. **Once o dosyayi oku.**

```dart
// DOGRU -- sadece Aether yazisi yeniden cizilir
ValueListenableBuilder<int>(
  valueListenable: signals.aether,
  builder: (context, aether, _) => Text('$aether'),
)

// YANLIS -- 60 fps'te tum agaci yeniden kurar
final aether = ref.watch(someBattleProvider);
```

**Her sinyal icin AYRI `ValueListenableBuilder` kullan.** Hepsini tek builder'a
sarmak, Aether degistiginde Core HP barini da yeniden cizer.

Komutlar `BattleCommands` arayuzu uzerinden gider (ayni dosyada):
`requestUnit(unitId)`, `toggleAbilityAiming()`, `castAbilityAt(x, y)`,
`pause()`, `resume()`.

## Yerlesim (portrait, 360x640 dp'de tasmasin)

```
┌─────────────────────────────┐
│ [⏸]  Dalga 3/8      ⚡ 240  │  ust serit: ince, yariseffaf
├─────────────────────────────┤
│                             │
│                             │
│      SAVAS ALANI            │  GameWidget -- HUD bunu kapatmaz
│      (dokunulabilir)        │
│                             │
│                             │
│  ▓▓▓▓▓▓▓▓░░░░  CORE  720   │  Core HP bari -- alt seridin hemen ustunde
├─────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐  ┌──┐│
│  │PULS│ │ARC │ │TTAN│  │⚡││  birlik uretim + yetenek
│  │ 25 │ │ 60 │ │140 │  │  ││
│  └────┘ └────┘ └────┘  └──┘│
└─────────────────────────────┘
```

Kaba taslak; oranlari sen kur.

## Bilesenler

### Ust serit
- Pause butonu (`RwIconButton`) → `commands.pause()`
- Dalga ilerlemesi → `signals.wave` (`WaveProgress`: current/total/isBossWave)
  Boss dalgasinda gorsel olarak farklilassin.
- Aether sayaci → `signals.aether`. `AppTypography.numeric` kullan (tabular
  rakam) ki deger degistikce yazi ziplamasin.

### Core HP bari
- `signals.coreHpRatio` (0..1) ve `signals.coreHp` (mutlak deger).
- `RwProgressBar` kullan.
- **Dusuk HP uyarisi:** oran %25'in altina dusunce renk degisimi ve hafif nabiz.
  Abartma -- oyuncu paniklemeli ama ekran okunamaz olmamali.

### Birlik uretim butonlari
- `signals.unitCosts` (`Map<String,int>`: unitId → guncel maliyet) ve
  `signals.aether` birlikte okunur.
- Uc birlik: `pulse_guard`, `arc_ranger`, `titan_frame`.
- **Aether yetmiyorsa buton pasif gorunmeli** (soluk, dokunulamaz) ama
  GIZLENMEMELI -- oyuncu neye biriktirdigini gormeli.
- Basinca `commands.requestUnit(unitId)`.
- Maliyet her uretimde artiyor; buton uzerindeki sayi guncel maliyeti gostersin.
- Hizli art arda basmaya uygun olmali (uzun animasyon koyma).

### Yetenek butonu
- `signals.ability` (`AbilityState`: `cooldownRatio`, `isReady`, `isAiming`).
- Hazir degilken cooldown'i **dairesel dolgu** ile goster.
- Basinca `commands.toggleAbilityAiming()`.
- **Nisan alma modu** aktifken (`isAiming`): savas alani uzerine hafif bir
  kaplama gelsin ve oyuncu bir noktaya dokununca `commands.castAbilityAt(x, y)`
  cagrilsin. Koordinat **normalize (0..1)** olmali: `localPosition.dx / genislik`.
  Nisan modundan cikmak icin bir yol birak (tekrar butona basma).

### Pause overlay
Pause'a basilinca uzerine gelen basit panel: DEVAM ET ve ANA MENU.
`RwDialog` veya `RwPanel` kullan. Oyunu `commands.resume()` ile surdur.

## Dosyalar

`lib/features/battle/view/battle_screen.dart` **mevcut ve GECICI** -- icinde
sadece `GameWidget` ve geri butonu var. Onu bu HUD ile **yeniden yaz**.

Ekran su parametreleri almali (veri-bagimsiz kalsin):
```dart
const BattleScreen({
  required this.levelId,
  required this.onExit,        // VoidCallback -- ana menuye donus
  super.key,
});
```

`RiftwardenGame`'i kurma sekli mevcut dosyada var, onu koru. Oyundan
`signals` ve `commands` alanlarina eris.

HUD parcalarini `lib/features/battle/widgets/` altina yaz:
`battle_top_bar.dart`, `core_health_bar.dart`, `unit_spawn_bar.dart`,
`ability_button.dart`, `battle_pause_overlay.dart`.

## Safe area
Tam ekran `SafeArea` KULLANMA. Savas alani centigin altina uzanmali; sadece
HUD ogeleri guvenli alanda kalsin. `MediaQuery.of(context).viewPadding` oku ve
ust/alt seride padding olarak uygula.

## Metinler
Mevcut: `hudAether`, `hudCore`, `hudWave`, `menuSettings`, `resultMainMenu`,
`commonClose`.

Yeni metin gerekiyorsa **sadece `lib/l10n/arb/app_en.arb`**'ye ekle
(anahtar + Ingilizce deger + `@anahtar` aciklamasi). Diger ARB'lere dokunma.
Kodda anahtari eklenmis gibi kullan; `flutter analyze` o satirda hata verecek,
bu BEKLENEN. Raporunda listele.

Birlik adlari icin `assets/content/units.json` icindeki `name` alanlari l10n
anahtaridir (`unitPulseGuard` gibi) ama ARB'de henuz yoklar -- bunlari da
`app_en.arb`'ye ekle.

## Dokunulacak dosyalarin tam listesi

```
DEGIS: lib/features/battle/view/battle_screen.dart   (yeniden yaz)
YENI:  lib/features/battle/widgets/                  (HUD parcalari)
DEGIS: lib/l10n/arb/app_en.arb                       (sadece bu ARB)
```

`lib/engine/` altina **KESINLIKLE DOKUNMA** -- baska bir worker su anda orada
efekt ve yetenek sistemini yaziyor. `lib/shared/widgets/` ve `lib/app/theme/`
de sabit; eksik bir sey varsa raporunda bildir.

## Kabul kriterleri

Bu komutlari SEN calistirmayacaksin, terminal kullanma. Planner kosturacak.

```
flutter analyze          # yeni l10n anahtarlari disinda 0 issue
python tools/ui_lint.py  # TEMIZ
```

Hatirlatma: ham renk yok, ham olcu yok, elde `TextStyle` yok, metin literali
yok, `EdgeInsetsDirectional` kullan, dokunma hedefi >= 48 dp,
**`ref.watch`/`ref.listen` YOK**.

## Rapor

`AGENTS.md`'deki rapor formatini kullan.
