#import "/lib.typ": sanity
#show: sanity.with(
  report: none,
  checks: ("missing-label": true, "unreferenced-equation": false, "unreferenced-footnote": false),
)

#set math.equation(numbering: "(1)")

$ a = 1 $ <eq:labelled>
$ b = 2 $

A claim#footnote[The evidence.] <fn:labelled> and another#footnote[More.].

#[#set math.equation(numbering: none)
$ c = 3 $]

See @eq:labelled and @fn:labelled.
