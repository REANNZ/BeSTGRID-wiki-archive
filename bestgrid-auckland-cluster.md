# BeSTGRID Auckland Cluster

The new BeSTGRID [SGI Altix XE](http://www.sgi.com/products/servers/altix/xe/) based Auckland Cluster arrived in February 2008 and was commissioned during March and April 2008.

This SGI Altix XE [cluster is based on:

- Intel® Quad-Core Xeon® Processor-based architecture
- 1600 MHz front-side bus,
- 16GB of memory per compute node,
- an ultra-dense architecture that packs sixteen cores in a slim 1U form factor,
- fully-buffered DDR2 memory,
- driving the cluster with an Altix XE250 head node for advanced extensibility, redundancy, reliability, and I/O rich-features.

# Configuration

## Hardware

|                     |  **SGI Altix XE250**                                                                                                                                         |  **SGI Altix XE320**                                                                                                                           |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
|    **Purpose**      |  Head Node                                                                                                                                                   |  Compute Nodes                                                                                                                                 |
|    **Quantity**     |  1                                                                                                                                                           |  5 systems x 2 Nodes each = 10 Nodes                                                                                                           |
|    **Processors**   |  2x Dual Core Xeon 3.4GHz 6M 1600 FSB 80W [http://processorfinder.intel.com/details.aspx?sspec=slanh X5272](http://www.sgi.com/pdfs/3942.pdf)] (Harpertown)  |  2x Quad Core Xeon 2.8GHz 12M 1600 FSB 80W [E5462](http://processorfinder.intel.com/details.aspx?sspec=slant) (Harpertown) = 8 Cores per Node  |
|    **Total Cores**  |  4                                                                                                                                                           |  80                                                                                                                                            |
|    **Memory**       |  16GB Fully Buffered DIMM 800 MHz                                                                                                                            |  16GB Fully Buffered DIMM 800 MHz for each Node, 2GB per Core= 160 GB memory                                                                   |
|    **Disk space**   |  4x 750GB SATA with HW RAID                                                                                                                                  |  1x 250GB SATA for each Node                                                                                                                   |

See [here](http://www.sgi.com/products/servers/altix/xe/configs.html) for more detailed configuration

## Operating System

[Linux CentOS](http://www.centos.org/) is a standard de-facto for BeSTGRID computing environment. [CentOS 5](http://www.centos.org/docs/5/) is installed on the production cluster.

## Cluster Software

The following Cluster software is installed:

- [Rocks 5](http://www.rocksclusters.org/wordpress/?p=83) Cluster Suit
- Specific functional packages are aprt of Rocks:
	
- [Torque](http://www.clusterresources.com/pages/products/torque-resource-manager.php) - Resource Manager
- [Maui](http://www.clusterresources.com/pages/products/maui-cluster-scheduler.php) - Maui Cluster Scheduler
- [MPI-CH](http://www-unix.mcs.anl.gov/mpi/) - Message Passing Interface Libraries

## Environment

The following area available on the cluster:

- gcc
- subversion
- jdk 1.5. Created semilinks for java and javac in /usr/bin
- readline-devel and libtercap-devel (needed by mrBayes)
- mrBayes (without mpi, without Cantebury fixes)
- gcc4-c++.i386 rpm with yum (not from roll repos since couldn't satisfy dependencies.)
- gtk2-devel.i386 (not from rolls)
- lamarc (with default wxWidgets)
- emacs
- openmpi (not from rolls, but all rpms were there)
- cluslaw
- cluslaw mpi version
- modelTest
- cvs
- rpm-build
- VDT client

## Computation Packages

The following packages are installed and maintained on the cluster:

|  RPM                |  Software               |  Architecture  |  Patches  |  Dependencies                        |  Build Process        |  Install Process             |  Location                    |
| ------------------- | ----------------------- | -------------- | --------- | ------------------------------------ | --------------------- | ---------------------------- | ---------------------------- |
|  beast-1.4.7-1      |  BEAST                  |  32 bit        |  None     |  java 1.5                            |  none                 |  Create symlinks for bin     |  Devbox, Production cluster  |
|  mrbayes-3.1.2-1    |  MrBayes                |  32 bit        |  None     |  readline-devel and libtercap-devel  |  make                 |  Create symlink for mb       |  Devbox, production cluster  |
|  cluslaw-1.8-1      |  cluslaw                |  32 bit        |  None     |  none                                |  make                 |  Create symlinks             |  Devbox, Production cluster  |
|  cluslawmpi-0.13-1  |  cluslaw (MPI version)  |  32 bit        |  None     |  openmpi                             |  make                 |  Create symlinks             |  Devbox, Production cluster  |
|  lamarc-2.1.2b-1    |  Lamarc                 |  32 bit        |  None     |  gtk2-devel                          |  make install         |  Devbox, Production cluster  |                              |
|  modeltest-3.7-1    |  ModelTest              |  32 bit        |  None     |  None                                |  make (need tarball)  |  create symlinks             |  Devbox, Production cluster  |

# Installation

## Naming

The cluster is known as the BeSTGRID Auckland Cluster, with the canonical name being:

- hpc-bestgrid.auckland.ac.nz

There is also a test cluster. It's been build from three virtual machines in Xen Enterprise virtual environment with the canonical name being:
- vhpc-bestgrid.auckland.ac.nz

## Hosting Location

The Cluster will be hosted within the Tier 1 University of Auckland ITS Data Centre, within the Owen G Glenn Building.

- ITS Data Center
- [BeSTGRID Auckland Cluster install notes](/wiki/spaces/BeSTGRID/pages/3818228783)
	
- [List of MAC Addresses](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=List%20of%20MAC%20Addresses&linkCreation=true&fromPageId=3818228708)
- [Hardware positions](/wiki/spaces/BeSTGRID/pages/3818228954)

# Testing

In order to confirm the Cluster is operating correctly to meet the Grid Operating Centre (GOC) requirements, testing has been carried out, documented in [Auckland Cluster Testing](/wiki/spaces/BeSTGRID/pages/3818228618)

# Operations

The BeSTGRID Auckland Cluster is monitored within the [Grid Australia Grid Operations Centre (GOC)](http://goc.arcs.org.au/), and activity is viewable via [Ganglia](http://hpc-bestgrid.auckland.ac.nz/ganglia/).

# Projects

`:Ocean Biogeographic Information System (OBIS)`


---

`:Austronesian Basic Vocabulary and Bantu Language Databases`
