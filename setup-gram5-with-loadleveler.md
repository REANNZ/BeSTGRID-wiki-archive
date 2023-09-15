# Setup GRAM5 with LoadLeveler

This page provides the LoadLeveler specific details for setting up a GRAM5 grid gateway.

Start by first installing a plain GRAM5, following the instructions on the [Setup GRAM5 on CentOS 5](setup-gram5-on-centos-5.md) page (skipping all PBS-specific steps), then proceed from here.

This procedure for setting up a LoadLeveler grid gateway is based on the `llgrid.tar` module that comes with LoadLeveler, and adapts it for GT5 with a patch coming from the EU IGE project.  Hence, you will need the LoadLeveler distribution available to proceed.

The steps in setting up gateway are:

1. Configuring the grid gateway as a submit-only node in LoadLeveler cluster
2. Installing GRAM5
3. Downloading the IGE patch
4. Patching, compiling and installing the llgrid module
5. Finishing up the GRAM5 configuration

# Linking into LoadLeveler cluster

Configure the grid gateway as a submit-only node in the LoadLeveler cluster.  This in particular includes:

- Configuring the grid gateway to accept the same set of user accounts (but not necessarily passwords) as the cluster
- Configuring the grid gateway to mount the user home directories (in the same location as they are seen on the cluster)
- Installing LoadLeveler binaries on the grid gateway
- Adding the gateway as a submit-only node on your cluster.  The following stanza in the `LoadL_admin` file does the job (to match your grid gateway name):

``` 
ng2hpc-c:    type = machine   central_manager = false  schedd_host = false submit_only = true
```
- You will also need a shared file visible by all LoadLeveler nodes and the grid gateway.  A convenient location for that file is on the GPFS filesystem, e.g. `/hpc/home/globus/loadl/globus-loadleveler.log`

# Installing GRAM5

Install GRAM5 as per [Setup GRAM5 on CentOS 5](setup-gram5-on-centos-5.md) page, skipping all PBS-specific steps.

# Patching and Compiling llgrid module

- Get the llgrid module from the LoadLeveler install tree - should be available as `/opt/ibmll/LoadL/full/lib/llgrid.tar`
- Download the patch from [http://www.ige-project.eu/patches/ll-adaptor-patch-for-gt5](http://www.ige-project.eu/patches/ll-adaptor-patch-for-gt5)
	
- Even though the "Get the patch here" link asks you to sign into the "ige-project.eu" Google Docs space, any Google account is accepted (use the *Sign in with a different account* link)
- The commands below assume you've downloaded it into `~globus/inst/LoadL-grid/llgrid.tar.patch.gt5.0.4 -p 0`

- Extract, patch and compile the module:

``` 

 cd ~globus/inst
 tar xf /opt/ibmll/LoadL/full/lib/llgrid.tar
 mv gt4 llgrid-gt5
 cd llgrid-gt5
 patch < /home/globus/inst/LoadL-grid/llgrid.tar.patch.gt5.0.4 -p 0
 > patching file deploy.sh
 > patching file seg-src/configure

```

- Edit `globus-loadleveler.conf` - point to point to your shared LoadLeveler job status file (e.g., `/hpc/home/globus/loadl/globus-loadleveler.log`)
	
- Note: this file must be world-writable

# Deploy and Configure the module

Deploy the module - install into Globus directory

- Run (they say as root, but it's OK as globus):

``` 
./deploy.sh globus
```
- This create the following under `$GLOBUS_LOCATION`


>  etc/globus-loadleveler.conf
>  etc/grid-services/jobmanager-loadleveler
>  lib/perl/Globus/GRAM/JobManager/loadleveler.pm
>  lib/seg_loadleveler_module.o
>  lib/libglobus_seg_loadleveler_gcc32dbg*
>  etc/globus-loadleveler.conf
>  etc/grid-services/jobmanager-loadleveler
>  lib/perl/Globus/GRAM/JobManager/loadleveler.pm
>  lib/seg_loadleveler_module.o
>  lib/libglobus_seg_loadleveler_gcc32dbg*

- Now, this installs only the 32-bit version of the SEG module - which is not what we want.


>  ***!!! Recompile SEG** (note: we want the **NON-THREADED** version for our environment)
>  cd llgrid-gt5/seg-src
>  ./configure --with-flavor=gcc64dbg
>  make
>  make install
>  ***!!! Recompile SEG** (note: we want the **NON-THREADED** version for our environment)
>  cd llgrid-gt5/seg-src
>  ./configure --with-flavor=gcc64dbg
>  make
>  make install

- Now enable the SEG module for the `loadleveler` job manager:
	
- Edit $GLOBUS_LOCATION/etc/grid-services/jobmanager-loadleveler and add the following to the list of arguments:

``` 
-seg-module loadleveler
```
- Try running the SEG with 

``` 
$GLOBUS_LOCATION/sbin/globus-job-manager-event-generator -scheduler loadleveler -background -pidfile /opt/globus/var/job-manager-seg-loadleveler.pid
```
- Create a `/etc/rc.d/init.d/globusseg` to run the SEG service automatically.

``` 

#!/bin/bash
# Startup script for globus scheduler event generator
#
# chkconfig: 345 99 06
#
# description: Start globus-job-manager-event-generator launching
#              globus-scheduler-event-generator

. /etc/profile.d/globus.sh
# or do 
# export GLOBUS_LOCATION=/opt/globus ; . $GLOBUS_LOCATION/etc/globus-user-env.sh

servicename=globusseg
pidfile=/opt/globus/var/job-manager-seg-loadleveler.pid
RETVAL=0

start () {
  $GLOBUS_LOCATION/sbin/globus-job-manager-event-generator -scheduler loadleveler -background -pidfile $pidfile
  RETVAL=$?
  [ $RETVAL -eq 0 ] && touch /var/lock/subsys/$servicename
}

stop () {
  RETVAL=1
  if [ -f $pidfile ] ; then
    PID=`cat $pidfile`
    if ps -p $PID > /dev/null ; then
      kill $PID
      RETVAL=$?
      rm /var/lock/subsys/$servicename
    fi
  fi
}

status () {
  if [ -f $pidfile ] ; then
    PID=`cat $pidfile`
    if ps -p $PID > /dev/null ; then
      echo "PID $PID running"
      RETVAL=0
    else
      echo "PID file exists but process not running"
      RETVAL=1
    fi
  else
    echo "Not running"
    RETVAL=1
  fi
}

case "$1" in
        start)
            start
            ;;
        stop)
            stop
            ;;
        status)
            status
            ;;
        restart)
            stop
            sleep 3
            start
            ;;
        *)
            echo $"Usage: $0 {start|stop|status|restart|condrestart}"
            ;;
esac
exit $RETVAL

```
- Enable the script with chkconfig:

``` 
chkconfig --add globusseg
```

# File List

The following files get installed under `$GLOBUS_LOCATION`

- `etc/globus-loadleveler.conf`: Configuration for LoadLeveler SEG, defines the path to the shared log.  Typical contents:

``` 
log_path=/hpc/home/globus/loadl/globus-loadleveler.log
```
- `etc/grid-services/jobmanager-loadleveler`: Job manager configuration for LoadLeveler, the typical contents (after turning SEG on) is:

``` 
stderr_log,local_cred - /opt/globus/libexec/globus-job-manager globus-job-manager -conf /opt/globus/etc/globus-job-manager.conf -type loadleveler -rdn jobmanager-loadleveler -machine-type unknown -publish-jobs -seg-module loadleveler
```
- `lib/perl/Globus/GRAM/JobManager/loadleveler.pm`: LRM interface script for LoadLeveler.  Needs to be customized for site specific details.
- ``` 
lib/libglobus_seg_loadleveler_<flavour>.*
```

: SEG libraries - need to be recompiled for 64-bit (non-gcc32) systems.

# Customizing LoadLeveler.pm

- Customize your loadleveler.pm - as per [Canterbury ng2hpc LoadLeveler Tweaks](/wiki/spaces/BeSTGRID/pages/3818228664#SetupNG2HPCatUniversityofCanterbury-Tweakingloadleveler.pm) or contact the [author of this documentation](vladimirbestgridorg.md)

- Note: if you are using LoadLeveler submit filters that depend on LoadLeveler binaries being in the PATH, you will need to modify `loadleveler.pm` by adding the following (Globus drops PATH when executing the perl job manager (loadleveler.pm) so this may be the simplest way):


>  $ENV{"PATH"} = "/bin:/sbin:/usr/bin:/usr/sbin";
>  $ENV{"PATH"}=$ENV{"PATH"}.":$llpath"; # Linux: $llpath = '/opt/ibmll/LoadL/full/bin';
>  $ENV{"PATH"} = "/bin:/sbin:/usr/bin:/usr/sbin";
>  $ENV{"PATH"}=$ENV{"PATH"}.":$llpath"; # Linux: $llpath = '/opt/ibmll/LoadL/full/bin';

# TODO

- Report to Globus team: job manager LRM-interface script (loadleveler.pm) not getting PATH in environment from GT 5.0.4 job manager
