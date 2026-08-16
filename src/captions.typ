#import "core.typ": blank, describe, finding

#let run(elements, cfg) = {
  let out = ()
  for elem in elements {
    if elem.group not in ("figure", "table") { continue }

    let caption = elem.element.caption

    if caption == none {
      let id = "missing-caption"
      if elem.target == none or not cfg.checks.at(id, default: false) { continue }
      out.push(finding(
        id,
        cfg.severities.at(id),
        describe(elem) + " has no caption",
        target: elem.target,
        page: elem.page,
        page-label: elem.page-label,
        order: elem.order,
      ))
    } else if blank(caption.body) {
      let id = "empty-caption"
      if not cfg.checks.at(id, default: false) { continue }
      out.push(finding(
        id,
        cfg.severities.at(id),
        describe(elem) + " has an empty caption",
        target: elem.target,
        page: elem.page,
        page-label: elem.page-label,
        order: elem.order,
      ))
    }
  }
  out
}
