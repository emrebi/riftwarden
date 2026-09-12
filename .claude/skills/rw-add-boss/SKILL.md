---
name: rw-add-boss
description: RIFTWARDEN'a yeni boss ekler veya mevcut boss fazlarını değiştirir. Boss'lar level 5, 10, 15 ... 50'de çıkar.
---

# Boss ekleme

Dosyalar:
- `assets/content/bosses.json` — tanım + faz makinesi
- `lib/engine/simulation/systems/boss_system.dart` — sadece **yeni mekanik** gerekiyorsa
- ilgili `assets/content/levels/sector_NN.json` — level'ın `boss` alanı

Şema: `docs/CONTENT_SCHEMA.md` → "bosses.json".

## Tasarım kuralı
Boss, devasa HP barı olan normal düşman OLAMAZ. Her fazda en az bir şey değişmeli:
saldırı deseni, savunma, arena, veya oyuncuya dayattığı karar.

## Faz yapısı
`phases` listesi `hpThreshold` azalan sırada. Boss HP'si eşiğin altına düşünce
o faza geçer, giriş animasyonu + screen shake tetiklenir.

- Level 5–20 boss'ları: **2 faz**
- Level 25–45: **2–3 faz**
- Level 50: **3 faz zorunlu**, final hissi vermeli

## Mevcut mekanikler
`summon_minions`, `shield`, `teleport`, `slam`, `beam`, `rift_summon`,
`hazard_field`, `knockback`, `invulnerable`, `enrage`, `core_strike`

Bunlar yetiyorsa **Dart yazma**, sadece JSON'da kombinle.

## Yeni mekanik eklerken
`boss_system.dart` içindeki mekanik tablosuna ekle. Kurallar:
- `step()` içinde allocation yok
- Minion spawn'ı düşman havuzunu kullanır; havuz doluysa sessizce atla
- `invulnerable` süresi 3 saniyeyi geçmemeli — oyuncu boşta beklemekten sıkılır

## Okunabilirlik
Mobil ekranda boss mekaniği **telegraflanmalı**: hasar veren alan önce
uyarı halkası göstermeli (`warningTime` ≥ 0.5 s). Uyarısız hasar adaletsiz hissettirir.

## Bitirdikten sonra
```bash
flutter analyze
flutter test test/content_validation_test.dart
```
