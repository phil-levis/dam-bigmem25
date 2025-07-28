#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

#let stanford = super(sym.star)
#let indep = super(sym.circle)

#let title = [
  The Future of Memory: Limits and Opportunities
]
#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Shuhan Liu#stanford, 
           Samuel Dayo#stanford, 
           Philip Levis#stanford, 
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
  authors: authors,
  affiliations: affiliations,
  conference: conference,
  doi: doi,
  copyright: "cc",
  // Set review to submission ID for the review process or to "none" for the final version.
  // review: [\#001],
)


= Abstract

Memory latency, bandwidth, and capacity are increasingly the bottlenecks in computing systems and software. Prior efforts have addressed these challenged by disaggregating memory from compute, enabling many CPUs to share centralized remote memory pools via interconnects like CXL. 

// To address these challenges, many papers have proposed decoupling memory from compute elements, allowing many CPUs to share large, disaggregated pools of memory.

In this paper, we take the opposite approach. Rather than create large shared pools of memory, memory should be broken up into smaller slices more tightly coupled with compute at a finer granularity. Rather than share a remote pool, each compute node provisions "enough" local, high-bandwidth memory, enabling micrometer-scale data movement and dramatically reducing access cost. Practical challenges in transistor and memory 2D size down-scaling and memory circuitry for keeping up with speed requirements and maintaining signal margin mean that memory's share of computing costs will only grow, such that huge pools of memory will be cost-effective only for very specialized applications. Furthermore, the energy, cost, and
complexities of remote memory technologies (e.g., RDMA) will limit its use to  application-specific architectures that address operational constraints. We propose several research
directions for future application-specific memory system design. 

[the above only says what's bad about disaggregated pools of memory. It did not say anything about what's good about our "opposite approach". Should we say something what's good about our approach? - Philip]
#acmart-ccs(ccs)
#acmart-keywords(keywords)
#acmart-ref(to-string(title), authors, conference, doi)

= Introduction <sec:introduction>
Memory disaggregation is gaining traction as a way to recude memory costs and improve utilization in datacenter-scale systems [ref]. The conventional model pools memory into a shared remote tier---typically accessed over interconnects like CXL---so that compute nodes can allocate more capacity on demand. This promised to reduce stranded memory and enable flexible provisioning  across diverse workloads. 

However, this model has deep  flaws. First, memory technology scaling is slowing: SRAM and DRAM are no longer keeping pace with compute on each new node, which means they aren't getting cheaper. As logic continues to shrink, memory becomes a growing fraction of system cost---making it economically and architecturally undesirable to provision large monolithic memory pools. Second, remote memory access remain costly. Off-chip memory access shared memory polls incur prohibitively high latency, lower bandwidth, and higher energy compared to local memory attached to compute nodes. These penalties make pooled memory unsuitable for many latency-sensitive workloads.

We propose a different approach: physically composable disaggregation. Instead of pulling memory away from compute, we build systems from tightly integrated compute-memory nodes using advances in packaging technology. When application needs more memory than a single node can provide, we scale across multiple such nodes accessing peer memory over lightweight, memory-semantic interconnects. 

== Paper overview
The rest of the paper is organized as follows: 
*Section 2* explains why plateauing memory density, not just technology scaling (what does this mean?), makes traditional memory hierarchies increasingly untenable. *Section 3* quantifies thhe performance and energy costs fo remote memory pools. *Section 4* presents our revisited model for memory disaggregation. *Section 5* explores how this model support distributed, locality-aware applications. 

= The ]End of Memory Scaling: SRAM and DRAM

// xxx Walk through what's happening with SRAM and DRAM scaling: density per unit area is
// not going up, which means that they won't become cheaper. As logic shrinks, memory
// will increasingly dominate costs, which means you won't want more of it. xxx

Modern computer systems employ a hierarchical memory structure where different memory technologies are organized based on their speed, cost, and capacity characteristics. This hierarchy starts from CPU registers at the top, followed by cache memory (SRAM), main memory (DRAM), and finally storage devices (SSDs or HDDs). For decades, two-dimensional (2D) device technology scaling simultaneously enabled higher memory density and capacity at reduced cost. However, traditional 2D device scaling for both SRAM and DRAM are saturating at advanced technology nodes (Fig. x), particularly at 5-nm node and below for SRAM and xx node for DRAM [ref, we can cite the Stanford memory trend]. The primary constraint stems from physical limitations as transistor dimensions approach atomic scales, affecting both logic and memory scaling. Importantly, CMOS digital logic has better noise immunity than memory that requires mixed signal designs, making memory scaling approaching bottlenecks earlier than logic scaling. SRAM scaling has significantly stagnated, with TSMC's N3 node [ref] showing only about 5% reduction in cell size compared to N5 where historically the reduction in cell size has been x % over 2 years from xxxx to xxxx year. 

[should we discuss DRAM device scaling issues first before this sentence? I mean the device level problems. Maybe ask Xiangjin Wu to write the DRAM part?]

These scaling challenges necessitate a fundamental rethinking of memory hierarchy design -- the industry must transition from capacity-focused approaches to bandwidth and energy-efficient memory utilization strategies. 

= Locality is Efficiency (Remote Costs You)

// xxx The basics of why the cost of accessing memory increases with distance, both in terms
// of energy and performance. xxx


The memory hierarchy is organized not solely by density, capacity and cost of memory technologies, but also by proximity to the CPU, access granularity, interconnect density, and communication protocols. Cache memory exemplifies this principle—L1, L2, and L3 caches all use the same SRAM technology, yet L1 cache achieves superior performance through smaller memory bank sizes, finer-grained access, and closer physical proximity to CPU cores.

DRAM's performance and energy challenges stem primarily from its off-chip placement (computing and SRAM are on the same chip, while DRAM is on separate chips). The fundamental bottleneck lies in the limited interconnect density between separate chips (e.g. DDR5 uses only 288 pins[ref]). High-bandwidth Memory (HBM) achieves higher bandwidth by improving the integration technology to provide higher interconnect density with Silicon Interposers [ref] (e.g. HBM3E has 1024 pins [ref]). This stark difference in pin count directly translates to the bandwidth advantage of HBM over DDR DRAM. Current state-of-the-art copper hybrid bonding achieves interconnect pitches as small as 2 μm [ref]. While this represents remarkable progress, it remains approximately 87 times larger than the 23 nm interconnect pitch [ref] achieved in advanced 3-nm node. This enormous gap between on-chip and off-chip interconnect connection density necessitates higher-speed signaling circuits to compensate for limited pin density, inevitably resulting in signal integrity degradation and increased energy consumption. The energy implications are profound. Research consistently demonstrates that data movement to the compute chip consumes approximately 70% of total memory system energy, while the DRAM core operations account for only 10-15% [ref]. 

Segregating memory from computing unnecessarily increases costs, energy consumption, and sacrifices performance on interconnects, which was once a negligible component but has become the dominant bottleneck in advanced technology nodes. [ this sentence seems out of place.]



= Memory Disaggregation, Revisited

// xxx Redefine disaggregation as breaking larger memories into multiple smaller ones, more
// tightly coupled with compute. xxx
// #linebreak()

Given the above challenges, we revisit memory disaggregation from a new angle: instead of pooling memory in one remote location accessed via a hierarchy of packaging and interconnects, we break up large memory into multiple smaller units that are physically much closer to compute---effectively _distributed local memories_. 
This approach flips the script by emphasizing finer-grained coupling of memory and compute at architectural and physical levels, and is enabled by advanced 2.5D and 3D integration technologies that co-package or vertically stack memory with compute. As a result, memory accesses occur over micrometer-scale distances using dense interconnects such as hybrid bonds or through-silicon vias, dramatically reducing the latency, energy, and bandwidth bottlenecks inherent to remote memory pools connected via off-chip fabrics.

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

= Acknowledgements
#lorem(20)

#bibliography("refs.bib", title: "References", style: "association-for-computing-machinery")

#colbreak(weak: true)
#set heading(numbering: "A.a.a")

= Artifact Appendix
In this section we show how to reproduce our findings.

