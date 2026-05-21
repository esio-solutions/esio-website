#!/usr/bin/env bash
# Renders marketing-typst/instagram/01-hook.typ once per (palette × theme)
# into marketing-typst/out/palette-comparison/<palette>/<theme>.jpg so palette
# variants can be compared side-by-side without rebuilding the whole carousel.
#
# After per-palette renders, composites every result into a single labeled
# worksheet at marketing-typst/out/palette-comparison/_all.jpg. Each palette
# appears as a (light, dark) pair labeled with palette name + theme, tiled
# 4 cells per row (2 palettes × 2 themes) so related variants stay adjacent.
#
# Iterates every folder under themes/esio-theme/assets/css/m3/ that has both
# light.json and dark.json (the typst renderer requires both). Folders missing
# JSON sidecars (legacy hand-curated palettes) are skipped with a warning.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TYPST_DIR="$ROOT/marketing-typst"
M3_DIR="$ROOT/themes/esio-theme/assets/css/m3"
OUTPUT_DIR="$TYPST_DIR/out/palette-comparison"
FONT_PATH="$TYPST_DIR/fonts"
SRC="$TYPST_DIR/instagram/01-hook.typ"
TYPST="${TYPST:-typst}"

if ! command -v "$TYPST" >/dev/null 2>&1; then
  echo "error: typst not found on PATH" >&2
  exit 1
fi
if ! command -v magick >/dev/null 2>&1; then
  echo "error: ImageMagick (magick) not found on PATH" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

total=0
skipped=0
for palette_dir in "$M3_DIR"/*/; do
  palette=$(basename "$palette_dir")
  if [[ ! -f "$palette_dir/light.json" || ! -f "$palette_dir/dark.json" ]]; then
    echo "  skip $palette (no light.json + dark.json)"
    skipped=$((skipped + 1))
    continue
  fi
  mkdir -p "$OUTPUT_DIR/$palette"
  for theme in light dark; do
    png_tmp="$(mktemp --suffix=.png)"
    "$TYPST" compile "$SRC" "$png_tmp" \
      --root "$ROOT" \
      --font-path "$FONT_PATH" \
      --input "palette=$palette" \
      --input "theme=$theme" \
      --input "lang=en"
    magick "$png_tmp" -quality 92 "$OUTPUT_DIR/$palette/$theme.jpg"
    rm -f "$png_tmp"
    total=$((total + 1))
    printf "  → %s/%s.jpg\n" "$palette" "$theme"
  done
done

echo ""
echo "done. $total JPG(s) written to $OUTPUT_DIR ($skipped palette(s) skipped)"

# ── Composite worksheet ────────────────────────────────────────────────────
# Build the input list in (palette × theme) order, labeling each cell with
# both the palette name and the theme so the sheet is self-describing when
# viewed standalone.
WORKSHEET="$OUTPUT_DIR/_all.jpg"
echo ""
echo "→ Building composite worksheet at $WORKSHEET"

inputs=()
for palette_dir in "$M3_DIR"/*/; do
  palette=$(basename "$palette_dir")
  if [[ ! -f "$palette_dir/light.json" || ! -f "$palette_dir/dark.json" ]]; then
    continue
  fi
  for theme in light dark; do
    inputs+=(-label "$palette / $theme" "$OUTPUT_DIR/$palette/$theme.jpg")
  done
done

magick montage \
  "${inputs[@]}" \
  -geometry "360x450+8+8" \
  -tile 4x \
  -background "#1a1a1a" \
  -fill "#e1e2eb" \
  -font "Plus-Jakarta-Sans-Bold" \
  -pointsize 14 \
  -quality 92 \
  "$WORKSHEET" 2>/dev/null \
  || magick montage \
       "${inputs[@]}" \
       -geometry "360x450+8+8" \
       -tile 4x \
       -background "#1a1a1a" \
       -fill "#e1e2eb" \
       -pointsize 14 \
       -quality 92 \
       "$WORKSHEET"
# Font fallback: if Plus Jakarta Sans isn't registered with fontconfig,
# magick errors before writing. Second invocation drops the -font flag and
# uses ImageMagick's default sans, which always works.

echo "  ✓ $WORKSHEET ($(du -h "$WORKSHEET" | cut -f1))"
