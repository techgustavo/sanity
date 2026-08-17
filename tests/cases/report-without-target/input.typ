#import "/lib.typ": sanity
#show: sanity.with(checks: ("missing-label": true, "table-without-header": true))

= One
=== Three

#figure(rect(), caption: [])

#figure(rect(), caption: [Captioned, unlabelled])

#table(columns: 1, [no header row])
