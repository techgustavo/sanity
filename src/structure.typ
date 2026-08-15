#import "core.typ": finding

#let id = "duplicate-label"

/// same label on two elements
#let run(elements, cfg) = {
  if not cfg.checks.at(id, default: false) { return () }

  let groups = (:)
  for elem in elements {
    groups.insert(elem.target, groups.at(elem.target, default: ()) + (elem,))
  }

  let out = ()
  for (target, group) in groups {
    if group.len() < 2 { continue }

    let pages = group.map(e => e.page).filter(p => p != none).dedup()
    out.push(finding(
      id,
      cfg.severities.at(id),
      "label <" + target + "> is attached to " + str(group.len()) + " elements"
        + if pages.len() > 1 { " (pages " + pages.map(str).join(", ") + ")" } else { "" },
      target: target,
      page: group.first().page,
    ))
  }
  out
}
