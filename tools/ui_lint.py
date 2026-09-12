#!/usr/bin/env python3
"""RIFTWARDEN arayuz denetimi.

`AGENTS.md` icindeki baglayici arayuz kurallarini mekanik olarak kontrol eder.
Amac, arayuz worker'inin ciktisini elle okumadan once ucuz bir kapi koymak:
tema token'ini atlayip ham deger yazmak, RTL'i bozmak, ceviriye baglanmamis
metin birakmak gibi ihlaller burada yakalanir.

    python tools/ui_lint.py              # tum arayuz dosyalari
    python tools/ui_lint.py lib/shared   # sadece verilen yol

Kacis kapisi: ihlalin oldugu satira `// ui-lint: ignore <sebep>` yaz.
Sebep zorunlu -- sebepsiz ignore da hata sayilir.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Arayuz worker'inin sahip oldugu dizinler.
UI_GLOBS = (
    "lib/shared/widgets/**/*.dart",
    "lib/features/*/view/**/*.dart",
    "lib/features/*/widgets/**/*.dart",
)

# Tema dosyalari token'larin TANIMLANDIGI yerdir; ham deger orada serbest.
THEME_DIR = ROOT / "lib" / "app" / "theme"

IGNORE_RE = re.compile(r"//\s*ui-lint:\s*ignore\s+(?P<reason>\S.*)$")
IGNORE_BARE_RE = re.compile(r"//\s*ui-lint:\s*ignore\s*$")

# Harf iceren metin ceviriye baglanmali. Sadece noktalama/rakam iceren
# literaller ('/', '%', '-', '99+') serbest.
TEXT_LITERAL_RE = re.compile(r"""\bText\(\s*(['"])(?P<body>(?:(?!\1).)*)\1""")


@dataclass(frozen=True)
class Rule:
    name: str
    pattern: re.Pattern[str]
    message: str
    theme_exempt: bool = False
    path_contains: str | None = None


RULES: tuple[Rule, ...] = (
    Rule(
        "ham-renk",
        re.compile(r"Color\(0x"),
        "Ham renk degeri. AppColors'tan oku (lib/app/theme/app_colors.dart).",
        theme_exempt=True,
    ),
    Rule(
        "ham-tipografi",
        re.compile(r"\bfontSize\s*:"),
        "Elde TextStyle. AppTypography'den al (lib/app/theme/app_typography.dart).",
        theme_exempt=True,
    ),
    Rule(
        "rtl-edgeinsets",
        re.compile(r"EdgeInsets\.only\([^)]*\b(?:left|right)\s*:"),
        "RTL bozar. EdgeInsetsDirectional.only(start:/end:) kullan.",
    ),
    Rule(
        "rtl-ltrb",
        re.compile(r"EdgeInsets\.fromLTRB\("),
        "RTL bozar. EdgeInsetsDirectional.fromSTEB(...) kullan.",
    ),
    Rule(
        "rtl-alignment",
        re.compile(r"\bAlignment\.(?:centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight)\b"),
        "RTL bozar. AlignmentDirectional.(centerStart/centerEnd/...) kullan.",
    ),
    Rule(
        "battle-riverpod",
        re.compile(r"\bref\.(?:watch|read|listen)\b"),
        "Savas HUD'u Riverpod okumaz. BattleSignals + ValueListenableBuilder kullan.",
        path_contains="features/battle/",
    ),
)


@dataclass(frozen=True)
class Finding:
    path: Path
    line_no: int
    rule: str
    message: str
    source: str

    def render(self) -> str:
        # Repo disindaki bir dosya elle verilmis olabilir (ornegin kendi
        # testimiz); o durumda tam yolu bas, kirilma.
        try:
            rel = self.path.relative_to(ROOT).as_posix()
        except ValueError:
            rel = self.path.as_posix()
        return (
            f"{rel}:{self.line_no}  [{self.rule}]\n"
            f"    {self.source.strip()}\n"
            f"    -> {self.message}"
        )


def collect_files(argv: list[str]) -> list[Path]:
    if argv:
        files: list[Path] = []
        for arg in argv:
            target = (ROOT / arg) if not Path(arg).is_absolute() else Path(arg)
            if target.is_dir():
                files.extend(target.rglob("*.dart"))
            elif target.suffix == ".dart":
                files.append(target)
        return sorted(set(files))

    files = []
    for pattern in UI_GLOBS:
        files.extend(ROOT.glob(pattern))
    return sorted(set(files))


def is_in_theme(path: Path) -> bool:
    return THEME_DIR in path.parents


def check_file(path: Path) -> list[Finding]:
    findings: list[Finding] = []
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeDecodeError) as exc:
        return [Finding(path, 0, "okunamadi", str(exc), "")]

    posix = path.as_posix()
    in_theme = is_in_theme(path)

    for i, line in enumerate(lines, start=1):
        # Sebepli ignore satiri denetimden muaf; sebepsiz olan hatadir.
        if IGNORE_RE.search(line):
            continue
        if IGNORE_BARE_RE.search(line):
            findings.append(
                Finding(
                    path, i, "ignore-sebepsiz",
                    "ui-lint: ignore kullanacaksan sebebini yaz.", line,
                )
            )
            continue

        # Yorum satirlarini atla: ornek kod gosteren yorumlar tetiklemesin.
        if line.lstrip().startswith("//"):
            continue

        for rule in RULES:
            if rule.theme_exempt and in_theme:
                continue
            if rule.path_contains and rule.path_contains not in posix:
                continue
            if rule.pattern.search(line):
                findings.append(Finding(path, i, rule.name, rule.message, line))

        # Text('...') literali: sadece harf iceriyorsa ceviri gerekir.
        for match in TEXT_LITERAL_RE.finditer(line):
            body = match.group("body")
            if any(ch.isalpha() for ch in body):
                findings.append(
                    Finding(
                        path, i, "cevrilmemis-metin",
                        "Kullaniciya gorunen metin AppLocalizations'tan gelmeli.",
                        line,
                    )
                )

    return findings


def main(argv: list[str]) -> int:
    files = collect_files(argv)
    if not files:
        print("denetlenecek arayuz dosyasi yok")
        return 0

    findings: list[Finding] = []
    for path in files:
        findings.extend(check_file(path))

    print(f"{len(files)} dosya denetlendi")
    if not findings:
        print("TEMIZ")
        return 0

    print(f"\n{len(findings)} ihlal:\n")
    for finding in findings:
        print(finding.render())
        print()

    by_rule: dict[str, int] = {}
    for finding in findings:
        by_rule[finding.rule] = by_rule.get(finding.rule, 0) + 1
    print("ozet: " + ", ".join(f"{k}={v}" for k, v in sorted(by_rule.items())))
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
