// marketing-typst/facebook/03-solution.typ
// Slide 3 of 5 — the solution: multi-line headline + paragraph + character.

#import "_layout.typ": *

#show: slide-setup

#let how = yaml("/marketing-typst/data/" + lang + "/how/meta.yml")
#let lines = how.headline.split("\n")

// Character art (bottom-right, no blob behind on this slide per Hugo source)
#place(
  bottom + right,
  dx: 10pt, dy: 30pt,
  image("/static/assets/characters/characters-04-gradient.svg", width: 320pt),
)

#pad(x: 56pt, y: 48pt)[
  #header("03")

  #v(16pt, weak: true)

  // Body — eyebrow + multi-line headline (last line in primary) + subtitle
  #block(width: 760pt)[
    #text(font: primary-font, size: 13pt, weight: 800, tracking: 0.12em, fill: primary)[#upper(how.tag)]
    #v(10pt, weak: true)

    #for (i, line) in lines.enumerate() [
      #let is-last = i == lines.len() - 1
      #if is-last [
        #text(font: display-font, size: 44pt, weight: 900, tracking: -1.5pt, fill: primary)[#line]\
      ] else [
        #text(font: display-font, size: 44pt, weight: 900, tracking: -1.5pt)[#line]\
      ]
    ]

    #v(12pt, weak: true)
    #block(width: 560pt)[
      #text(font: primary-font, size: 18pt, weight: 500, fill: muted)[#how.subtitle]
    ]
  ]

  #v(1fr)

  #footer-with-arrow()
]
