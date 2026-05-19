#!/usr/bin/env python3
"""
Builds a single comparison worksheet SVG from the variants in logo-suggestions/.

Output: logo-suggestions/_worksheet.svg — vector, scalable, Figma-importable.

Variants are embedded as nested <svg> elements (preserving each variant's own
viewBox), so the worksheet stays editable: in Figma, every tile becomes its
own frame; in Inkscape/Illustrator, every path stays selectable.

Run from project root:
    python3 scripts/build-logo-worksheet.py
"""
from __future__ import annotations
import html
import os
import re
from PIL import ImageFont

ROOT = os.path.dirname(os.path.abspath(__file__))
SUGS = os.path.join(ROOT, "logo-suggestions")
OUT = os.path.join(SUGS, "_worksheet.svg")

# Tile sizes (rendered px in worksheet)
SQUARE_W = 260
WORDMARK_W = 520
BANNER_W = 600

# Layout
CANVAS_W = 1700
PAD = 40
SECTION_GAP = 32
TILE_GAP = 20
LABEL_H = 26
COMMENT_W = 380
COMMENT_PAD = 28
TITLE_BAR_W = 6
TITLE_BAR_H = 30

# Palette
BG = "rgb(252,250,247)"
TEXT = "rgb(28,32,48)"
SUBTEXT = "rgb(110,116,138)"
ACCENT = "rgb(224,123,91)"      # terra
DIVIDER = "rgb(224,220,213)"
TILE_BAND_BG = "rgb(243,239,232)" # neutral warm beige; doesn't compete with card/tile colors

# Font sizes (in px). DejaVu used only for measurement; rendering uses
# Plus Jakarta Sans with sans-serif fallback so Figma/Illustrator pick up
# the brand font if installed.
F_TITLE_PX = 36
F_INTRO_PX = 16
F_SECTION_PX = 22
F_LABEL_PX = 14
F_COMMENT_PX = 14
INTRO_LH = 22
COMMENT_LH = 20

FONT_FAMILY = "'Plus Jakarta Sans', system-ui, -apple-system, sans-serif"
FL = "/usr/share/fonts/truetype/dejavu"
_measure_fonts = {
    "title":   ImageFont.truetype(f"{FL}/DejaVuSans-Bold.ttf", F_TITLE_PX),
    "intro":   ImageFont.truetype(f"{FL}/DejaVuSans.ttf", F_INTRO_PX),
    "section": ImageFont.truetype(f"{FL}/DejaVuSans-Bold.ttf", F_SECTION_PX),
    "label":   ImageFont.truetype(f"{FL}/DejaVuSans-Bold.ttf", F_LABEL_PX),
    "comment": ImageFont.truetype(f"{FL}/DejaVuSans.ttf", F_COMMENT_PX),
}


def measure(text: str, key: str) -> float:
    return _measure_fonts[key].getlength(text)


def wrap(text: str, key: str, max_w: float) -> list[str]:
    words = text.split()
    lines, cur = [], []
    for w in words:
        cand = " ".join(cur + [w])
        if measure(cand, key) <= max_w or not cur:
            cur.append(w)
        else:
            lines.append(" ".join(cur))
            cur = [w]
    if cur:
        lines.append(" ".join(cur))
    return lines


def parse_variant(path: str) -> tuple[str, str]:
    """Return (viewBox, inner_xml) of a variant SVG."""
    with open(path) as f:
        content = f.read()
    m = re.search(r"<svg([^>]*?)>(.*)</svg>\s*$", content, re.DOTALL)
    if not m:
        raise ValueError(f"Could not parse SVG at {path}")
    attrs, inner = m.group(1), m.group(2)
    vb = re.search(r'viewBox="([^"]+)"', attrs)
    return (vb.group(1) if vb else ""), inner.strip()


SECTIONS = [
    {
        "n": "01", "title": "Square mark — navy color sync",
        "tiles": [
            ("01a-color-current-325080", "BEFORE  #325080", SQUARE_W),
            ("01b-color-synced-1B2B6B",  "AFTER   #1B2B6B", SQUARE_W),
        ],
        "comment": (
            "The brand has two navies. #325080 lives in the logo files; "
            "#1B2B6B lives in hugo.toml, the OG image, and every dark surface "
            "of the site. Side-by-side they read as different colors — a real "
            "brand-system fracture, not a perceptual quirk. Recommend syncing "
            "everything to #1B2B6B (more saturated, already dominant) and "
            "deleting #325080 from the brand."
        ),
    },
    {
        "n": "02", "title": "Square mark — corner radius",
        "tiles": [
            ("02a-radius-06-current", "rx=6  (3.4%)  current",   SQUARE_W),
            ("02b-radius-22-modern",  "rx=22 (12.5%) modern",    SQUARE_W),
            ("02c-radius-40-ios",     "rx=40 (22.7%) iOS-style", SQUARE_W),
        ],
        "comment": (
            "Current rx=6 reads as 'rectangle with corners filed' — vintage. "
            "rx=22 is contemporary SaaS app-icon territory. rx=40 is iOS-canonical "
            "and signals 'this is an app on a home screen.' Recommend rx=22 as the "
            "default; reserve rx=40 for explicit iOS contexts."
        ),
    },
    {
        "n": "03", "title": "Square mark — clock pivot dot",
        "tiles": [
            ("03a-clock-no-pivot",   "BEFORE  no pivot",      SQUARE_W),
            ("03b-clock-with-pivot", "AFTER   with pivot dot", SQUARE_W),
        ],
        "comment": (
            "Without context, viewers read the cutout as a chevron or arrow. "
            "A 5-unit dot at the hand origin is the universal 'this is an analog "
            "clock' cue — anchors the time/forecasting metaphor. Caveat: at "
            "favicon scale (16-32px) the dot disappears; this fix shows up "
            "mainly at logomark scale (256px+)."
        ),
    },
    {
        "n": "04", "title": "Square mark — surface strategy (favicon vs app icon)",
        "tiles": [
            ("04a-favicon-transparent-light", "favicon  light",   SQUARE_W),
            ("04b-favicon-transparent-dark",  "favicon  dark",    SQUARE_W),
            ("04c-app-icon-tile-light",       "app icon  light",  SQUARE_W),
            ("04d-app-icon-tile-dark",        "app icon  dark",   SQUARE_W),
        ],
        "comment": (
            "Don't ship one mark for both surfaces. Browser tabs want a "
            "transparent mark that adapts to user-chosen tab colors. Social "
            "feeds want a defined tile that owns a square in the timeline. "
            "Wire both: transparent SVGs via <link media=prefers-color-scheme>, "
            "tile PNGs uploaded to LinkedIn/Twitter/Slack."
        ),
    },
    {
        "n": "05", "title": "Wordmark — navy color sync",
        "tiles": [
            ("05a-wordmark-current-325080", "BEFORE  #325080", WORDMARK_W),
            ("05b-wordmark-synced-1B2B6B",  "AFTER   #1B2B6B", WORDMARK_W),
        ],
        "comment": (
            "Same color fix as 01, applied to the production wordmark. If you "
            "accept the navy sync, this swap directly replaces "
            "static/assets/logo-blue.svg. Logo-white.svg and logo-black.svg "
            "need no changes — they're already pure white / pure black."
        ),
    },
    {
        "n": "06", "title": "Wordmark — clock pivot dot",
        "tiles": [
            ("06a-wordmark-no-pivot",   "BEFORE  no pivot",       WORDMARK_W),
            ("06b-wordmark-with-pivot", "AFTER   with pivot dot", WORDMARK_W),
        ],
        "comment": (
            "At wordmark scale the pivot is unmistakable — turns 'O with two "
            "wedges' into 'clock face.' Worth shipping if you want to push the "
            "time/forecasting metaphor in marketing surfaces (OG image, hero, "
            "press kit). Less impactful for the 28px nav header where the dot "
            "becomes sub-pixel."
        ),
    },
    {
        "n": "06+", "title": "Wordmark — letterforms × clock O (no pivot)",
        "tiles": [
            ("06a-wordmark-no-pivot",     "current  custom geometric letters",  WORDMARK_W),
            ("12a-wordmark-pjs-no-pivot", "system   Plus Jakarta Sans Black",   WORDMARK_W),
        ],
        "comment": (
            "Two letterform philosophies, same O. Custom letters give the wordmark "
            "its own typographic territory — distinctive but typographically "
            "separate from Plus Jakarta Sans Black, which sets every other "
            "heading on the site. The PJS prototype subs the system font for "
            "'esi' and keeps the custom O. PJS letters are narrower than the "
            "custom set, so the O sits more dominant in the composition — "
            "that's the trade-off, not a bug."
        ),
    },
    {
        "n": "06++", "title": "Wordmark — letterforms × clock O (with pivot)",
        "tiles": [
            ("06b-wordmark-with-pivot",     "current  custom + pivot dot",        WORDMARK_W),
            ("12b-wordmark-pjs-with-pivot", "system   PJS Black + pivot dot",     WORDMARK_W),
        ],
        "comment": (
            "Same letterform comparison, now with the pivot dot anchored at the "
            "clock-hand origin. The dot reads as a clock face in both versions; "
            "it does not depend on the letterforms. If you ship the clock metaphor, "
            "decide letterforms first, then add the pivot."
        ),
    },
    {
        "n": "07", "title": "Wordmark — branded card (additive, not a replacement)",
        "tiles": [
            ("07a-wordmark-tile-light", "white tile  +  navy wordmark", BANNER_W),
            ("07b-wordmark-tile-dark",  "navy tile   +  white wordmark", BANNER_W),
        ],
        "comment": (
            "3:1 banner format (rx=22) for surfaces that want the full wordmark "
            "with a hard square boundary: LinkedIn cover, X/Twitter header, "
            "slide deck title cards, email signature card. Additive to the "
            "existing transparent wordmark — that one stays in the nav header."
        ),
    },
    {
        "n": "08", "title": "Alternative metaphor — stock arrow vs clock (square)",
        "tiles": [
            ("04c-app-icon-tile-light",      "CLOCK  light",       SQUARE_W),
            ("08a-square-stock-arrow-light", "STOCK ARROW  light", SQUARE_W),
            ("04d-app-icon-tile-dark",       "CLOCK  dark",        SQUARE_W),
            ("08b-square-stock-arrow-dark",  "STOCK ARROW  dark",  SQUARE_W),
        ],
        "comment": (
            "Same disc, different cutout: an up-and-to-the-right growth arrow "
            "instead of clock hands. The stock-arrow metaphor is more universally "
            "legible — viewers see 'positive trajectory' immediately, no story "
            "needed. The clock is more poetic ('see your runway in time') but "
            "requires explaining. Both fit the brand voice; pick based on whether "
            "you want the mark to whisper (clock) or shout (arrow)."
        ),
    },
    {
        "n": "09", "title": "Alternative metaphor — wordmark variants",
        "tiles": [
            ("06a-wordmark-no-pivot",       "CLOCK",       WORDMARK_W),
            ("08c-wordmark-stock-arrow",    "STOCK ARROW", WORDMARK_W),
        ],
        "comment": (
            "Wordmark equivalent of section 08. Notice how the arrow's diagonal "
            "echoes the natural reading direction (left-to-right, ascending) — "
            "feels purposeful in a way the clock doesn't. Trade-off: the arrow "
            "is less distinctive (every fintech uses one), the clock is more "
            "ownable. If you commit to the arrow, the brand reads instantly as "
            "'finance / growth.'"
        ),
    },
    {
        "n": "10", "title": "Arrow style — energy comparison (square, light)",
        "tiles": [
            ("08a-square-stock-arrow-light",  "smooth",            SQUARE_W),
            ("09a-square-zigzag-arrow-light", "zig-zag · 4 turns", SQUARE_W),
            ("10a-square-zigzag3-light",      "zig-zag · 3 turns", SQUARE_W),
            ("11a-square-curved-arrow-light", "curved",            SQUARE_W),
        ],
        "comment": (
            "All four share the same canonical arrowhead — only the trend line "
            "differs. Smooth = calm/abstract. Zig-zag · 4 turns = busy/honest "
            "(volatile path, upward trend). Zig-zag · 3 turns = same idea, "
            "calmer rhythm. Curved = polished/editorial (organic wave). The "
            "'boring is the goal' brand voice probably points to smooth or "
            "curved; the founder-empathy positioning ('we know the path is "
            "bumpy') points to zig-zag."
        ),
    },
    {
        "n": "11", "title": "Arrow style — energy comparison (square, dark)",
        "tiles": [
            ("08b-square-stock-arrow-dark",  "smooth",            SQUARE_W),
            ("09b-square-zigzag-arrow-dark", "zig-zag · 4 turns", SQUARE_W),
            ("10b-square-zigzag3-dark",      "zig-zag · 3 turns", SQUARE_W),
            ("11b-square-curved-arrow-dark", "curved",            SQUARE_W),
        ],
        "comment": (
            "Same four variants on the dark tile. The white-on-navy reversal "
            "tends to make the trend line read more emphatically — every variant "
            "feels a bit louder. The curved version benefits most from the "
            "high-contrast treatment; its organic shape becomes a clear "
            "'flowing chart line' rather than a generic squiggle."
        ),
    },
    {
        "n": "12+a", "title": "Wordmark — letterforms × smooth stock arrow",
        "tiles": [
            ("08c-wordmark-stock-arrow",     "current  custom letterforms",         WORDMARK_W),
            ("12c-wordmark-pjs-stock-arrow", "system   Plus Jakarta Sans Black",    WORDMARK_W),
        ],
        "comment": (
            "Stock-arrow O paired with both letterform systems. The straight "
            "smooth arrow is the most generic shape — the letterform choice "
            "carries proportionally more of the brand identity here than in "
            "more distinctive arrow variants."
        ),
    },
    {
        "n": "12+b", "title": "Wordmark — letterforms × zig-zag (4 turns)",
        "tiles": [
            ("09c-wordmark-zigzag-arrow",  "current  custom letterforms",       WORDMARK_W),
            ("12d-wordmark-pjs-zigzag",    "system   Plus Jakarta Sans Black",  WORDMARK_W),
        ],
        "comment": (
            "Busy zig-zag O. The 4-turn zig-zag is visually loud regardless of "
            "letterforms; this comparison is mostly about whether the surrounding "
            "type can hold its own next to the busy mark, or whether the system "
            "(PJS) recedes too much."
        ),
    },
    {
        "n": "12+c", "title": "Wordmark — letterforms × zig-zag (3 turns)",
        "tiles": [
            ("10c-wordmark-zigzag3",       "current  custom letterforms",       WORDMARK_W),
            ("12e-wordmark-pjs-zigzag3",   "system   Plus Jakarta Sans Black",  WORDMARK_W),
        ],
        "comment": (
            "Calmer 3-turn zig-zag — same vocabulary as 12+b but with more "
            "breathing room in the cutout. Often the better choice for both "
            "letterform systems because the mark stops competing with the type."
        ),
    },
    {
        "n": "12+d", "title": "Wordmark — letterforms × curved arrow (exponential)",
        "tiles": [
            ("11c-wordmark-curved-arrow",  "current  custom letterforms",       WORDMARK_W),
            ("12f-wordmark-pjs-curved",    "system   Plus Jakarta Sans Black",  WORDMARK_W),
        ],
        "comment": (
            "Curved (exponential) O is the most editorial of the four arrow "
            "variants — feels organic, less infographic. Pairs especially well "
            "with PJS Black's slightly humanist proportions: the curve and the "
            "lettering share a softer geometry. If you commit to the curved O, "
            "PJS may be the more consistent letterform choice."
        ),
    },
    {
        "n": "13", "title": "Wordmark cards — latest design (PJS Black + curved-arrow O)",
        "tiles": [
            ("13a-card-light", "light  white tile + navy wordmark",  BANNER_W),
            ("13b-card-dark",  "dark   navy tile + white wordmark",  BANNER_W),
        ],
        "comment": (
            "Branded card format using the latest letterform decision (Plus "
            "Jakarta Sans Black) and the latest icon decision (curved exponential "
            "arrow). 3:1 banner with rx=22 corners — drop-in for LinkedIn cover, "
            "X/Twitter header, slide-deck title cards, email signature card. "
            "Two-color system: tile + wordmark, no accent."
        ),
    },
    {
        "n": "13+", "title": "Wordmark cards — 70-20-10 with terra-orange accent",
        "tiles": [
            ("13c-card-light-orange", "light  70 white / 20 navy / 10 orange",  BANNER_W),
            ("13d-card-dark-orange",  "dark   70 navy / 20 white / 10 orange",  BANNER_W),
        ],
        "comment": (
            "Same cards with terra-orange (#E07B5B) introduced as the 10% accent, "
            "showing through the arrow cutout in the O. Follows the 70-20-10 rule: "
            "tile dominates (~70%), wordmark fills ~20%, orange arrow punches the "
            "final 10%. The accent gives the card a brand-system feel — orange is "
            "the site's terra accent, so its appearance here ties the wordmark to "
            "the larger brand language without overwhelming the mark itself."
        ),
    },
    {
        "n": "13++", "title": "Wordmark card — orange dominant (CTA / hero surface)",
        "tiles": [
            ("13e-card-orange", "70 orange / 20 navy / 10 white", BANNER_W),
        ],
        "comment": (
            "Inverted hierarchy: terra orange becomes the dominant 70% (full "
            "tile), navy wordmark sits as the 20%, and white shows through the "
            "arrow cutout as the 10%. This is the loudest of the five cards — "
            "use for hero banners, CTA surfaces, paid social, or any moment "
            "where the brand should shout rather than whisper. Not for nav, "
            "not for utility surfaces."
        ),
    },
]


def render_text(x: int, y: int, text: str, *, size: int, weight: int = 400,
                fill: str = TEXT) -> str:
    """Single-line text element."""
    return (
        f'<text x="{x}" y="{y}" font-family="{FONT_FAMILY}" '
        f'font-size="{size}" font-weight="{weight}" fill="{fill}">'
        f'{html.escape(text)}</text>'
    )


def render_text_block(x: int, y: int, lines: list[str], *, size: int,
                      weight: int = 400, fill: str = TEXT,
                      line_height: int = 20) -> str:
    """Multi-line text via a single <text> with <tspan>s. y = baseline of first line."""
    if not lines:
        return ""
    spans = []
    for i, line in enumerate(lines):
        dy = 0 if i == 0 else line_height
        spans.append(f'<tspan x="{x}" dy="{dy}">{html.escape(line)}</tspan>')
    return (
        f'<text x="{x}" y="{y}" font-family="{FONT_FAMILY}" '
        f'font-size="{size}" font-weight="{weight}" fill="{fill}">'
        f'{"".join(spans)}</text>'
    )


def render_variant(x: int, y: int, w: int, h: int, viewBox: str, inner: str) -> str:
    """Embed a variant SVG as a nested <svg>, preserving its viewBox."""
    return (
        f'<svg x="{x}" y="{y}" width="{w}" height="{h}" '
        f'viewBox="{viewBox}" overflow="visible">{inner}</svg>'
    )


def variant_height(viewBox: str, target_w: int) -> int:
    """Compute display height from viewBox + target width."""
    parts = viewBox.split()
    vb_w, vb_h = float(parts[2]), float(parts[3])
    return int(round(target_w * vb_h / vb_w))


def build():
    title_text = "ESIO logo system — variant worksheet"
    intro_text = (
        "Side-by-side comparison of the proposed fixes. Each section shows the "
        "current state (BEFORE) and the proposed change(s) on a terra-orange "
        "background — the brand accent color, which exposes any leftover "
        "white-fill that pretends to be transparent. Comments on the right "
        "explain what changed and why."
    )

    # Pre-load all variants and compute their display heights.
    parsed = {}
    for sec in SECTIONS:
        for name, _label, target_w in sec["tiles"]:
            if name not in parsed:
                vb, inner = parse_variant(os.path.join(SUGS, f"{name}.svg"))
                parsed[name] = (vb, inner)

    # Layout: walk sections, accumulate heights.
    intro_lines = wrap(intro_text, "intro", CANVAS_W - 2 * PAD)
    header_h = PAD + 50 + 14 + len(intro_lines) * INTRO_LH + 12 + 4

    layouts = []
    for sec in SECTIONS:
        max_tile_h = 0
        for name, _label, w in sec["tiles"]:
            vb, _ = parsed[name]
            max_tile_h = max(max_tile_h, variant_height(vb, w))
        comment_lines = wrap(sec["comment"], "comment",
                             COMMENT_W - 2 * COMMENT_PAD)
        comment_h = len(comment_lines) * COMMENT_LH + 2 * COMMENT_PAD
        band_h = max(max_tile_h + LABEL_H + 16, comment_h)
        sec_h = 36 + 16 + band_h + SECTION_GAP
        layouts.append({
            "section": sec, "max_tile_h": max_tile_h,
            "comment_lines": comment_lines, "band_h": band_h, "sec_h": sec_h,
        })

    canvas_h = header_h + sum(l["sec_h"] for l in layouts) + PAD

    parts = []
    parts.append(
        f'<svg xmlns="http://www.w3.org/2000/svg" '
        f'viewBox="0 0 {CANVAS_W} {canvas_h}" '
        f'width="{CANVAS_W}" height="{canvas_h}" '
        f'font-family="{FONT_FAMILY}">'
    )
    parts.append(f'<rect width="{CANVAS_W}" height="{canvas_h}" fill="{BG}"/>')

    # Header
    y = PAD
    parts.append(render_text(PAD, y + 36, title_text,
                             size=F_TITLE_PX, weight=700))
    y += 50
    parts.append(render_text_block(PAD, y + 16, intro_lines,
                                   size=F_INTRO_PX, fill=SUBTEXT,
                                   line_height=INTRO_LH))
    y += len(intro_lines) * INTRO_LH + 12
    parts.append(
        f'<line x1="{PAD}" y1="{y}" x2="{CANVAS_W - PAD}" y2="{y}" '
        f'stroke="{DIVIDER}" stroke-width="2"/>'
    )
    y += 4

    # Sections
    for layout in layouts:
        sec = layout["section"]
        # Title
        parts.append(
            f'<rect x="{PAD}" y="{y + 8}" width="{TITLE_BAR_W}" '
            f'height="{TITLE_BAR_H}" fill="{ACCENT}"/>'
        )
        parts.append(render_text(
            PAD + 18, y + 30, f'{sec["n"]}  {sec["title"]}',
            size=F_SECTION_PX, weight=700,
        ))
        y += 36 + 16

        tile_x0 = PAD
        tile_x1 = CANVAS_W - PAD - COMMENT_W
        band_y0 = y
        band_y1 = y + layout["band_h"]
        parts.append(
            f'<rect x="{tile_x0}" y="{band_y0}" '
            f'width="{tile_x1 - tile_x0}" height="{layout["band_h"]}" '
            f'fill="{TILE_BAND_BG}"/>'
        )

        # Tiles, centered horizontally in the band
        tiles = sec["tiles"]
        widths = [w for _, _, w in tiles]
        total_w = sum(widths) + TILE_GAP * (len(widths) - 1)
        tx = tile_x0 + ((tile_x1 - tile_x0) - total_w) // 2
        for name, label, w in tiles:
            vb, inner = parsed[name]
            h = variant_height(vb, w)
            ty = band_y0 + (layout["band_h"] - h - LABEL_H) // 2
            parts.append(render_variant(tx, ty, w, h, vb, inner))
            # Centered label
            label_w_px = measure(label, "label")
            lx = tx + (w - label_w_px) // 2
            parts.append(render_text(
                int(lx), ty + h + 18, label,
                size=F_LABEL_PX, weight=700,
            ))
            tx += w + TILE_GAP

        # Comment column
        cx = tile_x1 + 24
        parts.append(
            f'<line x1="{tile_x1 + 12}" y1="{band_y0 + 8}" '
            f'x2="{tile_x1 + 12}" y2="{band_y1 - 8}" '
            f'stroke="{DIVIDER}" stroke-width="1"/>'
        )
        parts.append(render_text_block(
            cx, band_y0 + COMMENT_PAD + F_COMMENT_PX,
            layout["comment_lines"], size=F_COMMENT_PX, line_height=COMMENT_LH,
        ))

        y = band_y1 + SECTION_GAP

    parts.append("</svg>")

    with open(OUT, "w") as f:
        f.write("\n".join(parts))
    print(f"Wrote {OUT} ({CANVAS_W}x{canvas_h})")


if __name__ == "__main__":
    build()
