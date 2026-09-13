#!/usr/bin/env python3
"""Gecici (placeholder) sprite uretici.

Gercek sanat gelene kadar oyunun calisabilmesi icin basit ama **birbirinden
ayirt edilebilir** sekiller uretir. Amac guzel gorunmek degil; render
hattinin (SpriteBatch + atlas) gercek veriyle calistigini dogrulamak ve
oynanisi test edilebilir kilmak.

Neden Canvas ile daire cizmek yerine atlas: asil performans mimarisi tek
`drawAtlas` cagrisiyla yuzlerce sprite cizmek. Gecici olarak primitive
cizersek o yolu hic test etmemis oluruz ve gercek asset gelince render
katmanini bastan yazmak gerekir.

    python tools/assetkit/make_placeholders.py

Cikti: assets/images/sprites/<grup>/*.png  (sonra `assetkit pack` ile atlas)

Gercek sprite'lar geldiginde bu script'e ARTIK IHTIYAC KALMAZ; silinebilir.
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "images" / "sprites"

SIZE = 128          # kaynak cozunurluk; atlas paketlerken kuculecek
PAD = 8

# Sanat yonu (docs/ASSET_PROMPTS.md): dusmanlar menekse/macenta,
# muttefikler cyan/teal, kaynaklar kehribar.
ENEMY_VIOLET = (155, 92, 255)
ENEMY_MAGENTA = (232, 74, 196)
ALLY_CYAN = (63, 224, 255)
ALLY_TEAL = (43, 245, 200)
AMBER = (255, 196, 77)
DANGER = (255, 77, 94)


def _canvas() -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


def _polygon(cx: float, cy: float, r: float, sides: int, rot: float = 0.0):
    return [
        (
            cx + r * math.cos(rot + i * 2 * math.pi / sides),
            cy + r * math.sin(rot + i * 2 * math.pi / sides),
        )
        for i in range(sides)
    ]


def shape(
    kind: str,
    fill: tuple[int, int, int],
    *,
    scale: float = 1.0,
    core: bool = True,
) -> Image.Image:
    """Ayirt edilebilir bir silüet cizer.

    Silüetin ayirt edilebilir olmasi onemli: kucuk telefon ekraninda oyuncu
    dusman tipini renkten degil **bicimden** taniyabilmeli.
    """
    img, d = _canvas()
    c = SIZE / 2
    r = (SIZE / 2 - PAD) * scale
    outline = tuple(min(255, int(v * 1.4)) for v in fill)

    if kind == "circle":
        d.ellipse([c - r, c - r, c + r, c + r], fill=fill, outline=outline, width=3)
    elif kind == "triangle":
        d.polygon(_polygon(c, c, r, 3, -math.pi / 2), fill=fill, outline=outline)
    elif kind == "square":
        d.rectangle([c - r * 0.8, c - r * 0.8, c + r * 0.8, c + r * 0.8],
                    fill=fill, outline=outline, width=3)
    elif kind == "hexagon":
        d.polygon(_polygon(c, c, r, 6), fill=fill, outline=outline)
    elif kind == "diamond":
        d.polygon(_polygon(c, c, r, 4, -math.pi / 2), fill=fill, outline=outline)
    elif kind == "star":
        pts = []
        for i in range(10):
            rr = r if i % 2 == 0 else r * 0.45
            a = -math.pi / 2 + i * math.pi / 5
            pts.append((c + rr * math.cos(a), c + rr * math.sin(a)))
        d.polygon(pts, fill=fill, outline=outline)
    elif kind == "pentagon":
        d.polygon(_polygon(c, c, r, 5, -math.pi / 2), fill=fill, outline=outline)
    elif kind == "ring":
        d.ellipse([c - r, c - r, c + r, c + r], outline=fill, width=int(r * 0.35))
    elif kind == "bolt":
        d.polygon(
            [(c, c - r), (c + r * 0.4, c - r * 0.1), (c + r * 0.1, c - r * 0.1),
             (c, c + r), (c - r * 0.4, c + r * 0.1), (c - r * 0.1, c + r * 0.1)],
            fill=fill, outline=outline,
        )
    else:
        raise ValueError(f"bilinmeyen sekil: {kind}")

    # Merkez cekirdek: enerji hissi ve yon okunabilirligi icin.
    if core:
        cr = r * 0.22
        d.ellipse([c - cr, c - cr, c + cr, c + cr], fill=(255, 255, 255, 220))
    return img


# id -> (sekil, renk, olcek). id'ler assets/content/*.json ile birebir ayni.
GROUPS: dict[str, dict[str, tuple[str, tuple[int, int, int], float]]] = {
    "enemies": {
        "drifter":   ("circle",   ENEMY_VIOLET,  0.78),
        "skitter":   ("triangle", ENEMY_MAGENTA, 0.58),
        "bulwark":   ("hexagon",  ENEMY_VIOLET,  1.00),
        "splitter":  ("pentagon", ENEMY_MAGENTA, 0.85),
        "phaseborn": ("diamond",  ENEMY_VIOLET,  0.80),
        "leech":     ("star",     DANGER,        0.80),
        "spawner":   ("square",   ENEMY_MAGENTA, 0.92),
    },
    "units": {
        "pulse_guard": ("circle",   ALLY_CYAN, 0.70),
        "arc_ranger":  ("triangle", ALLY_CYAN, 0.72),
        "titan_frame": ("hexagon",  ALLY_TEAL, 0.95),
    },
    "fx": {
        "pulse_bolt":  ("bolt",   ALLY_CYAN, 0.45),
        "arc_lance":   ("bolt",   ALLY_TEAL, 0.55),
        "enemy_spit":  ("circle", ENEMY_MAGENTA, 0.35),
        "hit_spark":   ("star",   AMBER,     0.40),
        "aether_mote": ("circle", AMBER,     0.35),
    },
    "world": {
        "aether_core": ("ring",    ALLY_TEAL,     1.00),
        "rift_violet": ("ring",    ENEMY_VIOLET,  1.00),
        "rift_magenta": ("ring",   ENEMY_MAGENTA, 1.00),
    },
    # Upgrade kartlari ve yetenek butonu icin arayuz ikonlari.
    # Her aile farkli sekil: oyuncu karti okumadan once aileyi tanisin.
    "ui": {
        "upgrade_chain":     ("bolt",     ALLY_CYAN,     0.80),
        "upgrade_pierce":    ("triangle", ALLY_CYAN,     0.80),
        "upgrade_crit":      ("star",     AMBER,         0.80),
        "upgrade_explosion": ("circle",   DANGER,        0.80),
        "upgrade_swarm":     ("hexagon",  ALLY_TEAL,     0.80),
        "upgrade_economy":   ("diamond",  AMBER,         0.80),
        "upgrade_core":      ("pentagon", ALLY_TEAL,     0.80),
        "ability_collapse":  ("ring",     ENEMY_VIOLET,  0.90),
    },
}


def main() -> int:
    total = 0
    for group, items in GROUPS.items():
        d = OUT / group
        d.mkdir(parents=True, exist_ok=True)
        for name, (kind, color, sc) in items.items():
            shape(kind, color, scale=sc, core=(group != "world")).save(d / f"{name}.png")
            total += 1
        print(f"{group:8} {len(items):2} sprite -> {d.relative_to(ROOT)}")
    print(f"\ntoplam {total} gecici sprite")
    print("siradaki: python tools/assetkit/assetkit.py pack --group <grup>")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
