#import "/lib.typ": sanity
#show: sanity.with(
  bibliography: read("refs.bib"),
  checks: ("duplicate-caption": true, "uncited-entry": false),
  report: none,
)

#figure(rect(), caption: [Data from @a]) <fig:one>
#figure(rect(), caption: [Data from @b]) <fig:two>
#figure(rect(), caption: [Data from @a]) <fig:three>

See @fig:one and @fig:two and @fig:three.

#bibliography("refs.bib")
