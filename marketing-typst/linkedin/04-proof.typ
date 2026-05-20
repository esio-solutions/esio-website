#import "_layout.typ": *
#show: slide-setup

#let intro = yaml("/marketing-typst/data/" + lang + "/features/intro.yml")
#let panels = (
  yaml("/marketing-typst/data/" + lang + "/features/panels/01-cashflow.yml"),
  yaml("/marketing-typst/data/" + lang + "/features/panels/02-tax.yml"),
  yaml("/marketing-typst/data/" + lang + "/features/panels/03-projections.yml"),
  yaml("/marketing-typst/data/" + lang + "/features/panels/04-expenses.yml"),
)

#let head-lines = intro.headline.split("\n")
#let head-first = head-lines.slice(0, 2).join(" ")
#let head-rest = head-lines.slice(2).join(" ") + "."

#pad(left: SIZES.pad-x, right: SIZES.pad-x, top: SIZES.pad-top, bottom: SIZES.pad-bottom)[
  #header("04")
  #v(40pt)
  #block[
    #text(font: primary-font, size: SIZES.eyebrow, weight: 800, tracking: 0.12em, fill: primary)[#upper(intro.tag)]
    #v(14pt, weak: true)
    #text(font: display-font, size: SIZES.h-l, weight: 900, tracking: -2.2pt)[
      #head-first #text(fill: primary)[#head-rest]
    ]
  ]
  #v(56pt)
  #grid(columns: (1fr, 1fr), column-gutter: 20pt, row-gutter: 20pt,
    ..panels.map(p => feature(p.icon, p.title.replace("\n", " "), p.body)))
  #v(1fr)
  #footer-with-arrow()
]
