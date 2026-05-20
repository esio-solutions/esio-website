// marketing-typst/facebook/01-hook.typ
// Slide 1 of 5 — the hook: bold two-line headline + lede paragraph.
//
// Compile:
//   typst compile facebook/01-hook.typ ../output/facebook/01-hook.png \
//     --root .. --input theme=light --input lang=en \
//     --font-path fonts

#import "_layout.typ": *

#show: slide-setup

// Decorative background — blob + character art, placed first so they
// sit beneath the text content.
#bg-decoration("/static/assets/characters/characters-01-gradient.svg")

// Slide copy from data/<lang>/index/hero/meta.yml.
#let hero = yaml("/marketing-typst/data/" + lang + "/hero/meta.yml")

// "Stop guessing, start knowing" → ["Stop guessing", "start knowing"]
#let parts = hero.tagline.split(", ")
#let humanize(s) = upper(s.slice(0, 1)) + s.slice(1)
#let title-a = humanize(parts.at(0)) + "."
#let title-b = humanize(parts.at(1)) + "."

// Page content frame (corresponds to the old #hero padding 48px y / 56px x).
// font: primary-font is set explicitly on every text() call (belt-and-
// suspenders) so we can confirm at render time that Plus Jakarta Sans
// is actually applied — same font as the Hugo template's font-family.
#pad(x: 56pt, y: 48pt)[
  #header("01")

  #v(16pt, weak: true)

  // Body text — max-width 720pt as in the original.
  #block(width: 720pt)[
    // Eyebrow — "SMALL BUSINESS & STARTUPS" in primary tint
    #text(
      font: primary-font,
      size: 13pt,
      weight: 800,
      tracking: 2.8pt,
      fill: primary,
    )[#upper(hero.headline.emphasis + " " + hero.headline.suffix)]

    #v(10pt, weak: true)

    // Two-line headline; second line in primary. Weight 800 (ExtraBold)
    // because Plus Jakarta Sans's static distribution caps at 800.
    #text(font: display-font, size: 72pt, weight: 900, tracking: -2pt)[#title-a]\
    #text(font: display-font, size: 72pt, weight: 900, tracking: -2pt, fill: primary)[#title-b]

    #v(16pt, weak: true)

    // Lede paragraph, muted, max-width 540pt
    #block(width: 540pt)[
      #text(font: primary-font, size: 18pt, weight: 500, fill: muted)[#hero.paragraph]
    ]
  ]

  // Push footer to bottom of the page content area
  #v(1fr)

  #footer()
]
