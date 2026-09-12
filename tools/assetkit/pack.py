"""Sprite'lari tek bir atlas dokusuna paketler.

Neden atlas: Flame'in SpriteBatch'i tek bir Image uzerinden
Canvas.drawAtlas cagirir. Tum dusmanlar ayni dokuda olursa yuzlerce
dusman TEK draw call ile cizilir. Ayri dosyalar kullanilirsa her sprite
tipi icin ayri cagri gerekir ve swarm hedefine ulasilamaz.

Algoritma: shelf (raf) paketleme — yukseklige gore azalan sirada dizip
soldan saga yerlestirir, satir dolunca alta gecer. MaxRects kadar sikı
degildir ama kodu kucuk, sonucu ongorulebilir ve bizim boyutlarimizda
fark yaratmaz.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


def pack(
    sprites: dict[str, Image.Image],
    max_size: int = 2048,
    padding: int = 2,
) -> tuple[Image.Image, dict]:
    """(atlas goruntusu, atlas metadata) dondurur."""
    if not sprites:
        raise ValueError("paketlenecek sprite yok")

    items = sorted(
        sprites.items(), key=lambda kv: kv[1].height, reverse=True
    )

    # Atlas genisligini 256'dan baslayip gerektikce iki katina cikararak
    # sigan en kucuk kare dokuyu buluruz. Kucuk doku = daha az VRAM.
    for size in (256, 512, 1024, 2048, 4096):
        if size > max_size:
            break
        placed = _try_place(items, size, padding)
        if placed is not None:
            return _compose(items, placed, size)

    raise ValueError(
        f"sprite'lar {max_size}x{max_size} atlas'a sigmadi; "
        "tarifteki max_size degerini dusur veya grubu ikiye bol"
    )


def _try_place(items, size: int, padding: int):
    positions: dict[str, tuple[int, int]] = {}
    x = y = shelf_height = 0
    for name, img in items:
        w, h = img.width + padding, img.height + padding
        if w > size or h > size:
            return None
        if x + w > size:
            x = 0
            y += shelf_height
            shelf_height = 0
        if y + h > size:
            return None
        positions[name] = (x, y)
        x += w
        shelf_height = max(shelf_height, h)
    return positions


def _compose(items, positions, size: int):
    atlas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    frames: dict[str, dict] = {}
    for name, img in items:
        x, y = positions[name]
        atlas.paste(img, (x, y))
        frames[name] = {
            "x": x,
            "y": y,
            "w": img.width,
            "h": img.height,
        }
    meta = {"size": [size, size], "frames": frames}
    return atlas, meta


def write_atlas(atlas: Image.Image, meta: dict, out_png: Path) -> None:
    out_png.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(out_png, optimize=True)
    meta = {**meta, "image": out_png.name}
    out_json = out_png.with_suffix(".json")
    out_json.write_text(
        json.dumps(meta, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
