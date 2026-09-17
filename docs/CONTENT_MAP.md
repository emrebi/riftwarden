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
| **Malzeme yuzeyi (parchment/wood/stone/hud) kullan** | `lib/shared/widgets/rw_material_surface.dart` | — |
| **Buton kullan/değiştir (RwButton)** | `lib/shared/widgets/rw_button.dart` (`RwMaterialSurface` uzerine kurulu) | — |
| **Ikon buton kullan/değiştir (RwIconButton)** | `lib/shared/widgets/rw_icon_button.dart` (`RwMaterialSurface(shape: circle)` uzerine kurulu) | — |
| **Panel kullan/değiştir (RwPanel)** | `lib/shared/widgets/rw_panel.dart` (`RwMaterialSurface` uzerine kurulu; `RwPanelVariant`: standard/large/modal/smallInfo) | — |
| **Modal iletisim penceresi kullan/değiştir (RwDialog)** | `lib/shared/widgets/rw_dialog.dart` (`RwPanel(variant: modal)` + `RwVeil` uzerine kurulu) | — |
| **Kart kullan/değiştir (RwCard)** | `lib/shared/widgets/rw_card.dart` (`RwMaterialSurface` uzerine kurulu; `RwCardKind`: standard/defender/upgrade, `RwCardState`: standard/selected/locked/disabled) | — |
| **Ilerleme/can cubugu kullan/değiştir (RwProgressBar)** | `lib/shared/widgets/rw_progress_bar.dart` (el yapimi malzeme izi; `RwProgressVariant`: neutral/health/cooldown) | — |
| **Segmentli (dalga) ilerleme kullan/değiştir (RwSegmentedProgress)** | `lib/shared/widgets/rw_segmented_progress.dart` | — |
| **Para birimi gostergesi kullan/değiştir (RwCurrencyChip)** | `lib/shared/widgets/rw_currency_chip.dart` (`RwMaterialSurface(shape: pill)` uzerine kurulu; `RwCurrency`: aether/shard/cell) | — |
| **Sahne ustu karartma/veil kullan (RwVeil)** | `lib/shared/widgets/rw_veil.dart` (upgrade overlay BATTLE-01, pause BATTLE-08 kullanir) | — |
| **Esik karti (upgrade) secim katmani kullan/değiştir (UpgradeChoiceOverlay)** | `lib/features/battle/widgets/upgrade_choice_overlay.dart` (`RwVeil` + `RwCard(kind: upgrade)` uzerine kurulu; `lib/features/battle/view/battle_screen.dart` ve `lib/engine/simulation/systems/upgrade_system.dart` ile baglanir; ilustrasyon: `assets/images/ui_art/illustrations/<upgrade.icon>.webp`, tarif `illustrations.json`) | — |
| **Savunmaci yuvasi kullan/değiştir (RwDefenderSlot)** | `lib/shared/widgets/rw_defender_slot.dart` (`RwMaterialSurface(material: stone)` uzerine kurulu; `RwDefenderSlotState`: empty/available/selected/locked/purchaseable/unaffordable/occupied; portre: `assets/images/ui_art/portraits/<unitId>.webp`, tarif `portraits.json`) | — |
| **Yetenek cercevesi/cooldown ring kullan/değiştir (RwAbilityFrame)** | `lib/shared/widgets/rw_ability_frame.dart` (`RwMaterialSurface(shape: circle, material: stone)` uzerine kurulu; `RwAbilityState`: ready/cooldown/targeting/unavailable; ikon: `assets/images/ui_art/icons/<ability icon>.webp`, tarif `rift_collapse.json`) | — |
| **Acma/kapama anahtari kullan/değiştir (RwToggle)** | `lib/shared/widgets/rw_toggle.dart` (`RwMaterialSurface(shape: pill)` track + `circle` knob; SEC-02'de `SettingsSwitchRow` icindeki Material `Switch`'in yerine gecti) | — |
| **Susleme parcasi kullan/ekle (RwOrnament)** | `lib/shared/widgets/rw_ornament.dart` (`RwOrnament` tek parca, `RwSurfaceOrnaments` malzeme on ayari; RwPanel/RwCard `showOrnaments` ile kapatilir), `assets/images/ui_art/ornaments/`, tarif `tools/assetkit/recipes/ornaments.json` | — |
| **Ikon kullan/ekle (RwIcon)** | `lib/shared/widgets/rw_icon.dart`, `assets/images/ui_art/icons/` (raster, tarif tools/assetkit/recipes/icons.json; dosya yoksa Material glyph fallback) | — |
| **UI gorseli goster (RwArt)** | `lib/shared/widgets/rw_art.dart`, `assets/images/ui_art/<grup>/<id>.webp` | — |
| **Ekran iskeleti kullan/değiştir (RwScreenScaffold)** | `lib/shared/widgets/rw_screen_scaffold.dart` (baslik seridi `RwMaterialSurface(material: wood)` uzerine kurulu; `background` katmani ileride `RwArt(group: scenes)`) | — |
| **Ana menü ekranı kullan/değiştir** | `lib/features/main_menu/**` (sanat: ui_art/logo/main_menu, ui_art/scenes/main_menu (tarifler logo.json, scenes.json)) | — |
| **Sonuç ekranı kullan/değiştir** | `lib/features/result/**` (sanat: ui_art/illustrations/result.victory\|result.defeat (tarif result.json)) | — |
| **Bolum basligi kullan/değiştir (RwSectionHeader)** | `lib/shared/widgets/rw_section_header.dart` (`onDark` ile HUD/koyu zemin varyanti) | — |
| **Sayı/para/süre biçimlendir (locale)** | `lib/shared/format/rw_number_format.dart` | — |
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
