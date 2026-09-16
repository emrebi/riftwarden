# Görsel üretim prompt'ları — el yapımı çizgi film yönü

Bu dosya Codex görsel-üretim agent'ına verilecek hazır prompt'ları tutar.
Görsel otorite `docs/DESIGN.md`'dir; buradaki her prompt DESIGN.md §2, §3,
§16–19, §21, §25, §27'nin türetilmiş halidir. Üretilen görseller
`tools/assetkit` ile işlenir — bu yüzden **teknik kurallar pazarlık konusu
değildir**, onlar olmadan kesme/atlas paketleme bozulur.

Bu dosya artık eski web tabanlı üretici + zip indirme akışını değil, Codex
görsel-üretim agent'ını tarif eder (bkz. "Workflow"). Prompt metinlerinin
dili İngilizce kalır çünkü üretim modeli İngilizce prompt'ta daha tutarlı
sonuç verir; bu dosyanın kendi açıklama metni Türkçedir.

---

## STYLE BIBLE — her prompt'un başına aynen yapıştır

> **Art direction:** Warm, adventurous, hand-drawn 2D cartoon world. Small,
> expressive defenders protect an improvised ancient fortress from strange
> dimensional creatures. The science-fantasy element comes from impossible
> rifts, floating geography, unusual organisms, and relic-like mechanisms —
> never circuitry, military hardware, or holographic interfaces.
> Cartoon exaggeration is moderate: heads, hands, tools, eyes, and
> role-defining equipment may be enlarged for recognition, while bodies keep
> enough structure to animate and read in battle. Shapes are bold, poses are
> expressive, surfaces use restrained cel shading, and linework is slightly
> imperfect without becoming noisy — a bold dark keyline with a lighter inner
> edge or material seam.
> Palette: a sunlit, lived-in fortress world. Friendly energy is blue/cyan,
> hostile dimensional (Rift) energy is violet/magenta used sparingly as accent
> — not broad body glow — and warm amber is reserved for emphasis and reward
> moments.
> Explicit anti-goals: hard sci-fi, cyberpunk, holograms, glassmorphism,
> black high-contrast tech dashboards, military robots, realistic medieval fantasy, generic
> crystal fantasy, glossy generic mobile RPG framing, anime/chibi conventions,
> excessive purple/cyan coverage, excessive glow or gradients, perfect
> symmetry, corporate vector UI, gore, horror realism, zombies, realistic
> armor, soldiers, tanks, guns, or camouflage.
> Every subject must be instantly distinguishable from related subjects by
> silhouette alone at small size on a phone screen. Designs must be original —
> do not imitate any existing game, cartoon, franchise, or artist.

---

## TECHNICAL RULES — dört teslim tipi

Her prompt hangi tipte teslim istediğini söyler; ilgili blok prompt'un sonuna
aynen eklenir. Tip, hedef `tools/assetkit` grubunun tarifine (`chroma` alanı)
bağlıdır — bkz. `tools/assetkit/README.md` "Hedef boyutlar ve teslim".

### Tip A — Chroma sheet (gruplar: `units`, `enemies`, `fx`)

> **Output format (mandatory):**
> - Single image, one strict grid, equal cell size, objects centered in cells.
> - Background must be **flat pure magenta #FF00FF** across the entire image.
>   Absolutely uniform — no gradient, no vignette, no texture, no noise.
> - **No drop shadow or glow may touch the background.** Any shadow or outer
>   glow must be removed entirely. The subject must end at its own edge.
> - At least **40 pixels of clean magenta space** between every object and
>   between objects and the image border.
> - No text, no labels, no numbers, no captions, no borders, no frames,
>   no watermark, no UI elements, no ground plane, no scene, no background
>   props of any kind.
> - Render at high resolution.

> **Neden:** Arka plan chroma key ile silinecek (`chroma: true`). Magenta'ya
> değen gölge/glow silinince kirli kenar bırakır; objeler arası boşluk
> yetersizse otomatik dilimleyici iki objeyi tek parça sanır.

### Tip B — Transparent sheet / tekil obje (grup: `world`)

> **Output format (mandatory):**
> - Real alpha transparency around every subject — **not** a magenta or any
>   solid-color background. The canvas outside the subject(s) must be fully
>   transparent.
> - If more than one subject is in the same image: equal grid, subjects
>   centered in cells, at least **40 pixels of fully transparent space**
>   between every object and between objects and the image border.
> - No drop shadow or glow may touch the transparent edge; the subject must
>   end cleanly at its own silhouette.
> - No text, no labels, no borders, no frames, no watermark, no ground plane,
>   no background scenery.
> - Render at high resolution.

> **Neden:** `world` tarifinde `chroma: false` — dilimleyici alfa kanalına
> bakar, chroma key'e gerek yoktur ama bunun için görüntü zaten seffaf
> gelmelidir. Magenta zeminle teslim edilirse silinmeden atlas'a girer.

### Tip C — Tek dosya, seffaf, UI sanatı (gruplar: `portraits`, `illustrations`,
`icons`, `ornaments`, `logo`) — `ART-PREP` bu grupların tariflerini oluşturana
kadar hedef, sonraki işleme adımı için doğru üretilmiş dosyayı bekletmektir.

> **Output format (mandatory):**
> - One subject per image, real alpha transparency around it (no magenta, no
>   solid background).
> - Generous quiet margin on every side (at least 10% of canvas) so the image
>   can be safely cropped/cornered into a card, button, or frame without
>   clipping the subject.
> - No text baked into the image (localization renders text separately).
> - No drop shadow baked in unless the prompt explicitly asks for one; the
>   engine/UI composites its own shadow per DESIGN.md §21.
> - Render at high resolution; the processing step downsizes, never upsizes.

> **Neden:** Bu dosyalar atlas'a değil, tek tek `assets/images/ui_art/<grup>/`
> altına WebP olarak yazılacak (`RwArt`, bkz. UI_MIGRATION_PLAN AQ-1/AQ-2).
> Fazla dolu kadraj, kart/çerçeve kırpmasında konuyu keser.

### Tip D — Tam sahne / geniş arka plan (gruplar: `background` içindeki
sektör zeminleri, ve gelecekteki `scenes` UI grubu)

> **Output format (mandatory):**
> - Single wide **landscape 16:9** (or wider-safe) painted scene, opaque —
>   no transparency needed, this image is the background itself.
> - No characters, no props that must align pixel-exactly with gameplay
>   content, no UI, no text, no vignette or frame that would clash with
>   foreground elements composited on top.
> - Consistent light direction and readable value corridor across the whole
>   width (see the specific subject's own composition notes below).
> - Must extend/blend smoothly toward the edges for wide-device safe
>   extension.

> **Neden:** Bu görüntüler `chroma: false`, `slice: none` ile tek parça
> alınır (`background` tarifi) ve doğrudan lossy WebP'e basılır — kesme
> yapılmaz, tam görüntü kullanılır.

---

## Subject prompts (ART-01 … ART-13, sırasıyla `docs/UI_MIGRATION_PLAN.md` §5)

Her ART-ID'nin çıktısı `design/art_intake/<ART-ID>/` altına PNG olarak
kaydedilir (bu klasör commit edilmez — bkz. `.gitignore`). Planner onayından
sonra ilgili `assetkit` komutu çalıştırılır. FONT-01 hariç (üretim değil,
tedarik/lisans işi, bu dosyada prompt'u yok).

### ART-01 — Logo / wordmark + Rift-Warden amblem · Tip C (`logo`)

Style bible + aşağıdaki + Tip C.

> Create the RIFTWARDEN logo/wordmark and a companion circular Rift-Warden
> emblem mark, as two separate images. The wordmark is hand-lettered, bold,
> slightly uneven strokes consistent with the fortress world's carved-wood
> and painted-banner signage — not a sleek corporate sci-fi font. The emblem
> is a circular mark combining a stylized shield/ward shape with a small
> violet rift tear motif at its center, readable at small size (app icon
> scale) as well as large (main menu). No other localized text anywhere.

İşleme: onaydan sonra `ui_art` recipe hazır olduğunda (`ART-PREP` sonrası)
`assets/images/ui_art/logo/wordmark.webp` ve `assets/images/ui_art/logo/emblem.webp`.

### ART-02 — UI ornament kit · Tip C (`ornaments`)

Style bible + aşağıdaki + Tip C (her parça kendi dosyasında, tek obje).

> Create a small kit of reusable transparent UI ornament pieces matching a
> warm hand-drawn fortress-world interface (wood, parchment, stone, cloth):
> a wood board end cap, a wood peg/nail, a parchment torn corner, a parchment
> fold/tear edge strip, a stone corner cap, a cloth/banner tapered tail, and
> a selection marker (a small hand-painted ring/star burst used to highlight
> a chosen card or slot). Each piece is its own image, quiet edges, no full
> panel, no baked text — these are small reusable trims composited by code
> around code-native panels, not full painted frames.

### ART-03 — Icon family (24–48 dp) · Tip C (`icons`)

Style bible + aşağıdaki + Tip C (her ikon kendi dosyasında).

> Create a family of simple, bold, irregular-outline flat game icons, one
> subject per image, consistent stroke weight and corner treatment across
> the whole set, each legible at 24 dp inside a 48 dp control: aether (blue/
> cyan droplet or contained magical mote), rift shard (violet spiral/tear),
> aether cell (contained energy cell), attack (simple sword/impact mark, not
> realistic military styling), support (plus/leaf/ward form), area (burst
> with a few large rays), utility (gear-like improvised relic mark, not
> industrial chrome), magic (Rift curl/orb), health (heart/shield/Core mark),
> lock (chunky padlock silhouette), level (star/badge), settings (readable
> gear), pause (two broad bars), back (broad directional arrow), info
> (enclosed clear information mark), plus (simple plus), close (simple X),
> check (simple checkmark). No thin line icons, no glossy 3D gems, no mixed
> perspective, no text.

### ART-04 — Defenders: portraits + gameplay sprites · Tip C (`portraits`) + Tip A (`units`)

Style bible + aşağıdaki. Deliver as two separate requests.

**Portraits (Tip C, one file per unit):**
> Create three character portraits, one per image, for the allied defenders
> `pulse_guard`, `arc_ranger`, `titan_frame`. Pulse Guard: compact and
> numerous, a small friendly trooper with simple round armor plates and a
> shoulder-mounted relic emitter. Arc Ranger: slender, tall, a long carved
> tuning-fork relic weapon with a thin arc of contained energy between its
> prongs, light improvised gear. Titan Frame: broad and heavy, thick layered
> repaired plating, two wide ground-slam arms, low center of gravity, a
> warm-glowing relic core visible on its chest. Playful proportions,
> expressive face/pose, grouped local colors, limited material count, bold
> outline, restrained cel shading. Their equipment looks magical, ancient,
> biological, repaired, or improvised — never military, industrial, robotic,
> or firearm-realistic. Portrait framing may add expression and detail but
> each must remain recognizably the same character as its gameplay sprite.

**Gameplay sprites (Tip A, one sheet, `units` group):**
> Create a **3 columns x 1 row** sheet of the same three defenders
> (`pulse_guard`, `arc_ranger`, `titan_frame`) at gameplay scale: full body,
> facing right (toward the battlefield), simplified equipment detail so the
> role silhouette reads at small size, same design language as the portraits
> above.

### ART-05 — Enemies gameplay sprites · Tip A (`enemies`)

Style bible + aşağıdaki + Tip A.

> Create a **4 columns x 2 rows** sheet (7 creatures, last cell empty/
> transparent) of the seven Riftborn enemy archetypes, full body, facing
> left (toward the fortress), each visibly different in mass and motion so
> they stay distinguishable mid-swarm:
> 1. **drifter** — the common one, medium size, hovering slightly, a simple
>    dark organic husk with a small restrained violet glow at its core.
>    Reads as "basic enemy".
> 2. **skitter** — very fast, fragile, small, low, several thin legs, a
>    sharp forward-leaning body. Reads as "this thing is quick".
> 3. **bulwark** — huge, wide, heavy, thick stone-like plating covering most
>    of its body, tiny head, slow and immovable. Reads as "wall".
> 4. **splitter** — bulbous segmented body with small shapes faintly visible
>    under its skin, looks ready to burst.
> 5. **phaseborn** — partially translucent, part of its body fading into
>    faint violet static/particles. Reads as "hard to hit".
> 6. **leech** — long tendril-arms, a wide draining mouth, hunched forward
>    posture, a thin amber energy thread visibly being pulled toward it.
> 7. **spawner** — stationary, bloated, rooted with plant-like anchoring
>    limbs, small openings on its back from which tiny creatures emerge.
> All seven share the same species language: dark organic/stone bodies with
> restrained Rift-violet accents — never full-body purple glow. They can be
> funny in pose or expression and threatening in behavior; no gore, no
> horror realism, no zombies, no realistic armor, no military motifs.

### ART-06 — Fortress / citadel with 6 visible slot positions · Tip B (`world`)

Style bible + aşağıdaki + Tip B.

> Create a single fortress structure (`citadel_basic`) meant to stand at the
> left edge of a battlefield facing right, viewed from a slightly elevated
> front-leaning angle consistent with a hand-drawn 2D battlefield scene. It
> is old, improvised, inhabited, warm, and repaired — timber patches, rope,
> banners, lived-in details — not a sleek sci-fi structure. It has **six
> visible platform/ledge positions** on its upper section where defenders
> can be seen standing, readable as "six troops can garrison here" even
> without units present (railings, small platforms, or worn footholds). A
> sturdy wall section faces right, toward where enemies approach. Silhouette
> must read instantly as "home base to defend" at small size.

### ART-07 — Battlefield background 16:9 + wide extension · Tip D (`background`)

Style bible (adapted) + aşağıdaki + Tip D.

> Create a single wide **landscape 16:9** background for the `fractured_edge`
> battlefield: the ground the battle takes place on, seen from the same
> slightly elevated angle as the fortress. A sunlit, lived-in, slightly
> broken/floating terrain edge with warm ground colors, soft directional
> light from the upper-left, no characters, no props, no UI, no text. Leave
> a clean, uncluttered horizontal combat lane between where the fortress
> (left) and the rift (right) will be composited, so decor placed on top
> stays readable and does not look targetable or obscure feet/projectiles.
> Must blend smoothly toward the left/right edges for safe extension on
> wider devices.

### ART-08 — Main menu environment scene 16:9 + wide extension · Tip D (`background`, later `scenes`)

Style bible (adapted) + aşağıdaki + Tip D.

> Create a single wide **landscape 16:9** main-menu environment scene: an
> inviting establishing view of the fortress world at rest — warm sunlit sky,
> the fortress silhouette in the distance, gentle atmospheric depth — with
> enough calm negative space in the lower/side thirds for menu buttons and
> the logo to be composited on top later. No UI, no text, no characters in
> the foreground, no vignette that would clash with foreground UI. Must
> extend/blend smoothly toward the edges for wide-device safe extension.

### ART-09 — Rift portal ring + Rift Collapse icon/illustration + targeting reticle

Style bible + Tip B for the portal, Tip C for the icon/illustration/reticle.

**Rift portal (Tip B, `world`):**
> Create a single **Rift portal** — a jagged vertical tear in space that
> stands at the right edge of the battlefield (a spawn-flavor element, not a
> gameplay waypoint), made of an ancient stone/ring frame with unstable
> violet dimensional energy bleeding from its center. Reads instantly as
> "this is where the enemies come from," consistent with the restrained
> Rift-violet accent used elsewhere (not full-scene magenta bloom).

**Rift Collapse ability icon (Tip C, `icons`) and illustration (Tip C, `illustrations`) and targeting reticle (Tip C, `icons`):**
> Create three separate images for the `rift_collapse` ability: (1) a small
> icon — a simple violet Rift curl/orb consistent with the icon family style;
> (2) a larger square-safe illustration of the ability's effect (a controlled
> ring of violet energy collapsing inward on the battlefield) with quiet
> edges for card cropping; (3) a flat top-down targeting reticle ring in the
> same restrained violet accent, sparse particles, no page-wide glow.

### ART-10 — Upgrade illustrations per icon id · Tip C (`illustrations`)

Style bible + aşağıdaki + Tip C (one file per id).

> Create one square-safe illustration per upgrade, quiet edges for card
> cropping, each clearly depicting its effect through the fortress-world
> visual language (relic mechanisms, restrained energy accents, no sci-fi
> circuitry): `upgrade_chain` (chained energy arcing between targets),
> `upgrade_pierce` (a bolt punching through multiple foes in a line),
> `upgrade_crit` (a bright starburst impact), `upgrade_explosion` (a
> contained blast ring), `upgrade_swarm` (many small projectiles fanning
> out), `upgrade_economy` (an aether coin/mote bundle), `upgrade_core` (a
> warm glowing core/heart with a protective ward), `upgrade_pulse_dualshot`
> (twin pulse bolts side by side), `upgrade_pulse_overcharge` (a single
> oversized charged pulse bolt), `upgrade_arc_overcharge` (a thick, longer
> arcing bolt of energy), `upgrade_arc_focus` (a narrow, precise focused
> energy beam), `upgrade_titan_shockwave` (a ground-slam shockwave ring),
> `upgrade_titan_juggernaut` (a heavier, armored silhouette cue). Each icon
> id is visually distinct from the others at a glance.

### ART-11 — Environment props · Tip B (`world`)

Style bible + aşağıdaki + Tip B. Replaces the current `crystal_rock_a`,
`crystal_rock_b`, `energy_pylon`, `ruin_a`, `alien_tree_a`, `mountain_a`
decor set, which reads as generic crystal-fantasy and conflicts with
DESIGN.md's anti-goals. See "Önerilen yeni dekor id'leri" in the task report
for the replacement id list and their mapping to these prompts.

> Create a **4 columns x 2 rows** sheet (8 objects, extra cells empty/
> transparent) of purely decorative fortress-world battlefield scenery
> props, matching the fortress and battlefield's warm hand-drawn language —
> vegetation, ruins, floating land, distant towers, cloth, and small worn
> structures, **no generic crystal formations**:
> 1. **mossy_ruin_arch** — a broken stone archway fragment softened by moss
>    and hanging vines.
> 2. **broken_bridge_plank** — a snapped section of an old wooden bridge,
>    jutting out at an angle, rope still attached.
> 3. **floating_isle_root** — a small chunk of floating ground with exposed
>    roots and dangling dirt underneath, drifting just above the lane.
> 4. **watch_tower_distant** — a leaning, weathered wooden watchtower
>    silhouette piece, distant-scale.
> 5. **banner_post** — a worn wooden post flying a torn cloth banner.
> 6. **lantern_post** — an old iron-and-wood lantern post with a warm
>    firelight glow (no electric/energy styling).
> 7. **gnarled_tree** — a gnarled, character-filled tree with a warm
>    autumn-toned canopy.
> 8. **rift_touched_stone** — a cracked stone slab with one thin, restrained
>    violet Rift crack running through it — the only piece carrying a Rift
>    accent, used sparingly near the rift side of the lane.
> All eight share the same warm, lived-in, slightly imperfect material
> language described in the style bible.

### ART-12 — VFX: hit, death puff, aether mote, core impact, ability blast, projectiles · Tip A (`fx`)

Style bible + aşağıdaki + Tip A.

> Create a **5 columns x 3 rows** sheet of restrained, gameplay-readable game
> effects, each centered in its own cell, viewed straight-on:
> Row 1 — projectiles: a friendly cyan pulse bolt, a piercing white-hot
> lance, a short arcing energy segment, an amber explosive orb, a small
> violet enemy spit.
> Row 2 — impacts: a small cyan hit spark, a warm orange explosion burst, an
> electric chain burst, a small violet Rift impact puff (enemy death), a
> white critical-hit starburst.
> Row 3 — field effects: a circular cyan shield-ward dome, an amber aether
> pickup mote, a flat red top-down danger warning ring, a frost/slow crystal
> burst (small, restrained — not a generic crystal prop), a green healing
> pulse ring.
> All effects read as controlled, hand-drawn energy — bright cores fading to
> soft edges that still end cleanly (no bleeding into transparency), never a
> broad screen-covering bloom.

### ART-13 — Result victory/defeat accents · Tip C (`illustrations` or `scenes`)

Style bible + aşağıdaki + Tip C.

> Create two small accent illustrations for the result screen, one for
> victory (a warm, triumphant beat — e.g. a banner unfurl or a bright
> restrained burst around the fortress emblem) and one for defeat (a somber
> but not grim beat — e.g. a dimmed lantern or a torn banner), each
> square-safe with quiet edges, no text, consistent with the fortress
> world's hand-drawn material language.

---

## Codex'ten görsel alma

Görseller üretildikten sonra Codex, çıktı PNG dosyalarını doğrudan
`design/art_intake/<ART-ID>/` altına kaydeder (bu klasör commit edilmez —
bkz. `.gitignore`). Zip indirme/yükleme adımı yoktur; Codex bir görsel-üretim
agent'ı olarak yerel dosya sistemine yazar.

---

## Workflow

1. Planner, `docs/UI_MIGRATION_PLAN.md` §5'teki önerilen sıraya göre tek bir
   ART görevi verir (örn. "ART-03'ü üret").
2. Codex ham çıktıları `design/art_intake/<ART-ID>/` altına PNG olarak
   kaydeder (commit edilmez).
3. Planner çıktıyı `docs/DESIGN.md` ve ilgili yüzeye özgü referansa
   (`design/references/0X_*.png`, bkz. DESIGN.md §26) göre denetler; onaylar
   veya yeniden ürettirir.
4. Onaylanan çıktılar `assetkit` ile işlenir:
   - Oyun içi atlaslar (`units`, `enemies`, `fx`, `world` grupları) —
     `tools/assetkit/README.md`'deki komutlarla.
   - Dosya başı UI sanatı `assets/images/ui_art/<grup>/<id>.webp` altına
     (gruplar: `portraits`, `illustrations`, `icons`, `ornaments`, `logo`,
     `scenes`) — bu grupların tarifleri `ART-PREP` görevinde oluşturulur.
5. `python tools/assetkit/assetkit.py verify`, sonra ilgili `ARTINT-*` görevi
   entegrasyonu yapar.

Önerilen sıra: `docs/UI_MIGRATION_PLAN.md` §5.

---

## Sorun giderme

| Belirti | Sebep | Çözüm |
|---|---|---|
| Beklenenden az parça çıktı | Objeler birbirine değiyor | Tarifte `min_gap` düşür, ya da `"slice":"grid"` + `cols`/`rows` ver |
| Beklenenden çok parça çıktı | Bir objenin parçaları ayrı algılandı | `min_gap` artır |
| Kenarlarda mor/renkli hale | Gölge arka plana değmiş (Tip A) veya alfa kenarı temiz değil (Tip B/C) | Codex'e gölgesiz/temiz kenarlı yeniden ürettir; ya da Tip A için `tolerance` artır |
| Sprite'ın kendi rengi silindi | Sprite rengi #FF00FF'e çok yakın (sadece Tip A) | `tolerance` düşür (ör. 40) |
| Arka plan tam silinmedi (Tip A) | Gradyanlı/gürültülü zemin | `tolerance` artır (ör. 100); kalıcıysa düz zeminle yeniden ürettir |
| `world` grubunda obje bulunamadı | Görüntü chroma zeminle geldi ama tarif `chroma:false` | Codex'e gerçek alfa şeffaflığıyla yeniden ürettir (Tip B) |
