#import "/lib.typ": sanity
#show: sanity.with(report: none, checks: ("unreferenced-listing": false))

#figure(```rust
fn main() {}
```, caption: [A listing]) <lst:main>

#figure(rect(), caption: [A figure]) <fig:panel>
