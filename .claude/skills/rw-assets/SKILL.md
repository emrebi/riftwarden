---
name: rw-assets
description: RIFTWARDEN için Codex görsel-üretim agent'ına verilecek prompt'u hazırlar ve üretilen görselleri assetkit ile işler. "Yeni düşman sprite'ı lazım", "ART-05'i üret", "intake'i işle", "ikon üret" gibi isteklerde kullan.
---

# Asset üretme ve işleme

## Prompt hazırlarken
Şablonlar ve hazır ART görevi prompt'ları: `docs/ASSET_PROMPTS.md`. Sıra ve
her ART-ID'nin ne için kullanıldığı: `docs/UI_MIGRATION_PLAN.md` §5.

Her prompt üç parçadan oluşur ve **üçü de zorunludur**:
1. STYLE BIBLE (aynen kopyala — tutarlılık bunu gerektirir)
2. İlgili ART-ID'ye özel içerik tarifi
3. TECHNICAL RULES — dört teslim tipinden (A/B/C/D) o subject'e uyanı, aynen kopyala

En kritik teknik kural teslim tipine göre değişir:
- **Tip A** (`units`, `enemies`, `fx`): düz saf magenta #FF00FF arka plan, objeler arası ≥40 px boşluk.
- **Tip B** (`world`): gerçek alfa şeffaflığı, magenta değil.
- **Tip C** (`portraits`, `illustrations`, `icons`, `ornaments`, `logo`): tek obje, şeffaf, geniş kenar boşluğu.
- **Tip D** (`background`, `scenes`): tek parça, opak, 16:9 geniş sahne.

Prompt'u Codex görsel-üretim agent'ına **tek blok halinde** ver.

## Çıktıyı alma ve işleme
Codex, ürettiği ham PNG'leri `design/art_intake/<ART-ID>/` altına kaydeder
(bu klasör commit edilmez — bkz. `.gitignore`). Zip indirme/yükleme yoktur.

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
(genelde `min_gap` ayarı, `"slice":"grid"`, veya Tip A/Tip B karışıklığı).

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
- `world` grubu `chroma: false`'dır — Codex'ten magenta zeminle gelen bir
  `world` görseli dilimlenemez, gerçek alfa şeffaflığıyla yeniden üretilmesi
  gerekir.
