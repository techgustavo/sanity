#import "/lib.typ": sanity, sanity-ignore
#show: sanity.with(report: none)

#figure(rect(), caption: [Cover art]) <fig:cover>
#sanity-ignore(<fig:cover>, checks: "unreferenced-figures")
