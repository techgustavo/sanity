#import "/lib.typ": sanity

#show: sanity.with(
  bibliography: (read("primary.bib"), read("secondary.yml")),
  report: none,
)

Cited: @alpha and @gamma.

#bibliography(("primary.bib", "secondary.yml"))
