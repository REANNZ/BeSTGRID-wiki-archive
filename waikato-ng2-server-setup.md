# Waikato NG2 server setup

# Overview

As recommended in the deployment guidelines for ARCS and BeSTGRID, this GUMS server is being deployed.

This host is a Virtual Machine, using the x86_64 64 bit system architecture.  The Distribution is Debian Lenny (5.0), amd64.  The system image is based on a `debootstrap` generated system image, rather than an install from an ISO.  This meant that various debconf settings were not done on installation.  See [Debian Tips](/wiki/spaces/BeSTGRID/pages/3818228765)

It was installed following these documents:

- [Setting up an NG2](/wiki/spaces/BeSTGRID/pages/3818228585)
- [Setting up an NG2 on Ubuntu](/wiki/spaces/BeSTGRID/pages/3818228397)

Notes on the various stages and differences follow below.

# Apt sources.list

``` 

deb http://ftp.monash.edu.au/pub/linux/debian/ lenny main
deb http://security.debian.org/ lenny/updates main

```

# X509 ARCS Host Certificate Details

``` 

Subject/DN: "C=NZ/O=BeSTGRID/OU=The University of Waikato/CN=ng2.symphony.waikato.ac.nz"
Valid from: Aug 16 01:17:43 2010 GMT
Valid until: Aug 16 01:17:43 2011 GMT
Issued by: C=AU, O=APACGrid, OU=CA, CN=APACGrid/emailAddress=camanager@vpac.org
Contact email: symphony_admins@wand.net.nz

```

Emails with regard to renewal will come to the above address.  The certificate, its signing request, and the key can all be found in `/etc/grid-security` on the machine.  The key file is unencrypted. This certificate request and key are read-only for the root user.

The steps in [Debian Tips](/wiki/spaces/BeSTGRID/pages/3818228765) were carried out to make the machine more administrator friendly, with an emphasis on remote access.

# SMTP Mail Server Details

Post fix was installed with `apt-get install postfix`.  It is configured as a `Satelite system`, with mail smart host set to `smtp.waikato.ac.nz`.  The system mail name is set to `ng2.symphony.waikato.ac.nz`.

# Configuring Torque

Follow [Setting up an NG2 on Ubuntu#Configuring_local_scheduler_access](/wiki/spaces/BeSTGRID/pages/3818228397#SettingupanNG2onUbuntu-Configuring_local_scheduler_access)

On the Symphony cluster, torque is packaged as `torque-commands, torque-common,` etc.  

# Grid pulse setup

The instructions up at [Setting_up_an_NG2_on_Ubuntu#GridPulse](setting-up-an-ng2-on-ubuntu.md) were followed.

Here's a tip for Debian Lenny, or Debian 5. I installed `fakeroot` and `alien`, and did the following in my home directory:

``` 

$ wget http://projects.arcs.org.au/dist/production/5/x86_64/noarch/APAC-gateway-gridpulse-0.3-4.noarch.rpm
$ apt-get install fakeroot alien
$ fakeroot alien APAC-gateway-gridpulse-0.3-4.noarch.rpm

```

# Ggateway

Proceed as per [Setting_up_an_NG2_on_Ubuntu#Ggateway](setting-up-an-ng2-on-ubuntu.md)

# LRM log replication - PBS Telltail/logmaker

Proceed mostly as per [Setting_up_an_NG2_on_Ubuntu#Configure_LRM_log_replication_from_LRM_server_to_the_NG2](setting-up-an-ng2-on-ubuntu.md)

`pbs-logmaker` is now a separate package from pbs-telltail.  Download it from [pbs-logmaker-1.0.3-1.noarch.rpm](http://projects.arcs.org.au/dist/production/5/x86_64/noarch/pbs-logmaker-1.0.3-1.noarch.rpm)

and use alien to convert it to deb.

``` 

$ fakeroot alien pbs-logmaker-1.0.3-1.noarch.rpm

```

and 

``` 

# dpkg -i pbs-logmaker-1.0.3-1.noarch.rpm

```

to install it.

For the `/etc/init.d/pbs-logmaker` script use the following:

``` 

#!/bin/bash

# Start or stop pbs-logmaker daemon, which re-creates remote PBS server
# logs locally
#
# Graham Jenkins <graham@vpac.org>
# Dec. 2005. Rev'd 20070322

### BEGIN INIT INFO
# Provides:          pbs-logmaker
# Required-Start:    $local_fs $network $time
# Required-Stop:     $local_fs $network
# Should-Start:      
# Should-Stop:       
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: start and stop the pbs-logmaker daemon
# Description:       pbs-logmaker daemon
### END INIT INFO

case "$1" in
  start)    status /usr/sbin/pbs-logmaker >/dev/null 2>&1
            [ "$?" -eq 0 ] && echo "pbs-logmaker is already running" >&2 && exit 2
            echo -n "Starting pbs-logmaker "
            daemon /usr/sbin/pbs-logmaker \
              /var/spool/pbs-logmaker/server_logs 2812
            RETVAL=$?; echo                                                   ;;
  stop)     echo -n "Shutting down pbs-logmaker "
            pkill -15 pbs-logmaker
            RETVAL=$?; echo                                                   ;;
  status)   status /usr/sbin/pbs-logmaker                       ;;
  restart) "$0" stop; sleep 2; "$0" start                                     ;;
  *)       echo "Usage: $0 {start|stop|status|restart}" >&2; exit 2           ;;
esac
exit $RETVAL

```

# Configuring local scheduler access

Install the `daemon` package,

``` 

apt-get install daemon

```

and then proceed as per [Setting_up_an_NG2_on_Ubuntu#Configuring_local_scheduler_access_2](setting-up-an-ng2-on-ubuntu.md)

# VDT Pacman set up

As per [Setting_up_an_NG2_on_Ubuntu#Installing_VDT](setting-up-an-ng2-on-ubuntu.md). Since we are on Debian 5, no major problems here.

Do the following first:

The package `insserv` needs to be installed for the VDT init scripts to be set up by `chkconfig`.

``` 

# apt-get install insserv

```

To load VDT shell environment on login to server the following has to be added to `/etc/profile`

``` 

# Add this to deal with VDT environment setup
# Debian Squeeze has /etc/profile.d directory
# Matthew Grant <grntma@physics.otago.ac.nz> Mon, 06 Sep 2010 12:53:35 +1200
if [ -d /etc/profile.d ]; then
        for i in /etc/profile.d/*.sh; do
                if [ -r $i ]; then
                        . $i
                fi
        done
        unset i
fi

```

and the `/etc/profile.d` directory created.

``` 

# mkdir /etc/profile.d

```

Then proceed as per [Setting_up_an_NG2_on_Ubuntu#Installing_VDT](setting-up-an-ng2-on-ubuntu.md).

# Post-install configuration

Follow all steps according to [Setting up an NG2#Post-install configuration](/wiki/spaces/BeSTGRID/pages/3818228585#SettingupanNG2-Post-installconfiguration). Only thing to do before `vdt-control --on` is to:

- Edit `/opt/vdt/post-install/globus-ws` has to be edited to remove `tomcat-55` and `condor` from its `#Required-Start:` line.

# Setup job reporting

Follow all steps according to [Setting up an NG2#Setup job reporting](/wiki/spaces/BeSTGRID/pages/3818228585#SettingupanNG2-Setupjobreporting).

# Setup MDS/MIP

Install `python-lxml` and `libxml2-utils`,

``` 

apt-get install python-lxml libxml2-utils

```

and proceed according to [Setting_up_an_NG2_on_Ubuntu#Setup MDS/MIP](setting-up-an-ng2-on-ubuntu.md)

# Getting it all going

This documents work done by Vladimir Mencl in November/December 2010 to finish off the setup and get the gateway going.

# System setup

- open TCP ports 40000-41000 for outgoing connections

- remove NAT traversal for outgoing connections from NG2

- fix PBS log path in `/opt/vdt/globus/etc/globus-pbs.conf`
	
- The file was referring to `/var/torque/server_logs` but logs are being replicated to `/var/spool/pbs-logmaker/server_logs`
- Correct settings thus are:

``` 
log_path=/var/spool/pbs-logmaker/server_logs
```

- fix hostname - from unqualified `NG2` to FQDN `ng2.symphony.waikato.ac.nz`
	
- `/etc/hostname` already contains the correct hostname, but the system has not been rebooted since.  Reload now, check on next reboot:

``` 
hostname --file /etc/hostname
```
- dtto for nggums: edit `/etc/hostname` to make it FQDN (nggums.symphony.waikato.ac.nz) and reload with:

``` 
hostname --file /etc/hostname
```

- fix hostname (from "ng2" to "ng2.symphony.waikato.ac.nz") in globus config files: `/opt/vdt/globus/etc/globus-job-manager.conf` and `/opt/vdt/globus/etc/gram-service/globus_gram_fs_map_config.xml`

- make home directory not world readable - this triggers a [bug in Globus](http://bugzilla.globus.org/bugzilla/show_bug.cgi?id=6065):

``` 
chmod go-rx /home/grid/*
```

- add swap: fixes numerous issues (OutOfMemory errors reported by Globus)

- comment out "-comm none " mpiexec param in pbs.pm
	
- FIXES: "-c" jobs failing with: Cannot find executable "-o"

# Configure pbs.pm

Copy over pbs.pm from Canterbury.  Primarily: add "-np" to mpiexec to fix a problem where MPI jobs are launched on only 1 CPU

- Extra features:
	
- job tagging (tag PBS jobs with Globus DN)
- pbsdebug (recognized in job description file, PBS job description is saved to this a file named after the value of the pbsdebug option if present)
- emaildebug - earlier feature to have the PBS job description emailed to whatever is specified in the emaildebug extension
- log job submission (job ID + Globus DN) to `/opt/vdt/globus/var/pbs-acct/jobdn-subm.log`

- Removing these Canterbury-specific features:
	
- Host-count hack
- /opt/shared/bin added to PATH
- path to PBS binaries: qstat+qsub are in `/usr/bin`


- Extra: Create jobdn-subm.log


>  mkdir -p /opt/vdt/globus/var/pbs-acct
>  touch /opt/vdt/globus/var/pbs-acct/jobdn-subm.log
>  chmod a+rw /opt/vdt/globus/var/pbs-acct/jobdn-subm.log
>  mkdir -p /opt/vdt/globus/var/pbs-acct
>  touch /opt/vdt/globus/var/pbs-acct/jobdn-subm.log
>  chmod a+rw /opt/vdt/globus/var/pbs-acct/jobdn-subm.log

- Extra: modify pbs.pm and set:

``` 
     my $modulestring = "[ -r /opt/Modules/etc/profile.modules ] && . /opt/Modules/etc/profile.modules\n";
```
- (different location of modules profile, /opt/Modules/etc/profile.modules)

# Configuring MIP / MDS

- MIP: create symlink to apac_py module called default (MIP wasn't producing anything...)


>  cd /usr/local/mip/modules
>  ln -s apac_py default
>  cd /usr/local/mip/modules
>  ln -s apac_py default

- Fix Python syntax in apac_config.py
- Fix paths in `/usr/local/mip/config/source.pl` from `/home/eshook/Projects/MIP/mip` to `/usr/local/mip`
- Fix package name (pkgs) to "default" in sources.pl
- Fix package ids (to prefixed with host name) in apac_config.py

- Activate MIP:

/usr/local/mip/config/globus/mip-globus-config install

- Create empty map-file for mds:

touch /etc/grid-security/mds-grid-mapfile

- Create /usr/local/bin/mds-primer.sh (as documented in [Setting up an NG2#Activating MDS in Globus](/wiki/spaces/BeSTGRID/pages/3818228585#SettingupanNG2-ActivatingMDSinGlobus)

- Comment out a check for queue_type ="Execution in computingelement.py: (batch is not an execution queue)

``` 

--- computingelement.py.orig	2010-12-08 17:03:21.000000000 +1300
+++ computingelement.py	2010-12-08 16:58:32.000000000 +1300
@@ -125,10 +125,12 @@
 			user_acl_done = enabled = started = False
 
 			for line in lines:
-				if line.startswith("queue_type ="):
-					if not line.split()[-1] == "Execution":
-						print "Not execution queue"
-						break
+				#if line.startswith("queue_type ="):
+					#if not line.split()[-1] == "Execution":
+
+						#COMMENT OUT - WE WANT TO RUN ON A NON-EXEC QUEUE
+						#print "Not execution queue"
+						#break
 				if line.startswith("acl_host_enable ="):
 					if not line.split()[-1] == "True":
 						do_host_acl = False

```

# Job usage

- Had to ask ARCS why - send_grid_usage emails were not making it to the GOC

- Changed /etc/cron.hourly/auditquery to use just `mail` and not `/bin/mail` to send mail - on Debian, `mail` lives as `/usr/bin/mail`

# Pending issues

- PBS job tags are not showing up in qstat output - though they do show in the jobscript:

``` 
#PBS -v GLOBUS_USER_DN='/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl'
```
