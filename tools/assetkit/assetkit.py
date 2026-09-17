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
import fnmatch
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
UI_ART_DIR = ROOT / "assets" / "images" / "ui_art"
CONTENT_DIR = ROOT / "assets" / "content"

VALID_UI_GROUPS = {
    "portraits",
    "illustrations",
    "icons",
    "ornaments",
    "logo",
    "scenes",
}

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
    # Hedef cikti tipi: "atlas" (assets/images/sprites/<tarif>/) veya "ui_art".
    "target": "atlas",
    # ui_art hedefinde varsayilan grup (portraits, illustrations, icons, ornaments, logo, scenes).
    "ui_group": "",
    # Bos degilse sadece dosya adi bu fnmatch desenlerinden birine uyanlar islenir.
    "include": [],
    # Isimlendirme yontemi: "list" (names sirayla) veya "file_stem" (dosya adindan).
    "naming": "list",
    # file_stem isimlendirmede dosya kokunden atilacak sonek.
    "strip_suffix": "",
    # cells dilimlemede bilesen basina en az piksel esigi (alti gurultu).
    "min_component": 24,
    # ui_art'ta gruba ozel en uzun kenar (ornek {"icons": 128}), yoksa max_size.
    "max_size_by_group": {},
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


def resolve_item(
    src: Path,
    recipe_name: str,
    recipe: dict,
    produced_idx: int,
    out_override: Path | None,
) -> tuple[str, Path, int, bool]:
    """Isim, hedef dosya yolu, hedef en uzun kenar ve skip durumunu belirler.

    Dondurur: (item_id, dest_path, target_max_size, is_skip)
    """
    naming = recipe["naming"]
    if naming == "file_stem":
        name = src.stem
        strip_suffix = recipe["strip_suffix"]
        if strip_suffix and name.endswith(strip_suffix):
            name = name[:-len(strip_suffix)]
    elif naming == "list":
        names = recipe["names"]
        if produced_idx < len(names):
            name = names[produced_idx]
        else:
            name = f"{recipe_name}_{produced_idx:03d}"
    else:
        name = f"{recipe_name}_{produced_idx:03d}"

    if name == "_skip":
        return (name, Path(), 0, True)

    target = recipe["target"]
    if target == "ui_art":
        if "/" in name:
            grup, item_id = name.split("/", 1)
            if grup not in VALID_UI_GROUPS:
                raise SystemExit(
                    f"gecersiz ui grubu: '{grup}'. Gecerli gruplar: {', '.join(sorted(VALID_UI_GROUPS))}"
                )
        else:
            grup = recipe["ui_group"]
            item_id = name
            if not grup:
                raise SystemExit(f"ui_group bos ve ad grupsuz: '{name}'")
            if grup not in VALID_UI_GROUPS:
                raise SystemExit(
                    f"gecersiz ui_group: '{grup}'. Gecerli gruplar: {', '.join(sorted(VALID_UI_GROUPS))}"
                )

        target_max_size = recipe["max_size_by_group"].get(grup, recipe["max_size"])
        base = out_override if out_override else UI_ART_DIR
        dest_path = base / grup / f"{item_id}.webp"
        return (item_id, dest_path, target_max_size, False)

    elif target == "atlas":
        item_id = name
        target_max_size = recipe["max_size"]
        base = (out_override / recipe_name) if out_override else (STAGING / recipe_name)
        dest_path = base / f"{item_id}.webp"
        return (item_id, dest_path, target_max_size, False)

    else:
        raise SystemExit(f"bilinmeyen target: {target}")


def cmd_ingest(args: argparse.Namespace) -> int:
    recipe = load_recipe(args.recipe)
    target = recipe["target"]

    if target == "atlas":
        out_dir = (args.out / args.recipe) if args.out else (STAGING / args.recipe)
        if out_dir.exists() and not args.keep:
            shutil.rmtree(out_dir)
        out_dir.mkdir(parents=True, exist_ok=True)

    names: list[str] = list(recipe["names"])
    produced = 0
    written: list[tuple[Path, int, int]] = []

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        sources: list[Path] = []
        for idx, src_str in enumerate(args.source):
            src_path = Path(src_str)
            sub_workdir = tmp_path / f"src_{idx}"
            sub_workdir.mkdir(parents=True, exist_ok=True)
            sources.extend(collect_images(src_path, sub_workdir))

        if recipe["include"]:
            sources = [
                p
                for p in sources
                if any(fnmatch.fnmatch(p.name, pat) for pat in recipe["include"])
            ]

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

            if recipe["slice"] == "cells":
                if not recipe["cols"] or not recipe["rows"]:
                    raise SystemExit("cells slice icin cols ve rows zorunludur")
                cells = slicer.cells_slice(
                    img,
                    recipe["cols"],
                    recipe["rows"],
                    min_component=recipe["min_component"],
                )
                filled_count = sum(1 for c in cells if c is not None)
                print(
                    f"  {src.name}: {filled_count} dolu hucre / {recipe['cols'] * recipe['rows']}"
                )

                for cell in cells:
                    if cell is None:
                        continue

                    item_id, dest_path, target_max_size, is_skip = resolve_item(
                        src, args.recipe, recipe, produced, args.out
                    )
                    produced += 1
                    if is_skip:
                        continue

                    piece = trim.trim_alpha(cell, padding=0)
                    piece = trim.fit_within(piece, target_max_size)
                    piece = trim.trim_alpha(piece, padding=recipe["padding"])

                    save_image(piece, dest_path, recipe)
                    written.append((dest_path, piece.width, piece.height))

            else:
                if recipe["slice"] == "none":
                    # Tek parca: arka plan veya seffaf tekil portre/sahne
                    boxes = [(0, 0, img.width, img.height)]
                elif recipe["slice"] == "grid":
                    if not recipe["cols"] or not recipe["rows"]:
                        raise SystemExit("grid slice icin cols ve rows zorunludur")
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

                    item_id, dest_path, target_max_size, is_skip = resolve_item(
                        src, args.recipe, recipe, produced, args.out
                    )
                    produced += 1
                    if is_skip:
                        continue

                    piece = trim.fit_within(piece, target_max_size)
                    piece = trim.trim_alpha(piece, padding=recipe["padding"])

                    save_image(piece, dest_path, recipe)
                    written.append((dest_path, piece.width, piece.height))

    display_base = args.out if args.out else ROOT
    print()
    for p, w, h in written:
        try:
            rel = p.relative_to(display_base).as_posix()
        except ValueError:
            rel = p.as_posix()
        print(f"  {rel} ({w}x{h})")

    if target == "atlas":
        out_dir = (args.out / args.recipe) if args.out else (STAGING / args.recipe)
        try:
            rel_out = out_dir.relative_to(display_base).as_posix()
        except ValueError:
            rel_out = out_dir.as_posix()
        print(f"\n{len(written)} sprite -> {rel_out}")
    else:
        print(f"\n{len(written)} dosya yazildi")

    names_list = recipe["names"]
    if recipe["naming"] == "list" and names_list and produced != len(names_list):
        print(f"UYARI: {produced} parca uretildi, tarifte {len(names_list)} isim var")
    elif not names_list and recipe["naming"] == "list":
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
    """Icerik JSON'larinin atifta bulundugu her sprite atlas'ta ve ui_art'ta var mi.

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
    atlas_missing = bool(missing)
    if missing:
        print(f"\nEKSIK ({len(missing)}):")
        for sprite, files in sorted(missing.items()):
            where = ", ".join(sorted(set(files)))
            print(f"  {sprite}  <- {where}")
    else:
        unused = known - set(referenced)
        if unused:
            print(f"\nkullanilmayan {len(unused)} sprite: {', '.join(sorted(unused))}")
        print("\nTUM ATIFLAR KARSILANIYOR")

    # UI sanati kontrolu
    expected_ui: list[tuple[str, str]] = []

    units_path = CONTENT_DIR / "units.json"
    if units_path.exists():
        units_data = json.loads(units_path.read_text(encoding="utf-8"))
        for unit_key in units_data.keys():
            expected_ui.append(("portraits", unit_key))

    upgrades_path = CONTENT_DIR / "upgrades.json"
    if upgrades_path.exists():
        upgrades_data = json.loads(upgrades_path.read_text(encoding="utf-8"))
        for entry in upgrades_data.values():
            if isinstance(entry, dict) and entry.get("icon"):
                expected_ui.append(("illustrations", entry["icon"]))

    abilities_path = CONTENT_DIR / "abilities.json"
    if abilities_path.exists():
        abilities_data = json.loads(abilities_path.read_text(encoding="utf-8"))
        for entry in abilities_data.values():
            if isinstance(entry, dict) and entry.get("icon"):
                expected_ui.append(("icons", entry["icon"]))
                expected_ui.append(("illustrations", entry["icon"]))

    unique_expected_ui = sorted(set(expected_ui))

    present_ui = [
        (grp, item_id)
        for grp, item_id in unique_expected_ui
        if (UI_ART_DIR / grp / f"{item_id}.webp").exists()
    ]
    missing_ui = [
        (grp, item_id)
        for grp, item_id in unique_expected_ui
        if not (UI_ART_DIR / grp / f"{item_id}.webp").exists()
    ]

    print(f"\nui_art: {len(present_ui)}/{len(unique_expected_ui)} mevcut")
    if missing_ui:
        missing_str = ", ".join(f"{g}/{i}" for g, i in missing_ui)
        print(f"UI SANATI EKSIK ({len(missing_ui)}): {missing_str}")

    if atlas_missing:
        return 1
    if getattr(args, "strict_ui_art", False) and missing_ui:
        return 1
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
    p_ingest.add_argument(
        "source",
        nargs="+",
        help="zip dosyasi, klasor veya goruntu(ler)",
    )
    p_ingest.add_argument("--recipe", required=True, help="tarif adi")
    p_ingest.add_argument(
        "--keep",
        action="store_true",
        help="mevcut ciktilari silme, uzerine ekle",
    )
    p_ingest.add_argument(
        "--out",
        type=Path,
        default=None,
        help="cikti koku (verilirse atlas icin DIR/<tarif>/, ui_art icin DIR/<grup>/)",
    )
    p_ingest.set_defaults(func=cmd_ingest)

    p_pack = sub.add_parser("pack", help="sprite'lari atlas'a paketle")
    p_pack.add_argument("--group", required=True, help="tarif/grup adi")
    p_pack.set_defaults(func=cmd_pack)

    p_verify = sub.add_parser("verify", help="icerik <-> atlas ve ui_art tutarliligi")
    p_verify.add_argument(
        "--strict-ui-art",
        action="store_true",
        help="eksik ui_art varsa hata ver (cikis kodu 1)",
    )
    p_verify.set_defaults(func=cmd_verify)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
