#import "_layout.typ": *
#show: slide-setup

#bg-decoration("/static/assets/characters/characters-01-gradient.svg")

#let hero = yaml("/marketing-typst/data/" + lang + "/hero/meta.yml")
#let parts = hero.tagline.split(", ")
#let humanize(s) = upper(s.slice(0, 1)) + s.slice(1)
#let title-a = humanize(parts.at(0)) + "."
#let title-b = humanize(parts.at(1)) + "."

#pad(left: SIZES.pad-x, right: SIZES.pad-x, top: SIZES.pad-top, bottom: SIZES.pad-bottom)[
  #header("01")
  #v(48pt)

  #block(width: 820pt)[
    #text(font: primary-font, size: SIZES.eyebrow, weight: 800, tracking: 0.12em, fill: primary)[#upper(hero.headline.emphasis + " " + hero.headline.suffix)]
    #v(14pt, weak: true)
    #text(font: display-font, size: SIZES.h-xxl, weight: 900, tracking: -3.2pt)[#title-a]\
    #text(font: display-font, size: SIZES.h-xxl, weight: 900, tracking: -3.2pt, fill: primary)[#title-b]
    #v(40pt, weak: true)
    #block(width: 640pt)[
      #text(font: primary-font, size: SIZES.lede, weight: 500, fill: muted)[#hero.paragraph]
    ]
  ]
  #v(1fr)
  #footer()
]
