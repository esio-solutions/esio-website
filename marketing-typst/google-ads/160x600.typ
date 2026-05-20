// 160×600 — Wide Skyscraper
#import "_layout.typ": *
#show: setup-page(160pt, 600pt)

#let hero = yaml("/marketing-typst/data/" + lang + "/hero/meta.yml")
#let parts = hero.tagline.split(", ")
#let humanize(s) = upper(s.slice(0, 1)) + s.slice(1)
#let title-a = humanize(parts.at(0)) + "."
#let title-b = humanize(parts.at(1)) + "."
#let cta-label = hero.actions.at(0).label

#orb(top + right, 80pt, dx: 60pt, dy: -80pt)

#pad(x: 12pt, y: 14pt)[
  #image(logo-src, height: 24pt)
  #v(14pt, weak: true)
  #text(font: primary-font, size: 22pt, weight: 800, tracking: -0.4pt)[#title-a]\
  #v(6pt, weak: true)
  #text(font: primary-font, size: 22pt, weight: 800, tracking: -0.4pt, fill: primary)[#title-b]
  #v(1fr)
  #cta-pill(cta-label, size: 12pt, pad-x: 10pt, pad-y: 6pt)
]
