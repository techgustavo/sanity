#import "core.typ": blank, finding

/// only labelled figures are examined
#let run(elements, cfg) = {
  let out = ()
  for elem in elements {
    if elem.group not in ("figure", "table") { continue }

    let caption = elem.element.caption

    if caption == none {
      let id = "missing-caption"
      if not cfg.checks.at(id, default: false) { continue }
      out.push(finding(
        id,
        cfg.severities.at(id),
        elem.noun + " <" + elem.target + "> has no caption",
        target: elem.target,
        page: elem.page,
      ))
    } else if blank(caption.body) {
      let id = "empty-caption"
      if not cfg.checks.at(id, default: false) { continue }
      out.push(finding(
        id,
        cfg.severities.at(id),
        elem.noun + " <" + elem.target + "> has an empty caption",
        target: elem.target,
        page: elem.page,
      ))
    }
  }
  out
}
