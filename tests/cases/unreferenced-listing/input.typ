#import "/lib.typ": sanity
#show: sanity.with(report: none)

#figure(```rust
fn main() {}
```, caption: [A listing]) <lst:main>

#figure(rect(), caption: [A figure]) <fig:panel>

#figure(rect(), caption: [An algorithm], kind: "algorithm", supplement: [Algorithm]) <alg:sort>
