# IoSCC Setting up an NG2

# WIP: For Demonstration Purposes Only: Do not use 

This'll be a modified version of Vlad's information that will 

tease out the commonality between it's NG2-related info and 

that within the NGGUMS-related page.

Most of the modifications arise from the IoSCC work looking

to map the current BeSTGRID landscape and provide a Q&A format

on top of the actual information itself, more specifically in

the first instance, the deployment of a BeSTGRID gateway to

an SGE compute cluster, operated by Landcare Research using

Rocks for teh sysadmin side.

Initially, this will be a straight cut and paste of the source

from Vlad's "Setting up an NG2" page

# Top of Vlad's stuff

An NG2 server acts as a job submission gateway, accepting jobs via the WS-GRAM4 protocol and passing them on to the local scheduler. The NG2 is configured to make authorization decisions through callouts to a GUMS server (instead of a plain text grid-mapfile), so [Setting up a GUMS server](setting-up-a-gums-server.md) is an essential pre-requisite to setting up an NG2.

As an NG2 maps user requests to local "unix" accounts and uploads files to their home directories, it can only handle one cluster - or a set of clusters within a single administrative domain, i.e., one set of accounts and home directories.  **Important:** If you are connecting multiple clusters with distinct account sets / different home directories, you will need a separate NG2 for each cluster.

The NG2 runs the Globus Tookit 4, installed from the [Virtual Data Toolkit](http://vdt.cs.wisc.edu/) (VDT) distribution, version 2.0.0 at the time of writing.  

This guide is based on the [ARCS NG2 installation guide](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2), but extends it with additional steps and also clarifications.

The installation of an NG2 is very site specific - it depends a lot on the *local resource manager* (LRM, "job scheduler") used - but also on other aspects, such as the user account management system and the filesystem used for home directories.  This guide will cover the default case (PBS is the LRM) and will hint on solutions for the other situations.

# Prequisites

## OS requirements

This guide assumes the system where the NG2 will be installed has already been configured.

The following is recommended:

- Hardware requirements (VM configuration)
	
- Minimum: 512MB RAM, 1 CPU, 8GB filesystem, 1GB swap.
- Recommended: 1024MB RAM, 2 CPUs, 16GB filesystem, 2GB swap.

- OS: Linux CentOS 5 (or RHEL 5).  Other Linux distributions (or other operating systems) may work, please check the [VDT system requirements](http://vdt.cs.wisc.edu/releases/2.0.0/requirements.html).
	
- Both i386 (32-bit) and x86_64 (64-bit) distributions are supported.

>  **Hostname: it is recommended to use*ng2.*****your.site.domain***

- **If you are connecting multiple clusters with distinct account sets / different home directories, you will need a separate NG2 for each cluster.  Use*ng2_clustername_.your.site.domain**
- **If you are deploying a development/testing NG2 alongside a production NG2, use*ng2dev.your.site.domain**

- The system is setup to send outgoing email (i.e., typically, default SMTP relay would be set to the site's local SMTP server).
	
- Note: it is a requirement that the SMTP server does not overwrite the sender domain (in the From: address) - the domain must stay as the full hostname.

- The system is configured for time synchronization with a reliable time source.

## Cluster integration

- The OS must configured to recognize accounts used on the cluster.  Ideally, this would be done via the appropriate PAM module, but the accounts may be created in parallel (this is more feasible if the NG2 would be using only a few grid accounts and would not be granting access to personal accounts).
	
- It is not required to have password-based login configured for the cluster accounts (Globus will only be using sudo to map to the accounts).

- The system must mount users home directories from the cluster.

- The system must be integrated into the cluster as a submit-only host (at least).  I.e., for the case of PBS, it must be able to submit jobs via "qsub", cancel jobs with "qdel" and list cluster and queue status with "qstat" and "pbsnodes".
	
- The integration should be done either by installing the tools from the same distribution as the cluster was installed, or, for PBS, there is a convenience package with PBS tools.

## Network requirements

- The server needs a public IP address.
- The hostname must resolve to this IP address and the IP address must resolve back to the system's hostname.
- The server needs to be able to open INcoming and OUTgoing TCP connections to ports 8443, 2811, 7512, 15001 and 40000-41000 (a range of 1001 ports).
- In addition to that, also OUTgoing UDP packets to port 4810 and INCOMING+OUTGOING UDP to ports 40000-41000 (again a range of 1001 ports).
- In addition to that, OUTgoing TCP connection to ports 80 and 443.
	
- Note: The outgoing TCP traffic to ports 80 and 443 MAY go through a proxy (if the `http_proxy environment` variable is properly set), but all other traffic must be a direct connection.

## Certificates

In order to operate the host machine within ARCS, there are requirements to:

>  ***install the ARCS SLCS1 CA bundle**
>  ***install a host certificate** for this system
>  ***install a copy of the host certificate** for use by NG2

### ARCS SLCS1 CA bundle

Based on the instructions at [http://wiki.arcs.org.au/bin/view/Main/SLCS](http://wiki.arcs.org.au/bin/view/Main/SLCS)

The `ARCS SLCS1 CA` bundle needs to be installed on top of the **IGTF Global** bundle (this includes the `APACGrid CA`) that will be installed through tools within the VDT.

The VDT CA setup process will overwrite any certificates that have been added so we can just download the `ARCS SLCS1 CA` bundle

- If no other software has created the directory `/etc/grid-security` then it needs to be created

``` 

mkdir -p /etc/grid-security
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security

```

- Get the ARCS SLCS1 CA bundle and extract it into `/etc/grid-security` (creates `arcs-slcs-ca` subdirectory)
	
- The files should be owned by root

``` 

cd /etc/grid-security  
wget --no-check-certificate https://slcs1.arcs.org.au/arcs-slcs-ca.tar.gz -O - | tar xvz  
chown -R root:root /etc/grid-security/arcs-slcs-ca

```

The installed files should be similar (identical ??) to these

``` 

ls -l /etc/grid-security/arcs-slcs-ca/
-rw-r--r-- 1 root root 1996 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.0
-rw-r--r-- 1 root root  217 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.namespaces
-rw-r--r-- 1 root root  193 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.signing_policy

```

### Host Certificate

If a **host certificate** has not already been installed on the system then  **obtain a host certificate** for this system from the [APACGrid CA](http://wiki.arcs.org.au/bin/view/Main/HostCertificates)

- If no other software has created the directory `/etc/grid-security` then it needs to be created

``` 

mkdir -p /etc/grid-security/
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security

```

- Install the certificate and private key as `/etc/grid-security/hostcert.pem` and `/etc/grid-security/hostkey.pem` respectively
	
- The files should be owned by root
- The private key should be readable only to root

``` 

ls -l /etc/grid-security/host* /etc/grid-security/irods*
-rw-r--r-- 1 root   root   2634 Mar 13  2009 /etc/grid-security/hostcert.pem
-rw------- 1 root   root   1675 Mar 13  2009 /etc/grid-security/hostkey.pem

```

### Host Certificate Copies for NG2

- Install a copy of the certificate and the private key as `/etc/grid-security/containercert.pem` and `/etc/grid-security/containerkey.pem` respectively
	
- The files should be owned by daemon
- The private key should be readable only to daemon

``` 

ls -l /etc/grid-security/host* /etc/grid-security/container*
-rw-r--r-- 1 daemon daemon 2634 Mar 13  2009 /etc/grid-security/containercert.pem
-rw------- 1 daemon daemon 1675 Mar 13  2009 /etc/grid-security/containerkey.pem
-rw-r--r-- 1 root   root   2634 Mar 13  2009 /etc/grid-security/hostcert.pem
-rw------- 1 root   root   1675 Mar 13  2009 /etc/grid-security/hostkey.pem

```

>  **If setting up the Auth Tool,*get a "commercial" certificate** that would be trust in major browsers.  This may depend on your site's policies and supplier preferences - just follow them, there's nothing special about this certificate, it only has to be trusted by browsers.

## External Software

Setting up this server will require us to install software, from both the ARCS repository,

using `yum`, and from a VDT mirror, using `pacman`.

- Configure ARCS RPM repository

``` 
cd /etc/yum.repos.d && wget http://projects.arcs.org.au/dist/arcs.repo
```
- Note: on a 64-bit system, change the repository file to use ARCS i386 repository itself (the ARCS 64-bit repository is not populated).  I.e., change the `baseurl` for the *arcs* repository in `/etc/yum.repos.d/arcs.repo` to: 

``` 
baseurl=http://projects.arcs.org.au/dist/production/$releasever/i386
```

*RHEL Note*

I found that for an `RHEL` as opposed to a `CentOS` system I needed to 

drop the *$releasever* from the URI too, so 

``` 
baseurl=http://projects.arcs.org.au/dist/production/i386
```

- Download and setup pacman:

``` 

mkdir /opt/vdt
cd /opt/vdt
wget http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz
tar xf pacman-*.tar.gz
cd pacman-*/ && source setup.sh && cd ..

```

- Set an environmental variable for the VDTMIRROR that will be used

All of the instructions below should ensure the following environmental variable is set,

ahead of any `pacman` operations.

``` 
export VDTMIRROR=http://vdt.cs.wisc.edu/vdt_200_cache
```

# Preparing the installation

## Prerequisites

**Q** Is xinetd a dependency of the two ARCS packages ?

- If you do not have the network services launcher `xinetd` installed


>  yum install xinetd
>  yum install xinetd

- Install the ARCS system monitoring tool GridPulse and the ARCS Gateway addons


>  yum install APAC-gateway-gridpulse Ggateway
>  yum install APAC-gateway-gridpulse Ggateway

**Warning**

Installing `APAC-gateway-gridpulse` places an uncommented **cron task** in

the **root crontab** that will start whether you are ready or not.

You may want to comment this out.

Similarly, `Ggateway` installs an hourly **cron task** called `auditquery`

You can prevent this from running by removing the execute permission bit with `chmod`

`chmod -x /etc/cron.hourly/auditquery`

You will obvioulsy need to remember to turn these back on once you are happy with the

local set up.

## VDT components

- Required packages:
- ***Globus-WS** - the Globus WS-GRAM4 server
- ***PRIMA-GT4** - the PRIMA module for making authorization callouts to the GUMS server
- **Globus local scheduler interface: for PBS, choose*Globus-WS-PBS-Setup**, for SGE, choose **Globus-WS-SGE-Setup** ... for other LRMs, find out what's available.

- Recommended packages:
- ***GSIOpenSSH** - GSI-enabled ssh server and client
- ***MyProxy-Client** - to have the "myproxy-logon" command
- ***VOMS-Client** - to have the "voms-proxy-init" command
- ***UberFTP** - for a command-line GridFTP client, "uberftp"
- ***Globus-Base-SDK** - to be able to compile Globus packages (required if you need to recompile any parts of Globus or the local LRM interface)

Installing the recommended packages makes the server a useful grid client with command-line tools 

that can be usedfor testing & debugging.

## Installing VDT components

- If you do not have `pacman` setup, for example, you are returning to a partially installed system, you may need to set it up again

>  source /opt/vdt/pacman-*/setup.sh

This command adds a couple of VDT-related locations to the `$PATH` variable and sets 

`$PACMAN_LOCATION`.

- Assuming you have `pacman` setup for the current session

>  cd /opt/vdt
>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)

- Prepare and run the installation command-line: Start with {{pacman -get }} and add each package prefixed by '$VDTMIRROR:'

- The minimum install for a PBS-based system is:

``` 
pacman -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4 $VDTMIRROR:Globus-WS-PBS-Setup
```

- An equivalant install with all recommended packages is:

``` 
pacman -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4 $VDTMIRROR:VOMS-Client $VDTMIRROR:MyProxy-Client $VDTMIRROR:UberFTP $VDTMIRROR:Globus-Base-SDK $VDTMIRROR:GSIOpenSSH $VDTMIRROR:Globus-WS-PBS-Setup 

```

**Q** Would the user lose anything by doing this in stages, eg, Base, Recommended, LRM, that would then make things clearer, rather less specific to a given LRM,eg

``` 
pacman -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4
```

``` 
pacman -get $VDTMIRROR:VOMS-Client $VDTMIRROR:MyProxy-Client $VDTMIRROR:UberFTP \
$VDTMIRROR:Globus-Base-SDK $VDTMIRROR:GSIOpenSSH
```

``` 
pacman -get $VDTMIRROR:Globus-WS-SGE-Setup
```

**Note** You have to have some semblence of an SGE installtion on the gateway 

ahead of the `Globus-WS-SGE-Setup` set up: not clear exactly what it needs (logs mention `qsub`) but it baulks otherwise.

- Make the environment variable setup scripts created by VDT load in the default profile and load them for the current session


>  cp /opt/vdt/setup.sh  /etc/profile.d/vdt.sh
>  cp /opt/vdt/setup.csh /etc/profile.d/vdt.csh
>  . /etc/profile.d/vdt.sh
>  cp /opt/vdt/setup.sh  /etc/profile.d/vdt.sh
>  cp /opt/vdt/setup.csh /etc/profile.d/vdt.csh
>  . /etc/profile.d/vdt.sh

## Post-install VDT configuration

### Configure VDT certificate distribution

Certificate-based grid security with BeSTGRID relies upon the APACGrid CA.

The APACGrid CA is part of a global certificate distribution maintained by the IGTF. 

VDT comes with a tool to download and update a certificate distribution, but requires the user to make an (informed) choice on which certificate distribution to trust.  The VDT team is also creating a convenient distribution based on IGTF - but we do need to configure this tool to point to this distribution.

- Run the following command to select the VDT distribution and install it into /etc/grid-security/certificates

``` 
vdt-ca-manage setupca --location root --url vdt
```
- Note: behind the scenes, the tool will
	
- Backup and rename any exsting `/etc/grid-security/certificates`
- Add the following line to `$VDT_LOCATION/vdt/etc/vdt-update-certs.conf`: 

``` 
cacerts_url = http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version
```

- Note: Other installation notes can suggest getting the APACGrid CA Cert directly, eg 

``` 
wget https://ca.apac.edu.au/pub/cacert/cacert.crt
```
- However the APACGrid CA Cert is this one from the IGTF bundle 

``` 
/etc/grid-security/certificates/1e12d831.0
```

In order to have the ARCS SLCS1 CA bundle available we need to copy that bundle into the main certificates directory

and ensure that VDT includes those files in any subsequent updates:

- Copy the ARCS SLCS1 CA bundle files into `/etc/grid-security/certificates`

``` 

 cd /etc/grid-security/arcs-slcs-ca 
 cp * /etc/grid-security/certificates  

```

- Tell the VDT certificates updater to include the files in the next certificates update: edit `/opt/vdt/vdt/etc/vdt-update-certs.conf` and add:

``` 

 include=/etc/grid-security/arcs-slcs-ca/1ed4795f.0 
 include=/etc/grid-security/arcs-slcs-ca/1ed4795f.namespaces 
 include=/etc/grid-security/arcs-slcs-ca/1ed4795f.signing_policy

```

# Post-install configuration

## Tuning globus configuration

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

## Globus Interactions with the Local Resource Manager

(Removed the PBS specific info that was in a lot of this)

Globus was originally designed to be run on the cluster headnode where the Local Resource Manager would also be running.

When running Globus on a separate virtual machine, the NG2, it's necessary to facilitate the same information flow that would have been available in the single machine set up. 

Globus needs to interact with both the job scheduling and logging functionality of the LRM.

### Globus Interactions with the LRM's Job Scheduler

The ways Globus interacts with the Local Resource Manager's scheduling functionality are:

1. Globus invokes the internal Perl JobManager framework and runs LRM-specific module.

This module builds the job script and in the end runs whichever submission command is used.
2. When a job is killed, the LRM-specific module (as in #1) invokes a queue deletion command.
3. MDS4 running in the Globus WS-container invokes MIP (/usr/local/mip/mip) to gather information about the cluster - and that involves invoking queue status commands.
4. When accessing the home directory, the GridFTP server serves the files in users home directories (typically mount to NG2 via NFS).

The procedures implementing local scheduler access, include:

- Mount shared home directories (site specific)
- Link to cluster local accounts (site specific)
- Link to local scheduler (LRM and site specific)

### Globus Interactions with the LRM's Status Logging

Globus, at version 4, is unable to use any LRM tools to query the status of the local resource.

Globus is written under the assumption that it will have access to the LRM log files.

Globus runs a separate LRM-specific process called Scheduler-Event-Generator (SEG).

This process reads the LRM-specific logs and feeds the job status information to Globus.

This can be achieved by either

- mounting filesystems so as to make the log directory visible
- replicating the logs from the LRM server to the NG2.

LRM-specific versions of the `telltail` and `logmaker` scripts are used to 

replicate the logs.

These are need to be installed on the both the NG2 gateway and on the LRM machine.

### LRM-specific instructions

- PBS: Setting up an NG2/PBS specific parts
- SGE: Setting up an NG2/PBS specific parts  (See below for mine)

[Accounting Data Replication](#IoSCCSettingupanNG2-AccountingDataReplication)

## Turn VDT services on

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

- Note that the receiving software for the information wants the job accounting data in PBS format.
	
- There's therefore some LRM-specific stuff to do here

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

### LRM-specific instructions

- PBS: Setting up an NG2/PBS specific parts
- SGE: Setting up an NG2/PBS specific parts  (See below for mine)

[Usage reporting](#IoSCCSettingupanNG2-Usagereporting)

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

**KMB Note** I had already setup the EPEL repository at UoC.

- Install MIP and it's python module


>  yum install APAC-mip APAC-mip-module-py
>  yum install APAC-mip APAC-mip-module-py

For me it installed

``` 

 APAC-glue-schema              noarch     0.1-5          arcs
 APAC-mip                      noarch     0.2.7-5        arcs
 APAC-mip-module-py            noarch     1.0.651-14     arcs
Installing for dependencies:
 perl-IO-Socket-SSL            noarch     1.01-1.fc6     rhel-x86_64-server-5
 python-lxml                   x86_64     2.0.11-1.el5   epel

```

The YUM install seems to provide some files below `modules/int/` that are broken

links: not sure what to do with these **??**

``` 

Cluster/Cluster                   -> /home/eshook/Projects/MIP/mip/modules/int/.integrator
ComputingElement/ComputingElement -> /home/eshook/Projects/MIP/mip/modules/int/.integrator
Site/Site                         -> /home/eshook/Projects/MIP/mip/modules/int/.integrator
SubCluster/SubCluster             -> /home/eshook/Projects/MIP/mip/modules/int/.integrator

```

## Configuring MIP

**KMB Note**  I moved MIP so that it lives below `/opt/mip` and not `/usr/local/mip`.

All the following instructions therefore use the generic `/path/to/mip`

**KMB Note** Unbeknownst to you, `APAC-mip-globus` installs a script into the `Globus`

tree as `$GLOBUS_LOCATION/libexec/mip-exec`. It is actually a copy of the file `mip-exec.sh`

but as the `.sh` gets removed you might not associate the two. The script contains a hard-coded

path to the MIP executable.

Maybe we can simply **link it** which would preserve the "ownership" information.

This section assumes you'll be advertising in MDS:

- one *Site* element (representing your site)
- one *Cluster* element (representing the single cluster you are connecting to the grid)
- one *SubCluster* element (... this is a weird name for the hardware description of your cluster)
- one *ComputeElement* element (representing one job queue on your cluster)
- one *StorageElement* element (representing the user home directories accessible via GridFTP)

- If you need to advertise more ComputeElements, adjust the configuration accordingly (providing multiple IDs/names for the elements) - but please do not advertise multiple queues providing access to the same physical resources.  That would break the metascheduling algorithms used in Grisu.
- If you need to advertise multiple clusters (with the same home directories and user accounts), the changes will be still straightforward.
- If you need to advertise multiple clusters with the different home directories and user accounts (and you are already running multiple NG2s), it will be more complex - and you may have to use MIP integrator to aggregate data from multiple NG2s.  See [Setup MIP on NG2HPC at University of Canterbury](setup-mip-on-ng2hpc-at-university-of-canterbury.md) for more information on how that was done at Canterbury.

### default.pl

- Start configuring MIP by setting the element IDs in `/path/to/mip/config/default.pl`:
	
- Uncomment the lines for `SubCluster`, `Cluster`, `CompungElement` and `StorageElement`
- Change the Site ID to your site's domain name.
- Change the StorageElement name to your NG2 gateway hostname.
- Prefix the SubCluster, Cluster and ComputingElement ID qualifiers with your NG2 gateway hostname.
- You should get something similar to (where the gateway hostname is `ng2.canterbury.ac.nz`):

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

### apac_config.py

Now edit `/path/to/mip/config/apac_config.py` and define the Site, SubCluster,Cluster,ComputingElement, and StorageElement elements.  Use the same IDs as in `default.pl` as their IDs (the array index used when the object is created).  

Provide the following information:

- Fill in Site information as reasonable (it's not necessary to provide the OtherInfo and Sponsor fields - you may comment them out if they are not relevant)
- Define compute element for the local queue to be published.
- In the subCluster element, manually define CPU, Memory and OS properties - they are different for the cluster nodes and for NG2

- There should be one VOView and one StorageArea element for each VO group supported (like /ARCS/BeSTGRID, /ARCS/NGAdmin).  Edit the configuration accordingly.

**KMB Notes**

The original script hard codes paths to a couple of utilities for `PBS`. 

The equivalent utilities for SGE can be defined in a way that removes the need for

the sys admin to hard code such paths.

### SIP.ini

>  **Create /path/to/mip/config/default_*gateway.host.name**-sub1_SIP.ini

- 
- (i.e., name the file after the ID selected for the subCluster element).

**KMB Q?** There would seem to be no site specific info in this file: Why not distribute

a templat that people just rename ?

**KMB Q?** What does SIP stand for here ?

``` 

[source2]
uri: file:softwareInfoData/localSoftware.xml
format: APACGLUE1.2

[action]
type: log

[log]
location: /path/to/mip/var/log/mip.log

[definitionMapulations]
APACSchemaDirectory: /usr/local/share/

```

- Create MIP log file and make it writable:


>  mkdir -p /path/to/mip/var/log
>  touch /path/to/mip/var/log/mip.log
>  chmod a+rw /path/to/mip/var/log/mip.log
>  mkdir -p /path/to/mip/var/log
>  touch /path/to/mip/var/log/mip.log
>  chmod a+rw /path/to/mip/var/log/mip.log

### localSoftware.xml

- Define software packages in /path/to/mip/modules/apac_py/SubCluster/softwareInfoData/localSoftware.xml

A couple of examples follow, so as to show typical fields, firstly an available selfcontained

package, `R`, version 2.10.0, then a standard system command:

``` 

<SoftwarePackage LocalID="R/2.7.1">
    <Name>R</Name>
    <Version>2.7.1</Version>
    <Module>R/2.7.1</Module>
    <SoftwareExecutable LocalID="R/2.7.1">
        <Name>R</Name>
        <Path>/usr/bin</Path>
        <SerialAvail>true</SerialAvail>
        <ParallelAvail>false</ParallelAvail>
   </SoftwareExecutable>
</SoftwarePackage>

<SoftwarePackage LocalID="UnixCommands/coreutils-5.2.1-31.7">
     <Name>UnixCommands</Name>
     <Version>coreutils-5.2.1-31.7</Version>
     <Module>UnixCommands/coreutils-5.2.1-31.7</Module>
     <SoftwareExecutable LocalID="UnixCommands/coreutils-5.2.1-31.7-cat">
         <Name>cat</Name>
         <Path>/bin</Path>
         <SerialAvail>true</SerialAvail>
         <ParallelAvail>false</ParallelAvail>
     </SoftwareExecutable>
     <SoftwareExecutable LocalID="UnixCommands/coreutils-5.2.1-31.7-ls">
         <Name>ls</Name>
         <Path>/bin</Path>
         <SerialAvail>true</SerialAvail>
         <ParallelAvail>false</ParallelAvail>
     </SoftwareExecutable>
</SoftwarePackage>

```

- Test your MIP works and produces valid information
	
- Run 

``` 
/path/to/mip/mip
```
- Check for any error messages
- Review the data provided for meaningful values.

There may be more to this than meets the eye.

Vlad reckons that this `/opt/vdt/globus/libexec/mip-exec` is what actually

does something yet it hardcodes a path to the `MIP` script that I have not 

changed to match my setup (because I knew nothing about it), yet I was still able

to send stuff over to ARCS ?

## Activating MDS in Globus

If you are confident that the contents of your MDS is correct - and ready to be published to the outside world:

- Request that your NG2 is allowed to publish to the central MDS index: send a request to help@arcs.org.au and include the DN of your server.
	
- You can get the DN with: 

``` 
openssl x509 -subject -noout -in /etc/grid-security/hostcert.pem
```

- Activate MIP in Globus


>  yum install APAC-mip-globus
>  yum install APAC-mip-globus

- Secure your MDS - so that it's not open to the world for writing.  This contents would get posted to the central index.
	
- Create empty `/etc/grid-security/mds-grid-mapfile`: 

``` 
touch /etc/grid-security/mds-grid-mapfile
```
- The rest has been done by the APAC-mip-globus install scriptlet (which edits)

>    `/opt/vdt/globus /etc/globus_wsrf_mds_index/index-security-config.xml`
>    `/opt/vdt/globus/etc/globus_wsrf_mds_index/server-config.wsdd`)

- Disable auto-registration of RFT and GRAM services - they won't be able to authenticate now and we don't want them in the central index.  Edit

>   `/opt/vdt/globus/etc/gram-service/jndi-config.xml`
>   `/opt/vdt/globus/etc/globus_wsrf_rft/jndi-config.xml`

 and set the **reg** parameter to `false`.

- Restart globus


>  service globus-ws stop
>  service globus-ws start
>  service globus-ws stop
>  service globus-ws start

Guy Kloss at Massey pointed out that you need to prime the MDS.

I added his script as a `/etc/cron.daily` file.

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

- For more information, see my description of the [problem](vladimirs-grid-notes.md#Vladimir&#39;sgridnotes-RFTstagingfails).

# Making local cluster accounts ready for the grid

- Some grid clients would assume that the Globus scratch directory (refered to as `${GLOBUS_SCRATCH_DIR`} in Globus job scripts) exists in each account.  By default, Globus maps the scratch directory to `$HOME/.globus/scratch`.
	
- Create this directory for each user (and make it owned by the user).

# Testing

- Note: you will need a valid proxy certificate on the system where you run the tests ... if this is your NG2, the myproxy-logon command from MyProxy-Client may now come handy.

Vlad's notes suggest running some gsiftp tests with `uberftp`.

Older `uberftp` clients, such as the ones from 

>  [http://vdt.cs.wisc.edu/vdt_rpms/1.10.1/release-1/x86_rhap_5/](http://vdt.cs.wisc.edu/vdt_rpms/1.10.1/release-1/x86_rhap_5/)

can't use `-passive` and `-active`

- Try running a job through the Globus built-in Fork scheduler:


>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft Fork -c /usr/bin/id
>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft Fork -c /usr/bin/id

- Try running a job through the Globus LRM scheduler (SGE):


>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft SGE -c /usr/bin/id
>  globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft SGE -c /usr/bin/id

# Post Install Operations

I have started to gather this info together, away from the clutter of the install instructions here

[Administering_an_NG2](administering-an-ng2.md)

# My SGE Notes 

The local resource manager for VUW's pilot BeSTGRID-facing compute grid (Note: a RHEL `x86_64` not CentOS platform) is SGE.

These are my SGE-specfic notes where they differ from those provided in the Rocks-specific

notes elsewhere.

## Install SGE

- Get SGE `ge62u5_lx24-amd64.tar.gz` from the Grid Engine project download page.

- Create a user and group for `sgeadmin`

``` 

cd /opt
tar xf /path/to/ge62u5_lx24-amd64.tar.gz
# creates /opt/ge6.2u5
ln -sf /opt/ge6.2u5 /opt/gridengine
cd /opt/gridengine
tar xf ge-6.2u5-common.tar.gz
tar xf ge-6.2u5-bin-lx24-amd64.tar.gz
rm ge-6.2u5-bin-lx24-amd64.tar.gz ge-6.2u5-common.tar.gz
chown -R sgeadmin:sgeadmin /opt/ge6.2u5

```

Temporarily assign a password to the `segadmin` account so that we can 

rsync the `$SGE_ROOT/$SGE_CELL/common` directory from the grid master,

as that is all you actually need at install time.

Then lock the `segadmin` account, before running an execd install.

``` 

cd $SGE_ROOT
./install_execd

```

The install process will offer you the chance to create a script to start the 

`execd` at machine boot - you can say no to this: the gateway machine

is not an execution host.

Be aware that the install process will start (`sge_execd`) one anyway 

but there you go, you'll just have to kill it once you've completed the install,

unless you choose to install the boot script just to be able to shut it down.

The install process will offer you the chance to create a queue instance for the 

gateway host - again, say no.

## Accounting Data Replication

Vlad's files at the ARCS Gitorious from `sge-scripts/log-replication`

``` 

sge-logmaker               ng2:/usr/local/sge-telltail/sge-logmaker
sge-logmaker.RH            ng2:/etc/rc.d/init.d/sge-logmaker 

sge-telltail               qmaster:/usr/local/sge-telltail/sge-telltail
sge-telltail-as-nobody.RH  qmaster:/etc/rc.d/init.d/sge-telltail 

```

Needed to install the `perl-DateManip` package.

Went with `/opt/sge-telltail` rather than create a directory below 

`/usr/local`. Edit init.d scripts to reflect that change.

## Globus integration

We have the default.

## Environment variables for qsub

Vlad's second option does appear to work, however there's a gotcha.

Scripts in `/etc/profile.d` do not need to have executable bits

set so as to have their contents "sourced" into the environment.

It would appear (after a lot of looking so as to see it appear) that 

scripts in `$VDT_LOCATION/post-setup` do need to have some

executable bits set.

By default the SGE `settings.{c,}sh` files that get created

in `$SGE_ROOT/$SGE_CELL/common` so not have executable bits

set.

If you simply copy those to `/etc/profile.d` those won't have 

either.

If you then link the `/etc/profile.d` scripts into 

`$VDT_LOCATION/post-setup` then neither will those.

## Job manager LRM interface script

Downloaded `sge.pm` from ARCS and installed.

Re Vlad's notes on alternatives to editing `/etc/services`, there may be some scope

for setting the environment we want inside the `sge.pm` so try editing that.

``` 

# cd /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/
# diff -u sge.pm{-20100517,}
--- sge.pm-20100517     2010-06-11 12:19:39.000000000 +1200
+++ sge.pm      2010-06-11 12:21:21.000000000 +1200
@@ -22,7 +22,8 @@
     $mpirun, $sun_mprun,
     $CAT,
     $SGE_ROOT, $SGE_CELL,
-    $SGE_MODE, $SGE_RELEASE);
+    $SGE_MODE, $SGE_RELEASE,
+    $SGE_QMASTER_PORT, $SGE_EXECD_PORT);
 
 BEGIN
 {
@@ -52,6 +53,9 @@
     $SGE_RELEASE = '6.0u6';
 
     $ENV{"SGE_ROOT"} = $SGE_ROOT;
+
+    $SGE_QMASTER_PORT = '6444';
+    $ENV{"SGE_QMASTER_PORT"} = $SGE_QMASTER_PORT;
 }

```

Couple of things to watch here

>    1. Make sure that the **$SGE_ARCH** is actually yours !
>    2. It is not just **SGE_QMASTER_PORT** that needs to be set there you also need **SGE_EXECD_PORT**

to which end we can make use of **SGE's** own utility to report the **arch**

``` 

# diff -u sge.pm{-20100517,}
--- sge.pm-20100517     2010-06-11 12:19:39.000000000 +1200
+++ sge.pm      2010-07-08 16:58:18.000000000 +1200
@@ -22,12 +22,14 @@
     $mpirun, $sun_mprun,
     $CAT,
     $SGE_ROOT, $SGE_CELL,
-    $SGE_MODE, $SGE_RELEASE);
+    $SGE_MODE, $SGE_RELEASE,
+    $SGE_QMASTER_PORT, $SGE_EXECD_PORT);
 
 BEGIN
 {
     $SGE_ROOT    = '/opt/gridengine';
-    $SGE_ARCH    = "lx26-amd64";
+    # $SGE_ARCH    = "lx26-amd64";
+    chomp($SGE_ARCH = `$SGE_ROOT/util/arch`);
     $qsub        = "$SGE_ROOT/bin/$SGE_ARCH/qsub";
     $qstat       = "$SGE_ROOT/bin/$SGE_ARCH/qstat";
     $qdel        = "$SGE_ROOT/bin/$SGE_ARCH/qdel";
@@ -52,6 +54,12 @@
     $SGE_RELEASE = '6.0u6';
 
     $ENV{"SGE_ROOT"} = $SGE_ROOT;
+
+    $SGE_QMASTER_PORT = '6444';
+    $ENV{"SGE_QMASTER_PORT"} = $SGE_QMASTER_PORT;
+
+    $SGE_EXECD_PORT = '6445';
+    $ENV{"SGE_EXECD_PORT"} = $SGE_EXECD_PORT;
 }
 

```

At this point you should step back into the main thread of instructions

[Turn VDT services on](#IoSCCSettingupanNG2-TurnVDTserviceson)

## Usage reporting

Download the scripts, install and edit, and create the `$SGE_ROOT/$SGE_CELL/common/acct/pbs`

subdirectory required by it to get stuff into PBS format.

Modify the `/etc/cron.hourly/auditquery` script.

Note that my original script has only

`from gram_audit_table;`

and not

`from gram_audit_table where local_job_id is not NULL and finished_flag = TRUE;`

OK, that's a patch that's back in the non-LRM-specific notes.

We have skipped out but maybe we should have skipped back by now ???

And why did we not get `Ggateway-1.0.2-2 (released 2010-02-25)` ???

## Turning on debugging in JobManager.pm and subclassed codes

I couldn't see how to do this from the outside but there's a hack that achieves

the same thing as if you had changed the JobDescription object externally:

``` 

# cd $GLOBUS_LOCATION/lib/perl/Globus/GRAM
# diff -u JobManager.pm{.orig,}
--- JobManager.pm.orig  2010-07-08 16:33:20.000000000 +1200
+++ JobManager.pm       2010-07-08 16:35:59.000000000 +1200
@@ -90,6 +90,8 @@
         new Globus::GRAM::ExtensionsHandler($class, $description);
     }
 
+    $description->add('logfile', '/tmp/kevslog.log');
+
     if(defined($description->logfile()))
     {
         local(*FH);

```

Just remember to swap back once you have finished inspecting/debugging.

## Job scripts are copied into `/tmp`

The `sge.pm` from ARCS make a copy of the script that gets submitted to the 

SGE in `/tmp` and owned by the mapped username.

It is not clear why.

## More editing of sge.pm for MPI jobs

The default, non-Sun, SGE submission script builder is controlled by this stanza

``` 

        else
        {
            #####
            # Using non-Sun's MPI.
            #
            $sge_job_script->print("$mpirun " # " -np ". $description->count() . " "
                                   . $description->executable() . " $args < "
                                   . $description->stdin() . "\n");
        }

```

Note that the `-np` is actually commented out.

For an SGE-aware OpenMPI installtion, running on a culster of virtual machines

where OpenMPI can seemingly get confused by the virtual bridge interfaces, I 

had to alter that to 

``` 

        else
        {
            #####
            # Using non-Sun's MPI.
            #
            $sge_job_script->print( "$mpirun "
                ."--mca btl_tcp_if_include eth0 "
                ."-np \$NSLOTS "
                . $description->executable() . " $args "
                . "\n");
        }

```
