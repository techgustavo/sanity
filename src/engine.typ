#import "collect.typ"
#import "references.typ"
#import "structure.typ"
#import "captions.typ"
#import "citations.typ"

#let _bibliography-hint(sources) = {
  let read-calls = sources.map(s => "read(\"" + s + "\")")
  let argument = if read-calls.len() == 1 {
    read-calls.first()
  } else {
    "(" + read-calls.join(", ") + ")"
  }
  "bibliography entries are not checked; add bibliography: " + argument + " to the show rule"
}

#let analyse(cfg) = {
  let elements = collect.labelled-elements()
  let referenced = collect.referenced-labels()
  let bibs = collect.bibliographies()

  let findings = ()
  findings += references.run(elements, referenced, cfg)
  findings += structure.run(elements, cfg)
  findings += captions.run(elements, cfg)

  if cfg.bib-keys != none and bibs.len() > 0 and not collect.prints-full-bibliography(bibs) {
    findings += citations.run(cfg.bib-keys, collect.cited-keys(), cfg)
  }

  let ignored = collect.ignored-labels()
  findings = findings.filter(f => f.target == none or f.target not in ignored)

  let seen = ()
  let unique = ()
  for f in findings {
    let key = (f.id, f.target)
    if key in seen { continue }
    seen.push(key)
    unique.push(f)
  }
  findings = unique

  // report in reading order
  let position = (:)
  for (i, elem) in elements.enumerate() {
    if elem.target not in position { position.insert(elem.target, i) }
  }
  let rank(f) = {
    if f.target == none { elements.len() } else { position.at(f.target, default: elements.len()) }
  }
  let stride = findings.len() + 1
  findings = findings
    .enumerate()
    .sorted(key: ((i, f)) => rank(f) * stride + i)
    .map(((i, f)) => f)

  // said once
  let notes = ()
  let sources = collect.bibliography-sources(bibs)
  if findings.len() > 0 and cfg.bib-keys == none and sources.len() > 0 {
    notes.push(_bibliography-hint(sources))
  }

  // so that the appended report send a reader straight to the element
  let locations = (:)
  for elem in elements {
    if elem.target not in locations { locations.insert(elem.target, elem.element.location()) }
  }

  (findings: findings, notes: notes, locations: locations)
}
