# Auckland Cluster Infrastructure

# Gateways 

# Production

[Upgrading NG2](/wiki/spaces/BeSTGRID/pages/3818228661)

# Test

Is used to share virtual test cluster.

[Auckland Test Gateway](/wiki/spaces/BeSTGRID/pages/3818228485) - ng2test.auckland.ac.nz

# Clusters 

# Production

# Reference

Consists of single front node, and is used to bootstrap other frontends in case of failure or upgrade. 

Hosts **restore** rolls for test and production clusters, **development** roll with all applications that are not in standard rolls, and standard rolls that we use.

## Contents of Restore Roll

- Network configuration of nodes. i.e. contents of **rocks dump**
- System configuration files. Specified in /src/system-files/version.mk
	
- /etc/passwd
- /etc/shadow
- /etc/gshadow
- /etc/group
- /etc/exports
- /etc/auto.home
- /etc/motd
- Other configuration files. Specified in ./version.mk
	
- /etc/X11/xorg.conf
- /etc/sysconfig/iptables
- /etc/hosts.equiv

Any other configuration files should be added to version.mk in top level directory.

To create a restore roll, go to /export/site-roll/rocks/src/roll/restore directory on the cluster and run

>  make roll

To add roll to reference cluster without installing it (as it contains specific networking information and should be installed on one cluster only), go to reference cluster and run


## Contents of Development Roll

- not decided yet *

## [Auckland Rocks Cluster Backup and Restore Procedure](/wiki/spaces/BeSTGRID/pages/3818228576)

# Test

[Auckland Cluster Testing](/wiki/spaces/BeSTGRID/pages/3818228618) 

# Documentation 

[WAN kickstart](http://www.rocksclusters.org/roll-documentation/base/5.0/central.html)

[Roll Development Guide](http://www.rocksclusters.org/rocks-documentation/reference-guide/4.3/)

[Upgrade and Reconfiguration of Frontend](http://www.rocksclusters.org/roll-documentation/base/5.0/upgrade-frontend.html)
