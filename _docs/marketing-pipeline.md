# Marketing renderer — Typst pipeline

The marketing ad assets (Facebook / Instagram / LinkedIn carousels and
Google Display banners) are rendered by Typst from templates under
`marketing-typst/`. The whole subsystem is self-contained inside that
folder — templates, fonts, slide content data, config, and the render
script all live together.

## What lives where

```
marketing-typst/
├── marketing.toml          palette + font config (pinned, independent
│                           of the site's interactive M3 picker)
├── tokens.typ              shared loader — reads marketing.toml +
│                           m3/<palette>/<mode>.json into named constants
│                           (primary, surface, primary-font, display-font, …)
├── data/                   slide content (YAML), {en, da}
│   ├── en/{hero,pain,how,features,subscribe}/…
│   └── da/…
├── fonts/                  static TTF/woff2 files Typst loads via
│                           --font-path (Inter, Fraunces, Material Symbols)
├── facebook/               1200×630 landscape — 5 slides + _layout.typ
├── instagram/              1080×1350 portrait — 5 slides + _layout.typ
├── linkedin/               1200×1200 square — 5 slides + _layout.typ
├── google-ads/             5 display-banner sizes + _layout.typ
├── render.sh               compiles every (platform × lang × theme × slide)
│                           combination to JPG
├── out/                    rendered JPGs, grouped per-platform, flat
│                           (gitignored — re-run render.sh to regenerate)
└── .gitignore              ignores out/
```

## Running the renderer

```sh
TYPST=~/.local/bin/typst ./marketing-typst/render.sh
```

Outputs 80 JPGs total: 4 platforms × 2 languages × 2 themes × 5 slides
(20 for google-ads since each banner size is one slide). Each lands at
`marketing-typst/out/<platform>/<slide>-<lang>-<theme>.jpg`, ready to
drag-upload to that platform's ad manager.

Requires Typst on PATH (or set `TYPST=path/to/typst`) and ImageMagick
(`magick`). The render itself runs in seconds — no Docker, no browser,
no Hugo.

## Decisions

### Why Typst instead of Hugo + Playwright

The previous pipeline rendered HTML templates via headless Chrome and
screenshotted them. It hit four recurring failure modes — all rooted in
HTML/CSS being the wrong abstraction for "render a static image":

1. `hugo --minify`'s tdewolff CSS minifier stripped quotes from
   multi-word `font-family` values, silently breaking fonts in
   screenshots.
2. Hugo's `safeCSS` didn't preserve safety markers across partial
   boundaries — `"` and `+` got HTML-entity escaped inside `<style>`
   blocks, breaking M3 selectors and font URLs.
3. Browser font loading is async; even `document.fonts.ready` sometimes
   resolved before fonts were actually applied.
4. Heavy pipeline: Hugo build + Docker + Playwright + inline-style
   manipulation for something that's fundamentally "render data into a
   layout."

Typst is a typesetting language with markdown-feel syntax. It compiles
straight to PNG/PDF/SVG, no browser, no async font loading, no CSS
minifier quirks. All four failure modes vanish.

### Why ads pin a palette instead of following the site picker

Marketing assets are rendered once and published to ad platforms. If they
tracked the live site's palette picker, every palette experiment on the
site would silently invalidate already-published ads. The
`marketing-typst/marketing.toml` pin decouples ad brand stability from
site-side experimentation. To change the ad palette: edit
`marketing-typst/marketing.toml`, re-run `render.sh`, re-upload.

### Why Inter + Fraunces (matching the website)

`marketing.toml` declares:
- `fonts.primary = "Inter"` (body/UI text)
- `fonts.display = "Fraunces"` (headlines)

Same families the website uses (`[params.typography].fontFamily` and
`.displayFontFamily` in `hugo.toml`). Both surfaces now render a
visually identical "voice."

The static font files in `marketing-typst/fonts/` were extracted at
`opsz=14` from the Fraunces variable font — text-optimized, thicker
strokes. The website's font loader was updated at the same time to
explicitly declare `opsz=14` in its Google Fonts URL
(`themes/esio-theme/layouts/_partials/head/fonts.html`), so the
variable font served by Google Fonts uses the same optical-size
instance. Without that explicit declaration, Google would serve
Fraunces at its default opsz, which differs from the static instance
and would make the website headlines visibly thicker than the marketing
headlines.

If you ever want to tune the Fraunces optical size:
1. Re-extract statics: `python3 -m fontTools.varLib.instancer
   Fraunces-Variable.ttf wght=900 opsz=<value> SOFT=0 WONK=0 --output
   Fraunces-Black.ttf` (and Medium 500, Bold 700)
2. Update `[params.typography].displayFontOpsz` in `hugo.toml` to the
   same value so the site stays in sync.

### Why icons via Material Symbols Outlined

Slide 04-proof's feature panels use Material Symbols icons (the icon
font's name-to-glyph ligature mechanism — typing `"currency_exchange"`
with `features: ("liga": 1)` renders the corresponding glyph). The
static instance lives at `marketing-typst/fonts/MaterialSymbolsOutlined-Static.ttf`
(extracted from the variable font at `wght=400 FILL=0 GRAD=0 opsz=48`).

The slide-04 navigation arrow and the inline focal arrow on slide 01-hook
also use Material Symbols (`arrow_right_alt` ligature), so they pick up
the active palette's primary color automatically via `text(fill: primary)`.

## Per-platform sizing

Each platform's `_layout.typ` carries a `SIZES` dict mirroring the Hugo
CSS's per-platform scale (`themes/esio-theme/layouts/_partials/<platform>/styles.html`
in git history if you need the original numbers):

| Platform | Canvas | logo | h-xxl | h-l | padding (x / top / bottom) |
|---|---|---|---|---|---|
| Facebook | 1200×630 | 64pt | 72pt | 44pt | 56 / 48 / 48 |
| Instagram | 1080×1350 | 144pt | 108pt | 76pt | 80 / 80 / 96 |
| LinkedIn | 1200×1200 | 108pt | 100pt | 64pt | 72 / 64 / 80 |

Google-ads sizes vary per banner — sized inline in each banner's `.typ`.

## When something breaks

- **A slide overflows the canvas** (Typst: "cannot export multiple
  images without a page number template"). Typst tried to paginate
  because content overflowed. Common causes:
  - Danish (longer than English) wraps to more lines than expected.
    Either reduce font size on that slide's card/feature body, or
    tighten the gap between sections (the `#v(…pt)` calls).
  - Headline at h-l/h-xxl now extends below the canvas after a font
    swap (different metrics). Drop one notch (h-xxl → h-xl).
- **Font renders wrong**. Check `~/.local/bin/typst fonts --font-path
  marketing-typst/fonts` includes the font you expect. If the warning
  "variable fonts are not currently supported" appears, the font file
  is a variable, not a static — re-extract via fonttools' instancer.
- **Color looks off**. Check `marketing-typst/marketing.toml` palette
  name. The palette JSON sidecars live at
  `themes/esio-theme/assets/css/m3/<palette>/{light,dark}.json` and are
  emitted by `scripts/generate-m3-palette.mjs` alongside the CSS.
