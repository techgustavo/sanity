#import "/lib.typ": sanity

#show: sanity.with(checks: ("unreferenced-heading": true), report: none)

$ a = 1 $ <eq:unnumbered>
= Unnumbered heading <sec:unnumbered>

#set figure(numbering: none)
#figure(rect(), caption: [Unnumbered]) <fig:unnumbered>

#set math.equation(numbering: "(1)")
#set heading(numbering: "1.")
#set figure(numbering: "1")

$ b = 2 $ <eq:numbered>
= Numbered heading <sec:numbered>
#figure(rect(), caption: [Numbered]) <fig:numbered>
