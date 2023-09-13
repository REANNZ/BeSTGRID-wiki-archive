# General notes on Auckland gateway

# Hardware

The **gateway.auckland.ac.nz** Gateway Server is based on IBM System x3500 with some modifications. It has two 64-bit DualCore **3GHz** [Intel Xeon processors 5160](http://download.intel.com/products/processor/xeon/dc51kprodbrief.pdf) with 4MB shared L2 cache, 1333 MHz Front-Side Bus and supports Virtualization Technology, EM64T and Demand-Based Switching. Also there are **10GB of RAM** (667 MHz ECC Chipkill DDR2), two additional **NetXtreme** 1000 T+ Dual-Port PCI-X network card and ServeRAID-8k SAS Controller.

# Network connectivity

The Server is connected by **six** 1Gb Ethernet ports to University Network.

# Clusters connected

# General notes

Two 73GB Hot-Swap Ultra320 SAS hard drives configured as a RAID1 with total volume **68.25 GB** (XENHOST).  

Four 146GB Hot-Swap SAS drives combined to RAID5 and give **409.85 GB** of disk space (VMHOST).
