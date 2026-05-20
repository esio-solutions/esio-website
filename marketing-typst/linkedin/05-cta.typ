#import "_layout.typ": *
#show: slide-setup

#let sub = yaml("/marketing-typst/data/" + lang + "/subscribe/meta.yml")

#bg-decoration("/static/assets/characters/characters-03-gradient.svg")

#pad(left: SIZES.pad-x, right: SIZES.pad-x, top: SIZES.pad-top, bottom: SIZES.pad-bottom)[
  #header("05")
  #v(56pt)
  #block(width: 820pt)[
    #text(font: primary-font, size: SIZES.eyebrow, weight: 800, tracking: 0.12em, fill: primary)[#upper(sub.tag)]
    #v(14pt, weak: true)
    #text(font: display-font, size: SIZES.h-xl, weight: 900, tracking: -2.8pt)[#sub.headline.prefix]\
    #text(font: display-font, size: SIZES.h-xl, weight: 900, tracking: -2.8pt, fill: primary)[#sub.headline.suffix.]
    #v(40pt, weak: true)
    #block(width: 660pt)[
      #text(font: primary-font, size: SIZES.lede, weight: 500, fill: muted)[#sub.body]
    ]
    #v(48pt, weak: true)
    #cta-pill(sub.formBox.cta.label)
  ]
  #v(1fr)
  #footer()
]
