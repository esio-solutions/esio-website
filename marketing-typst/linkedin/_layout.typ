// marketing-typst/linkedin/_layout.typ
// LinkedIn square — 1200×1200.

#import "../tokens.typ": *

// Size scale matches Hugo's _partials/linkedin/styles.html proportions
// (h-xxl 100px, logo 108px, padding 64/72/80, etc.).
#let SIZES = (
  h-xxl: 100pt, h-xl: 80pt, h-l: 64pt, h-m: 44pt, h-s: 28pt,
  eyebrow: 16pt, lede: 22pt, pageno: 18pt,
  logo: 108pt,
  pad-x: 72pt, pad-top: 64pt, pad-bottom: 80pt,
)

#let slide-setup(body) = {
  set page(width: 1200pt, height: 1200pt, margin: 0pt, fill: surface)
  set text(font: primary-font, fill: on-surface, size: 14pt,
    top-edge: "ascender", bottom-edge: "descender")
  set par(leading: 0.3em)

  // Slide-level decorative orbs — matches Hugo .slide::before (460pt
  // primary 18% top-right) and .slide::after (420pt surface-elev 45%
  // bottom-left). Sized for LinkedIn per _partials/linkedin/styles.html.
  place(top + right, dx: 140pt, dy: -160pt,
    circle(radius: 230pt, fill: primary.transparentize(82%)))
  place(bottom + left, dx: -120pt, dy: 200pt,
    circle(radius: 210pt, fill: surface-container-high.transparentize(55%)))

  body
}

#let logo-src = if theme == "light" {
  "/static/assets/logos/logo-blue.svg"
} else {
  "/static/assets/logos/logo-white.svg"
}

#let muted = on-surface.transparentize(35%)

#let header(page-no, total: "05") = grid(
  columns: (1fr, auto), align: horizon,
  image(logo-src, height: SIZES.logo),
  text(font: primary-font, size: SIZES.pageno, weight: 800, tracking: 2.8pt, fill: muted)[
    #page-no / #total
  ],
)

#let footer() = text(font: primary-font, size: 16pt, weight: 700, fill: muted)[esio.dk]

#let bg-decoration(character-src) = {
  // Blob: opacity 25% so it's visible behind the character.
  place(bottom + right, dx: 120pt, dy: 140pt,
    circle(radius: 280pt, fill: primary.transparentize(75%)))
  // Character: 460pt → 540pt to occupy more of the lower quadrant.
  place(bottom + right, dx: 30pt, dy: 40pt,
    image(character-src, width: 540pt))
}

#let card(icon, title, body-text) = block(
  fill: card-bg, stroke: 1pt + card-border, radius: 16pt,
  inset: 24pt, width: 100%,
)[
  #text(font: primary-font, size: 36pt)[#icon]
  #v(10pt, weak: true)
  #text(font: primary-font, size: 24pt, weight: 800, fill: on-surface)[#title]
  #v(8pt, weak: true)
  #text(font: primary-font, size: 18pt, weight: 500, fill: muted)[#body-text]
]

#let feature(icon-name, title, body-text) = block(
  fill: card-bg, stroke: 1pt + card-border, radius: 14pt,
  inset: 20pt, width: 100%,
)[
  #text(font: "Material Symbols Outlined", size: 44pt, fill: primary,
    features: ("liga": 1))[#icon-name]
  #v(12pt, weak: true)
  #text(font: primary-font, size: 22pt, weight: 800, fill: on-surface)[#title]
  #v(6pt, weak: true)
  #text(font: primary-font, size: 16pt, weight: 500, fill: muted)[#body-text]
]

#let cta-pill(label) = box(
  fill: primary, inset: (x: 32pt, y: 16pt), radius: 999pt,
)[
  #text(font: primary-font, size: 26pt, weight: 800, fill: on-primary)[#label]
]

// Material Symbols `arrow_right_alt` ligature — sized for LinkedIn's
// square canvas.
// Big inline arrow — 4× the original 64pt for prominent use.
#let big-arrow() = text(
  font: "Material Symbols Outlined",
  size: 256pt,
  fill: primary,
  features: ("liga": 1),
)[arrow_right_alt]

// Footer arrow — back to Hugo's original 64pt so the cards above keep
// their full vertical real estate.
#let foot-arrow() = text(
  font: "Material Symbols Outlined",
  size: 64pt,
  fill: primary,
  features: ("liga": 1),
)[arrow_right_alt]

#let footer-with-arrow() = grid(
  columns: (1fr, auto, 1fr),
  align: (left + bottom, center + bottom, right + bottom),
  text(font: primary-font, size: 16pt, weight: 700, fill: muted)[esio.dk],
  foot-arrow(),
  [],
)
