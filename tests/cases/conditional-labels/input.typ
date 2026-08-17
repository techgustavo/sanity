#let draft = false

#if draft {
  [#figure(rect(), caption: [Draft only]) <fig:draft>]
} else {
  [#figure(rect(), caption: [Final]) <fig:final>]
}

See @fig:final.
