#import "core.typ": severity-order
#import "collect.typ": paged

#let _plurals = (info: "info", warning: "warnings", error: "errors")

#let _count(n, severity) = {
  str(n) + " " + if n == 1 { severity } else { _plurals.at(severity) }
}

/// "1 error, 3 warnings", in decreasing severity skipping empty buckets
#let summary(findings) = {
  let parts = severity-order
    .rev()
    .map(sev => (sev, findings.filter(f => f.severity == sev).len()))
    .filter(((sev, n)) => n > 0)
    .map(((sev, n)) => _count(n, sev))
  if parts.len() == 0 { "no issues" } else { parts.join(", ") }
}

/// one finding per line
#let format-text(findings, notes: ()) = {
  if findings.len() == 0 and notes.len() == 0 { return "" }

  let lines = ()
  for f in findings {
    lines.push(f.severity + ": " + f.message + " [" + f.id + "]")
    if f.page != none { lines.push("  --> page " + str(f.page)) }
  }
  for note in notes {
    lines.push("note: " + note)
  }
  lines.push("")
  lines.push("sanity: " + summary(findings))
  lines.join("\n")
}

#let _colors = (
  info: rgb("#5f6773"),
  warning: rgb("#d8a926"),
  error: rgb("#dc2d21"),
)

/// the page a finding sits on
#let _where(f, locations) = {
  if f.page == none { return [] }
  let label = "page " + str(f.page)
  let loc = locations.at(f.target, default: none)
  text(fill: _colors.info, if loc == none { label } else { link(loc, label) })
}

#let _body(findings, notes, locations) = [
  #set text(font: ("DejaVu Sans Mono",), size: 8.5pt, fill: rgb("#1c1c1c"))
  #set par(justify: false, leading: 0.55em)

  #text(weight: "bold")[sanity] #h(0.6em) #text(fill: _colors.info, summary(findings))
  #line(length: 100%, stroke: 0.4pt + rgb("#c8ccd2"))
  #v(0.4em)

  #grid(
    columns: (auto, 1fr, auto),
    column-gutter: 0.9em,
    row-gutter: 0.7em,
    ..for f in findings {
      (
        text(fill: _colors.at(f.severity), f.severity),
        [
          #f.message \
          #text(fill: _colors.info, size: 0.85em, f.id)
        ],
        _where(f, locations),
      )
    }
  )

  #if notes.len() > 0 [
    #v(0.6em)
    #for note in notes [
      #text(fill: _colors.info)[note: #note] \
    ]
  ]
]

/// the same findings, appended to the document
#let appended-report(findings, notes: (), locations: (:)) = {
  if findings.len() == 0 and notes.len() == 0 { return none }

  if paged() {
    page(
      columns: 1,
      header: none,
      footer: none,
      numbering: none,
      _body(findings, notes, locations),
    )
  } else {
    raw(format-text(findings, notes: notes), block: true)
  }
}
