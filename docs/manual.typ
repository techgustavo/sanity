#import "/src/core.typ": default-checks, default-severities
#import "/src/report.typ": _body as report-body, wash

#let ink = rgb("#1c1c1c")
#let quiet = rgb("#6d747d")
#let rule-grey = rgb("#ccd1d7")
#let paper-grey = rgb("#f5f6f8")
#let severity-colour = (
  info: rgb("#608FEA"),
  warning: rgb("#FFBB3E"),
  error: rgb("#F06262"),
)

#let sans = "Inter"
#let mono = "JetBrains Mono"

#set document(title: "sanity", author: "Gustavo Rodrigues")
#set page(
  paper: "a4",
  margin: (x: 2.6cm, top: 2.6cm, bottom: 2.4cm),
  numbering: "1",
  number-align: center,
)
#set text(font: sans, size: 9.8pt, fill: ink, lang: "en")
#set par(justify: false, leading: 0.68em, spacing: 1.2em)

#show link: set text(fill: severity-colour.info)
#show raw: set text(font: mono, size: 8.4pt, features: (liga: 0, calt: 0))
#show raw.where(block: false): it => box(it)
#show raw.where(block: true): it => block(
  width: 100%,
  fill: paper-grey,
  inset: (x: 12pt, y: 10pt),
  radius: 3pt,
  it,
)

#let package-name = regex("\bsanity\b")
#show package-name: it => text(font: mono, size: 0.92em, it)
#show raw: it => {
  show package-name: x => x
  it
}

#show heading.where(level: 1): it => block(above: 2.4em, below: 1.1em)[
  #block(below: 0pt, text(size: 15pt, weight: "bold", it))
  #block(above: 0.55em, line(length: 100%, stroke: 0.5pt + rule-grey))
]
#show heading.where(level: 2): it => block(above: 1.7em, below: 0.8em)[
  #text(size: 11pt, weight: "bold", it)
]
#show heading.where(level: 3): it => block(above: 1.4em, below: 0.6em)[
  #text(size: 9.8pt, weight: "bold", it)
]

#let state-colour = (on: rgb("#47CE76"), off: quiet)

#let pill(body, colour, width) = box(
  width: width,
  fill: wash(colour),
  inset: (x: 0pt, y: 2pt),
  outset: (y: 3pt),
  radius: 2pt,
  align(center, text(size: 7.5pt, font: mono, fill: colour, body)),
)

#let check(id, body) = {
  let on = default-checks.at(id)
  let severity = default-severities.at(id)

  block(above: 1.6em, below: 0.5em, breakable: false)[
    #grid(
      columns: (1fr, auto),
      align: (left + bottom, right + bottom),
      text(font: mono, size: 9.8pt, weight: "bold", id),
      {
        text(size: 8pt, fill: quiet)[default:]
        h(6pt)
        let state = if on { "on" } else { "off" }
        pill(state, state-colour.at(state), 24pt)
        h(5pt)
        pill(severity, severity-colour.at(severity), 44pt)
      },
    )
    #v(-0.4em)
    #line(length: 100%, stroke: 0.4pt + rule-grey)
  ]
  body
}

#let describes(ids) = {
  for id in default-checks.keys() {
    assert(
      id in ids,
      message: "manual: no entry for the check " + id,
    )
  }
}

#let finding(severity, message, id, page-label: none) = (
  severity: severity,
  message: message,
  id: id,
  target: none,
  page: none,
  page-label: page-label,
)

#let logo = "assets/sanity.svg"

#block(above: 0pt, below: 1.6cm)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 16pt,
    align: (left + horizon, right + horizon),
    [
      #text(size: 26pt, weight: "bold")[sanity]
      #v(-0.45em)
      #text(size: 11pt, fill: quiet)[
        A simple Typst package to find unreferenced figures, uncited sources and lost labels.
      ]
      #v(0.5em)
      #{
        show package-name: x => x
        text(size: 8.5pt, font: mono, fill: quiet)[
          version 0.1.0,
          #link("https://github.com/techgustavo/sanity")[github.com/techgustavo/sanity]
        ]
      }
    ],
    box(height: 2.5cm, image(logo)),
  )
]

#outline(depth: 1)

= Getting started

sanity analyzes your document after it has been compiled by Typst and reports unreferenced figures, uncited bibliography entries, as well as captions and labels that have gone missing. You add it as a `show` rule.

```typst
#import "@preview/sanity:0.1.0": *

#show: sanity
```

With these lines, whenever there is something to report, a page is attached listing what was found, just like this:

#v(0.4em)
#block(
  width: 100%,
  stroke: 0.5pt + rule-grey,
  inset: (x: 14pt, y: 12pt),
  radius: 3pt,
  report-body(
    (
      finding("warning", "equation <eq:capacity> is never referenced", "unreferenced-equation", page-label: "1"),
      finding("warning", "figure <fig:noise> is never referenced", "unreferenced-figure", page-label: "1"),
      finding("info", "figure <fig:noise> has no caption", "missing-caption", page-label: "1"),
      finding("warning", "bibliography entry \"example2026\" is never cited", "uncited-entry"),
    ),
    (:),
  ),
)
#v(0.4em)

== What to read next

#link(<checks>)[The checks] lists every check (what it reports). #link(<configuration>)[Configuration] and #link(<exemptions>)[Leaving something out] are how you change its behavior. #link(<command-line>)[From the command line] and #link(<ci>)[In CI] read the findings without touching the document.

The package needs Typst 0.14 or newer, but the command line script needs 0.15 (where `typst eval` arrived).

= The checks <checks>

#describes((
  "unreferenced-figure": true,
  "unreferenced-table": true,
  "unreferenced-listing": true,
  "unreferenced-equation": true,
  "unreferenced-footnote": true,
  "unreferenced-heading": true,
  "duplicate-label": true,
  "heading-level-skip": true,
  "reference-order": true,
  "missing-caption": true,
  "empty-caption": true,
  "missing-label": true,
  "duplicate-caption": true,
  "uncited-entry": true,
  "bibliography-not-checked": true,
  "orphaned-ignore": true,
  "missing-alt-text": true,
  "table-without-header": true,
))

Twelve checks run as soon as you apply the `show` rule. The other six are `off` until you ask for them with `checks: ("id": true)`.

An element is _only_ reported as unreferenced if you gave it a label, so a figure with no label _cannot_ be pointed at anyway.

== Elements nothing points at

#check("unreferenced-figure")[
  A labelled figure that no `@ref` and no `#link(<label>)` in the document points at.
]

#check("unreferenced-table")[
  The same, for a figure whose `kind` is `table`.
]

#check("unreferenced-listing")[
  The same again, for a figure whose `kind` is `raw`. A figure of some other `kind` is named after its `kind` in the message but reports under `unreferenced-figure`.
]

#check("unreferenced-equation")[
  A labelled block equation that nothing points at.
]

#check("unreferenced-footnote")[
  A labelled footnote that nothing points at.
]

#check("unreferenced-heading")[
  A labelled heading that nothing points at. `Off` by default.
]

#v(0.5em)

Note: Elements Typst cannot number are never called unreferenced.

== Labels and structure

#check("duplicate-label")[
  One label attached to more than one element. Typst rejects any reference to a
  repeated label.
]

#check("heading-level-skip")[
  A heading two or more levels below the one before it, like a `===` straight after a `=`.
]

#check("reference-order")[
  A figure or table first mentioned out of numbering order (figure 2 discussed
  before figure 1). This is not a rule of documents at large, so it is `off` by default.
]

== Captions

#check("missing-caption")[
  A _labelled_ figure or table with no caption at all.
]

#check("empty-caption")[
  A caption with nothing in it.
]

#check("missing-label")[
  A captioned figure or table with no label. It is `off` by default because some documents caption figures they never intend to reference.
]

#check("duplicate-caption")[
  Two figures, or two tables, carrying the same caption.
]

== The bibliography

#check("uncited-entry")[
  An entry in the bibliography data that nothing in the document cites. It can
  only run when sanity has that data (see #link(<bibliography>)[The
  bibliography]).
]

#check("bibliography-not-checked")[
  Says that `uncited-entry` could not run, and names the file to pass so that
  it can.
]

== Exemptions

#check("orphaned-ignore")[
  A `sanity-ignore` that matches nothing.

  Bibliography keys count as matches, since `#sanity-ignore("styleguide")` is
  how you keep an entry you never cite.
]

== A document that has to be tagged

#check("missing-alt-text")[
  An image with no `alt` text.
]

#check("table-without-header")[
  A table with no `table.header` row.
]

= Configuration <configuration>

```typst
#show: sanity.with(
  checks: ("unreferenced-heading": true, "empty-caption": false),
  severities: ("duplicate-label": "warning"),
  bibliography: read("refs.bib"),
  report: none,
  strict: true,
)
```

#table(
  columns: (auto, auto, 1fr),
  column-gutter: 14pt,
  stroke: none,
  inset: (x: 0pt, y: 6pt),
  align: (left + top, left + top, left + top),
  table.hline(stroke: 0.5pt + rule-grey),
  table.header(
    text(weight: "bold", size: 9.5pt)[Argument],
    text(weight: "bold", size: 9.5pt)[Default],
    text(weight: "bold", size: 9.5pt)[What it does],
  ),
  table.hline(stroke: 0.5pt + rule-grey),

  raw("checks"), raw("(:)"),
  [A dictionary keyed by check id.],

  raw("severities"), raw("(:)"),
  [The same, with `"info"`, `"warning"` or `"error"` as values.],

  raw("bibliography"), raw("none"),
  [What `read()` returns for a `.bib` or `.yml` file (or an array of them).],

  raw("report"), raw("auto"),
  [`auto` appends the page and `none` leaves the document completely untouched.],

  raw("strict"), raw("false"),
  [`true` fails the compilation on any warning/error],
  table.hline(stroke: 0.5pt + rule-grey),
)

Nothing at `info` fails a build.

```typst
#show: sanity.with(severities: ("empty-caption": "info"), strict: true)
```

= Leaving something out <exemptions>

Some figures are meant to be unreferenced, so you can exempt them:

```typst
#sanity-ignore(<fig:cover>, reason: "decorative")
```

It takes labels or plain strings, and any number of them, so it also works for
labels built at compile time.

```typst
#for id in appendix-ids {
  sanity-ignore(label("fig:" + id))
}
```

To silence one check rather than everything about an element:

```typst
#sanity-ignore(<fig:map>, checks: "unreferenced-figure")
```

`reason` is just a note to whoever reads the source, if the exemption goes stale, the reason appears in the `orphaned-ignore` message, so you know which one to delete.

= The bibliography <bibliography>

A Typst package cannot read your `.bib` file. But from the command line, `bin/sanity` reads the files your document names and hands them over.

Inside the document, pass the data yourself, like this:

```typst
#show: sanity.with(bibliography: read("refs.bib"))
```

#link("https://www.bibtex.org/Format/")[BibTeX] and #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[Hayagriva] files are both understood and an array covers a document with more than one.

```typst
#show: sanity.with(bibliography: (read("primary.bib"), read("extra.yml")))
```

= From the command line <command-line>

The #link("https://github.com/techgustavo/sanity/blob/main/bin/sanity")[`bin/sanity`] script reports on a document without modifying it. It exits non-zero when it finds a warning or an error.

```
$ bin/sanity paper.typ
warning: figure <fig:latency> is never referenced [unreferenced-figure]
  ┌─ page 4

sanity: 1 warning
```

You can download the script from GitHub and make it executable.

```
curl -sSLO https://raw.githubusercontent.com/techgustavo/sanity/main/bin/sanity
chmod +x sanity
```

#table(
  columns: (auto, 1fr),
  column-gutter: 14pt,
  stroke: none,
  inset: (x: 0pt, y: 6pt),
  table.hline(stroke: 0.5pt + rule-grey),
  raw("--json"),
  [Print the findings as a JSON array instead of a report.],
  raw("--version"),
  [Print the package the script imports.],
  raw("--help"),
  [Print the flags.],
  table.hline(stroke: 0.5pt + rule-grey),
)

`--json` gives an array of dictionaries with the keys `id`, `severity`, `message`, `target`, `page` and `page-label`.

```
$ bin/sanity paper.typ --json
[{"id":"unreferenced-figure","severity":"warning", ..}]
```

= In CI <ci>

Exits 1 on a warning or an error, 0 otherwise, and 2 when the document does not compile.

```yaml
name: manuscript
on: [push, pull_request]

jobs:
  sanity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: typst-community/setup-typst@v5
      - run: |
          curl -sSLO https://raw.githubusercontent.com/techgustavo/sanity/main/bin/sanity
          chmod +x sanity
          ./sanity paper.typ
```

`strict: true` setting causes the compilation itself fails, so `typst compile` gates the build and no script is needed. To get a PDF out of such a document anyway, pass `--input sanity=report`, or `--input sanity=off` for the untouched one.

= Thanks for considering this package!
