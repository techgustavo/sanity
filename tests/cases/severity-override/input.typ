#import "/lib.typ": sanity

#show: sanity.with(
  severities: ("unreferenced-figure": "info", "missing-caption": "error"),
  report: none,
)

#figure(rect(), caption: [Nobody points here]) <fig:quiet>
#figure(rect()) <fig:bare>

See @fig:bare.
