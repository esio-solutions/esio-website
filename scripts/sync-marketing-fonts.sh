#!/usr/bin/env bash
# Syncs marketing-typst/fonts/ with the fonts referenced in
# marketing-typst/marketing.toml [fonts]. Typst loads fonts from
# --font-path (set in marketing-typst/render.sh) — system fonts are
# not searched in CI, so the family used by the renderer must live in
# that directory as TTFs.
#
# Currently pinned to Plus Jakarta Sans (tokotype/PlusJakartaSans). To
# swap fonts, change FAMILY/REPO/TAG/WEIGHTS below and re-run; stale
# files from the previous family are pruned automatically.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONT_DIR="$ROOT/marketing-typst/fonts"

FAMILY="PlusJakartaSans"
REPO="tokotype/PlusJakartaSans"
TAG="2.7.1"
# Weight-name pairs matching primary_weights in marketing.toml (400-800).
WEIGHTS=(Regular Medium SemiBold Bold ExtraBold)

# Families that previous syncs may have left behind.
STALE_FAMILIES=(Inter Fraunces)

mkdir -p "$FONT_DIR"

echo "→ Fetching $FAMILY $TAG into $FONT_DIR"
for weight in "${WEIGHTS[@]}"; do
  file="${FAMILY}-${weight}.ttf"
  url="https://raw.githubusercontent.com/${REPO}/${TAG}/fonts/ttf/${file}"
  curl -fsSL --retry 3 -o "$FONT_DIR/$file" "$url"
  echo "  ✓ $file"
done

for stale in "${STALE_FAMILIES[@]}"; do
  shopt -s nullglob
  for f in "$FONT_DIR/${stale}-"*; do
    rm -f "$f"
    echo "  ✗ removed $(basename "$f")"
  done
  shopt -u nullglob
done

echo "done. marketing-typst/fonts/ now matches marketing.toml [fonts]."
