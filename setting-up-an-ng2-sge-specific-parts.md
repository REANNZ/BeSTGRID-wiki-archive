# Setting up an NG2 SGE specific parts

This page contains the Sun Grid Engine (SGE) specific supplementary material for the instructions on [setting up a job submission gateway](setting-up-an-ng2.md).

Scripts used within this page should have their most recent copy in the [ARCS Gitorious server sge-scripts project](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts)

# Prerequsites

- The job submission gateway and the SGE cluster should have a common user space (i.e. users have the same credentials, attributes, and home directories).
	
- [Sharing Rocks users with LDAP](/wiki/spaces/BeSTGRID/pages/3818228593)

- SGE must be configured to log enough information into the "reporting" and "accounting" files.
- **The default for SGE is*not** to do reporting.

# LRM access

This section gives instructions on how to make the SGE Cluster accessible from the job submission gateway.

## Install SGE

- For a Rocks cluster, the RPM used by Rocks can be downloaded from the head node, eg:



## Configure SGE: Copy configuration

- Create an *executable* shell script `/etc/profile.d/sge.sh` setting all the key variables (SGE_ROOT, SGE_ARCH, SGE_CELL, SGE_QMASTER_PORT, SGE_EXECD_PORT, add PATH $SGE_ROOT/bin/$SGE_ARCH, add LD_LIBRARY_PATH $SGE_ROOT/lib/$SGE_ARCH):

``` 

# Based on /etc/profile.d/sge-binaries.sh at oldesparky - part 
# of rocks-sge-5.2-2

SGE_ROOT=/opt/gridengine ; export SGE_ROOT
SGE_ARCH=`$SGE_ROOT/util/arch`; export SGE_ARCH
# not setting MANPATH and MANTYPE
SGE_CELL=default; export SGE_CELL
SGE_QMASTER_PORT=536; export SGE_QMASTER_PORT
SGE_EXECD_PORT=537; export SGE_EXECD_PORT

PATH=$SGE_ROOT/bin/$SGE_ARCH:$PATH; export PATH
MANPATH=$SGE_ROOT/man${MANPATH:+:}$MANPATH

LD_LIBRARY_PATH=$SGE_ROOT/lib/$SGE_ARCH:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH

```

- Create a mockup of the cell directory:

``` 
mkdir -p /opt/gridengine/default/common
```
- Copy `/opt/gridengine/default/common/{bootstrap,act_qmaster`} over from the real SGE headnode

- To prevent problems with installing the Globus-WS-SGE-Setup VDT package, make sure the *reporting* file exists before you proceed to that setup.  If you would be setting up log replication with sge-telltail only later, create a mock empty file with:

``` 
touch /opt/gridengine/default/common/reporting
```

- add the permissons on the SGE master

## Configure SGE: Shared Configuration

This method makes the SGE configuration available to the NG2 via a NFS share and sets up NG2 as a submission host. These steps assume the the `$SGE_CELL` is `default`.

- Share the SGE Cell directory by adding the following line to `/etc/exports` on the master host:

``` 

opt/gridengine/default       ng2.your.domain.com(rw,no_root_squash)

```
- Check that `/opt/gridengine/default/common/hosts_aliases` contains a matching the master host's internal and external addresses, for example :

``` 

master.host.external master.internal

```
- Add the NG2 server as a submission host with:

``` 

qconf -as ng2.your.domain

```
- Switching to the NG2 Create as stub directory to mount the SGE Cell directory with:

``` 

mkdir /opt/gridengine/default

```
- Add the SGE Cell directory share by adding this line to `/etc/fstab`:

``` 

master.host.address/opt/gridengine/default /opt/gridengine/default nfs defaults 0 0

```
- Mount the share with:

``` 

mount -a

```
- Add the SGE environment variables to `/etc/profile` with:

``` 

cp /opt/gridengine/default/common/settings.sh /etc/profile.d/sge.sh
. /etc/profile

```

**Note:** this method may not require log replication, and Globus GRAM4 can be pointed directly at /opt/gridengine/default/common/reporting

# Log replication (Telltail)

As detailed previoulsy, the gateway software expects to see information from the LRM's reporting

file.

The approach taken for an SGE LRM is the same as that for a PBS LRM: a script on the cluster headnode is used to 

send information to a script on the gateway, where the reporting file is then replicated.

The scripts `sge-telltail` and `sge-logmaker` are based on their PBS counterparts `pbs-telltail` and `pbs-logmaker`.  

For an SGE cluster, the default reporting file is referenced as $SGE_ROOT/$SGE_CELL/common/reporting.

For a default SGE installtion, that file name is therefore `/opt/gridengine/default/common/reporting`


## Telltail Script Installation: Gateway (NG2)

- Download the files from

>   [http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/trees/master/log-replication](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/trees/master/log-replication)

### Prerequisites

The `sge-logmaker` script has a requirement on `Perl`'s `DateManip` package.

This should be available through `YUM`'s base repository, so, if not already 

installed, can be installed with

>   yum install perl-DateManip

### Installation

The following instructions asssume you will use `/usr/local/sge-telltail`. If you choose

to use another location, eg, `/opt/sge-telltail`, you will need to edit the init scripts accordingly.

The downloaded files should be installed, and the new directory for storing accounting

information created, as follows:

- `sge-logmaker` as `/usr/local/sge-telltail/sge-logmaker`
- `sge-logmaker.RH` as `/etc/rc.d/init.d/sge-logmaker`

>  mkdir -p /usr/local/sge-telltail
>  cp sge-telltail/sge-logmaker /usr/local/sge-telltail/sge-logmaker 
>  cp sge-telltail/init.d/sge-logmaker.RH /etc/rc.d/init.d/sge-logmaker
>  mkdir $SGE_ROOT/$SGE_CELL/common/acct

- Edit `/etc/rc.d/init.d/sge-logmaker` and change the following if needed:
	
- Reporting file location (default: `/opt/gridengine/default/common/reporting`)
- TCP port number to receive messages (default: `2812`)

- Start the service:


>  service sge-logmaker start
>  service sge-logmaker start

- Make the service start automatically:


>  chkconfig --add sge-logmaker
>  chkconfig --add sge-logmaker

## Telltail Script Installation: SGE Cluster Headnode

- Download the files from

>   [http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/trees/master/log-replication](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/trees/master/log-replication)

### Prerequisites

A default installtion of SGE will not produce the reporting file that the Globus gateway

software needs to have access to, so this will need to be set up.

The value of the controling parameters can be seen when viewing the `sge_conf`.

The defaults are:

``` 

# qconf -sconf
...
reporting_params             accounting=true reporting=false \
                             flush_time=00:00:15 joblog=false sharelog=00:00:00
...

```

The `sge_conf` will need to be configured to set 

>  reporting=true
>  joblog=true

Activating reporting should be done with the consideration of information found

in the man page for `sge_conf` and the SGE Administration Guide.

### Installation

The following instructions asssume you will use `/usr/local/sge-telltail`. If you choose

to use another location, eg, `/opt/sge-telltail`, you will need to edit the init scripts accordingly.

The downloaded files should be installed as follows:

- `sge-telltail` as `/usr/local/sge-telltail/sge-telltail`
- `sge-telltail-as-nobody.RH` as `/etc/rc.d/init.d/sge-telltail`

>  mkdir -p /usr/local/sge-telltail
>  cp sge-telltail/sge-telltail /usr/local/sge-telltail/sge-telltail
>  cp sge-telltail/init.d/sge-telltail-as-nobody.RH /etc/rc.d/init.d/sge-telltail

- Edit `/etc/rc.d/init.d/sge-telltail` and change the following if needed:
	
- Reporting file location (default: SGE_REPORTING='/opt/gridengine/default/common/reporting')
- Remote host name and port number (default: REMOTES="ng2:2812")
- ***DO NOT** rely on ng2 resolving in your default domain: use the FQDN

- Start the service:


>  service sge-telltail start
>  service sge-telltail start

- Make the service start automatically:


>  chkconfig --add sge-telltail
>  chkconfig --add sge-telltail

# Globus integration

## Log file path

- This should be just the matter of editing `$GLOBUS_LOCATION/etc/globus-sge.conf`:


>  log_path=/opt/gridengine/default/common/reporting
>  log_path=/opt/gridengine/default/common/reporting

## Job manager LRM interface script

- Get the `sge.pm` module suitable for use on ARCS Grid/BeSTGRID from the [ARCS code server](https://code.arcs.org.au/gitorious/) and install it into `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/`:
	
- [View sge.pm](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/blobs/master/globus-jobmanager/arcs-sge/sge.pm)
- [Download sge.pm](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/blobs/raw/master/globus-jobmanager/arcs-sge/sge.pm)
- For clusters using OpenMPI and Sun Grid Engine (e.g. Rocks), use the orte parallel environment rather than mpi, that is change sge.pm so that:


>  $mpi_pe      = 'orte'; 
>  $mpi_pe      = 'orte'; 

 ***ALTERNATIVELY**: You can get a plain-vanilla out of the box sge.pem by also installing the Globus-SGE-Setup module (for GT2) - that creates sge.pm:

>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
>  pacman -get $VDTMIRROR:Globus-SGE-Setup
>  **You would get basic job submission working with this sge.pm - but*DO NOT USE THIS SCRIPT IN A PRODUCTION ENVIRONMENT ON BeSTGRID**

- 
- The script that comes with VDT would break job submission on BeSTGRID - e.g., it requires each executable to be specified as a full path.

## Fix RSH for SGE under Rocks

Rocks modifies the SGE configuration to override the built in RSH client and forces SGE to use SSH. This breaks for parallel jobs that span nodes. In order to correct this log in as a SGE manager on the SGE Master and use the command:

>  qconf -mconf

Delete the following lines (probably at the end of the config):

``` 

qrsh_command                 /usr/bin/ssh
rsh_command                  /usr/bin/ssh
rlogin_command               /usr/bin/ssh

```

Do not alter any lines that direct SGE to use `builtin` which probably occur earlier in the configuration.

## Environment variables for qsub

- The environment where Globus (and sge.pm) invoke SGE's qsub must be correctly set to include the information qsub is looking for - the port number for the qmaster process.  Without that, job submission via Globus is failing with: 

``` 
error: could not get environment variable SGE_QMASTER_PORT or service "sge_qmaster"
```
- Option 1: add the `sge_qmaster` to `/etc/services` as a service running at tcp port 536 and sge_execd at port 537(or the actual ports your SGE installation uses):

``` 

sge_qmaster     536/tcp
sge_execd       537/tcp

```
- Option 2:
	
- Make VDT include the SGE environment:

``` 
ln /etc/profile.d/sge.sh /opt/vdt/post-setup/
```
- ***Note**: because  `/opt/vdt/setup.sh` ignores symbolic links, you must either hard-link or copy the file into `/opt/vdt/post-setup/`.  Also note the script must be executable.

# Usage reporting

Usage reporting is done by sending daily emails with job accounting data in PBS format.  The solution described here is built around:

1. extracting daily SGE accounting data from the `reporting` file (in SGE format)
2. translating the daily data into PBS format
3. emailing this off to the Grid Operations Center (GOC)

The first part is done automatically by the sge-telltail/sge-logmaker scripts - the accounting data is automatically stored in daily files.  If the reporting file is mounted from the headnode over NFS, this can be done by the `sge-reporting2acct.pl` script.  

The translation into PBS format is done by the `sge2pbs.pl`.

The whole process is driven by the `send_grid_usage` script (started from cron).

All of the scripts can be accessed in the ARCS Gitorious server at [http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/trees/master/usage-reporting](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/trees/master/usage-reporting)

An important aspect of this process is filtering the job records, so that only jobs that originated from the grid are reported back to the GOC.  This is done based on the job name - which would start either with `sge_job_script` (the name of the job script file) or the `Grid_``ng2-hostname``_``jobname` (if sge.pm set the job name with `-N`).  The filtering is done in `sge-logmaker` (if replicating the logs) or in `sge-reporting2acct.pl` (if mounting the cell directory from the headnode).  If you need other behavior, you may wish to customize these scripts.

- Create a directory to hold the accounting information extracted from the reporting file:

``` 
mkdir /opt/gridengine/default/common/acct
```
- And a directory to hold the logs after translating them to PBS syntax:

``` 
mkdir /opt/gridengine/default/common/acct/pbs
```
- Install the [send_grid_usage](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/blobs/raw/master/usage-reporting/send_grid_usage) script on the cluster NG2 (by convention as /usr/local/sbin/send_grid_usage) to be run daily (1am is a good time...) ... so you may also do this by creating this cron-job file as: `/etc/cron.d/send_grid_usage.cron`:

``` 
3 1 * * * root /usr/local/sbin/send_grid_usage
```
- Set `CLUSTER_NAME` to the name of your cluster as specified in `default.pl`.
- Set `SITE_NAME` to the name assigned to your site on the GOC.
- This script also depends on `/usr/local/sbin/sge2pbs.pl` and `/usr/local/sbin/sge-reporting2acct.pl`: download the scripts from the links below and install them into `/usr/local/sbin`:
- `sge2pbs.pl`: [Download](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/blobs/raw/master/usage-reporting/sge2pbs.pl) [View](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/blobs/master/usage-reporting/sge2pbs.pl)
- `sge-reporting2acct.pl`: [Download](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/blobs/raw/master/usage-reporting/sge-reporting2acct.pl) [View](http://code.arcs.org.au/gitorious/grid-usage/sge-scripts/blobs/master/usage-reporting/sge-reporting2acct.pl)

>  ***Important**: SGE tracks jobs solely by their number, while the GOC requires the job ID to be a number followed by a cluster domain (such as `1234.ng2.your.site`).  The sge2pbs.pl will add your hostname automatically to the Job ID.  Modify the `/etc/cron.hourly/auditquery` script to modify the JobID in the same way:

``` 

--- auditquery.orig2	2010-02-25 12:02:45.000000000 +1300
+++ auditquery	2010-05-17 16:34:30.000000000 +1200
@@ -17,13 +17,13 @@
 # Read and log records, create delete statements and send email
 mysql <<EOF 2>/dev/null | sed -n '2,$p' |
 use auditDatabase;
-select concat_ws(' ',local_job_id, subject_name)
+select concat(local_job_id,'.`hostname` ', subject_name)
 from gram_audit_table where local_job_id is not NULL and finished_flag = TRUE;
 EOF
 while read Line; do
   logger -t Job-DN "$Line"
   echo     "Job-DN: $Line"
-  JobId="`echo $Line | awk '{print $1}'`"
+  JobId="$( basename $( echo $Line | awk '{print $1}') .$(hostname) )"
   echo "delete from  gram_audit_table" >>$File
   echo "where local_job_id = '$JobId';">>$File
 done | /bin/mail -s "`hostname` JobID `date +%Y%m%d`" grid_pulse@lists.arcs.org.au >/dev/null 2>&1

```

# MIP configuration

Support for SGE has been implemented only recently and is not yet included in the APAC-mi-module-py RPM.

- Download a new version of [computingelement.py](http://projects.arcs.org.au/svn/systems/trunk/rpms/SOURCES/infosystems/apac_py/ComputingElement/computingelement.py) from the [ARCS Systems SVN](http://projects.arcs.org.au/svn/systems/trunk) and store it in `/usr/local/mip/modules/apac_py/ComputingElement` (overwriting the existing file):

``` 
wget -O /usr/local/mip/modules/apac_py/ComputingElement/computingelement.py http://projects.arcs.org.au/svn/systems/trunk/rpms/SOURCES/infosystems/apac_py/ComputingElement/computingelement.py
```

- Modify `/usr/local/mip/config/apac_config.py` and:
	
- set `SGE` as the JobManager
- set `SGE` as the LRMSType
- configure the full path to the `qstat` and `qconf` binaries (either as absolute path or based on expanding the `SGE_ROOT` and `SGE_ARCH` environment variables)

``` 

computeElement.JobManager = 'SGE'
computeElement.LRMSType = 'SGE'
computeElement.qstat = os.environ['SGE_ROOT'] + "/bin/" + os.environ['SGE_ARCH'] + "/qstat"
computeElement.qconf = os.environ['SGE_ROOT'] + "/bin/" + os.environ['SGE_ARCH'] + "/qconf"

```

Please let [Vladimir Mencl](vladimirbestgridorg.md) know about any issues you discover.

- Please note that when Globus invokes MIP (as the `daemon` user), MIP must have the right permissions and environment variable settings to access SGE.  To make Globus load the SGE profile script as part of VDT environment (same as above in [Globus integration - Environment variables for qsub](#SettingupanNG2SGEspecificparts-Environmentvariablesforqsub)), copy the profile script into `$VDT_LOCATION/post-setup`:

``` 
cp  /etc/profile.d/sge.sh /opt/vdt/post-setup/
```
- ***Note**: `/opt/vdt/setup.sh` ignores symbolic links, it is recommended that `sge.sh` is copied.  Also note the script must be executable.

# Example outputs

## SGE Reporting File

Once you have turned on **reporting=true** and **joblog=true** your reporting file 

will contain, for each job, a block of status information similar to the following block.

All lines start with a time stamp  and some lines have been wrapped because they are very long.

The three machines involved are 

**ng2.dom.ain**, **headnode.dom.ain** and **compute1.dom.ain**

whilst the user the job runs as is **arcsvo01**

Your names will be different.

``` 

1278638133:new_job:1278638133:38:-1:NONE:sge_job_script.25201:arcsvo01:arcsvo01::defaultdepartment:sge:1024
1278638133:job_log:1278638133:pending:38:-1:NONE::arcsvo01:ng2.dom.ain:0:1024:1278638133:sge_job_script.25201:
 arcsvo01:arcsvo01::defaultdepartment:sge:new job
1278638141:job_log:1278638141:sent:38:0:NONE:t:master:headnode.dom.ain:0:1024:1278638133:sge_job_script.25201:
 arcsvo01:arcsvo01::defaultdepartment:sge:sent to execd
1278638141:job_log:1278638141:delivered:38:0:NONE:r:master:headnode.dom.ain:0:1024:1278638133:sge_job_script.25201:
 arcsvo01:arcsvo01::defaultdepartment:sge:job received by execd
1278638142:acct:all.q:compute1.dom.ain:arcsvo01:arcsvo01:sge_job_script.25201:38:sge:0:1278638133:1278638141:
 1278638141:0:0:0:0.099984:0.163975:0.000000:0:0:0:0:17692:0:0:0.000000:0:0:0:0:142:93:NONE:defaultdepartment:NONE:
 1:0:0.263959:0.000000:0.000000:NONE:0.000000:NONE:0.000000:0:0
1278638142:job_log:1278638142:finished:38:0:NONE:r:execution daemon:comute1.dom.ain:0:1024:1278638133:sge_job_script.25201:
 arcsvo01:arcsvo01::defaultdepartment:sge:job exited
1278638142:job_log:1278638142:finished:38:0:NONE:r:master:headnode.dom.ain:0:1024:1278638133:sge_job_script.25201:
 arcsvo01:arcsvo01::defaultdepartment:sge:job waits for schedds deletion
1278638156:job_log:1278638156:deleted:38:0:NONE:T:scheduler:headnode.dom.ain:0:1024:1278638133:sge_job_script.25201:
arcsvo01:arcsvo01::defaultdepartment:sge:job deleted by schedd

```

# Contributors

This page was initially created by Vladimir Mencl and populated with skeletons of the target instructions.  Others are welcome to contribute.
