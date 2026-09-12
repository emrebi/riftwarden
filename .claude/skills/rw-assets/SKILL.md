---
name: rw-assets
description: RIFTWARDEN için Gemini'ye sprite/ikon ürettirme prompt'u hazırlar ve gelen zip'i assetkit ile işler. "Yeni düşman sprite'ı lazım", "zip'i işle", "ikon üret" gibi isteklerde kullan.
---

# Asset üretme ve işleme

## Prompt hazırlarken
Şablonlar ve hazır parti prompt'ları: `docs/ASSET_PROMPTS.md`.

Her prompt üç parçadan oluşur ve **üçü de zorunludur**:
1. STYLE BIBLE (aynen kopyala — tutarlılık bunu gerektirir)
2. Bu partiye özel içerik tarifi
3. TECHNICAL RULES (aynen kopyala — kesme buna bağlı)

En kritik teknik kural: **düz saf magenta #FF00FF arka plan, objeler arası ≥40 px boşluk,
arka plana değen gölge/glow yok.** Bu sayede ağır arka plan kaldırma modeline gerek kalmaz.

Kullanıcıya prompt'u **tek blok halinde**, kopyalanmaya hazır ver.

## Gelen zip'i işleme
```bash
python tools/assetkit/assetkit.py ingest <zip-yolu> --recipe <grup>
python tools/assetkit/assetkit.py pack   --group <grup>
python tools/assetkit/assetkit.py verify
```

Gruplar: `enemies`, `units`, `fx`, `ui`. Yeni grup = `tools/assetkit/recipes/<ad>.json`.

`ingest` çıktısı kaç parça bulduğunu yazar. **Beklediğin sayıyla karşılaştır** —
tutmuyorsa `docs/ASSET_PROMPTS.md` sonundaki sorun giderme tablosuna bak
(genelde `min_gap` ayarı veya `"slice":"grid"` gerekir).

## İsimlendirme
Tarifin `names` listesi sprite'lara sırayla atanır. Liste boşsa `grup_000` diye
numaralanır ve sonradan elle adlandırman gerekir — mümkünse tarife isim listesi ekle.

Sprite adları içerik JSON'larındaki `sprite` / `skin` / `icon` alanlarıyla
birebir eşleşmeli. `verify` bunu kontrol eder.

## Dikkat
- Atlas tek dokudur ve `SpriteBatch` bunun üzerinden tek draw call yapar.
  Grubu bölmek performansı böler — `atlas_max` sığmıyorsa önce `max_size` düşür.
- `padding` 2'nin altına inme: texture bleeding (komşu sprite'ın pikselinin
  sızması) oluşur ve çok geç fark edilir.
