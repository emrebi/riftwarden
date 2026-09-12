"""Contact sheet'i tek tek sprite'lara boler.

Iki yontem var:

auto  : izdusum profili (projection profile) segmentasyonu. Once tamamen
        bos satir bantlari bulunur, sonra her bandin icinde tamamen bos
        sutunlar. Gemini'den "her obje arasinda en az 40 px bosluk, sikı
        N x M grid" istedigimiz icin bu yontem pratikte %100 isabetli
        calisir ve grid olcusunu bilmemize gerek birakmaz.

grid  : sabit N x M dilimleme. Auto'nun yanildigı (objelerin birbirine
        degdigi) nadir durumlar icin kacis kapisi.
"""

from __future__ import annotations

import numpy as np
from PIL import Image

Box = tuple[int, int, int, int]  # left, top, right, bottom


def _runs(occupied: np.ndarray, min_gap: int) -> list[tuple[int, int]]:
    """Dolu bolgelerin (baslangic, bitis) araliklarini dondurur.

    min_gap'ten kisa bosluklar ayirici sayilmaz; boylece bir sprite'in
    kendi icindeki kucuk boslugu (ornegin bacak arasi) yanlislikla iki
    ayri obje gibi gorunmez.
    """
    result: list[tuple[int, int]] = []
    start: int | None = None
    gap = 0
    for i, is_full in enumerate(occupied):
        if is_full:
            if start is None:
                start = i
            gap = 0
        elif start is not None:
            gap += 1
            if gap >= min_gap:
                result.append((start, i - gap + 1))
                start = None
                gap = 0
    if start is not None:
        result.append((start, len(occupied)))
    return result


def auto_slice(
    img: Image.Image,
    min_gap: int = 12,
    min_area: int = 256,
    alpha_threshold: int = 16,
) -> list[Box]:
    """Seffaf bosluklara gore sprite kutularini bulur."""
    alpha = np.asarray(img.convert("RGBA").getchannel("A"))
    mask = alpha > alpha_threshold

    boxes: list[Box] = []
    for top, bottom in _runs(mask.any(axis=1), min_gap):
        band = mask[top:bottom]
        for left, right in _runs(band.any(axis=0), min_gap):
            cell = band[:, left:right]
            if not cell.any():
                continue
            # Bandin icinde dikeyde de kirp: ayni satirdaki objeler farkli
            # yuksekliklerde olabilir.
            rows = np.where(cell.any(axis=1))[0]
            t = top + int(rows[0])
            b = top + int(rows[-1]) + 1
            if (right - left) * (b - t) < min_area:
                continue
            boxes.append((left, t, right, b))
    return boxes


def grid_slice(img: Image.Image, cols: int, rows: int) -> list[Box]:
    """Sabit izgara dilimleme. Sol ustten saga, sonra asagi."""
    w, h = img.size
    cw, ch = w // cols, h // rows
    return [
        (c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)
        for r in range(rows)
        for c in range(cols)
    ]
