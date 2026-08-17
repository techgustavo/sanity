#import "/lib.typ": sanity
#show: sanity.with(report: none, checks: ("missing-alt-text": true))

#figure(image("plot.svg", width: 1cm, alt: "A grey square"), caption: [Described]) <fig:ok>
#figure(image("map.svg", width: 1cm), caption: [Undescribed]) <fig:bare>

See @fig:ok and @fig:bare.
