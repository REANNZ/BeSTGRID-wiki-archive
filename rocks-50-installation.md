# Rocks 5.0 Installation

Rocks 5.0 based on CentOS 5.0. This OS recognizes the network card of the Headnode. 

But Auto Partitioning mode creates [GUID Partition Table](http://en.wikipedia.org/wiki/GUID_Partition_Table) and then Rocks doesn't continue the installation on this partition table.

We had to created MSDOS partition table manually and then Rocks finished installation:

# Partition table

``` 

Model: LSI MegaRAID 8708ELP (scsi)
Disk /dev/sda: 2247GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos

Number  Start   End     Size    Type      File system  Flags
 1      32.3kB  10.0GB  10.0GB  primary   ext3         boot
 2      10.0GB  510GB   500GB   primary   ext3
 3      510GB   2247GB  1737GB  extended               lba
 5      510GB   514GB   4294MB  logical   ext3
 6      514GB   515GB   1077MB  logical   linux-swap
 7      515GB   2247GB  1732GB  logical                lvm

```

Rocks requirements for some partitions: 

>  **at least 8GB for**/*, so 10GB has been allocated
>  **at least 4GB for**/var*, so 4GB has been allocated
>  **rest of disk to be allocated to**/export*

Because single MSDOS partition shouldn't be large 2TB and total size of RAID-5 on the Headnode is 2247GB, we allocated 500G for **/export** to make a remaining space less than 2TB.

Another issue is that LVM is not supported by Rocks ([Paragraph 15](http://www.rocksclusters.org/rocks-documentation/4.3/install-frontend.html)). So on next incarnation of Rocks we will create another partition to allocate remaining space. 

Directories mounted on compute nodes are specified in /etc/auto.share /etc/auto.home

# Network Interfaces

The headnode has **two** physical network plugs and **three** NICs. Two of them are ordinary NICs installed on the motherboard and third one is a NIC built in Board Management Controller (BMC). 

The BMC monitors onboard instrumentation such as temperature sensors, power status, voltages and fan speed, and provides remote power control capabilities to reboot and/or reset the server. It also includes remote access to the BIOS configuration and operating system console information via serial-over-LAN (SOL) or embedded KVM capabilities. Because the controller is a separate processor, the monitoring and control functions work regardless of CPU operation or system power-on status.

Rocks always uses eth0 for private network and eth1 for public network. BMC shares network connection with 00:30:48:7F:71:88 therefore eth0 must be :89. But during boot it assigns eth0 => 88 and eth1 => 89. The easiest way to change this is in rocks database **cluster**, table **networks**. Then run

>  rocks sync config

The resulting values in **networks** table are

>  ------------------------------------------------------------------------------------------------------------+

|  ID  |  Node  |  MAC                |  IP              |  Netmask  |  Gateway          |  Name             |  Device  |  Subnet  |  Module  |  Options  |  Comment  |
| ---- | ------ | ------------------- | ---------------- | --------- | ----------------- | ----------------- | -------- | -------- | -------- | --------- | --------- |

>  ------------------------------------------------------------------------------------------------------------+

|   1  |     1  |  00:30:48:7f:71:89  |  10.1.1.1        |  NULL     |  NULL             |  cluster          |  eth0    |       1  |  igb     |  NULL     |  NULL     |
| ---- | ------ | ------------------- | ---------------- | --------- | ----------------- | ----------------- | -------- | -------- | -------- | --------- | --------- |
|   2  |     1  |  00:30:48:7f:71:88  |  130.216.189.80  |  NULL     |  130.216.189.254  |  cluster.hpc.org  |  eth1    |       2  |  igb     |  NULL     |  NULL     |

>  ------------------------------------------------------------------------------------------------------------+

**Update** For some reason, I had to modify /etc/sysconfig/network-scripts by hand even after *rocks sync config* command.

# Installing compute nodes

There are 3 ways to monitor installation:

- connect display
- use rocks-console compute-x-x (needs X running on frontnode)
- use ssh -p 2200 compute-x-x (not sure how it works, but does not require X). requires verification.

(unconfirmed, from the rocks mailing list).

To insert NAS appliance, it has to be manually repartitioned.
