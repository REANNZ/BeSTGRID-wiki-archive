# Xen Install

[To The Gateway Server Configuration](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=The_GateWay_Configuration&linkCreation=true&fromPageId=3818228529)

During basic Xen install we were following the procedure described in [APACGrid twiki page](http://wiki.arcs.org.au/twiki/bin/view/APACgrid/XenInstall).

There were some changes which we've implemented in this sequence:

### Partitioning:

- partitions on XENHOST volume:
	
- sda1 / ext3 10GB
- sda2 swap 2GB
- sda3 /home ext3 57.8GB (remain space)
- partitions on VMHOST volume:
	
- sdb1 LVM PV 409.85GB

**Xen version:**

The latest version of Xen (**3.0.4-1**) has been downloaded and installed. 

That led to changing the version of boot files to:
- initrd.img-2.6.16.33-xen
- vmlinuz-2.6.16.33-xen
