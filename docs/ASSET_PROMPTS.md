# Gorsel uretim prompt'lari — tek yapistirma (web ChatGPT)

Bu dosya web ChatGPT'ye **tek parca** yapistirilacak hazir prompt'lari tutar.
Gorsel otorite `docs/DESIGN.md`'dir; her prompt DESIGN.md SS2, SS3, SS16-19,
SS21, SS25, SS27'nin turetilmis halidir. Uretilen gorseller `tools/assetkit`
ile islenir. Prompt metinlerinin dili Ingilizce'dir; bu dosyanin kendi
aciklama metni Turkce'dir.

## Nasil kullanilir

1. Web ChatGPT'de yeni bir sohbet ac, `design/references/05_UI_DESIGN_SYSTEM.png`
   dosyasini ve asagida ilgili ART bolumunde yazan yuzeye ozgu referans
   dosyasini yukle.
2. Ayni bolumdeki tek kod blogunu **aynen** yapistir. Baska hicbir ek metin
   gerekmez — stil kurallari, yasakli motifler ve teslim formati prompt'un
   icine gomulmustur.
3. ChatGPT'nin dondurdugu zip'i `design/art_intake/<ART-ID>.zip` olarak
   kaydet (bu klasor commit edilmez — bkz. `.gitignore`). **Zip'i repo
   kokune kaydetme.**
4. `design/art_intake/<ART-ID>/` altina cikart, planner'a haber ver.

---

### ART-01 — Logo / wordmark + Rift-Warden amblem

Upload: 05_UI_DESIGN_SYSTEM.png + 01_MAIN_MENU.png
Zip: ART-01.zip

```
Create two original images for my mobile game RIFTWARDEN, matching the uploaded UI design system image and main menu reference: (1) the RIFTWARDEN logo/wordmark, (2) a companion circular Rift-Warden emblem mark.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. Small expressive defenders protect an improvised ancient fortress from strange dimensional Riftborn creatures. Science-fantasy comes from impossible rifts, floating geography, unusual organisms and relic-like mechanisms — never circuitry, military hardware, or holographic interfaces. Bold shapes, restrained cel shading, a bold dark keyline with a lighter inner edge or material seam, linework slightly imperfect but not noisy. Palette: sunlit lived-in fortress world; friendly energy blue/cyan; hostile Rift energy violet/magenta used sparingly as accent; warm amber reserved for emphasis. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, glassmorphism, black high-contrast tech dashboards, military robots, realistic medieval fantasy, generic crystal fantasy, glossy generic mobile RPG framing, anime/chibi conventions, excessive glow or gradients, perfect symmetry, corporate vector UI, sleek corporate sci-fi lettering.
SUBJECTS: (1) wordmark "RIFTWARDEN" — hand-lettered, bold, slightly uneven strokes consistent with the fortress world's carved-wood and painted-banner signage. (2) emblem — a circular mark combining a stylized shield/ward shape with a small violet rift tear motif at its center, readable at small size (app icon scale) as well as large (main menu). No other localized text anywhere.
LAYOUT: one subject per image, real alpha transparency (no magenta, no solid background), generous quiet margin on every side (at least 10% of canvas) so it can be cropped into a card/button/frame without clipping, no drop shadow baked in. Render at high resolution.
DELIVERY: put both PNGs in a zip named ART-01.zip and give me the zip.
```

### ART-02 — UI ornament kit

Upload: 05_UI_DESIGN_SYSTEM.png + 03_UPGRADE_CHOICE.png
Zip: ART-02.zip

```
Create ONE original ornament sheet for my mobile game RIFTWARDEN, matching the uploaded UI design system image and upgrade-choice card reference. These are small reusable UI trims composited by code around code-native panels, not full painted frames.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art (wood, parchment, stone, cloth). Bold shapes, restrained cel shading, a bold dark keyline with a lighter inner edge or material seam, linework slightly imperfect but not noisy. Palette: sunlit lived-in fortress world; friendly energy blue/cyan; hostile Rift energy violet/magenta used sparingly as accent; warm amber reserved for emphasis. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, glassmorphism, corporate vector UI, excessive glow or gradients, perfect symmetry, full painted panel/frame (pieces only), text or letters.
LAYOUT: one image, flat pure magenta #FF00FF background everywhere, 4 columns x 2 rows grid, wide equal gaps between pieces, each piece centered in its cell with empty margin, nothing touching cell edges, no shadow or glow touching the background. Fill row by row in this exact order (last cell empty):
1 board_end_cap – wood board end cap · 2 peg – wood peg/nail · 3 parchment_corner – parchment torn corner · 4 parchment_edge – parchment fold/tear edge strip · 5 stone_corner – stone corner cap · 6 banner_tail – cloth/banner tapered tail · 7 selection_marker – a small hand-painted ring/star burst used to highlight a chosen card or slot
DELIVERY: high resolution PNG (at least 1536 px wide). Put the PNG in a zip named ART-02.zip and give me the zip.
```

### ART-03 — Icon family (24–48 dp)

Upload: 05_UI_DESIGN_SYSTEM.png + 02_GAMEPLAY_HUD.png
Zip: ART-03.zip

```
Create ONE original icon sheet for my mobile game RIFTWARDEN, matching the uploaded UI design system image (section "17. ICONOGRAPHY") and gameplay HUD reference. If I also uploaded draft icons, keep their basic silhouette ideas but redraw them in this style.
STYLE: warm hand-drawn 2D cartoon game UI. Bold, slightly irregular dark brown-black outline with the SAME weight on every icon; simple flat color fills with at most one small flat highlight shape; minimal inner detail; one accent color per icon; consistent corner treatment and light direction. Must stay readable when shrunk to 24 px.
FORBIDDEN: gradients, gloss, glow, neon, 3D gems, thin line icons, mixed perspective, sci-fi/cyberpunk/military look, text or letters (info may use a simple "i" shape), imitation of any existing game or artist.
LAYOUT: one image, flat pure #FF00FF magenta background everywhere, 5 columns x 4 rows grid, wide equal gaps between icons, each icon centered in its cell with empty margin, nothing touching cell edges, no shadows on the background. Fill row by row in this exact order (last cell empty):
1 aether – blue/cyan droplet (battle resource) · 2 shard – small chipped violet-blue stone fragment (not a glossy gem) · 3 cell – small contained energy vial/relic · 4 rift – violet spiral/tear, no tiny detached pieces · 5 attack – simple sword/impact mark, not military · 6 support – plus/leaf/ward form · 7 area – burst with a few large rays · 8 utility – gear-like improvised relic mark, not chrome · 9 magic – rift curl/orb · 10 health – heart/shield mark · 11 lock – chunky padlock · 12 level – star badge · 13 settings – readable gear · 14 pause – two broad bars · 15 back – broad arrow pointing LEFT · 16 info – enclosed "i" mark · 17 plus – simple plus · 18 close – simple X · 19 check – simple checkmark
DELIVERY: high resolution PNG (at least 1536 px wide). Put the PNG in a zip named ART-03.zip and give me the zip.
```

### ART-04 — Defenders: portraits + gameplay sprites

Upload: 05_UI_DESIGN_SYSTEM.png + 04_DEFENDER_LOADOUT.png
Zip: ART-04.zip

```
Create original art for my mobile game RIFTWARDEN's three allied defenders (`pulse_guard`, `arc_ranger`, `titan_frame`), matching the uploaded UI design system image and defender loadout reference. Deliver FOUR images total: three single-character portraits plus one gameplay sprite sheet.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. Playful proportions, expressive face/pose, grouped local colors, limited material count, bold dark keyline with a lighter inner edge or material seam, restrained cel shading. Equipment looks magical, ancient, biological, repaired, or improvised — never military, industrial, robotic, or firearm-realistic. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, military robots, realistic armor, soldiers, tanks, guns, camouflage, gore, horror realism, excessive glow or gradients, anime/chibi conventions, text or letters.
SUBJECTS: pulse_guard — compact and numerous, a small friendly trooper with simple round armor plates and a shoulder-mounted relic emitter. arc_ranger — slender, tall, a long carved tuning-fork relic weapon with a thin arc of contained energy between its prongs, light improvised gear. titan_frame — broad and heavy, thick layered repaired plating, two wide ground-slam arms, low center of gravity, a warm-glowing relic core visible on its chest.
IMAGE 1-3 (portraits): one character per image, real alpha transparency (no magenta, no solid background), generous quiet margin on every side (at least 10% of canvas), expressive pose/face, no text or drop shadow baked in. Each must remain recognizably the same character as its gameplay sprite.
IMAGE 4 (gameplay sheet): a 3 columns x 1 row sheet of the same three defenders (pulse_guard, arc_ranger, titan_frame, left to right) at gameplay scale — full body, facing right (toward the battlefield), simplified equipment detail so the role silhouette reads at small size. Flat pure magenta #FF00FF background across the entire image, equal cell size, each character centered in its cell, at least 40 px of clean magenta space between every character and the image border, no shadow or glow touching the background, no text/labels/borders.
DELIVERY: high resolution PNGs. Put all 4 PNGs in a zip named ART-04.zip and give me the zip.
```

### ART-05 — Enemies gameplay sprites

Upload: 05_UI_DESIGN_SYSTEM.png + 02_GAMEPLAY_HUD.png
Zip: ART-05.zip

```
Create ONE original enemy sprite sheet for my mobile game RIFTWARDEN, matching the uploaded UI design system image and gameplay HUD reference.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. All seven creatures share the same species language: dark organic/stone bodies with restrained Rift-violet accents — never full-body purple glow. They can be funny in pose or expression and threatening in behavior. Bold dark keyline, restrained cel shading. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: gore, horror realism, zombies, realistic armor, military motifs, hard sci-fi, cyberpunk, excessive glow or gradients, text or letters.
LAYOUT: one image, flat pure magenta #FF00FF background everywhere, 4 columns x 2 rows grid (7 creatures, last cell empty/magenta), wide equal gaps between creatures, each creature centered in its cell facing LEFT (toward the fortress), no shadow or glow touching the background, no text/labels/borders. Fill row by row in this exact order (last cell empty):
1 drifter – the common one, medium size, hovering slightly, a simple dark organic husk with a small restrained violet glow at its core; reads as "basic enemy" · 2 skitter – very fast, fragile, small, low, several thin legs, a sharp forward-leaning body; reads as "this thing is quick" · 3 bulwark – huge, wide, heavy, thick stone-like plating covering most of its body, tiny head, slow and immovable; reads as "wall" · 4 splitter – bulbous segmented body with small shapes faintly visible under its skin, looks ready to burst · 5 phaseborn – partially translucent, part of its body fading into faint violet static/particles; reads as "hard to hit" · 6 leech – long tendril-arms, a wide draining mouth, hunched forward posture, a thin amber energy thread visibly being pulled toward it · 7 spawner – stationary, bloated, rooted with plant-like anchoring limbs, small openings on its back from which tiny creatures emerge
DELIVERY: high resolution PNG (at least 1536 px wide). Put the PNG in a zip named ART-05.zip and give me the zip.
```

### ART-06 — Fortress / citadel with 6 visible slot positions

Upload: 05_UI_DESIGN_SYSTEM.png + 02_GAMEPLAY_HUD.png
Zip: ART-06.zip

```
Create ONE original image for my mobile game RIFTWARDEN: the `citadel_basic` fortress structure, matching the uploaded UI design system image and gameplay HUD reference.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. Old, improvised, inhabited, warm, and repaired — timber patches, rope, banners, lived-in details — not a sleek sci-fi structure. Bold dark keyline, restrained cel shading. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, military hardware, glossy generic mobile RPG framing, excessive glow or gradients, text or letters.
SUBJECT: a single fortress structure meant to stand at the left edge of a battlefield facing right, viewed from a slightly elevated front-leaning angle consistent with a hand-drawn 2D battlefield scene. It has six visible platform/ledge positions on its upper section where defenders can be seen standing, readable as "six troops can garrison here" even without units present (railings, small platforms, or worn footholds). A sturdy wall section faces right, toward where enemies approach. Silhouette must read instantly as "home base to defend" at small size.
LAYOUT: real alpha transparency around the subject — not magenta or any solid-color background — the canvas outside the fortress must be fully transparent, no drop shadow or glow touching the transparent edge, the fortress must end cleanly at its own silhouette, no text/labels/borders/ground plane/background scenery. Render at high resolution.
DELIVERY: put the PNG in a zip named ART-06.zip and give me the zip.
```

### ART-07 — Battlefield background 16:9 + wide extension

Upload: 05_UI_DESIGN_SYSTEM.png + 02_GAMEPLAY_HUD.png
Zip: ART-07.zip

```
Create ONE original wide landscape background for my mobile game RIFTWARDEN: the `fractured_edge` battlefield ground, matching the uploaded UI design system image and gameplay HUD reference.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. A sunlit, lived-in, slightly broken/floating terrain edge with warm ground colors, soft directional light from the upper-left. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, military hardware, excessive glow or gradients, characters, props, UI, text.
SUBJECT: the ground the battle takes place on, seen from the same slightly elevated angle as the fortress. Leave a clean, uncluttered horizontal combat lane between where the fortress (left) and the rift (right) will be composited, so decor placed on top stays readable and does not look targetable or obscure feet/projectiles.
LAYOUT: single wide landscape 16:9 (or wider-safe) painted scene, opaque, no transparency needed, no characters, no props that must align pixel-exactly with gameplay content, no UI, no text, no vignette or frame that would clash with foreground elements composited on top, consistent light direction across the whole width, must blend smoothly toward the left/right edges for wide-device safe extension.
DELIVERY: high resolution PNG. Put the PNG in a zip named ART-07.zip and give me the zip.
```

### ART-08 — Main menu environment scene 16:9 + wide extension

Upload: 05_UI_DESIGN_SYSTEM.png + 01_MAIN_MENU.png
Zip: ART-08.zip

```
Create ONE original wide landscape main-menu environment scene for my mobile game RIFTWARDEN, matching the uploaded UI design system image and main menu reference.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. An inviting establishing view of the fortress world at rest — warm sunlit sky, the fortress silhouette in the distance, gentle atmospheric depth. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, military hardware, excessive glow or gradients, characters in the foreground, UI, text, vignette that would clash with foreground UI.
SUBJECT: enough calm negative space in the lower/side thirds for menu buttons and the logo to be composited on top later.
LAYOUT: single wide landscape 16:9 (or wider-safe) painted scene, opaque, no transparency needed, no UI, no text, must extend/blend smoothly toward the edges for wide-device safe extension.
DELIVERY: high resolution PNG. Put the PNG in a zip named ART-08.zip and give me the zip.
```

### ART-09 — Rift portal + Rift Collapse icon/illustration/reticle

Upload: 05_UI_DESIGN_SYSTEM.png + 02_GAMEPLAY_HUD.png
Zip: ART-09.zip

```
Create FOUR original images for my mobile game RIFTWARDEN's `rift_collapse` battlefield element and ability, matching the uploaded UI design system image and gameplay HUD reference.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. Restrained Rift-violet accent used elsewhere — never full-scene magenta bloom. Bold dark keyline, restrained cel shading. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, excessive glow or gradients, text or letters.
SUBJECTS:
1 portal — a single Rift portal: a jagged vertical tear in space that stands at the right edge of the battlefield (a spawn-flavor element, not a gameplay waypoint), made of an ancient stone/ring frame with unstable violet dimensional energy bleeding from its center. Reads instantly as "this is where the enemies come from."
2 rift_collapse_icon — a small icon: a simple violet Rift curl/orb consistent with a flat game-icon style.
3 rift_collapse_illustration — a larger square-safe illustration of the ability's effect: a controlled ring of violet energy collapsing inward on the battlefield, with quiet edges for card cropping.
4 rift_collapse_reticle — a flat top-down targeting reticle ring in the same restrained violet accent, sparse particles, no page-wide glow.
LAYOUT: one subject per image, real alpha transparency (no magenta, no solid background), generous quiet margin on every side (at least 10% of canvas) so it can be cropped into a card/button/frame without clipping, no drop shadow baked in unless the subject description says so, no text. Render at high resolution.
DELIVERY: put all 4 PNGs in a zip named ART-09.zip and give me the zip.
```

### ART-10 — Upgrade illustrations per icon id

Upload: 05_UI_DESIGN_SYSTEM.png + 03_UPGRADE_CHOICE.png
Zip: ART-10.zip

```
Create original square-safe upgrade illustrations for my mobile game RIFTWARDEN, matching the uploaded UI design system image and upgrade-choice card reference. Deliver one image per upgrade id, quiet edges for card cropping.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. Each clearly depicts its effect through the fortress-world visual language (relic mechanisms, restrained energy accents, no sci-fi circuitry). Bold dark keyline, restrained cel shading. Each icon id is visually distinct from the others at a glance. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, sci-fi circuitry, excessive glow or gradients, text or letters.
SUBJECTS (one image per id): upgrade_chain – chained energy arcing between targets · upgrade_pierce – a bolt punching through multiple foes in a line · upgrade_crit – a bright starburst impact · upgrade_explosion – a contained blast ring · upgrade_swarm – many small projectiles fanning out · upgrade_economy – an aether coin/mote bundle · upgrade_core – a warm glowing core/heart with a protective ward · upgrade_pulse_dualshot – twin pulse bolts side by side · upgrade_pulse_overcharge – a single oversized charged pulse bolt · upgrade_arc_overcharge – a thick, longer arcing bolt of energy · upgrade_arc_focus – a narrow, precise focused energy beam · upgrade_titan_shockwave – a ground-slam shockwave ring · upgrade_titan_juggernaut – a heavier, armored silhouette cue
LAYOUT: one subject per image, real alpha transparency (no magenta, no solid background), generous quiet margin on every side (at least 10% of canvas), no text baked in, no drop shadow baked in. Render at high resolution.
DELIVERY: put all 13 PNGs (one per id above, named by id) in a zip named ART-10.zip and give me the zip.
```

### ART-11 — Environment props

Upload: 05_UI_DESIGN_SYSTEM.png + 02_GAMEPLAY_HUD.png
Zip: ART-11.zip

```
Create ONE original decor sheet for my mobile game RIFTWARDEN, matching the uploaded UI design system image and gameplay HUD reference. These are purely decorative battlefield scenery props.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art — vegetation, ruins, floating land, distant towers, cloth, and small worn structures, no generic crystal formations. All eight pieces share the same warm, lived-in, slightly imperfect material language. Bold dark keyline, restrained cel shading. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: generic crystal-fantasy formations, hard sci-fi, cyberpunk, excessive glow or gradients, text or letters.
LAYOUT: one image, flat pure magenta #FF00FF background everywhere, 4 columns x 2 rows grid (8 objects), wide equal gaps between objects, each object centered in its cell with empty margin, no shadow or glow touching the background, no text/labels/borders/ground plane/scene. Fill row by row in this exact order:
1 mossy_ruin_arch – a broken stone archway fragment softened by moss and hanging vines · 2 broken_bridge_plank – a snapped section of an old wooden bridge, jutting out at an angle, rope still attached · 3 floating_isle_root – a small chunk of floating ground with exposed roots and dangling dirt underneath, drifting just above the lane · 4 watch_tower_distant – a leaning, weathered wooden watchtower silhouette piece, distant-scale · 5 banner_post – a worn wooden post flying a torn cloth banner · 6 lantern_post – an old iron-and-wood lantern post with a warm firelight glow (no electric/energy styling) · 7 gnarled_tree – a gnarled, character-filled tree with a warm autumn-toned canopy · 8 rift_touched_stone – a cracked stone slab with one thin, restrained violet Rift crack running through it — the only piece carrying a Rift accent
DELIVERY: high resolution PNG (at least 1536 px wide). Put the PNG in a zip named ART-11.zip and give me the zip.
```

### ART-12 — VFX: hit, death puff, aether mote, core impact, ability blast, projectiles

Upload: 05_UI_DESIGN_SYSTEM.png + 02_GAMEPLAY_HUD.png
Zip: ART-12.zip

```
Create ONE original VFX sheet for my mobile game RIFTWARDEN, matching the uploaded UI design system image and gameplay HUD reference. All effects read as controlled, hand-drawn energy — bright cores fading to soft edges that still end cleanly (no bleeding into transparency), never a broad screen-covering bloom.
STYLE: warm, hand-drawn 2D cartoon game VFX consistent with the fortress-world palette: friendly energy blue/cyan, hostile Rift energy violet used sparingly, warm amber for reward/impact emphasis. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, neon, excessive glow or gradients bleeding into transparency, text or letters.
LAYOUT: one image, flat pure magenta #FF00FF background everywhere, 5 columns x 3 rows grid, wide equal gaps between effects, each effect centered in its cell, viewed straight-on, no shadow or glow touching the background, no text/labels/borders. Fill row by row in this exact order:
1 proj_pulse – a friendly cyan pulse bolt · 2 proj_lance – a piercing white-hot lance · 3 proj_arc – a short arcing energy segment · 4 proj_explosive – an amber explosive orb · 5 proj_enemy_spit – a small violet enemy spit · 6 hit_spark – a small cyan hit spark · 7 hit_explosion – a warm orange explosion burst · 8 hit_chain – an electric chain burst · 9 hit_rift_puff – a small violet Rift impact puff (enemy death) · 10 hit_crit – a white critical-hit starburst · 11 field_shield – a circular cyan shield-ward dome · 12 field_aether_mote – an amber aether pickup mote · 13 field_danger_ring – a flat red top-down danger warning ring · 14 field_slow – a frost/slow crystal burst (small, restrained, not a generic crystal prop) · 15 field_heal – a green healing pulse ring
DELIVERY: high resolution PNG (at least 1536 px wide). Put the PNG in a zip named ART-12.zip and give me the zip.
```

### ART-13 — Result victory/defeat accents

Upload: 05_UI_DESIGN_SYSTEM.png + 03_UPGRADE_CHOICE.png
Zip: ART-13.zip

```
Create two original accent illustrations for my mobile game RIFTWARDEN's result screen, matching the uploaded UI design system image and reference.
STYLE: warm, hand-drawn 2D cartoon fortress-world game art. Bold dark keyline, restrained cel shading, consistent with the fortress world's hand-drawn material language. Original design — do not imitate any existing game, cartoon, franchise, or artist.
FORBIDDEN: hard sci-fi, cyberpunk, holograms, excessive glow or gradients, text or letters, grim/horror imagery.
SUBJECTS: (1) victory — a warm, triumphant beat, e.g. a banner unfurl or a bright restrained burst around the fortress emblem. (2) defeat — a somber but not grim beat, e.g. a dimmed lantern or a torn banner.
LAYOUT: one subject per image, real alpha transparency (no magenta, no solid background), square-safe with quiet edges on every side so it can be cropped without clipping, no text baked in, no drop shadow baked in. Render at high resolution.
DELIVERY: put both PNGs in a zip named ART-13.zip and give me the zip.
```

---

## FONT-01 — Localization fonts

- FONT-01 is not a generation task: fonts must be sourced/licensed, not AI-generated.
- Required script coverage: Latin, Arabic, CJK (Han/Hiragana/Katakana/Hangul), Thai.
- Track the license and source URL for each chosen font family alongside the asset in the planner's intake notes.

---

## Isleme

Onaylanan ciktilar `assetkit` ile islenir:

```bash
python tools/assetkit/assetkit.py ingest design/art_intake/<ART-ID> --recipe <grup>
python tools/assetkit/assetkit.py pack   --group <grup>
python tools/assetkit/assetkit.py verify
```

- Atlas gruplari (`units`, `enemies`, `fx`, `world`, `background`): mevcut
  tarifler (`tools/assetkit/recipes/*.json`) degismez.
- Dosya-basina UI sanati gruplari (`portraits`, `illustrations`, `icons`,
  `ornaments`, `logo`, `scenes`): tarifleri `ART-PREP` gorevinde eklenir;
  eklendikten sonra ayni `ingest`/`pack`/`verify` akisi kullanilir.

## Sorun giderme

| Belirti | Sebep | Cozum |
|---|---|---|
| Beklenenden az parca cikti | Objeler birbirine deginiyor | Tarifte `min_gap` dusur, ya da `"slice":"grid"` + `cols`/`rows` ver |
| Beklenenden cok parca cikti | Bir objenin parcalari ayri algilandi | `min_gap` artir |
| Kenarlarda mor/renkli hale | Golge arka plana degmis (magenta gruplar) veya alfa kenari temiz degil (transparan gruplar) | ChatGPT'ye golgesiz/temiz kenarli yeniden urettir; ya da magenta gruplar icin `tolerance` artir |
| Sprite'in kendi rengi silindi | Sprite rengi #FF00FF'e cok yakin (sadece magenta gruplar) | `tolerance` dusur (or. 40) |
| Arka plan tam silinmedi (magenta gruplar) | Gradyanli/gurultulu zemin | `tolerance` artir (or. 100); kaliciysa duz zeminle yeniden urettir |
| `world` grubunda obje bulunamadi | Goruntu magenta zeminle geldi ama tarif `chroma:false` | ChatGPT'ye gercek alfa seffafligiyla yeniden urettir |
