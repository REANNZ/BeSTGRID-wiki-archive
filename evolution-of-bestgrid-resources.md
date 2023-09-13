# Evolution of BeSTGRID Resources

This page documents, where we were able to track down and get reponses from the administrators of existing resources, both those currently within and those hoping to be with BeSTGRID, the considerations that were taken into account at the time those resources were deployed.

The considerations expressed here may serve to help inform choices that administrators looking to deploy new grid resources at their site would take.

## University of Auckland Grid

The UoA grid uses Torque as its Local Resource Manager (LRM)

Torque is a derivative of the Portable Batch System (PBS)

**Torque** was chosen because

>    In 2006, when the UoA grid was initially set-up, PBS was the LRM in use within
>    the Australian grid environment, APAC (now ARCS).
>    Prior to that time, APAC had been using PBS, considered it to be a de facto standard
>    for HPC in general, and so had deployed it, on familiarity grounds, into their new grid
>    environments.
>    APAC had considered also Condor for their grid environments but, at that time, chose PBS.

## University of Canterbury Resources

### Blue Fern

In June 2007, the University of Canterbury's IBM p575, acquired in 2006, became the first HPC 

resource available on BeSTGRID, later followed by the 2048-node BlueGene/L system which expanded

the facility in July 2007. Access is however only available with a personal login account.

Both systems run IBM's **LoadLeveler** as the LRM.

**LoadLeveler** was chosen because

>    it came with IBM hardware and can drive it well

### Engineering College Cluster

The Engineering College operates a Rocks/SGE cluster of about 33 nodes.

**Sun Grid Engine** (SGE) was chosen because:

>    it supports better ways of tightening down access to nodes (users can't ssh into a node
>    outside of SGE).  That is, better then PBS.

## Landcare Research SCENZ Grid Cluster

Landcare Research runs a dedicated cluster of 104 CPU running the Rocks cluster OS

**Sun Grid Engine** (SGE) was chosen because:

>   Sun Grid Engine is deployed 'out of the box', and automatically managed by the Rocks OS.

furthermore:

>   Landcare Research has significant investment in other Sun products (Sun servers and Solaris
>   in particular) so we have staff who have had some previous experience with SGE.

## Lincoln University Condor Grid

The Lincoln University Condor Grid consists of 300 cores, this are split across dual core student computer suite pcs running linux, an 8 core windows server and an 8 core linux box.

The student computer suite pcs forms the bulk of the grid and operate in a cycle scavaging mode. 

**Condor** was chosen because:

>    Condor was chosen as the local resource manager for this grid as it ran on Microsoft 
>    Windows and we had previous experience in using Condor.

The initial deployment of the condor grid was done on machines not done under the control of the Central IT Service, this allowed us to prototype and experiment with various configuration options and to run some trial problems before it was rolled out wider.

We have two classes of nodes within our Condor configuration, submit only nodes, these are typically staff machines (not included in the core count above) which can submit jobs for executing.  Execute only nodes, these are the machines in the student computer suites and can only execute jobs.

The reason for this distinction came down to grid stability, we found that staff machines can be more unreliable, particularly those machines where staff can install software.  The student computer suite pcs had a more standard and predictable software setup, these machines are also regularly reset to a standard image.

## Massey University Cluster

Massey's cluster runs Torque/PBSas its Local Resource Manager (LRM)

Torque is a derivative of the Portable Batch System (PBS).

**Torque** was chosen because 

>    when we set up our first cluster in the late 90s PBS was really the only choice. 

however they note that

>    We're not completely happy with Torque/PBS since it does have it's quirks and
>    we would probably use SGE if starting from scratch now.

but

>    Many of our users have scripts that rely on PBS and it would take some effort
>    for them to change. 

## University of Otago Cluster Resources

### Condor Cluster

A 100 node Condor cluster, within Physics, was used  between 2005-2007 but

it was abandoned because it would not work through firewalls. The master node

was debian linux, and the compute nodes were microsoft windows machines. 

We developed a one-click windows installer for our Condor grid. This

cluster was removed in 2007, and replaced by a Hadoop-based map-reduce

cluster.

We plan to interface the Hadoop cluster to BeSTGRID

**Condor** was chosen because 

>    it was easy to install.

### X-Grid Cluster

A Campus-wide X-Grid cluster is being rolled out for distributed R.

The machines are installed and configured by ITS, and it is planned to

have 400 CPUs be end of 2010.  At the moment, the only jobs submitted

are from the OGRE meta-cluster (see below).

**X-grid** was chosen because 

>    it is simple to configure mac-os based lab machines to join a cluster.

### Maggie Cluster

Maggie is a Rocks-based cluster that uses Torque as a local resource

manager. It is currently accessible through  BestGRID. Maggie was 

originally a 40 CPU cluster and began operation in 2004. 

**Torque** was chosen because

>    it is simple to install and configure and very easy for students to master.

### Amazon EC2 Clusters

We have used Amazon EC2 map-reduce clusters for large search-engine

indexing jobs. We plan to launch a distributed-R compute cluster in

the cloud, based on debian-linux machine images, for mission-critical

simulation where cycle-scavenging is not appropriate, 

**Amazon EC2** was chosen because 

>    it is scalable, we don't pay for resources we don't need and reliability is very good.

### OGRE

The OGRE distributed compute environment is designed to work through

firewalls. The code is open source and has been developed at the

University of Otago. The OGRE is a cycle scavenging meta-cluster, that

farms out compute jobs to the X-Grid cluster, two Torque based

clusters and one PBS Pro-based SGI untrix cluster. OGRE also includes

dedicated OGRE nodes on desktops. OGRE uses x509 certificates for

authentication, and a globus-ogre bridge is planned.

**OGRE** was developed because 

>    Condor was too difficult to modify, and has fundamental architectural flaws that
>    makes it very difficult for condor clusters to be deployed securely across network
>    boundaries.

## Victoria University of Wellington Resources

### VUW's SGE Grid

This 250-machine cycle-stealing grid runs on NetBSD machines in the School of Engineering and Computer

Science and the School of Mathematics, Statistics and Operational Research.

**Sun Grid Engine** (SGE) was chosen because:

>    SGE was available for NetBSD

### VUW's Condor Grid

This 950-machine cycle-stealing grid runs on public lab machines (windows) operated by VUW's

central IT facilitator, ITS. The grid itself is operated on behalf of ITS by the School of

Engineering and Computer Science

**Condor** was chosen because:

>    Condor was going to work on the ITS Windows machines without the need for extra
>    software (eg. Sun's TCP/IP stack for Windows ,, required for SGE), which would
>    have been difficult for ITS to install and I think there was also a license cost involved.
