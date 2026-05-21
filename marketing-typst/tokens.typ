// marketing-typst/tokens.typ
// ─────────────────────────────────────────────────────────────────────────────
// Shared palette + font config for ad templates.
//
// Reads:
//   - data/marketing.toml             — pinned palette + font config
//   - themes/.../m3/<palette>/<mode>.json  — M3 design tokens
//
// Theme (light/dark) selected via Typst's --input flag at render time:
//   typst compile slide.typ out.png --root . --input theme=dark
// Defaults to "light" if --input theme is not provided.
//
// Language (en/da) selected via --input lang=<lang> — consumed in slide
// modules to choose the right data/<lang>/index/... file, not here.
// ─────────────────────────────────────────────────────────────────────────────

#let marketing = toml("/marketing-typst/marketing.toml")
#let primary-font = marketing.fonts.primary
#let display-font = marketing.fonts.at("display", default: marketing.fonts.primary)

// Render-time inputs. --input palette=<name> overrides marketing.toml when
// supplied — used by the palette-comparison script to render every M3 folder
// without rewriting marketing.toml each iteration.
#let theme = sys.inputs.at("theme", default: "light")
#let lang  = sys.inputs.at("lang",  default: "en")
#let palette-name = sys.inputs.at("palette", default: marketing.palette)

// Load M3 tokens for the active theme.
#let palette = json("/themes/esio-theme/assets/css/m3/" + palette-name + "/" + theme + ".json")

// Helper — keys in the JSON are kebab-case; Typst dict access via .at()
// avoids ambiguity with hyphen parsing.
#let c(k) = rgb(palette.at(k))

// Named constants matching M3 role names (kebab → use dashes here too).
#let primary                    = c("primary")
#let on-primary                 = c("on-primary")
#let primary-container          = c("primary-container")
#let on-primary-container       = c("on-primary-container")
#let primary-fixed              = c("primary-fixed")
#let on-primary-fixed           = c("on-primary-fixed")

#let secondary                  = c("secondary")
#let on-secondary               = c("on-secondary")
#let secondary-container        = c("secondary-container")
#let on-secondary-container     = c("on-secondary-container")

#let tertiary                   = c("tertiary")
#let on-tertiary                = c("on-tertiary")
#let tertiary-container         = c("tertiary-container")
#let on-tertiary-container      = c("on-tertiary-container")

#let surface                    = c("surface")
#let on-surface                 = c("on-surface")
#let surface-variant            = c("surface-variant")
#let on-surface-variant         = c("on-surface-variant")
#let surface-dim                = c("surface-dim")
#let surface-bright             = c("surface-bright")
#let surface-container          = c("surface-container")
#let surface-container-low      = c("surface-container-low")
#let surface-container-high     = c("surface-container-high")
#let surface-container-highest  = c("surface-container-highest")
#let surface-container-lowest   = c("surface-container-lowest")

#let outline                    = c("outline")
#let outline-variant            = c("outline-variant")

#let error-color                = c("error")
#let on-error                   = c("on-error")

// Convenience aliases matching the ad templates' previous --c-* names.
// Card background: in light mode, surface-dim reads better than container-high.
#let card-bg = if theme == "light" { surface-dim } else { surface-container-high }
#let card-border = outline-variant
