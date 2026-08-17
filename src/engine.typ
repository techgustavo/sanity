#import "collect.typ"
#import "references.typ"
#import "structure.typ"
#import "captions.typ"
#import "citations.typ"
#import "accessibility.typ"
#import "ignores.typ"

#let analyse(cfg) = {
  let doc = collect.collected()
  let elements = doc.elements
  let referenced = collect.referenced-labels()
  let bibs = collect.bibliographies()

  let findings = ()
  findings += references.run(elements, referenced, cfg)
  findings += structure.run(elements, cfg)
  findings += captions.run(elements, cfg)
  findings += accessibility.run(doc.images, doc.tables, cfg)

  let from-bibliography = if bibs.len() > 0 and not collect.prints-full-bibliography(bibs) {
    if cfg.bib-keys == none {
      citations.not-checked(collect.bibliography-sources(bibs), cfg)
    } else {
      citations.run(cfg.bib-keys, collect.cited-keys(), cfg)
    }
  } else { () }
  findings += from-bibliography.enumerate().map(((i, f)) => f + (order: doc.count + i))

  let exemptions = collect.ignores()
  let ignored = exemptions.map(i => i.target).dedup()
  findings = findings.filter(f => f.target == none or f.target not in ignored)

  let orphaned = doc.count + from-bibliography.len()
  findings += ignores
    .run(
      exemptions,
      cfg.bib-keys,
      cfg,
      bibliography-unknown: bibs.len() > 0 and cfg.bib-keys == none,
    )
    .enumerate()
    .map(((i, f)) => f + (order: orphaned + i))

  let seen = ()
  let unique = ()
  for f in findings {
    if f.target != none {
      let key = (f.id, f.target)
      if key in seen { continue }
      seen.push(key)
    }
    unique.push(f)
  }
  findings = unique

  // report in reading order
  let stride = findings.len() + 1
  findings = findings
    .enumerate()
    .sorted(key: ((i, f)) => f.order * stride + i)
    .map(((i, f)) => (
      id: f.id,
      severity: f.severity,
      message: f.message,
      target: f.target,
      page: f.page,
      page-label: f.page-label,
    ))

  // so that the appended report sends a reader straight to the element
  let locations = (:)
  for elem in elements {
    if elem.target != none and elem.target not in locations {
      locations.insert(elem.target, elem.element.location())
    }
  }

  (findings: findings, locations: locations)
}
