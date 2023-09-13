# Auckland Cluster Testing

# Development System

on VM in data center. I will use it for development before test cluster stabilizes.

To ensure consistency with Rocks environment I am using rpms from standard rolls, if available. Currently they are under /home/yhal003/RPMS 

OS: CentOS 4.4

IP: 130.216.189.66

## Dependencies

packages not available in default rolls and needed for the distribution.

libtermcap-devel.i386

## Issues

- when run without arguments, beast needs X for file chooser. probably not an issue, but...

# Globus Testing

Development machine is also set up to submit jobs on gateway.


# Test Cluster

All nodes of test cluster are virtual machines running on Xen VM.  This allows us to get  64 bit Rocks 5.0 environment, the same as on production cluster.  Currently test cluster consists of frontnode and two compute nodes.

## Install Notes

*add install notes *

## Configuration

Frontend IP: 130.216.189.82

## How To Point Gateway To The Right Cluster

Just edit /usr/spool/PBS/server_name

# Possible Problems with Rocks Installation


# Documentation

[ Rocks user guide|http://www.rocksclusters.org/rocks-documentation/4.3/]

[http://www.bestgrid.org/index.php/Bioinformatics_applications_at_University_of_Canterbury_HPC](http://www.bestgrid.org/index.php/Bioinformatics_applications_at_University_of_Canterbury_HPC)
