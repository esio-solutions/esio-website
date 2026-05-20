// 320×50 — Mobile leaderboard
#import "_layout.typ": *
#show: setup-page(320pt, 50pt)

#let hero = yaml("/marketing-typst/data/" + lang + "/hero/meta.yml")
#let parts = hero.tagline.split(", ")
#let humanize(s) = upper(s.slice(0, 1)) + s.slice(1)
#let title-a = humanize(parts.at(0)) + "."
#let title-b = humanize(parts.at(1)) + "."
#let cta-label = hero.actions.at(0).label

#pad(x: 10pt, y: 6pt)[
  #grid(
    columns: (auto, 1fr, auto),
    align: horizon,
    column-gutter: 8pt,
    image(logo-src, height: 22pt),
    // Tight banner — title in 2 stacked lines so it fits horizontally
    [
      #text(font: primary-font, size: 10pt, weight: 800, tracking: -0.1pt)[
        #title-a\
        #text(fill: primary)[#title-b]
      ]
    ],
    cta-pill(cta-label, size: 9pt, pad-x: 7pt, pad-y: 4pt),
  )
]
