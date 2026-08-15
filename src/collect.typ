#let label-of(elem) = if elem.has("label") { str(elem.label) } else { none }

#let paged() = if "target" in dictionary(std) { target() == "paged" } else { true }

#let page-of(elem) = {
  if not paged() { return none }
  let loc = elem.location()
  if loc == none { none } else { loc.page() }
}

#let figure-kind(fig) = {
  let kind = fig.kind
  if kind == table { return "table" }
  if kind == raw { return "listing" }
  if type(kind) == str { return kind }
  "figure"
}

#let referenced-labels() = {
  let from-refs = query(std.ref).map(r => str(r.target))
  let from-links = query(link).filter(l => type(l.dest) == label).map(l => str(l.dest))
  (from-refs + from-links).dedup()
}

// everything Typst will let you write `@label` for
#let _referenceable = {
  selector(figure).or(math.equation).or(heading).or(std.footnote)
}

#let labelled-elements() = {
  let out = ()

  for elem in query(_referenceable) {
    let name = label-of(elem)
    if name == none { continue }

    let func = elem.func()
    // (only a block equation can carry a number... and only a numbered can be
    // referenced)
    if func == math.equation and not elem.block { continue }
    if elem.numbering == none { continue }

    let (group, noun) = if func == figure {
      let kind = figure-kind(elem)
      (if kind == "table" { "table" } else { "figure" }, kind)
    } else if func == math.equation {
      ("equation", "equation")
    } else if func == heading {
      ("heading", "heading")
    } else {
      ("footnote", "footnote")
    }

    out.push((target: name, group: group, noun: noun, page: page-of(elem), element: elem))
  }

  out
}

/// bib keys
#let cited-keys() = query(std.cite).map(c => str(c.key)).dedup()

#let bibliographies() = query(std.bibliography)

#let prints-full-bibliography(bibs) = bibs.any(b => b.full == true)

#let bibliography-sources(bibs) = {
  bibs.map(b => b.sources).flatten().filter(s => type(s) == str).dedup()
}

/// values of our own metadata markers
#let _markers(name, key) = {
  query(label(name))
    .filter(m => m.func() == metadata and type(m.value) == dictionary and key in m.value)
    .map(m => m.value)
}

/// labels the author asked to keep quiet about
#let ignored-labels() = _markers("sanity-ignore", "target").map(v => v.target).dedup()

/// configuration left behind by the show rule, if the document uses one
#let stored-config() = {
  let markers = _markers("sanity-config", "checks")
  if markers.len() == 0 { none } else { markers.first() }
}
