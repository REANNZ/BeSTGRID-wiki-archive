# Virtual Machines

# Virtual Machine Overview 

Each of the grid head nodes hosts a variety of virtual machines that encapsulate different functionality of the cluster.

We are following the guidelines of the [Australian Partnership for Advanced Computing](http://www.apac.edu.au/) (APAC), who have several years experience with virtualisation for grids.

# Virtualisation Technologies 

Something about KVM,Xen kernels, and VMWAre goes here.

We are using Xen kernels, which use a Hypervisor approach...

# Virtual Machines Being Used by BeSTGRID Head Nodes 

# NGCompute

## About NGCompute

The role of National Gateway Compute, or NGCompute, is to house Portable Batch System (PBS) software which receives jobs that users have submitted and allocates them to a cluster.

NGCompute is a virtual machine representing the head node of a computational cluster. Traditionally, this would be a separate physical machine, but with a Xen kernel technology, this machine can be housed on any multi-core processing machine. The NGCompute machine at Massey, for example, is a virtual machine held on the gateway machine.

A variety of PBS software can be used, and made to communicate with the Virtual Data Toolkit (VDT) implementation of the Globus Toolkit. [Torque PBS](http://www.clusterresources.com/pages/products/torque-resource-manager.php) is natively supported in VDT, but it is also possible to use the [Sun Grid Engine](http://gridengine.sunsource.net/) or [OpenPBS](http://www.openpbs.org/), although these may require significant adjustment to VDT/Globus install scripts.

PBS Server was not designed to be run on a separate machine from the submission gateway machine, so a number of workarounds have been created to duplicate log file; to make the client tools and PBS server think they are on the same machine. These are pbs-logmaker and pbs-telltail, which are available from the APAC repository.

## Set Up Information

First it is necessary to create a new virtual machine on a Xen-kernel machine.

For virtual machine set-up see:

- [APAC Grid Xen Install](http://www.vpac.org/twiki/bin/view/APACgrid/XenInstall)
- [Vladimir__Bootstrapping_a_virtual_machine](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Bootstrapping_a_virtual_machine&linkCreation=true&fromPageId=3816950830)

After which PBS can be installed and set-up on the virtual machine.

For detailed guides on NGCompute and PBS set-up:

- [Vladimir__Setup NGCompute](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20NGCompute&linkCreation=true&fromPageId=3816950830)

## Set Up Information

# NG2

## About NG2

## Set Up Information

- [Massey NG2 Gateway Set Up Notes](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Massey%20NG2%20Gateway%20Set%20Up%20Notes&linkCreation=true&fromPageId=3816950830)
