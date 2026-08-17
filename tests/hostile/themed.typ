#import "/lib.typ": sanity

#set page(
  fill: rgb("#101418"),
  background: rotate(30deg, text(60pt, fill: luma(120))[DRAFT]),
)
#set text(fill: white, size: 18pt, lang: "ar", dir: rtl)
#set align(center)

#show: sanity
#include "body.typ"
