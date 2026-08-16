#let severity-order = ("info", "warning", "error")

#let finding(
  id,
  severity,
  message,
  target: none,
  page: none,
  page-label: none,
  order: 0,
) = (
  id: id,
  severity: severity,
  message: message,
  target: target,
  page: page,
  page-label: page-label,
  order: order,
)

/// whether anything here should fail a build, "info" never does
#let blocking(findings) = findings.any(f => f.severity != "info")

#let default-checks = (
  "unreferenced-figure": true,
  "unreferenced-table": true,
  "unreferenced-equation": true,
  "unreferenced-footnote": true,
  // labelling sections you never cross-reference is common enough that
  // this would mostly produce (a lot of) noise (so false by default)
  "unreferenced-heading": false,
  "duplicate-label": true,
  "heading-level-skip": true,
  "missing-caption": true,
  "empty-caption": true,
  "uncited-entry": true,
  "bibliography-not-checked": true,
  "orphaned-ignore": true,
  "missing-alt-text": false,
  "table-without-header": false,
)

#let default-severities = (
  "unreferenced-figure": "warning",
  "unreferenced-table": "warning",
  "unreferenced-equation": "warning",
  "unreferenced-footnote": "warning",
  "unreferenced-heading": "warning",
  // a duplicated label makes every reference to it a hard compile error
  "duplicate-label": "error",
  "heading-level-skip": "warning",
  "missing-caption": "warning",
  "empty-caption": "warning",
  "uncited-entry": "warning",
  "bibliography-not-checked": "info",
  "orphaned-ignore": "warning",
  "missing-alt-text": "warning",
  "table-without-header": "warning",
)

// a typo in a check id would otherwise turn a check off in silence
#let config(checks: (:), severities: (:), bib-keys: none) = {
  for id in checks.keys() + severities.keys() {
    assert(id in default-checks, message: "sanity: no such check: " + id)
  }
  for (id, level) in severities {
    assert(
      level in severity-order,
      message: "sanity: severity for " + id + " must be info, warning or error",
    )
  }

  (
    checks: default-checks + checks,
    severities: default-severities + severities,
    bib-keys: bib-keys,
  )
}

#let describe(elem) = {
  if elem.target != none {
    elem.noun + " <" + elem.target + ">"
  } else if elem.page-label != none {
    elem.noun + " on page " + elem.page-label
  } else {
    elem.noun
  }
}

#let _whitespace = ("space", "linebreak", "parbreak", "h", "v")

/// whether a piece of content says nothing at all
#let blank(it) = {
  if it == none { return true }
  if type(it) == str { return it.trim() == "" }
  if type(it) != content { return false }

  if it.has("text") { return it.text.trim() == "" }
  if it.has("children") { return it.children.all(blank) }
  if it.has("body") and it.body != none { return blank(it.body) }
  repr(it.func()) in _whitespace
}
