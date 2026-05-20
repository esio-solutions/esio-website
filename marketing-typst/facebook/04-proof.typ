// marketing-typst/facebook/04-proof.typ
// Slide 4 of 5 — proof: 4-feature grid demonstrating the product.

#import "_layout.typ": *

#show: slide-setup

#let intro = yaml("/marketing-typst/data/" + lang + "/features/intro.yml")
#let panels = (
  yaml("/marketing-typst/data/" + lang + "/features/panels/01-cashflow.yml"),
  yaml("/marketing-typst/data/" + lang + "/features/panels/02-tax.yml"),
  yaml("/marketing-typst/data/" + lang + "/features/panels/03-projections.yml"),
  yaml("/marketing-typst/data/" + lang + "/features/panels/04-expenses.yml"),
)

// Hugo splits the headline at newlines and combines: first two lines as
// regular, rest as accent (primary color). For 4-line headlines, that's
// "first 2 lines" + "last 2 lines accent".
#let head-lines = intro.headline.split("\n")
#let head-first = head-lines.slice(0, 2).join(" ")
#let head-rest = head-lines.slice(2).join(" ") + "."

#pad(x: 56pt, y: 48pt)[
  #header("04")

  #v(16pt, weak: true)

  #block[
    #text(font: primary-font, size: 13pt, weight: 800, tracking: 0.12em, fill: primary)[#upper(intro.tag)]
    #v(10pt, weak: true)
    #text(font: display-font, size: 44pt, weight: 900, tracking: -1.5pt)[
      #head-first #text(fill: primary)[#head-rest]
    ]
  ]

  #v(1fr)

  // 4-panel feature grid
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    column-gutter: 12pt,
    ..panels.map(p => feature(
      p.icon,
      // Title may have embedded newlines — replace with spaces for the card
      p.title.replace("\n", " "),
      p.body,
    )),
  )

  #v(1fr)

  #footer-with-arrow()
]
