// marketing-typst/google-ads/_layout.typ
// Google Display banners — shared helpers. Each banner sets its own page
// size since the Google Display formats vary (300×250, 728×90, etc.).

#import "../tokens.typ": *

#let setup-page(width, height) = {
  // Returns a show rule for use as `#show: setup-page(300pt, 250pt)`.
  body => {
    set page(width: width, height: height, margin: 0pt, fill: surface)
    set text(font: primary-font, fill: on-surface)
    set par(leading: 0.5em)
    body
  }
}

#let logo-src = if theme == "light" {
  "/static/assets/logos/logo-blue.svg"
} else {
  "/static/assets/logos/logo-white.svg"
}

// Small CTA pill — sizes parameterised because banners vary widely.
#let cta-pill(label, size: 14pt, pad-x: 14pt, pad-y: 8pt) = box(
  fill: primary,
  inset: (x: pad-x, y: pad-y),
  radius: 999pt,
)[
  #text(font: primary-font, size: size, weight: 800, fill: on-primary)[#label →]
]

// Small decorative orb — primary-tinted circle. Returns a `place(...)` call.
#let orb(pos, radius, dx: 0pt, dy: 0pt, opacity: 18%) = place(
  pos, dx: dx, dy: dy,
  circle(radius: radius, fill: primary.transparentize(100% - opacity)),
)
