# assetkit

Web ChatGPT'den alinan contact sheet zip'lerini oyunun kullandigi seffaf
sprite'lara ve atlas dokularina cevirir. Python 3.12 + Pillow + numpy
(kurulu olmalari yeterli, ek paket yok).

## Akis

```
web ChatGPT (kullanici zip'i design/art_intake/<ART-ID>.zip olarak kaydeder,
              design/art_intake/<ART-ID>/ altina cikartir)
   │
   ▼
ingest  ── chroma key ─▶ dilimle ─▶ kirp ─▶ olcekle ─▶ atlas: assets/images/sprites/<grup>/*.webp
   │                                                   ui_art: assets/images/ui_art/<grup>/*.webp
   ▼
pack    ── shelf paketleme ─▶ assets/images/atlas/<grup>.webp + .json (sadece atlas hedefi icin)
   ▼
verify  ── icerik JSON'larindaki sprite atiflari atlas'ta ve ui_art'ta var mi
```

UI sanati akisi: `ui_art` tarifleri `pack` gerektirmez, dogrudan `assets/images/ui_art/<grup>/` yazar.

Pipeline'in son ciktisi her zaman **WebP**'dir (PNG degil). Kalite karari:

- **Sprite ve atlas: WebP LOSSLESS.** Lossy WebP alfa kenarlarinda hale
  birakir ve atlas icinde komsu sprite'a renk sizdirir; oyunda gorunur
  bozulma olur. Lossless yine PNG'den kucuktur.
- **Arka plan (alfa yok, buyuk resim): WebP LOSSY, quality 85.** Asil boyut
  kazanci burada saglanir.

## Komutlar

```bash
# Atlas akisi
python tools/assetkit/assetkit.py ingest indirilenler/enemies.zip --recipe enemies
python tools/assetkit/assetkit.py pack   --group enemies
python tools/assetkit/assetkit.py verify

# Coklu kaynak ve ozel cikti koku (--out)
python tools/assetkit/assetkit.py ingest sheet_1.png sheet_2.png --recipe illustrations --out /tmp/cikis

# UI sanati eksiklerini siki kontrol ile denetleme
python tools/assetkit/assetkit.py verify --strict-ui-art
```

`ingest` girdi olarak bir veya birden fazla zip, klasor veya tek goruntu kabul eder (verilen sirayla islenir).

## Tarifler

`recipes/<ad>.json`. Alanlar:

| Alan | Varsayilan | Ne yapar |
|---|---|---|
| `chroma` | `true` | Magenta arka plani seffaflastir. Goruntu zaten seffafsa otomatik atlanir. |
| `key` | `[255,0,255]` | Chroma rengi |
| `tolerance` | `70` | Bu mesafenin altindaki pikseller tam seffaf |
| `soft_edge` | `40` | Yumusak kenar bandi genisligi (anti-aliasing icin) |
| `slice` | `"auto"` | `auto` = bosluga gore otomatik, `grid` = sabit `cols` x `rows`, `cells` = bilesen merkezine gore bildirilen izgara (hucre kenarini asan govde ve kopuk parcalar konusuyla kalir, bos hucre isim tuketmez), `none` = tek parca |
| `cols` | `0` | `grid` ve `cells` dilimleme icin sutun sayisi |
| `rows` | `0` | `grid` ve `cells` dilimleme icin satir sayisi |
| `min_gap` | `12` | Iki objeyi ayirmak icin gereken en az bos piksel |
| `min_area` | `256` | Bundan kucuk parcalar gurultu sayilir, atilir (`auto` dilimlemede) |
| `min_component` | `24` | `cells` dilimlemede gurultu sayilip atilacak en az bilesen piksel sayisi |
| `max_size` | `256` | Sprite'in en uzun kenari (sadece kucultur) |
| `max_size_by_group` | `{}` | `ui_art` hedefinde gruba ozel en uzun kenar (ornek `{"icons": 128}`), yoksa `max_size` gecerlidir |
| `padding` | `2` | Sprite cevresine birakilan seffaf pay (texture bleeding onler) |
| `atlas_max` | `2048` | Atlas doku ust siniri |
| `target` | `"atlas"` | Cikti hedefi: `"atlas"` (`assets/images/sprites/<tarif>/`) veya `"ui_art"` (`assets/images/ui_art/<grup>/`) |
| `ui_group` | `""` | `ui_art` hedefinde varsayilan grup (`portraits`, `illustrations`, `icons`, `ornaments`, `logo`, `scenes`) |
| `include` | `[]` | Bos degilse sadece dosya adi bu `fnmatch` desenlerinden birine uyan girdiler islenir |
| `naming` | `"list"` | Isimlendirme yontemi: `"list"` (`names` sirayla) veya `"file_stem"` (dosya adindan) |
| `strip_suffix` | `""` | `file_stem` isimlendirmede dosya kokunden atilacak sonek |
| `names` | `[]` | Sirayla atanacak sprite adlari. Bos birakilirsa `grup_000` seklinde numaralanir. `_skip` verilirse parca uretilmez/yazilmaz ama isim tuketilir. `ui_art` hedefinde `grup/id` biciminde ad verilerek oge baska bir UI grubuna yonlendirilebilir. |
| `format` | `"webp_lossless"` | `webp_lossless` veya `webp_lossy`. Yukaridaki kalite kararina bak. |
| `quality` | `85` | `webp_lossy` icin kalite (0-100). `webp_lossless` icin yok sayilir. |

`slice` alani `"none"` de olabilir: goruntu dilimlenmeden tek parca olarak
alinir (chroma da genelde `false` olur) — arka plan gibi butun goruntunun
kendisi tek obje oldugu durumlar icin.

## Web ChatGPT'ye ne yapistirilacagi

Tek-yapistirma prompt'lari: `docs/ASSET_PROMPTS.md`. Her ART bolumundeki tek
kod blogu aynen ChatGPT'ye yapistirilir (referans gorseller ayrica yuklenir).
ChatGPT'nin dondurdugu zip `design/art_intake/<ART-ID>.zip` olarak kaydedilir
(repo kokune degil), sonra `design/art_intake/<ART-ID>/` altina cikartilir
(bu klasor commit edilmez).

En onemli kural (chroma tarifleri icin — `units`, `enemies`, `fx`): **duz saf
magenta (#FF00FF) arka plan, objeler arasinda en az 40 px bosluk.** Bu sayede
agir bir arka plan kaldirma modeline (rembg vb.) ihtiyac kalmaz, kesme %100
isabetli olur. `world` grubu (`chroma: false`) icin gercek alfa seffafligi
gerekir, magenta zemin degil.

## Hedef boyutlar ve teslim

| Grup | Teslim sekli | Intake klasoru | Hedef en uzun kenar | Cikis |
|---|---|---|---|---|
| `enemies` | magenta chroma sheet | `design/art_intake/ART-05/` | 192 px/obje | atlas: `assets/images/atlas/enemies.webp` |
| `units` | magenta chroma sheet | `design/art_intake/ART-04/` | 192 px/obje | atlas: `assets/images/atlas/units.webp` |
| `fx` | magenta chroma sheet | `design/art_intake/ART-12/` | 128 px/obje | atlas: `assets/images/atlas/fx.webp` |
| `world` | seffaf sheet/tekil | `design/art_intake/ART-06/`, `ART-07/`, `ART-09/`, `ART-11/` | 256 px/obje | atlas: `assets/images/atlas/world.webp` |
| `background` | tam sahne, tek parca, opak | `design/art_intake/ART-07/`, `ART-08/` | 2048 px (genis kenar) | `assets/images/backgrounds/<id>.webp` (lossy q85) |
| `portraits` | tek dosya, seffaf | `design/art_intake/ART-04/` | ~512 px | `assets/images/ui_art/portraits/<unitId>.webp` |
| `illustrations` | tek dosya, seffaf | `design/art_intake/ART-09/`, `ART-10/`, `ART-13/` | ~512 px | `assets/images/ui_art/illustrations/<id>.webp` |
| `icons` | magenta chroma sheet | `design/art_intake/ART-03/`, `ART-09/` | ~128 px | `assets/images/ui_art/icons/<id>.webp` |
| `ornaments` | magenta chroma sheet | `design/art_intake/ART-02/` | ~256 px | `assets/images/ui_art/ornaments/<id>.webp` |
| `logo` | tek dosya, seffaf | `design/art_intake/ART-01/` | ~1024 px | `assets/images/ui_art/logo/<id>.webp` |
| `scenes` | tam sahne, tek parca, opak | `design/art_intake/ART-08/`, `ART-13/` | 2048 px (genis kenar) | `assets/images/ui_art/scenes/<id>.webp` |

`portraits`/`illustrations`/`icons`/`ornaments`/`logo`/`scenes` gruplarinin
`assetkit` tarifleri (`portraits`, `icons`, `ornaments`, `illustrations`,
`rift_collapse`) `ART-PREP` gorevinde olusturulur (logo/scenes/result tarifleri
ilgili ART onaylaninca ARTINT gorevinde eklenir); bu tablo o gorevlerin
hedef boyut/klasor sozlesmesidir. Var olan `enemies`/`units`/`fx`/`world`/
`background` tarifleri degismez.
