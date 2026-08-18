<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/techgustavo/sanity/raw/main/docs/assets/banner-dark.svg">
  <img alt="sanity checks for your Typst documents" src="docs/assets/banner-light.svg" width="100%">
</picture>

`sanity` reads your compiled document and reports the figures nothing points at, the bibliography entries nothing cites, and the captions and labels that went missing on the way.

```typst
#import "@preview/sanity:0.1.0": *

#show: sanity
```

These two lines are *basically* what you need to use the package. When there is nothing to report, the compiled PDF is byte for byte the one you would have got without `sanity`. When there is, a page is appended listing what turned up, just like this:

<img alt="Six findings, each with its severity, its message, the id of the check that made it, and a link to the page it is on." src="docs/assets/report.svg" width="100%">

> [!NOTE]
> Needs Typst 0.14 or newer. The command line script additionally needs 0.15, since it uses `typst eval`.

## Manual

It is worth checking [docs/manual.pdf](docs/manual.pdf) for package details. It contains a description of each check (what it reports and where it sets the threshold) as well as the full configuration, exceptions, command-line usage, and how everything works.

This page is the short version, you can check out
[what it checks](#what-it-checks) ·
[bibliography](#bibliography) ·
[the command line](#from-the-command-line) ·
[CI](#in-ci) ·
[recipes](#recipes)

## What it checks

Twelve checks are performed by default as soon as you apply the `show` rule, including checks for figures, tables, listings, and equations, and many others.

Only elements you labelled yourself are reported as unreferenced, since an unlabelled figure cannot be pointed at and is often decorative. The [manual](docs/manual.pdf) gives each check an entry of its own.

## Bibliography

`uncited-entry` needs the bibliography data, and a package cannot read your `.bib`. From the command line `bin/sanity` reads it for you; inside the document, hand it over:

```typst
#show: sanity.with(bibliography: read("refs.bib"))
```

[BibTeX](https://www.bibtex.org/Format/) and [Hayagriva](https://github.com/typst/hayagriva/blob/main/docs/file-format.md) files are both understood, and an array covers a document with more than one bibliography. Without the data `sanity` says so, at `info` severity, which prints and never fails a build.

## From the command line

The [`bin/sanity`](https://github.com/techgustavo/sanity/blob/main/bin/sanity) script reports on a document without touching it, reads its bibliography for it, and exits non-zero on a warning or an error.

```
$ bin/sanity paper.typ
warning: figure <fig:latency> is never referenced [unreferenced-figure]
  ┌─ page 4

sanity: 1 warning
```

It lives here rather than in the published package, since a package cannot ship an executable:

```
curl -sSLO https://raw.githubusercontent.com/techgustavo/sanity/main/bin/sanity
chmod +x sanity
```

`--help` lists the flags.

## In CI

There are two ways to gate a build on `sanity`, and you only need one of them.

**The script**, which leaves the document alone. It exits `1` on a warning or an error, `0` when there is nothing to report, and `2` when the document does not compile, so a pull request that breaks a cross-reference stops coming back green:

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

**Or `strict: true`** in the document, which makes the compilation itself fail. Then `typst compile` gates the build on its own and there is no script to download:

```yaml
      - run: typst compile paper.typ
```

## Recipes

<details>
<summary>Check a document without touching it</summary>

With the [one-file script](#from-the-command-line)

```
bin/sanity paper.typ
```

</details>

<details>
<summary>Check the bibliography too</summary>

A package cannot open your `.bib`, so the document hands the data over

```typst
#show: sanity.with(bibliography: read("refs.bib"))
```

</details>

<details>
<summary>Let one figure go unreferenced</summary>

This one is decorative, so nothing is ever going to point at it

```typst
#sanity-ignore(<fig:cover>, reason: "decorative")
```

</details>

<details>
<summary>Silence one check on one element</summary>

The element stays under every other check

```typst
#sanity-ignore(<fig:map>, checks: "unreferenced-figure")
```

</details>

<details>
<summary>Turn a check on or off</summary>

By the id, which the [manual](docs/manual.pdf) lists for each check

```typst
#show: sanity.with(checks: ("reference-order": true, "empty-caption": false))
```

</details>

<details>
<summary>Fail the compilation instead of appending a page</summary>

Which is what [CI](#in-ci) wants

```typst
#show: sanity.with(strict: true)
```

</details>

<details>
<summary>Get the plain PDF back</summary>

No edit to the source, just the one input

```
typst compile --input sanity=off paper.typ
```

</details>

---

**License:** MIT.
