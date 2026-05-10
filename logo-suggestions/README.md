# Logo Suggestions

Exploratory variants for the still-actionable items from the design review. Open each `.svg` directly in a browser or file viewer.

This folder is outside `static/` so Hugo won't publish it. Rename / move into `static/assets/` only when promoting a variant to production.

## 01 — Navy color sync

The brand currently has two navies: `#1B2B6B` (used in `hugo.toml`, the OG image, and dark surfaces) and `#325080` (used in the logo files). Pick one.

| File | Navy | Notes |
|---|---|---|
| `01a-color-current-325080.svg` | `#325080` | Reference: what the logo files currently use |
| `01b-color-synced-1B2B6B.svg` | `#1B2B6B` | Synced to the website's primary navy — recommended |

`01b` is more saturated and confident; sits flush with the OG image and homepage navy without reading as a different color.

## 02 — Corner radius

Current production tile uses `rx="6"` — only ~3.4% of the 176-unit tile width. Modern app icons go bigger.

| File | rx | % of width | Feel |
|---|---|---|---|
| `02a-radius-06-current.svg` | 6 | 3.4% | What we ship today — reads as "rectangle with corners filed" |
| `02b-radius-22-modern.svg` | 22 | 12.5% | Contemporary SaaS app-icon look |
| `02c-radius-40-ios.svg` | 40 | 22.7% | iOS-canonical app icon — strong "app on home screen" feel |

Recommendation: `02b` for general use; `02c` only if you specifically want to lean into the iOS app-icon aesthetic.

## 03 — Clock pivot dot (legibility)

The clock metaphor is great — but invisible to viewers who haven't been told. A single small dot at the hand pivot point is the universal "this is a clock" signal.

| File | Treatment |
|---|---|
| `03a-clock-no-pivot.svg` | Current — clock readable but ambiguous |
| `03b-clock-with-pivot.svg` | Adds a 5-unit navy dot at the hand pivot — strengthens the "clock" read |

The pivot dot is the cheapest possible disambiguation. Worth user-testing whether it makes viewers spontaneously identify the mark as a clock.

## 04 — Favicon vs. App icon strategy

Different surfaces want different treatments. The current tile-on-everything approach fights browser chrome but suits social feeds.

### Browser favicon (transparent, adapts to tab color)

| File | Mode |
|---|---|
| `04a-favicon-transparent-light.svg` | Light tabs (navy mark on user's tab color) |
| `04b-favicon-transparent-dark.svg` | Dark tabs (white mark on user's tab color) |

Wire these via the existing `media="(prefers-color-scheme: …)"` partial.

### Social profile / app icon (tile, ownable square presence)

| File | Mode |
|---|---|
| `04c-app-icon-tile-light.svg` | White tile + navy clock — for light-mode contexts |
| `04d-app-icon-tile-dark.svg` | Navy tile + white clock — for dark-mode / hero contexts |

Use these for LinkedIn company logo, Slack workspace icon, Twitter/X avatar, iOS/Android app icon, etc. — all 400×400+ surfaces where you want a strong, branded square.

## 05 — Wordmark color sync

Same color fix as `01`, applied to the full wordmark used in the site header (`logo-blue.svg`) and OG image.

| File | Navy |
|---|---|
| `05a-wordmark-current-325080.svg` | `#325080` (current) |
| `05b-wordmark-synced-1B2B6B.svg` | `#1B2B6B` (recommended) |

If you accept the navy sync, this replaces `static/assets/logo-blue.svg` directly. The `logo-white.svg` and `logo-black.svg` siblings don't need changes — they're already pure white / pure black.

## 06 — Wordmark with clock pivot dot

Same legibility tweak as `03`, applied to the wordmark.

| File | Treatment |
|---|---|
| `06a-wordmark-no-pivot.svg` | Synced navy, current geometry |
| `06b-wordmark-with-pivot.svg` | Adds 5-unit navy pivot dot |

The pivot dot is more visible at wordmark scale (e.g., on the OG image) than at favicon scale, so this variant is mainly worth shipping if you want to push the clock metaphor harder in marketing surfaces.

## 07 — Wordmark on tile (branded card)

For surfaces where you want the full wordmark with a hard square boundary — LinkedIn cover photo, Twitter/X header, slide deck title cards, email signature card. 3:1 aspect ratio (800×267 viewBox), `rx=22` to match the app icon.

| File | Treatment |
|---|---|
| `07a-wordmark-tile-light.svg` | White tile + navy wordmark |
| `07b-wordmark-tile-dark.svg` | Navy tile + white wordmark |

Not a replacement for the existing transparent wordmark used in the nav header — additive, for branded contexts.

## 08 — Alternative metaphor: stock arrow (instead of clock)

A different cutout in the same disc — an up-and-to-the-right growth arrow instead of clock hands. More universally legible (every viewer reads "positive trajectory" instantly), but less ownable (every fintech ships a growth arrow). The clock is poetic-but-needs-explaining; the arrow is direct-but-generic.

| File | Treatment |
|---|---|
| `08a-square-stock-arrow-light.svg` | White tile + navy disc + smooth arrow cutout |
| `08b-square-stock-arrow-dark.svg`  | Navy tile + white disc + smooth arrow cutout |
| `08c-wordmark-stock-arrow.svg`     | Full wordmark with smooth arrow in the O |

## 09 — Zig-zag stock arrow (4 turns, busy)

Replaces the smooth diagonal with a stock-chart line: 5 segments alternating up/down, 4 direction changes. Reads instantly as "real businesses go up and down but trend up."

| File | Treatment |
|---|---|
| `09a-square-zigzag-arrow-light.svg` | White tile + navy disc + zig-zag cutout |
| `09b-square-zigzag-arrow-dark.svg`  | Navy tile + white disc + zig-zag cutout |
| `09c-wordmark-zigzag-arrow.svg`     | Full wordmark with zig-zag in the O |

## 10 — Zig-zag stock arrow (3 turns, calmer)

Same idea as 09 but with 4 segments and 3 direction changes — quieter rhythm, the same chart story told with fewer wiggles.

| File | Treatment |
|---|---|
| `10a-square-zigzag3-light.svg` | White tile, 3-turn zig-zag |
| `10b-square-zigzag3-dark.svg`  | Navy tile, 3-turn zig-zag |
| `10c-wordmark-zigzag3.svg`     | Wordmark with 3-turn zig-zag in the O |

## 11 — Curved trend arrow

Smooth Bezier curve (two chained cubic segments) instead of angular zig-zag. Reads as a polished editorial-style chart line: gentle dip near the start, rise to a peak, slight valley, big rise to the arrowhead. More organic, less "chart screenshot."

| File | Treatment |
|---|---|
| `11a-square-curved-arrow-light.svg` | White tile, curved trend |
| `11b-square-curved-arrow-dark.svg`  | Navy tile, curved trend |
| `11c-wordmark-curved-arrow.svg`     | Wordmark with curved trend in the O |

## Unified arrowhead

All four arrow types (smooth, 4-turn zig-zag, 3-turn zig-zag, curved) now share the same canonical arrowhead geometry — `<polygon points="490,50 462,54.3 481.6,77.1">` — and the same mask + stroked-path architecture. The trend line is the only thing that differs between variants.

See sections 08-12 of `_worksheet.svg` for direct comparisons.

## Worksheet output

`_worksheet.svg` is the all-in-one comparison sheet — vector, scalable, Figma-importable. Every variant is embedded as a nested `<svg>` (preserving its viewBox), so importing the worksheet into Figma turns each tile into its own selectable frame. Re-run `scripts/build-logo-worksheet.py` after editing any variant to refresh.

## How to inspect

```sh
# Open one in your default browser:
xdg-open logo-suggestions/02b-radius-22-modern.svg

# Or render all to PNGs for side-by-side comparison:
# (requires Inkscape — already installed in this environment)
for f in logo-suggestions/*.svg; do
  inkscape --export-type=png --export-width=256 \
    --export-filename="${f%.svg}.png" "$f"
done
```
