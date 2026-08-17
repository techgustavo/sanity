#figure(rect(), caption: [One]) <fig:one>
#figure(rect(), caption: [Two]) <fig:two>
#figure(rect(), caption: [Three]) <fig:three>

#let discussed = ("one", "three")
#for id in discussed {
  [See #ref(label("fig:" + id)). ]
}
