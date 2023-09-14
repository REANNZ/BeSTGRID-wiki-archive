# Setup NGData (SRB) at University of Canterbury

The NGData virtual machine will host the SRB server: this machine will also run a GridFTP server - both to directly access the data on the HPC storage and as an interface to SRB.

# Preparation and system installation

- The system will need sufficient disk space for the metadata, hence creating it with 20G disk space and a 2G swap.
- The system has to run CentOS-5 (required by ARCS SRB packages), hence [install it as CentOS 5](/wiki/spaces/BeSTGRID/pages/3818228741)
- The system will need an X509 host certificate.

# Integration with HPC internal network

- The system will need two network interfaces: one for accessing the HPC internal network.
- The system should use dedicated network interfaces (via pciback) to have a non-copying network path - otherwise, there would be a serious penalty on data throughput.

- So far creating the system with just virtual Xen adapters
	
- Configure two virtual adapters in the Xen domain configuration file: 

``` 
vif = [ 'mac=00:16:3e:84:B5:03, bridge=xenbr0', 'mac=00:16:3E:C0:A8:03,bridge=xenbr1' ]
```
- Configure eth1 with a static network address:

``` 

ONBOOT=yes
USERCTL=no
IPV6INIT=no
PEERDNS=yes
TYPE=Ethernet
DEVICE=eth1
HWADDR=00:16:3E:C0:A8:03
BOOTPROTO=none
NETMASK=255.255.255.0
IPADDR=192.168.4.204

```

- Update `/etc/hosts` with new "Cluster Management Network (VLAN 4)" (from HPC cluster-wide `/etc/hosts`)

- Create entries in /etc/fstab:


>  hpcgrid1-c:/hpc/gridusers      /hpc/gridusers   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/griddata      /hpc/griddata   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/home      /hpc/home   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/projects      /hpc/projects   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/work      /hpc/work   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/bluefern      /hpc/bluefern   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/gridusers      /hpc/gridusers   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/griddata      /hpc/griddata   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/home      /hpc/home   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/projects      /hpc/projects   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/work      /hpc/work   nfs     fg,retry=20,hard    0 0
>  hpcgrid1-c:/hpc/bluefern      /hpc/bluefern   nfs     fg,retry=20,hard    0 0

- Create mount-points


>  mkdir -p /hpc/{home,work,projects,bluefern,griddata,gridusers}
>  mkdir -p /hpc/{home,work,projects,bluefern,griddata,gridusers}

- Enable and start portmap, nfslock, and netfs (automount these fs)


>  for I in portmap nfslock netfs ; do service $I start ; chkconfig $I on ; done
>  for I in portmap nfslock netfs ; do service $I start ; chkconfig $I on ; done

# SRB installation

- Follow [http://projects.arcs.org.au/trac/systems/wiki/DataServices/SRBQuickStart](http://projects.arcs.org.au/trac/systems/wiki/DataServices/SRBQuickStart)
- Start with installing MARCS yum repo:


>  wget [http://projects.arcs.org.au/marcs/marcs.repo](http://projects.arcs.org.au/marcs/marcs.repo) -P /etc/yum.repos.d/
>  wget [http://projects.arcs.org.au/marcs/marcs.repo](http://projects.arcs.org.au/marcs/marcs.repo) -P /etc/yum.repos.d/

- Install SRB binary packages:


>  yum install gridFTP_SRB_DSI.i386
>  yum install gridFTP_SRB_DSI.i386

- ***Note:** at this point, `/etc/grid-security` SHOULD exist - otherwise, an installation scriptlet creating `/etc/grid-security/grid-mapfile.srb` fails.

# What's left for SRB post-configuration


- Follow the configuration instruction printed by the gridFTP_SRB_DSI post-installation scriptlet:

``` 

Please add
srb_hostname_dn <YOUR SERVER DN>
srb_default_resource <YOU DEFAULT RESOURCE>
to /usr/srb/globus/etc/gridftp_srb.conf.
If you want to use to auto command execution feature,
you will also have to add:
srb_auto_executable <THE FULL PATH OF THE EXECUTABLE>
srb_user_name <THE UNIX USER TO RUN THE EXECUTABLE>
The grid-mapfile for the SRB DSI can be found at:
/etc/grid-security/grid-mapfile.srb

```
