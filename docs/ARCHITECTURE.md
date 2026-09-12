# RIFTWARDEN — Mimari Plan ve Yol Haritası

## Context

`C:\Users\ASUS\Desktop\flutter_projects\wargame` şu an boş bir Flutter 3.47.1 scaffold'u (`lib/main.dart` = counter demo, git repo değil, 6 platform klasörü var). Buradan portrait-only iOS/Android için bir **auto-battle + swarm defense + roguelite upgrade** oyunu (RIFTWARDEN) çıkaracağız.

Bu planın asıl amacı kod yazmak değil; **ileride içerik eklerken yapay zekanın repoyu baştan okumak zorunda kalmadığı** bir yapı kurmak. "Level 51 ekle" dendiğinde tek bir JSON dosyasına, "yeni düşman ekle" dendiğinde tek bir config + tek bir behavior dosyasına dokunulmalı. Mimarinin her kararı bu kısıt altında alındı.

**Çalışma modeli:** Bu plan Opus xhigh tarafından bir kez kuruluyor. Sonrasında Opus medium planner/reviewer, Sonnet 5 worker (implementasyon, test yok, rapor var), Gemini 3 Flash UI tasarımcısı, Gemini web asset üreticisi olarak devam edecek.

### Onaylanan kararlar
| Konu | Karar |
|---|---|
| Market | Ana menüde sade **Store** (gerçek para + soft currency). Savaş içi build sadece upgrade kartlarıyla. Ekipman/gear marketi **yok**. |
| Git | `https://github.com/MarskyTech/RiftWarden.git` (gh CLI `emremars` olarak login, hazır) |
| Bundle ID | `com.riftwarden.game` (Android applicationId + namespace, iOS bundle id) |
| Claude skill | Dışarıdan plugin kurulmayacak; projeye özel `.claude/skills/` yazılacak + mevcut `dart-flutter` skill'leri kullanılacak |

---

## 1. Rol Dağılımı ve Çalışma Protokolü

```
OPUS MEDIUM (planner/reviewer)          SONNET 5 (worker)
  │ task brief yazar ──────────────────────▶ implementasyon
  │                                          │ flutter analyze
  │ ◀──────────────── sabit formatlı rapor ──┘
  │ 1-3 kritik dosyayı spot-check eder
  │ commit mesajını verir → commit + push
  └ sonraki adıma geçer
```

**Worker kuralları** (`CLAUDE.md` + `.claude/skills/rw-worker-task/SKILL.md` içine yazılacak):
- Test yazma, `flutter run` deneme, emulator açma **yok**.
- Tek kalite kapısı: `flutter analyze` → **0 error, 0 warning**. (Token maliyeti yok, kırılmaların ~%90'ını yakalar.)
- İçerik JSON'ı değiştiyse ek kapı: `flutter test test/content_validation_test.dart` (şema doğrulayıcı, saniyeler sürer).
- Brief'te listelenmeyen dosyaya dokunma; gerekiyorsa raporda "sapma" olarak bildir.
- Yorum satırı ekleme dışında açıklama üretme, özet paragrafı yazma.

**Zorunlu rapor formatı:**
```
## TASK <id> RAPOR
### Yapılanlar
- <madde>
### Dosyalar
eklendi:     <path>
değiştirildi: <path>
silindi:     <path>
### Kapılar
analyze: PASS/FAIL (<n> issue)
content:  PASS/FAIL/-
### Sapmalar
- <brief dışına çıkılan yer veya "yok">
```

**Commit dili:** Türkçe, tek satır, düz. Örn: `simülasyon çekirdeği ve entity pool eklendi`.

---

## 2. Teknoloji Kararları

| Paket | Versiyon | Neden |
|---|---|---|
| `flame` | ^1.38.2 | Oyun döngüsü, kamera, `SpriteBatch` (drawAtlas sarmalayıcısı — swarm'ın kilit taşı) |
| `flame_audio` | ^2.12.2 | SFX/müzik havuzu |
| `flutter_riverpod` | ^3.4.3 | **Sadece uygulama katmanı** state (menü, ayar, cüzdan, progression) |
| `go_router` | latest | Deklaratif ekran akışı, deep-link'e hazır |
| `google_mobile_ads` | ^9.1.0 | Rewarded ad (test ID'ler verildi) |
| `in_app_purchase` | ^3.3.0 | Consumable + non-consumable |
| `shared_preferences` | ^2.5.5 | Save blob (versiyonlu JSON + migration) |
| `flutter_localizations` + `intl` | SDK | 15 dil, gen-l10n |
| `package_info_plus`, `device_info_plus` | latest | Store/analytics meta |

**Bilinçli olarak ALINMAYANLAR:** `flame_riverpod` (oyun döngüsünü Riverpod'a bağlamak 60fps'te felaket), ayrı haptic paketi (Flutter'ın `HapticFeedback`'i yeterli), `flutter_animate` (UI aşamasında gerekirse eklenir), Hive/Isar (save boyutu buna değmez).

> **Kritik kural:** Riverpod savaş döngüsünün içine **asla** girmez. Savaş state'i düz Dart'tır; HUD'a `ValueNotifier` köprüsüyle, throttle'lanarak akar.

---

## 3. Katman Mimarisi

```
lib/
├── main.dart                     # sadece bootstrap çağrısı
├── app/
│   ├── bootstrap.dart            # storage, ads, iap, content, locale init sırası
│   ├── app.dart                  # MaterialApp.router + locale + theme
│   ├── router/app_router.dart
│   └── theme/                    # ★ design tokens — Gemini UI buraya bağlanır
│       ├── app_colors.dart  app_typography.dart  app_spacing.dart  app_theme.dart
├── core/
│   ├── services/                 # StorageService AudioService HapticService
│   │                             # AdService IapService AnalyticsService
│   ├── utils/                    # pooling helpers, math, rng (seeded)
│   └── constants/
├── content/                      # ★ İÇERİK KATMANI — genişleme yüzeyi
│   ├── schema/                   # UnitConfig EnemyConfig UpgradeConfig LevelConfig
│   │                             # SectorConfig BossConfig AbilityConfig StoreItemConfig
│   ├── loader/content_loader.dart
│   └── registry/content_registry.dart   # id → config lookup, tek erişim noktası
├── domain/                       # saf Dart, Flutter import'u YOK
│   ├── entities/
│   ├── rules/                    # StatResolver DamageCalculator WavePlanner
│   │                             # RewardCalculator UpgradePool
│   └── progression/
├── data/
│   ├── models/                   # SaveGameV1, MetaProgress, Wallet, PurchaseState
│   ├── repositories/             # SaveRepository MetaRepository WalletRepository
│   └── migrations/
├── engine/                       # ★ FLAME — widget import'u YOK
│   ├── riftwarden_game.dart
│   ├── simulation/
│   │   ├── battle_simulation.dart      # fixed timestep + sistem sırası
│   │   ├── entities/                   # düz Dart struct'lar (Component DEĞİL)
│   │   ├── pools/                      # EntityPool<T>, free-list
│   │   ├── spatial/spatial_hash_grid.dart
│   │   └── systems/                    # Spawn Movement Targeting Combat
│   │                                   # Economy Wave Ability Boss Effect
│   ├── render/                         # SpriteBatch tabanlı renderer component'ler
│   ├── effects/                        # particle pool, damage number, screen shake
│   └── bridge/battle_signals.dart      # ★ engine → HUD tek köprü
├── features/                     # ★ MVVM ekranlar (her biri: view/ viewmodel/ widgets/)
│   ├── boot/  main_menu/  level_select/  battle/  result/
│   ├── settings/  store/  meta_upgrades/
├── shared/widgets/               # ortak buton/panel/dialog — Gemini tasarımları
└── l10n/
```

**MVVM eşlemesi:** Model = `content/schema` + `domain` + `data/models` · ViewModel = Riverpod `Notifier` (ekranlar) ve `BattleViewModel` (savaş HUD'u, `BattleSignals`'ı dinler) · View = `features/*/view` + `shared/widgets`.

**Bağımlılık yönü tek taraflı:** `features → domain/content/data`, `engine → domain/content`, `domain → hiçbir şey`. `engine`'in `features`'ı, `domain`'in Flutter'ı bilmesi yasak.

---

## 4. Motor Mimarisi — Swarm'ı Nasıl Kaldırıyoruz

Bu, planın en kritik teknik kararı. Yüzlerce düşmanı her biri ayrı `PositionComponent` yaparak kaldırmak mobilde mümkün değil.

**Simülasyon ve render tamamen ayrılır:**

```
BattleSimulation (düz Dart, Flame bilmez)     Flame World (sadece çizer)
  EnemyEntity[]   ── havuz, önceden ayrılmış      SwarmRenderer      (1 SpriteBatch)
  UnitEntity[]    ── havuz                        UnitRenderer       (1 SpriteBatch)
  ProjectileEntity[] ── havuz                     ProjectileRenderer (1 SpriteBatch)
  step(fixedDt) → sistemler sırayla               EffectRenderer     (1 SpriteBatch)
                                                  CoreComponent / RiftComponent
```

| Teknik | Nasıl |
|---|---|
| **Batch render** | Düşman/birlik/mermi tipi başına tek atlas → Flame `SpriteBatch` → tek `drawAtlas` çağrısı. 500 düşman = ~4 draw call. |
| **Object pooling** | Savaş başında sabit kapasite ayrılır (`maxEnemies`, `maxProjectiles` level config'den). Savaş sırasında **sıfır allocation**. Free-list index stack. |
| **Spatial hash grid** | Flame'in collision detection'ı tamamen kapalı. Uniform grid (hücre ≈ 2× max menzil); her sim adımında clear+insert O(n). Hedef arama komşu hücrelerde. |
| **Fixed timestep** | 60 Hz accumulator. Render `prevX/prevY` ile alpha-lerp yapar → düşük FPS'te bile deterministik ve pürüzsüz. Slow-motion = dt ölçeklemesi. |
| **Targeting throttle** | Birlikler her karede değil, `id % 6` ile dağıtılmış şekilde ~100ms'de bir hedef tazeler. |
| **Stat caching** | Upgrade alındığında `StatResolver` bir kez çalışır → `ResolvedStats`. Kare başına stat hesabı yok. |
| **Behavior flags** | `chainLightning`, `pierce`, `explodeOnDeath` vb. tek `int` bitmask. Kontrol = bit testi. |
| **AI basitliği** | Pathfinding yok. Level, normalize 0..1 uzayda `lanes` (waypoint listeleri) tanımlar; düşman waypoint takip eder + hafif separation. Engeller lane çizimiyle çözülür, A* ile değil. |

**HUD köprüsü** (`engine/bridge/battle_signals.dart`): `ValueNotifier<int> aether`, `ValueNotifier<double> coreHpRatio`, `ValueNotifier<WaveProgress>`, `ValueNotifier<UpgradeOffer?>`, `ValueNotifier<AbilityState>`. Sürekli değerler **100 ms'de bir** güncellenir; kesikli olaylar (upgrade teklifi, boss girişi, level sonu) anında. HUD `ValueListenableBuilder` kullanır → kare başına widget rebuild yok.

**Upgrade sunumu — karar:** Slow-motion değil, **tam pause**. 150 ms'lik slow-mo rampasıyla girilir, kartlar alttan yükselir. Gerekçe: tek elle mobil kullanımda oyuncu kart okurken ilerleme kaybetmemeli; ayrıca "ordun büyüdü" hissini veren geri dönüş anını pause temiz gösterir.

---

## 5. İçerik Veri Modeli (AI için ucuz genişleme yüzeyi)

```
assets/content/
├── units.json          enemies.json      elites.json       bosses.json
├── upgrades.json       abilities.json    modifiers.json
├── sectors.json        meta_upgrades.json                  store.json
└── levels/
    ├── sector_01.json  (level 1-5)  ...  sector_10.json (level 46-50)
```

`LevelConfig` şeması (kısaltılmış):
```jsonc
{
  "levelId": 12, "sectorId": 3, "environmentId": "shattered_spires",
  "coreHp": 1000, "startingAether": 120, "difficultyMultiplier": 1.35,
  "maxEnemies": 240,                      // pool kapasitesi
  "rifts":  [{"id":"a","x":0.22,"y":0.06,"skin":"rift_violet"},
             {"id":"b","x":0.78,"y":0.06,"skin":"rift_violet"}],
  "lanes":  [{"id":"la","from":"a","waypoints":[[0.22,0.3],[0.4,0.6],[0.5,0.88]]}],
  "modifiers": ["dense_fog"],
  "waves": [
    { "id":1, "delay":2.0, "groups":[
        {"enemy":"drifter","count":20,"interval":0.35,"lane":"la"} ]},
    { "id":2, "delay":4.0, "groups":[
        {"enemy":"bulwark","count":6,"interval":1.2,"lane":"la","eliteChance":0.15},
        {"enemy":"skitter","count":18,"interval":0.2,"lane":"lb","delay":3.0} ]}
  ],
  "boss": null,
  "rewards": {"shards": 25, "firstClearCells": 5}
}
```

**Sonuç:** "Level 51–55 ekle" = `levels/sector_11.json` yaz + `sectors.json`'a bir giriş. **Hiçbir Dart dosyasına dokunulmaz.** "Vortexer düşmanı ekle" = `enemies.json`'a giriş + gerekiyorsa `engine/simulation/systems/behaviors/vortexer_behavior.dart` + registry'ye tek satır.

`test/content_validation_test.dart` tüm JSON'ları yükleyip doğrular: bilinmeyen enemy/lane/rift id'si, negatif değer, eksik atlas anahtarı, sector-level boşluğu → test kırmızı olur. Bu, worker'ın veri hatalarını bedava yakalar.

**Upgrade modeli** — salt sayı artışı değil, iki mekanizma:
```jsonc
{ "id":"arc_chain_2", "family":"chain", "rarity":"epic", "requires":["arc_chain_1"],
  "stats":  [{"target":"arc_ranger","stat":"chainTargets","op":"add","value":2}],
  "flags":  ["chainLightning"],
  "weight": 40 }
```
`UpgradePool` weighted-random seçer; oyuncu bir family'den aldıkça o family'nin weight'i kontrollü artar (build kurulmasını destekler, tam şansa bırakmaz). Rarity alanı baştan var ama ilk sürümde sadece kart rengini ve weight'i etkiler.

---

## 6. Monetization

**Para birimleri:** `Aether` (savaş içi, run sonunda sıfırlanır) · `Rift Shard` (soft meta, level ödülü) · `Aether Cell` (hard, IAP + ilk-geçiş/günlük ödül).

**Store içeriği** (`assets/content/store.json`, hepsi data-driven):
- Consumable IAP: Cell paketleri × 5 kademe
- Non-consumable: `Remove Ads`, `Starter Pack` (Cell + kalıcı %10 Aether kazancı)
- Cell ile: Shard paketi, revive token, sektör atlama
- Shard ile: meta upgrade'ler (starting Core HP, starting Aether, unit damage, reinforcement/ability cooldown, Aether efficiency)

> Meta upgrade tavanı bilinçli olarak düşük tutulacak (toplam ~%25 güç artışı). "Satın almadan geçemezsin" durumu oluşmamalı; build seçimi baskın kalmalı.

**Rewarded ad yerleşimleri** (verilen test ID'ler `AdConfig`'e gömülü, prod ID'ler TODO placeholder; `kReleaseMode` ile seçim):
| Yer | Limit |
|---|---|
| Core yok olunca **Continue** | run başına **1** |
| Zafer ekranında **2× ödül** | level başına 1 |
| Günlük bedava Cell | günde 1 |
| Upgrade kartı **reroll** | run başına 2 |

Reklam sonrası revive tükenince "gerçek para ile devam et" (Cell harcama) seçeneği çıkar — istediğin akış bu.

`AdService` ve `IapService` **arayüz arkasında** olacak; motor ve domain bunları hiç bilmez, sadece `features/*/viewmodel` çağırır. Böylece reklam ağı değişirse tek dosya değişir.

---

## 7. Platform, Lokalizasyon, Font

**Mobil-only:** `web/`, `windows/`, `linux/`, `macos/` klasörleri silinir, `.metadata` temizlenir. `main.dart`'ta `SystemChrome.setPreferredOrientations([portraitUp, portraitDown])`.
- Android: `applicationId` + `namespace` = `com.riftwarden.game`, `minSdk 24`, `targetSdk 36`, AdMob App ID meta-data.
- iOS: deployment target `15.0`, Info.plist'te portrait-only, `GADApplicationIdentifier`, `SKAdNetworkItems`, `NSUserTrackingUsageDescription`.
- Safe area: tüm ekranlar `SafeArea`; savaş HUD'u notch/Dynamic Island/Android gesture bar'ı hesaba katan `MediaQuery.viewPadding` ile konumlanır.

**15 dil** (`l10n/app_*.arb`, gen-l10n): `en ja ko zh zh_Hant de fr es it pt_BR ru ar th id tr`. Sistem dili default, fallback `en`. Arapça için RTL — tüm UI `EdgeInsetsDirectional` ve `start/end` kullanacak (savaş alanı yön-bağımsız kalır).

**Font sorunu (önemli):** Tek font Latin+CJK+Thai+Arapça kapsamaz. Çözüm: display/logo/rakamlar için tek bir teknolojik Latin font (Orbitron/Exo 2 sınıfı), gövde metin için locale'e göre seçilen Noto alt kümeleri. `AppFonts.forLocale(locale)` helper'ı tema kurulumunda çağrılır. CJK fontları büyüktür → sadece gerekli ağırlık bundle'lanır.

---

## 8. Asset Pipeline (`tools/assetkit/`)

Python 3.12 + Pillow 12 + numpy **zaten kurulu** — ek kurulum gerekmiyor.

```
tools/assetkit/
├── assetkit.py     # CLI
├── chroma.py       # magenta key → alpha + despill
├── slice.py        # grid dilimleme + connected-component otomatik tespit
├── trim.py         # autocrop + padding + resize
├── pack.py         # shelf packer → atlas.png + atlas.json
└── recipes/        # her asset grubu için tarif (hedef boyut, padding, atlas adı)
```

```bash
python tools/assetkit/assetkit.py ingest downloads/enemies.zip --recipe enemies
python tools/assetkit/assetkit.py pack --group enemies      # → assets/images/atlas/
python tools/assetkit/assetkit.py verify                    # content JSON ↔ atlas tutarlılığı
```

**Gemini prompt kuralları** (`docs/ASSET_PROMPTS.md` içine şablon olarak yazılacak) — kesme/bg kaldırma işini baştan kolaylaştıran kısım:
- Arka plan **düz saf magenta `#FF00FF`**, gradient yok, arka plana düşen gölge yok → chroma key %100 güvenilir olur, `rembg` gibi ağır araca gerek kalmaz.
- Her obje arasında en az 40 px magenta boşluk, **sıkı N×M grid**, eşit hücre.
- Ortografik top-down 3/4 görünüm, ışık sol üstten, sabit.
- Metin/etiket/watermark/UI çerçevesi yok.
- Her promptun başına aynı **style bible** cümlesi yapıştırılır (tutarlılık için).

Transparan PNG gelirse chroma adımı atlanır, doğrudan trim+pack çalışır — script iki durumu da destekler.

---

## 9. Projeye Özel Claude Skill'leri

`.claude/skills/` altına — amaç: ileride bir iş için **repo değil, 150-250 satırlık skill** yüklensin.

| Skill | Ne yapar |
|---|---|
| `rw-add-level` | Level/sector ekleme: şema, zorluk eğrisi kuralları, doğrulama komutu |
| `rw-add-enemy` | Yeni düşman: config alanları, behavior dosyası şablonu, registry kaydı, atlas anahtarı |
| `rw-add-unit` | Yeni savunma birliği |
| `rw-add-upgrade` | Upgrade + family/weight/synergy kuralları |
| `rw-add-boss` | Boss + phase state machine şablonu |
| `rw-assets` | assetkit kullanımı + Gemini prompt şablonu |
| `rw-ui-integrate` | Gemini'nin ürettiği tasarımı `app/theme` + `features/*/view`'a bağlama kuralları |
| `rw-worker-task` | Sonnet worker sözleşmesi + rapor formatı |

Ek olarak kök `CLAUDE.md` (sert kurallar + komutlar) ve `docs/CONTENT_MAP.md` (tek sayfa "hangi iş → hangi dosya" indeksi).

---

## 10. Yol Haritası

Her adım = bir Sonnet worker görevi + bir commit. Commit mesajları önerilmiştir.

### M0 — Temel (4 adım)
| # | İş | Commit |
|---|---|---|
| 1 | Platform temizliği: web/windows/linux/macos sil, bundle id `com.riftwarden.game`, portrait lock, minSdk 24 / iOS 15, `.metadata` temizle, counter demo sil | `proje mobil-only hale getirildi ve kimlik ayarlandı` |
| 2 | Bağımlılıklar, tüm klasör iskeleti (boş barrel dosyalarıyla), sıkı `analysis_options.yaml`, `git init` + remote + `.gitignore` | `bağımlılıklar ve katman iskeleti eklendi` |
| 3 | `core/services`: Storage, Audio, Haptic, Log + Riverpod `ProviderScope` + `bootstrap.dart` init sırası | `core servisler ve bootstrap eklendi` |
| 4 | l10n altyapısı, 15 ARB dosyası (anahtarlar + en/tr dolu, diğerleri placeholder), `AppFonts.forLocale` | `15 dil altyapısı eklendi` |

### M1 — İçerik ve Domain (4 adım)
| # | İş | Commit |
|---|---|---|
| 5 | `tools/assetkit/` tamamı + `docs/ASSET_PROMPTS.md` → **Gemini asset üretimi buradan sonra paralel başlayabilir** | `asset pipeline araçları eklendi` |
| 6 | `content/schema` modelleri + `ContentLoader` + `ContentRegistry` + `test/content_validation_test.dart` | `içerik şema ve registry katmanı eklendi` |
| 7 | İlk içerik verisi: 3 birlik, 7 düşman arketipi, ~40 upgrade, Rift Collapse ability, sector 1-2 level'ları | `başlangıç içerik verisi eklendi` |
| 8 | `domain/rules`: StatResolver, DamageCalculator, UpgradePool, WavePlanner, RewardCalculator | `savaş kuralları katmanı eklendi` |

### M2 — Motor (5 adım)
| # | İş | Commit |
|---|---|---|
| 9 | Simülasyon çekirdeği: entity struct'ları, `EntityPool`, `SpatialHashGrid`, fixed-timestep `BattleSimulation` | `simülasyon çekirdeği ve entity havuzu eklendi` |
| 10 | Sistemler: Spawn, Movement (lane+separation), Targeting, Combat, Economy, Wave | `savaş sistemleri eklendi` |
| 11 | Render: `SpriteBatch` renderer'lar, placeholder atlas, kamera, interpolasyon | `batch render katmanı eklendi` |
| 12 | Efektler: particle pool, hasar sayıları, screen shake, haptic tetikleyicileri, ölüm animasyonu | `görsel geri bildirim katmanı eklendi` |
| 13 | `BattleSignals` köprüsü + Ability sistemi (Rift Collapse, dokunmalı hedefleme + warning) | `HUD köprüsü ve özel yetenek eklendi` |

### M3 — Oyun Akışı (4 adım)
| # | İş | Commit |
|---|---|---|
| 14 | Savaş içi upgrade sistemi: tetikleyiciler, pause+kart sunumu, rarity, weighted pool, reroll kancası | `savaş içi upgrade sistemi eklendi` |
| 15 | Boss sistemi: phase state machine, mekanikler (summon/shield/teleport/hazard), level 5 & 10 boss'ları | `boss sistemi eklendi` |
| 16 | Router + ekran akışı iskeleti (boot → menu → level select → battle → result), **placeholder UI** | `ekran akışı ve yönlendirme eklendi` |
| 17 | Save/meta progression: `SaveGameV1`, repository'ler, migration, cüzdan | `kayıt ve meta ilerleme sistemi eklendi` |

### M4 — Gelir ve İçerik (3 adım)
| # | İş | Commit |
|---|---|---|
| 18 | `AdService` + rewarded (continue/2× ödül/günlük/reroll) + `AdConfig` test ID'leri + manifest/plist | `ödüllü reklam entegrasyonu eklendi` |
| 19 | `IapService` + Store ekranı + satın alma doğrulama + restore + Remove Ads | `mağaza ve satın alma sistemi eklendi` |
| 20 | 50 level içeriği (sector 1-10), zorluk eğrisi, elite/boss dağılımı, level 50 final | `50 level içeriği eklendi` |

### M5 — Cila (3 adım)
| # | İş | Commit |
|---|---|---|
| 21 | **Gemini UI entegrasyonu**: design token'ları `app/theme`'e, tasarımlar `features/*/view` ve `shared/widgets`'a | `oyun arayüzü tasarımı entegre edildi` |
| 22 | Gerçek asset'lerin pipeline'dan geçirilip bağlanması, ses/müzik | `oyun görselleri ve sesleri eklendi` |
| 23 | Performans geçişi (pool boyutları, atlas birleştirme, profil), store hazırlığı (ikon, splash, imzalama, privacy) | `performans iyileştirmeleri ve store hazırlığı yapıldı` |

**Paralellik:** Adım 5 bitince Gemini asset üretimi, adım 16 bitince Gemini UI tasarımı paralel yürüyebilir — Sonnet motor üzerinde çalışmaya devam ederken.

---

## 11. Doğrulama

| Ne zaman | Nasıl |
|---|---|
| Her worker adımı sonunda | `flutter analyze` → 0 issue |
| İçerik JSON değiştiğinde | `flutter test test/content_validation_test.dart` |
| M2 bitiminde (ilk oynanabilir) | `flutter run --release` gerçek cihazda: 200+ düşmanla FPS ölçümü (DevTools performance overlay), hedef **stabil 60 fps / min 45** |
| M3 bitiminde | Level 1-5 baştan sona oynanır: wave akışı, upgrade, kazanma/kaybetme ekranları |
| M4 bitiminde | Test reklam ID'leriyle rewarded akışı, IAP sandbox (Play Internal Testing / TestFlight) |
| M5 bitiminde | Farklı aspect ratio'larda (notch'lu iPhone, uzun Android) safe-area kontrolü, RTL için Arapça'ya geçip menü taraması |

Manuel kontrolleri sen yapacaksın; worker sadece analyze kapısını geçirip rapor bırakacak.

---

## 12. Varsayımlar ve Açık Uçlar

1. **İsim:** RIFTWARDEN çalışma adı. Store'a çıkmadan önce isim taraması (App Store/Play'de çakışma + trademark) yapılmalı. Bundle ID `com.riftwarden.game` ismi değişirse yeniden ayarlanmalı.
2. **Prod reklam/IAP ID'leri:** Şimdilik sadece Google'ın test ID'leri gömülü. AdMob hesabı ve Play/App Store Connect ürünleri açıldığında `AdConfig` ve `store.json`'a gerçek ID'ler girilecek.
3. **Sunucu yok:** Tüm progression cihazda. IAP doğrulaması client-side; hile riski kabul edildi (single-player, leaderboard yok). Cloud save/leaderboard istenirse sonradan `data/repositories` arkasına eklenebilir.
4. **Ses assetleri:** Bu planda üretim yöntemi belirlenmedi (Gemini görsel üretiyor, ses üretmiyor). M5'te ayrıca karar verilecek.
5. **Rift Pass / sezon sistemi:** Mimari destekliyor ama ilk sürüme dahil değil; launch sonrası retention verisiyle karar verilecek.
