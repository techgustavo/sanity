#import "/lib.typ": sanity
#show: sanity.with(checks: ("reference-order": true), report: none)

See @tab:b, @fig:a, @lst:a, then @tab:a.

#figure(rect(), caption: [Panel]) <fig:a>

#figure(
  table(columns: 1, table.header([Trial]), [1]),
  caption: [First table],
) <tab:a>

#figure(
  table(columns: 1, table.header([Trial]), [2]),
  caption: [Second table],
) <tab:b>

#figure(```rust
fn main() {}
```, caption: [A listing]) <lst:a>
