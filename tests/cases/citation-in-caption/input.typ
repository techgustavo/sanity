#import "/lib.typ": sanity
#show: sanity.with(bibliography: read("refs.bib"), report: none)

Some text, @both and @prose-only.

#figure(rect(), caption: [Image credit: @caption-only.]) <fig:credit>

#figure(rect(), caption: [Also see @both.]) <fig:both>

See @fig:credit and @fig:both.

#bibliography("refs.bib")
