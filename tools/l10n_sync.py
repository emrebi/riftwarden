#!/usr/bin/env python3
"""ARB senkronizasyonu.

Arayuz worker'i yeni metin anahtarlarini SADECE `app_en.arb`'ye ekler
(bkz. AGENTS.md). Bu script o anahtarlari diger 15 locale dosyasina yayar.

Ceviri yapmaz -- eksik anahtara Ingilizce degeri koyar ve TODO olarak
isaretler. Gercek ceviri turu tum ekranlar bitince tek seferde yapilacak
(bkz. docs/KNOWN_GAPS.md madde 5).

    python tools/l10n_sync.py            # eksikleri yay
    python tools/l10n_sync.py --check    # yayma, sadece rapor et (exit 1)

Turkce icin `TR_OVERRIDES` tablosuna elle ceviri girilebilir; girilmisse
Ingilizce yerine o kullanilir.
"""

from __future__ import annotations

import argparse
import io
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARB_DIR = ROOT / "lib" / "l10n" / "arb"
TEMPLATE = ARB_DIR / "app_en.arb"

# Turkce cevirileri. Burada olmayan anahtar Ingilizce kalir ve raporda
# "TR eksik" olarak listelenir.
TR_OVERRIDES: dict[str, str] = {
    "battlePauseTitle": "DURAKLATILDI",
    "battleResume": "DEVAM ET",
    "battleAimHint": "HEDEFE DOKUN",
    "hudBossWave": "BOSS DALGASI",
    # Birlik adlari ozel isim: ceviri yok, tum dillerde ayni kalir.
    "unitPulseGuard": "Pulse Guard",
    "unitArcRanger": "Arc Ranger",
    "unitTitanFrame": "Titan Frame",
}


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def save(path: Path, data: dict) -> None:
    with io.open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(prog="l10n_sync", description=__doc__)
    parser.add_argument(
        "--check", action="store_true",
        help="degisiklik yapma, eksikleri rapor et ve eksik varsa 1 don",
    )
    args = parser.parse_args(argv)

    if not TEMPLATE.exists():
        raise SystemExit(f"sablon bulunamadi: {TEMPLATE}")

    template = load(TEMPLATE)
    keys = [k for k in template if not k.startswith("@")]

    # Aciklamasi olmayan anahtar: ceviri kalitesi icin baglam sart.
    undocumented = [k for k in keys if f"@{k}" not in template]

    targets = sorted(p for p in ARB_DIR.glob("app_*.arb") if p != TEMPLATE)
    added_total = 0
    tr_missing: list[str] = []
    report: list[str] = []

    for path in targets:
        data = load(path)
        locale = data.get("@@locale", path.stem.replace("app_", ""))
        missing = [k for k in keys if k not in data]
        if not missing:
            continue

        if args.check:
            report.append(f"  {path.name:20} {len(missing)} eksik")
            added_total += len(missing)
            continue

        for key in missing:
            if locale == "tr" and key in TR_OVERRIDES:
                data[key] = TR_OVERRIDES[key]
            else:
                data[key] = template[key]
                if locale == "tr":
                    tr_missing.append(key)
        # Anahtar sirasi sablonu takip etsin; diff'ler okunabilir kalsin.
        ordered = {"@@locale": locale}
        ordered.update({k: data[k] for k in keys if k in data})
        save(path, ordered)
        added_total += len(missing)
        report.append(f"  {path.name:20} +{len(missing)}")

    if undocumented:
        print(f"UYARI: aciklamasi ({'@anahtar'}) olmayan {len(undocumented)} anahtar:")
        for k in undocumented:
            print(f"  {k}")
        print("  -> ceviri kalitesi icin app_en.arb'ye @aciklama ekle\n")

    if not added_total:
        print("tum locale'ler guncel")
        return 0

    print(("eksik anahtarlar:" if args.check else "yayilan anahtarlar:"))
    print("\n".join(report))
    print(f"\ntoplam {added_total}")

    if tr_missing:
        print(
            f"\nTR cevirisi eksik ({len(tr_missing)}): {', '.join(sorted(set(tr_missing)))}"
            "\n  -> tools/l10n_sync.py icindeki TR_OVERRIDES tablosuna ekle"
        )

    if args.check:
        return 1

    print("\nsiradaki: flutter gen-l10n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
