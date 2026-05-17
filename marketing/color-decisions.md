# Colour & Theme Decisions

Short-form log of the colour-system decisions made during the May 2026 cleanup pass on the marketing site.

## Context

The theme system had grown to 11 themes during palette exploration. The "Dark" theme is the designer's canonical brand; the rest were mood explorations that read as paint-chip names (skincare, agency, lifestyle) rather than legitimate UI modes for a B2B budgeting tool. The index page traversed 7 distinct background hexes per scroll, with the features section alone cycling through 5 panel pastels. SVG illustrations had hardcoded brand hex values that didn't follow theme switches.

---

## Decisions

### 1. Pruned themes: 11 → 3
- **Dark** (default) — canonical brand, navy + terra.
- **Light** — daytime variant of the same brand (white surface, navy text, terra accents preserved). `primaryContainer` rebuilt from `terraPale` → `terraLight` so tinted backgrounds had contrast against `surfaceDim` (also terraPale).
- **App preview** (renamed from `esio-budget`) — mirrors the in-app Radzen palette (blue + slate). Lets visitors preview the live product UI.
- **Removed:** modern-pro, tech-forward, cultivated-warmth, timeless-confidence, summer-fun, sunrise-glow, twilight-comfort, electric-citrus.

**Why:** Each removed theme targeted a different audience (wellness, agency, fintech-bro). Mixing them into a financial-software brand undermined positioning. Production B2B sites typically ship 1-3 themes; the picker was reading as *"we couldn't decide"*. Light + Dark + a product-preview slot covers every legitimate user need.

### 2. Page background colours: 7 → 4
Dark-theme section backgrounds collapsed to **navy / navyDark / navyMid / terra**. The features strip now alternates between navy and navyMid (two-tone rhythm) instead of cycling through 5 distinct pastels.

**Why:** Material 3 caps surface tokens around 4-5 because that's what the eye reads as *structural* before colour starts competing as *content*. With 5 panel pastels, the features strip competed with its own illustrations and copy. Two-tone alternation reads as rhythm rather than kaleidoscope.

### 3. Dropped the purple brand-lock
`#features { --features-bg: var(--color-purple); … }` — five scoped vars, none consumed by any rule. A vestigial brand-lock that didn't actually appear on the page.

**Why:** Even when dead code, a brand-lock signals intent. The features section now draws backgrounds from the surface system like every other section. `purple` survives in the palette for spot uses (decorative avatars, how-steps gradient endpoint) — appropriate as a *brand-locked accent*, not a section background.

### 4. Per-panel text-colour rules: 5 → 1
Five `.fp-N .fp-title` rules (each hardcoding a different colour) collapsed to one universal `.fp-title, .fp-desc { color: var(--color-on-surface) }`.

**Why:** Once panel backgrounds collapse to the surface family, on-surface gives the right contrast for *every* panel in *every* theme. No exceptions needed.

### 5. Pruned brand-palette tokens
- **Removed:** `panelLavender`, `panelSteel`, `panelPeriwinkle` (no longer referenced after the features-panel collapse).
- **Removed:** `ebPrimaryDark`, `ebSecondaryDark` (declared but never consumed — over-specification from the Radzen import).
- **Kept:** all multiple navy/terra shades (designer-chosen tonal depths) and the `eb*` colours that have legitimate consumers.

**Why:** Brand tokens earn their place by being *consumed*. Tokens that aren't are scaffolding the design system carries without benefit.

### 6. SVG theming: identity-only, not structural
The `svg/inline.html` partial does build-time hex → CSS-var substitution for **brand-accent** colours only:
- `#E07B5B → var(--color-primary)`
- `#F37C5A → var(--color-primary)`
- `#FAE8DF → color-mix(in srgb, var(--color-primary), white 85%)`

Structural-dark colours (`#1B2B6B`, `#464E58`) stay **literal**.

**Why:** The first attempt mapped `#1B2B6B → var(--color-on-surface)` — which made navy structural lines flip to *white* in the Dark theme, disappearing into the SVG's own literal-white browser-frame interiors. The conceptual error: navy inside these illustrations represents *dark ink on the illustration's own white interior*, not *text on the theme's surface*. Those are two different surfaces; only one of them flips with the theme.

---

## Principles established

### Brand colour ≠ semantic colour
- **Brand colours** (`navy = "#1B2B6B"`) are paint chips. Stable across themes. Live in `hugo.toml [params.colors]`.
- **Semantic colours** (`surface`, `primary`, `onSurface`) are role slots. Resolve to different brand colours per theme. Live in `hugo.toml [params.theme.X]`.
- CSS should reference semantic tokens. Brand-direct references are *brand-locks* — UI that won't follow the theme.

### Each theme has a 4-colour signature
| Theme | Signature |
|---|---|
| Dark | navy + terra + white + a panel accent |
| Light | white + navyDark + terra + a panel accent |
| App preview | ebPrimary + ebSecondary + ebBaseLight + ebOnBase |

The other tokens each theme touches are *functional derivatives* (depth, hover containers, soft tints) — infrastructure, not branding. The "4 colours" metric is about *identity*, not about token-count parity with Material 3's full slot set.

### Two kinds of SVG theming
1. **Identity theming** — accents that carry brand meaning (CTAs, focal callouts) follow the theme primary because the meaning travels with the theme.
2. **Contrast preservation** — structural ink/lines that need to stay legible against a *fixed-by-design* surface (an SVG's own white interior) must NOT follow theme tokens designed for the host page's surfaces.

The substitution map serves identity theming only; contrast preservation is achieved by leaving values literal.

### When to use which SVG-rendering technique
| Use case | Technique | Where it's applied |
|---|---|---|
| Monochrome glyph that should follow theme | CSS `mask` | `esio-icon01..05`, features intro grid |
| Multi-colour illustration with brand accents | Inline `<svg>` + `var(--color-*)` substitution | `chart-bg.svg`, 7× `marketing/0N-*.svg` |
| Brand-locked or character art | Plain `<img src>` with literal hex | `characters-01..06.svg`, logos |

---

## What's still open

- **The how-steps gradient** (`background: linear-gradient(…, var(--how-accent), var(--color-purple))`) — still references `--color-purple` directly. Minor brand-lock; not yet decided whether to theme.
- **Algorithmic shade derivation** — Dark and App-preview could potentially drop to 4-6 source brand tokens by computing depth/state variants via `color-mix()` instead of hand-picking `navyDark/navyMid/terraDark/etc.` That refactor would touch `styles.css` and trade designer-chosen tonal precision for a smaller palette. Deferred.
- **Orphan illustration SVGs** (`features-01/03/06/08.svg`) — not consumed anywhere; left in `static/assets/illustrations/` pending a decision on whether they'll be wired up or deleted.

---

## Addendum: Status colours imported from the app

Per the description analysis, a budgeting tool needs status colours (positive variance, loss, deadline, info) that the marketing palette didn't have. Rather than invent these, they're imported verbatim from `EsioBudget.WebApp/wwwroot/css/site.css` so the marketing site and live product share one status vocabulary.

### Added to `[params.colors]`

```toml
success = "#386A20"   # forest green (--rz-success)   — positive variance, on-track, growth
danger  = "#b3261e"   # deep red    (--rz-danger)    — losses, overdue, error states
warning = "#e8e971"   # citrus pale (--rz-warning)   — caution, VAT deadlines, review needed
info    = "#085786"   # deep blue   (--rz-info)      — neutral notices, informational banners
```

### Architecture

- **CSS-direct** (not theme-aware) — a positive number should always look positive, regardless of which theme is active. They live in `[params.colors]` but not in any `[params.theme.X]` block.
- **Tailwind v4 tree-shakes unreferenced `@theme` tokens**, so `themes/esio-theme/assets/css/esio.css` exposes them via `.status-{success,danger,warning,info}` utility classes. The classes pin the tokens in the compiled CSS *and* give consumers a public API.
- **Why not just rebrand my earlier sage/rust/amber proposal**: I'd guessed `sage #7BA889` and `rust #C4604D`; the app's actual `#386A20` and `#b3261e` are deeper and more authoritative. Pulling values directly from the source removes a "wait, does this match the app?" friction point and guarantees the two products read as one family.

### Existing `yellow` kept (different role from `warning`)

`yellow #F5C842` is a saturated attention-grabber used on the pricing "Most Popular" badge. `warning #e8e971` is a paler, status-caution citrus from the app. They're different visual signals — marketing-attention vs app-domain-caution — so both stay rather than collapsing into one.

### Accessibility note

`warning #e8e971` is light enough to fail WCAG AA as text on white (~1.5:1 contrast). Use it as a *background* for caution badges (paired with `--color-on-surface` for the text), not as text colour on light surfaces. If a caution-text role appears later, import `--rz-warning-dark #918908` from the app.

### Variants available in source but not yet imported

The app defines light/dark/darker shades for each status family (e.g., `--rz-success-light #c0ffaa`, `--rz-success-dark #3e9108`, `--rz-success-darker #194100`). Imported on-demand if a consumer rule needs them — keeps the marketing palette tight.

---

## Addendum: The icon-set problem (origins + path forward)

The five `esio-iconNN.svg` files used in the Features section (intro panel grid + previously as panel-mask silhouettes) are **incoherent as a set**. They look like they were drawn by different people because, effectively, they were.

### What was found

Forensic audit of the originals:

| File | Path count | Visual character |
|---|---|---|
| `esio-icon01` | 1 monolithic merged path | Composite scene (document + chart + magnifier) |
| `esio-icon02` | 24 paths | Money-cycle with currency notes + chart |
| `esio-icon03` | 41 paths | TAX form + calculator + pen |
| `esio-icon04` | 5 paths | Profile card (unused orphan) |
| `esio-icon05` | 14 paths | Calendar grid + dollar callout |

All five were exported from Adobe Illustrator 30.2.1 (early 2025) on the same `1920×1080` artboard, with the default `.st0` class naming. There's no shared grid, no shared stroke weight, no shared visual heft. A coherent icon set has paths-per-icon within a narrow range (typically 1-5); ranging from 1 to 41 is the geometric fingerprint of **individual illustrations drawn one at a time**, not a system.

### Why this happened

Most likely commissioned/in-house designer work where each icon was treated as its own illustration rather than as part of a system. Indicators:

- **HD-frame artboard (1920×1080)** — icon library work uses 24×24 or 16×16 grids; an HD canvas is illustration-scale.
- **All-`.st0` monochrome class** — exporter default, no styling discipline applied.
- **Default Illustrator output** with no metadata fields populated (no `<title>`, `<desc>`, `<metadata>`, RDF, or Dublin Core).
- **Path-count range 1–41** spanning more than an order of magnitude — discipline icon sets vary at most 2-3×.

Git trail dead-ends at the initial commit (2026-05-03, authored by iustinian). Before that, the files presumably lived as Illustrator masters on the designer's machine.

### Why it matters for the marketing site

- **Brand cohesion**: when icons next to each other have visibly different stroke weight, density, and visual heft, the page reads as *"this is a Frankenstein"* even if every other design decision is tight. Icons are surfaces visitors scan rapidly; inconsistency there scores high on the "this product is unpolished" intuition.
- **Theme/mask treatment can't repair geometry**: this session went through CSS-mask + primary-colour theming (which unified colour) then a Lucide swap (which unified line-weight) — neither survived contact with the use case. Mask unifies hue but not shape; Lucide unifies line-weight but not subject matter. **Whatever the icons should be has to be decided at *source-art* level**, not via downstream styling.
- **One-asset-two-roles compounds the problem**: the same files were consumed by the intro grid (small 110×110 — icon scale) and the per-panel mask silhouette (~600×600 — decoration scale). Any single design choice fails one role. The silhouette role was removed; the intro grid role remains and needs a coherent icon set.

### Current state

The originals have been parked in `assets/icons/old/` (un-referenced, preserved in git history for reference or rollback). The marketing site's intro grid renders empty until replacements are installed.

### Path forward — Material Symbols

The intended replacement is **Material Symbols** (Google's Material 3 icon family, Apache 2.0 licensed). Reasons:

- **Discipline**: every glyph designed on a 24×24 grid with a fixed stroke weight, weight axis (100-700), grade axis, optical size axis. The visual variance any two icons can have is bounded by design.
- **Brand alignment**: ESIO's CSS uses Material 3 semantic tokens (`--color-surface`, `--color-primary`, `--color-on-surface`, etc.). Material 3 icons share the same design language.
- **Style options**: Outlined (light/airy), Rounded (soft corners), Sharp (rigid). Each in Fill 0 or Fill 1. Fill 1 Rounded is the closest match to the original's "filled scene" visual heft while being part of a real system.
- **Theme-friendly**: as monochrome SVGs they slot directly into the existing CSS-mask + `var(--color-primary)` background-paint pattern.

The current ICON pipeline is now:
- Files in `assets/icons/` (Hugo asset pipeline with content-hashed URLs — `resources.Fingerprint`)
- Consumed by `themes/esio-theme/layouts/_partials/sections/features.html` intro grid via `resources.Get`
- Cache-busts on file change (the URL hash changes), so visual updates land immediately

When the replacement Material Symbols icons are dropped into `assets/icons/`, they'll inherit this pipeline automatically.
