# assetkit

Gemini'den gelen contact sheet'leri oyunun kullandigi seffaf sprite'lara ve
atlas dokularina cevirir. Python 3.12 + Pillow + numpy (kurulu olmalari yeterli,
ek paket yok).

## Akis

```
Gemini (magenta zeminli N x M sheet)
   │  zip indir
   ▼
ingest  ── chroma key ─▶ dilimle ─▶ kirp ─▶ olcekle ─▶ assets/images/sprites/<grup>/
   ▼
pack    ── shelf paketleme ─▶ assets/images/atlas/<grup>.png + .json
   ▼
verify  ── icerik JSON'larindaki sprite atiflari atlas'ta var mi
```

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

## Gemini'ye ne sorulacagi

Prompt sablonlari: `docs/ASSET_PROMPTS.md`.

En onemli kural: **duz saf magenta (#FF00FF) arka plan, objeler arasinda en az
40 px bosluk.** Bu sayede agir bir arka plan kaldirma modeline (rembg vb.)
ihtiyac kalmaz, kesme %100 isabetli olur.
