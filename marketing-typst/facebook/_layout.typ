// marketing-typst/facebook/_layout.typ
// Facebook 1200×630 page setup + shared chrome (header, footer).
//
// Each slide imports this and calls #setup() at the top, then uses
// #header(...) / #footer(...) helpers for the recurring chrome.

#import "../tokens.typ": *

// Page + text setup helpers. NOTE: `set page()` inside a function does NOT
// propagate to the document — set rules apply to the calling scope only.
// So each slide must invoke the set rules at top level. Use as:
//   #import "_layout.typ": *
//   #show: slide-setup
// The slide-setup show rule wraps the entire document body, applying the
// set rules at top level (which DOES propagate).
#let slide-setup(body) = {
  set page(width: 1200pt, height: 630pt, margin: 0pt, fill: surface)
  // top-edge: "ascender" / bottom-edge: "descender" makes the line box
  // include the full font metrics so descenders don't clip into the next
  // line below.
  set text(font: primary-font, fill: on-surface, size: 14pt,
    top-edge: "ascender", bottom-edge: "descender")
  set par(leading: 0.3em)

  // Slide-level decorative orbs — match Hugo's .slide::before (primary
  // 18% top-right) and .slide::after (surface-container-high 45% bottom-left).
  // Sizes from _partials/facebook/styles.html. They bleed off the canvas
  // edges so only a corner-arc is visible — present on every slide.
  place(top + right, dx: 100pt, dy: -120pt,
    circle(radius: 160pt, fill: primary.transparentize(82%)))
  place(bottom + left, dx: -100pt, dy: 160pt,
    circle(radius: 140pt, fill: surface-container-high.transparentize(55%)))

  body
}

// Theme-aware logo path
#let logo-src = if theme == "light" {
  "/static/assets/logos/logo-blue.svg"
} else {
  "/static/assets/logos/logo-white.svg"
}

// Muted on-surface — same intent as the old --c-on-surface-muted
// (35% transparent, slightly lighter in dark mode where 32% was used).
#let muted = on-surface.transparentize(35%)

// Header row — logo on the left, page indicator on the right.
// page-no is a 2-char string like "01", "02", … so the formatting stays
// stable across slides.
#let header(page-no, total: "05") = grid(
  columns: (1fr, auto),
  align: horizon,
  image(logo-src, height: 64pt),
  text(size: 14pt, weight: 800, tracking: 2pt, fill: muted)[
    #page-no / #total
  ],
)

// Footer — just "esio.dk".
#let footer() = text(size: 13pt, weight: 700, fill: muted)[esio.dk]

// Decorative orbs — background blob (large, primary-tinted) and
// foreground character art. Renders at page level so they sit behind
// the text content placed afterward.
#let bg-decoration(character-src) = {
  // Blob: opacity bumped to 25% (was 18%) for visible presence.
  place(
    bottom + right,
    dx: 110pt, dy: 130pt,
    circle(radius: 190pt, fill: primary.transparentize(75%)),
  )
  // Character: 340pt → 400pt for stronger lower-right anchoring.
  place(
    bottom + right,
    dx: 20pt, dy: 30pt,
    image(character-src, width: 400pt),
  )
}

// Card used on slide 02 (pain) — emoji glyph + bold title + body.
// Sizes trimmed slightly to accommodate the taller full-metric line box
// (top-edge: ascender, bottom-edge: descender) without overflowing the
// 534pt usable inner height.
#let card(icon, title, body-text) = block(
  fill: card-bg,
  stroke: 1pt + card-border,
  radius: 14pt,
  inset: (x: 16pt, y: 14pt),
  width: 100%,
)[
  #text(font: primary-font, size: 22pt)[#icon]
  #v(4pt, weak: true)
  #text(font: primary-font, size: 17pt, weight: 800, fill: on-surface)[#title]
  #v(4pt, weak: true)
  #text(font: primary-font, size: 12pt, weight: 500, fill: muted)[#body-text]
]

// Feature panel used on slide 04 — Material Symbols icon + title + body.
// The icon name (e.g. "currency_exchange") is rendered via the Material
// Symbols Outlined font's ligature substitution: with features ("liga": 1)
// the multi-character name resolves to a single glyph at compile time.
#let feature(icon-name, title, body-text) = block(
  fill: card-bg,
  stroke: 1pt + card-border,
  radius: 12pt,
  inset: 12pt,
  width: 100%,
)[
  #text(
    font: "Material Symbols Outlined",
    size: 28pt,
    fill: primary,
    features: ("liga": 1),
  )[#icon-name]
  #v(6pt, weak: true)
  #text(font: primary-font, size: 15pt, weight: 800, fill: on-surface)[#title]
  #v(4pt, weak: true)
  #text(font: primary-font, size: 11pt, weight: 500, fill: muted)[#body-text]
]

// CTA pill used on slide 05.
#let cta-pill(label) = box(
  fill: primary,
  inset: (x: 24pt, y: 12pt),
  radius: 999pt,
)[
  #text(font: primary-font, size: 20pt, weight: 800, fill: on-primary)[#label]
]

// Big arrow — for prominent inline use (e.g. slide 01-hook focal point).
// 4× the original 56pt for visual impact.
#let big-arrow() = text(
  font: "Material Symbols Outlined",
  size: 224pt,
  fill: primary,
  features: ("liga": 1),
)[arrow_right_alt]

// Smaller arrow for the footer-with-arrow rows on slides 02-04. The footer
// arrow is just a navigation hint between slides; back to Hugo's original
// 56pt so the cards above keep their full real estate.
#let foot-arrow() = text(
  font: "Material Symbols Outlined",
  size: 56pt,
  fill: primary,
  features: ("liga": 1),
)[arrow_right_alt]

// Foot variant for slides 02-04 — esio.dk on the left, foot arrow centered.
#let footer-with-arrow() = grid(
  columns: (1fr, auto, 1fr),
  align: (left + bottom, center + bottom, right + bottom),
  text(font: primary-font, size: 13pt, weight: 700, fill: muted)[esio.dk],
  foot-arrow(),
  [],
)
