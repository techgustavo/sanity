#import "/lib.typ": sanity
#show: sanity.with(checks: ("reference-order": true), report: none)

See @fig:b, then @fig:a. And @fig:a again, then @fig:c and @fig:b.

#figure(rect(), caption: [First]) <fig:a>
#figure(rect(), caption: [Second]) <fig:b>
#figure(rect(), caption: [Third]) <fig:c>
