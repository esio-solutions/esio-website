#!/usr/bin/env python3
"""
Generate a "gradient" variant of a flat character SVG.

The flat character files under static/assets/characters/ use a small
<style> block with class-based flat fills:

    .iN-st0 { fill: none; }
    .iN-st1 { fill: #3770b5; }
    .iN-st4, .iN-st5 { fill: #ce9e91; }    # comma-separated selectors
    .iN-st5 { isolation: isolate; opacity: .99; }   # other properties

This script:
  • Parses every CSS rule in the <style> block, including
    comma-separated selectors and rules whose declarations aren't a
    fill (these get preserved unchanged in the output).
  • For each `fill: #hex` rule, emits one <linearGradient> per
    selector and replaces the rule's fill value with `url(#<class>-grad)`.
  • The new <defs> block contains all the gradients plus the rewritten
    <style> with every original non-fill rule preserved.

Net effect: each shape gets a subtle top-to-bottom highlight (≈15%
lighter colour at the top, base colour at the bottom) without losing
any of the original styling (isolation, opacity, stroke, fill:none, …).

Usage:
    python3 scripts/generate-character-gradient.py <input.svg> [output.svg]

Batch mode (process every flat character file in a directory):
    python3 scripts/generate-character-gradient.py --batch <dir>
    (skips files whose name already ends in `-gradient.svg`)
"""

import re
import sys
from pathlib import Path

# How much to mix each base colour with white for the top gradient stop.
# 0.15 = 15% white. Higher = brighter highlight; past ~0.25 the result
# starts to read as "shiny".
LIGHTEN_FACTOR = 0.15


def lighten(hex_color: str, factor: float = LIGHTEN_FACTOR) -> str:
    """Mix `hex_color` with white by `factor` (0..1). Returns #rrggbb."""
    h = hex_color.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    r = round(r + (255 - r) * factor)
    g = round(g + (255 - g) * factor)
    b = round(b + (255 - b) * factor)
    return f"#{r:02x}{g:02x}{b:02x}"


# Parse a CSS rule "selector { declarations }" — handles whitespace +
# newlines because [^{] / [^}] both include them.
RULE_RE = re.compile(r"([^{}]+?)\s*\{([^}]*)\}", re.DOTALL)


def parse_rules(style_body: str) -> list[tuple[list[str], dict[str, str]]]:
    """Parse a CSS body into (selectors, declarations) tuples in order."""
    out = []
    for m in RULE_RE.finditer(style_body):
        selectors = [s.strip() for s in m.group(1).split(",") if s.strip()]
        decls: dict[str, str] = {}
        # Preserve declaration order by reading sequentially.
        for decl in m.group(2).split(";"):
            if ":" not in decl:
                continue
            k, v = decl.split(":", 1)
            decls[k.strip()] = v.strip()
        if selectors and decls:
            out.append((selectors, decls))
    return out


def is_hex_fill(decls: dict[str, str]) -> bool:
    fill = decls.get("fill", "")
    return fill.startswith("#") and re.fullmatch(r"#[0-9a-fA-F]{3,8}", fill) is not None


def render_decls(decls: dict[str, str]) -> str:
    return "; ".join(f"{k}: {v}" for k, v in decls.items()) + ";"


def transform(text: str) -> tuple[str, int]:
    """Replace the first <defs> block with one carrying the gradients +
    rewritten style block. Returns (new_text, num_gradients_generated)."""

    defs_match = re.search(r"<defs>(.*?)</defs>", text, re.DOTALL)
    if not defs_match:
        raise SystemExit("No <defs>...</defs> block found in the SVG.")
    style_match = re.search(r"<style[^>]*>(.*?)</style>", defs_match.group(1), re.DOTALL)
    if not style_match:
        raise SystemExit("No <style>...</style> block found inside <defs>.")

    rules = parse_rules(style_match.group(1))
    if not rules:
        raise SystemExit("Could not parse any CSS rules from <style>.")

    gradients: list[str] = []
    style_rules: list[str] = []
    grad_seen: set[str] = set()

    for selectors, decls in rules:
        if is_hex_fill(decls):
            base = decls["fill"]
            # Emit one rule + one gradient per selector so each class has
            # its own gradient ID (avoids cross-character collisions when
            # multiple inlined SVGs share a page).
            for sel in selectors:
                cls = sel.lstrip(".")
                grad_id = f"{cls}-grad"
                if cls not in grad_seen:
                    light = lighten(base)
                    gradients.append(
                        f'    <linearGradient id="{grad_id}" x1="0" y1="0" x2="0" y2="1">\n'
                        f'      <stop offset="0" stop-color="{light}"/>\n'
                        f'      <stop offset="1" stop-color="{base}"/>\n'
                        f"    </linearGradient>"
                    )
                    grad_seen.add(cls)
                # Replace the fill in this rule's declarations; preserve
                # any other properties (stroke, opacity, …).
                new_decls = dict(decls)
                new_decls["fill"] = f"url(#{grad_id})"
                style_rules.append(
                    f"      .{cls} {{ {render_decls(new_decls)} }}"
                )
        else:
            # Non-fill rule (e.g. `fill: none`, `isolation: isolate`,
            # `opacity: .99`, `stroke: #...`) — preserve unchanged with
            # original comma-separated selector list.
            sel_str = ", ".join(selectors)
            style_rules.append(f"      {sel_str} {{ {render_decls(decls)} }}")

    new_defs = (
        "  <!-- Generated by scripts/generate-character-gradient.py.\n"
        "       Per-color linear gradients (top stop = base lightened\n"
        "       ~15% with white, bottom stop = base) give each shape a\n"
        "       soft overhead-light highlight. Gradients use\n"
        "       objectBoundingBox space so each shape gets its own ramp\n"
        "       regardless of size. Non-fill rules (fill:none, opacity,\n"
        "       isolation, stroke, …) from the source file are preserved\n"
        "       verbatim — only `fill: #hex` rules are rewritten. -->\n"
        "  <defs>\n"
        + "\n".join(gradients)
        + "\n"
        + "    <style>\n"
        + "\n".join(style_rules)
        + "\n"
        + "    </style>\n"
        + "  </defs>"
    )

    new_text, n = re.subn(
        r"<defs>.*?</defs>", new_defs, text, count=1, flags=re.DOTALL
    )
    if n == 0:
        raise SystemExit("Failed to replace the <defs> block.")
    return new_text, len(gradients)


def process_file(input_path: Path, output_path: Path | None = None) -> Path:
    if output_path is None:
        output_path = input_path.with_name(input_path.stem + "-gradient.svg")
    text = input_path.read_text()
    new_text, n_gradients = transform(text)
    output_path.write_text(new_text)
    print(f"wrote {output_path}  (gradients: {n_gradients})")
    return output_path


def batch(dir_path: Path) -> None:
    if not dir_path.is_dir():
        raise SystemExit(f"Not a directory: {dir_path}")
    files = sorted(
        f
        for f in dir_path.glob("*.svg")
        if not f.stem.endswith("-gradient")
    )
    if not files:
        raise SystemExit(f"No flat character SVGs found in {dir_path}")
    for f in files:
        try:
            process_file(f)
        except SystemExit as e:
            print(f"skip {f}: {e}", file=sys.stderr)


def main() -> None:
    args = sys.argv[1:]
    if not args or args[0] in {"-h", "--help"}:
        print(__doc__)
        return

    if args[0] == "--batch":
        if len(args) < 2:
            raise SystemExit("--batch requires a directory argument.")
        batch(Path(args[1]))
        return

    input_path = Path(args[0])
    if not input_path.exists():
        raise SystemExit(f"Input file not found: {input_path}")
    output_path = Path(args[1]) if len(args) > 1 else None
    process_file(input_path, output_path)


if __name__ == "__main__":
    main()
