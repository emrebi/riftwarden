# Gemini Asset Prompt'ları

Bu dosya, web Gemini'ye yapıştırılacak hazır prompt'ları tutar.
Üretilen görseller `tools/assetkit` ile işlenir — bu yüzden **teknik kurallar
pazarlık konusu değildir**, onlar olmadan kesme/arka plan kaldırma bozulur.

---

## STYLE BIBLE — her prompt'un başına aynen yapıştır

> **Art direction:** Stylized sci-fi dimensional fantasy. Floating shattered
> worlds between dimensions, crystalline energy technology, alien creatures
> made of dark matter and glowing energy. Premium mobile game quality —
> comparable to a top-grossing App Store title, NOT cheap hyper-casual art.
> Semi-realistic stylized 3D-render look with clean readable silhouettes.
> Palette: deep void indigo and purple bases, cyan/teal energy for allied
> technology, violet/magenta energy for hostile Riftborn creatures, amber for
> resources. Lighting is consistent: key light from top-left, subtle rim light
> in the creature's own energy color. Orthographic top-down 3/4 view, as seen
> from a camera looking down at about 60 degrees.
> Every creature must be instantly distinguishable from the others by
> silhouette alone at small size on a phone screen.
> No real-world military themes: no soldiers, tanks, guns, zombies, armies,
> camouflage or modern weapons anywhere.

---

## TECHNICAL RULES — her prompt'un sonuna aynen yapıştır

> **Output format (mandatory):**
> - Single image, one strict grid, equal cell size, objects centered in cells.
> - Background must be **flat pure magenta #FF00FF** across the entire image.
>   Absolutely uniform — no gradient, no vignette, no texture, no noise.
> - **No drop shadow or glow may touch the background.** Any shadow or outer
>   glow must be removed entirely. The creature must end at its own edge.
> - At least **40 pixels of clean magenta space** between every object and
>   between objects and the image border.
> - No text, no labels, no numbers, no captions, no borders, no frames,
>   no watermark, no UI elements, no ground plane, no scene, no background
>   props of any kind.
> - Render at high resolution.

> **Neden:** Arka plan chroma key ile silinecek. Magenta'ya değen gölge/glow
> silinince kirli kenar bırakır; objeler arası boşluk yetersizse otomatik
> dilimleyici iki objeyi tek parça sanır.

---

## Parti 1 — Riftborn düşmanlar (7 adet)

Style bible + aşağıdaki + teknik kurallar.

> Create a **4 columns x 2 rows** sprite sheet (7 creatures, last cell empty
> magenta) of original alien creatures called **Riftborn** — beings that pour
> out of tears in space. Each creature is a distinct species, shown standing
> facing the viewer, full body.
>
> 1. **DRIFTER** — the common one. Medium size, hovering slightly, a floating
>    armored husk with a single glowing violet core in its chest and trailing
>    shadow ribbons instead of legs. Reads as "basic enemy".
> 2. **SKITTER** — very fast, fragile. Small, low, six thin blade-like legs,
>    sharp forward-leaning body, magenta streaks. Reads as "this thing is quick".
> 3. **BULWARK** — huge tank. Wide, heavy, thick crystalline plating covering
>    most of its body, tiny head, slow and immovable. Reads as "wall".
> 4. **SPLITTER** — bulbous segmented body with visible internal smaller
>    creatures glowing under a translucent membrane, looks ready to burst.
> 5. **PHASEBORN** — partially translucent, half its body fading into ghostly
>    violet static, edges dissolving into particles. Reads as "can't be hit".
> 6. **LEECH** — sinister and greedy: long tendril-arms, a wide draining maw,
>    hunched forward posture, amber energy visibly being pulled into it.
> 7. **SPAWNER** — stationary bloated host with open vents on its back from
>    which tiny creatures emerge; rooted, plant-like anchoring limbs.
>
> All seven share the same species language: dark matter bodies, violet/magenta
> energy cores, crystalline growths. They must clearly belong to the same
> universe while being unmistakable from each other in silhouette.

İşleme:
```bash
python tools/assetkit/assetkit.py ingest indirilenler/enemies.zip --recipe enemies
python tools/assetkit/assetkit.py pack --group enemies
```

---

## Parti 2 — Savunma birlikleri (3 adet)

> Create a **3 columns x 1 row** sprite sheet of three allied defensive units.
> These are constructs of allied energy technology — clean, engineered,
> cyan/teal, clearly the opposite faction to the organic violet Riftborn.
>
> 1. **PULSE GUARD** — the cheap basic trooper. Compact humanoid frame of
>    smooth white-cyan plating, a small shoulder-mounted pulse emitter,
>    friendly and readable. Reads as "many of these".
> 2. **ARC RANGER** — long-range specialist. Slender, tall, a long tuning-fork
>    style energy rifle with visible arcing electricity between its prongs,
>    light armor, elegant.
> 3. **TITAN FRAME** — heavy tank unit. Massive broad-shouldered walker,
>    thick layered plating, two wide ground-slam arms, low center of gravity,
>    glowing teal reactor in its chest. Reads as "unstoppable wall".
>
> Same engineered design language across all three: hard surfaces, panel lines,
> teal energy seams, no organic shapes.

```bash
python tools/assetkit/assetkit.py ingest indirilenler/units.zip --recipe units
python tools/assetkit/assetkit.py pack --group units
```

---

## Parti 3 — Efektler ve mermiler

> Create a **5 columns x 3 rows** sprite sheet of game effects, each centered
> in its own cell, viewed straight-on:
>
> Row 1 — projectiles: cyan pulse bolt, white-hot piercing lance, forking
> electric arc segment, amber explosive orb, violet enemy spit.
> Row 2 — impacts: small cyan hit spark, large orange explosion burst,
> electric chain burst, purple void implosion, white critical-hit starburst.
> Row 3 — field effects: circular teal shield dome, amber Aether pickup mote,
> red danger warning ring (flat ring, top-down), frost/slow crystal burst,
> green healing pulse ring.
>
> All effects are pure energy — bright cores fading to transparent-looking
> edges (but edges must still end cleanly, do NOT blend into the background).

```bash
python tools/assetkit/assetkit.py ingest indirilenler/fx.zip --recipe fx
python tools/assetkit/assetkit.py pack --group fx
```

---

## Parti 4 — Arayüz ikonları

> Create a **6 columns x 3 rows** sprite sheet of clean flat game UI icons,
> each centered in its own cell. Single-color-plus-accent style, thick enough
> strokes to stay legible at 48x48 pixels on a phone.
>
> Row 1: Aether resource crystal (amber), Rift Shard (cyan shard), Aether Cell
> (orange power cell), settings gear, pause bars, sound-on speaker.
> Row 2: music note, vibration waves, globe/language, shop bag, play triangle,
> lock (closed padlock).
> Row 3: star (reward), heart/core shield, upgrade arrow-up chevron, refresh
> reroll arrows, video-play (rewarded ad), close X.
>
> Consistent stroke weight and corner radius across all icons. No text.

```bash
python tools/assetkit/assetkit.py ingest indirilenler/ui.zip --recipe ui
python tools/assetkit/assetkit.py pack --group ui
```

---

## Gemini'den zip alma

Görseller üretildikten sonra:

> Put all generated images into a single .zip file and give me the download link.

Zip'i indir, `assetkit ingest` komutuna yolunu ver. Zip içindeki klasör yapısı
önemli değil, tüm görüntüler özyinelemeli bulunur.

---

## Sorun giderme

| Belirti | Sebep | Çözüm |
|---|---|---|
| Beklenenden az parça çıktı | Objeler birbirine değiyor | Tarifte `min_gap` düşür, ya da `"slice":"grid"` + `cols`/`rows` ver |
| Beklenenden çok parça çıktı | Bir objenin parçaları ayrı algılandı | `min_gap` artır |
| Kenarlarda mor hale | Gölge arka plana değmiş | Gemini'ye gölgesiz yeniden ürettir; ya da `tolerance` artır |
| Sprite'ın kendi moru silindi | Sprite rengi #FF00FF'e çok yakın | `tolerance` düşür (ör. 40) |
| Arka plan tam silinmedi | Gradyanlı/gürültülü zemin | `tolerance` artır (ör. 100); kalıcıysa düz zeminle yeniden ürettir |
