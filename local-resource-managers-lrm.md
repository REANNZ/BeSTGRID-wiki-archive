# Local Resource Managers LRM

# Introduction

The term *Local Resource Manager* (LRM), serves as a placeholder name for a number of technologies

that all manage, within an institition-local context as opposed to managing interactions initiated

externally, computational resources.

The equivalent term for those technologies that manage externally initiated interactions

is *Gateway*.

The various technologies that can be described as LRMs perform a common enough set of

management operations that allow those who deploy and adminster them, to talk in generic

terms about those operations. The use of the term *Local Resource Manager* performs a similar

function for the software packages themselves.

The management operations of an LRM, within a computational grid context, will usually include,

but need not exclusively be limited to, the scheduling of computational tasks across the

computational resources.

# BeSTGRID's LRM technologies

The various presentations of overviews of technologies deployed within BeSTGRID 

- [http://technical.bestgrid.org/index.php/Computational_Grid_Resources](http://technical.bestgrid.org/index.php/Computational_Grid_Resources)

- [http://technical.bestgrid.org/index.php/Evolution_of_BeSTGRID_Resources](http://technical.bestgrid.org/index.php/Evolution_of_BeSTGRID_Resources)

- [http://wiki.test.bestgrid.org/index.php/IoSCCTest:TestTable](http://wiki.test.bestgrid.org/index.php/IoSCCTest:TestTable)

suggest that the following LRMs are currently in widespread use:

## Condor

### Project Homepage

[http://www.cs.wisc.edu/condor/](http://www.cs.wisc.edu/condor/)

states that:

>    The goal of the Condor® Project is to develop, implement, deploy, and evaluate mechanisms
>    and policies that support High Throughput Computing (HTC) on large collections of
>    distributively owned computing resources.

It is developed by the Condor Team at the University of Wisconsin Madison

### BeSTGRID's Precis

Condor is often used to build cycle scavenging grids, these grids typically make use of lab or staff machines when the main user isn't actively using them.  This allows a large pool of potentially underutilised resources to be harnessed and able to do useful computations.

### Related Pages from within BeSTGRID

- [The Massey Cluster](http://technical.bestgrid.org/index.php/Massey_Cluster)

## PBS/Torque

### Project Homepage

[http://www.clusterresources.com/pages/products/torque-resource-manager.php](http://www.clusterresources.com/pages/products/torque-resource-manager.php)

states that:

>    TORQUE is an open source resource manager providing control over batch jobs and
>    distributed compute nodes.

TORQUE is based on an original product called Portable Batch System (PBS) and whilst

the two names are still in use and seemingly interchangeable, PBS is more likely to

refer to a now commericially maintained version, although the company which currently

distributes PBS Professional, also have OpenPBS which they don't mantain.

### BeSTGRID's Precis

Torque is the LRM of choice for the two main providers of computational grid

resources within BeSTGRID, the Universities of Auckland and Canterbury.

### Related Pages from within BeSTGRID

- [PBS-specific instructions for setting up a Job Submission Gateway (NG2)](http://technical.bestgrid.org/index.php/Setting_up_an_NG2/PBS_specific_parts)

## Sun Grid Engine

### Project Homepage

[http://gridengine.sunsource.net](http://gridengine.sunsource.net)

states that:

>    The Grid Engine project is an open source community effort to facilitate the adoption of
>    distributed computing solutions.
>    ...
>    the Grid Engine project provides enabling distributed resource management software for
>    wide ranging requirements from compute farms to grid computing.

References to Sun Grid Engine as simply Grid Engine may increase, following Oracle's takeover

of Sun Microsystems, who initially open-sourced their Codine product as SGE. The SGE acronym 

seems likely to live on for a while, not least because of the visibility of the term within

its operating environment.

### BeSTGRID's Precis

SGE is the default LRM for Rocks clusters, Rocks itself being a popular,

packaged, operating system distribution aimed at simplifying the administration

of clusters.

### Related Pages from within BeSTGRID

- [SGE-specific instructions for setting up a Job Submission Gateway (NG2)](http://technical.bestgrid.org/index.php/Setting_up_an_NG2/SGE_specific_parts)

# Other LRMs
