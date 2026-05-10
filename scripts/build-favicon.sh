#!/usr/bin/env bash
# Regenerates static/favicon.ico from static/assets/logo-square-light.svg.
# Run after editing the square logo SVG. Requires inkscape + python3 with Pillow.
#
# Note: the snap build of Inkscape is confined and cannot write to /tmp, so the
# scratch PNG is staged inside the repo and removed on exit.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SVG="$ROOT/static/assets/logo-square-light.svg"
ICO="$ROOT/static/favicon.ico"
PNG="$ROOT/.favicon-build.png"
trap 'rm -f "$PNG"' EXIT

inkscape --export-type=png --export-width=256 --export-height=256 \
    --export-filename="$PNG" "$SVG" >/dev/null 2>&1

python3 - "$PNG" "$ICO" <<'PY'
import sys
from PIL import Image
src, dst = sys.argv[1], sys.argv[2]
Image.open(src).save(dst, format="ICO", sizes=[(16, 16), (32, 32), (48, 48)])
PY

echo "Wrote $ICO"
