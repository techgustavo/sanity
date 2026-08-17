#import "/lib.typ": sanity, sanity-ignore
#show: sanity.with(report: none)

#figure(rect(), caption: []) <fig:cover>
#sanity-ignore(<fig:cover>, checks: "unreferenced-figure", reason: "decorative")

#figure(rect(), caption: []) <fig:other>
#sanity-ignore(<fig:other>)
