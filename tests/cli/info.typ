#import "/lib.typ": sanity
#show: sanity.with(report: none, severities: ("unreferenced-figure": "info"))

#figure(rect(), caption: [Nothing points at this]) <fig:orphan>
