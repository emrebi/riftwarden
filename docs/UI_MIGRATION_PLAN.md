# RIFTWARDEN — UI Migration Plan (neon sci-fi → handmade cartoon)

Status: APPROVED (2026-09-16) · Visual authority: `docs/DESIGN.md` · Architecture authority: `CLAUDE.md`, `docs/ARCHITECTURE.md`
Default worker: Sonnet 5 Medium · Planner/reviewer: Opus

## 0. Execution workflow and progress

### Workflow (canonical from 2026-09-16)
- Opus = permanent planner/reviewer. Each turn: verify HEAD + `git status`, pick the next READY task from §6, confirm its dependencies are committed, emit ONE self-contained worker prompt.
- Worker executes exactly one task; never runs `git add/commit/reset/stash/checkout`; reports in the CLAUDE.md report format.
- Opus reviews the real `git diff`, re-runs validations itself (worker PASS is not trusted), answers APPROVE or FIX REQUIRED.
  APPROVE includes: manual device check if relevant, exact commit paths, commit title, next READY task.
- User commits; Opus verifies HEAD before starting the next task.
- Execution mode (user decision 2026-09-17): planner runs worker tasks as Sonnet subagents, reviews and commits batches itself up to Phase 6 (art integration), then stops for the user. User produces art in parallel.
- Commit cadence (user decision 2026-09-17): every task is still reviewed individually, but commits are BATCHED per group:
  C1 UI-05+UI-07 · C2 UI-08+UI-09 · C3 UI-04 (High, alone) · C4 UI-06 · C5 UI-10..UI-13 · C6 UI-14..UI-17 · C7 UI-18..UI-20+QA-01 ·
  C8 BATTLE-01+02 · C9 BATTLE-03+04 · C10 BATTLE-05 (alone) · C11 BATTLE-06..09 · C12 MENU-01 · C13 SEC-01..04 ·
  ART-PREP and each ARTINT alone; ARTINT-07 alone. Max 4 tasks per commit. Pending approved tasks are listed in the progress table.
  Worker prompts note that earlier approved tasks may be uncommitted in the tree and must not be touched.
- Model routing: default Sonnet 5 Medium; Sonnet 5 High only for UI-04 and ARTINT-07 (any other escalation must be justified first).
- Asset stream: starts after DOC-02; follows §5 order. Coding never waits for art unless a task is ART-BLOCKED.
  Generator (2026-09-17): web ChatGPT image generation (Codex drafts failed flat-fill/consistency). Per ART task:
  user uploads `design/references/05_UI_DESIGN_SYSTEM.png` + the surface-specific reference named in the ART section and pastes
  that section's SINGLE self-contained English prompt from `docs/ASSET_PROMPTS.md` (style rules embedded; nothing else to copy);
  ChatGPT returns ONE zip; user saves it as
  `design/art_intake/<ART-ID>.zip` (gitignored, never repo root) and extracts to `design/art_intake/<ART-ID>/`; planner reviews.
  Icon/ornament families are requested as ONE grid sheet on flat #FF00FF (one generation = consistent style), sliced by assetkit;
  ART-PREP recipes must accept both magenta sheets and alpha PNGs for ui_art groups.
  Earlier Codex drafts (aether, shard, cell, rift, attack; outside the repo) are not discarded: they may be uploaded to ChatGPT as
  silhouette references for ART-03, but final icons come from one consistent sheet.

**DOC-03 — Single-paste asset prompts (inserted 2026-09-17)**
- Goal: every ART section in `docs/ASSET_PROMPTS.md` is ONE self-contained English prompt the user pastes as-is (style bible,
  forbidden motifs and output format embedded), plus a short line "Upload: 05_UI_DESIGN_SYSTEM.png + <reference>" and the zip name.
- Remove: separate "prepend STYLE BIBLE" instructions, Tip A–D rationale blocks, Codex-specific sections; replace with the web ChatGPT
  zip workflow above. Families (ART-02 ornaments, ART-03 icons, ART-12 VFX) are requested as one magenta grid sheet with a fixed
  row-major order; single-subject art (portraits, illustrations, logo, scenes, fortress, backgrounds) stays one image per subject.
- Files: `docs/ASSET_PROMPTS.md`, `tools/assetkit/README.md` (intake wording), `.claude/skills/rw-assets/SKILL.md` (workflow wording).
- Art: ART-INDEPENDENT · Validation: analyze 0; assetkit verify unchanged · Worker: Sonnet Medium.
- Design/architecture decisions are not reopened; genuine blockers are raised as ARCHITECTURE QUESTION.

### Actual history (supersedes the originally planned commit split)
- `316e2b7` — DESIGN.md, references, this plan AND the upgrade-card engine (P15) in one commit; also tracks `RIFTWARDEN_APPROVED_REFERENCES.zip` (18 MB duplicate of `design/references/`). Removal is a user decision, not a migration task.
- `b0de6b1` — SAFE-01 (`kUpgradeCardsEnabled = false`). HEAD is playable; card offers disabled until BATTLE-01.

### Progress
| Task | Status | Commit |
|---|---|---|
| SAFE-01 | DONE | `b0de6b1` |
| DOC-01 | DONE | `970b904` |
| DOC-02 | DONE | `2ea1ea4` |
| UI-01 | DONE | `fd0acf1` |
| UI-02 | DONE | `1afb171` |
| DOC-03 | DONE | `21c9347` |
| UI-03 | DONE | `b06259a` |
| UI-05 | DONE | batch C1 |
| UI-07 | DONE | batch C1 |
| UI-08 | DONE (1 fix: RTL double mirror) | batch C2 |
| UI-09 | DONE | batch C2 |
| UI-04 | DONE (1 fix: bounded path cache) | batch C3 |
| UI-06 | DONE | batch C4 |
| UI-10 | DONE (1 fix: press crossfade, double semantics) | batch C5 |
| UI-11 | DONE | batch C5 |
| UI-12 | DONE | batch C5 |
| UI-13 | DONE (1 fix: modal overflow at 360h) | batch C5 |
| UI-14 | DONE (1 fix: card semantics hid action/body) | batch C6 |
| UI-15 | DONE (1 fix: damage trail color restored, raw white) | batch C6 |
| UI-16 | DONE | batch C6 |
| UI-17 | DONE | batch C6 |
| UI-18 | DONE | batch C7 |
| UI-19 | DONE | batch C7 |
| UI-20 | DONE | batch C7 |
| QA-01 | DONE | batch C7 |
| BATTLE-01 | DONE (1 fix: reselect softlock, reveal >320 ms, icon contrast) | batch C8 |
| BATTLE-02 | DONE | batch C8 |
| BATTLE-03 | DONE (1 fix: legacy dark band, segment -1) | batch C9 |
| BATTLE-04 | DONE (top offset overlapped top bar, fixed) | batch C9 |
| BATTLE-05 | DONE (1 fix: shared x/6 capacity indicator restored) | batch C10 |
| BATTLE-06 | DONE (planner nit: raw icon sizes to consts) | batch C11 |
| BATTLE-07 | DONE (gap: no dedicated a11y key for Rift Collapse, uses battleAimHint) | batch C11 |
| BATTLE-08 | DONE | batch C11 |
| BATTLE-09 | DONE | batch C11 |
| MENU-01 | READY | — |
| ART-03 (asset) | APPROVED (intake sheet, 19 icons) | not committed (intake) |
| ART-02 (asset) | APPROVED (intake sheet 4x2, 7 pieces) | not committed (intake) |
| ART-10 (asset) | APPROVED after 1 revision (watch on device: arc_overcharge horned dummy, titan_juggernaut enemy-like golem) | intake: ART-10_1.png (4x2, 8), ART-10_2.png (4x2, 5) |
| ART-09 (asset) | APPROVED (transparent sheet 4x1: portal, icon, illustration, reticle) | intake: ART-09.png |
| ART-05 (asset) | APPROVED (Codex gpt-5.6-luna revision replaced intake; ART-PREP notes: bulwark crosses cell edge ~8px -> bbox/component slicing, tight key tolerance for thin violet lines) | intake: ART-05.png |
| ART-04 (asset) | IN PROGRESS (Codex gpt-5.6-luna) | intake: codex/ART-04/ |
| ART-01, 06, 07, 08, 11, 12, 13 (asset) | IN PROGRESS (user, parallel) | — |
| all others | PENDING (see §6 order) | — |

The planner updates this table in the commit of each approved task. This file is the single source of truth for task status; the planner's private plan file (P1–P17 era) is archive only.

Architecture decisions AQ-1..AQ-4 are APPROVED (see "ARCHITECTURE DECISIONS" at the end).

## 1. Current state (2026-09-16, verified in repository)

- Theme: `lib/app/theme/` — AppColors (dark neon; `aether` = amber #FFC44D, `aetherCyan` = cyan), AppSpacing/AppRadius/AppDuration (sound, keep),
  AppTypography (sound roles, fonts null), AppDecorations (AppGradients void/cyan, AppShadows.glow, AppBorders, AppBorderRadii), AppTheme (global dark).
- Shared widgets (`lib/shared/widgets/`): RwButton(variant primary/secondary/ghost/danger*), RwIconButton, RwPanel, RwDialog (unused by screens),
  RwCard (gallery only), RwProgressBar (damage trail), RwCurrencyChip (aether/shard/cell), RwScreenScaffold, RwSectionHeader. All neon.
- Legacy amber `AppColors.aether` used in: battle/unit_spawn_bar (6), battle/ability_shop_panel (4), battle/battle_top_bar (2), result/result_ad_button (3), shared/rw_currency_chip (1).
- `AppShadows.glow` / `AppGradients.*` / `AppColors.voidDeep` used across shared widgets, battle, level_select, result, orientation_gate.
- No Flutter widget displays raster art today (`Image.asset` absent). Sprite atlases are Flame-only (`engine/render/atlas_registry.dart`).
- Screens (all landscape, 640x360 smoke-tested): orientation_gate, boot (dev, temporary), main_menu, level_select, settings, result, battle HUD.
  Menus use sample data from boot; routes not connected (out of scope here).
- Upgrade-card ENGINE (P15) committed (`316e2b7`), no card UI yet; offers disabled by SAFE-01 (`b0de6b1`) until BATTLE-01.
- Art: all sprites are generated geometric placeholders; no logo, fonts, backgrounds, audio.
- Stale docs for the new direction: README (portrait), AGENTS.md (agy/Gemini-specific contract + neon visual identity), CLAUDE.md role table (Gemini UI / Gemini web asset),
  docs/ASSET_PROMPTS.md (superseded style), docs/ui_briefs/* (all neon-era briefs incl. battle-upgrade-cards.md), ARCHITECTURE M5 step 21 ("Gemini UI integration").

## 2. Migration principles

1. Foundation first: tokens → primitives → shared components → screens → art integration → cleanup. A screen is migrated once.
2. No parallel theme/component library (DESIGN §28). Evolve existing files and public APIs; add variants/params with defaults.
3. Public constructors of screens and shared widgets stay source-compatible. New params are optional.
4. Legacy neon tokens stay as documented LEGACY aliases until UI-CLEAN; do NOT use `@Deprecated` (would break `flutter analyze` 0).
5. Art-independent by default: every art slot has a code-native fallback, so coding never waits for art.
6. Repository-backed scope only. Pictured Gold/XP/profile/skins/Daily Rewards/Achievements/Lore/Store/Meta/loadout = FUTURE, not planned.
7. Gameplay architecture untouched. Battle UI reads `BattleSignals` via `ValueListenableBuilder`; no Riverpod in battle; no signal/command changes in UI tasks.
8. Each task updates the dev widget gallery (`lib/features/boot/view/widget_gallery.dart`) for the components it changes — the gallery is the visual QA surface.
9. One task = one conceptual change, reviewable in one diff, gated by analyze/ui_lint/tests.
10. Extensible without re-analysis: every task that adds a shared component, token group, art path or asset recipe adds/updates its row in `docs/CONTENT_MAP.md` in the same task.
11. Token economy follows CLAUDE.md "Token ekonomisi"; cosmetic doc gaps are folded into the next doc task, not a separate round.

## 3. Dependency graph

```
SAFE-01 ─┐
DOC-01 ──┼─► UI-01 ─► UI-02 ─► UI-03 ─► UI-04 ─┬─► UI-10 (button) ─┬─► UI-11 icon btn
DOC-02 ─(asset stream)                          │                   ├─► UI-12 panel ─► UI-13 dialog
         UI-05 typography ─────────────────────►┤                   ├─► UI-14 card
         UI-06 theme ◄── UI-01..UI-05           │                   ├─► UI-15 progress
         UI-07 number format ──────────────────►┤                   ├─► UI-16 currency chip ◄─ UI-07, UI-08
         UI-08 icon registry ──────────────────►┤                   ├─► UI-17 scaffold+header
         UI-09 art slot (AQ-1) ────────────────►┘                   ├─► UI-18 defender slot ◄─ UI-09
                                                                    ├─► UI-19 cooldown ring/ability frame
                                                                    └─► UI-20 toggle
UI-10..UI-20 ─► QA-01 (component smoke + RTL)
QA-01 ─► BATTLE-01 upgrade overlay (◄ UI-13 veil, UI-14 card; removes SAFE-01 guard) ─► BATTLE-02 overlay tests
      ─► BATTLE-03 top bar ─► BATTLE-04 core HP ─► BATTLE-05 purchase row ─► BATTLE-06 ability shop panel
      ─► BATTLE-07 rift collapse button ─► BATTLE-08 pause modal ─► BATTLE-09 battle smoke update
BATTLE-09 ─► MENU-01 ─► SEC-01 level select ─► SEC-02 settings ─► SEC-03 result ─► SEC-04 orientation gate
ART-PREP (after UI-09, any time) ─► ARTINT-* (each blocked by its ART task, see §5)
All screens + ARTINT done ─► UI-CLEAN ─► QA-FINAL
```

Asset → coding blockers:
```
DOC-02 ──► every ART-xx
ART-02 ornaments ─► ARTINT-01      ART-03 icons ─► ARTINT-02      ART-04 defenders ─► ARTINT-03, ARTINT-06
ART-10 upgrade art + ART-09 rift collapse ─► ARTINT-04            ART-05 enemies + ART-12 VFX ─► ARTINT-06
ART-06 fortress + ART-07 battlefield + ART-09 portal ─► ARTINT-07 ART-11 props ─► ARTINT-08
FONT-01 ─► ARTINT-05               ART-01 logo + ART-08 menu scene ─► ARTINT-09   ART-13 result accents ─► ARTINT-10
```

## 4. Coding workstream — ordered tasks

Default validation (unless task says otherwise): `flutter analyze` 0 · `python tools/ui_lint.py` TEMIZ · `flutter test test/ui_smoke_test.dart` PASS.
Default must-not-change: `lib/engine/**`, `lib/domain/**`, `lib/content/**`, `assets/content/**`, `lib/data/**`, `pubspec.yaml`, screen/shared public constructors (additive optional params allowed), `BattleSignals`/`BattleCommands`.
Worker contract: CLAUDE.md worker rules; tests only where the task says so; no git commands.

### PHASE 0 — SAFETY / BASELINE

**SAFE-01 — Temporary upgrade-offer guard (applied on uncommitted engine WIP)**
- Goal: the upgrade-card engine can be committed in a playable state while no card UI exists.
- Why now: without it the uncommitted engine pauses battle forever at the first kill threshold; it must never be committed that way.
- Files likely: `lib/core/constants/game_constants.dart` (add `const bool kUpgradeCardsEnabled = false;` with a Turkish ASCII comment: why it exists, that BATTLE-01 sets it true/removes it), `lib/engine/simulation/systems/upgrade_system.dart` (in `step`: keep `world.totalKills += world.killsThisStep;`, then `if (!kUpgradeCardsEnabled) return;` before threshold/offer logic).
- Must not change: all other WIP files (signals, controller, world, battle_system, default_systems, battle_screen, ability_shop_panel, upgrade_text, content, l10n, tests); do not revert, reformat or "clean up" any WIP; no git commands (no stash/checkout/commit).
- Dependencies: none (runs on the current working tree). · Art: ART-INDEPENDENT
- Non-goals: UI, new tests, threshold/content changes, controller/signal changes, removing any WIP code.
- Acceptance: with the flag false no offer is ever opened and `sim.beginSlowMotionPause` is never called by UpgradeSystem; battle reaches victory/defeat; `chooseUpgrade`/`rerollUpgrades` stay safe no-ops (no active offer); flipping the flag to true restores P15 behavior unchanged; diff limited to the two files.
- Validation: `flutter analyze` 0; `flutter test` (all: content, ui_smoke, orientation gate); `python tools/ui_lint.py`; `python tools/l10n_sync.py --check`. Planner additionally checks `git status` shows only the pre-existing WIP set + these two files, stash empty. User: play level 1 to the end on device.
- Commit: together with the whole engine WIP (Commit 2). · Risk: low. · Worker: Sonnet Medium.

**BASE-00 — Visual baseline (USER, manual, not a worker task)**
- Capture device screenshots (640x360-class and a wide notched phone, both rotations) of: gate, main menu, level select, settings, result V/D, battle HUD, ability shop open, pause, widget gallery. Keep locally (not committed) for before/after review.

**DOC-01 — Align agent/docs with DESIGN.md**
- Goal: workers must not read neon-era instructions.
- Why now: every UI task reads CLAUDE.md/AGENTS.md first.
- Files likely: `README.md` (landscape + handmade identity, link DESIGN.md), `AGENTS.md` (becomes the generic UI/asset agent contract for the Sonnet UI worker and the Codex image agent: replace neon visual identity with a pointer to DESIGN.md, remove agy/Gemini-specific instructions, keep the UI rules and screen-layout constraints), `CLAUDE.md` (doc index links to DESIGN.md + UI_MIGRATION_PLAN.md; role table: UI implementation = Sonnet worker, assets = Codex image agent + `tools/assetkit`; workflow rules unchanged), `docs/ARCHITECTURE.md` (M5 step 21 → "UI migration per UI_MIGRATION_PLAN.md"; neon visual-identity wording → DESIGN.md pointer), `docs/ui_briefs/README.md` NEW (all existing briefs = LEGACY/superseded, do not implement), `.claude/skills/rw-ui-integrate/SKILL.md` (LEGACY header pointing to DESIGN.md + UI_MIGRATION_PLAN.md; body unchanged).
- Must not change: code, CLAUDE.md architecture rules/worker rules/commit protocol/pitfalls, DESIGN.md, UI_MIGRATION_PLAN.md, existing brief files' contents, `tools/agy-task.ps1`.
- Dependencies: none. · Art: ART-INDEPENDENT
- Non-goals: rewriting ASSET_PROMPTS (DOC-02). · Acceptance: no doc still instructs neon/portrait/sci-fi-dashboard visuals.
- Validation: analyze (no code). · Risk: low. · Worker: Sonnet Medium.

**DOC-02 — Rewrite docs/ASSET_PROMPTS.md for handmade direction**
- Goal: prompt templates + technical rules for the Codex image agent (DESIGN §17–19, §25, §29).
- Why now: DESIGN §25 forbids commissioning art before this; unblocks the whole asset stream in parallel with coding.
- Files likely: `docs/ASSET_PROMPTS.md`, `tools/assetkit/README.md` (target sizes per asset class), `.claude/skills/rw-assets/SKILL.md` (Codex image-agent workflow instead of Gemini web).
- Must not change: assetkit code, recipes (ART-PREP does that). · Dependencies: none. · Art: ART-INDEPENDENT
- Acceptance: one section per ART task (§5) with subject list from repository ids, style bible, forbidden motifs, size/format/chroma rules, deliverable naming.
- Validation: none beyond analyze. · Risk: low. · Worker: Sonnet Medium.

### PHASE 1 — DESIGN FOUNDATION

**UI-01 — Semantic color + material tokens (additive)**
- Goal: add DESIGN §4 semantics without visual change yet.
- Files: `lib/app/theme/app_colors.dart`.
- Scope: add `background`, `rift`, `health`, `textOnLight`/`textOnLightSecondary`/`textOnDark`/`textOnDarkSecondary`, `cta` (amber), `reward` (amber), material neutrals `parchmentBase/Edge`, `woodFace/Edge`, `stoneFace/Edge`, `hudFace/Edge`, `outlineInk`, `shadowWarm`, `selection`. Retune nothing yet. Mark neon-only tokens LEGACY in doc comments.
- Must not change: existing token values (UI-02 does), other files. · Deps: DOC-01. · Art: ART-INDEPENDENT
- Non-goals: using new tokens. · Acceptance: every §4 semantic has a token; values tuned against reference intent (not hex copying).
- Validation: analyze, ui_lint. · Risk: low. · Worker: Sonnet Medium.

**UI-02 — Aether semantic swap (amber → cyan)**
- Goal: `AppColors.aether` = battle Aether resource only (blue/cyan); amber action/affordability/reward emphasis moves to `AppColors.cta`.
- Rule: resource identity (Aether counter, cost icon/value) keeps `AppColors.aether`; emphasis (buy border/glow, "abilities available" highlight/dot, ad/reward CTA) uses `AppColors.cta`. Required so the abilities toggle "open" (cyan) and "affordable" (amber) states stay distinguishable.
- Files: `app_colors.dart` (aether value → reference intent 0xFF48C8F2), `lib/features/battle/widgets/unit_spawn_bar.dart` (abilities toggle affordable border/icon/glow/dot → cta; unit cost stays aether), `lib/features/battle/widgets/ability_shop_panel.dart` (buy border/glow → cta; cost icon/text stays aether), `lib/features/result/widgets/result_ad_button.dart` (all amber → cta). `battle_top_bar.dart` and `rw_currency_chip.dart` unchanged (they mean the resource).
- Deps: UI-01. · Art: ART-INDEPENDENT · Acceptance: no emphasis meaning left under `AppColors.aether`; `aetherCyan` kept; only color token references change (no layout/behavior change).
- Risk: low (intended visible color shift). · Worker: Sonnet Medium.

**UI-03 — Decorations rebuild (materials, depth, restrained energy)**
- Goal: DESIGN §21 depth + material recipes behind existing file.
- Files: `lib/app/theme/app_decorations.dart`.
- Scope: add `AppMaterial` enum (parchment, wood, stone, hud) + `AppMaterials.fill/edge/keyline(material)`; `AppShadows.contact`, `raised`, `pressed` (warm, narrow, directional); `AppShadows.energy(color)` tight accent. Keep `AppGradients.*`, `AppShadows.glow`, `AppShadows.panel`, `AppBorders`, `AppBorderRadii` compiling as LEGACY.
- Must not change: callers. · Deps: UI-01. · Art: ART-INDEPENDENT
- Acceptance: new API documented; zero call-site changes. · Risk: low. · Worker: Sonnet Medium.

**UI-04 — RwMaterialSurface primitive**
- Goal: one code-native surface all components use: material face + bold keyline + inner seam + controlled irregular silhouette (chipped/clipped corners for stone/hud, softened uneven corners for parchment/wood) + depth state (normal/raised/pressed/disabled/selected) + optional decoration slot (ART-01 later).
- Files: NEW `lib/shared/widgets/rw_material_surface.dart` (ShapeBorder/CustomPainter; deterministic irregularity from a seed/key, not random per frame), gallery section.
- Must not change: existing widgets. · Deps: UI-03. · Art: ART-OPTIONAL (decoration slot empty until ARTINT-01)
- Non-goals: raster ornaments, any screen. · Acceptance: all materials × states render in gallery at 640x360; RTL mirrors asymmetric details; content bounds rectangular; paints cached (no per-frame allocation in paint for static state).
- Validation: default + gallery smoke. · Risk: medium — every component depends on its API. · Worker: **Sonnet High** (foundational API design + custom painting + RTL).

**UI-05 — Typography roles for handmade UI**
- Files: `lib/app/theme/app_typography.dart`.
- Scope: add `screenTitle`, `sectionTitle`, `button`, `smallLabel` (keep existing getters as aliases); remove forced tracking/uppercase assumptions from label roles; add `onLight(style)`/`onDark(style)` color helpers; keep tabular `numeric`; `AppFonts.display` stays null with hook for FONT-01.
- Deps: UI-01. · Art: ART-OPTIONAL (fonts later) · Acceptance: no size below current small-label; body ≥13, critical controls ≥16 dp.
- Risk: low. · Worker: Sonnet Medium.

**UI-06 — AppTheme remap**
- Files: `lib/app/theme/app_theme.dart`.
- Scope: scaffold background → `background`; ColorScheme from new semantics; Material defaults (text selection, dialog, progress, tooltip) mapped to materials; keep locale font selection and mobile behavior.
- Deps: UI-01, UI-03, UI-05. · Art: ART-INDEPENDENT · Acceptance: screens still render (colors shift), smoke PASS.
- Risk: medium (global visual shift) · Worker: Sonnet Medium.

**UI-07 — Locale-aware number formatting**
- Files: NEW `lib/shared/format/rw_number_format.dart` (intl NumberFormat, Arabic digits for `ar`), no call-site changes yet.
- Deps: none. · Art: ART-INDEPENDENT · Acceptance: unit-free helper; used later by UI-15/UI-16/BATTLE-*. Closes KNOWN_GAPS "Arapça rakamlar" when adopted.
- Validation: analyze. · Risk: low. · Worker: Sonnet Medium.

**UI-08 — Semantic icon registry (RwIcon / AppIcons)**
- Files: NEW `lib/shared/widgets/rw_icon.dart`.
- Scope: enum of DESIGN §16 semantics (aether, shard, cell, rift, attack, support, area, utility, magic, health, lock, level, settings, pause, back, info, plus, close, check); code-native Material fallback today; back mirrored in RTL; raster source hook (resolved by UI-09) later.
- Deps: UI-01. · Art: ART-OPTIONAL (ART-03 swaps in ARTINT-02) · Acceptance: every glyph readable at 24 dp in 48 dp control in gallery.
- Risk: low. · Worker: Sonnet Medium.

**UI-09 — UI art slot (see ARCHITECTURE QUESTION AQ-1)**
- Goal: one way for Flutter widgets to show raster art (portraits, upgrade illustrations, logo, ornaments) with graceful fallback.
- Files: NEW `lib/shared/widgets/rw_art.dart` (+ path conventions `assets/images/ui_art/<group>/<id>.webp`), `pubspec.yaml` assets entry for `assets/images/ui_art/` (explicitly allowed for this task), empty folder keep file.
- Scope: `RwArt(group, id, fallback)` → `Image.asset` with `errorBuilder` → fallback widget; no engine import.
- Deps: UI-01 (AQ-1 APPROVED). · Art: ART-OPTIONAL · Acceptance: missing file shows fallback without exception; no `lib/engine` import; ids follow AQ-2 convention (`portraits/<unitId>`, `illustrations/<upgrade.icon>`, `icons/<name>`, `ornaments/<name>`, `logo/<name>`, `scenes/<name>`); smoke PASS.
- Risk: low-medium (pubspec). · Worker: Sonnet Medium.

### PHASE 2 — SHARED COMPONENTS (each updates its gallery section)

**UI-10 — RwButton** · Files: `rw_button.dart` · Scope: variants on RwMaterialSurface — primary (amber/cta board), secondary (parchment/timber), ghost (quiet timber/text), danger (red clay); add optional `isSelected`; pressed 1–2 dp depression within AppDuration.instant/fast; disabled flat; keep API (label, onPressed, variant, icon, isExpanded, height) · Deps: UI-04, UI-05, UI-08 · Art: ART-OPTIONAL (nails/board ends later) · Accept: 48 dp min, long-label wrap/ellipsis rule per DESIGN §23 · Worker: Sonnet Medium.

**UI-11 — RwIconButton** · Files: `rw_icon_button.dart` · Scope: `material` param (stone default, wood, hud); `isSelected`/`isActive` (targeting) state; accept `RwIconData`/IconData; keep color override params working · Deps: UI-04, UI-08 · Art: ART-OPTIONAL · Worker: Sonnet Medium.

**UI-12 — RwPanel** · Files: `rw_panel.dart` · Scope: `variant` (standard, large, modal, smallInfo) × `material` (parchment default, hud, wood frame); header styling via UI-05; keep API · Deps: UI-04 · Art: ART-OPTIONAL · Worker: Sonnet Medium.

**UI-13 — RwDialog + battle veil** · Files: `rw_dialog.dart`, NEW `lib/shared/widgets/rw_veil.dart` (dim + slight desaturate overlay, used by upgrade overlay & pause) · Scope: modal = RwPanel.modal; flexible localized sizing; safe area; keep `show()` · Deps: UI-10, UI-12 · Art: ART-INDEPENDENT · Worker: Sonnet Medium.

**UI-14 — RwCard anatomy + states** · Files: `rw_card.dart` · Scope: shared anatomy (frame, state border, art zone, title band, body, badge/type marker, action zone); states standard/selected/locked/disabled; `kind` defender/upgrade/standard; rarity as secondary accent; art zone takes any widget (RwArt later); keep API (title, rarity, description, icon, badge, child, onTap, isSelected) · Deps: UI-04, UI-05, UI-09 · Art: ART-OPTIONAL · Accept: 3 upgrade cards fit one row at 640x360 · Worker: Sonnet Medium.

**UI-15 — RwProgressBar** · Files: `rw_progress_bar.dart`, NEW `rw_segmented_progress.dart` (wave segments) · Scope: illustrated track (hud/parchment), semantic variants health (auto danger <25%), cooldown, neutral; keep clamping + damage trail logic; remove neon glow · Deps: UI-04 · Art: ART-INDEPENDENT · Worker: Sonnet Medium.

**UI-16 — RwCurrencyChip** · Files: `rw_currency_chip.dart` · Scope: material chip, RwIcon per currency (aether cyan), RwNumberFormat, tabular counter; keep enum + API · Deps: UI-07, UI-08, UI-04 · Art: ART-OPTIONAL · Worker: Sonnet Medium.

**UI-17 — RwScreenScaffold + RwSectionHeader** · Files: `rw_screen_scaffold.dart`, `rw_section_header.dart` · Scope: background slot (default `AppColors.background` scene color, optional RwArt background), header as wood/banner strip with RwIconButton back (RTL mirrored); section header ink/banner accent, locale-appropriate casing; keep SafeArea split and API · Deps: UI-10, UI-11, UI-09 · Art: ART-OPTIONAL · Worker: Sonnet Medium.

**UI-18 — RwDefenderSlot** · Files: NEW `lib/shared/widgets/rw_defender_slot.dart` · Scope: stateless visual with states empty/available/selected/locked/purchaseable/unaffordable/occupied; portrait slot (RwArt fallback = unit placeholder shape/initial), cost row (RwIcon aether + RwNumberFormat), count badge; stateless, parameter-driven · Deps: UI-04, UI-08, UI-09, UI-07 · Art: ART-OPTIONAL (portraits in ARTINT-03) · Worker: Sonnet Medium.

**UI-19 — RwCooldownRing / ability frame** · Files: NEW `lib/shared/widgets/rw_ability_frame.dart` · Scope: circular stone frame, states ready (single pulse), cooldown (radial mask + tabular seconds), targeting (reticle), unavailable; painter allocation-free for animated state · Deps: UI-04, UI-08, UI-07 · Art: ART-OPTIONAL (ART-09 icon) · Worker: Sonnet Medium.

**UI-20 — RwToggle** · Files: NEW `lib/shared/widgets/rw_toggle.dart` · Scope: material-language on/off control for settings (48 dp, state not color-only) · Deps: UI-04 · Art: ART-INDEPENDENT · Worker: Sonnet Medium.

**QA-01 — Component smoke + RTL** (tests allowed) · Files: `test/ui_smoke_test.dart` · Scope: pump widget gallery at 640x360 and 800x360 in `en` and `ar`; exceptions/overflow none; RwArt fallback path exercised · Deps: UI-10..UI-20 · Art: ART-INDEPENDENT · Validation: flutter test (all) · Worker: Sonnet Medium.

### PHASE 3 — BATTLE UI (engine WIP committed together with SAFE-01; see §0 and §8)

**BATTLE-01 — Upgrade choice overlay (replaces P16)** · Files: NEW `lib/features/battle/widgets/upgrade_choice_overlay.dart`, `battle_screen.dart` (wire, above HUD, below pause), `game_constants.dart` + `upgrade_system.dart` (remove SAFE-01 guard — only these lines) · Scope: DESIGN §13 — RwVeil, banner (upgradeChooseTitle), three RwCard(kind: upgrade) in one row centered for 1–2, `upgrade_text.dart` titles/descriptions/rarity, family marker, staggered ≤320 ms interruptible reveal, reroll RwButton with `upgradeRerollsLeft`, calls `commands.chooseUpgrade/rerollUpgrades`; content passed as param (no provider in widget) · Must not change: signals/commands/controller/upgrade engine logic · Deps: UI-13, UI-14, UI-10, QA-01 · Art: ART-OPTIONAL (ART-10 in ARTINT-04) · Risk: medium (touches WIP files) · Worker: Sonnet Medium.

**BATTLE-02 — Overlay tests (replaces P17)** · Files: `test/ui_smoke_test.dart` · Scope: 640x360/800x360, 3 and 1 card, tap → chooseUpgrade(id), rerollsLeft 0 → no call, `ar` locale · Deps: BATTLE-01 · Validation: flutter test (all) · Worker: Sonnet Medium.

**BATTLE-03 — Top bar (wave plaque, Aether chip, pause)** · Files: `battle_top_bar.dart` · Scope: parchment/wood wave plaque with RwSegmentedProgress (current/total; boss emphasis only via existing `isBossWave`), RwCurrencyChip(aether), RwIconButton pause; thin; viewPadding · Deps: UI-11, UI-15, UI-16 · Art: ART-OPTIONAL · Worker: Sonnet Medium.

**BATTLE-04 — Core HP panel** · Files: `core_health_bar.dart`, `battle_screen.dart` (placement only if needed) · Scope: label, RwProgressBar health + trail, value, warning icon + slow pulse <25% · Deps: UI-15, UI-08 · Art: ART-OPTIONAL · Worker: Sonnet Medium.

**BATTLE-05 — Defender purchase row** · Files: `unit_spawn_bar.dart` · Scope: RwDefenderSlot per unit (purchaseable/unaffordable/occupied-count from `slots`), cost, "x/6" feedback, fast repeat purchase, abilities entry affordance; bottom strip ≤20% incl. safe area · Must not change: callbacks/params used by battle_screen · Deps: UI-18 · Art: ART-OPTIONAL (portraits ARTINT-03) · Risk: medium (469-line file) · Worker: Sonnet Medium.

**BATTLE-06 — Ability shop panel restyle** · Files: `ability_shop_panel.dart` (WIP-touched) · Scope: RwPanel smallInfo/parchment, compact offer cards (RwCard standard, owned/unaffordable states), RwButton buy; keep `upgrades` param + `upgrade_text.dart` use · Deps: UI-12, UI-14, UI-10 · Art: ART-OPTIONAL · Worker: Sonnet Medium.

**BATTLE-07 — Rift Collapse control + targeting hint** · Files: `ability_button.dart`, `battle_screen.dart` (aim hint styling only) · Scope: RwAbilityFrame states from `AbilityState` (cooldownRemaining/Total, isAiming); tap again exits targeting (existing command) · Deps: UI-19 · Art: ART-OPTIONAL (ART-09) · Worker: Sonnet Medium.

**BATTLE-08 — Pause modal** · Files: `battle_pause_overlay.dart` · Scope: RwVeil + RwPanel.modal + RwButtons; behavior unchanged · Deps: UI-13 · Art: ART-INDEPENDENT · Worker: Sonnet Medium.

**BATTLE-09 — Battle smoke update** (tests allowed) · Files: `test/ui_smoke_test.dart` · Scope: HUD widget type list, `ar` locale, bottom strip height ≤20% assertion · Deps: BATTLE-03..08 · Worker: Sonnet Medium.

### PHASE 4 — MAIN MENU

**MENU-01 — Main menu structure (world-integrated, art-independent)** · Files: `lib/features/main_menu/**` · Scope: DESIGN §15 composition — logo region (text/RwArt fallback, no FittedBox body text), PLAY dominant cta board, secondary boards only for backed flows (Journey/Level select, Settings); Store/Upgrades buttons and Shard/Cell wallet HIDDEN (params retained, unused, documented) · Must not change: MainMenuScreen constructor · Deps: UI-10, UI-17, UI-09 · Art: ART-OPTIONAL · Decision: AQ-3 APPROVED (hide non-backed areas, keep constructor compatibility) · Same rule applies wherever Store/Meta/wallet appear (e.g. SEC-01 Shard chip, SEC-02 restore purchases row is kept only if its callback is wired; otherwise hidden) · Worker: Sonnet Medium.

### PHASE 5 — CURRENT SECONDARY SCREENS

**SEC-01 — Level select** · Files: `lib/features/level_select/**` · Scope: parchment journey map cards (RwCard/RwPanel), node states via shared visuals (locked = lock + silhouette, current = restrained pulse), remove glow · Keep data types/constructor · Deps: UI-14, UI-12, UI-17 · Art: ART-OPTIONAL · Worker: Sonnet Medium.

**SEC-02 — Settings** · Files: `lib/features/settings/**` · Scope: RwToggle rows, parchment panels, action rows → RwButton secondary · Deps: UI-20, UI-12, UI-17 · Art: ART-INDEPENDENT · Worker: Sonnet Medium.

**SEC-03 — Result (victory/defeat)** · Files: `lib/features/result/**` · Scope: title banner, reward row with RwCurrencyChip, primary action immediate, ad button cta/reward semantics, `canWatchAd` rule kept · Deps: UI-10, UI-12, UI-16 · Art: ART-OPTIONAL (ART-13 in ARTINT-10) · Worker: Sonnet Medium.

**SEC-04 — Orientation gate** · Files: `lib/features/orientation_gate/view/**`, `widgets/**` · Scope: background/semantics/phone indicator colors to new language; controller untouched; portrait 360x640 + landscape remain valid · Deps: UI-01..UI-06 · Art: ART-INDEPENDENT · Worker: Sonnet Medium.

(Boot dev menu: NOT migrated — temporary; must only keep compiling.)

### PHASE 6 — PRODUCTION ART INTEGRATION (coding side)

**ART-PREP — assetkit for UI art** · Acceptance addition: family sheets (ART-02 4x2, ART-03 5x4, ART-12) and multi-sheet single-subject deliveries on alpha (ART-10: two 4x2 transparent sheets, 13 ids row-major across sheets) are sliced by their DECLARED grid (cols x rows, row-major names, empty cells skipped), not by auto blob detection — detached parts of one subject (ART-02 selection_marker spikes, ART-03 level sparkles) must stay with their subject; then chroma + trim per cell · Files: `tools/assetkit/assetkit.py`, new recipes `portraits.json`, `ui_art.json`, `illustrations.json` (non-atlas per-file WebP output into `assets/images/ui_art/<group>/`), `verify` extended to check RwArt ids referenced by content (unit ids, upgrade icon ids, ability icon) · Deps: UI-09, DOC-02 · Art: ART-INDEPENDENT · Validation: assetkit verify · Worker: Sonnet Medium. (Can run any time after UI-09.)

**ARTINT-01 — UI ornament kit into RwMaterialSurface decoration slots** · ART-BLOCKED (ART-02) · Files: `rw_material_surface.dart`, recipes · Worker: Sonnet Medium.
**ARTINT-02 — Icon family into RwIcon** · ART-BLOCKED (ART-03) · Files: `rw_icon.dart` · Worker: Sonnet Medium.
**ARTINT-03 — Defender portraits into RwDefenderSlot / purchase row** · ART-BLOCKED (ART-04 portraits) · Files: `rw_defender_slot.dart`, `unit_spawn_bar.dart` (id → RwArt) · Worker: Sonnet Medium.
**ARTINT-04 — Upgrade illustrations + Rift Collapse art** · ART-BLOCKED (ART-10, ART-09) · Files: `upgrade_choice_overlay.dart`, `ability_shop_panel.dart`, `rw_ability_frame.dart` · Worker: Sonnet Medium.
**ARTINT-05 — Fonts** · ART-BLOCKED (FONT-01) · Files: `pubspec.yaml` fonts, `assets/fonts/`, `app_typography.dart` AppFonts · Accept: Arabic/CJK/Thai coverage; no label depends on display glyphs · Worker: Sonnet Medium.
**ARTINT-06 — Gameplay sprites (units, enemies, FX) re-pack** · ART-BLOCKED (ART-04 sprites, ART-05, ART-12) · Files: atlases via assetkit; renderer scale constants only if sizes change (`engine/render/*` — render-only change, allocation rules apply) · Validation: + assetkit verify + device FPS check · Worker: Sonnet Medium.
**ARTINT-07 — Battlefield background, fortress, rift portals** · ART-BLOCKED (ART-06, ART-07, ART-09) · Files: `lib/engine/render/map_renderer.dart` (image background with wide-screen extension, fortress sprite), `assets/content/castles.json` slot coordinates (data only, to match art), recipes · Risk: high (engine render + content alignment + letterbox) · Worker: **Sonnet High**.
**ARTINT-08 — Environment props** · ART-BLOCKED (ART-11) · Files: `assets/content/environments.json` sprite ids, world atlas · Note: current decor ids (crystal_rock_*, energy_pylon) conflict with DESIGN anti-goals → new ids · Worker: Sonnet Medium.
**ARTINT-09 — Logo + main menu scene** · ART-BLOCKED (ART-01, ART-08) · Files: `lib/features/main_menu/**` (RwArt swap only) · Worker: Sonnet Medium.
**ARTINT-10 — Result accents** · ART-BLOCKED (ART-13) · Files: `lib/features/result/**` · Worker: Sonnet Medium.

**UI-CLEAN — Remove legacy neon** · ART-INDEPENDENT (but last) · Files: `app_decorations.dart`/`app_colors.dart` legacy removal (AppGradients.screenBackground/primaryButton/dangerButton/panel, AppShadows.glow broad usage, void* as defaults), `tools/ui_lint.py` new rule forbidding legacy tokens, unused world sprites (aether_core, rift_violet, rift_magenta) · Deps: all screens + ARTINT done · Validation: default + assetkit verify · Worker: Sonnet Medium.

**QA-FINAL — DESIGN §30 compliance pass** (tests allowed) · Scope: per-screen checklist, ui_smoke with `ar` + long-string locale (de) + 640x360 + 800x360; update KNOWN_GAPS · Deps: UI-CLEAN · Worker: Sonnet Medium.

## 5. Asset workstream (Codex image agent — do not start before DOC-02)

| ID | Asset | Repository subjects | Unblocks | Priority |
|---|---|---|---|---|
| ART-01 | Logo/wordmark + Rift/Warden emblem (no localized text other than the name) | — | ARTINT-09 | P3 |
| ART-02 | UI ornament kit: board ends, nails/pegs, parchment tears/corners, stone caps, banner tails, selection marker | — | ARTINT-01 | P1 |
| ART-03 | Icon family (24–48 dp): aether, shard, cell, rift, attack, support, area, utility, magic, health, lock, level, settings, pause, back, info, plus, close, check | RwIcon enum | ARTINT-02 | P1 |
| ART-04 | Defenders: portraits + gameplay sprites | pulse_guard, arc_ranger, titan_frame | ARTINT-03, ARTINT-06 | P1 |
| ART-05 | Enemies gameplay sprites | drifter, skitter, bulwark, splitter, phaseborn, leech, spawner | ARTINT-06 | P2 |
| ART-06 | Fortress/citadel with 6 visible slot positions | castles.json citadel_basic | ARTINT-07 | P2 |
| ART-07 | Battlefield background 16:9 + wide extension, clean fortress→rift value corridor | environments.json fractured_edge | ARTINT-07 | P2 |
| ART-08 | Main menu environment scene 16:9 + wide extension | — | ARTINT-09 | P3 |
| ART-09 | Rift portal ring + Rift Collapse icon/illustration + targeting reticle | abilities.json rift_collapse | ARTINT-04, ARTINT-07 | P1 |
| ART-10 | Upgrade illustrations per icon id | upgrade_chain, _pierce, _crit, _explosion, _swarm, _economy, _core, _pulse_dualshot, _pulse_overcharge, _arc_overcharge, _arc_focus, _titan_shockwave, _titan_juggernaut | ARTINT-04 | P1 |
| ART-11 | Environment props (vegetation, ruins, floating land, towers; no generic crystals) | new decor ids | ARTINT-08 | P3 |
| ART-12 | VFX: hit, death puff, aether mote, core impact, ability blast, projectiles | fx atlas ids | ARTINT-06 | P2 |
| ART-13 | Result victory/defeat accents | — | ARTINT-10 | P3 |
| FONT-01 | Display font (original/licensed) + body families (Latin, Arabic, CJK, Thai) — sourcing/licensing, not generation | — | ARTINT-05 | P2 |

Recommended art order: ART-03, ART-02, ART-10, ART-09, ART-04 (P1, parallel with Phases 1–3) → ART-06, ART-07, ART-05, ART-12, FONT-01 → ART-01, ART-08, ART-11, ART-13.
FUTURE (not planned): loadout portraits/skins, extra defenders, Gold/XP/profile/Daily Rewards/Achievements/Lore/Store/Meta art.

## 6. Ordered task list

| # | ID | Phase | Art | Worker |
|---|---|---|---|---|
| 1 | SAFE-01 | 0 | IND | Medium |
| 2 | DOC-01 | 0 | IND | Medium |
| 3 | DOC-02 | 0 | IND | Medium |
| 4 | UI-01 | 1 | IND | Medium |
| 5 | UI-02 | 1 | IND | Medium |
| 6 | UI-03 | 1 | IND | Medium |
| 7 | UI-05 | 1 | OPT | Medium |
| 8 | UI-07 | 1 | IND | Medium |
| 9 | UI-08 | 1 | OPT | Medium |
| 10 | UI-09 | 1 | OPT | Medium (after AQ-1) |
| 11 | UI-04 | 1 | OPT | **High** |
| 12 | UI-06 | 1 | IND | Medium |
| 13 | UI-10 | 2 | OPT | Medium |
| 14 | UI-11 | 2 | OPT | Medium |
| 15 | UI-12 | 2 | OPT | Medium |
| 16 | UI-13 | 2 | IND | Medium |
| 17 | UI-14 | 2 | OPT | Medium |
| 18 | UI-15 | 2 | IND | Medium |
| 19 | UI-16 | 2 | OPT | Medium |
| 20 | UI-17 | 2 | OPT | Medium |
| 21 | UI-18 | 2 | OPT | Medium |
| 22 | UI-19 | 2 | OPT | Medium |
| 23 | UI-20 | 2 | IND | Medium |
| 24 | QA-01 | 2 | IND | Medium |
| 25 | BATTLE-01 | 3 | OPT | Medium |
| 26 | BATTLE-02 | 3 | IND | Medium |
| 27 | BATTLE-03 | 3 | OPT | Medium |
| 28 | BATTLE-04 | 3 | OPT | Medium |
| 29 | BATTLE-05 | 3 | OPT | Medium |
| 30 | BATTLE-06 | 3 | OPT | Medium |
| 31 | BATTLE-07 | 3 | OPT | Medium |
| 32 | BATTLE-08 | 3 | IND | Medium |
| 33 | BATTLE-09 | 3 | IND | Medium |
| 34 | MENU-01 | 4 | OPT | Medium |
| 35 | SEC-01 | 5 | OPT | Medium |
| 36 | SEC-02 | 5 | IND | Medium |
| 37 | SEC-03 | 5 | OPT | Medium |
| 38 | SEC-04 | 5 | IND | Medium |
| 39 | ART-PREP | 6 | IND | Medium (any time after UI-09) |
| 40–49 | ARTINT-01…10 | 6 | BLOCKED | Medium; ARTINT-07 **High** |
| 50 | UI-CLEAN | 6 | IND | Medium |
| 51 | QA-FINAL | 6 | IND | Medium |

## 7. Art-blocked vs independent

- ART-INDEPENDENT (20): SAFE-01, DOC-01, DOC-02, UI-01, UI-02, UI-03, UI-06, UI-07, UI-13, UI-15, UI-20, QA-01, BATTLE-02, BATTLE-08, BATTLE-09, SEC-02, SEC-04, ART-PREP, UI-CLEAN, QA-FINAL (UI-CLEAN/QA-FINAL ordered last).
- ART-OPTIONAL (fallback now, fidelity later) (21): UI-04, UI-05, UI-08, UI-09, UI-10, UI-11, UI-12, UI-14, UI-16, UI-17, UI-18, UI-19, BATTLE-01, BATTLE-03..07, MENU-01, SEC-01, SEC-03.
- ART-BLOCKED (10): ARTINT-01…ARTINT-10.
- Phases 0–5 (38 tasks) complete without any production art. Final fidelity (DESIGN §30 "production-approved art") requires Phase 6.

## 8. Conflict map (uncommitted upgrade-card engine; committed together with SAFE-01)

| WIP file | Later tasks touching it | Handling |
|---|---|---|
| `lib/core/constants/game_constants.dart` | SAFE-01 (add flag), BATTLE-01 (remove flag) | sequential; only flag lines |
| `lib/engine/simulation/systems/upgrade_system.dart` | SAFE-01, BATTLE-01 | guard lines only; engine logic frozen |
| `lib/features/battle/view/battle_screen.dart` | BATTLE-01, BATTLE-04 (placement), BATTLE-07 (aim hint) | strictly sequential; StackFit.expand, errorBuilder/loadingBuilder, `upgrades:` param preserved |
| `lib/features/battle/widgets/ability_shop_panel.dart` | BATTLE-06, ARTINT-04 | keep `upgrades` param + upgrade_text helpers |
| `lib/features/battle/viewmodel/upgrade_text.dart` | BATTLE-01, BATTLE-06 (read only) | do not edit except adding ids with new upgrades |
| `lib/engine/bridge/battle_signals.dart`, `battle_controller.dart`, `battle_world.dart`, `battle_system.dart`, `default_systems.dart`, `systems.dart` | none (read only) | UI tasks must not modify |
| `lib/l10n/arb/*`, `lib/l10n/gen/*`, `tools/l10n_sync.py` | any task adding strings (BATTLE-01, MENU-01, SEC-*) | add to app_en.arb + TR_OVERRIDES, run l10n_sync + gen-l10n in the same task; never parallel |
| `assets/content/levels/sector_01.json`, `level_config.dart`, content test | none (ARTINT-07/08 touch castles.json/environments.json only) | — |
| `docs/ui_briefs/battle-upgrade-cards.md` | DOC-01 marks LEGACY | superseded by BATTLE-01 |
| `test/ui_smoke_test.dart` (not WIP) | QA-01, BATTLE-02, BATTLE-09, QA-FINAL | sequential |
| `lib/features/boot/view/widget_gallery.dart` | every UI-xx task | sequential by construction |

Status: engine (`316e2b7`) and SAFE-01 (`b0de6b1`) are committed; the "WIP files" above are now regular files. The table remains the overlap map: tasks touching the same file run strictly sequentially, each starting from a clean tree.

## 9. Validation strategy

- Every task: `flutter analyze` 0; `python tools/ui_lint.py` TEMIZ; `flutter test test/ui_smoke_test.dart` PASS.
- Content/asset-touching: `flutter test test/content_validation_test.dart`, `python tools/assetkit/assetkit.py verify`.
- l10n-touching: `python tools/l10n_sync.py --check` current.
- Test-writing tasks (QA-01, BATTLE-02, BATTLE-09, QA-FINAL): full `flutter test`.
- Planner re-runs all gates; never trusts worker PASS; checks `git status` scope and `git stash list` empty.
- Visual: widget gallery on device after each Phase 2 task; user device check (640x360-class + wide notched, both rotations, `ar` RTL once per phase) against BASE-00 screenshots and the surface-specific reference.
- Battle: bottom strip ≤20% height, battlefield center unobstructed, release build on device after Phase 3.

## 10. Completion criteria

- All screens in scope (gate, main menu, level select, settings, result, battle HUD, ability shop, upgrade overlay, pause) satisfy DESIGN §30.
- No production code references legacy neon tokens; ui_lint enforces it (UI-CLEAN).
- No `AppColors.aether` used for amber meanings; battle Aether is cyan everywhere.
- All shared components expose material/state variants; no screen-local duplicate of button/panel/card/slot/ring visuals.
- Phase 6 art integrated for every ART task; `assetkit verify` reports no missing ids; placeholders removed.
- KNOWN_GAPS updated (Arabic digits closed when RwNumberFormat adopted; fonts closed after ARTINT-05).

## ARCHITECTURE DECISIONS (approved 2026-09-16)

- **AQ-1 — APPROVED.** Flutter UI raster art = per-file WebP under `assets/images/ui_art/<group>/<id>.webp`, loaded by engine-independent `RwArt` (Image.asset + fallback). Gameplay sprites stay in Flame atlases. `lib/shared`/`lib/features` never import `lib/engine/render` for art.
- **AQ-2 — APPROVED.** Content → UI art mapping by existing ids, no schema change: `portraits/<unitId>`, `illustrations/<upgrade.icon>`, ability art by `abilities.json icon`. A `portrait` field is not added.
- **AQ-3 — APPROVED.** Non-repository-backed areas (Store, Meta Upgrades, Shard/Cell wallet and similar) are hidden; existing public constructors stay compatible (params retained, unused, documented). Removing params requires a separate approval.
- **AQ-4 — APPROVED.** Battlefield background, fortress and rift portals remain in Flame `MapRenderer` (engine render layer); not moved to Flutter UI. Menu scene stays Flutter via RwArt.
