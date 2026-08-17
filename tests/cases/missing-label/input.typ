#import "/lib.typ": sanity
#show: sanity.with(report: none, checks: ("missing-label": true))

#figure(rect(), caption: [Discussed at length]) 

#figure(rect(), caption: [Also discussed]) <fig:labelled>

// typst will not number this one
#figure(rect(), caption: [Decorative], numbering: none)

See @fig:labelled.

#figure(
  rect(),
  caption: [A caption long enough that the message would rather show its opening words than the whole of it],
)

#figure(rect(), caption: [The reader's own words])
