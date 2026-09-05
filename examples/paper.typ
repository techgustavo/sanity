// in a document of your own the import is
// #import "@preview/sanity:0.2.0": *
#import "/lib.typ": *

#show: sanity.with(bibliography: read("refs.bib"))

#set page(numbering: "1")
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
#set par(justify: true)

#align(text(20pt, weight: "bold")[Article example])

= Introduction

#lorem(35) @example2026.

= Results

#lorem(25) The relation used throughout is @eq:example.

$ a + b = c $ <eq:example>

#lorem(30)

#figure(
  rect(width: 8cm, height: 3cm, fill: luma(85%)),
  caption: [An example figure.],
) <fig:example>

#lorem(20)

// this one is decorative
#figure(
  rect(width: 5cm, height: 2cm, fill: luma(85%)),
  caption: [A decorative figure.],
) <fig:decorative>

#sanity-ignore(<fig:decorative>, reason: "decorative")

#bibliography("refs.bib")
