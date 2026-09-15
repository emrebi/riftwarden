#!/usr/bin/env python3
"""RIFTWARDEN asset pipeline.

Gemini'nin urettigi contact sheet'leri (cogu zaman magenta arka planli,
N x M izgara halinde) oyunun kullandigi seffaf sprite'lara ve atlas
dokularina cevirir.

    python tools/assetkit/assetkit.py ingest indirilenler/enemies.zip --recipe enemies
    python tools/assetkit/assetkit.py pack   --group enemies
    python tools/assetkit/assetkit.py verify

Tarifler tools/assetkit/recipes/<ad>.json icindedir.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))

import chroma  # noqa: E402
import pack as packer  # noqa: E402
import slice as slicer  # noqa: E402
import trim  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
RECIPES = Path(__file__).parent / "recipes"
STAGING = ROOT / "assets" / "images" / "sprites"
ATLAS_DIR = ROOT / "assets" / "images" / "atlas"
CONTENT_DIR = ROOT / "assets" / "content"

DEFAULTS = {
    "chroma": True,
    "key": [255, 0, 255],
    "tolerance": 70,
    "soft_edge": 40,
    "slice": "auto",
    "cols": 0,
    "rows": 0,
    "min_gap": 12,
    "min_area": 256,
    "padding": 2,
    "max_size": 256,
    "atlas_max": 2048,
    "names": [],
    # Sprite/atlas: lossless. Lossy WebP alfa kenarlarinda hale birakir ve
    # atlas icinde komsu sprite'a renk sizdirir; oyunda gorunur bozulma
    # olur. Lossless yine PNG'den kucuktur. Arka plan gibi alfasiz buyuk
    # resimlerde "webp_lossy" ile asil boyut kazanci saglanir.
    "format": "webp_lossless",
    "quality": 85,
}


def save_image(img: Image.Image, path: Path, recipe: dict) -> None:
    """Recipe'nin 'format' alanina gore WebP olarak yazar."""
    path.parent.mkdir(parents=True, exist_ok=True)
    fmt = recipe["format"]
    if fmt == "webp_lossy":
        img.save(path, "WEBP", lossless=False, quality=recipe["quality"], method=6)
    elif fmt == "webp_lossless":
        img.save(path, "WEBP", lossless=True, method=6)
    else:
        raise SystemExit(f"bilinmeyen format: {fmt} (webp_lossless veya webp_lossy olmali)")


def load_recipe(name: str) -> dict:
    path = RECIPES / f"{name}.json"
    if not path.exists():
        found = sorted(p.stem for p in RECIPES.glob("*.json"))
        available = ", ".join(found) if found else "(yok)"
        raise SystemExit(
            f"tarif bulunamadi: {path}\nmevcut tarifler: {available}"
        )
    return {**DEFAULTS, **json.loads(path.read_text(encoding="utf-8"))}


def collect_images(source: Path, workdir: Path) -> list[Path]:
    """zip / klasor / tek dosya girdisini goruntu listesine cevirir."""
    if source.is_file() and source.suffix.lower() == ".zip":
        with zipfile.ZipFile(source) as zf:
            zf.extractall(workdir)
        base = workdir
    elif source.is_dir():
        base = source
    elif source.is_file():
        return [source]
    else:
        raise SystemExit(f"girdi bulunamadi: {source}")

    exts = {".png", ".jpg", ".jpeg", ".webp"}
    # __MACOSX gibi arsiv artiklarini ele.
    return sorted(
        p
        for p in base.rglob("*")
        if p.suffix.lower() in exts and "__MACOSX" not in p.parts
    )


def cmd_ingest(args: argparse.Namespace) -> int:
    recipe = load_recipe(args.recipe)
    out_dir = STAGING / args.recipe
    if out_dir.exists() and not args.keep:
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    names: list[str] = list(recipe["names"])
    produced = 0

    with tempfile.TemporaryDirectory() as tmp:
        sources = collect_images(Path(args.source), Path(tmp))
        if not sources:
            raise SystemExit("girdide islenecek goruntu yok")

        for src in sources:
            img = Image.open(src).convert("RGBA")

            # Zaten seffafsa chroma adimini atla: gercekten mor olan
            # sprite piksellerini bosuna silmeyelim.
            if recipe["chroma"] and not chroma.has_alpha(img):
                img = chroma.key_out(
                    img,
                    key=tuple(recipe["key"]),
                    tolerance=recipe["tolerance"],
                    soft_edge=recipe["soft_edge"],
                )

            if recipe["slice"] == "none":
                # Tek parca: arka plan gibi butun goruntunun kendisi obje
                # olan durumlarda dilimleme/chroma anlamsizdir.
                boxes = [(0, 0, img.width, img.height)]
            elif recipe["slice"] == "grid" and recipe["cols"] and recipe["rows"]:
                boxes = slicer.grid_slice(img, recipe["cols"], recipe["rows"])
            else:
                boxes = slicer.auto_slice(
                    img,
                    min_gap=recipe["min_gap"],
                    min_area=recipe["min_area"],
                )

            print(f"  {src.name}: {len(boxes)} parca")

            for box in boxes:
                piece = trim.trim_alpha(img.crop(box), padding=0)
                if piece.width < 4 or piece.height < 4:
                    continue
                piece = trim.fit_within(piece, recipe["max_size"])
                piece = trim.trim_alpha(piece, padding=recipe["padding"])

                if produced < len(names):
                    name = names[produced]
                else:
                    name = f"{args.recipe}_{produced:03d}"
                save_image(piece, out_dir / f"{name}.webp", recipe)
                produced += 1

    print(f"\n{produced} sprite -> {out_dir.relative_to(ROOT)}")
    if not names:
        print(
            "NOT: tarifte 'names' bos. Dosyalar sirayla numaralandirildi;\n"
            "     elle yeniden adlandir ya da tarife isim listesi ekle."
        )
    return 0


def cmd_pack(args: argparse.Namespace) -> int:
    recipe = load_recipe(args.group)
    src_dir = STAGING / args.group
    if not src_dir.exists():
        raise SystemExit(f"once ingest calistir: {src_dir} yok")

    # .webp asil format; .png sadece gecis donemi icin (henuz donusturulmemis
    # eski sprite klasorleri varsa) okunur.
    sprites: dict[str, Image.Image] = {}
    for p in sorted(src_dir.glob("*.webp")):
        sprites[p.stem] = Image.open(p).convert("RGBA")
    for p in sorted(src_dir.glob("*.png")):
        sprites.setdefault(p.stem, Image.open(p).convert("RGBA"))
    if not sprites:
        raise SystemExit(f"{src_dir} icinde webp/png yok")

    atlas, meta = packer.pack(
        sprites,
        max_size=recipe["atlas_max"],
        padding=recipe["padding"],
    )
    out = ATLAS_DIR / f"{args.group}.webp"
    packer.write_atlas(atlas, meta, out, recipe)
    width, height = meta["size"]
    print(
        f"{len(sprites)} sprite -> {out.relative_to(ROOT)} ({width}x{height})"
    )
    return 0


def cmd_verify(args: argparse.Namespace) -> int:
    """Icerik JSON'larinin atifta bulundugu her sprite atlas'ta var mi.

    Eksik sprite calisma aninda sessiz bir bos kare olarak cikar ve fark
    etmesi zordur; burada erken yakalamak icin.
    """
    known: set[str] = set()
    for meta_path in sorted(ATLAS_DIR.glob("*.json")):
        meta = json.loads(meta_path.read_text(encoding="utf-8"))
        known.update(meta.get("frames", {}))

    referenced: dict[str, list[str]] = {}
    for json_path in sorted(CONTENT_DIR.rglob("*.json")):
        data = json.loads(json_path.read_text(encoding="utf-8"))
        for sprite in find_sprite_keys(data):
            referenced.setdefault(sprite, []).append(
                str(json_path.relative_to(ROOT))
            )

    missing = {k: v for k, v in referenced.items() if k not in known}

    print(f"atlas'ta {len(known)} sprite, icerikte {len(referenced)} atif")
    if missing:
        print(f"\nEKSIK ({len(missing)}):")
        for sprite, files in sorted(missing.items()):
            where = ", ".join(sorted(set(files)))
            print(f"  {sprite}  <- {where}")
        return 1

    unused = known - set(referenced)
    if unused:
        print(f"\nkullanilmayan {len(unused)} sprite: {', '.join(sorted(unused))}")
    print("\nTUM ATIFLAR KARSILANIYOR")
    return 0


def find_sprite_keys(node: object) -> list[str]:
    """Icerik agacindaki sprite / skin / icon alanlarini toplar."""
    found: list[str] = []
    if isinstance(node, dict):
        for key, value in node.items():
            if key in ("sprite", "skin", "icon") and isinstance(value, str):
                found.append(value)
            else:
                found.extend(find_sprite_keys(value))
    elif isinstance(node, list):
        for item in node:
            found.extend(find_sprite_keys(item))
    return found


def main() -> int:
    parser = argparse.ArgumentParser(prog="assetkit", description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    p_ingest = sub.add_parser("ingest", help="zip/klasor -> seffaf sprite'lar")
    p_ingest.add_argument("source", help="zip dosyasi, klasor veya tek goruntu")
    p_ingest.add_argument("--recipe", required=True, help="tarif adi")
    p_ingest.add_argument(
        "--keep",
        action="store_true",
        help="mevcut ciktilari silme, uzerine ekle",
    )
    p_ingest.set_defaults(func=cmd_ingest)

    p_pack = sub.add_parser("pack", help="sprite'lari atlas'a paketle")
    p_pack.add_argument("--group", required=True, help="tarif/grup adi")
    p_pack.set_defaults(func=cmd_pack)

    p_verify = sub.add_parser("verify", help="icerik <-> atlas tutarliligi")
    p_verify.set_defaults(func=cmd_verify)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
