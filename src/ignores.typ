#import "core.typ": finding
#import "collect.typ": label-exists

#let id = "orphaned-ignore"

#let run(ignores, bib-keys, cfg) = {
  if not cfg.checks.at(id, default: false) { return () }

  let keys = if bib-keys == none { () } else { bib-keys }
  let seen = ()
  let out = ()
  for entry in ignores {
    let target = entry.target
    if target in seen { continue }
    seen.push(target)
    if target in keys or label-exists(target) { continue }

    out.push(finding(
      id,
      cfg.severities.at(id),
      "sanity-ignore names <" + target + ">, which is not in the document",
      target: target,
    ))
  }
  out
}
