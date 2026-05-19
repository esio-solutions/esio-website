#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# render-instagram-carousel.sh
#
# Renders the 5-slide marketing carousel into JPGs for every (format × lang
# × theme × slide) combination:
#
#   format : instagram (1080×1350)  +  facebook (1200×630)
#   lang   : en, da
#   theme  : dark, light, app-preview
#   slide  : 01-hook · 02-pain · 03-solution · 04-proof · 05-cta
#
# Pipeline:
#   1. `hugo --minify` builds the site, including the per-format pages at
#      /marketing/<format>/<slide>/ (and /da/marketing/<format>/<slide>/).
#      Content stubs live at content/marketing/<format>/, layouts at
#      themes/esio-theme/layouts/marketing/<format>/single.html. Each slide
#      partial pulls copy from data/<lang>/index/<section>/.
#   2. A one-shot Playwright container loads each URL with ?theme=<theme>,
#      waits for fonts, and screenshots at the format's native viewport.
#   3. JPGs land in marketing/output/<format>/<lang>/<theme>/<slide>.jpg.
#
# Manual usage:
#     ./scripts/render-instagram-carousel.sh
#
# Requires:
#   - hugo (the static site builder)
#   - docker
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
RENDER_DIR="$REPO_ROOT/marketing/instagram"   # docker build context; name is legacy
PUBLIC_DIR="$REPO_ROOT/public"
OUTPUT_DIR="$REPO_ROOT/marketing/output"
IMAGE_TAG="esio-social-render:latest"

# ── Tool checks ─────────────────────────────────────────────────────────────
for tool in docker hugo; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: $tool not installed." >&2
    exit 1
  fi
done

mkdir -p "$OUTPUT_DIR"

# ── 1. Hugo build ───────────────────────────────────────────────────────────
echo "building Hugo site → $PUBLIC_DIR ..."
( cd "$REPO_ROOT" && hugo --minify --cleanDestinationDir )

for fmt in instagram facebook linkedin google-ads; do
  if [[ ! -d "$PUBLIC_DIR/marketing/$fmt" ]]; then
    echo "error: $PUBLIC_DIR/marketing/$fmt missing after hugo build." >&2
    echo "       check content/marketing/$fmt/*.md and its layouts." >&2
    exit 1
  fi
done

# ── 2. Docker image ─────────────────────────────────────────────────────────
echo "building $IMAGE_TAG ..."
docker build --quiet -t "$IMAGE_TAG" "$RENDER_DIR"

# ── 3. Render ───────────────────────────────────────────────────────────────
echo "rendering slides into $OUTPUT_DIR ..."
docker run \
  --rm --init \
  --user "$(id -u):$(id -g)" \
  -v "$PUBLIC_DIR:/work/public:ro" \
  -v "$OUTPUT_DIR:/work/output" \
  "$IMAGE_TAG"

# ── Done ────────────────────────────────────────────────────────────────────
count=$(find "$OUTPUT_DIR" -name '*.jpg' | wc -l)
echo "done. $count JPG(s) in $OUTPUT_DIR (organised by format/lang/theme)"
