# assetkit

Gemini'den gelen contact sheet'leri oyunun kullandigi seffaf sprite'lara ve
atlas dokularina cevirir. Python 3.12 + Pillow + numpy (kurulu olmalari yeterli,
ek paket yok).

## Akis

```
Gemini (magenta zeminli N x M sheet)
   │  zip indir
   ▼
ingest  ── chroma key ─▶ dilimle ─▶ kirp ─▶ olcekle ─▶ assets/images/sprites/<grup>/*.webp
   ▼
pack    ── shelf paketleme ─▶ assets/images/atlas/<grup>.webp + .json
   ▼
verify  ── icerik JSON'larindaki sprite atiflari atlas'ta var mi
```

Pipeline'in son ciktisi her zaman **WebP**'dir (PNG degil). Kalite karari:

- **Sprite ve atlas: WebP LOSSLESS.** Lossy WebP alfa kenarlarinda hale
  birakir ve atlas icinde komsu sprite'a renk sizdirir; oyunda gorunur
  bozulma olur. Lossless yine PNG'den kucuktur.
- **Arka plan (alfa yok, buyuk resim): WebP LOSSY, quality 85.** Asil boyut
  kazanci burada saglanir.

## Komutlar

```bash
python tools/assetkit/assetkit.py ingest indirilenler/enemies.zip --recipe enemies
python tools/assetkit/assetkit.py pack   --group enemies
python tools/assetkit/assetkit.py verify
```

`ingest` girdi olarak zip, klasor veya tek goruntu kabul eder.

## Tarifler

`recipes/<ad>.json`. Alanlar:

| Alan | Varsayilan | Ne yapar |
|---|---|---|
| `chroma` | `true` | Magenta arka plani seffaflastir. Goruntu zaten seffafsa otomatik atlanir. |
| `key` | `[255,0,255]` | Chroma rengi |
| `tolerance` | `70` | Bu mesafenin altindaki pikseller tam seffaf |
| `soft_edge` | `40` | Yumusak kenar bandi genisligi (anti-aliasing icin) |
| `slice` | `"auto"` | `auto` = bosluga gore otomatik, `grid` = sabit `cols` x `rows` |
| `min_gap` | `12` | Iki objeyi ayirmak icin gereken en az bos piksel |
| `min_area` | `256` | Bundan kucuk parcalar gurultu sayilir, atilir |
| `max_size` | `256` | Sprite'in en uzun kenari (sadece kucultur) |
| `padding` | `2` | Sprite cevresine birakilan seffaf pay (texture bleeding onler) |
| `atlas_max` | `2048` | Atlas doku ust siniri |
| `names` | `[]` | Sirayla atanacak sprite adlari. Bos birakilirsa `grup_000` seklinde numaralanir. |
| `format` | `"webp_lossless"` | `webp_lossless` veya `webp_lossy`. Yukaridaki kalite kararina bak. |
| `quality` | `85` | `webp_lossy` icin kalite (0-100). `webp_lossless` icin yok sayilir. |

`slice` alani `"none"` de olabilir: goruntu dilimlenmeden tek parca olarak
alinir (chroma da genelde `false` olur) — arka plan gibi butun goruntunun
kendisi tek obje oldugu durumlar icin.

## Gemini'ye ne sorulacagi

Prompt sablonlari: `docs/ASSET_PROMPTS.md`.

En onemli kural: **duz saf magenta (#FF00FF) arka plan, objeler arasinda en az
40 px bosluk.** Bu sayede agir bir arka plan kaldirma modeline (rembg vb.)
ihtiyac kalmaz, kesme %100 isabetli olur.
