---
name: rw-add-upgrade
description: RIFTWARDEN savaş içi upgrade sistemine yeni upgrade ekler veya havuzu dengeler. "Zincir şimşek build'ini güçlendir", "yeni ekonomi upgrade'i ekle" gibi isteklerde kullan.
---

# Upgrade ekleme

Dosya: `assets/content/upgrades.json`. Şema: `docs/CONTENT_SCHEMA.md` → "upgrades.json".

## Tasarım kuralı (en önemli kısım)
Salt sayı yığını istemiyoruz. `Damage +%10 / +%20 / +%30` zinciri **kabul edilmez**.

Her upgrade ailesi en az bir **oynanış değiştiren** üye içermeli:
- sayısal: `stats` ile stat değiştirir
- davranışsal: `flags` ile yeni bir mekanik açar (zincirleme, delme, ölümde patlama)

Hedef: oyuncu aynı level'ı farklı build'lerle oynayabilsin.

## Aileler ve kimliği
| family | Kimliği | Örnek davranış bayrağı |
|---|---|---|
| `chain` | Elektrik düşmanlar arasında seker | `chainLightning` |
| `pierce` | Mermi düşmanın içinden geçer | `piercing` |
| `crit` | Nadir ama çok büyük vuruş | `critical` |
| `explosion` | Ölüm zincirleme reaksiyon | `explodeOnDeath` |
| `swarm` | Ucuz birlik, çok sayı | `cheapReinforcement` |
| `titan` | Az ama devasa birlik | `knockback` |
| `economy` | Daha çok Aether → daha büyük ordu | `bonusAether` |
| `core` | Savunma: Core HP, kalkan, rejenerasyon | `coreShield` |
| `status` | Yakma / dondurma / yavaşlatma / sersemletme | `burn`, `freeze`, `slow`, `stun` |

## Ağırlık ve rarity
| rarity | weight aralığı | Ne zaman |
|---|---|---|
| `common` | 80–120 | Küçük sayısal artış, her build'de işe yarar |
| `rare` | 40–70 | Anlamlı sıçrama veya ilk davranış bayrağı |
| `epic` | 15–35 | Build tanımlayan, genelde `requires` ister |
| `legendary` | 3–10 | Oyunu değiştiren tek seferlik, `maxStacks: 1` |

`requires` ile zincir kur: `arc_chain_1` alınmadan `arc_chain_2` havuza girmez.

## Synergy
Oyuncu bir aileden upgrade aldıkça o ailenin ağırlığı kontrollü artar
(`lib/domain/rules/upgrade_pool.dart`). Bu yüzden **her ailede en az 3 üye** olmalı;
2 üyeli aile synergy'yi hissettirmez, oyuncu build kuramaz.

## Yeni davranış bayrağı gerekiyorsa
1. `lib/domain/rules/behavior_flags.dart` içine yeni bit ekle
2. Bayrağı okuyan sistemde kontrolü ekle (genelde `combat_system.dart`)
3. `step()` içinde bit testi kullan — string karşılaştırma veya map lookup değil

## Bitirdikten sonra
```bash
flutter analyze
flutter test test/content_validation_test.dart
```
