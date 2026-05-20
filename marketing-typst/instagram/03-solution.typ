#import "_layout.typ": *
#show: slide-setup

#let how = yaml("/marketing-typst/data/" + lang + "/how/meta.yml")
#let lines = how.headline.split("\n")

#place(
  bottom + right,
  dx: 40pt, dy: 80pt,
  image("/static/assets/characters/characters-04-gradient.svg", width: 580pt),
)

#pad(left: SIZES.pad-x, right: SIZES.pad-x, top: SIZES.pad-top, bottom: SIZES.pad-bottom)[
  #header("03")
  #v(56pt)

  #block(width: 880pt)[
    #text(font: primary-font, size: SIZES.eyebrow, weight: 800, tracking: 0.12em, fill: primary)[#upper(how.tag)]
    #v(18pt, weak: true)
    #for (i, line) in lines.enumerate() [
      #let is-last = i == lines.len() - 1
      #if is-last [
        #text(font: display-font, size: SIZES.h-xl, weight: 900, tracking: -3pt, fill: primary)[#line]\
      ] else [
        #text(font: display-font, size: SIZES.h-xl, weight: 900, tracking: -3pt)[#line]\
      ]
    ]
    #v(48pt, weak: true)
    #block(width: 780pt)[
      #text(font: primary-font, size: SIZES.lede, weight: 500, fill: muted)[#how.subtitle]
    ]
  ]

  #v(1fr)
  #footer-with-arrow()
]
