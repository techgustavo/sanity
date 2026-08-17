// off by default 
#import "/lib.typ": sanity
#show: sanity.with(report: none, checks: ("table-without-header": true))

#figure(
  table(columns: 2, table.header([Trial], [Result]), [1], [ok]),
  caption: [Has a header],
) <tab:ok>

#figure(
  table(columns: 2, [1], [ok]),
  caption: [Has none],
) <tab:bare>

See @tab:ok and @tab:bare.
