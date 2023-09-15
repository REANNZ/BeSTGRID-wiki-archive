# Concept Document for a National HPC Facility

## Table of Contents 
 - [Main Part of Document ](#main-part-of-document-)
- [See Also ](#see-also-)
- [Submission Suggestions (Alan McCulloch, AgResearch)](#submission-suggestions-(alan-mcculloch,-agresearch))
-- [Problem Domain](#problem-domain)
# Main Part of Document 

under construction

# See Also 

- [Concept Document](concept-document-for-a-national-hpc-facility.md)
- [Definitions and Descriptions of HPC Platforms](definitions-and-descriptions-of-high-performance-computing-platforms.md)
- [Science Case](science-case-for-a-national-hpc-facility.md)
- [HPC in New Zealand](current-high-performance-computing-installations-in-new-zealand.md)
- [National High Performance Computing](national-high-performance-computing.md)

= Appendices/Notes = 

# Submission Suggestions (Alan McCulloch, AgResearch)

Just my $.01. These are my own views , not necessarily AgResearch

Initial very tentative thoughts on the submission is that it needs to cover the following areas. Even in the concept stage, there would need to be at least some feel for the likely answers to these sorts of questions :  

- Previous work - what previous initiatives like this have been successful or otherwise and is there a model to follow (or avoid) ?

- Needs to have a rough overview of the likely problem domain -what sort of problems people want to solve?

- Needs to have a rough idea of projected requirements of total processor cycles, RAM, storage , connectivity and software environment (e.g. MPI/Posix).  Even if people just supply a description of the broad class of problem , there is probably enough general knowledge around to translate qualitative descriptions into rough numbers

- Needs to have a rough idea of the various types of potential user - CRI/University scientists , students and  developers/technical people ; Industry scientists , students and support staff ; Individual researchers not associated with major institutions or companies, either on their own or associated with small start-ups
- For each class , needs to acknowledge specific requirements that group may have. For example, industry and CRI may be subject to IP legal constraints, that could require consideration in the design ; things like up-time and availability on demand may be important to some users, so that the resource may need to be (flexibly) partitioned between use-classes
- Needs to have some comment on constitutional/governance matters -e.g.
- who will have access to the resource and on what basis ? ($fee ? by application , which is assessed on merit ? no restriction ? ) - for example what about researchers outside large institutions ?
- how will the success of the centre be evaluated and monitored ? - some suggestion as to non-fudgeable objective performance indicators. CPU Load ? Papers published that cite the resource ? Number of users logging in ? Customer satisfaction surveys ?
- roughly what will be the process used to respond to information obtained from the performance indicators ? - it is very unlikely the sweet spot will be hit on day one, there needs to be a process and some funding available to fix things that we got wrong, and develop and modify the setup over time in response to experience
- roughly what sort of governance will be in place and how will governors be appointed

## Problem Domain

I assume we will need to make some attempt at a survey of problems people want to use HPC to solve now and in the near future, even at concept stage.

This is a **very** incomplete and hasty potted list of a few problems from one or two areas of my institution. It is completely

inadequate but have to start somewhere ! 


|  R, Perl  |  Proposed  |   |
| --------- | ---------- | - |

|  Analysis of data from SNP chips experiments and investigation of the use of SNP chips for whole genome selection  |  various, including stochastic simulations , haplotyping , quantitative genetics methods, data mining problems , power computations |
| ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |

|  R, Perl  |  Future  |   |
| --------- | -------- | - |

|  [Spider vision](http://www.biomimetics.org.nz/drupal/node/view/69)  |  Neural Networks with Genetic Algorithms |
| -------------------------------------------------------------------- | ---------------------------------------- |

|  Custom in-house software  |  Development  |   |
| -------------------------- | ------------- | - |

|  Minimum/optimal tiling path  |  Dynamic programming |
| ----------------------------- | -------------------- |

|  Custom in-house software  |  Development  |
| -------------------------- | ------------- |
