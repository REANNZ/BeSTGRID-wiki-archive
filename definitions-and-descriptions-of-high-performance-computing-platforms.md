# Definitions and Descriptions of High Performance Computing Platforms

## Table of Contents 
 - [Beowulf Clusters](#beowulf-clusters)
-- [Embarrassingly parallel problems](#embarrassingly-parallel-problems)
- [HPC clusters](#hpc-clusters)
- [Super-clusters or 'Lumpy' configurations](#super-clusters-or-'lumpy'-configurations)
- [FPGAs](#fpgas)
- [See Also](#see-also)
# Beowulf Clusters

**Beowulf** is a design for high-performance parallel computing clusters on inexpensive 'commodity' hardware. 

A **Beowulf** is [typically defined](http://en.wikipedia.org/wiki/Beowulf_cluster) as a group of usually identical PC computers running a Free and Open Source Software (FOSS) Unix-like operating system, such as Linux or BSD. They are networked into a small TCP/IP LAN, and have libraries and programs installed which allow processing to be shared among them.

There is no particular piece of software that defines a cluster as a Beowulf. Commonly used parallel processing libraries include MPI (Message Passing Interface) and PVM (Parallel Virtual Machine). Both of these permit the programmer to divide a task among a group of networked computers, and recollect the results of processing. It is a common misconception that any software will run faster on a Beowulf.  The software must be re-written to take advantage of the cluster, and specifically have multiple non-dependent parallel computations involved in its execution.

## Embarrassingly parallel problems

A common use of these clusters in practice is to provide much improved performance on [embarrassingly parallel problems](http://en.wikipedia.org/wiki/Embarrassingly_parallel_problem) - for this class of problem , no software rewrites are required and much improved throughput can always be obtained.  A typical example of such a problem would be , to find protein sequences, or sequence models, in a given large database , that are similar to sequences in a given large batch of query sequences or models. The phrase "embarrassingly parallel" is used to describe this problem, because it is very easy to arrange for the problem to be solved by a number of processes running concurrently, but **independently**, on a cluster or server farm. The reason these problems are "easy to arrange" , is that they do not require the use of special parallel libraries such as MPI and PVM - standard libraries and binaries can be used.  In the case of database searching, for example, each node in the cluster typically contains a copy of the databaset to be searched, and the standard search program libraries (such as blast, hmmersearch etc), and the batch of sequences to be searched is simply broken into chunks , and each chunk is searched against the database concurrently on each node, and the results are concatenated at the end.

Although perhaps not always considered a true example of "super", or "high performance" computing, in practice this class of problem is important, and solving it is a standard but critical part of many of the high throughput experimental systems in moderm biology, such as DNA sequencing and expression profiling (microarray), so that , for example, large sequencing runs can be annotated in a day even on a modest sized cluster , instead of the month it might take on one or two machines.

The class of problems that are treatable in this way is probably quite large. In statistics, compute intensive methods such as permutation tests and bootstrapping are examples of this type of easily parallelisable approach.  Some problems which in theory cannot be solved by concurrent but independent processes , neverthless can be in practice, either because in practice the data or model can be partitioned into independent chunks (e.g. diagonalising , or near-diagonalising matrices, and processing sub-matrices independently, then merging at the end) , or can be so partitioned by making appropriate simplifying approximations. 

# HPC clusters

- Typically a large number of machines with 8 cores and 16GB RAM interconnected with Gigabit Ethernet (or more recently Infiniband or equivalent).
- 8 core 32GB RAM machine configurations also available as well as 8 core 64GB RAM configurations
- Many HPC workloads require less than 8 cores and 2GB RAM per processing core.

# Super-clusters or 'Lumpy' configurations

- Typically made up of numerous 16 or 32-PROC machines each with 128GB of memory, and interconnected by infinband or equivalent
- Running full POSIX environments, like Linux and pre-built tools
- Favoured in Australia as they provide for a wide range of tools and software packages catering for a broad spectrum of disciplines.
- They provide good support the scientist who doesn't have time for coding OpenMP or MPI, and wants to run pre-developed tools and packages.

**SUPERCOMPUTERS**

(Supercomputers, e.g. Cray, Blue Gene)

# FPGAs

Tim Molteno writes:

I am responding here on behalf of our Electronics Research group in the Otago Physics Department.

For the past two years we have been using a cluster of 15 AMD-64 machines for electromagnetic optimisation and logic design synthesis problems. The majority of these problems are embarrassingly parallel. The code is all custom written in either C++ or mercury. We use MPI for interprocess communication for some simulations and have for the last year used CONDOR for job scheduling.

We have also developed (as part of our research) application specific hardware for computation. At this point geared towards the acceleration of physics simulations as well as rendering.  Our approach is similar to that used by the CRAY XD1 - but in this instance we have developed our own hardware based around Xilinx FPGA's. 

Thus our interest in the national HPC centre is twofold. First, we would be interested in running large electromagnetic optimisation problems on a very large cluster, and second we would like to use a research network like KAREN to explore the integration of our application specific supercomputing hardware into a high-performance computing environment.

If the HPC cluster were to use machines with reconfigurable hardware (i.e. 

FPGA co-processors). Then we would be particularly interested as these systems offer incredible performance advantages if the FPGA is programmed directly. 

We have developed several frameworks for Application Specific Supercomputing in Hardware at Otago, and see the development of a national HPC infrastructure as an excellent opportunity to provide a focus for New Zealand researchers in this area. Indeed, as recent articles [1](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=1&linkCreation=true&fromPageId=3818228416) have shown, this kind of application specific hardware is likely to become a significant part the HPC landscape, and I would hope that our national HPC facilities are geared toward these exciting future technologies.

# See Also

- [Concept Document](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Concept_Document_for_a_National_HPC_Facility&linkCreation=true&fromPageId=3818228416)
- [Definitions and Descriptions of HPC Platforms](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Definitions_and_Descriptions_of_High_Performance_Computing_Platforms&linkCreation=true&fromPageId=3818228416)
- [Science Case](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Science_Case_for_a_National_HPC_Facility&linkCreation=true&fromPageId=3818228416)
- [HPC in New Zealand](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Current_High_Performance_Computing_Installations_in_New_Zealand&linkCreation=true&fromPageId=3818228416)
- [National High Performance Computing](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=National_High_Performance_Computing&linkCreation=true&fromPageId=3818228416)
