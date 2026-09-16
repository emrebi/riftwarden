# İçerik Şeması

`assets/content/` altındaki JSON dosyalarının sözleşmesi.
Bu şema, oyunun **kod değiştirmeden büyüyebilen** yüzeyidir.

> **Birim kuralı:** Konumlar (`x`, `y`, `wallX`, `defenseLineX`, `yMin`/`yMax`, `band`,
> yuva ve decor konumları) JSON'da her zaman **0..1** yazılır. Motor bunları izotropik
> dünyaya çevirirken x'i `kFieldAspect` (16/9) ile çarpar — bu sayede motor dünyası
> izotropiktir: ekranda çizilen bir alan ile oyun mantığının çalıştığı alan birebir
> aynı ölçekte örtüşür (bir daire ekranda da daire kalır, elipse dönmez). Menzil,
> yarıçap ve hız ise **yükseklik birimi** cinsindendir (alan yüksekliği = 1), x/y
> ayrımı olmadan doğrudan kullanılır.
>
> **Motordaki `core*` adları kale yapısını ifade eder** (`coreHp`, `coreDamage`,
> `coreHpRatio` vb.) — motor tarihsel ismini korur, görsel ve metin karşılığı "Kale"dir.

Konumlar JSON'da 0..1 yazılır; motor dünyasında x, `[0, kFieldAspect]` aralığında,
y ise `[0, 1]` aralığındadır. Ekran boyutuna çevirme sadece render katmanında
(`FieldProjection`) yapılır — içerik cihazdan bağımsızdır.

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
      "environmentId": "shattered_spires",   // environments.json'daki ortam
      "castle": { "id": "citadel_basic", "hp": 900 },   // castles.json'daki kale
      "startingAether": 100,
      "difficultyMultiplier": 1.25,          // düşman HP/hasar çarpanı
      "maxEnemies": 200,                     // havuz kapasitesi — FPS tavanı
      "maxProjectiles": 400,

      // Dusman sag kenarin hemen disinda, bu bantta rastgele y'de dogar.
      "spawn": { "yMin": 0.22, "yMax": 0.80, "riftSkin": "rift_violet", "riftCount": 3 },

      // Bu cizgiyi gecmeden dusman hedeflenemez. wallX < defenseLineX olmali.
      "defenseLineX": 0.62,

      // Alan etkisi. Pathfinding YOKTUR — sadece slowFactor / damageTakenMul uygular.
      "terrain": [
        { "type": "slow",  "x": 0.45, "y": 0.38, "radius": 0.12, "factor": 0.6 },
        { "type": "cover", "x": 0.52, "y": 0.68, "radius": 0.10, "damageTakenMul": 0.5 }
      ],

      "modifiers": ["dense_fog"],            // modifiers.json id'leri, boş olabilir

      "waves": [
        {
          "id": 1,
          "delay": 2.0,                      // önceki dalga bitince bu kadar bekle
          "groups": [
            { "enemy": "drifter", "count": 20, "interval": 0.35 }
          ]
        },
        {
          "id": 2,
          "delay": 4.0,
          "groups": [
            { "enemy": "bulwark", "count": 6,  "interval": 1.2, "eliteChance": 0.15 },
            { "enemy": "skitter", "count": 18, "interval": 0.2, "delay": 3.0,
              "band": [0.22, 0.45] }          // opsiyonel: grubun kendi spawn bandi
          ]
        }
      ],

      "boss": null,                          // veya bosses.json'dan bir id
      "rewards": { "shards": 20, "firstClearCells": 3 },

      // Toplam oldurme sayisi bunlardan birine ulasinca esik karti teklifi
      // acilir (bkz. "upgrades.json" ve `UpgradeSystem`). Kesin artan olmali.
      "upgradeKillThresholds": [18, 55, 95]
    }
  ]
}
```

**Kurallar**
- `levelId` global ve benzersiz. Sektör N → level `(N-1)*5+1` … `N*5`.
- `castle.id` `castles.json`'da tanımlı olmalı.
- `0 < castle içindeki wallX < defenseLineX < 1`.
- `0 <= spawn.yMin < spawn.yMax <= 1`; grup `band`'ları bu aralığın içinde kalmalı.
- `terrain.type` `slow` veya `cover`: `slow` için `0 < factor < 1`, `cover` için `0 < damageTakenMul < 1`.
- `environmentId` `environments.json`'da tanımlı olmalı.
- `boss` dolu ise o level'ın son dalgasından sonra boss gelir. Boss level'ları: 5, 10, 15, … 50.
- `maxEnemies` gerçekçi tut: aynı anda ekranda olabilecek en yüksek sayı + %20 pay.
  Çok yüksek vermek boşuna bellek, çok düşük vermek spawn'ların sessizce atlanması demek.
- `upgradeKillThresholds` boş olamaz, kesin artan olmalı; ilk değer toplam düşman sayısının
  (dalga gruplarındaki `count` toplamı) ~%10-15'i, son değer bu toplamın %75'ini geçmemeli.

---

## castles.json

Kale (motor içinde `core`), üzerinde savaşçı yuvaları taşır.

```jsonc
{
  "citadel_basic": {
    "sprite": "castle_citadel",
    "x": 0.09, "y": 0.51,          // kalenin merkezi
    "wallX": 0.19,                 // dusmanin durup saldirdigi sinir
    "slots": [                     // savasci yuvalari, sirayla ilk bosa yerlesir
      [0.07, 0.33], [0.13, 0.36],
      [0.07, 0.51], [0.13, 0.51],
      [0.07, 0.69], [0.13, 0.66]
    ]
  }
}
```

**Kurallar**
- `wallX < 1` ve kullanan her level'in `defenseLineX`'inden küçük olmalı.
- `slots` en az 1 eleman içermeli; her eleman `[x, y]` çifti.

---

## environments.json

Sektörün görsel zemini ve dekor öğeleri (çoğu görsel; sadece `terrain` alan etkisi verir).

```jsonc
{
  "fractured_edge": {
    "background": "bg_fractured_edge",
    "decor": [
      { "sprite": "crystal_rock_a", "x": 0.31, "y": 0.18, "scale": 1.0 },
      { "sprite": "alien_tree_a",   "x": 0.72, "y": 0.86, "scale": 0.8 }
    ]
  }
}
```

---

## enemies.json

```jsonc
{
  "drifter": {
    "name": "enemyDrifter",          // l10n anahtarı
    "sprite": "drifter",             // atlas kare adı
    "hp": 40, "speed": 0.09,         // speed = yukseklik birimi/saniye
    "coreDamage": 10,                // sur'a her vurusta verilen hasar
    "wallAttackInterval": 1.0,       // vurus araligi (saniye), varsayilan 1.0
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
| `march` | Sola ilerle, `wallX`'te dur, sur'a periyodik hasar ver | varsayılan, ek dosya gerekmez |
| `rush` | Sola ilerle ama sınıra yaklaşınca hızlan | `behaviors/rush_behavior.dart` |
| `split` | Ölünce N küçük düşmana bölünür | `behaviors/split_behavior.dart` |
| `phase` | Periyodik olarak dokunulmaz olur | `behaviors/phase_behavior.dart` |
| `drain` | Sur'a vurunca Aether de çalar | `behaviors/drain_behavior.dart` |
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
    "hp": 60, "damage": 8, "range": 1.0, "attackSpeed": 1.6,
    "radius": 0.02,
    "projectile": "pulse_bolt",       // null = yakın dövüş
    "targetPriority": "nearestWall"   // nearestWall | nearest | strongest
  }
}
```

Savaşçılar hareket etmez — kale yuvasında sabit durur, `moveSpeed` yoktur. `range`
yuvadan `defenseLineX`'e uzanacak şekilde büyük tutulmalı (yuva ≈ 0.2 birim,
sınır ≈ 1.1 birim civarı).

`targetPriority` hedef seçim önceliğini belirler:
- `nearestWall` — sınıra en yakın (x'i en küçük) düşman
- `nearest` — yuvaya en yakın düşman
- `strongest` — en yüksek hp'li düşman

---

## upgrades.json

Upgrade'ler iki şekilde etki eder: **sayısal** (`stats`) ve **davranışsal** (`flags`).
Sadece sayısal artış yığını istemiyoruz — her aile birkaç davranış değiştirici içermeli.
Ayrıca kaynak bakımından ikiye ayrılır: **kart** (savaş içi eşik kartı, ücretsiz seçim)
ve **dükkan** (Aether ile satın alınan savaşçı yeteneği).

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
    "weight": 60,                      // havuzdaki ağırlık (source: card için)
    "source": "card",                  // card (varsayilan) | shop
    "stats": [
      { "target": "arc_ranger", "stat": "chainTargets", "op": "add", "value": 1 }
    ],
    "flags": ["chainLightning"]
  },
  "arc_ranger_overcharge": {
    "name": "upgradeArcOvercharge",
    "description": "upgradeArcOverchargeDesc",
    "icon": "upgrade_overcharge",
    "family": "chain",
    "rarity": "epic",
    "requires": [],
    "maxStacks": 1,
    "source": "shop",
    "cost": 80,                        // Aether maliyeti (sadece shop)
    "unit": "arc_ranger",              // hangi savasci tipine ait (sadece shop)
    "stats": [
      { "target": "arc_ranger", "stat": "chainTargets", "op": "add", "value": 2 }
    ],
    "flags": ["chainLightning"]
  }
}
```

- `target`: bir unit id'si, veya `all` (tüm birlikler), `core`, `economy`, `ability`.
- `op`: `add` (toplama) veya `mul` (çarpma). Tüm `add`'ler önce, sonra `mul`'lar uygulanır.
- `flags`: davranış bit bayrakları (`lib/domain/rules/behavior_flags.dart`).
- `source: shop` olan upgrade'ler kart havuzuna GİRMEZ; savaş içi Aether yetenek
  dükkanında `unit` alanındaki savaşçı tipi için görünür, `cost` Aether ile alınır.
- `source: card` (veya alan yoksa varsayılan) mevcut eşik kartı akışında kalır.

**Denge kuralı:** Aynı `family`'den upgrade alındıkça o ailenin havuzdaki ağırlığı
kontrollü artar. Bu, oyuncunun build kurabilmesini sağlar ama tamamen şansa da bırakmaz.
Savaşçı başına 2-3 dükkan yeteneği hedeflenir.

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
