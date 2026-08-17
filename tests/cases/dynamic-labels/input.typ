#let sample(id) = figure(rect(width: 1cm), caption: [Sample #id])

#for id in ("alpha", "beta", "gamma") {
  [#sample(id)#label("fig:" + id)]
}

#for id in ("alpha", "gamma") {
  [See #ref(label("fig:" + id)). ]
}
