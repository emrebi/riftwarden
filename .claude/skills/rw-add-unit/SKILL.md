---
name: rw-add-unit
description: RIFTWARDEN'a yeni savunma birliği (sniper, drone, healer, artillery, shield unit vb.) ekler. Config + sprite + varsa yeni rol davranışı.
---

# Yeni savunma birliği ekleme

Dosya: `assets/content/units.json`. Şema: `docs/CONTENT_SCHEMA.md` → "units.json".

## Denge referansı (level 1 tabanı)
| Birlik | cost | hp | damage | range | attackSpeed | role |
|---|---|---|---|---|---|---|
| pulse_guard | 25 | 60 | 8 | 0.18 | 1.6 | swarm |
| arc_ranger | 60 | 35 | 26 | 0.32 | 0.9 | ranged |
| titan_frame | 140 | 400 | 30 | 0.10 | 0.6 | tank |

Yeni birliği bu üçgene göre konumlandır. Her birliğin net bir **rolü** olmalı:
"biraz daha iyi pulse_guard" bir rol değildir.

`costGrowth` (her üretimde maliyet çarpanı): swarm birlikleri ~1.06-1.08,
tank birlikleri ~1.12-1.15. Bu, sonsuz tek-tip spam'i engeller.

## Rol eklerken
`role` alanı hedefleme ve konumlanma davranışını belirler:
- `swarm` — öne çıkar, en yakın düşmana saldırır
- `ranged` — geride kalır, menzil sınırında durur
- `tank` — en öne çıkar, düşmanı üzerine çeker
- `support` — birliklerin arkasında kalır, düşmana saldırmaz

Yeni bir rol gerekiyorsa `lib/engine/simulation/systems/targeting_system.dart` ve
`movement_system.dart` içinde ilgili dalı ekle. Mevcut roller yetiyorsa Dart yazma.

## Upgrade bağlantısı
Yeni birlik en az bir upgrade ailesinden faydalanmalı, yoksa oyuncu ona yatırım
yapmaz. `/rw-add-upgrade` ile 2-3 upgrade ekle.

## Bitirdikten sonra
```bash
flutter analyze
flutter test test/content_validation_test.dart
python tools/assetkit/assetkit.py verify
```
