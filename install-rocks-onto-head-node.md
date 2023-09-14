# Install Rocks onto Head Node

Rocks 5.0 (V) for i386 and x86_64 architectures has been released on 30th April. Thus we have used a released version for the second iteration.

# Partition table

We recreated partitions for the iteration 2. Previous layout has been described [here](/wiki/spaces/BeSTGRID/pages/3818228624).

Rocks 5.0 ISO file has been connected via IPMI/BMC tool to the Headnode. The Headnode had been rebooted with option:

>  frontend rescue

After setting Network parameters a window with 3 options appeared on a screen. To open shell one should choose "**Skip**".

The following set of command had been executed to recreate partitions:

``` 

# to delete previous partitions
parted /dev/sda rm 7
parted /dev/sda rm 6
parted /dev/sda rm 5
parted /dev/sda rm 3
parted /dev/sda rm 2
parted /dev/sda rm 1
# to make partition table MBR based (instead of GPT which is unsupported by grub
parted /dev/sda mklabel msdos
# to create / partition
parted /dev/sda mkpart primary ext3 0 10GB
# to create /tmp partition and make the remaining space less than 2TB
parted /dev/sda mkpart primary ext3 10GB 50GB
# to create extended partition for remaining space
parted /dev/sda mkpart extended 50GB 2247GB
# to create /var partition
parted /dev/sda mkpart logical ext3 50GB 60GB
# to create /export partition for the remaining space
parted /dev/sda mkpart logical ext3 60GB 2247GB
# to make first partition bootable
parted /dev/sda set 1 boot on

```

# Installation of Rocks

After rebooting via BMC console a standard mode to install Rocks had been chosen:

>  frontend

The following rolls had been selected:

- area51
- base
- bio
- ganglia
- hpc
- java
- kernel
- os
- web-server

Domain name of the production cluster is **hpc-bestgrid.auckland.ac.nz**

Public IP Address is **130.216.189.80**

The installation had been finished without any issues.

Network interfaces had been swapped according the [this note](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Rocks_5.0_Installation&linkCreation=true&fromPageId=3818228980).

# Convention for IP addresses and node names of the Cluster

The following convention for IP addresses and node names had been admitted:

1. compute nodes named as **compute-1**...**compute-10**
2. eth0 interfaces of each node have IPs in a range **10.0.1.1-10.0.1.10**
3. aliases for eth0 interfaces are **compute-1**...**compute-10**
4. eth1 interfaces of each node have IPs in a range **10.0.2.1-10.0.2.10**
5. aliases for eth1 interfaces are **mgr-1**...**mgr-10**
6. BMCs of each node have IPs in a range **10.0.3.1-10.0.3.10**
7. Nodes should have IPs and names assigned in their physical order in racks
