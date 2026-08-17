#import "/lib.typ": sanity-ignore

#figure(rect(), caption: [Cover art]) <fig:cover>
#sanity-ignore(<fig:cover>, reason: "decorative")

#let ids = ("a", "b")
#for id in ids {
  [#figure(rect(), caption: [Appendix #id])#label("app:" + id)]
}
#for id in ids {
  sanity-ignore(label("app:" + id))
}
