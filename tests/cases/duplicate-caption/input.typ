#import "/lib.typ": sanity
#show: sanity.with(report: none, checks: ("duplicate-caption": true))

#figure(rect(), caption: [Throughput against channel width.]) <fig:a>
#figure(rect(), caption: [Throughput  against channel   width.]) <fig:b>
#figure(table(columns: 1, [x]), caption: [Throughput against channel width.]) <tab:a>

See @fig:a, @fig:b and @tab:a.
