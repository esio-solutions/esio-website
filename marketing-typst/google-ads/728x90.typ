// 728×90 — Leaderboard
#import "_layout.typ": *
#show: setup-page(728pt, 90pt)

#let hero = yaml("/marketing-typst/data/" + lang + "/hero/meta.yml")
#let parts = hero.tagline.split(", ")
#let humanize(s) = upper(s.slice(0, 1)) + s.slice(1)
#let title-a = humanize(parts.at(0)) + "."
#let title-b = humanize(parts.at(1)) + "."
#let cta-label = hero.actions.at(0).label

#orb(top + right, 70pt, dx: 0pt, dy: -30pt, opacity: 16%)

#pad(x: 20pt, y: 14pt)[
  #grid(
    columns: (auto, 1fr, auto),
    align: horizon,
    column-gutter: 24pt,
    image(logo-src, height: 44pt),
    [
      #text(font: primary-font, size: 24pt, weight: 800, tracking: -0.3pt)[#title-a #text(fill: primary)[#title-b]]
    ],
    cta-pill(cta-label, size: 16pt, pad-x: 18pt, pad-y: 10pt),
  )
]
