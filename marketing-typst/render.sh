#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# marketing-typst/render.sh
#
# Compiles every marketing template into SVGs for every
# (format × lang × theme × slide) combination via Typst.
#
# Replaces the previous Hugo + Playwright + Docker pipeline at
# scripts/render-instagram-carousel.sh — see _docs/marketing-pipeline.md
# (or _docs/marketing-css-pipeline.md if not renamed yet).
#
# Output layout — three-level hierarchy: language / platform / theme:
#   marketing-typst/out/<lang>/<format>/<theme>/<slide>.svg
# Lets you navigate by audience first (en vs da campaigns), then platform
# (FB vs IG vs LI vs Google), then mode (light vs dark variants). The
# out/ folder is gitignored — re-run this script to regenerate.
#
# Requires:
#   - typst on PATH (or set TYPST env var to point at the binary)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# Find repo root (parent of this script's directory)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
OUTPUT_DIR="$SCRIPT_DIR/out"
FONT_PATH="$SCRIPT_DIR/fonts"
TYPST="${TYPST:-typst}"

if ! command -v "$TYPST" >/dev/null 2>&1; then
  echo "error: typst not found on PATH. Install via 'apt install typst' or" >&2
  echo "       download from github.com/typst/typst/releases and set TYPST=path/to/typst." >&2
  exit 1
fi

# Format catalogue — (name, slides as space-separated)
# Slides are .typ file basenames under marketing-typst/<format>/
#
# `square` is the universal 1080×1080 social asset — one square satisfies
# every feed (Facebook, Instagram, LinkedIn), replacing the former
# per-platform folders. `google-ads` keeps its mandated IAB banner sizes,
# which can't be square.
declare -A SLIDES=(
  ["square"]="01-hook 02-pain 03-solution 04-proof 05-cta"
  ["google-ads"]="160x600 300x250 300x600 320x50 728x90"
)

LANGS=("en" "da")
THEMES=("light" "dark")

total=0
for lang in "${LANGS[@]}"; do
  for format in square google-ads; do
    for theme in "${THEMES[@]}"; do
      out_dir="$OUTPUT_DIR/$lang/$format/$theme"
      mkdir -p "$out_dir"
      for slide in ${SLIDES[$format]}; do
        src="$SCRIPT_DIR/$format/${slide}.typ"
        if [[ ! -f "$src" ]]; then
          echo "warn: missing $src — skipping" >&2
          continue
        fi
        "$TYPST" compile "$src" "$out_dir/${slide}.svg" \
          --format svg \
          --root "$REPO_ROOT" \
          --font-path "$FONT_PATH" \
          --input "theme=$theme" \
          --input "lang=$lang"
        total=$((total + 1))
        printf "  → %s/%s/%s/%s.svg\n" "$lang" "$format" "$theme" "$slide"
      done
    done
  done
done

echo ""
echo "done. $total SVG(s) written to $OUTPUT_DIR"
