# İçerik Haritası — "Hangi iş için hangi dosya"

Bu dosyanın tek amacı: bir iş için repoyu taramak zorunda kalmamak.
Aşağıdaki tablodan işini bul, **sadece** listelenen dosyaları aç.

---

## Sık yapılan işler

| İstek | Dokunulacak dosyalar | Skill |
|---|---|---|
| **Yeni level / sektör ekle** | `assets/content/levels/sector_NN.json`, `assets/content/sectors.json` | `/rw-add-level` |
| **Level dengele (zorluk, ödül)** | sadece ilgili `sector_NN.json` | `/rw-add-level` |
| **Yeni düşman ekle** | `assets/content/enemies.json`, (gerekirse) `lib/engine/simulation/behaviors/<ad>_behavior.dart`, `lib/content/registry/content_registry.dart` | `/rw-add-enemy` |
| **Yeni savunma birliği ekle** | `assets/content/units.json`, (gerekirse) behavior, registry | `/rw-add-unit` |
| **Yeni upgrade ekle** | `assets/content/upgrades.json`, (yeni davranış ise) `lib/domain/rules/behavior_flags.dart` | `/rw-add-upgrade` |
| **Eşik kartı ekle / eşik değiştir** | `assets/content/upgrades.json`, ilgili `sector_NN.json` (`upgradeKillThresholds`), `lib/engine/simulation/systems/upgrade_system.dart`, `lib/domain/rules/upgrade_pool.dart`, `lib/features/battle/viewmodel/upgrade_text.dart` | `/rw-add-upgrade` |
| **Yeni boss ekle** | `assets/content/bosses.json`, `lib/engine/simulation/systems/boss_system.dart` | `/rw-add-boss` |
| **Yeni yetenek ekle** | `assets/content/abilities.json`, `lib/engine/simulation/systems/ability_system.dart` | — |
| **Kale/harita objesi ekle veya değiştir** | `assets/content/castles.json`, `assets/content/environments.json` | `/rw-add-level` |
| **Arazi alanı davranışı değiştir (slow/cover)** | `lib/engine/simulation/systems/terrain_system.dart` | — |
| **Harita render'ını değiştir** | `lib/engine/render/map_renderer.dart` | — |
| **Mağaza ürünü ekle/değiştir** | `assets/content/store.json`, `lib/core/services/iap_service.dart` | — |
| **Meta upgrade ekle** | `assets/content/meta_upgrades.json` | — |
| **Görsel kural / renk-tipografi-dekorasyon token'ı** | `docs/DESIGN.md` (kural), `lib/app/theme/*` (uygulama) | — |
| **UI geçiş görevi / ilerleme** | `docs/UI_MIGRATION_PLAN.md` (§0 ilerleme, §4 görev tanımı) | — |
| **Ortak UI bileşeni kullan/değiştir** | `lib/shared/widgets/*` (yeni bileşen eklenince buraya satır eklenir) | — |
| **Yeni dil metni ekle** | `lib/l10n/arb/app_en.arb` (şablon) + diğer 15 ARB, sonra `flutter gen-l10n` | — |
| **Renk / yazı tipi / ölçü değiştir** | `lib/app/theme/` (4 dosya) | `/rw-ui-integrate` |
| **Gemini tasarımını bağla** | `lib/app/theme/`, `lib/features/<ekran>/view/`, `lib/shared/widgets/` | `/rw-ui-integrate` |
| **Sprite/ikon işle** | `tools/assetkit/`, `docs/ASSET_PROMPTS.md` | `/rw-assets` |
| **Görsel üret / işle** | `docs/ASSET_PROMPTS.md`, `tools/assetkit/`, `design/art_intake/` | `/rw-assets` |
| **Reklam yerleşimi değiştir** | `lib/core/services/ad_service.dart`, ilgili `features/*/viewmodel` | — |
| **Performans sorunu (FPS)** | `lib/engine/simulation/`, `lib/engine/render/`, level JSON'undaki `maxEnemies` | — |
| **Açılış yön kapısı** | `lib/features/orientation_gate/`, `lib/core/services/orientation_service.dart`, `lib/app/router/app_router.dart` | — |

---

## Katman sorumlulukları

```
lib/app/        Uygulama kabuğu: tema, router, locale, bootstrap sırası
lib/core/       Platform servisleri (storage, audio, haptic, ads, iap) + yardımcılar
lib/content/    JSON şemaları, loader, registry — içeriğe TEK erişim noktası
lib/domain/     Saf oyun kuralları. Flutter import'u YOK.
lib/data/       Kayıt, meta ilerleme, cüzdan. Repository'ler.
lib/engine/     Flame + simülasyon. Widget import'u YOK.
lib/features/   MVVM ekranlar (view / viewmodel / widgets)
lib/shared/     Ekranlar arası ortak widget'lar
```

**Bağımlılık yönü tek taraflıdır:**
```
features ──▶ domain, content, data, core
engine   ──▶ domain, content, core
domain   ──▶ (hiçbir şey)
```
Ters yönde bir import görürsen bu bir hatadır.

---

## Motorun kritik dosyaları

Bunlar "load-bearing"dir; değiştirmeden önce dosya başındaki doc yorumunu oku.

| Dosya | Ne yapar |
|---|---|
| `engine/simulation/battle_simulation.dart` | Sabit adımlı döngü, zaman ölçeği, pause/slow-mo |
| `engine/simulation/battle_system.dart` | Sistem sözleşmesi + **faz sırası** |
| `engine/simulation/pools/entity_pool.dart` | Yoğun havuz, swap-remove, deferred cikarma |
| `engine/simulation/spatial/spatial_hash_grid.dart` | Yakınlık sorguları, sıfır allocation |
| `engine/bridge/battle_signals.dart` | Motor → HUD tek köprü + UI → motor komut arayüzü |
| `core/constants/game_constants.dart` | Yapısal sabitler (adım süresi, throttle, hücre boyutu) |

---

## İçerik dosyaları

```
assets/content/
├── units.json            savunma birlikleri
├── enemies.json          Riftborn arketipleri
├── elites.json           elite varyant kuralları
├── bosses.json           boss tanımları + faz makineleri
├── upgrades.json         savaş içi upgrade havuzu
├── abilities.json        aktif yetenekler
├── modifiers.json        battlefield modifier'ları
├── sectors.json          10 sektör: ortam, palet, rift görünümü
├── castles.json          kale tipleri: sprite, konum, duvar sınırı, savaşçı yuvaları
├── environments.json     zemin + dekor öğeleri (dağ, ağaç, bina vb.)
├── meta_upgrades.json    kalıcı ilerleme (Rift Shard ile)
├── store.json            IAP + soft currency ürünleri
└── levels/
    └── sector_01.json … sector_10.json    (5'er level)
```

Her JSON değişikliğinden sonra:
```bash
flutter test test/content_validation_test.dart
```
