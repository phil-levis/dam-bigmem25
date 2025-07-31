//#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "clean-acmart.typ": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

#let stanford = super(sym.star)
#let indep = super(sym.circle)

// Footnote spacing, make it tight
#show footnote.entry: it => {set par(leading: 0.1em, spacing: 1em); it}
#set footnote.entry(gap: 3pt)

#let title = [
  The Future of Memory: Limits and Opportunities
]
#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Shuhan Liu#stanford, 
           Samuel Dayo#stanford, 
           Philip Levis#stanford, 
           Subhasish Mitra#stanford, \  
           Thierry Tambe#stanford,
           David Tennenhouse#indep,
           H.-S. Philip Wong#stanford],
    email: [@stanford.edu],
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
  ),
  (
    name: [Independent Researcher],
    mark: indep
  )
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
  authors: (), //authors,
  affiliations: (),// affiliations,
  conference: conference,
  doi: doi,
  copyright: none,
  // Set review to submission ID for the review process or to "none" for the final version.
  // review: [\#001],
)


= Abstract

Memory latency, bandwidth, capacity, and energy increasingly limit performance. In this paper, we reconsider proposed system architectures that consist of huge (many-terabyte to petabyte scale) memories shared among large numbers of CPUs. We argue two practical engineering challenges, scaling and signaling, limit such designs.
//Limits in transistor and memory manufacturing mean memory increasingly dominate system cost. 
//, such that huge memories will be cost-effective only for very specialized applications.
//Furthermore, even for those applications, limits on the scaling of signalling speeds will make it difficult for memory pools to  keep up with the applications' bandwidth requirements. 
//Furthermore, the energy, cost, and
//complexities of remote memory technologies (e.g., RDMA) will them to 
//application-specific architectures that address operational constraints. 

// To address these challenges, many papers have proposed decoupling memory from compute elements, allowing many CPUs to share large, disaggregated pools of memory.

We propose the opposite approach. Rather than create large,  shared, homogenous memories, systems 
explicitly break memory up into smaller slices more tightly coupled with compute elements. Leveraging advances in 2.5D/3D integration, this compute-memory node provisions private
local memory, enabling accesses of node-exclusive data through micrometer-scale distances, and dramatically
reduced access cost. In-package memory elements support shared state within a processor, providing far better bandwidth and energy-efficiency than DRAM, which is used as main memory for large working sets and cold data. Hardware's making memory capacities and distances explicit allows software to efficiently compose this hierarchy, managing 
data placement and movement. 

// need to include that we still have shared memory (eg., on-package HBM and DIMMs; local 3D integrated memories provide each chiplet with expanded capacity with lower latency ...)

//[say what's good about our approach]
//#acmart-ccs(ccs)
//#acmart-keywords(keywords)
//#acmart-ref(to-string(title), authors, conference, doi)

= Introduction <sec:introduction>

The idea of a large, distributed address space of memory is
appealing. It allows applications to seamlessly
grow beyond a single host while leaving the complexities of
caching, consistency, and placement to lower system layers.
In the 1980s and 1990s, this idea was explored as distributed shared memory 
(DSM), informing  memory consistency models in
modern multi-core and multiprocessor systems.

//Memory disaggregation is gaining traction as a way to reduce memory costs and improve utilization in datacenter-scale systems@li25pond. The conventional model pools memory into a shared remote tier---typically accessed over interconnects like CXL---so that compute nodes can allocate more capacity on demand. Pooling promises to reduce stranded memory and enable flexible provisioning across diverse workloads. 

As memory is increasingly the bottleneck in data center and cloud servers, research is revisiting
these ideas to enable a next generation of systems with huge network-attached memories that are pooled, i.e., shared, across many 
processors. This paper argues that this approach is untenable due to two modern engineering 
barriers: scaling and signaling.
These are practical limits, grounded in physics.

The first, _scaling_, refers to the ability to make transistors and circuits smaller and cheaper
with more precise tools and complex manufacturing processes. Memory technology scaling has effectively ended. SRAM's and DRAM's 
cost per byte have both flattened and there is no roadmap to significantly reduce them in the next
five years. As logic continues to shrink, albeit at a slower pace than before, 
memory becomes a growing fraction of system cost, making it economically and
architecturally undesirable to provision large memories. Instead, we should work to improve the efficiency with which memory is utilized.

// there are 3D DRAM on the horizon that all memory companies are working on, but they won't be available in 5 years. So we are still technically correct. - Philip

The second barrier, _signaling_, has to do with the energy required to move signals between components at a given bandwidth. It dictates that the energy efficiency and bandwidth to/from memory 
improve with tighter integration with computational logic.@ho01wires Within a chiplet, access to an SRAM cache line that is far away is slower and/or requires higher energy than a nearby one -- while access to one on another chiplet is more expensive still.#footnote([Modern server processors are made up of multiple, separately manufactured _chiplets_ that are packaged together into
a larger system.]) Going to DRAM across traces on a circuit board is an order of magnitude more
expensive; CXL or RDMA to remote memory add even more overheads. These penalties make remote memory
prohibitively expensive.

Faced with these barriers, we propose a different approach: physically composable disaggregation. Systems are built from compute-memory nodes that tightly integrate compute with private local memory and on-package shared memory, while using off-package DRAM for bulk capacity. Software explicitly composes the memory system---deciding what data remains local, what is shared across nodes, and what is relegated to DRAM. // Instead of pulling memory away from compute, we build systems from tightly integrated compute-memory nodes using advances in packaging technology.  These memories can be provisioned flexibly, supporting multiple modes---for example, as a transparent cache or as explicit NUMA domains under software control. When an application needs more memory than a single node can provide, we scale across multiple such nodes accessing peer memory over lightweight, memory-semantic interconnects. 


// chiplets access local data via their expanded capacity memories; Share data between chiplets first access through on-packaged intergated memories (ie., HBM). Employ DRAM DIMMs for large-capacity blocked; for moving large chunks of data. 
// Composable means software being able to determine where data is placed and deciding which data is local and which data is shared. 

//== Paper overview
//The rest of the paper is organized as follows: 
//*Section 2* explains why plateauing memory density, not just technology scaling (what does this mean?), makes traditional memory hierarchies increasingly untenable. *Section 3* quantifies thhe performance and energy costs fo remote memory pools. *Section 4* presents our revisited model for memory disaggregation. *Section 5* explores how this model support distributed, locality-aware applications. 


= The End of 2D Scaling: SRAM and DRAM


#figure(
  image("scaling.png"),
  placement: top,
  caption: [Both DRAM and SRAM have stopped scaling. Reducing cost/byte requires revolutionary changes.],
) <scaling>

// xxx Walk through what's happening with SRAM and DRAM scaling: density per unit area is
// not going up, which means that they won't become cheaper. As logic shrinks, memory
// will increasingly dominate costs, which means you won't want more of it. xxx

Two-dimensional (2D) semiconductor scaling  enabled higher memory density and capacity at reduced cost. However, @scaling shows how traditional 2D scaling of both SRAM and DRAM has ended. The cost per byte of DRAM has been
flat for over a decade, which is why as servers have scaled up, DRAM has come to dominate
system cost.#cite(<patel_xfm_2023>)
SRAM has reached similar limits: we can no longer make
smaller SRAM cells, and so their cost is flat. 

For SRAM, the primary constraint stems from transistor dimensions approaching atomic scales: manufacturing tolerances limit transistor matching of the cross-coupled inverter pair, reducing signal margin.
Computational logic does not suffer
from this issue as each stage restores the digital signal. 
For DRAM, the primary constraint is the cost of etching the high aspect-ratio capacitors and the complex transistor geometry that guarantees low leakage. More advanced nodes decrease
the physical size of DRAM cells, but not the per-transistor cost. We can continue to make
larger DRAM DIMMs, but their per-byte cost does not decrease.#footnote([3D DRAM promises to improve bit density but the cost of manufacturing is still unknown.])

The primary takeaway from these limits is that enormous memories will be enormously expensive.
On-chip caches will not grow faster than chip area, and modern server processors are already huge (AMD SP5 is 5,428mm#super("2")). 
Systems will have to use memory more efficiently.

= Locality = Efficiency AND Bandwidth//Performance

#figure(
  // box(
  //   [*Plot that shows the DRAM BW/core for AMD Naples to Grado, Intel Skylake to Granite Rapids*],
  //   height: 1in,
  //  stroke: 1pt),
  image("DRAM BW per core.png"),
  placement: top,
  caption: [DRAM bandwidth/core for server processors (and core counts). Per-core bandwidth is tagnant.],
) <bandwidth>


#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.5pt + black, top: 1.5pt + black)
  } else if y == 4 {
    (bottom: 1.5pt + black)
  },
 // fill: (x, y) => if (calc.rem(y, 2) == 0 and y != 0) {
 //   rgb(220,220,220)
 // },
  align: (left, right, right, right)
)

#show table.cell: set text(size: 8pt)
#figure(
  table(columns: 4,
  inset: 2pt,
  table.header(
    [*Integration*], [*Pitch*], [*Energy/bit*], [*BW/chip*]//,[*Pin Rate*] 
  ),
  [On-die (5nm) (e.g. SRAM)], [0.028 $mu$m],   [5 fJ], [131 TB/s], //[2 Gbps ],
  [Hybrid bonding (e.g. V-Cache)],     [9 $mu$m],  [$approx$600 fJ], [2.5 TB/s], //[8 Gbps],
  [Microbump (e.g. HBM)],   [36 $mu$m],  [$approx$2,000 fJ], [1.2 TB/s],// [8 Gbps],
  [C4 solder bump (e.g. DDR)],  [730 $mu$m], [$approx$10,000 fJ], [0.1 TB/s]),// [32 Gbps]), 
  placement: auto,
  caption: [Four major integration methods: tighter integration has lower energy and higher bandwidth communication.],
) <pitch>



// xxx The basics of why the cost of accessing memory increases with distance, both in terms
// of energy and performance. xxx



//Modern computer systems employ a hierarchical memory structure where different memory technologies are 
//organized based on their speed, cost, and capacity. Scaling up core counts in server processors have
//added additional levels of "sub-NUMA clusters", which represent accessing a cache line on the same
//compute chiplet is faster and cheaper than a cache line on a different chiplet.

Tighter integration increases the bandwidth and energy efficiency of signaling to move data to and from memory.  
Caches exemplify this principle: L1, L2, and L3 caches all use the same SRAM technology, 
but L1 caches achieve superior performance through smaller memory bank sizes, finer-grained access, 
and closer physical proximity to CPU cores. 

DRAM bandwidth to a processor socket has been slowly improving: a modern DDR5-5600 DIMM is 358Gbps, and the DIMMs per socket grew from 8 to 12, for an aggregate bandwidth of 4.3Tbps. At the same time, however, the number of cores per socket has grown, exceeding or matching bandwidth improvements. @bandwidth shows the per-core bandwidth for Intel and AMD server processor packages since 2018: it has been stagnant.

DRAM's bandwidth  //by performance, you mean bandwidth or latency? can this be more specific?
limits and energy costs stem from being connected on a 
printed circuit board (PCB), which has limited number of copper traces and bump pins 
(e.g. 288 pins for DDR5). High-bandwidth Memory (HBM) repurposes DRAM dies //DR
and moves them closer with improved integration technology. By using an in-package silicon logic base die tucked underneath several DRAM dies, connected by through-silicon-vias, each HBM3E stack has 1024 pins and shorter interconnect distance. This stark difference in pin count directly translates to HBM's bandwidth advantage. @pitch shows how tighter physical integration allows denser pins, higher bandwidth, and lower energy. Lower pin densities necessitate higher-speed signaling circuits, increasing energy consumption.

These integration limits mean that cores will not see performance improvements from DRAM. Packages cannot accommodate additional DIMMs, and their pin counts are already at their practical limits. Higher signaling speeds across  copper traces has a high energy cost. 


//TODO: Replace with primary takeaway of section 3. Basically, we can't have more DIMMs because of the space and they can't get much faster.

// to discuss at DAM meeting: how important latency is. whether we should add into Table I and add more details. 

  
// The energy implications are profound. Research consistently demonstrates that data movement to/from the compute chip consumes 
// approximately 70% of total memory system energy, while the DRAM cells themselves account for only
// 10-15% [ref]. (The tradeoff is that tighter integration is limited by module size).#footnote("E.g., one literally cannot fit terabytes of DRAM inside a chip package, which is why HBM capacity is limited.")
//While current state-of-the-art copper hybrid bonding in 3D stacking has pitches as small as 
//2μm [ref], this remains >70 times larger than the 5nm node's 28nm.

//this last sentence reads rather strange and it is not clear what it conveys. Does it mean we want tighter integration? But the next sentence also says we cannot fit everything on to one chip. So what gives?

//Segregating memory from computing unnecessarily increases costs, energy consumption, and sacrifices performance on interconnects, which was once a negligible component but has become the dominant bottleneck in advanced technology nodes. [ this sentence seems out of place.]

= Physically Composable Disaggregation

// xxx Redefine disaggregation as breaking larger memories into multiple smaller ones, more
// tightly coupled with compute. xxx
// #linebreak()


These scaling challenges necessitate a fundamental rethinking of memory hierarchy design -- shifting focus from raw capacity to locality, bandwidth, and energy efficiency. // we must transition from a focus on raw capacity to emphasizing bandwidth and energy-efficiency. 

//We revisit memory "disaggregation" from a new angle: instead of pooling memory in one remote location accessed via a hierarchy of packaging and interconnects, we break up larger memories into multiple smaller units, much closer to computation units. // ---effectively _distributed local memories_. 

// We propose flipping the script by emphasizing finer-grained integration of memory and compute at architectural and physical levels and through an increased emphasis on memory utilization --- even if it sometimes comes at some modest decrease in compute utilization. It is enabled by advanced 2.5D and 3D integration technologies that co-package or vertically stack memory with compute with dense interconnects. As a result, memory accesses occur over micrometer-scale distances using dense interconnects such as micro-bumps, hybrid bonds, through-silicon vias and/or monolithic integration on the wafer itself, dramatically reducing the latency, energy, and bandwidth bottlenecks inherent to transparent, large address spaces.


We propose flipping the script on memory "disaggregation" by emphasizing finer-grained integration of memory and compute with /*at architectural and physical levels and through an*/ increased emphasis on memory utilization---even if it sometimes comes at some modest decrease in compute utilization. At the center of this approach is the compute-memory node, which uses 3D integration technologies to integrate compute with a local memory, stacking memory on top of compute similar to AMD's VCache design and Milan-X processors.@Vcache

Unlike a cache, however, this private local memory is explicitly managed and the exclusive home for node-specific data such as execution stacks and other thread-private state. Accesses over micrometer-scale distances via micro-bumps, hybrid bonds, through-silicon vias, or monolithic wafer-level interconnects, dramatically reduce the latency, energy, and bandwidth bottlenecks of large address spaces. Mirroring practises in modern multi-chiplet processors, shared state that must span nodes--such as locks---is placed in on-package shared memory (e.g., HBM), which, while slower than private local slices, still deliver far better bandwidth and energy-efficiency than off-package DRAM.  

// What does on chiplet look like now?
// Enabled by 2.5 and 3D integration technologies that co-package or vertically stack memory with compute using dense interconnects, each node will have a private accessed local memory. 

// Enabled by advanced 2.5D/3D integration, we co-package or vertically stack memory with compute using dense interconnects. Each compute-memory node functions as a sub-NUMA domain collapsed onto the package: like modern processors favoring local DDR5s, each node provides its own local slice of memory. Local accesses span micrometer-scale distances via micro-bumps, hybrid bonds, through-silicon vias and/or monolithic inter-layer vias, while overflow accesses to peer nodes resemble a remote-NUMA hop, but at tens of instead of hundreds of nanoseconds. Multiplying these micro-NUMA domains preserves familiar locality semantics while dramatically reducing the latency, energy, and bandwidth bottlenecks inherent to transparent, large address spaces.

However, integration is limited by physical constraints (e.g. thermal dissipation, module size, etc.)#footnote("E.g., one literally cannot fit terabytes of DRAM inside a chip package."). Large memories will continue to require off-package DRAM.  Instead of serving as a pooled, flat, shared address space, DRAM becomes a bulk, capacity-driven storage tier for large working sets and cold data, while performance-critical accesses are managed using the faster disaggregated on-package memories. Software _composes_ the memory system itself---deciding what data remains local, what is shared, and what is relegated to off-package DRAM---making data placement and movement explicit through abstractions that expose near-zero distance local memory alongside higher-latency shared tiers in a way that enables efficient composition. 


//nodes access local data in local memory with dense interconnect enabled by levaraging advanced 2.5D/3D intergation. Data shared by multiple node is accessed by 

//shared data accessed by multiple nodes can still be stored in co-packaged memory to provide extended capacity 

// 
// divides its DDR5 DIMMs into left-and right-hand domains, favoring accesses to the local side and paying a premium for accesses to the far side, this approach gives each module its own "local" slice of integrated memory. Intra-module accesses now travel only micrometers-scale through dense micro-bumps, hybrid bonds, through-silicon vias and/or monolithic inter-layer vias, while overflow traffic to a peer module resembles a remote-NUMA hop, but at tens rather than hundreds of nanoseconds. By multiplying these micro-NUMA domains and shrinking the distance between them, we preserve familair localityt semantics while dramatically reducing the latency, energy, band bandwidth bottlenecks inherent to transparent, large address spaces. 


/*
= Application Architectures

// the question is whathappens when the application memory exceeds that of a single machine node then? Well you'd split the application over multiple machines, achieving the combined memory of a machine with 2X RAM using two 1x RAM machines. Incorporating mechanisms like RDMA (Remote Direct Memory Acess), enables peer-to-peer memory sharing by enabling peer-to-peer data movement directly between application memory on the participating machines, without CPU involvement. Effectively, instead of one single centralized memory pool, a cluster of machines is treated as a large distributed memory with localicty awareness ay the cluster level [ref]. This approac approacg pushed the concept of locality one level up---(a machine's local memory vs. remote memory (a peer machine's local memory) leveraging lower latency reads/writes via load/stores to remote memory hosted on different machines while avoiding a monolithic memory pool. 


// When an application can't fit on a single machine, you distribute/parallelize it.  E.g.,distributed databases. Having peers share memory over RDMA is different than putting all
// of the memory in a central place: it's pushing the concept of locality one level up. In datacenter/cloud systems, sometimes a given application uses RDMA because it can't fit on
// a machine due to operational limits. I.e., datacenter servers have X RAM, and the app needs 2X RAM. You can't deploy a special machine with 2X RAM, so you deploy it on 2 machines and access remote memory with RDMA. But these designs are tightly entwined with the application, and are not general purpose systems.

Within the proposed approach to memory disaggregation, applications with memory footprint exceeding the capacity of a single machine and its coupled local memory, are distribute and parallelized across multiple such nodes. This enables applications to scale their total memory capacity while retaining the latency and bandwidth advantages of local access. In this model, each machine continues to prioritize fast access of its own local memory, but can fetch memory from a neighboring machine via peer-to-peer accesses. [Need example. E.g., distributed databases point]

We envision that these peer-to-peer accesses will occur over a tightly integrated, cluster-wide interconnect that enables machines to directly access each other's memory with low latency and minimal overhead. Crucially, such interconnects must support memory-sematic operations--enabling  one machine to read from or write to another's memory as if it were its own, effectively extending each machine's accessible memory beyond its physical boundary. Remote Direct Memory Access (RDMA) is a prominent realization of this concept. Unlike conventional communication methods like RPC or message-passing, which require coordination by the remote CPU and OS, RDMA allows direct memory-to-memory transfers that bypass the remote CPU, eliminate kernel involvement, and avoid data copies into intermediate buffers. This RDMA "lightweight" because memory operations occur entirely in hardware with no need for context switches or CPU servicing on the remote end [refs], preserving end-to-end system efficiency of cross node memory accesses with micro-second scale latency and low CPU overhead. 

This approach pushes the concept of locality one level up: in a traditional NUMA system, local memory is on-die or on-socket, and remote memory is elsewhere on the board. In our disaggregation model, locality now refers to memory attached to the local node vs. memory hosted by peer nodes, with the interconnect serving as the fabric across this new abstraction boundary. Just as NUMA-aware software seeks to avoid crossing sockets unnecessarily, distributed runtimes in this mode aim to maximize local memory access and minimize remove communication, but do so across machines.

This model is well-suited to datacenter and cloud environments, where machines are often not general-uprose but instead co-designed alongside the application they serve. In these settings, developers routinely tailor application runtime, memory layouts, and communication patterns to the specific hardware infrastructure [refs?]. Such tight integration between software and system enables explicit handling of memory locality, via mechanisms like remote reads, object migration, and partitioned state models, baked directly into the application. Due to the co-architected application and system, scaling out memory across multiple nodes becomes not only feasible, but beneficial, eliminating the need for a centralized memory pool and its associated overheads in latency, energy, and software complexity.



// In essence, locality is elevated: memory access is no longer just "on-chip vs. off-chip," but rather "local node vs. peer node." Systems using such a model effectively treat the cluster as a large memory space with machine-level NUMA semantics--data is local unless fetched from a neighboring node. 
// - such as remote direct memory access (RDMA) over high-speed fabric [ref: maybe NVIDIA RoCE?].
// This approach facilitates scaling while preserving the concept of locality, but pushed to a higher level of abstraction; each machine continues to prioritize fast access to its own local memory, but can also access the memory of a peer machine over a shared interconnect--at higher latency and lower bandwidth, yet still far more efficient than traditional off-chip DRAM or centralized pools [PROOF? REF?]. In effect locality is redefined at the machine-to-machine level: either local (on the current node) or remote (on a peer node), and the system treats these tiers similarly to NUMA domains within a single server--just scaled out across a cluster.

//= Acknowledgements
//#lorem(20)
*/

#bibliography("refs.bib", title: "References", style: "association-for-computing-machinery")

//#colbreak(weak: true)
//#set heading(numbering: "A.a.a")

//= Artifact Appendix
//In this section we show how to reproduce our findings.

