---
name: rw-add-unit
description: RIFTWARDEN'a yeni savunma birliği (sniper, drone, healer, artillery, shield unit vb.) ekler. Config + sprite + varsa yeni rol davranışı.
---

# Yeni savunma birliği ekleme

Dosya: `assets/content/units.json`. Şema: `docs/CONTENT_SCHEMA.md` → "units.json".

> Savaşçılar hareket etmez — kale yuvasında sabit durur. `moveSpeed` alanı YOKTUR.
> `range` yuvadan `defenseLineX`'e uzanacak şekilde büyük tutulmalı (yuva ≈ 0.2
> birim, sınır ≈ 1.1 birim civarı — yükseklik biriminde).

## Denge referansı (level 1 tabanı)
| Birlik | cost | hp | damage | range | attackSpeed | targetPriority |
|---|---|---|---|---|---|---|
| pulse_guard | 25 | 60 | 8 | 1.0 | 1.6 | nearestWall |
| arc_ranger | 60 | 35 | 26 | 1.3 | 0.9 | strongest |
| titan_frame | 140 | 400 | 30 | 0.75 | 0.6 | nearestWall |

Yeni birliği bu üçgene göre konumlandır. Her birliğin net bir **rolü** olmalı:
"biraz daha iyi pulse_guard" bir rol değildir.

`costGrowth` (her üretimde maliyet çarpanı): swarm birlikleri ~1.06-1.08,
tank birlikleri ~1.12-1.15. Bu, sonsuz tek-tip spam'i engeller.

## Hedef önceliği (`targetPriority`)
Sabit duran savaşçının hangi düşmanı seçeceğini belirler:
- `nearestWall` — sınıra en yakın (x'i en küçük) düşman — öndeki tehdide öncelik
- `nearest` — yuvaya en yakın düşman
- `strongest` — en yüksek hp'li düşman — büyük hedefleri öncelikli vurur

Yeni bir öncelik türü gerekiyorsa `lib/engine/simulation/systems/targeting_system.dart`
içinde ilgili dalı ekle. Mevcut üç değer yetiyorsa Dart yazma.

## Upgrade bağlantısı
Yeni birlik en az bir upgrade ailesinden faydalanmalı, yoksa oyuncu ona yatırım
yapmaz. `/rw-add-upgrade` ile 2-3 upgrade ekle.

## Bitirdikten sonra
```bash
flutter analyze
flutter test test/content_validation_test.dart
python tools/assetkit/assetkit.py verify
```
