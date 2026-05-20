// marketing-typst/facebook/05-cta.typ
// Slide 5 of 5 — call-to-action: prompt + button + character.

#import "_layout.typ": *

#show: slide-setup

#let sub = yaml("/marketing-typst/data/" + lang + "/subscribe/meta.yml")

// Decorative background — blob + character art (same pattern as slide 01)
#bg-decoration("/static/assets/characters/characters-03-gradient.svg")

#pad(x: 56pt, y: 48pt)[
  #header("05")

  #v(16pt, weak: true)

  #block(width: 720pt)[
    #text(font: primary-font, size: 13pt, weight: 800, tracking: 0.12em, fill: primary)[#upper(sub.tag)]
    #v(10pt, weak: true)
    #text(font: display-font, size: 56pt, weight: 900, tracking: -1.5pt)[#sub.headline.prefix]\
    #text(font: display-font, size: 56pt, weight: 900, tracking: -1.5pt, fill: primary)[#sub.headline.suffix.]

    #v(12pt, weak: true)
    #block(width: 560pt)[
      #text(font: primary-font, size: 18pt, weight: 500, fill: muted)[#sub.body]
    ]

    #v(16pt, weak: true)
    #cta-pill(sub.formBox.cta.label)
  ]

  #v(1fr)

  #footer()
]
