# Auckland Test Gateway

# Test Gateway Setup 

[APAC Test Suite For Auckland Gateway](/wiki/spaces/BeSTGRID/pages/3818228561)

[APAC repository](http://projects.gridaus.org.au/trac/systems/wiki/YumRepository) contains rpms for torque client

and other parts for ng2 gateway. The repository should be configured to not perform signature check:

>  gpgcheck=0

URL - [http://projects.arcs.org.au/dist/production/4/i386/](http://projects.arcs.org.au/dist/production/4/i386/).

[How to install Ng2 gateway](http://projects.gridaus.org.au/trac/systems/wiki/HowTo/InstallNg2)

# Information

- IP 130.216.89.8
- hostname ng2test.auckland.ac.nz

# VDT Install and Configuration

[Virtual Data Toolkit](http://vdt.cs.wisc.edu/index.html)

[list of VDT packages](http://vdt.cs.wisc.edu/releases/1.10.0/installation_select.html)

## Globus WS

- diff is not default on VM, so


>   yum install diffutils.i386
>   yum install diffutils.i386

- since CentOS 4.4 is not officially supported, we tell pacman to assume we are red hat 4 ([Installing on unsupported platform](http://vdt.cs.wisc.edu/releases/1.10.0/installation_advanced#unsup_plat)):


>  pacman -get -pretend-platform linux-rhel-4 [http://vdt.cs.wisc.edu/vdt_1100_cache:Globus-WS](http://vdt.cs.wisc.edu/vdt_1100_cache:Globus-WS)
>  pacman -get -pretend-platform linux-rhel-4 [http://vdt.cs.wisc.edu/vdt_1100_cache:Globus-WS](http://vdt.cs.wisc.edu/vdt_1100_cache:Globus-WS)

- all pre-installation questions are answered "yes", certificates are installed as root.

## Gatekeeper

- no need to specify platform second time:


>  pacman -get [http://vdt.cs.wisc.edu/vdt_1100_cache:VDT-Gatekeeper](http://vdt.cs.wisc.edu/vdt_1100_cache:VDT-Gatekeeper)
>  pacman -get [http://vdt.cs.wisc.edu/vdt_1100_cache:VDT-Gatekeeper](http://vdt.cs.wisc.edu/vdt_1100_cache:VDT-Gatekeeper)

- questions section
	
- set up Globus GRIS for non-secure access for simplicity. We probably don't need our own MDS anyway.
- since we are going to use GUMS, edg-mkgridmap cron job is disabled.
- gatekeeper requires xinetd:


>  yum install xinetd.i386
>  yum install xinetd.i386

## Globus-WS-PBS-Setup

PBS support isn't included in Globus-WS package on default. To install PBS support a package Globus-PBS-Setup should be installed then. 

- no need to specify platform second time:


>  pacman -get [http://vdt.cs.wisc.edu/vdt_1100_cache:Globus-WS-PBS-Setup](http://vdt.cs.wisc.edu/vdt_1100_cache:Globus-WS-PBS-Setup)
>  pacman -get [http://vdt.cs.wisc.edu/vdt_1100_cache:Globus-WS-PBS-Setup](http://vdt.cs.wisc.edu/vdt_1100_cache:Globus-WS-PBS-Setup)

# Installing Certificates

[How to request and install ARCS certificates](http://wiki.arcs.org.au/bin/view/Main/HostCertRequestAPACGridCA)

contents of grid-security.conf and grid-host-ssl.conf were transferred from real ng2 (with small modifications).

commands to make certificate requests for host:

>  grid-cert-request -host ng2test.bestgrid.org -force  -ca 1e12d831

Request without -int mode gives openssl error, and -int option is not supported, so I used openssl method:

>  [http://wiki.arcs.org.au/bin/view/Main/HostCertificates#Using_OpenSSL_from_the_Command_Line](http://wiki.arcs.org.au/bin/view/Main/HostCertificates#Using_OpenSSL_from_the_Command_Line)

Certificate and key locations:

>  /etc/grid-security/containerkey.pem
>  /etc/grid-security/containercert.pem

To introspect certificate info:

>  grid-cert-info -file /etc/grid-security/containercert.pem 

Created grid mapfile by hand, as the services require it before the startup.

Example /etc/grid-mapfile:

>  yhal003 "C=NZ, O=BeSTGRID, OU=The University of Auckland, CN=Yuriy Halytskyy"

# GUMS

Installation procedure

- installed GUMS Service


>  pacman -get [http://vdt.cs.wisc.edu/vdt_1100_cache:GUMS-Service](http://vdt.cs.wisc.edu/vdt_1100_cache:GUMS-Service)
>  pacman -get [http://vdt.cs.wisc.edu/vdt_1100_cache:GUMS-Service](http://vdt.cs.wisc.edu/vdt_1100_cache:GUMS-Service)

- [How To Install NG2 GUMS Instructions](http://projects.gridaus.org.au/trac/systems/wiki/HowTo/InstallNgGums)
	
- add gateway hostname to /etc/hosts
- Modify  build_nggums_vdt181.sh  PATH variable to include /opt/vdt/vdt/sbin/
- edit that file to have nohup /opt/vdt/fetch-crl/share/doc/fetch-crl-2.6.6/fetch-crl.cron
- edit mysql password in gums-add-mysql-admin
- add myself to gums admins ./gums-add-mysql-admin "/C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Yuriy Halytskyy"
- use the certificate for admin in browser to access GUMS web interface at ng2test.bestgrid.org:8443/gums

Error using GUMS web interface below means that two last steps were done incorrectly.

>  Error generating grid-mapfile: You are not authorized to perform this function. Contact your gums administrator if access is needed.

# PBS configuration

Gateway needs torque client, for GRAM to send requests to head node. The client must be configured to be able to send jobs

to head node.

Necessary configuration includes setting up passwordless ssh access between the gateway and headnode (both ways?), configuring

firewall and editing default server name in config files.

- torque client install


>  yum install torque-client.i386
>  yum install torque-client.i386


[GLobus PBS Integration](/wiki/spaces/BeSTGRID/pages/3818228682)

## Torque troubleshooting

[Torque troubleshooting](http://www.clusterresources.com/torquedocs21/10.1troubleshooting.shtml)

The error

>  qsub: Bad UID for job execution MSG=ruserok failed validating yhal003/yhal003 from ng2test.bestgrid.org

Had the following solution (from Rocks mailing list):

>  Bad UID for Job execution

>     If a user attempts to submit a job to PBS receives the following error
>     message Bad UID for execution, the user has not been authorized to run
>     on the server or execution host.

>     PBS  does  not  assume  a  uniform UID space; that means that UserA on
>     HostX  may  not  be  the  same  user  as  UserA on HostY. Therefore if
>     UserA at HostX  submits  a  job  to be run on HostY as UserA, or anyother
>     named  user,  then  PBS must be told that is ok. This authorization is
>     performed  by PBS by calling the common C library call ruserok(). Thus
>     on  HostY,  either  HostX must appear in the file /etc/hosts.equiv, or
>     UserA at HostX must appear in UserA's .rhosts file.

remote pbs commands:

>  qstat -B 130.216.77.36 #see queue status
>  qsub -q @130.216.77.36 # submit job on cluster host

# MDS

[Software Information Provider](http://projects.gridaus.org.au/trac/systems/wiki/InfoSystems/ConfigureGridAusSoftwareInfoProvider)

[Publishing information about hardware](http://projects.gridaus.org.au/trac/systems/wiki/InfoSystems/InstallConfigSteps)

## MIP Configuring

After installing MIP/MDS onto ng2test there were warning messages in $GOBUS_LOCATION/var/container-real.log:

``` 

2008-05-27 14:25:16,931 WARN  client.ServiceGroupRegistrationClient [Timer-5,status:472] Warning: Could not register
https://130.216.189.8:9443/wsrf/services/DefaultIndexService to servicegroup at 
https://ngmds.hpcu.uq.edu.au:8443/wsrf/services/DefaultIndexService -- check the URL and that the remote service is up.  Remote 
exception was org.globus.wsrf.impl.security.authorization.exceptions.AuthorizationException: "<anonymous>" is not authorized to 
use operation: {http://mds.globus.org/index/2004/07/12}add on this service

2008-05-27 14:25:17,393 WARN  client.ServiceGroupRegistrationClient [Timer-5,status:472] Warning: Could not register 
https://130.216.189.8:9443/wsrf/services/DefaultIndexService to servicegroup at 
https://mds.sapac.edu.au:8443/wsrf/services/DefaultIndexService -- check the URL and that the remote service is up.  Remote exception 
was org.globus.wsrf.impl.security.authorization.exceptions.AuthorizationException: "<anonymous>" is not authorized to use 
operation: {http://mds.globus.org/index/2004/07/12}add on this service

```

To fix that a command should be issued:

>  /usr/local/mip/config/globus/mip-globus-config -l /opt/vdt/globus install
>  service globus-ws stop
>  service globus-ws start

It updates several files:

``` 

installing mip-globus config files in place...
==> backing up /opt/vdt/globus/etc/globus_wsrf_mds_index/downstream.xml to /opt/vdt/globus/etc/globus_wsrf_mds_index/downstream.xml.orig
==> installing /opt/vdt/globus/etc/globus_wsrf_mds_index/downstream.xml
==> backing up /opt/vdt/globus/etc/globus_wsrf_mds_index/upstream.xml to /opt/vdt/globus/etc/globus_wsrf_mds_index/upstream.xml.orig
==> installing /opt/vdt/globus/etc/globus_wsrf_mds_index/upstream.xml
==> backing up /opt/vdt/globus/etc/globus_wsrf_mds_index/server-config.wsdd to /opt/vdt/globus/etc/globus_wsrf_mds_index/server-config.wsdd.orig
==> installing /opt/vdt/globus/etc/globus_wsrf_mds_index/server-config.wsdd
==> backing up /opt/vdt/globus/etc/globus_wsrf_mds_index/hierarchy.xml to /opt/vdt/globus/etc/globus_wsrf_mds_index/hierarchy.xml.orig
==> installing /opt/vdt/globus/etc/globus_wsrf_mds_index/hierarchy.xml
==> installing /opt/vdt/globus/etc/globus_wsrf_mds_index/client-security-config.xml
==> backing up /opt/vdt/globus/etc/globus_wsrf_mds_index/index-security-config.xml to /opt/vdt/globus/etc/globus_wsrf_mds_index/index-security-config.xml.orig
==> installing /opt/vdt/globus/etc/globus_wsrf_mds_index/index-security-config.xml
==> installing /opt/vdt/globus/libexec/mip-exec
==> installing /opt/vdt/globus/etc/globus_wsrf_mds_index/gluece-rpprovider-config.xml

```

Also a file should be created:

>  /etc/grid-security/mds-grid-map

with entry

>  "/C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=ng2test.auckland.ac.nz" grid-mds

Then the following persons should be contacted to authorize gateway to be present in MDS:

``` 

 Gerson Galang <gerson.galang@sapac.edu.au>
 Will Hsu <w.hsu1@uq.edu.au

```
