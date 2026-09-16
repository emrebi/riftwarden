---
name: rw-assets
description: RIFTWARDEN için web ChatGPT'ye tek parça yapıştırılacak görsel üretim prompt'unu hazırlar ve dönen zip'i assetkit ile işler. "Yeni düşman sprite'ı lazım", "ART-05'i üret", "intake'i işle", "ikon üret" gibi isteklerde kullan.
---

# Asset üretme ve işleme

## Prompt hazırlarken
Hazır ART görevi prompt'ları: `docs/ASSET_PROMPTS.md`. Sıra ve her ART-ID'nin
ne için kullanıldığı: `docs/UI_MIGRATION_PLAN.md` §5.

Her ART bölümü tek, kendi içinde yeterli bir İngilizce prompt bloğu içerir
(stil kuralları, yasaklı motifler ve teslim formatı zaten gömülü). Kullanıcı:
1. Web ChatGPT'de `design/references/05_UI_DESIGN_SYSTEM.png` + ilgili
   bölümde yazan yüzeye özgü referansı yükler.
2. O bölümdeki tek kod bloğunu aynen yapıştırır.
3. Dönen zip'i `design/art_intake/<ART-ID>.zip` olarak kaydeder (repo
   köküne değil) ve `design/art_intake/<ART-ID>/` altına çıkartır.

## Çıktıyı alma ve işleme
Zip çıkışı `design/art_intake/<ART-ID>/` altına çıkartılır (bu klasör commit
edilmez — bkz. `.gitignore`).

Planner çıktıyı `docs/DESIGN.md` ve ilgili yüzeye özgü referansa
(`design/references/0X_*.png`) göre onayladıktan sonra:

```bash
python tools/assetkit/assetkit.py ingest design/art_intake/<ART-ID> --recipe <grup>
python tools/assetkit/assetkit.py pack   --group <grup>
python tools/assetkit/assetkit.py verify
```

Atlas grupları: `enemies`, `units`, `fx`, `world`, `background`. Dosya başı
UI sanatı grupları (`portraits`, `illustrations`, `icons`, `ornaments`,
`logo`, `scenes`) `ART-PREP` görevinde eklenen tariflerle çalışır ve
`assets/images/ui_art/<grup>/<id>.webp` altına yazılır. Yeni atlas grubu =
`tools/assetkit/recipes/<ad>.json`.

`ingest` çıktısı kaç parça bulduğunu yazar. **Beklediğin sayıyla karşılaştır**
— tutmuyorsa `docs/ASSET_PROMPTS.md` sonundaki sorun giderme tablosuna bak
(genelde `min_gap` ayarı, `"slice":"grid"`, veya magenta/alfa karışıklığı).

## İsimlendirme
Tarifin `names` listesi sprite'lara sırayla atanır. Liste boşsa `grup_000`
diye numaralanır ve sonradan elle adlandırman gerekir — mümkünse tarife isim
listesi ekle.

Sprite/UI sanatı adları içerik JSON'larındaki `sprite` / `skin` / `icon`
alanlarıyla veya `unitId` ile birebir eşleşmeli. `verify` bunu kontrol eder.

## Dikkat
- Atlas tek dokudur ve `SpriteBatch` bunun üzerinden tek draw call yapar.
  Grubu bölmek performansı böler — `atlas_max` sığmıyorsa önce `max_size` düşür.
- `padding` 2'nin altına inme: texture bleeding (komşu sprite'ın pikselinin
  sızması) oluşur ve çok geç fark edilir.
- `world` grubu `chroma: false`'dır — magenta zeminle gelen bir `world`
  görseli dilimlenemez, gerçek alfa şeffaflığıyla yeniden üretilmesi gerekir.
