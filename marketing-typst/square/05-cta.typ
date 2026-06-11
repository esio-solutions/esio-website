// marketing-typst/square/05-cta.typ — square CTA slide (1080×1080).

#import "_layout.typ": *
#show: slide-setup

#let sub = yaml("/marketing-typst/data/" + lang + "/subscribe/meta.yml")

#bg-decoration("/static/assets/characters/characters-03-gradient.svg")

#pad(left: SIZES.pad-x, right: SIZES.pad-x, top: SIZES.pad-top, bottom: SIZES.pad-bottom)[
  #header("05")
  #v(40pt)

  #block(width: 780pt)[
    #text(font: primary-font, size: SIZES.eyebrow, weight: 800, tracking: 0.12em, fill: primary)[#upper(sub.tag)]
    #v(18pt, weak: true)
    #text(font: display-font, size: SIZES.h-xl, weight: 900, tracking: -3pt)[#sub.headline.prefix]\
    #text(font: display-font, size: SIZES.h-xl, weight: 900, tracking: -3pt, fill: primary)[#sub.headline.suffix.]
    #v(28pt, weak: true)
    #block(width: 720pt)[
      #text(font: primary-font, size: SIZES.lede, weight: 500, fill: muted)[#sub.body]
    ]
    #v(36pt, weak: true)
    #cta-pill(sub.formBox.cta.label)
  ]

  #v(1fr)
  #footer()
]
