---
name: rw-add-enemy
description: RIFTWARDEN'a yeni Riftborn düşman tipi ekler. "Vortexer adında yeni düşman ekle" gibi isteklerde kullan. Config + (gerekirse) tek behavior dosyası + registry satırı; combat sisteminin tamamını okumaya gerek yok.
---

# Yeni düşman ekleme

## 1. Config (her zaman)
`assets/content/enemies.json` içine giriş ekle. Şema: `docs/CONTENT_SCHEMA.md` → "enemies.json".

Denge referansı (level 1 tabanı):
| Arketip | hp | speed | coreDamage | aetherReward |
|---|---|---|---|---|
| drifter (taban) | 40 | 0.045 | 10 | 3 |
| skitter (hızlı/kırılgan) | 18 | 0.11 | 6 | 2 |
| bulwark (tank) | 320 | 0.018 | 25 | 12 |

Yeni düşmanı bu üç referansa göre konumlandır. `speed` normalize birim/saniye —
0.045 ≈ ekranı ~22 saniyede geçer.

## 2. Davranış (sadece gerekiyorsa)
`behavior` alanı mevcut bir değerse (`march`, `rush`, `split`, `phase`, `drain`, `spawn`)
**hiç Dart yazma**, iş bitti.

Yeni bir davranış gerekiyorsa:
- `lib/engine/simulation/behaviors/<ad>_behavior.dart` oluştur
- Mevcut bir behavior dosyasını örnek al — aynı arayüzü uygula
- `lib/content/registry/content_registry.dart` içindeki behavior tablosuna tek satır ekle

**Kritik:** behavior `step()` içinde allocation yapamaz. Gerekli scratch tamponları
`onBattleStart` içinde ayrılır. Varlıklara `id` ile referans verilir, dizinle değil.

## 3. Sprite
`sprite` alanı `assets/images/atlas/enemies.json` içindeki bir kare adı olmalı.
Sprite henüz yoksa `/rw-assets` ile üret, sonra:
```bash
python tools/assetkit/assetkit.py verify
```

## 4. Level'lara yerleştir
Yeni düşmanı kullanan dalga eklemek `/rw-add-level` işidir.

## Bitirdikten sonra
```bash
flutter analyze
flutter test test/content_validation_test.dart
```
