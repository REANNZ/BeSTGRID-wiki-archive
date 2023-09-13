# Auckland NG2 Setup with VDT 1.10

NG2 Gateway deployed on new Xen infrastructure.

- hostname ng2hpc.ceres.auckland.ac.nz
- IP 130.216.189.201
- OS CentOS 5.3
- test machine ng2test.auckland.ac.nz (130.216.189.8)

# Preliminaries

Open ports

|  protocol  |  range          |  description      |
| ---------- | --------------- | ----------------- |
|  tcp       |  80             |  yum              |
|  tcp       |  443            |  yum              |
|  tcp       |  8443           |  tomcat           |
|  tcp       |  2811           |  gridftp control  |
|  tcp       |  39999 - 41001  |  gridftp data     |

> 1. add ARCs repository
>  cd /etc/yum.repos.d && wget [http://projects.arcs.org.au/dist/arcs.repo](http://projects.arcs.org.au/dist/arcs.repo)
>  yum update

## Install CA bundle and apply for host certificate

We only need [APAC](http://wiki.arcs.org.au/bin/view/Main/InstallCABundle) bundle:

>  cd /etc/
>  wget [http://wiki.arcs.org.au/pub/Main/InstallCABundle/APACGrid_CA_Bundle_Full.tar.gz](http://wiki.arcs.org.au/pub/Main/InstallCABundle/APACGrid_CA_Bundle_Full.tar.gz)
>  tar -xzvf APACGrid_CA_Bundle_Full.tar.gz
>  rm APACGrid_CA_Bundle_Full.tar.gz
>  cd /opt/vdt/globus
>  ln -s /etc/grid-security/certificates
>  mv certificates TRUSTED_CA

Apply for host certificate using [openssl](http://wiki.arcs.org.au/bin/view/Main/HostCertificates) method.

we need both host certificate and container certificate:

>  cp /etc/grid-security/hostcert.pem /etc/grid-security/containercert.pem
>  cp /etc/grid-security/hostkey.pem /etc/grid-security/containerkey.pem

# Install and Configure Pacman

[Pacman](http://atlas.bu.edu/~youssef/pacman/) is a package manager used to install [VDT](http://vdt.cs.wisc.edu).

> 1. download pacman tar
>  wget [http://atlas.bu.edu/~youssef/pacman/sample_cache/tarballs/pacman-latest.tar.gz](http://atlas.bu.edu/~youssef/pacman/sample_cache/tarballs/pacman-latest.tar.gz)
>  tar -zxf pacman-latest.tar.gz
>  cd pacman-3.26/
>  . setup.sh

# VDT

Install globus web services:

>  mkdir /opt/vdt
>  cd /opt/vdt
>  pacman -get [http://vdt.cs.wisc.edu/vdt_1101_cache:Globus-WS](http://vdt.cs.wisc.edu/vdt_1101_cache:Globus-WS)
> 1. install as root, all other questions as "yes"
>  pacman -get [http://vdt.cs.wisc.edu/vdt_1101_cache:Globus-WS-PBS-Setup](http://vdt.cs.wisc.edu/vdt_1101_cache:Globus-WS-PBS-Setup)

Setup [sudo](http://vdt.cs.wisc.edu/releases/1.10.1/installation_post_server.html) for globus web services.

Install gatekeeper (globus authentication service)

>  pacman -get [http://vdt.cs.wisc.edu/vdt_1101_cache:VDT-Gatekeeper](http://vdt.cs.wisc.edu/vdt_1101_cache:VDT-Gatekeeper)

copy grid-mapfile from ng2 to new gateway (needed temporarily)

setup gridftp port range in /opt/vdt/setup.sh :

>  export GLOBUS_TCP_PORT_RANGE=40000,41000

# GUMS

install PRIMA

>  pacman -get [http://vdt.cs.wisc.edu/vdt_1101_cache:PRIMA-GT4](http://vdt.cs.wisc.edu/vdt_1101_cache:PRIMA-GT4)

see ARCS modifications section

To configure PRIMA with our GUMS server:

>  /opt/vdt/vdt/setup/configure_prima_gt4 --enable --gums-server nggums.auckland.ac.nz
>  vdt-control --off
>  vdt-control --on

# MDS

Monitoring and Discovery Service is used to publish information about grid resources. Published data is based on

abstract [Glue Schema](http://glueschema.forge.cnaf.infn.it/uploads/Spec/GLUEInfoModel_1_2_final.pdf) and is not tied up to particular data format. However most ARCS tools work with [XML Implementation](http://glueschema.forge.cnaf.infn.it/Mapping/XMLSchema%20implementation) of GLUE.

[http://projects.gridaus.org.au/trac/systems/wiki/InfoSystems/IntegrateGridAusInfoServiceProvider](http://projects.gridaus.org.au/trac/systems/wiki/InfoSystems/IntegrateGridAusInfoServiceProvider)

Copied that metadata file from original gateway. Need the following files:

>  /usr/local/mip/config/apac_config.py
>  /usr/local/mip/config/default.pl
>  /usr/local/mip/config/*.ini

Also need to replace references to ng2.auckland.ac.nz:

>  sed -i -e 's/ng2.auckland.ac.nz/ng2hpc.ceres.auckland.ac.nz/' /usr/local/mip/config/apac_config.py
>  sed -i -e 's/ng2.auckland.ac.nz/ng2hpc.ceres.auckland.ac.nz/' /usr/local/mip/config/*.pl

To publish MDS data to ARCS service:

>  yum install APAC-mip-globus
>  /usr/local/mip/config/globus/mip-exec.sh -validate
>  vdt-control -off; vdt-control -on;

# GSISSH

>  pacman -get [http://vdt.cs.wisc.edu/vdt_1101_cache:GSIOpenSSH](http://vdt.cs.wisc.edu/vdt_1101_cache:GSIOpenSSH)

I also run it on 22 port so it is only possible to login with certificate.

# ARCS Modifications

[ARCS Installation Instructions For VDT 1.10](http://projects.gridaus.org.au/trac/systems/wiki/HowTo/Ng2Centos5)

Points of interest:

- moving from 9443 to 8443 port
- configure GUMS authentication

GGateway contains auditquery script that runs as a cronjob and sends an email with grid usage to ARCS.

Gtroque-client is Torque client that can send jobs to remote Torque server (such as the cluster).

pbs-telltail contains scripts to transfer pbs logs from the cluster to gateway

>  yum install Gtorque-client Ggateway pbs-telltail
> 1. location of torque logs, necessary for Globus to interact with torque
>  echo "log_path=/usr/spool/PBS/server_logs" > /opt/vdt/globus/etc/globus-pbs.conf

update /usr/spool/PBS/server_name to point to hpc-bestgrid.auckland.ac.nz

# Gridpulse

All grid systems should report their status to [http://status.arcs.org.au/](http://status.arcs.org.au/)

The script that sends an email is installed with APAC-gateway-gridpulse rpm.

We need some extra steps to ensure this script functions correctly

>  chmod +x /usr/local/lib/gridpulse/system_packages.pulse
>  /sbin/chkconfig --del acpid
>  /sbin/chkconfig --del mdmonitor
>  /sbin/chkconfig --del cpuspeed

# Local Modifications

Some modifications to default install procedure are specific for Auckland site.

## NFS Between Cluster and Gateway

The cluster needs to export NFS shares for every user. Edit /etc/exports:

>  /home/grid-bestgrid 130.216.189.201(async,no_subtree_check,rw)
>  /home/grid-bird 130.216.189.201(async,no_subtree_check,rw)
>  /home/grid-lyndon 130.216.189.201(async,no_subtree_check,rw)
>  /home/grid-browning 130.216.189.201(async,no_subtree_check,rw)
>  /home/grid-admin 130.216.189.201(async,no_subtree_check,rw)
>  /home/grid-bio 130.216.189.201(async,no_subtree_check,rw)

Restart NFS on cluster:

>  /sbin/service nfs restart

Edit /etc/sysconfig/iptables on cluster:

>  -A INPUT -p tcp -s 130.216.189.201 -j ACCEPT
>  -A INPUT -p udp -s 130.216.189.201 -j ACCEPT

Restart iptables on cluster

>  /sbin/service iptables restart

Edit /etc/fstab on gateway:

>  hpc-bestgrid.auckland.ac.nz:/home/grid-bestgrid /home/grid-bestgrid nfs defaults 0 0
>  hpc-bestgrid.auckland.ac.nz:/home/grid-browning /home/grid-browning nfs defaults 0 0
>  hpc-bestgrid.auckland.ac.nz:/home/grid-bird /home/grid-bird nfs defaults 0 0
>  hpc-bestgrid.auckland.ac.nz:/home/grid-lyndon /home/grid-lyndon nfs defaults 0 0
>  hpc-bestgrid.auckland.ac.nz:/home/grid-bio /home/grid-bio nfs defaults 0 0
>  hpc-bestgrid.auckland.ac.nz:/home/grid-admin /home/grid-admin nfs defaults 0 0

Mount directories:

>  mount -v /home/grid-bestgrid
>  mount -v /home/grid-bestgrid
>  mount -v /home/grid-browning
>  mount -v /home/grid-bio
>  mount -v /home/grid-admin

## Enable Passwordless SSH between ng2 and cluster

nothing to do, since NFS home directory already contains all public keys 🙂

## . Authorise torque client

In order to submit jobs using torque client from the gateway we need to add ng2hpc.ceres.auckland.ac.nz to /etc/hosts.equiv on the cluster

## Custom PBS.pm

Need to get latest version from SVN repository.

> 1. replace username with your own.
>  curl --user yhal003 [https://subversion.auckland.ac.nz/svn/UoA.ITSS.EAO/eResearch/scripts/pbs.pm](https://subversion.auckland.ac.nz/svn/UoA.ITSS.EAO/eResearch/scripts/pbs.pm) > /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm

If you don't have acess to subversion, it can also can be downloaded from [//ftp.bestgrid.org/pub/pbs.pm here](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=ftp&title=%2F%2Fftp.bestgrid.org%2Fpub%2Fpbs.pm%20here).

Also need to run pbs-logmaker to send data to our new gateway

>  /usr/bin/perl /usr/local/pbs-telltail/pbs-telltail /opt/torque/server_logs ng2hpc.ceres.auckland.ac.nz 2812

## Audit

Warning: 

The configuration files below, except auditquery, are outdated.

So don't rely on them, just follow [this](http://www.globus.org/toolkit/docs/4.0/execution/wsgram/WS_GRAM_Audit_Logging.html) guide for versions 4.0.5-4.0.8. Old configs still contain useful information like user credentials.

Also do not replace grid-utils, just add AuditDatabaseAppender from an old jar.

Globus monitoring needs to be configured to use shared mysql database. All necessary configuration files are in subversion

>  curl --user yhal003 [https://subversion.auckland.ac.nz/svn/UoA.ITSS.EAO/eResearch/scripts/audit/auditquery](https://subversion.auckland.ac.nz/svn/UoA.ITSS.EAO/eResearch/scripts/audit/auditquery) > /etc/cron.hourly/auditquery
>  curl --user yhal003 [https://subversion.auckland.ac.nz/svn/UoA.ITSS.EAO/eResearch/scripts/audit/container-log4j.properties](https://subversion.auckland.ac.nz/svn/UoA.ITSS.EAO/eResearch/scripts/audit/container-log4j.properties) > /opt/vdt/globus/container-log4j.properties
>  curl --user yhal003 [https://subversion.auckland.ac.nz/svn/UoA.ITSS.EAO/eResearch/scripts/audit/jndi-config.xml](https://subversion.auckland.ac.nz/svn/UoA.ITSS.EAO/eResearch/scripts/audit/jndi-config.xml) > /opt/vdt/globus/etc/gram-service/jndi-config.xml
>  vdt-control --off
>  vdt-control --on

The following library was copied from original ng2 for audit to work (not sure why...): /opt/vdt/globus/lib/gram-utils.jar

we also need to give the host access to mysql-bg.ceres.auckland.ac.nz:3306/ng2_auditDatabase database.
