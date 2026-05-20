// marketing-typst/facebook/02-pain.typ
// Slide 2 of 5 — the pain: three problem cards.

#import "_layout.typ": *

#show: slide-setup

#let pain = yaml("/marketing-typst/data/" + lang + "/pain/meta.yml")

// pain/cards/ filenames are localised per language in the source data.
// Typst doesn't have directory-listing, so the names are mapped explicitly.
#let card-files = if lang == "da" {
  ("01-uventede-skatteregninger.yml", "02-intet-klart-overblik.yml", "03-konstant-tvivl.yml")
} else {
  ("01-surprise-tax-bills.yml", "02-no-clear-picture.yml", "03-constant-doubt.yml")
}
#let cards = card-files.map(f => yaml("/marketing-typst/data/" + lang + "/pain/cards/" + f))

#pad(x: 56pt, y: 48pt)[
  #header("02")

  #v(16pt, weak: true)

  // Slide header — eyebrow + headline with primary-tinted emphasis
  #block[
    #text(font: primary-font, size: 13pt, weight: 800, tracking: 0.12em, fill: primary)[#upper(pain.tag)]
    #v(10pt, weak: true)
    #text(font: display-font, size: 44pt, weight: 900, tracking: -1.5pt)[
      #pain.headline.primary #text(fill: primary)[#pain.headline.emphasis]
    ]
  ]

  #v(1fr)

  // Three-card row
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 14pt,
    ..cards.map(c => card(c.icon, c.title, c.body)),
  )

  #v(1fr)

  #footer-with-arrow()
]
