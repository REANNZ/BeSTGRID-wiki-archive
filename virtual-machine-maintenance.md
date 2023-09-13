# Virtual Machine Maintenance

# Basic Xen Information 

- Domain0 is the Xen jargon name for your physical host machine. The virtual machines are sometimes called DomainU (or Domain1, Domain2,...).

- Xen Virtual Machines have configuration files that are stored in /etc/xen/ on Domain0 - the physical host machine.

- Xen Virtual Machines can be set to boot with the physical machine, if a symbolic link to their Xen configuration file is placed in /etc/xen/auto.

# Basic Xen Commands 

- To get a list of the currently active Xen Virtual Machines:


>  xm list
>  xm list


- To manually shutdown a Xen Virtual Machine:


>  xm shutdown NAME
>  xm shutdown NAME

# Common Xen Problems 

If the 'xm list' command shows that a machine is powered on, but the 'State' is not set to 'b', you will not be able to access the machine. Either the machine is still booting, or has failed to boot properly, and is stuck in the famous Xen 'limbo' mode. Example:

>  [unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dgridserver%2B%7E%3Bsearch%3Fq%3Droot)# xm list
>  Name                                      ID Mem(MiB) VCPUs State   Time(s)
>  Domain-0                                   0     2070     2 r-----  54374.1
>  ng2i386_v2                                94     1515     2 b---   3922.4
>  ngnfs                                     92      781     1 b---   1619.0
>  testStor                                  95     1030     1 -p--      0.0

The physical machine is in state 'r'. Two working virtual machines (ng2i386_v2 and ngnfs) are in state 'b'. A third virtual machine (testStor) was not able to get through the boot process (is in state 'p') and can not be accessed.

The most common cause of the Xen limbo is that the machine is being booted via SSH, and is trying to launch a console using graphical TTY which it can not access.

To start the machine remotely and also grab its console (rather than just SSH login):

>  ssh -XC root@it040106 "xm create -c testStor"

where 'it040106' is the domain name of the physical machine, and 'testStor' is the name of the virtual machine.

# Machine Boot Order 

To get the grid infrastructure of virtual and physical machines running, they should be booted in a specific order:

1. Storage Machines that will be used for user data.
2. Shared homes and binaries machine containing NFS server.
3. Compute Cluster Head Node Machine containing PBS server.
4. Globus Gateway machine (called 'ng2i386_v2' at Massey).

At Massey only the Gateway is a Virtual Machine, the others are all on physical machines, so starting the Gloubus Virtual Machines is not complicated:

>  ssh -XC root@it040106 "xm create -c ng2i386_v2"

# Accessing Virtual Machines 

All of the virtual machines and other servers are command-line based, with no graphical support. To access the machines for maintenance, to see if the /homes have mounted for example, you can simply SSH into the machines in the usual manner.
