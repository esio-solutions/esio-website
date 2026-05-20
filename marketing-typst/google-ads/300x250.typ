// 300×250 — Medium Rectangle
#import "_layout.typ": *
#show: setup-page(300pt, 250pt)

#let hero = yaml("/marketing-typst/data/" + lang + "/hero/meta.yml")
#let parts = hero.tagline.split(", ")
#let humanize(s) = upper(s.slice(0, 1)) + s.slice(1)
#let title-a = humanize(parts.at(0)) + "."
#let title-b = humanize(parts.at(1)) + "."
#let cta-label = hero.actions.at(0).label

// Decorative orb top-right
#orb(top + right, 80pt, dx: 60pt, dy: -70pt)

#pad(18pt)[
  #image(logo-src, height: 28pt)
  #v(14pt, weak: true)
  #text(font: primary-font, size: 26pt, weight: 800, tracking: -0.5pt)[#title-a]\
  #text(font: primary-font, size: 26pt, weight: 800, tracking: -0.5pt, fill: primary)[#title-b]
  #v(1fr)
  #cta-pill(cta-label)
]
