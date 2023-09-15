# Setting up an NG2

An NG2 server acts as a job submission gateway to local compute resources.

Jobs are accepted via the WS-GRAM4 protocol and passed onto the local job scheduler.

The local job scheduler is commonly referred to as a *local resource manager* (LRM),

as it may do more than merely schedule jobs. This document will use that latter terminology.

The NG2 runs the Globus Tookit 4, installed from the [Virtual Data Toolkit](http://vdt.cs.wisc.edu/) (VDT) distribution, version 2.0.0 at the time of writing.  The NG2 is configured to make authorization decisions through callouts to a GUMS server (instead of a plain text grid-mapfile), so [Setting up a GUMS server](/wiki/spaces/BeSTGRID/pages/3818228918) is an essential pre-requisite to setting up an NG2.

As an NG2 maps user requests to local "unix" accounts and uploads files to their home directories, it can only handle one cluster - or a set of clusters within a single administrative domain, i.e., one set of accounts and home directories.  **Important:** If you are connecting multiple clusters with distinct account sets / different home directories, you will need a separate NG2 for each cluster.

This guide is based on the [ARCS NG2 installation guide](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2), but extends it with additional steps and also clarifications.

The installation of an NG2 is very site specific - it depends a lot on the LRM - but also on other aspects, such as the user account management system and the filesystem used for home directories.  This guide will cover the default case (PBS is the LRM) and will hint on solutions for the other situations.

As a "parallel companion" to this page, setup instructions are given for an NG2 on an Ubuntu server base system: [Setting up an NG2 on Ubuntu](/wiki/spaces/BeSTGRID/pages/3818228397)

This page uses the following LRM-specific pages as supplementary material:

- [Setting up an NG2/PBS specific parts](setting-up-an-ng2-pbs-specific-parts.md)
- [Setting up an NG2/SGE specific parts](setting-up-an-ng2-sge-specific-parts.md)

# Preliminaries

## OS requirements

This guide assumes the system where NG2 will be installed has already been configured.

The following is recommended:

- Hardware requirements (VM configuration)
	
- Minimum: 512MB RAM, 1 CPU, 8GB filesystem, 1GB swap.
- Recommended: 1024MB RAM, 2 CPUs, 16GB filesystem, 2GB swap.

- OS: Linux CentOS 5 (or RHEL 5).  Other Linux distributions (or other operating systems) may work, please check the [VDT system requirements](http://vdt.cs.wisc.edu/releases/2.0.0/requirements.html).
	
- Both i386 (32-bit) and x86_64 (64-bit) distributions are supported.

>  **Hostname: it is recommended to use*ng2.*****your.site.domain***

- **If you are connecting multiple clusters with distinct account sets / different home directories, you will need a separate NG2 for each cluster.  Use*ng2*clustername**.your.site.domain*
- **If you are deploying a development/testing NG2 alongside a production NG2, use*ng2dev.your.site.domain**

- The system is setup to send outgoing email (i.e., typically, default SMTP relay would be set to the site's local SMTP server).
	
- Note: it is a requirement that the SMTP server does not overwrite the sender domain (in the From: address) - the domain must stay as the full hostname.

- The system is configured for time synchronization with a reliable time source.

## Grid User Accounts

Unless your site is going to map each external user to a single internal account on your cluster, 

you will need a number of "grid user" accounts that allow for the mapping of external job requests

to known internal accounts.

This requirement overlaps with the realm of the GUMS server and the current documentation for 

setting up the GUMS server for use within BeSTGRID assumes the two "grid user" accounts are

`grid-admin` and `grid-bestgrid`.

Whilst those specific names are not requirements, it is after all the job of the GUMS to do the mapping

required, you should ensure that you match the names between those you configure when setting up GUMS

and those you provide upon the cluster, and hence on the NG2.

## Cluster integration

- The OS must configured to recognize accounts used on the cluster.  Ideally, this would be done via the appropriate PAM module, but the accounts may be created in parallel (this is more feasible if the NG2 would be using only a few grid accounts and would not be granting access to personal accounts).
	
- It is not required to have password-based login configured for the cluster accounts (Globus will only be using sudo to map to the accounts).

- The system must mount users home directories from the cluster.

- The system must be integrated into the cluster as a submit-only host (at least).  I.e., for the case of PBS, it must be able to submit jobs via "qsub", cancel jobs with "qdel" and list cluster and queue status with "qstat" and "pbsnodes".
	
- The integration should be done either by installing the tools from the same distribution as the cluster was installed, or, for PBS, there is a convenience package with PBS tools.

## Network requirements

- The server needs a public (and static) IP address.
- The hostname must resolve to this IP address and the IP address must resolve back to the system's hostname.
- The server needs to be able to open INcoming and OUTgoing TCP connections to ports 8443, 2811, 7512, 15001 and 40000-41000 (a range of 1001 ports).
- In addition to that, is requires INcoming + OUTgoing UDP to ports 40000-41000 (again a range of 1001 ports).
- In addition to that, OUTgoing TCP connection to ports 80 and 443.
	
- Note: The outgoing TCP traffic to ports 80 and 443 MAY go through a proxy (if the `http_proxy environment` variable is properly set), but all other traffic must be a direct connection.
- In addition, OUTgoing UDP to port 4810 (Globus usage statistics packets)
	
- (see [http://www.globus.org/toolkit/docs/5.0/5.0.0/Usage_Stats.html](http://www.globus.org/toolkit/docs/5.0/5.0.0/Usage_Stats.html))

**Note:** Remember to check the firewall settings on the server itself, as the default install of CentOS may restrict the use of these ports.

## Certificates

Before proceeding with the certificate, [obtain a host certificate](/wiki/spaces/BeSTGRID/pages/3818228502) for this system from the [APACGrid CA](http://wiki.arcs.org.au/bin/view/Main/HostCertificates)

- If no other software has created the directory `/etc/grid-security` then it needs to be created

``` 

mkdir -p /etc/grid-security
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security

```

- Install the certificate and private key as `/etc/grid-security/hostcert.pem` and `/etc/grid-security/hostkey.pem` respectively
	
- The files should be owned by root
- The private key should be readable only to root

- If you are doing installation in a different order (e.g., you only got the host certificate after installing pacman VDT), or if you are installing new certificates, install a copy of the certificate and private key as `/etc/grid-security/containercert.pem` and `/etc/grid-security/containerkey.pem` respectively
	
- The files should be owned by daemon
- The private key should be readable only to daemon

``` 

ls -l /etc/grid-security/host* /etc/grid-security/container*
-rw-r--r-- 1 daemon daemon 2691 Feb 23 14:30 /etc/grid-security/containercert.pem
-rw------- 1 daemon daemon 1679 Feb 23 14:30 /etc/grid-security/containerkey.pem
-rw-r--r-- 1 root   root   2691 Feb 23 12:52 /etc/grid-security/hostcert.pem
-rw------- 1 root   root   1679 Feb 23 12:52 /etc/grid-security/hostkey.pem

```

# Preparing the installation

## Prerequisites

First, we setup the ARCS repository and install GridPulse (the ARCS system monitoring tool) from the ARCS repository:

- Configure ARCS RPM repository

``` 
cd /etc/yum.repos.d && wget http://projects.arcs.org.au/dist/arcs.repo
```
- Note: on a 64-bit system, change the repository file to use ARCS i386 repository itself (the ARCS 64-bit repository is not populated).  I.e., change the `baseurl` for the [arcs] repository in `/etc/yum.repos.d/arcs.repo` to: 

``` 
baseurl=http://projects.arcs.org.au/dist/production/$releasever/i386
```

- Install the system monitoring tool GridPulse, ARCS Gateway addons, and network services launcher xinetd (if not yet installed)


>  yum install APAC-gateway-gridpulse Ggateway xinetd
>  yum install APAC-gateway-gridpulse Ggateway xinetd

## Configuring local scheduler access

An NG2 needs to be properly integrated with the Local Resource Manager.  Globus was originally designed to be run on the cluster headnode - and when running it on a separate virtual machine, the NG2, it's necessary to facilitate the same information flow.  The ways Globus interacts with the Local Resource Manager are:

1. Globus invokes the internal Perl JobManager framework and runs LRM-specific module - typically pbs.pm, other sites have sge.pm, loadleveler.pm.  This module builds the job script and in the end runs "qsub" (or "llsubmit" or whatever submission command is used).
2. Globus runs a separate LRM-specific process called Scheduler-Event-Generator (SEG).  This process reads the LRM-specific logs and feeds the job status information to Globus.  This assumes Globus is running on the headnode.  For the APACGrid/ARCS setup where Globus runs inside a separate VM, the (PBS/SGE) logs must replicated to

the NG2 - that's what pbs-telltail/pbs-logmaker do.  These are installed in the pbs-telltail package on the NG2 - but they also need to be configured on the headnode.
3. When a job is killed, the pbs.pm module (as in #1) invokes qdel or equivalent.
4. MDS4 running in the Globus WS-container invokes MIP (/usr/local/mip/mip) to gather information about the cluster - and that involves invoking "qstat" and "pbsnodes" (or equivalents).
5. When accessing the home directory, the GridFTP server serves the files in users home directories (typically mount to NG2 via NFS).

The procedure to implement local scheduler access is inherently LRM specific.  

The procedure will include:

- Mount shared home directories (site specific)
- Link to cluster local accounts (site specific)
- Link to local scheduler (LRM and site specific)

Please see the following links for LRM-specific instructions:

- PBS: [Access with PBS](setting-up-an-ng2-pbs-specific-parts.md)
- SGE: [Access with SGE](setting-up-an-ng2-sge-specific-parts.md)

## Configure LRM log replication from LRM server to the NG2

Globus needs to know about "scheduler events" - such as jobs starting and finishing.

Globus was designed with the assumption it would be running on the LRM server and would have direct access to the LRM logs.

With the gateway architecture of deploying Globus on a separate VM, it is necessary to replicate the logs from the LRM server to the NG2.

**Note**: an alternative to this solution (replicating the logs) is to mount the logs directory from the cluster head node on the NG2.

This is again a LRM-specific task - so please see the relevant LRM-specific instructions:

- PBS: [Setting up an NG2/PBS specific parts#Log replication](setting-up-an-ng2-pbs-specific-parts.md)
- SGE: [Setting up an NG2/SGE specific parts#Log replication](setting-up-an-ng2-sge-specific-parts.md)

# Installing VDT

## Select VDT packages

Select packages from the following sets:

- Required packages:
- ***Globus-WS** - the Globus WS-GRAM4 server
- ***PRIMA-GT4** - the PRIMA module for making authorization callouts to the GUMS server
- **Globus local scheduler interface: for PBS, choose*Globus-WS-PBS-Setup**, for SGE, choose **Globus-WS-SGE-Setup** ... for other LRMs, find out what's available.

- Recommended packages:
- ***GSIOpenSSH** - GSI-enabled ssh server and client

- Optional recommended packages: client tools
- ***MyProxy-Client** - to have the "myproxy-logon" command
- ***VOMS-Client** - to have the "voms-proxy-init" command
- ***UberFTP** - for a command-line GridFTP client, "uberftp"

- Optional recommended packages: development
- ***Globus-Base-SDK** - to be able to compile Globus packages (required if you need to recompile any parts of Globus or the local LRM interface)

The [author's](vladimirbestgridorg.md) choice is to recommend installing all of these above optional packages: it makes the gateway also a useful client system with command-line tools installed - useful for testing & debugging right on the NG2.

## Install VDT

The installation is done via pacman, the package manager used by VDT.

- As root, download and setup pacman:

``` 

mkdir /opt/vdt
cd /opt/vdt
wget http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz
tar xf pacman-*.tar.gz
cd pacman-*/ && source setup.sh && cd ..

```

- Set the environment


>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)

- Prepare and run the installation command-line: Start with {{pacman -get }} and add each package prefixed by '$VDTMIRROR:'
	
- The minimum install for a PBS-based system is:

``` 
pacman -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4 $VDTMIRROR:Globus-WS-PBS-Setup
```
- The full install with all optional recommended packages (and PBS) is:

``` 
pacman -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4 $VDTMIRROR:Globus-WS-PBS-Setup $VDTMIRROR:VOMS-Client $VDTMIRROR:MyProxy-Client $VDTMIRROR:UberFTP $VDTMIRROR:Globus-Base-SDK $VDTMIRROR:GSIOpenSSH

```
- The full install with all optional recommended packages (for SGE) is:

``` 
pacman -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4 $VDTMIRROR:Globus-SGE-Setup $VDTMIRROR:Globus-WS-SGE-Setup $VDTMIRROR:VOMS-Client $VDTMIRROR:MyProxy-Client $VDTMIRROR:UberFTP $VDTMIRROR:Globus-Base-SDK $VDTMIRROR:GSIOpenSSH

```

- Wait about a minute or two for the installer to prompt you to agree to licenses.
- Have a cup of coffee - the download and installation may take 15-30 minutes.

- Make the environment variable setup script created by VDT load in the default profile


>  ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
>  . /etc/profile
>  ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
>  . /etc/profile

# Post-install configuration

## Configure VDT certificate distribution

VDT comes with a tool to download and update a certificate distribution, but requires the user to make an (informed) choice on which certificate distribution to trust.  The VDT team is also creating a convenient distribution based on IGTF - but we do need to configure this tool to point to this distribution.

- Run the following command to select the VDT distribution and install it into /etc/grid-security/certificates

``` 
vdt-ca-manage setupca --location root --url vdt
```
- Note: behind the scenes, the tool adds the following line to `$VDT_LOCATION/vdt/etc/vdt-update-certs.conf`: 

``` 
cacerts_url = http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version
```



## Tuning Globus configuration

- Set web services to listen on 8443:

``` 
sed --in-place=.ORI -e '/WSC_PORT/ s/9443/8443/' /opt/vdt/post-install/globus-ws
```
- Make Globus publish hostname in URLs:

``` 
sed -i '/<globalConfiguration>/a\        <parameter name="publishHostName" value="true"/>' /opt/vdt/globus/etc/globus_wsrf_core/server-config.wsdd
```

- Make Globus use port range 40000-41000 (and optionally also set default MyProxy server)

``` 

mkdir /opt/vdt/post-setup
echo "export GLOBUS_TCP_PORT_RANGE=40000,41000" > /opt/vdt/post-setup/ARCS.sh
echo "export MYPROXY_SERVER=myproxy.arcs.org.au" >> /opt/vdt/post-setup/ARCS.sh
chmod a+xr /opt/vdt/post-setup/ARCS.sh

```

- Configure Globus to make callouts to the GUMS server (use your GUMS server hostname in the command)


>  /opt/vdt/vdt/setup/configure_prima_gt4 --enable --gums-server nggums.*your.site.domain*
>  /opt/vdt/vdt/setup/configure_prima_gt4 --enable --gums-server nggums.*your.site.domain*

- Switch more services to use GUMS instead of grid-mapfile

``` 

sed -i 's,<authz value="gridmap"/>,<authz value="osg:org.opensciencegrid.authz.gt4.OSGAuthorization"/>,g' /opt/vdt/globus/etc/gram-service/managed-job-security-config.xml
sed -i 's,<authz value="gridmap"/>,<authz value="osg:org.opensciencegrid.authz.gt4.OSGAuthorization"/>,g' /opt/vdt/globus/etc/globus_wsrf_mds_index/index-security-config.xml
sed -i 's,<authz value="gridmap"/>,<authz value="osg:org.opensciencegrid.authz.gt4.OSGAuthorization"/>,g' /opt/vdt/globus/etc/globus_wsrf_mds_index/factory-security-config.xml
sed -i 's,<authz value="gridmap"/>,<authz value="osg:org.opensciencegrid.authz.gt4.OSGAuthorization"/>,g' /opt/vdt/globus/etc/globus_wsrf_rft/security-config.xml
sed -i 's,<authz value="gridmap"/>,<authz value="osg:org.opensciencegrid.authz.gt4.OSGAuthorization"/>,g' /opt/vdt/globus/etc/globus_delegation_service/service-security-config.xml
sed -i '/<gridmap value="\/etc\/grid-security\/grid-mapfile"\/>/d' /opt/vdt/globus/etc/globus_wsrf_mds_index/index-security-config.xml

```

## Setup sudo

Open `/etc/sudoers` (ideally using `visudo`) and make the following changes:

- If there is a `requiretty` line, comment it out.
- Add the following snippet, allowing Globus (running as `daemon`) to run

``` 

#GLOBUSUSERS alias
Runas_Alias GLOBUSUSERS = ALL, !root

# Globus mappings with PRIMA
daemon ALL=(GLOBUSUSERS) \
       NOPASSWD: /opt/vdt/globus/libexec/globus-job-manager-script.pl *
daemon ALL=(GLOBUSUSERS) \
       NOPASSWD: /opt/vdt/globus/libexec/globus-gram-local-proxy-tool *

# Globus mappings with grid-mapfile
daemon ALL=(GLOBUSUSERS) \
       NOPASSWD: /opt/vdt/globus/libexec/globus-gridmap-and-execute \
       -g /etc/grid-security/grid-mapfile \
       /opt/vdt/globus/libexec/globus-job-manager-script.pl *
daemon ALL=(GLOBUSUSERS) \
       NOPASSWD: /opt/vdt/globus/libexec/globus-gridmap-and-execute \
       -g /etc/grid-security/grid-mapfile \
       /opt/vdt/globus/libexec/globus-gram-local-proxy-tool *

```

## Setup Globus for LRM

The Globus Scheduler Event Generator (SEG) must be configured with the path to the LRM logs (replicated from the LRM server).

Also, it is necessary to configure the LRM interface script (e.g., pbs.pm)

This is again a LRM-specific task - so please see the relevant LRM-specific instructions:

- PBS: [Setting up an NG2/PBS specific parts#Globus integration](setting-up-an-ng2-pbs-specific-parts.md)
- SGE: [Setting up an NG2/SGE specific parts#Globus integration](setting-up-an-ng2-sge-specific-parts.md)

## Start VDT services

- Mark all services as enabled:

``` 

vdt-control --enable fetch-crl
vdt-control --enable vdt-rotate-logs
vdt-control --enable vdt-update-certs
vdt-control --enable gsiftp
vdt-control --enable mysql5
vdt-control --enable globus-ws

```
- Turn all services on


>  vdt-control --on
>  vdt-control --on

- And follow to force gsiftp to start - even though VDT complains about conflict with non-VDT (CentOS) gsiftp entry in /etc/services:


>  vdt-control --on --force gsiftp
>  vdt-control --on --force gsiftp

# Setup job reporting

The grid gateway sends information to the Grid Operations Center (GOC, [http://status.arcs.org.au/](http://status.arcs.org.au/)) on system status and job usage.

1. The system status emails are sent by `/usr/local/bin/gridpulse` invoked every 20 minutes from root's crontab.
2. Job usage emails are sent daily from the cluster headnode.
3. The final piece of information, linking the Distinguished Name (DN) of the submitter with the local scheduler job ID is sent hourly by `/etc/cron.hourly/auditquery`, pulling the information out of the Globus audit database.

- Email help@arcs.org.au and have your NG2 server added to your site on the [Grid Operations Centre](http://status.arcs.org.au/)

For these to work properly, do the following changes:

- Create the Audit database in MySQL and configure Globus to populate it by downloading and running the [AddAuditNg2Vdt200p11.sh](https://projects.arcs.org.au/trac/systems/raw-attachment/wiki/HowTo/InstallNg2/AddAuditNg2Vdt200p11.sh) script
- Restart Globus: 

``` 
service globus-ws stop; service globus-ws start
```

>  ***IMPORTANT**: Patch the `/etc/cron.hourly/auditquery` script with the following patch:
>  ***NOTE**: This patch has been integrated into Ggateway-1.0.2-2 (released 2010-02-25).  Do not apply the patch if you have installed this version or later.

``` 

--- auditquery.orig	2006-12-20 17:57:47.000000000 +1300
+++ auditquery	2010-02-19 16:33:11.000000000 +1300
@@ -18,7 +18,7 @@
 mysql <<EOF 2>/dev/null | sed -n '2,$p' |
 use auditDatabase;
 select concat_ws(' ',local_job_id, subject_name)
-from gram_audit_table;
+from gram_audit_table where local_job_id is not NULL and finished_flag = TRUE;
 EOF
 while read Line; do
   logger -t Job-DN "$Line"
@@ -26,11 +26,11 @@
   JobId="`echo $Line | awk '{print $1}'`"
   echo "delete from  gram_audit_table" >>$File
   echo "where local_job_id = '$JobId';">>$File
-done | /bin/mail -s "`hostname` JobID `date +%Y%m%d`" grid_pulse@vpac.org >/dev/null 2>&1
+done | /bin/mail -s "`hostname` JobID `date +%Y%m%d`" grid_pulse@lists.arcs.org.au >/dev/null 2>&1
 
 #
 # Perform deletions
 ( cat $File
   echo "delete from  gram_audit_table"
-  echo "where local_job_id is NULL;" ) | mysql >/dev/null 2>&1
+  echo "where local_job_id is NULL and finished_flag = TRUE;" ) | mysql >/dev/null 2>&1
 exit 0

```

The final bit is to send the daily usage logs from the cluster headnode to the Grid Operations Centre (GOC).

Both of the LRM-specific task instructions suggest that you use a *site name* which has been assigned

to your site on the GOC. There may no longer be one assigned there. UoC appear to use `NZ-Cant`,

Victoria chose to use a similar `NZ-VUW`.

This is again a LRM-specific task - so please see the relevant LRM-specific instructions:

- PBS: [Setting up an NG2/PBS specific parts#Usage reporting](setting-up-an-ng2-pbs-specific-parts.md)
- SGE: [Setting up an NG2/SGE specific parts#Usage reporting](setting-up-an-ng2-sge-specific-parts.md)

# Setup MDS/MIP

The Monitoring and Discovery Service (MDS) acts as a directory of services available on the grid: namely compute resources, storage resources and software packages.

The Modular Information Provider (MIP) is the software implementation populating the local MDS on the NG2 (and this information gets then pushed to the central MDS index).

This section documents setting up both MIP and the local MDS.  These instructions follow [https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/InstallConfigSteps](https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/InstallConfigSteps)

Note: the current MIP implementation only works with PBS-based clusters.  Please email the [author of this page](vladimirbestgridorg.md) if you need to get MIP going with other LRMs.  This has been done for LoadLeveler (extending MIP to provide cluster load information for LoadLeveler) and is working-in-progress for SGE.

## Install MIP

- Enable the EPEL repository (Extra Packages for Enterprise Linux) - we'll need to fetch some packages from there.
	
- On an x86_64 system, run:

``` 
rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm
```
- On an i386 system, run:

``` 
rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm
```

- Install MIP and it's python module:

``` 
yum install APAC-mip APAC-mip-module-py APAC-glue-schema
```
- Note: the APAC-glue-schema package (containing the XML schema defitions for GLUE 1.2 with APACGrid extensions) would install as a dependency - but is listed here for clarity.

## Configuring MIP

This section assumes you'll be advertising in MDS:

- one *Site* element (representing your site)
- one *Cluster* element (representing the single cluster you are connecting to the grid)
- one *SubCluster* element (... this is a weird name for the hardware description of your cluster)
- one *ComputeElement* element (representing one job queue on your cluster)
- one *StorageElement* element (representing the user home directories accessible via GridFTP)

- If you need to advertise more ComputeElements, adjust the configuration accordingly (providing multiple IDs/names for the elements) - but please do not advertise multiple queues providing access to the same physical resources.  That would break the metascheduling algorithms used in Grisu.
- If you need to advertise multiple clusters (with the same home directories and user accounts), the changes will be still straightforward.
- If you need to advertise multiple clusters with the different home directories and user accounts (and you are already running multiple NG2s), it will be more complex - and you may have to use MIP integrator to aggregate data from multiple NG2s.  See [Setup MIP on NG2HPC at University of Canterbury](/wiki/spaces/BeSTGRID/pages/3818228466) for more information on how that was done at Canterbury.

### Configure default.pl

- Start configuring MIP by setting the element IDs in `/usr/local/mip/config/default.pl`:
	
- Uncomment the lines for `SubCluster`, `Cluster`, `CompungElement` and `StorageElement`
- Change the Site ID to your site domain name.
- Change the StorageElement name to your NG2 hostname.
- Prefix the SubCluster, Cluster and ComputingElement IDs with your NG2 hostname.
- You should get (example):

``` 

  clusterlist => ['default'],
  uids =>  {
    Site => [ "canterbury.ac.nz", ],
    SubCluster => [ "ng2.canterbury.ac.nz-sub1", ],
    Cluster => [ "ng2.canterbury.ac.nz-cluster1", ],
    ComputingElement => [ "ng2.canterbury.ac.nz-compute1", ],
    StorageElement => [ "ng2.canterbury.ac.nz", ],
  }

```

### Configure apac_config.py

Now create/edit `/usr/local/mip/config/apac_config.py` (using `/usr/local/mip/modules/apac_py/example_config.py` as a base) and define the `Site`, `SubCluster`, `Cluster`, `ComputingElement`, and `StorageElement` elements.  Use the same IDs as in `default.pl` as their IDs (the array index used when the object is created).  

Provide the following information:

- Fill in Site information as reasonable (it's not necessary to provide the `OtherInfo` and `Sponsor` fields - you may comment them out if they are not relevant)
- Define the cluster element:
	
- `cluster` : Set the string to the same cluster name as in `default.pl`
- `cluster.Name` : Set to the hostname of the job submisson gateway to the cluster
- `cluster.WNTmpDir` : For Linux set this to `/tmp`
- `cluster.TmpDir` : For Linux set this to `~/.globus/scratch`
- Define compute element for the local queue to be published:
	
- Configure appropriately for your local resource manager
		
- PBS: [MIP Configuration](setting-up-an-ng2-pbs-specific-parts.md)
- SGE: [MIP Configuration](setting-up-an-ng2-sge-specific-parts.md)
- `computeElement.Name` : The name of the queue as it is named in your LRM
- `computeElement.HostName` : The hostname of the job submission gateway to the cluster
- `computeElement.ContactString` : Use the WSGRAM suggestion in the comment on this line, giving
		
- {{

``` 
https://gateway.host.name:8443/wsrf/services/ManagedJobFactoryService
```

}}
- `computeElement.DefaultSE` : The hostname of the job submission gateway to the cluster
- `computeElement.GRAMVersion` : Update to match the installed GRAM version (use `vdt-version` to obtain this)
- `computeElement.ACL` :  can be optionally set to a list of VOs permitted to use the cluster eg ['/ARCS/BeSTGRID', '/ARCS/NGAdmin'].  If not provided, the list will be synthesized as union of all VOView ACLs.
- There should be one `VOView` and one `StorageArea` element for each VO group supported (like /ARCS/BeSTGRID, /ARCS/NGAdmin).  Edit the configuration accordingly.

``` 

# VOVIEW
# this name is defined must be unique for each voview in the computing element. It is not
# see twiki page for further details on this section
voview = computeElement.views['ng2-yoursite-NGAdmin'] = VOView()

# the RealUser is used in working out the job information for the VOView, ie WaitingJobs,
# it should be retrieved from GUMS in the future
voview.RealUser = 'grid-admin'
voview.DefaultSE = 'gateway.host.name'
voview.DataDir = '/home/grid-admin'
voview.ACL = [ '/ARCS/NGAdmin' ]

voview = computeElement.views['ng2-yoursite-BeSTGRID'] = VOView()

# the RealUser is used in working out the job information for the VOView, ie WaitingJobs,
# it should be retrieved from GUMS in the future
voview.RealUser = 'grid-bestgrid'
voview.DefaultSE = 'gateway.host.name'
voview.DataDir = '/home/grid-bestgrid'
voview.ACL = [ '/ARCS/BeSTGRID' ]

#/VOVIEW

```
- In the `subCluster` element, you may need to manually define CPU, Memory and OS properties
- ***Note**: There may be differences between the cluster node and gateway hardware
- `subcluster.SMPSize` : Set this to cores per node?
- Processor details may have to be set manually as the processors are not local, the information required can be found in `/proc/cpuinfo` of the compute nodes.
- Memory details may have to be set manually as the memory is not local, this should match the memory information from the compute nodes of your cluster.

### Create Config file

>  **Create /usr/local/mip/config/default_ng2.*yoursite**-sub1_SIP.ini (i.e., name the file after the ID selected for the subCluster element).

``` 

[source2]
uri: file:softwareInfoData/localSoftware.xml
format: APACGLUE1.2

[action]
type: log

[log]
location: /usr/local/mip/var/log/mip.log

[definitionMapulations]
APACSchemaDirectory: /usr/local/share/

```

### Create Log File

- Create MIP log file and make it writable:


>  mkdir -p /usr/local/mip/var/log
>  touch /usr/local/mip/var/log/mip.log
>  chmod a+rw /usr/local/mip/var/log/mip.log
>  mkdir -p /usr/local/mip/var/log
>  touch /usr/local/mip/var/log/mip.log
>  chmod a+rw /usr/local/mip/var/log/mip.log

### Testing and finishing up

- [Define software packages](/wiki/spaces/BeSTGRID/pages/3818228867) in /usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/localSoftware.xml
- Test your MIP works and produces valid information
	
- Run 

``` 
/usr/local/mip/mip
```
- Check for any error messages
- Review the data provided for meaningful values.

- To troubleshoot and see the output if individual MIP modules, use the following - for either Site, Cluster, SubCluster or ComputingElement - changing the second argument to the respective element's ID as defined in sources.pl and apac_conf.py:

``` 

export PYTHONPATH="/usr/local/mip/modules/apac_py:$PYTHONPATH"
cd /usr/local/mip/
./modules/apac_py/Site/site.py default element-id ./config/

```

When collecting the MIP information, you also need to interface with the LRM - in a LRM specific way.  MIP was initially developed with PBS in mind, so there's very little to do for PBS (except for setting the path to the client binaries) - and this may be much harder for other LRMs.

Please see the relevant LRM-specific instructions:

- PBS: [Setting up an NG2/PBS specific parts#PBS MIP configuration](setting-up-an-ng2-pbs-specific-parts.md)
- SGE: [Setting up an NG2/SGE specific parts#SGE MIP configuration](setting-up-an-ng2-sge-specific-parts.md)

### More about configuring MIP

Check the pages for MIP for specific information about how to configure a cluster's applications and services with MIP.

## Activating MDS in Globus

If you are confident that the contents of your MDS is correct and ready to be published to the outside world **and after you have extensively tested your gateway** (GridFTP access and job submission work both internally and from outside your institution's network):

- For testing, see the [testing section below](#SettingupanNG2-Testing) - ask your colleagues to help with testing by emailing `help at bestgrid.org`
- Request that your NG2 is allowed to publish to the central MDS index: send a request to `help at arcs.org.au` and include the DN of your server.
	
- You can get the DN with: 

``` 
openssl x509 -subject -noout -in /etc/grid-security/hostcert.pem
```

- Activate MIP in Globus


>  yum install APAC-mip-globus
>  yum install APAC-mip-globus

- Check that the MIP output validates against the XML schema: check the output of:


>  /usr/local/mip/config/globus/mip-exec.sh -validate > /dev/null
>  /usr/local/mip/config/globus/mip-exec.sh -validate > /dev/null

- Secure your MDS - so that it's not open to the world for writing.  This contents would get posted to the central index.
	
- Create empty `/etc/grid-security/mds-grid-mapfile`: 

``` 
touch /etc/grid-security/mds-grid-mapfile
```
- The rest has been done by the APAC-mip-globus install scriptlet (editing `/opt/vdt/globus/etc/globus_wsrf_mds_index/index-security-config.xml` and `/opt/vdt/globus/etc/globus_wsrf_mds_index/server-config.wsdd`)

>  **Disable auto-registration of RFT and GRAM services - they won't be able to authenticate now and we don't want them in the central index.  Edit **`/opt/vdt/globus/etc/gram-service/jndi-config.xml`** and **`/opt/vdt/globus/etc/globus_wsrf_rft/jndi-config.xml`** and set the*reg** parameter to `false`.

- Restart globus


>  service globus-ws stop
>  service globus-ws start
>  service globus-ws stop
>  service globus-ws start

- The MDS service inside Globus unfortunately sometimes does not start on its owned and needs to be *"primed"*" - a single `wsrf-query` run against the local MDS service causes it to kick in and initialize properly.  This may be necessary after every reboot and/or Globus restart.  This process can be automated:
- Create a shell script `/usr/local/bin/mds-primer.sh`

``` 

#!/bin/bash
. /opt/vdt/setup.sh

# be explicit about the certificate and key we use
X509_USER_CERT=/etc/grid-security/hostcert.pem
X509_USER_KEY=/etc/grid-security/hostkey.pem

# store the proxy certificate in a separate location
X509_USER_PROXY=$(mktemp)
 
export X509_USER_CERT X509_USER_KEY X509_USER_PROXY

$GLOBUS_LOCATION/bin/grid-proxy-init -valid 00:05 -q
$GLOBUS_LOCATION/bin/wsrf-query -s https://$(hostname --fqdn):8443/wsrf/services/DefaultIndexService > /dev/null
$GLOBUS_LOCATION/bin/grid-proxy-destroy

```

- Make the script executable


>  $ sudo chmod 755 /usr/local/bin/mds-primer.sh
>  $ sudo chmod 755 /usr/local/bin/mds-primer.sh

- Add a crontab entry for it calling it every 20 minutes:


>  5,25,45 * * * * /usr/local/bin/mds-primer.sh
>  5,25,45 * * * * /usr/local/bin/mds-primer.sh

# Polishing Globus

VDT originally came with two defects in the service control scripts installed in `/etc/rc.d/init.d`:

1. All services were marked to be started at order rank 99, making them start in alphabetic order - and this was particularly breaking `globus-ws` if `mysql` wasn't running at the time Globus tried accessing it during start up.
2. The services don't register themselves as running in `/var/lock/subsys`.  Consequently, on system shutdown, the service control scripts don't get invoked to shutdown the services gracefully.

- In VDT 2.0, the first issue has been partly delt with by making `mysql5` start at order rank 90 (starting before all other VDT services) - but it's still desirable to start Tomcat before Apache.
- The second issue has not been addressed yet.

To address these issues, apply the following patches to the master copies of the scripts in `/opt/vdt/post-install`:

- mysql5:

``` 

--- mysql5.orig	2010-02-18 10:13:45.000000000 +1300
+++ mysql5	2010-02-18 11:57:41.000000000 +1300
@@ -332,6 +332,7 @@
       then
         touch /opt/vdt/mysql5/var/mysqlmanager
       fi
+      touch /var/lock/subsys/mysql5
       exit $return_value
     elif test -x $bindir/mysqld_safe
     then
@@ -346,6 +347,7 @@
       then
         touch /opt/vdt/mysql5/var/mysql
       fi
+      touch /var/lock/subsys/mysql5
       exit $return_value
     else
       log_failure_msg "Couldn't find MySQL manager ($manager) or server ($bindir/mysqld_safe)"
@@ -379,6 +381,7 @@
       then
         rm -f $lock_dir
       fi
+      rm -f /var/lock/subsys/mysql5
       exit $return_value
     else
       log_failure_msg "MySQL manager or server PID file could not be found!"

```

- globus-ws

``` 

--- globus-ws-fixed-start-seq	2008-02-05 16:29:47.000000000 +1300
+++ globus-ws	2008-02-12 16:00:18.000000000 +1300
@@ -39,2 +39,3 @@
     container_exit=$?
+    if [ $container_exit -eq 0 ] ; then touch /var/lock/subsys/globus-ws ; fi
 
@@ -49,2 +50,3 @@
     $VDT_LOCATION/globus/sbin/globus-stop-container-detached
+    rm -f /var/lock/subsys/globus-ws
 else

```

- Make VDT start using these scripts (install them into /etc/rc.d/init.d) with:


>  vdt-control --off
>  vdt-control --on
>  vdt-control --off
>  vdt-control --on

- For more information, see my description of the [problem](/wiki/spaces/BeSTGRID/pages/3818228535#Vladimir&#39;sgridnotes-RFTstagingfails).

# Making local cluster accounts ready for the grid

- Some grid clients would assume that the Globus scratch directory (refered to as `${GLOBUS_SCRATCH_DIR`} in Globus job scripts) exists in each account.  By default, Globus maps the scratch directory to `$HOME/.globus/scratch`.
	
- Create this directory for each user (and make it owned by the user).

# Testing

- Note: you will need a valid proxy certificate on the system where you run the tests ... if this is your NG2, the myproxy-logon command from MyProxy-Client may now come handy.

- Try running a job through the Globus built-in Fork scheduler:


>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft Fork -c /bin/uname -a
>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft Fork -c /bin/uname -a

- Try running a job through the Globus LRM scheduler (PBS):


>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft PBS -c /bin/uname -a
>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft PBS -c /bin/uname -a

## Acceptance testing

Before requesting to allow your gateway to register itself into MDS, run the following tests:

- GridFTP file transfers with either UberFTP or globus-url-copy - testing both active and passive mode


>  uberftp -passive ng2.your.site dir
>  uberftp -active ng2.your.site dir
>  uberftp -passive ng2.your.site dir
>  uberftp -active ng2.your.site dir

- submitting a simple Fork job (with command given by -c)


>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft Fork -c /bin/uname -a
>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft Fork -c /bin/uname -a

- submitting a simple LRM (PBS/SGE/...) job (also with command given by -c).  PBS is used as the LRM in this example.


>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft PBS -c /bin/uname -a
>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft PBS -c /bin/uname -a

- repeating all of these from an off-site location - as your colleagues at other sites
- submitting a job with file staging directives (in the XML format).  Test the following features in the XML file:
	
- File staging
- Use of the globus scratch dir (${GLOBUS_SCRATCH_DIR})
- MPI jobs
- Store the following file as `jobtest.xml`
	
- Note: this job downloads a sample input file from Canterbury (so leave the source URLs as they are)

``` 

<job>
  <executable>mb</executable>
  <directory>${GLOBUS_SCRATCH_DIR}/mrbcalc</directory>
  <argument>extra-very-small-zealignementnex.NEX</argument>
  <stdout>mrbayesjob-out</stdout>
  <stderr>mrbayesjob-err</stderr>
  <count>4</count>
  <maxWallTime>1000</maxWallTime>
  <jobType>mpi</jobType>
  <fileStageIn>
    <transfer>
      <sourceUrl>gsiftp://ng2.canterbury.ac.nz/opt/shared/examples/empty/</sourceUrl>
      <destinationUrl>file:///${GLOBUS_SCRATCH_DIR}/mrbcalc</destinationUrl>
    </transfer>
    <transfer>
      <sourceUrl>gsiftp://ng2.canterbury.ac.nz/opt/shared/examples/mrbayes/extra-very-small-zealignementnex.NEX</sourceUrl>
      <destinationUrl>file:///${GLOBUS_SCRATCH_DIR}/mrbcalc/</destinationUrl>
    </transfer>
  </fileStageIn>
  <fileCleanUp>
    <deletion><file>file:///${GLOBUS_SCRATCH_DIR}/mrbcalc/</file></deletion>
  </fileCleanUp>
</job>

```
- In case the last RSL file leads to problems (as it depends on the availability of MrBayes), the following should provide a simpler validation test, to be used in the same way as the previous file.
	
- Note: this job also downloads a sample input file from Canterbury (so leave the source URL as it is)

``` 

<job>
  <executable>/bin/cat</executable> 
  <argument>${GLOBUS_SCRATCH_DIR}/file-to-cat</argument>
  <maxWallTime>10</maxWallTime>
  <jobType>single</jobType>
  <fileStageIn>
    <transfer>
      <sourceUrl>gsiftp://ng2.canterbury.ac.nz/etc/redhat-release</sourceUrl>
      <destinationUrl>file:///${GLOBUS_SCRATCH_DIR}/file-to-cat</destinationUrl>
    </transfer>
  </fileStageIn>
  <fileCleanUp>
    <deletion><file>file:///${GLOBUS_SCRATCH_DIR}/file-to-cat</file></deletion>
  </fileCleanUp>
</job>

```

- And run the job with:

``` 
globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft PBS -f jobtest.xml
```

## Testing MIP/MDS with Globus

- Login to the NG2 as a non-root user and get initialize a local proxy certificate (either with `grid-proxy-init` or `myproxy-logon`)
- Query the local MDS contents with



- Check that the XML in MDS validates against the schema as well:



- Check whether the new NG2 shows up in the WebMDS listing (after it has been configured to be allowed to publish to the central MDS index, this may take a while until the entry shows up in here):[http://webmds.arcs.org.au/webmds/](http://webmds.arcs.org.au/webmds/)
