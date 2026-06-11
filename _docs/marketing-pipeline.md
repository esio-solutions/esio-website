# Marketing renderer — Typst pipeline

The marketing ad assets (a universal 1080×1080 square social carousel and
Google Display banners) are rendered by Typst from templates under
`marketing-typst/`. The whole subsystem is self-contained inside that
folder — templates, fonts, slide content data, config, and the render
script all live together.

One square asset satisfies every social feed (Facebook, Instagram,
LinkedIn), so there is a single `square/` format rather than a folder per
platform. The `google-ads/` banners stay separate — their IAB dimensions
are mandated by the ad network and can't be square.

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
├── fonts/                  static TTF files Typst loads via --font-path
│                           (Plus Jakarta Sans, Material Symbols)
├── square/                 1080×1080 universal social — 5 slides +
│                           _layout.typ (serves FB / IG / LI feeds)
├── google-ads/             5 display-banner sizes + _layout.typ
├── render.sh               compiles every (format × lang × theme × slide)
│                           combination to SVG
├── out/                    rendered SVGs, grouped <lang>/<format>/<theme>/
│                           (gitignored — re-run render.sh to regenerate)
└── .gitignore              ignores out/
```

## Running the renderer

```sh
TYPST=~/.local/bin/typst ./marketing-typst/render.sh
```

Outputs 40 SVGs total: 2 formats × 2 languages × 2 themes × 5 slides
(`square` has 5 carousel slides; `google-ads` has 5 banner sizes, one
slide each). Each lands at
`marketing-typst/out/<lang>/<format>/<theme>/<slide>.svg`, ready to
drag-upload to the relevant ad manager.

Requires only Typst on PATH (or set `TYPST=path/to/typst`) — Typst exports
SVG natively, so there's no ImageMagick/PNG round-trip. The render runs in
seconds — no Docker, no browser, no Hugo.

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

### Why Plus Jakarta Sans (matching the website)

`marketing.toml` declares a single family:
- `fonts.primary = "Plus Jakarta Sans"` (body/UI text)

No `fonts.display` key — `tokens.typ` falls `display-font` back to
`primary` (see `tokens.typ:19`), so headlines and body share Plus Jakarta
Sans. The static weights in `marketing-typst/fonts/`
(`PlusJakartaSans-{Regular,Medium,SemiBold,Bold,ExtraBold}.ttf`) cover the
400–800 range the slides ask for via `weight:`.

Same family the website uses (`[params.typography].fontFamily` in
`hugo.toml`), so both surfaces render a visually identical "voice." To
swap the family: drop the new static TTFs into `marketing-typst/fonts/`,
update `fonts.primary` (and `fonts.primary_weights`) in `marketing.toml`,
and re-run `render.sh`.

### Why icons via Material Symbols Outlined

Slide 04-proof's feature panels use Material Symbols icons (the icon
font's name-to-glyph ligature mechanism — typing `"currency_exchange"`
with `features: ("liga": 1)` renders the corresponding glyph). The
static instance lives at `marketing-typst/fonts/MaterialSymbolsOutlined-Static.ttf`
(extracted from the variable font at `wght=400 FILL=0 GRAD=0 opsz=48`).

The slide-04 navigation arrow and the inline focal arrow on slide 01-hook
also use Material Symbols (`arrow_right_alt` ligature), so they pick up
the active palette's primary color automatically via `text(fill: primary)`.

## Sizing

`square/_layout.typ` carries a `SIZES` dict defining the type + spacing
scale for the 1080×1080 canvas. It was scaled down ~0.8× from the former
1080×1350 Instagram portrait layout, because the square canvas has ~270pt
less vertical room (~904pt usable inner height vs 1174pt) — the same copy
in a shorter box needs smaller headings and tighter gaps to fit.

| Format | Canvas | logo | h-xxl | h-l | padding (x / top / bottom) |
|---|---|---|---|---|---|
| square | 1080×1080 | 112pt | 84pt | 60pt | 72 / 64 / 72 |

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
