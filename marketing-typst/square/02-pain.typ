// marketing-typst/square/02-pain.typ — square pain slide (1080×1080).

#import "_layout.typ": *
#show: slide-setup

#let pain = yaml("/marketing-typst/data/" + lang + "/pain/meta.yml")
#let card-files = if lang == "da" {
  ("01-uventede-skatteregninger.yml", "02-intet-klart-overblik.yml", "03-konstant-tvivl.yml")
} else {
  ("01-surprise-tax-bills.yml", "02-no-clear-picture.yml", "03-constant-doubt.yml")
}
#let cards = card-files.map(f => yaml("/marketing-typst/data/" + lang + "/pain/cards/" + f))

#pad(left: SIZES.pad-x, right: SIZES.pad-x, top: SIZES.pad-top, bottom: SIZES.pad-bottom)[
  #header("02")
  #v(28pt)

  #block(width: 100%)[
    #text(font: primary-font, size: SIZES.eyebrow, weight: 800, tracking: 0.12em, fill: primary)[#upper(pain.tag)]
    #v(14pt, weak: true)
    #text(font: display-font, size: SIZES.h-l, weight: 900, tracking: -2.5pt)[#pain.headline.primary]\
    #text(font: display-font, size: SIZES.h-l, weight: 900, tracking: -2.5pt, fill: primary)[#pain.headline.emphasis]
  ]

  #v(32pt)

  #stack(spacing: 20pt,
    ..cards.map(c => h-card(c.icon, c.title, c.body)),
  )

  #v(1fr)
  #footer-with-arrow()
]
