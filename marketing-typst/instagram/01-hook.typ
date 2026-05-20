// marketing-typst/instagram/01-hook.typ — portrait hook slide (1080×1350).

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

  // Tightened header → eyebrow gap (was 80pt). Pulls headline up.
  #v(48pt)

  #block(width: 100%)[
    #text(font: primary-font, size: SIZES.eyebrow, weight: 800, tracking: 0.12em, fill: primary)[#upper(hero.headline.emphasis + " " + hero.headline.suffix)]
    #v(14pt, weak: true)
    #text(font: display-font, size: SIZES.h-xxl, weight: 900, tracking: -3.5pt)[#title-a]\
    #text(font: display-font, size: SIZES.h-xxl, weight: 900, tracking: -3.5pt, fill: primary)[#title-b]
    // Tightened headline → paragraph gap so the body sits right under
    // the emphasis line rather than floating in a void.
    #v(28pt, weak: true)
    #block(width: 760pt)[
      #text(font: primary-font, size: SIZES.lede, weight: 500, fill: muted)[#hero.paragraph]
    ]
    // Inline big-arrow — matches Hugo's `<div class="mt-56">{{ partial
    // "instagram/big-arrow.html" . }}</div>` on slide-01-hook.
    // Reduced spacing so the longer Danish copy still fits on canvas.
    #v(40pt, weak: true)
    #big-arrow()
  ]

  #v(1fr)
  #footer()
]
