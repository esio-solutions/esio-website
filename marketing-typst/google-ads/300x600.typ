// 300×600 — Half-page
#import "_layout.typ": *
#show: setup-page(300pt, 600pt)

#let hero = yaml("/marketing-typst/data/" + lang + "/hero/meta.yml")
#let parts = hero.tagline.split(", ")
#let humanize(s) = upper(s.slice(0, 1)) + s.slice(1)
#let title-a = humanize(parts.at(0)) + "."
#let title-b = humanize(parts.at(1)) + "."
#let cta-label = hero.actions.at(0).label

// Two orbs — top-right and bottom-left (decorative pair like the original)
#orb(top + right, 120pt, dx: 100pt, dy: -120pt, opacity: 18%)
#orb(bottom + left, 100pt, dx: -80pt, dy: 100pt, opacity: 25%)

#pad(22pt)[
  #image(logo-src, height: 32pt)
  #v(18pt, weak: true)
  #text(font: primary-font, size: 11pt, weight: 800, tracking: 2.4pt, fill: primary)[#upper(hero.headline.emphasis + " " + hero.headline.suffix)]
  #v(8pt, weak: true)
  #text(font: primary-font, size: 38pt, weight: 800, tracking: -1pt)[#title-a]\
  #text(font: primary-font, size: 38pt, weight: 800, tracking: -1pt, fill: primary)[#title-b]
  #v(1fr)
  #cta-pill(cta-label, size: 14pt, pad-x: 14pt, pad-y: 8pt)
]
