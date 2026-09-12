"""Kirpma ve olceklendirme."""

from __future__ import annotations

from PIL import Image


def trim_alpha(img: Image.Image, padding: int = 0, threshold: int = 8) -> Image.Image:
    """Seffaf kenar boslugunu atar, istege bagli sabit padding birakir.

    Padding neden gerekli: atlas'ta komsu sprite'larin pikselleri bilinear
    filtreleme sirasinda birbirine sizabilir ("texture bleeding"). Sprite
    basina 1-2 px seffaf pay bunu tamamen onler.
    """
    rgba = img.convert("RGBA")
    alpha = rgba.getchannel("A")
    bbox = alpha.point(lambda v: 255 if v > threshold else 0).getbbox()
    if bbox is None:
        return Image.new("RGBA", (1, 1), (0, 0, 0, 0))

    cropped = rgba.crop(bbox)
    if padding <= 0:
        return cropped

    out = Image.new(
        "RGBA",
        (cropped.width + padding * 2, cropped.height + padding * 2),
        (0, 0, 0, 0),
    )
    out.paste(cropped, (padding, padding))
    return out


def fit_within(img: Image.Image, max_size: int) -> Image.Image:
    """En-boy oranini koruyarak en uzun kenari max_size'a indirir.

    Sadece kucultur, buyutmez: Gemini'den gelen gorsel zaten kucukse
    upscale etmek bulanik sonuc verir, oldugu gibi birakmak daha iyidir.
    """
    longest = max(img.width, img.height)
    if longest <= max_size:
        return img
    scale = max_size / longest
    return img.resize(
        (max(1, round(img.width * scale)), max(1, round(img.height * scale))),
        Image.LANCZOS,
    )
