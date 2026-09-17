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


def label_components(mask: np.ndarray) -> np.ndarray:
    """8-komsu bagli bilesen etiketleri (0 = bos).

    scipy/cv2 bagimliligi eklememek icin satir-run tabanli union-find.
    2000 px'lik bir sheet'te ~0.3 s surer.
    """
    h, w = mask.shape
    parent = [0]

    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    labels = np.zeros((h, w), dtype=np.int32)
    prev: list[tuple[int, int, int]] = []
    for y in range(h):
        row = mask[y]
        d = np.diff(np.concatenate(([0], row.view(np.int8), [0])))
        starts = np.flatnonzero(d == 1)
        ends = np.flatnonzero(d == -1)
        cur: list[tuple[int, int, int]] = []
        j = 0
        for s, e in zip(starts.tolist(), ends.tolist()):
            lab = 0
            while j < len(prev) and prev[j][1] < s:
                j += 1
            k = j
            while k < len(prev) and prev[k][0] <= e:
                pl = prev[k][2]
                if lab == 0:
                    lab = find(pl)
                else:
                    ra, rb = find(lab), find(pl)
                    if ra != rb:
                        parent[max(ra, rb)] = min(ra, rb)
                        lab = min(ra, rb)
                k += 1
            if lab == 0:
                lab = len(parent)
                parent.append(lab)
            labels[y, s:e] = lab
            cur.append((s, e, lab))
        prev = cur
    lut = np.array([find(i) for i in range(len(parent))], dtype=np.int32)
    return lut[labels]


def cells_slice(
    img: Image.Image,
    cols: int,
    rows: int,
    min_component: int = 24,
    alpha_threshold: int = 16,
) -> list[Image.Image | None]:
    """Bilesen merkezine gore hucre dilimleme.

    Objelerin merkezine gore hucre atamasi yapar; hucre kenarini asan
    parcalar kendi konusuyla kalir, komsu hucrelerin tasan kisimlari maskelenir.
    Bilesen dusmeyen hucreler None doner.
    """
    img_rgba = img.convert("RGBA")
    alpha = np.asarray(img_rgba.getchannel("A"))
    mask = alpha > alpha_threshold
    lab = label_components(mask)

    labels, counts = np.unique(lab, return_counts=True)
    w, h = img.size

    # Hucreye atanan bilesenler ve etiket bbox'lari
    cell_components: dict[tuple[int, int], list[int]] = {}
    comp_bboxes: dict[int, tuple[int, int, int, int]] = {}

    for label, count in zip(labels.tolist(), counts.tolist()):
        if label == 0 or count < min_component:
            continue
        ys, xs = np.nonzero(lab == label)
        min_x, max_x = int(xs.min()), int(xs.max())
        min_y, max_y = int(ys.min()), int(ys.max())
        comp_bboxes[label] = (min_x, min_y, max_x, max_y)

        cx = (min_x + max_x) / 2.0
        cy = (min_y + max_y) / 2.0

        col = min(max(0, int(cx // (w / cols))), cols - 1)
        row = min(max(0, int(cy // (h / rows))), rows - 1)
        cell_components.setdefault((row, col), []).append(label)

    results: list[Image.Image | None] = []
    for r in range(rows):
        for c in range(cols):
            assigned = cell_components.get((r, c))
            if not assigned:
                results.append(None)
                continue

            # Hucreye atanan bilesenlerin birlesik bbox'i
            u_min_x = min(comp_bboxes[lbl][0] for lbl in assigned)
            u_min_y = min(comp_bboxes[lbl][1] for lbl in assigned)
            u_max_x = max(comp_bboxes[lbl][2] for lbl in assigned)
            u_max_y = max(comp_bboxes[lbl][3] for lbl in assigned)

            cropped = img_rgba.crop((u_min_x, u_min_y, u_max_x + 1, u_max_y + 1))
            cropped_lab = lab[u_min_y : u_max_y + 1, u_min_x : u_max_x + 1]

            assigned_set = set(assigned)
            foreign_mask = (cropped_lab != 0) & (~np.isin(cropped_lab, list(assigned_set)))
            if foreign_mask.any():
                arr = np.array(cropped, copy=True)
                arr[foreign_mask, 3] = 0
                results.append(Image.fromarray(arr))
            else:
                results.append(cropped)

    return results

