// marketing-typst/square/_layout.typ
// Universal social slide — 1080×1080 square page setup + shared chrome.
//
// One square asset satisfies every social feed (Facebook, Instagram,
// LinkedIn), per the marketer's "mostly 1080×1080" brief. Replaces the
// former per-platform facebook/ (1200×630), instagram/ (1080×1350) and
// linkedin/ (1200×1200) layouts. The google-ads/ banners stay separate —
// their IAB dimensions are mandated and can't be square.
//
// Ported from the old instagram/_layout.typ (also 1080-wide). The type
// scale + spacing below are pulled in from that portrait layout because
// the square canvas has ~270pt less vertical room (904pt usable inner
// height vs 1174pt). If a slide overflows, Typst spills onto a 2nd page
// and the SVG export in render.sh errors — that's the fit check.

#import "../tokens.typ": *

// Size scale — scaled down ~0.8× from the 1080×1350 portrait layout to
// fit the shorter square canvas. Keep proportions consistent across slides.
#let SIZES = (
  h-xxl: 84pt,  h-xl: 70pt,  h-l: 60pt,  h-m: 44pt,  h-s: 30pt,
  eyebrow: 17pt, lede: 21pt, pageno: 18pt,
  logo: 112pt,
  pad-x: 72pt, pad-top: 64pt, pad-bottom: 72pt,
)

#let slide-setup(body) = {
  set page(width: 1080pt, height: 1080pt, margin: 0pt, fill: surface)
  // Full-metric line box (ascender to descender) — stops descenders
  // from clipping into the line below.
  set text(font: primary-font, fill: on-surface, size: 16pt,
    top-edge: "ascender", bottom-edge: "descender")
  set par(leading: 0.3em)

  // Slide-level decorative orbs — top-right primary + bottom-left elevation.
  place(top + right, dx: 160pt, dy: -180pt,
    circle(radius: 240pt, fill: primary.transparentize(82%)))
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
  columns: (1fr, auto),
  align: horizon,
  image(logo-src, height: SIZES.logo),
  text(font: primary-font, size: SIZES.pageno, weight: 800, tracking: 3pt, fill: muted)[
    #page-no / #total
  ],
)

#let footer() = text(font: primary-font, size: 18pt, weight: 700, fill: muted)[esio.dk]

#let bg-decoration(character-src) = {
  // Blob behind the character.
  place(
    bottom + right,
    dx: 140pt, dy: 160pt,
    circle(radius: 280pt, fill: primary.transparentize(75%)),
  )
  // Character focal element — trimmed from 620pt to fit the square canvas.
  place(
    bottom + right,
    dx: 40pt, dy: 60pt,
    image(character-src, width: 500pt),
  )
}

// Horizontal card (icon left, title+body right).
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

// Material Symbols `arrow_right_alt` ligature — focal point on 01-hook.
// Trimmed from the portrait layout's 216pt to fit the square canvas.
#let big-arrow() = text(
  font: "Material Symbols Outlined",
  size: 150pt,
  fill: primary,
  features: ("liga": 1),
)[arrow_right_alt]

// Footer arrow.
#let foot-arrow() = text(
  font: "Material Symbols Outlined",
  size: 64pt,
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
