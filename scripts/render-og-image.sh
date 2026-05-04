#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# render-og-image.sh
#
# Render static/assets/og-default.svg → static/assets/og-default.jpg at the
# canonical 1200×630 OG card dimensions. The SVG is the source of truth;
# the JPG is the build artifact that social platforms actually scrape.
#
# Manual usage:
#     ./scripts/render-og-image.sh
#
# Pre-commit hook (recommended — auto-rebuilds the JPG whenever the SVG is
# staged, so the two never drift). The hook itself lives at
# scripts/hooks/pre-commit; activate it with a single symlink:
#
#     ln -sf ../../scripts/hooks/pre-commit .git/hooks/pre-commit
#     chmod +x scripts/hooks/pre-commit
#
# Requires:
#   - inkscape           (snap install inkscape  /  apt install inkscape)
#   - python3 + Pillow   (apt install python3-pil  /  pip install pillow)
#
# Note on fonts:
#   The SVG declares "Plus Jakarta Sans" as the primary font. If that font
#   isn't installed locally, Inkscape falls back to the system sans-serif and
#   the rendered text won't match the design exactly. To install:
#     1. Download TTFs from https://fonts.google.com/specimen/Plus+Jakarta+Sans
#        (or https://github.com/tokotype/PlusJakartaSans)
#     2. Copy the .ttf files into ~/.local/share/fonts/
#     3. Run: fc-cache -f
#   This script will warn (but still run) if the font is missing.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
SVG="$REPO_ROOT/static/assets/og-default.svg"
JPG="$REPO_ROOT/static/assets/og-default.jpg"

# Snap-confined Inkscape can only write inside the user's home directory, so
# the temp PNG must land in the repo (which is in home) — not /tmp/, which
# is the default mktemp location. Without -p, this script silently produces
# an empty file when Inkscape is installed via snap.
PNG_TMP="$(mktemp -p "$REPO_ROOT" --suffix=.png)"
trap 'rm -f "$PNG_TMP"' EXIT

# ── Tool checks ─────────────────────────────────────────────────────────────
if ! command -v inkscape >/dev/null 2>&1; then
  echo "error: inkscape not installed (need it for SVG → PNG)." >&2
  echo "       install via 'snap install inkscape' or 'apt install inkscape'." >&2
  exit 1
fi

if ! python3 -c "import PIL" 2>/dev/null; then
  echo "error: Python Pillow not installed (need it for PNG → JPG)." >&2
  echo "       install via 'apt install python3-pil' or 'pip install pillow'." >&2
  exit 1
fi

# ── Font check (warning only — continues with fallback if missing) ──────────
if ! fc-list 2>/dev/null | grep -qi "plus jakarta"; then
  echo "warning: 'Plus Jakarta Sans' not installed; rendered text will use a fallback font." >&2
  echo "         install instructions in this script's header comment." >&2
fi

# ── Render ──────────────────────────────────────────────────────────────────
echo "rendering $SVG → $JPG"

# SVG → PNG via Inkscape (silence Gdk warnings that fire in headless envs)
inkscape "$SVG" \
  --export-type=png \
  --export-filename="$PNG_TMP" \
  --export-width=1200 \
  --export-height=630 \
  2>&1 | grep -vE "^$|Gdk-WARNING|Failed to load cursor" >&2 || true

# Sanity-check that Inkscape actually produced a non-empty PNG. Snap or
# permission issues can cause silent zero-byte output that would confuse
# the next step with a cryptic Pillow UnidentifiedImageError.
if [[ ! -s "$PNG_TMP" ]]; then
  echo "error: Inkscape produced no output ($PNG_TMP is empty or missing)." >&2
  echo "       check Inkscape's stderr above for clues; common cause is" >&2
  echo "       snap confinement preventing writes outside \$HOME." >&2
  exit 1
fi

# PNG → JPG via Pillow (quality 85, RGB, optimised)
python3 - "$PNG_TMP" "$JPG" <<'PY'
import sys
from PIL import Image
src, dst = sys.argv[1], sys.argv[2]
im = Image.open(src)
im.convert('RGB').save(dst, 'JPEG', quality=85, optimize=True)
print(f"wrote {dst} ({im.size[0]}x{im.size[1]})")
PY

# ── Done ────────────────────────────────────────────────────────────────────
size=$(du -h "$JPG" | cut -f1)
echo "done. og-default.jpg is now $size."
