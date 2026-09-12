"""Chroma key: duz renk arka plani alfaya cevirir.

Neden magenta (#FF00FF): oyun sanatinda pratikte hic kullanilmayan bir renk
oldugu icin yanlislikla sprite'in bir parcasi silinmez. Gemini'ye asset
uretirken "duz saf magenta arka plan" dedirtmemizin sebebi budur; boylece
agir bir arka plan kaldirma modeline (rembg vb.) hic ihtiyac kalmaz.
"""

from __future__ import annotations

import numpy as np
from PIL import Image

MAGENTA = (255, 0, 255)


def has_alpha(img: Image.Image, threshold: int = 250) -> bool:
    """Goruntu zaten anlamli bir alfa kanali tasiyor mu.

    Gemini bazen dogrudan seffaf PNG dondurur. O durumda chroma adimini
    atlayip dogrudan kirpmaya gecmek gerekir, yoksa gercek magenta
    piksellerini (varsa) bosuna sileriz.
    """
    if img.mode != "RGBA":
        return False
    alpha = np.asarray(img.getchannel("A"))
    return bool((alpha < threshold).mean() > 0.02)


def key_out(
    img: Image.Image,
    key: tuple[int, int, int] = MAGENTA,
    tolerance: int = 70,
    soft_edge: int = 40,
    despill: bool = True,
) -> Image.Image:
    """Arka plan rengini seffaflastirir.

    tolerance : bu mesafenin altindaki pikseller tamamen seffaf olur.
    soft_edge : tolerance ile tolerance+soft_edge arasi kismi seffaf olur;
                bu, JPEG sikistirmasindan gelen kenar bulanikligini ve
                anti-aliasing'i temiz keser (aksi halde disari "merdiven"
                ya da mor hale cikar).
    despill   : kalan yari-seffaf kenar piksellerindeki mor tasmayi bastirir.
    """
    rgba = img.convert("RGBA")
    arr = np.asarray(rgba).astype(np.int16)

    # Mesafe hesabi float32'de yapilir. int16'da (255-0)^2 = 65025 tasar,
    # negatife doner ve sqrt NaN uretir; bu da tum maskeyi bozar.
    rgb = arr[..., :3].astype(np.float32)
    key_arr = np.array(key, dtype=np.float32)
    dist = np.sqrt(((rgb - key_arr) ** 2).sum(axis=-1))

    alpha = np.clip((dist - tolerance) / max(soft_edge, 1), 0.0, 1.0)
    out_alpha = np.clip(alpha * arr[..., 3].astype(np.float32), 0, 255).astype(
        np.uint8
    )

    out = arr.copy()
    out[..., 3] = out_alpha

    if despill:
        # Kenarda kalan mor tasma: R ve B kanali G'den cok yuksekse, ikisini
        # de G seviyesine cek. Sadece kismi seffaf piksellerde uygulanir ki
        # gercekten mor olan sprite parcalari bozulmasin.
        edge = (out_alpha > 0) & (out_alpha < 255)
        if edge.any():
            r = out[..., 0]
            g = out[..., 1]
            b = out[..., 2]
            spill = edge & (r > g) & (b > g)
            avg = ((r + b) // 2).astype(np.int16)
            limit = np.minimum(avg, g + 12)
            out[..., 0] = np.where(spill, np.minimum(r, limit), r)
            out[..., 2] = np.where(spill, np.minimum(b, limit), b)

    return Image.fromarray(out.astype(np.uint8), mode="RGBA")
