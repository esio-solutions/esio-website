// marketing-typst/instagram/_layout.typ
// Instagram carousel — 1080×1350 portrait page setup + shared chrome.

#import "../tokens.typ": *

// Size scale matches Hugo's _partials/instagram/styles.html proportions
// (h-xxl 108px, logo 144px, padding 80/80/96, etc.). Keep these in sync
// with the Hugo source when porting tweaks back-and-forth — they define
// the visual grammar of the platform.
#let SIZES = (
  h-xxl: 108pt,  h-xl: 88pt,  h-l: 76pt,  h-m: 52pt,  h-s: 34pt,
  eyebrow: 18pt, lede: 24pt, pageno: 20pt,
  logo: 144pt,
  pad-x: 80pt, pad-top: 80pt, pad-bottom: 96pt,
)

#let slide-setup(body) = {
  set page(width: 1080pt, height: 1350pt, margin: 0pt, fill: surface)
  // Full-metric line box (ascender to descender) — stops descenders
  // from clipping into the line below.
  set text(font: primary-font, fill: on-surface, size: 16pt,
    top-edge: "ascender", bottom-edge: "descender")
  set par(leading: 0.3em)

  // Slide-level decorative orbs — matches Hugo .slide::before (520pt
  // primary 18% top-right) and .slide::after (460pt surface-elev 45%
  // bottom-left). Sized for Instagram per _partials/instagram/styles.html.
  place(top + right, dx: 160pt, dy: -180pt,
    circle(radius: 260pt, fill: primary.transparentize(82%)))
  place(bottom + left, dx: -120pt, dy: 220pt,
    circle(radius: 230pt, fill: surface-container-high.transparentize(55%)))

  body
}

#let logo-src = if theme == "light" {
  "/static/assets/logos/logo-blue.svg"
} else {
  "/static/assets/logos/logo-white.svg"
}

#let muted = on-surface.transparentize(35%)

#let header(page-no, total: "05") = grid(
  columns: (1fr, auto),
  align: horizon,
  image(logo-src, height: SIZES.logo),
  text(font: primary-font, size: SIZES.pageno, weight: 800, tracking: 3pt, fill: muted)[
    #page-no / #total
  ],
)

#let footer() = text(font: primary-font, size: 18pt, weight: 700, fill: muted)[esio.dk]

#let bg-decoration(character-src) = {
  // Blob: bumped opacity from 18% to 25% so it's actually perceptible.
  place(
    bottom + right,
    dx: 140pt, dy: 160pt,
    circle(radius: 320pt, fill: primary.transparentize(75%)),
  )
  // Character: 520pt → 620pt so it reads as a focal element, not
  // a corner accent.
  place(
    bottom + right,
    dx: 40pt, dy: 60pt,
    image(character-src, width: 620pt),
  )
}

// Horizontal card for instagram (icon left, title+body right). Sizes
// trimmed for the taller full-metric line box.
#let h-card(icon, title, body-text) = block(
  fill: card-bg,
  stroke: 1pt + card-border,
  radius: 18pt,
  inset: (x: 26pt, y: 20pt),
  width: 100%,
)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 20pt,
    align: top + left,
    text(font: primary-font, size: 36pt)[#icon],
    [
      #text(font: primary-font, size: 22pt, weight: 800, fill: on-surface)[#title]
      #v(4pt, weak: true)
      #text(font: primary-font, size: 13pt, weight: 500, fill: muted)[#body-text]
    ],
  )
]

#let feature(icon-name, title, body-text) = block(
  fill: card-bg,
  stroke: 1pt + card-border,
  radius: 14pt,
  inset: 18pt,
  width: 100%,
)[
  #text(
    font: "Material Symbols Outlined",
    size: 40pt,
    fill: primary,
    features: ("liga": 1),
  )[#icon-name]
  #v(8pt, weak: true)
  #text(font: primary-font, size: 20pt, weight: 800, fill: on-surface)[#title]
  #v(4pt, weak: true)
  #text(font: primary-font, size: 11pt, weight: 500, fill: muted)[#body-text]
]

#let cta-pill(label) = box(
  fill: primary,
  inset: (x: 40pt, y: 20pt),
  radius: 999pt,
)[
  #text(font: primary-font, size: 32pt, weight: 800, fill: on-primary)[#label]
]

// Material Symbols `arrow_right_alt` ligature — sized for Instagram's
// larger portrait canvas.
// Big inline arrow (focal point on 01-hook) — 3× the original 72pt;
// 4× pushed the Danish 01-hook past the canvas height.
#let big-arrow() = text(
  font: "Material Symbols Outlined",
  size: 216pt,
  fill: primary,
  features: ("liga": 1),
)[arrow_right_alt]

// Footer arrow — back to Hugo's original 72pt so the cards above keep
// their full vertical real estate.
#let foot-arrow() = text(
  font: "Material Symbols Outlined",
  size: 72pt,
  fill: primary,
  features: ("liga": 1),
)[arrow_right_alt]

#let footer-with-arrow() = grid(
  columns: (1fr, auto, 1fr),
  align: (left + bottom, center + bottom, right + bottom),
  text(font: primary-font, size: 18pt, weight: 700, fill: muted)[esio.dk],
  foot-arrow(),
  [],
)
