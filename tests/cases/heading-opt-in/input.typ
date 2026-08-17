#import "/lib.typ": sanity

#show: sanity.with(checks: ("unreferenced-heading": true), report: none)

#set heading(numbering: "1.")

= Referenced <sec:used>
= Not referenced <sec:unused>

See @sec:used.
