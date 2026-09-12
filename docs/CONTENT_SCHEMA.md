# İçerik Şeması

`assets/content/` altındaki JSON dosyalarının sözleşmesi.
Bu şema, oyunun **kod değiştirmeden büyüyebilen** yüzeyidir.

Tüm koordinatlar **normalize 0..1** uzayındadır (sol üst = 0,0; sağ alt = 1,1).
Ekran boyutuna çevirme sadece render katmanında yapılır — içerik cihazdan bağımsızdır.

Her değişiklikten sonra:
```bash
flutter test test/content_validation_test.dart
```

---

## levels/sector_NN.json

Bir sektörün 5 level'ı. Dosya adı sektör numarasını verir (`sector_03.json` → level 11-15).

```jsonc
{
  "sectorId": 3,
  "levels": [
    {
      "levelId": 11,
      "environmentId": "shattered_spires",   // sectors.json'daki ortam
      "coreHp": 900,
      "startingAether": 100,
      "difficultyMultiplier": 1.25,          // düşman HP/hasar çarpanı
      "maxEnemies": 200,                     // havuz kapasitesi — FPS tavanı
      "maxProjectiles": 400,

      "rifts": [
        { "id": "a", "x": 0.25, "y": 0.06, "skin": "rift_violet" },
        { "id": "b", "x": 0.75, "y": 0.06, "skin": "rift_violet" }
      ],

      // Düşmanlar bu waypoint zincirini takip eder. Pathfinding YOKTUR.
      // Son waypoint Core'a yakın olmalı (Core ~ [0.5, 0.86]).
      "lanes": [
        { "id": "la", "from": "a", "waypoints": [[0.25,0.30],[0.38,0.60],[0.50,0.84]] },
        { "id": "lb", "from": "b", "waypoints": [[0.75,0.30],[0.62,0.60],[0.50,0.84]] }
      ],

      "modifiers": ["dense_fog"],            // modifiers.json id'leri, boş olabilir

      "waves": [
        {
          "id": 1,
          "delay": 2.0,                      // önceki dalga bitince bu kadar bekle
          "groups": [
            { "enemy": "drifter", "count": 20, "interval": 0.35, "lane": "la" }
          ]
        },
        {
          "id": 2,
          "delay": 4.0,
          "groups": [
            { "enemy": "bulwark", "count": 6,  "interval": 1.2, "lane": "la",
              "eliteChance": 0.15 },
            { "enemy": "skitter", "count": 18, "interval": 0.2, "lane": "lb",
              "delay": 3.0 }                 // grup içi ek gecikme
          ]
        }
      ],

      "boss": null,                          // veya bosses.json'dan bir id
      "rewards": { "shards": 20, "firstClearCells": 3 }
    }
  ]
}
```

**Kurallar**
- `levelId` global ve benzersiz. Sektör N → level `(N-1)*5+1` … `N*5`.
- Her `lane.from` bir `rift.id`'ye, her `group.lane` bir `lane.id`'ye karşılık gelmeli.
- `boss` dolu ise o level'ın son dalgasından sonra boss gelir. Boss level'ları: 5, 10, 15, … 50.
- `maxEnemies` gerçekçi tut: aynı anda ekranda olabilecek en yüksek sayı + %20 pay.
  Çok yüksek vermek boşuna bellek, çok düşük vermek spawn'ların sessizce atlanması demek.

---

## enemies.json

```jsonc
{
  "drifter": {
    "name": "enemyDrifter",          // l10n anahtarı
    "sprite": "drifter",             // atlas kare adı
    "hp": 40, "speed": 0.045,        // speed = birim/saniye (normalize)
    "coreDamage": 10,
    "aetherReward": 3,
    "radius": 0.022,                 // çarpışma/hedefleme yarıçapı
    "behavior": "march",             // aşağıdaki listeden
    "flags": []
  }
}
```

`behavior` değerleri ve nerede uygulandıkları:

| behavior | Anlamı | Dosya |
|---|---|---|
| `march` | Lane'i takip et, Core'a ulaşınca hasar ver | varsayılan, ek dosya gerekmez |
| `rush` | Lane'i takip et ama Core'a yaklaşınca hızlan | `behaviors/rush_behavior.dart` |
| `split` | Ölünce N küçük düşmana bölünür | `behaviors/split_behavior.dart` |
| `phase` | Periyodik olarak dokunulmaz olur | `behaviors/phase_behavior.dart` |
| `drain` | Core'a ulaşınca Aether de çalar | `behaviors/drain_behavior.dart` |
| `spawn` | Sabit durur, küçük düşman üretir | `behaviors/spawn_behavior.dart` |

Yeni bir `behavior` eklemek = yeni bir dosya + registry'de tek satır. Başka hiçbir yer değişmez.

---

## units.json

```jsonc
{
  "pulse_guard": {
    "name": "unitPulseGuard",
    "sprite": "pulse_guard",
    "cost": 25, "costGrowth": 1.08,   // her üretimde maliyet × bu
    "hp": 60, "damage": 8, "range": 0.18, "attackSpeed": 1.6,
    "moveSpeed": 0.03, "radius": 0.02,
    "projectile": "pulse_bolt",       // null = yakın dövüş
    "role": "swarm"                   // swarm | ranged | tank | support
  }
}
```

---

## upgrades.json

Upgrade'ler iki şekilde etki eder: **sayısal** (`stats`) ve **davranışsal** (`flags`).
Sadece sayısal artış yığını istemiyoruz — her aile birkaç davranış değiştirici içermeli.

```jsonc
{
  "arc_chain_1": {
    "name": "upgradeArcChain1",
    "description": "upgradeArcChain1Desc",
    "icon": "upgrade_chain",
    "family": "chain",                 // synergy havuzu
    "rarity": "rare",                  // common | rare | epic | legendary
    "requires": [],                    // önce alınması gereken upgrade id'leri
    "maxStacks": 1,
    "weight": 60,                      // havuzdaki ağırlık
    "stats": [
      { "target": "arc_ranger", "stat": "chainTargets", "op": "add", "value": 1 }
    ],
    "flags": ["chainLightning"]
  }
}
```

- `target`: bir unit id'si, veya `all` (tüm birlikler), `core`, `economy`, `ability`.
- `op`: `add` (toplama) veya `mul` (çarpma). Tüm `add`'ler önce, sonra `mul`'lar uygulanır.
- `flags`: davranış bit bayrakları (`lib/domain/rules/behavior_flags.dart`).

**Denge kuralı:** Aynı `family`'den upgrade alındıkça o ailenin havuzdaki ağırlığı
kontrollü artar. Bu, oyuncunun build kurabilmesini sağlar ama tamamen şansa da bırakmaz.

---

## sectors.json

```jsonc
{
  "1": {
    "name": "sectorFracturedEdge",
    "environmentId": "fractured_edge",
    "background": "bg_sector_01",
    "riftSkin": "rift_violet",
    "palette": { "accent": "#9B5CFF", "fog": "#0E0C1C" },
    "unlockAfterLevel": 0
  }
}
```

---

## bosses.json

```jsonc
{
  "warden_prime": {
    "name": "bossWardenPrime",
    "sprite": "boss_warden_prime",
    "hp": 12000, "radius": 0.09,
    "phases": [
      { "hpThreshold": 1.0, "mechanics": ["summon_minions", "slam"] },
      { "hpThreshold": 0.6, "mechanics": ["shield", "summon_minions", "beam"] },
      { "hpThreshold": 0.25, "mechanics": ["teleport", "rift_summon", "enrage"] }
    ]
  }
}
```

`mechanics` değerleri `lib/engine/simulation/systems/boss_system.dart` içinde kayıtlıdır.
Boss sadece büyük HP barı olmamalı — her fazda en az bir mekanik değişmeli.

---

## abilities.json / modifiers.json / meta_upgrades.json / store.json

```jsonc
// abilities.json
{ "rift_collapse": {
    "name": "abilityRiftCollapse", "icon": "ability_collapse",
    "cooldown": 25.0, "radius": 0.18, "damage": 250, "warningTime": 0.6 } }

// modifiers.json — battlefield modifier'ları
{ "dense_fog": { "name": "modDenseFog", "effects": [
    { "stat": "unitRange", "op": "mul", "value": 0.85 } ] } }

// meta_upgrades.json — Rift Shard ile alınır, kalıcı
{ "core_hp_1": { "name": "metaCoreHp1", "cost": 50, "maxLevel": 5,
    "stat": "coreMaxHp", "op": "mul", "valuePerLevel": 1.05 } }

// store.json — IAP + soft currency
{ "cells_small": { "type": "consumable", "productId": "com.riftwarden.game.cells_small",
    "grants": { "cells": 100 } },
  "remove_ads":  { "type": "nonConsumable", "productId": "com.riftwarden.game.remove_ads" } }
```

> **Meta upgrade denge tavanı:** tüm meta upgrade'ler birlikte oyuncuya en fazla
> ~%25 güç kazandırmalı. Amaç "satın almadan geçemezsin" hissini önlemek;
> build seçimi baskın kalmalı.
