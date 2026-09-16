# RIFTWARDEN Visual Design Specification

This document is the canonical production visual specification for RIFTWARDEN. The repository is authoritative for product scope, gameplay, data, and technical constraints. The five files in `design/references/` are authoritative for visual language and the presentation areas assigned to them in section 26. A pictured feature is not a product requirement unless the repository supports it.

## 1. DESIGN PRINCIPLES

1. **World first.** The battlefield, fortress, defenders, creatures, and environment establish the experience; UI frames information without becoming the scene.
2. **Handmade, not technological.** Controls use illustrated wood, parchment, stone, cloth, ink, and carved forms. Digital behavior may be precise, but its visible shell must feel made inside the world.
3. **Playful and immediately readable.** Exaggeration, expression, and irregularity are welcome only when state, hierarchy, text, and touch targets remain unmistakable at 640 x 360 dp.
4. **The battlefield remains primary.** Combat UI is compact, edge-anchored, and limited to information needed for immediate decisions. The bottom battle strip must never exceed 20% of screen height.
5. **Irregularity is controlled.** Silhouettes and ornamental edges may vary; alignment, content order, interaction states, and spacing rhythm remain systematic.
6. **Illustration carries personality.** Characters, creatures, environments, upgrade art, and a small set of ornaments create identity. Layout, state, text, and most surfaces remain reusable Flutter structures.
7. **One component language.** Screens reuse the same buttons, panels, cards, bars, tabs, slots, chips, and state rules. A new screen does not invent a parallel design system.
8. **Meaning precedes color.** Every critical state combines color with shape, icon, label, value, motion, or contrast; Aether cyan and Rift violet are accents rather than page-wide washes.

## 2. VISUAL IDENTITY

RIFTWARDEN is a warm, adventurous, hand-drawn 2D cartoon world in which small, expressive defenders protect an improvised ancient fortress from strange dimensional creatures. The science-fantasy element comes from impossible rifts, floating geography, unusual organisms, and relic-like mechanisms—not circuitry, military hardware, or holographic interfaces.

Cartoon exaggeration is moderate: heads, hands, tools, eyes, and role-defining equipment may be enlarged for recognition, while bodies retain enough structure to animate and read in battle. Shapes are bold, poses are expressive, surfaces use restrained cel shading, and linework is slightly imperfect without becoming noisy.

RIFTWARDEN is identifiable through the contrast of a sunlit, lived-in fortress world with uncanny violet rifts; tiny brave defenders against readable swarms; parchment and timber interfaces integrated into architecture; and recurring circular rift/warden marks. Friendly energy is blue/cyan, hostile dimensional energy is violet/magenta, and warm amber is reserved for emphasis and selected resource/reward moments.

Explicit anti-goals: hard sci-fi, cyberpunk, holograms, glassmorphism, black-neon dashboards, military robots, realistic medieval fantasy, generic crystal fantasy, glossy generic mobile RPG framing, anime/chibi conventions, excessive purple/cyan coverage, excessive glow or gradients, perfect symmetry, and corporate vector UI. No existing game, cartoon, franchise, or artist is to be imitated.

## 3. SHAPE LANGUAGE

- **Irregularity:** outer silhouettes may vary by roughly one small visual beat per edge: a bowed board, chipped stone, folded parchment corner, or uneven ink line. Content bounds remain rectangular and predictable.
- **Corners:** avoid uniformly perfect pills and generic rounded rectangles. Use softened, slightly uneven corners for parchment and wood; chunkier clipped corners for stone and dark-neutral HUD frames. Pills are reserved for counters, compact tags, and progress tracks.
- **Outlines:** important components use a bold dark keyline with a lighter inner edge or material seam. Small components reduce detail before reducing contrast. Repeated outlines share a small set of weights.
- **Asymmetry:** ornaments, knots, leaves, nails, chips, and cloth folds may be asymmetrical. Text, icons, values, and hit regions remain aligned.
- **Wood:** broad boards, visible end variation, sparse grain, pegs/nails, warm ochre-brown depth. Use for primary navigation, major CTA frames, loadout rails, and structural trims.
- **Parchment:** warm low-contrast body, darker ink, subtly torn or folded silhouette. Use for reading-heavy panels, descriptions, upgrade bodies, and notices.
- **Stone:** compact, heavy, chipped, cool-neutral. Use for fortress-linked slots, ability frames, locked states, and durable HUD anchors.
- **Cloth/banner:** tapered or torn lower edge, limited folds, one emblem. Use for titles, section markers, and world-integrated signage—not for every label.

Component bodies, clipping, borders, layout, state changes, and most shadows are code-native. Small corner caps, board ends, parchment tears, nails, vines, and banner tails may be reusable transparent raster slices. Unique painted frames with baked text are prohibited.

## 4. COLOR SYSTEM

The approved reference defines intent; production values must be tuned in `AppColors` against actual device captures rather than sampled blindly from the concept sheet. Existing public token names should be retained as compatibility aliases during migration where practical.

| Semantic token | Intended role | Migration decision |
|---|---|---|
| `background` | Bright sky/world atmosphere or scene-specific illustrated background | Add; replaces a universal void background outside intentionally dark overlays |
| `surface` | Warm parchment or quiet dark-neutral contextual surface | Modify existing value/usage; material variants must be explicit |
| `surfaceRaised` | Lighter parchment, raised timber face, or raised dark HUD face | Modify existing value/usage |
| `textPrimary` | Near-black ink on light surfaces; warm off-white on dark surfaces | Split into on-light/on-dark semantics while preserving the current alias |
| `textSecondary` | Softer ink/brown or muted warm gray | Modify |
| `textDisabled` | Clearly subdued but still legible neutral | Modify and verify contrast |
| `aether` | Canonical visual semantic for the friendly battle resource and allied energy; blue/cyan | Reassign semantic intent. Legacy amber Aether usage must not remain under the same `aether` semantic name during migration |
| `rift` | Hostile dimensional energy; violet/magenta | Consolidate existing Rift accents under a semantic role |
| `health` | Healthy Core/enemy health; green | Add |
| `danger` | Critical health, destructive confirmation, severe failure | Keep semantic role; retune away from neon if needed |
| `warning` | Caution, incoming wave, important affordability/reward emphasis | Keep; warm amber |
| `success` | Completion, confirmation, healing | Keep semantic role |
| `common` | Warm neutral/stone rarity | Keep role, retune |
| `rare` | Clear blue rarity | Keep role |
| `epic` | Violet rarity | Keep role |
| `legendary` | Amber/gold rarity | Keep role |

Additional material tokens are required for parchment base/edge, wood face/edge, stone face/edge, dark HUD face, outline ink, shadow, and selection highlight. These are structural neutrals, not new competing accents.

Usage rules:

- Battle Aether's canonical visual semantic is cyan/blue. It appears on the battle-resource icon, allied magic, ready/targeting feedback, and selected allied details without tinting whole screens. Legacy amber Aether styling must be migrated to correctly named warning, CTA, or reward-emphasis semantics rather than retained as another visual meaning of `aether`.
- Rift violet/magenta appears on portals, hostile energy, Rift Collapse identity where appropriate, and enemy-linked warnings. It does not become the default panel color.
- Warm amber identifies primary CTA emphasis, warning, legendary rarity, or repository-supported reward currencies according to context. Gold shown in references is not a battle resource requirement.
- Gradients are shallow material/value shifts, not luminous neon ramps.
- Text color is selected by surface role. A single global light-text assumption is insufficient for parchment.

## 5. TYPOGRAPHY

- **Logo:** a bespoke raster/vector-like wordmark asset with chunky hand-lettered forms, uneven baseline, strong outline, and a Rift/Warden emblem. It is not localized.
- **Display:** expressive hand-drawn display family for Latin headings where glyph coverage exists. It must never be the only readable route for localized text.
- **Screen title:** bold, compact, high-contrast; allows two lines only where the layout explicitly supports it.
- **Section title:** short, firm, slightly condensed in feel; sentence case or locale-appropriate casing. Do not force uppercase for scripts/locales where it harms reading.
- **Body:** highly legible system or bundled multilingual family, comfortable at small landscape sizes, with restrained line length.
- **Button:** bold and compact; label remains readable without aggressive tracking or forced scaling.
- **Small label:** used sparingly for metadata, state, and captions; never the sole carrier of a critical action.
- **Number/resource counter:** tabular figures, strong weight, stable width, and high contrast.

`AppTypography`'s current role structure and tabular numeric behavior are sound and should be preserved. The current null font configuration is temporary. Production requires an original/licensed display font plus locale-appropriate body families with Arabic, CJK, Thai, and Latin coverage. Until bundled, functional UI must fall back safely to system fonts. No important label may depend on a decorative font's missing glyphs.

## 6. SPACING AND LAYOUT

Preserve the existing 4 dp rhythm: 4, 8, 12, 16, 24, 32, and 48 dp. `screenGutter` at 20 dp is a valid baseline; apply horizontal safe-area padding in addition to it. `minTouchTarget` remains 48 dp.

- Screen gutter: 20 dp baseline plus notch/inset.
- Compact HUD inset: 4–12 dp, using the existing scale.
- Card gap: 8–12 dp at 640 x 360; 12–16 dp when space allows.
- Panel padding: 12–16 dp compact, 16–24 dp standard/large.
- Modal outer inset: minimum 24 dp where width allows; must respect safe area.
- Decorative raster may overhang layout bounds but may not reduce content padding or hit targets.
- Do not introduce arbitrary one-off spacing to mimic painterly edges; visual irregularity belongs to decoration, not layout math.

## 7. BUTTON SYSTEM

| Type | Visual construction | Use |
|---|---|---|
| Primary | Warm amber/yellow board or carved face, dark outline, shallow lower edge/shadow, optional play/action icon | One dominant action per region or screen |
| Secondary | Parchment or quiet timber face, dark outline, lower visual weight | Navigation and supporting actions |
| Icon | Compact stone/dark-neutral or wood-framed control with readable glyph | Back, pause, settings, info, add |
| Danger | Restrained red-clay/danger face; never magenta neon | Destructive confirmation only |

States are mandatory: default; pressed with 1–2 dp visual depression plus short scale/translation; disabled with reduced contrast and no raised shadow; selected/emphasized with amber edge/light seam plus shape or marker. Press feedback begins immediately and completes within `AppDuration.instant` or `fast`. Optional nails, board ends, or corner caps use reusable small raster decoration. Decoration may be omitted in compact HUD controls.

## 8. PANEL SYSTEM

- **Standard:** reusable content group; parchment for reading, dark-neutral for compact HUD, or restrained wood frame around either.
- **Large:** screen-level content region with the same anatomy and more padding; not a bespoke painting.
- **Modal:** strongest depth, clear title area, dimmed context behind it, and one obvious decision region.
- **Small-info:** compact parchment tag or dark-neutral plaque for tips, labels, and transient status.

Wood communicates structure/action, parchment communicates readable information, stone communicates durability/lock/fortress, and dark-neutral surfaces preserve contrast over busy battle art. Use one dominant material per panel. Do not stack wood, stone, cloth, parchment, and glow on a single ordinary container.

## 9. CARD SYSTEM

All cards share: outer material frame; state border; optional art zone; title; concise supporting text; optional badge/type marker; and a predictable action/state zone.

- **Standard:** quiet parchment or neutral face.
- **Selected:** amber highlight plus stronger outline/check or selection marker; never color alone.
- **Locked:** darkened silhouette or obscured art, lock icon, and accessible lock reason where available.
- **Disabled:** content remains identifiable but loses elevation and saturation.
- **Defender:** portrait-dominant, name and role visible, level only if supported by data.
- **Upgrade:** illustration at top, title band, description body, family/type indicator when repository data supplies it, rarity accent kept secondary to the effect text.

## 10. GAMEPLAY HUD

`02_GAMEPLAY_HUD.png` is the visual authority, constrained by currently implemented gameplay and product data.

Information priority is: battlefield and threats; Core HP; wave state; spendable Aether; defender purchase affordability/slot capacity; Rift Collapse readiness; pause. No Gold, XP, premium currency, profile, or meta progression belongs in battle unless gameplay is explicitly extended later.

- **Core HP:** anchored above/near the fortress on the left. Show label, green-to-danger bar, and current value; retain the delayed damage trail. Below 25%, combine red state, pulse, and warning icon without screen-wide flashing.
- **Wave:** compact top-center parchment/wood plaque with current/total and simple segmented progress. If/when repository-backed boss gameplay is implemented, boss waves may add icon/shape and danger emphasis; this is not a current HUD requirement.
- **Aether:** top edge resource chip with blue/cyan droplet/icon and tabular value. This is the spendable battle currency used by current defender and ability-shop costs.
- **Pause:** top-end 48 dp icon control, safe-area aware.
- **Purchase row:** bottom edge, portrait-led cards for the three implemented units: Pulse Guard, Arc Ranger, Titan Frame. Each shows current Aether cost and slot feedback. Fast repeat purchase remains possible.
- **Rift Collapse:** bottom-end, visually distinct circular/stone ability control with icon, state, and cooldown.
- **Enemy health:** compact bars only when useful for meaningful target or damage reading. Boss-specific health treatment applies only if/when repository-backed boss gameplay is implemented. Avoid bars over every small swarm creature when the screen becomes striped.
- **Visibility:** top HUD stays thin; bottom strip including safe-area content stays at or below 20% of total height. Center lanes remain unobstructed. Popovers must be compact and dismissible.

Combat UI must preserve the repository's established performance and data-flow boundary. Canonical implementation rules remain in `CLAUDE.md` and `docs/ARCHITECTURE.md`; this visual specification does not redefine them.

## 11. DEFENDER SLOT SYSTEM

Supported battle states are empty/available, selected where selection exists, purchaseable, unaffordable, and occupied. A persistent locked state is shown only when actual unlock data is supplied.

- **Empty:** quiet stone/parchment frame with plus or placement mark.
- **Available:** recognizable portrait and normal frame.
- **Selected:** amber edge plus raised marker/check; portrait stays fully readable.
- **Locked:** lock and silhouette, never a fabricated level requirement.
- **Purchaseable:** portrait, Aether cost, and active raised state.
- **Unaffordable:** visible portrait/cost with flattened depth, subdued color, and disabled interaction.
- **Occupied:** portrait plus clear occupied marker/count; do not imply it is another purchasable copy if the slot itself is being represented.

At battle scale, portrait silhouette and cost outrank name. Names may truncate to one line only when the portrait and role remain sufficient; localized tooltips/details can carry the full name.

## 12. RIFT COLLAPSE / ABILITY SYSTEM

- **Ready:** vivid Rift icon, restrained amber/blue ready rim, slight single pulse, and enabled depth.
- **Cooldown:** desaturated icon, radial mask or ring, and localized/tabular remaining time where space permits.
- **Targeting:** reticle replaces or overlays the ready icon; battlefield receives a light dim and clear target cursor/radius. Tapping the button again exits targeting.
- **Unavailable:** flattened dark-neutral/stone state with a blocked marker; no glow.

Cast feedback uses a short anticipation, localized target flash, inward Rift pull, impact, and brief recovery. Do not flood the screen with bloom. State transitions must be readable from icon, ring/fill, and motion as well as color.

## 13. UPGRADE CHOICE SYSTEM

`03_UPGRADE_CHOICE.png` governs the overlay. Combat pauses and remains visible behind a darkened, slightly desaturated veil; the scene is context, not a replacement background.

The canonical hierarchy is exactly three equal-priority choices in one row. Runtime must fail safely if content supplies one or two choices: preserve card proportions and center them rather than stretching them. At 640 x 360, cards shorten ornament and description before reducing legibility.

Each card contains: illustration/icon area; title band; localized title; localized description up to three concise lines; rarity accent; and family/type indicator when the existing `family` data is useful. Cards differ by art/material accent, not by arbitrary size. Touch/selected feedback uses immediate depression, amber edge, and a short confirmation response. Reveal is staggered, bottom-up, and no longer than the current `cardReveal` intent; interaction is never blocked until animation ends. No balance values are specified here.

## 14. DEFENDER / LOADOUT PRESENTATION

### Current product requirements

The repository currently defines three combat units—Pulse Guard, Arc Ranger, and Titan Frame—and presents them in the battle purchase row. Their readable portrait, name, current Aether cost, slot availability, and unit-specific in-battle ability-shop offers are current requirements. Any non-battle roster surface must derive its entries and fields from repository data rather than the concept image.

### Future visual extensions

If a defender roster/loadout feature is approved later, use `04_DEFENDER_LOADOUT.png` for: filter tabs; a portrait roster grid; selected card treatment; one large expressive character presentation; role badge; ability list; and a compact active-loadout rail. The selected defender should bridge roster, hero art, details, and active loadout through consistent portrait and highlight.

XP bars, levels beyond existing data, skins, upgrade currency/cost, additional defenders, biography, multiple abilities, and editable team/loadout behavior are not current requirements. They require product/data approval before UI implementation.

## 15. MAIN MENU

`01_MAIN_MENU.png` governs composition and world integration. Use a wide illustrated environment with fortress activity on one side, distant dimensional landmarks, and small storytelling moments. The logo has top/center authority without hiding the world. The Play CTA is the largest and warmest control.

**Current navigation:** expose only flows backed by working repository behavior. Play is the primary entry; Journey/level selection and Settings may appear only where their routes and behavior are actually connected. Navigation should feel mounted to architecture—boards, signs, banners, or a fortress rail—not like floating app cards.

**Future navigation and account extensions:** Store, Meta Upgrades, Defenders/loadout, and any Shard or Cell wallet/balance region require repository-backed systems and data before appearing as product navigation or persistent account UI. Player profile/level, Gold, premium currency, Daily Rewards, Achievements, Lore, and extra social/account controls shown in the reference likewise remain concept-only unless separately approved.

## 16. ICONOGRAPHY

Icons use bold irregular outlines, simple filled masses, minimal internal detail, and one semantic accent. They must read at 24 dp inside 48 dp controls. Avoid thin line icons, glossy 3D gems, and mixed perspective.

- Aether: blue/cyan droplet or contained magical mote.
- Rift: violet spiral/tear.
- Attack: simple sword/impact mark without realistic military styling.
- Support: plus/leaf/ward form.
- Area: burst with few large rays.
- Utility: gear-like improvised relic mark, not industrial chrome.
- Magic: Rift curl/orb.
- Health: heart/shield/Core mark.
- Lock: chunky padlock silhouette.
- Level: star/badge only when level data exists.
- Settings: readable gear.
- Pause: two broad bars.
- Back: broad directional arrow, mirrored for RTL.
- Info: enclosed lowercase/clear information mark.

Code-native icons are acceptable for temporary and generic system actions. Production identity/resource/role/ability icons should be lossless raster or atlas assets from one authored family. Text is never baked into icons.

## 17. CHARACTER ART DIRECTION

Defenders have strong, distinct silhouettes and role-first equipment: Pulse Guard compact and numerous; Arc Ranger slender and long-range; Titan Frame broad and heavy. Their technology looks magical, ancient, biological, repaired, or improvised—never military, industrial, robotic, or firearm-realistic. Use playful proportions, expressive faces/poses, grouped local colors, limited material count, bold outline, and restrained cel shading. At gameplay scale, eliminate costume micro-detail before losing the role silhouette. Portrait art may add expression and detail but must remain recognizably the same character. Designs must be original.

## 18. ENEMY ART DIRECTION

The seven implemented enemy archetypes need visibly different mass and motion: basic drifter, fast skitter, heavy bulwark, unstable splitter, intangible phaseborn, draining leech, and stationary spawner. Small units read through speed and compact outline; medium units through role appendages; large units through mass and screen presence. All share dark organic/stone bodies with restrained Rift-violet energy, but their entire bodies are not purple glow. Swarms use value and silhouette grouping so projectiles and defenders remain readable. Enemies can be funny in pose or expression and threatening in behavior. Avoid gore, horror realism, zombies, realistic armor, and military motifs.

## 19. WORLD / ENVIRONMENT ART

The fortress occupies the left and must visibly support six existing battle slots without becoming a flat UI shelf. It is old, improvised, inhabited, warm, and repaired. Rifts occupy the enemy/right origin and use a stone/ancient ring plus unstable violet dimensional energy.

Vegetation, ruins, floating land, bridges, distant towers, cloth, tools, and small creatures provide story. Ground establishes a clear horizontal combat lane with foreground and background depth; decor must not look targetable or obscure feet/projectiles. Use atmospheric perspective and lighter distant contrast. Preserve a clean value corridor between fortress and rift. Scene decoration may be asymmetric, but spawn direction and threat flow remain immediately obvious.

## 20. MOTION AND JUICE

- Button press: immediate 90–160 ms depression/scale and shadow reduction.
- Selection: short edge draw/pop plus marker; no looping glow.
- Card reveal: 240–320 ms rise/fade, slight stagger, always interruptible.
- Aether gain: small icon/value bump and short mote travel where affordable.
- Ability ready: one restrained pulse and icon settle; no endless large bloom.
- Ability cast: anticipation, target confirmation, impact, brief camera/effect response.
- Low health: slow restrained pulse below 25%; intensity increases through contrast, not flashing.
- Upgrade reveal: battlefield veil, banner settle, three-card stagger.
- Victory/defeat: short expressive scene/title response; primary action remains immediately available.

Preserve `AppDuration.instant` (90 ms), `fast` (160 ms), `normal` (240 ms), `slow` (400 ms), and the 320 ms card-reveal intent unless device testing demonstrates a need to adjust globally. Continuous animation is reserved for current/urgent states and must be battery-conscious.

## 21. SHADOW / DEPTH / EFFECTS

- **Normal:** narrow dark contact shadow and clear outline.
- **Raised:** 2–4 dp visual lift, stronger lower-edge shadow, optional lighter top seam.
- **Pressed:** reduced/removed lower shadow and 1–2 dp downward response.
- **Selected:** normal depth plus amber/light edge and explicit marker.
- **Aether accent:** tight cyan edge light or small mote; never a broad panel glow.
- **Rift accent:** tight violet inner energy and sparse particles; never a page-wide magenta bloom.

Shadows are warm/dark and directional, not blurred black fog. Glow is reserved for energy sources and critical state feedback. No excessive bloom, multiple competing glows, or glow behind body text.

## 22. RESPONSIVE RULES

- **640 x 360 dp:** compliance baseline. Use compact spacing, short descriptions, three upgrade cards in one row, horizontally scrollable collections where necessary, and no clipped touch targets.
- **Standard 16:9:** expand world visibility and breathing room before enlarging HUD.
- **Wider devices:** extend illustrated scene and lane; keep key HUD groups within comfortable anchored regions rather than stretching panels across empty width.
- **Safe areas:** background/game world extends under cutouts; interactive UI adds `MediaQuery.viewPadding.left/right/top/bottom` as appropriate. Both landscape rotations must work.
- **Long text:** flexible constraints, wrapping, and bounded lines take precedence over fixed text widths. Do not rely on `FittedBox` to make body text illegibly small.
- **RTL:** directional padding/alignment, mirrored navigation arrows, and logical start/end order. Battlefield's fortress-left/enemies-right gameplay orientation remains fixed unless game design explicitly changes; text and UI flow still honor RTL.

## 23. LOCALIZATION RULES

Allocate at least 30% expansion room for button and label strings. Prefer flexible widths, `Wrap`, and content-driven panel height outside the tightly bounded HUD. Titles may wrap to two lines; body descriptions wrap naturally within defined maxima; noncritical metadata may ellipsize only when a detail view or icon preserves meaning. Critical action labels must not silently truncate.

Do not render functional body or action text below the existing small-label scale; minimum practical body text should remain near the current 13 dp token and critical controls near 16 dp. Use locale-aware number formatting, including Arabic digits where appropriate. Avoid forced uppercase and excessive tracking. Mirror directional icons and spacing. No important localized text may be embedded in raster artwork.

## 24. ACCESSIBILITY / READABILITY

- Meet strong contrast on both parchment and dark-neutral surfaces; validate final asset composites, not token swatches alone.
- Keep every interactive target at least 48 x 48 dp.
- Pair color with icon, label, fill amount, outline, or motion for ready, locked, selected, unaffordable, danger, and rarity states.
- Keep battle silhouettes distinct from ground and effects; reduce decor contrast near active lanes.
- Use tabular, stable counters and avoid animated number movement that shifts layout.
- Do not flash rapidly. Low-health and ready feedback use restrained cadence.
- Preserve text scaling where layout permits and provide scroll/flexible overflow for settings and information surfaces.

## 25. ASSET RULES

The existing `tools/assetkit` pipeline remains authoritative: source sheets are ingested, chroma-keyed/sliced where appropriate, trimmed, scaled, and packed. Sprites and atlases use lossless WebP; large opaque backgrounds use lossy WebP quality 85. Transparent sprites require clean edges and atlas padding. The current atlas groups—units, enemies, world, FX, and UI—remain useful.

- Character/enemy gameplay sprites: transparent lossless WebP, strong silhouette, consistent camera and light, atlas-packed.
- Portraits/large character art: separate lossless or high-quality WebP sized for actual presentation; do not upscale gameplay sprites.
- Backgrounds: 16:9 or wider safe composition, lossy WebP q85, no text/UI baked in.
- Icons: one authored family, lossless WebP/atlas; test at final 24–48 dp sizes.
- Ability/upgrade art: square-safe illustration with quiet edges for card cropping, lossless WebP.
- VFX: transparent, tightly trimmed, restrained bloom, atlas-packed and gameplay-readable.
- UI decoration: small reusable nine-slice/corner/edge assets where code cannot provide the illustrated character; no whole-screen UI paintings.

The present asset prompt document describes the superseded semi-realistic hard-surface direction and must be revised in a future documentation task before new production art is commissioned. Existing assets are implementation placeholders unless individually re-approved against this specification.

## 26. APPROVED REFERENCES

| Reference | Authority | Limits |
|---|---|---|
| `01_MAIN_MENU.png` | Main Menu and world/menu presentation | Does not authorize profile, Gold, premium currency, Daily Rewards, Achievements, or Lore |
| `02_GAMEPLAY_HUD.png` | Gameplay composition and HUD hierarchy | Gold is replaced by repository-supported battle Aether; implemented unit count and actions govern |
| `03_UPGRADE_CHOICE.png` | Upgrade-choice interface | Effect text/data and available choices come from runtime content |
| `04_DEFENDER_LOADOUT.png` | Defender presentation and roster system | Loadout/skins/XP/extra defenders are future-only until product approval |
| `05_UI_DESIGN_SYSTEM.png` | Reusable UI components and component states | Token values are visual intent, not copied hex constants |

Conflict resolution order: repository product/gameplay truth controls what exists; this document controls production visual rules; the purpose-specific reference controls composition for its assigned surface; `05_UI_DESIGN_SYSTEM.png` controls reusable component appearance; other screenshots are supporting inspiration only. Technical accessibility, localization, safe-area, and 640 x 360 constraints override literal screenshot geometry. When references disagree, use the surface-specific reference and the smallest reusable component interpretation that satisfies it.

## 27. DO / DON'T

| Do | Don't |
|---|---|
| Use warm, handmade cartoon surfaces integrated into the world | Use neon sci-fi dashboards, glassmorphism, or cyberpunk panels |
| Keep layouts systematic under illustrated edges | Make alignment randomly crooked |
| Reuse code-native buttons, cards, panels, bars, tabs, and slots | Paint a unique full UI image for every screen |
| Use strong defender/enemy silhouettes and role cues | Use military robots, realistic weapons, soldiers, or tanks |
| Keep Aether and Rift colors as controlled accents | Wash entire screens in cyan/purple glow |
| Use parchment for reading and wood/stone for structure | Use generic crystal fantasy as the default material |
| Keep the combat HUD edge-anchored and under 20% at the bottom | Cover the battlefield with giant counters or panels |
| Use controlled asymmetry in decoration | Make information order inconsistent |
| Localize live text in Flutter | Bake localized labels or numbers into raster art |
| Let repository data define features and fields | Treat every concept-image element as a committed feature |

## 28. EXISTING SYSTEM MIGRATION

No second theme or component library is to be created. Migration evolves existing APIs and adds variants/tokens behind them where possible.

| Item | Current status | Action | Rationale |
|---|---|---|---|
| `app_colors.dart` | Complete dark-neon palette with useful semantic state/rarity names; Aether semantics are split/confusing | MODIFY | Retain compatible names, introduce warm material neutrals and on-light/on-dark text, make battle Aether canonically blue/cyan, and move legacy amber usage to correctly named warning/CTA/reward-emphasis semantics rather than keeping it under `aether` |
| `app_spacing.dart` | Coherent 4 dp scale, 20 dp gutter, 48 dp touch target, useful duration scale | KEEP | Already meets rhythm, landscape, and interaction constraints; add only named component sizes if repeated |
| `app_typography.dart` | Sound role hierarchy and tabular numerics; no bundled font; tech-like display intent | MODIFY | Preserve roles/sizes as baseline, add handmade display treatment and multilingual production fonts without sacrificing readability |
| `app_decorations.dart` | Dark gradients, cyan primary gradient, generic rounded borders, broad glow | REPLACE | Keep the file/API location but rebuild tokens around parchment/wood/stone/dark HUD materials, illustrated trims, tighter shadows, restrained energy accents |
| `app_theme.dart` | Global dark Material 3 mapping and system-font fallback | MODIFY | Map Material defaults to new semantics, support light parchment plus dark HUD contexts, retain mobile behavior and locale font selection |
| `RwButton` | Reusable variants, disabled state, immediate press scale, 48 dp minimum | MODIFY | Keep API/behavior; replace neon gradient and perfect rounded rectangle with material variants, depth, selected/emphasized support, optional decoration |
| `RwCard` | Reusable title/description/rarity selection card; rarity currently dominates border/glow | MODIFY | Introduce shared anatomy and explicit standard/defender/upgrade/locked/disabled states; use restrained rarity accents and art zones |
| `RwPanel` | Reusable titled gradient panel | MODIFY | Add standard/large/modal/small-info and material roles without creating one-off panels |
| `RwDialog` | Good 1–2 action structure and modal helper | MODIFY | Retain behavior; adopt parchment/wood modal construction, localized flexible sizing, and new depth rules |
| `RwIconButton` | 48 dp enforcement and press response; generic circle/dark surface | MODIFY | Add stone/wood/dark-neutral variants, authored icon support, selected/targeting state, and illustrated outline/depth |
| `RwProgressBar` | Valuable generic bar with clamping and delayed damage trail | MODIFY | Preserve logic; replace neon glow/pill-default styling with illustrated track, semantic variants, segmentation where needed |
| `RwCurrencyChip` | Stateless reusable counter; temporary geometry; supports Aether, Shard, Cell | MODIFY | Preserve enum/data API where feasible; use authored icons, correct Aether cyan semantics, material chip frame, locale-aware formatting |
| `RwScreenScaffold` | Correct full-bleed background/SafeArea separation and reusable header | MODIFY | Preserve safe-area architecture; permit illustrated background/material header variants and avoid universal void gradient |
| `RwSectionHeader` | Reusable hierarchy but neon bar/uppercase treatment | MODIFY | Convert to ink/banner/material accent and locale-appropriate casing |
| Material switches/default icons | Functional but visually generic | REPLACE | Wrap/style through the canonical material and icon language where visible |
| Material tokens for parchment/wood/stone/dark HUD | Missing | ADD | Required to express approved direction without one-off styling |
| Tabs, defender slots, role badges, cooldown ring | Screen-local or missing | ADD | Reusable stateful visuals are required by approved references and current battle UX |
| Current full-screen void gradients and broad glow helpers | Visually central today | DEPRECATE | Keep only for transitional compatibility or rare dimensional overlays; remove as default identity |

## 29. MISSING PRODUCTION ASSETS

- Final original RIFTWARDEN logo/wordmark and emblem.
- Licensed/original handmade display font, plus locale-complete body font plan and files.
- Production 16:9 main-menu/environment artwork with safe extension for wider devices.
- Production battlefield backgrounds for supported environments.
- Fortress/citadel art matching the approved handmade world and six slot positions.
- Updated gameplay sprites and larger portraits for Pulse Guard, Arc Ranger, and Titan Frame.
- Updated gameplay sprites for all seven implemented enemy archetypes, plus any boss art required by content.
- Rift portal/rift variants and restrained Rift/Aether VFX in the approved 2D style.
- Authored Aether, Shard, Cell, role, navigation, state, lock, level, settings, pause, back, and info icon family.
- Rift Collapse ability icon/illustration and targeting/cooldown visual assets.
- Upgrade illustrations for every current upgrade icon id and future content-safe template.
- Reusable wood board ends, nails/pegs, parchment tears/corners, stone caps, cloth/banner pieces, and selection markers suitable for code-native composition.
- Result-screen victory/defeat accent art and small world-story decorative props.
- Optional roster/loadout portrait set only after that feature is approved.

## 30. DEFINITION OF DONE

A future UI screen is compliant only when all applicable items are true:

- [ ] Uses repository-supported features, fields, resources, and actions only.
- [ ] Follows the authority assignment in section 26 and the handmade world-first identity.
- [ ] Reuses or extends the existing theme/component system; no parallel design system or one-off full-screen painted UI.
- [ ] Uses semantic `AppColors`, `AppSpacing`/`AppRadius`, `AppTypography`, and shared decoration tokens; no raw UI values where project lint prohibits them.
- [ ] Uses localized live text; no important localized text is baked into raster assets.
- [ ] Works at 640 x 360 dp without overflow, clipped actions, or illegible scaling.
- [ ] Works in both landscape rotations and applies horizontal safe-area padding.
- [ ] Uses directional layout/alignment and behaves correctly in RTL.
- [ ] Allows longer translations through flexible width, wrapping, or safe scrolling.
- [ ] Keeps all interactive targets at least 48 x 48 dp.
- [ ] Communicates critical states without relying on color alone.
- [ ] Keeps Aether cyan and Rift violet as accents and avoids excessive glow/gradients.
- [ ] Uses production-approved art with correct WebP/atlas pipeline rules and clean small-size silhouettes.
- [ ] Uses short, interruptible, production-friendly motion based on shared duration tokens.
- [ ] Keeps the combat battlefield primary; battle bottom HUD remains at or below 20% of screen height.
- [ ] Conforms to the combat UI performance and data-flow boundary defined canonically in `CLAUDE.md` and `docs/ARCHITECTURE.md`.
- [ ] Has been visually checked on light parchment, dark HUD, smallest landscape, wider/notched device, long-string locale, and Arabic RTL cases.
- [ ] Adds no military, cyberpunk, holographic, glass, generic crystal-fantasy, or franchise-imitative visual language.
