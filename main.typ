#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

#let stanford = super(sym.star)

#let title = [
  The Future of Memory: Limits and Opportunities
]
#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Shuhan Liu, Samuel Dayo, Thierry Tambe, Philip Levis, H.-S. Philip Wong, _et al._],
    email: [@stanford.edu],
    mark: stanford,
  ),
  // Or you can put affiliations directly in the author list
  // (
  //   name: [FirstName Surname],
  //   email: [email\@email.com],
  //   // You can put any thing here, and they will automatically be appended below the author name
  //   department: [Department of Computer Science and Engineering],
  //   institute: [The Chinese University of Hong Kong],
  //   city: [Hong Kong],
  // ),
)
#let affiliations = (
  (
    name: [Stanford University],
    mark: stanford,
//    department: [Department of Electrical],
    // You can put any thing here, and they will automatically be appended below
    // city: [Hong Kong],
  ),
//  (
//    name: [Institution/University Name],
//    mark: super(sym.suit.diamond),
//    department: [Department Name],
//  ),
  // More affiliations
)
#let conference = (
  name:  [The International Workshop on Big Memory],
  short: [BigMem 2025],
  year:  [2025],
  date:  [October 13],
  venue: [Seoul, Republic of Korea],
)
#let doi = "https://doi.org/10.1145/0000000000"
#let ccs = (
  (
    generic: [Software and its engineering],
    specific: ([Virtual machines], [Virtual memory], ),
  ),
  (
    generic: [Computer systems organization],
    specific: ([Heterogeneous (hybrid) systems], ),
  ),
)
#let keywords = ("Virtual machine", "Virtual memory", "Operating system", )

#show: acmart.with(
  title: title,
  authors: authors,
  affiliations: affiliations,
  conference: conference,
  doi: doi,
  copyright: "cc",
  // Set review to submission ID for the review process or to "none" for the final version.
  // review: [\#001],
)


= Abstract

Memory latency, bandwidth, and capacity are increasingly the bottlenecks in computing
systems and software. To address these challenges, many papers have proposed decoupling
memory from compute elements, allowing many CPUs to share large, disaggregated pools of
memory.

In this paper, we propose taking the opposite approach. Rather than create large shared
pools of memory, memory should be more tightly coupled with compute at a finer granularity.
Practical challenges in transistor scaling and memory circuitry mean that memory's share
of computing costs will only grow, such that huge pools of memory will be cost-effective
only for very specialized applications. Furthermore, the energy, cost, and
complexities of remote memory technologies (e.g., RDMA) will limit its use to  application-specific
architectures that address operational constraints. We propose several research
directions for future application-specific memory system design.


#acmart-ccs(ccs)
#acmart-keywords(keywords)
#acmart-ref(to-string(title), authors, conference, doi)

= Introduction <sec:introduction>


== Paper overview


= The End of Memory Scaling: SRAM and DRAM

Walk through what's happening with SRAM and DRAM scaling: density per unit area is
not going up, which means that they won't become cheaper. As logic shrinks, memory
will increasingly dominate costs, which means you won't want more of it.

= Locality is Efficiency (Remote Costs You)

The basics of why the cost of accessing memory increases with distance, both in terms
of energy and performance. 

= Memory Disaggregation, Revisited

Redefine disaggregation as breaking larger memories into multiple smaller ones, more
tightly coupled with compute.

= Application Architectures

When an application can't fit on a single machine, you distribute/parallelize it.  E.g.,
distributed databases. Having peers share memory over RDMA is different than putting all
of the memory in a central place: it's pushing the concept of locality one level up.

In datacenter/cloud systems, sometimes a given application uses RDMA because it can't fit on
a machine due to operational limits. I.e., datacenter servers have X RAM, and the app needs 2X
RAM. You can't deploy a special machine with 2X RAM, so you deploy it on 2 machines and access
remote memory with RDMA. But these designs are tightly entwined with the application, and
are not general purpose systems.

= Acknowledgements
#lorem(20)

#bibliography("refs.bib", title: "References", style: "association-for-computing-machinery")

#colbreak(weak: true)
#set heading(numbering: "A.a.a")

= Artifact Appendix
In this section we show how to reproduce our findings.

