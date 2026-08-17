#import "/lib.typ": sanity

#show: sanity.with(
  bibliography: (read("refs.bib"), read("notes.bib")),
  report: none,
)

See @shannon1948.

#bibliography("refs.bib")
