# Setup NG2HPC at University of Canterbury

The NG2HPC is a copy of the NG2 machine created to integrate the [IBM p575 HPC](http://www.ucsc.canterbury.ac.nz/) with the grid.

The steps in the setup are:

1. Integrate the machine with the cluster's filesystem
2. Integrate the virtual machine with load leveler
3. Install globus
4. Install globus load leveler setup.
5. Install and configure MIP to register the cluster in the MDS.

# Filesystem integration

In order for globus to state-in files needed by jobs, `ng2hpc` needs access to the cluster's filesystem.  The HPC uses GPFS - we were considering either mounting the filesystem directly via GPFS, or exporting the filesystem from a node (the **p520**) via NFS and mounting it on the gateway.

## GPFS

We have obtained the *GPFS Multiplatform CD* with GPFS binaries and drivers for Linux.  RHEL4 is a supported platform, and the driver compiles fine under a Centos 4.4 kernel (2.6.9-42.0.10ELsmp).  The drivers however did not compile under the modified Xen kernel.  It is however possible to setup a Xen [Vladimir__HVM virtual machine](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__HVM%20virtual%20machine&linkCreation=true&fromPageId=3818228664) running unmodified CentOS kernel and install the drivers there.  

We did not use this option, but the steps are:

1. Pre-install: needs compatibility libraries and `imake`:

``` 
yum install compat-libstdc++-33 xorg-x11-devel
```
2. Run `gpfs_install-3.1.0-0_i386` from the CD; this creates rpm files in `/usr/lpp/mmfs/3.1/`
3. Install the RPM packages:

``` 
rpm -Uvh /usr/lpp/mmfs/3.1/*.rpm
```
4. Follow the instructions in `/usr/lpp/mmfs/src/README`
	
1. export SHARKCLONEROOT=/usr/lpp/mmfs/src
2. cd /usr/lpp/mmfs/src/config
3. cp site.mcr.proto site.mcr
4. edit site.mcr
		
- `LINUX_DISTRIBUTION = REDHAT_LINUX`
- `#define LINUX_DISTRIBUTION_LEVEL 44`
- `#define LINUX_KERNEL_VERSION 2060942`
- If you forget to change the definitions at this time, you must later edit both `src/site.mcr` and `src/shark/config/site.mcr`.
5. And compile and install

``` 

make World
su -c make InstallImages
cd /usr/lpp/mmfs/bin
insmod tracedev
insmod mmfslinux
insmod mmfs26 

```

## NFS

Export filesystems (`/hpc/{home,work,projects,griddata,gridusers`} from the cluster via NFS, and mount them to `ng2hpc`.

`/etc/fstab`:

>  hpcgrid1-c:/hpc/gridusers      /hpc/gridusers   nfs     fg,retry=20,hard,acregmin=1,acdirmin=1    0 0

In order to force tighter synchronization and avoid situation when a file is created on the server side and not yet visible locally, minimum attribute caching interval has been reduced to 1s.

- To make `updatedb` run on just local filesystems, exclude `nfs` from `updatedb` runs: edit `/etc/updatedb.conf` and add `nfs` to the `PRUNEFS` list:


>  PRUNEFS = "auto afs gfs gfs2 iso9660 sfs udf **nfs**"
>  PRUNEFS = "auto afs gfs gfs2 iso9660 sfs udf **nfs**"

Note that for client NFS to work, portmapper must be running - and in order for NFS filesystems from `/etc/fstab` to be mounted at boot time, service netfs must be on: 

``` 

chkconfig portmap on
chkconfig netfs on  

service portmap start
service netfs start

```

# Load Leveler

This has been done and the machine is capable of submitting LoadLeveler jobs.  Note that this had to be redone.  The GT40-LoadLeveler integration library requires the full version of loadleveler - it has hardcoded path names into `/opt/ibmll/LoadL/so/bin/`, while the submit-only version installs into `/opt/ibmll/LoadL/so/bin`.  Also note that LoadLeveler and GT40 must be installed 'before' the integration library can be installed.

## Install LoadLeveler binaries

We have installed the LoadLeveler "full" binaries from the *LoadLeveler 3.4 Multiplatform* CD.

>  yum install openmotif
> 1. needed by LoadL-full

>  rpm -e --noscripts LoadL-so-license-RH4-X86-3.4.0.0-0 LoadL-so-RH4-X86-3.4.0.0-0
> 1. 
> 1. 
> 1. -noscripts is essential - the LoadL*license RPMs would remove /opt/ibmll when uninstalled
>  rpm -Uvh /root/inst/LoadLMulti/LoadL-full-license-RH4-X86-3.4.0.0-0.i386.rpm
>  rpm -Uvh /root/inst/LoadLMulti/LoadL-full-RH4-X86-3.4.0.0-0.i386.rpm

either:

>  /opt/ibmll/LoadL/sbin/install_ll -d /root/inst

or create `/opt/ibmll/LoadL/lap/license/status.dat`

>  #Wed May 16 16:50:45 NZST 2007
>  Status=9

Finally, 

>  rpm -Uvh LoadL-so-RH4-X86-3.4.0.0-0.i386.rpm

The binaries are now in `/opt/ibmll/LoadL/full/bin/`.

The next step is to configure LoadLeveler.  LoadLeveler expects that user `loadl` exists, and reads the configuration from `~loadl`.

>  adduser -u 1005 loadl

Now, the optimal step would be to mount all home directories from `/hpc/home`, including `~loadl`.  Until the directories are exported, the temporary solution is to copy configuration from the HPC:

>  su loadl
>  cd ~loadl
>  ssh vme28@hpclogin2 tar cvzf - -C /hpc/home/loadl LoadL_{admin,config} local > loadl-config-snapshot-2007-05-18.tar.gz
>  tar xzf loadl-config-snapshot-2007-05-18.tar.gz
>  chmod 755 . 

**Update**: The home directories are already exported via NFS, and I am now using the shared LoadLeveler configuration from `/hpc/home/loadl` (`vipw`, change home directory of user `loadl` from `/home/loadl` to `/hpc/home/loadl`).

Your admin needs to setup a *public scheduler* and add your machine as a submit-only node, and needs to create a configuration file for your machine.  This file should exist for both the name how the cluster knows the machine (ng2hpc-c) and the hostname of the machine (ng2hpc).  Thus, create in `~loadl/local/` files `LoadL_config.ng2hpc` and `LoadL_config.ng2hpc-c` with

>  SCHEDD_RUNS_HERE = FALSE
>  STARTD_RUNS_HERE = FALSE
>  START_DAEMONS = FALSE

Add `/opt/ibmll/LoadL/full/bin/` to your `PATH` and `llsubmit`, `llq`, ... should work now.  Note that in case different LoadLeveler versions are mixed, the *Central Manager* must run the most recent version of all involved.  Otherwise, commands such as `llstatus` may report communication errors.

To make LoadLeveler binaries automatically accessible to everyone create (executable) `/etc/profile.d/loadl.sh`:

``` 

PATH=$PATH:/opt/ibmll/LoadL/full/bin/
export PATH

```

# Globus

The Globus installation has roughly followed the [NG2 setup](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20NG2&linkCreation=true&fromPageId=3818228664) - and thus, roughly followed the [APAC NG2 setup](http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsNg2). The key difference has been that as LoadLeveler is used instead of PBS, no PBS-specific packages were installed, and the PBS-specific installation steps from the build script were skipped.

The main steps have been:

- `yum install Gbuild Gpulse`
- skipping Gtorque-client (and other PBS-specific instructions)
- install host certificate into `/etc/grid-security/host{cert,key}.pem` (key protected)
- cleanup services that can't run (and cause `gridpulse.sh` to report the host as `Not OK`)


>  chkconfig lvm2-monitor off
>  chkconfig cpuspeed off
>  chkconfig lvm2-monitor off
>  chkconfig cpuspeed off

- `yum update` (to update to CentOS 4.5, and to avoid inconsistencies in package update status (new packages would be installed from the CentOS 4.5 distribution).
- modify `BuildNg2Vdt161.sh` to skip PRIMA setup and to skip any PBS-specific checks and configuration steps (saved as `BuildNg2Vdt161NoPrima.sh`)
	
- do not install `pbs-telltail`
- do not check for `qstat`
- do not install `Globus-WS-PBS-Setup` (I did let it install, and it was a pain to remove all traces of it from the gateway)
- do not configure PRIMA (let us us EDG-GridMap instead)
- do not set up the pbs-logmaker service

``` 

--- BuildNg2Vdt161.sh   2007-05-16 18:59:49.000000000 +1200
+++ BuildNg2Vdt161NoPrima.sh    2007-07-20 15:19:16.000000000 +1200
@@ -26,8 +26,11 @@
             vim-enhanced iptables ntp yp-tools mailx nss_ldap libXp   \
             tcsh openssh-server sudo lsof slocate bind-utils telnet   \
             gcc vixie-cron anacron crontabs diffutils xinetd tmpwatch \
-            sysklogd logrotate man pbs-telltail compat-libstdc++-33   \
+            sysklogd logrotate man compat-libstdc++-33   \
             compat-libcom_err perl-DBD-MySQL openssl097a gcc-c++ $Extras
+###### disabled by VLADIMIR MENCL: #pbs-telltail
+## DISABLED by VLADIMIR MENCL 2007-07-11
+if [ -n "$REALLYBUGMEWITHQSTAT" ] ; then
 until qstat >/dev/null 2>/dev/null ; do
   echo    "==> qstat not found or not configured!"
   echo -n "==> Enter path (e.g. /usr/local/pbs/bin), else enter 'q' .. "
@@ -35,6 +38,7 @@
   [ "$_Ans" = q ] && echo "==> You might want to do: yum install Gtorque-client" && exit 1
 done
 [ -d /usr/spool/PBS/server_logs ] && export PBS_HOME=/usr/spool/PBS
+fi

 #
 # Pacman, port-range adjustment, java-version adjustment, VDT
@@ -64,7 +68,8 @@

 #
 # VDT Components
-for Component in JDK-1.5 Globus-WS PRIMA-GT4 Fetch-CRL Globus-WS-PBS-Setup ; do
+###### disabled by VLADIMIR MENCL: Globus-WS-PBS-Setup
+for Component in JDK-1.5 Globus-WS PRIMA-GT4 Fetch-CRL ; do
   echo "==> Checking/Installing: $Component"
   pacman -pretend-platform linux-rhel-4 $ProxyString \
     -get http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:$Component || echo "==> Failed!"
@@ -87,7 +92,9 @@
 wait_timeout=2764800
 ' /opt/vdt/mysql/var/my.cnf
 . /etc/profile; vdt-control --force --on && echo "==> Installed: startup scripts"
-if [ ! -f /etc/grid-security/prima-authz.conf ] ; then
+
+## DISABLED by VLADIMIR MENCL 2007-07-11
+if [ -n "$REALLYINSTALLPRIMA" -a ! -f /etc/grid-security/prima-authz.conf ] ; then
   until [ -n "$Gums_Server" ] ; do
     echo -n "==> Please enter the name of your GUMS server [e.g. nggums.vpac.org ] .. "
     read Gums_Server
@@ -126,7 +133,7 @@
 #
 # Wrapup
 [ -x  /usr/local/sbin/SecureMdsVdt161.sh ] && /usr/local/sbin/SecureMdsVdt161.sh Supress
-chkconfig --add pbs-logmaker; service pbs-logmaker start
+###### disabled by VLADIMIR MENCL: chkconfig --add pbs-logmaker; service pbs-logmaker start
 echo "==> Re-starting: xinetd"
 chkconfig --add xinetd; service xinetd start; service xinetd reload
 echo "==> Running: /opt/vdt/fetch-crl/share/doc/fetch-crl-2.6.2/fetch-crl.cron"

```
- run `BuildNg2Vdt161NoPrima.sh`
- `visudo`, copy and paste from `/opt/vdt/post-install/README` (the Build script configures the sudo permissions for the syntax used with PRIMA, with a grid-mapfile, the command syntax is different)
- `/opt/vdt/post-install/README` did not give any additional instructions
- container did not start because we have no gridmap-file

- Install EDG-Make-Gridmap


>   pacman -pretend-platform linux-rhel-4 -get [http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:EDG-Make-Gridmap](http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:EDG-Make-Gridmap)
>   vdt-control --on edg-mkgridmap # this enables cron job
>   pacman -pretend-platform linux-rhel-4 -get [http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:EDG-Make-Gridmap](http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:EDG-Make-Gridmap)
>   vdt-control --on edg-mkgridmap # this enables cron job

- Configure grid-mapfile - see the [Vladimir__Setup_NG2#Main_NG2_Setup NG2 setup instructions](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup_NG2&linkCreation=true&fromPageId=3818228664) (creating `/opt/vdt/edg/etc/edg-mkgridmap.conf` and creating grid user accounts)

- Install UberFTP - to use as a client tool.


>  pacman -pretend-platform linux-rhel-4 -get [http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:UberFTP](http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:UberFTP)
>  pacman -pretend-platform linux-rhel-4 -get [http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:UberFTP](http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:UberFTP)

**Note**: in March 2008, I have [installed a GUMS server](/wiki/spaces/BeSTGRID/pages/3818228678) and switched the gateways to use PRIMA.  Due to the [whitespace issue](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setup_NGGums_at_University_of_Canterbury&linkCreation=true&fromPageId=3818228664), I had to install an updated PRIMA library properly encoding and decoding the whitespace.  I have used the one I compiled when helping to solve the problem, and which was installed on the VDT161 instance on Ng2SGE.

After doing that, it was sufficient to turn PRIMA on with:

>  /opt/vdt/vdt/setup/configure_prima_gt4 --enable --gums-server nggums.canterbury.ac.nz

# LoadLeveler integration

This has been done according to the [IBM instructions](http://www-128.ibm.com/developerworks/grid/library/gr-twsllglobus/index.html).  Before this integration is done LoadLeveler (full version) and and Globus Toolkit 4.0 must be installed and configured.

## Installing LoadLeveler GT40 integration library

- Extract the integration library (it is in the `llgrid.tar` file packaged with the LoadL-full RPM)


>  mkdir /root/inst/llgrid
>  cd /root/inst/llgrid
>  tar xvf /opt/ibmll/LoadL/full/lib/llgrid.tar
>  mkdir /root/inst/llgrid
>  cd /root/inst/llgrid
>  tar xvf /opt/ibmll/LoadL/full/lib/llgrid.tar

- Change the configuration file


>  vi /root/inst/llgrid/gt4/globus-loadleveler.conf
>  vi /root/inst/llgrid/gt4/globus-loadleveler.conf

- **change **`log_path`** to a directory that*is accessible both by globus and by the LoadLeveler scheduler** — that likely means an NFS-mounted directory.


>  log_path=/hpc/gridusers/globus/loadl/globus-loadleveler.log
>  log_path=/hpc/gridusers/globus/loadl/globus-loadleveler.log

Now the instructions ask to run

>  cd /root/inst/llgrid/gt4
>  ./deploy.sh

The deploy script configures LoadLeveler as an additional scheduler in your Globus installation.  Namely, it:

- installs the perl script `GLOBUS_LOCATION/lib/perl/Globus/GRAM/JobManager/loadleveler.pm` to handle job submission and status inquiry.
- installs information service provider `$GLOBUS_LOCATION/libexec/globus-scheduler-provider-loadleveler` to provide basic MDS information (though this is not the GLUE MDS information).
- `$GLOBUS_LOCATION/etc/grid-services/jobmanager-loadleveler` - don't know what's this one good for (?? GT2)
- $GLOBUS_LOCATION/etc/globus-loadleveler.conf - configuration file for the SEG (Scheduler Event Generator) specifying where the log file is
- $GLOBUS_LOCATION/etc/gram-service/globus_gram_fs_map_config.xml - configure directory mappings for the `Loadleveler` *Factory Type*.
- copy the SEG binaries into `$GLOBUS_LOCATION/lib/`

``` 
cp -f seg-binary-linux/* $GLOBUS_LOCATION/lib/
```
- create the log file

However, a number of additonal steps have to be done.

>  ***Important!** `jndi-config.xml` **must** specify substitution definitions file and a refresh period.  jndi-config.xml files for other GRAM services have these definitions, but `etc/gram-service-Loadleveler/jndi-config.xml` does not.  Add

``` 

                <parameter>
                    <name>
                        substitutionDefinitionsFile
                    </name>
                    <value>
                        /opt/vdt/globus/etc/gram-service-Loadleveler/substitution-definition.properties
                    </value>
                </parameter>
                <parameter>
                    <name>
                        substitutionDefinitionsRefreshPeriod
                    </name>
                    <value>
                        <!-- MINUTES -->
                        480
                    </value>
                </parameter>

```

 to the end of `resourceParams` and copy `/opt/vdt/globus/etc/gram-service-Fork/substitution-definition.properties` to `/opt/vdt/globus/etc/gram-service-Loadleveler/substitution-definition.properties`.


>   07/12 17:38:56 TI-9260 Cannot open globus LoadLeveler log file for l4n02-c.85.0.
>   07/12 17:38:56 TI-9260 Cannot open globus LoadLeveler log file for l4n02-c.85.0.

## Troubleshooting

Check loadleveler log files (on the scheduler node, `l4n02-c:/var/loadl/log/SchedLog` ???, for example the messages 

[http://www-unix.globus.org/toolkit/docs/4.0/execution/wsgram/user-index.html#s-wsgram-user-troubleshooting](http://www-unix.globus.org/toolkit/docs/4.0/execution/wsgram/user-index.html#s-wsgram-user-troubleshooting)

Remaining problem:

- (unresolved, did not reoccur) - GridFTP could not retrieve output file when job completed too fast
	
- may have been solved by reducing NFS attribute caching time interval.
- unresolved: if job does not produce any error output, LoadLeveler deletes the stdErr file and Globus reports a GriFTP file not found error.

## Additional configuration

GBLL_{TASKS_PER_NODE,COMMENT,RESTART,...} env vars - environment for Loadleveler.pm

see Grid Toolbox Adminstration Guide, [http://dl.alphaworks.ibm.com/technologies/gridtoolbox/GridAdmin.pdf](http://dl.alphaworks.ibm.com/technologies/gridtoolbox/GridAdmin.pdf)

If compiling SEG libraries

INSTALL Globus-SDK

>  pacman -pretend-platform linux-rhel-4 -get [http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:Globus-Base-SDK](http://www.grid.apac.edu.au/repository/mirror/vdt-1.6.1.mirror:Globus-Base-SDK)
>   ./configure --prefix=$GLOBUS_LOCATION --with-flavor=gcc32dbg
>  make 
>  make install

### Cleaning up PBS

If Globus-PBS-Setup / Globus-WS-PBS-Setup is accidentally installed, removing pacman packages is not enough.  

>  pacman -remove Globus-PBS-Setup Globus-WS-PBS-Setup

In addition, you have to remove all files installed by `vdt_globus_jobmanager_pbs-VDT1.6.0-x86_rhas_4.tar.gz` and `vdt_globus_wsjobmanager_pbs-VDT1.6.0-x86_rhas_4.tar.gz` have to be removed manually.

## Testing LoadLeveler jobs

job submission: -Ft Loadleveler

??? what happens to -Ft PBS jobs (if submitted accidentally?)

job submission: "two strategies" [LLGT40UserGuide](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=LLGT40UserGuide&linkCreation=true&fromPageId=3818228664)

>  (1) submit via GRAM only "llsubmit sample1.jcf".  Obvious (though un-stated) drawback is that the GRAM job will terminiate immediately and the LL job won't be monitorable via Globus

 (2) -Ft Loadleveler

ehm.... as "fs mappings" are entered for each port (-Ft) separately, can we have multiple home mappings for different ports? 

(and have a single ng2?)

# Logging grid usage

I have created a  `/usr/local/sbin/send_grid_usage` script to report LoadLeveler job usage.  The script send the information in the same way as the `send_grid_usage` script written by David Bannon for PBS systems.  However, as LoadLeveler has a completely different system of storing job accounting information, the script has to first obtain the information from LoadLeveler with `llsummary` and next convert the information into PBS format with the script `/usr/local/sbin/loadl2pbs.pl` I wrote for this purpose.  Note that this script has to use the Job Step Id (Job Id with `".0"` appended) as the PBS JobID to  match the information produced by sent in the Job-DN emails by the `auditquery` script.

The script keeps a local copy of the LoadLeveler data and the converted PBS output in `/opt/vdt/globus/var/llacct`

The `/etc/cron.hourly/auditquery` script worked without modification, but I have extended it to log the JobID-DN pair locally into `/opt/vdt/globus/var/llacct/jobdn.log`

# Tweaking loadleveler.pm

- If job description does not specify a job class (via a `queue` element), set a default job class: `par4_6` for parallel jobs and `serial_6` for serial jobs.
- Tagging jobs: extract user identity from `X509_USER_CERT` (if job credentials have been delegated) and *tag* the job with this information by setting `GLOBUS_USER_DN` and `GLOBUS_USER_EMAIL` in the LoadLeveler job environment.
	
- If user email is available, set LoadLeveler `notify_user` to the users's email:

``` 
# \@ notify_user    = $job_environment{GLOBUS_USER_EMAIL}
```
- Change the POE executable from `/bin/poe` to `/usr/bin/poe`.  On AIX, `/bin` is symlink to `/usr/bin` anyway; on Linux, only `/usr/bin` exists.
- If job does not have `uniq_id` (has not been seen yet), use `"".time().".$$"` as the unique ID for log file name.
- Remove `(Adapter h1. "ethernet")` job requirement (for an unexplained reason, this requirement could not be satisfied on Linux, and is not necessary on any nodes anyway).
- Let the script print a "letterhead" statement to `stderr` to prevent LoadLeveler from deleting the empty stderr file.

``` 
$script_file->print('echo "This job has been processed at the University of Canterbury Supercomputing Center (node `hostname`)" >&2'."\n");
```
- Until the `modules` package in installed, add at least `/usr/local/bin` to the job's PATH:

``` 
$script_file->print('PATH=/usr/local/bin:/hpc/home/vme28/bin:$PATH'."\n");
```
- Log the JobID - User-DN pair to `/opt/vdt/globus/var/llacct/jobdn-subm.log`
- If job submission fails, report the `llsubmit` error output as a `GT3_FAILURE_MESSAGE` message, so that it gets displayed on the globusrun-ws console (and also output the error message into the job standard error).
- Workaround for a LoadLeveler bug: if job environment size is just below 1kB, a job with a number of tasks >=8 may fail with

``` 
0031-769 Invalid task environment data received.
```

  For ordinary jobs, this would happen when the `GLOBUS_USER_DN` and `GLOBUS_USER_EMAIL` are both set.  In this case, we get the environment size over the treshhold with a comment environment variable (`GLOBUS_COMMENT`).
- Get [BlueGene job submission](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20BlueGene%20job%20submission%20on%20NG2HPC&linkCreation=true&fromPageId=3818228664) working.
- If (cpu)Count is > $LL_MAX_TASKS_PER_NODE (16) and hostCount is not specified, assume hostCount (ll_node) to be the least number of nodes necessary to accommodate all the tasks:

``` 
($ll_total_tasks - 1)/$LL_MAX_TASKS_PER_NODE + 1;
```


- Convert parallel jobs with just 1 CPU to serial jobs only when `$job_desc_type eq "multi"`. Such jobs are not really used on ARCS/APACGrid/BeSTGRID, and the value quite clearly indicates the cases where job type was unspecified (such as for jobs launched with `globusrun-ws -c`).Let jobs specified as MPI be processed as parallel.

``` 

-   if ($ll_job_type eq "parallel") {
+   if (($ll_job_type eq "parallel") && ($desc_jobtype eq "multiple")) {
       if (!(($ll_total_tasks > 1) || (not_null($ll_blocking)) ||
             defined($ll_tasks_per_node) || defined($ll_min_processor) ||
             defined($ll_max_processors) || defined($ll_task_geometry))) {
          $ll_job_type = "serial";
       }

```

## Solving handing SEG module

The Globus LoadLeveler SEG module was occasionally hanging.  After watching it with strace, I could tell that occasionally, a read from `loadleveler.log` would return a chunk of null bytes - which breaks how the SEG handles it's input buffer.

The null bytes are read when `loadleveler.pm` writes to `loadleveler.log` locally, and at the same time, LoadLeveler writes to `loadleveler.log` remotely in GPFS.  Apparently, the Linux kernel at Ng2HPC is confused, and a read returns a chunk of data containing the locally written event followed by null of the bytes up to the current size returned by NFS - unfortunately, the data that's already been written to the file in GPFS is replaced with null bytes by the confused Linux kernel at ng2hpc.

I have solved this by not writing to the file locally, and instead forwarding the locally created messages over a TCP connection to a "logmaker" instance running at hpcgrid1 (already within the GPFS space).

The message `loadleveler.pm` needs to write into the file is the "PENDING" state event - it won't be generated by LoadLeveler.  The message is `"001;".time().";$job_id;1;0\n"` and it is passed to `/hpc/gridusers/globus/loadl/logmaker.pl` running on hpcgrid1.

## Receiving Mail

As LoadLeveler may be sending email to the user submitting the job (which may be a virtual account, but nevermind), I have enabled receiving remote email on Ng2Hpc. Edit `/etc/mail/sendmail.cf`:

>  O DaemonPortOptions=Port=smtp,Addr=0.0.0.0, Name=MTA

## Job script debugging

To enable grid developers to see the job script generated, the following snippet (based on PBS version by Graham Jenkins) was added to loadleveler.pm (right after `$script_file->close();`)

``` 

   if ($description->emaildebug() ne '') {          # APAC-Specific 'emaildebug' extension
     my $em=$description->emaildebug();
     `/usr/bin/Mail -s "Job-Script.\$\$" $em < $script_filename || :`
   }

```

The way to use it is to include an `emaildebug` extension in the job description, containing the email address where the PBS job script should be sent:

``` 

<!-- Usage: globusrun-ws -submit -s -S -F ng2 -Ft PBS -f gt4-jobname.rsl -->
<job>
  <executable>/usr/bin/env</executable>
  <jobType>single</jobType>
  <extensions>
    <emaildebug>email@address.com</emaildebug>
  </extensions>
</job>

```

This snippet was installed both at ng2hpc.canterbury.ac.nz and ng2hpcdev.canterbury.ac.nz

## Job script debugging - file based option

On an additional request from grid developers (Sean Flemming), the following similar extension was implemented to copy the job script file into a file in the current directory.  The name of the file is specified in the `pbsdebug` extension.

The following snippet was added to the code that builds up the LoadLeveler job command file - after the `# queue` statement, before starting the executable, right after the custom PATH environment variable setting:

>    $pbs_debug_file = $description->pbsdebug();
>    if ($pbs_debug_file ne "")
>    {
>        $script_file->print("\n#pbsdebug\n");
>        $script_file->print("cp \$0 '$pbs_debug_file'\n");
>    }

The extension can be used with a similar job snippet:

``` 

<job>
  <executable>/usr/bin/id</executable>
  <jobType>single</jobType>
  <extensions>
    <pbsdebug>jobscript-debug</pbsdebug>
  </extensions>
</job>

```

This extension was installed both at ng2hpc.canterbury.ac.nz and ng2hpcdev.canterbury.ac.nz

# Tuning the system

## Tuning Loadleveler/Globus communication

The way Globus integrates with the HPC - namely given that the Globus LoadLeveler SEG polls for new changes in /hpc/gridusers/globus/loadl/globus-loadleveler.log - makes the system vulnerable to delays in how job status information propagates to the system.

When show-casing the grid to new users, it looks rather embarrassing when the job shows as Unsubmitted up to a minute after it is submitted to the system - especially if it starts running immediately and output files are already visible in the job directory.

To reduce the delay, I have done two changes:

### Decrease the poll interval for the Globus LoadLeveler SEG

- Modify the SEG module source code: apply the following changes to `/root/inst/llgrid-3.4.2.3/gt4/seg-src`

``` 

--- seg_loadleveler_module.c.orig	2007-08-30 02:33:24.000000000 +1200
+++ seg_loadleveler_module.c	2009-08-20 13:14:45.000000000 +1200
@@ -365,7 +365,9 @@
         rc = globus_l_loadleveler_find_logfile(state);
         if(rc == SEG_LOADLEVELER_ERROR_LOG_NOT_PRESENT)
         {
-            GlobusTimeReltimeSet(delay, 60, 0);
+            //GlobusTimeReltimeSet(delay, 60, 0);
+            // decreasing delay from 60s to 8s
+            GlobusTimeReltimeSet(delay, 8, 0);
         }
         else
         {

```
- Recompile and install with

``` 

./configure --with-flavor=gcc32dbg
gmake
gmake install

```
- Restart globus (or at least the LoadLeveler scheduler generator - find its pid with:


>  ps ax|grep "globus-scheduler-event-generator -s loadleveler"
>  ps ax|grep "globus-scheduler-event-generator -s loadleveler"

### Reduce attribute NFS caching time

The above itself does not solve the problem yet - by default NFS caches file and directory attributes for 60s.  It is necessary to also set `acregmax` and `acdirmax` to a lower value (5s).

- Add `acregmax=5,acdirmax=5` to NFS mount options for /hpc/gridusers (and all other GPFS filesystems) in /etc/fstab

``` 

hpcgrid1-c:/hpc/gridusers      /hpc/gridusers   nfs     fg,retry=20,hard,acregmax=5,acdirmax=5    0 0
hpcgrid1-c:/hpc/griddata      /hpc/griddata   nfs     fg,retry=20,hard,acregmax=5,acdirmax=5    0 0
hpcgrid1-c:/hpc/home      /hpc/home   nfs     fg,retry=20,hard,acregmax=5,acdirmax=5    0 0
hpcgrid1-c:/hpc/projects      /hpc/projects   nfs     fg,retry=20,hard,acregmax=5,acdirmax=5    0 0
hpcgrid1-c:/hpc/work      /hpc/work   nfs     fg,retry=20,hard,acregmax=5,acdirmax=5    0 0
hpcgrid1-c:/hpc/bluefern      /hpc/bluefern   nfs     fg,retry=20,hard,acregmax=5,acdirmax=5    0 0

```

# Installing MIP

The gateway has MIP installed, and feeds the GLUE information via **MIP remote** to Ng2, where the information gets published into MDS.  Due to its complexity, [installing MIP on Ng2HPC](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20MIP%20on%20NG2HPC&linkCreation=true&fromPageId=3818228664) has been documented on a separate page.

# Synchronizing local accounts with the HPC

In order for [local accounts mapping](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setup_NGGums_at_University_of_Canterbury&linkCreation=true&fromPageId=3818228664) to work, all such (HPC) accounts must also exist locally on Ng2HPC.

After considering several alternatives, I have written a script that creates a local password file based on the following rules:

- Take the default CentOS `/etc/passwd` as the basis.


>  **Search HPC's password file, and select*any account that has a UID>1000 and home in **`"/hpc"`
>  **Search HPC's password file, and select*any account that has a UID>1000 and home in **`"/hpc"`

- Merge the selected HPC accounts with the stub for local accounts.

This would overwrite any locally created accounts, but there should not be any such accounts created over the lifetime of the gateway.

Also note that as HPC keeps passwords in a Kerberos database, it would be rather tricky to support password-based logins - but I don't need to grant users access to the gateway.

For groups, I have similar (ad-hoc) rules, which select actual user groups and skip system groups:

- Use a stub of a default CentOS group file.


>  **From HPC's group file, select*all groups with UID>=202** (skip `200=ipsec` and `201=sshd`)
>  **From HPC's group file, select*all groups with UID>=202** (skip `200=ipsec` and `201=sshd`)

Note that in the password file, I have to:

>  **Convert the password entry from form **`"``"` (AIX Kerberos) to `"x"` (Linux shadow) for my personal login to work.

- Convert shell from `/usr/bin/{ksh,csh,bash`} to `/bin/$1`

To setup autocopying, I have created an SSH RSA key for root on ng2hpc:

``` 

 ssh-keygen -t rsa
 => /root/.ssh/id_bestgridpwd_rsa

```

Create `/hpc/gridusers/ictsbgrd/.ssh/authorized_keys` with the contents of `/root/.ssh/id_bestgridpwd_rsa.pub`

Use the following command to SCP with only RSA authentication permitted (not to get ever prompted for a password):

``` 

 scp -i /root/.ssh/id_bestgridpwd_rsa -o PasswordAuthentication=no ictsbgrd@hpcgrid1.canterbury.ac.nz:/etc/'{passwd,group}' ./hpc/ < /dev/null > /dev/null 2>&1

```

The merging of the password and group files is done in `/root/pwdmrg` by the script `/root/pwdmrg/pwdsync.sh`.  This script:

- copies the password and group file from hpcgrid1 into the HPC subdirectory.
- invokes `pwdmrg.pl` to merge the stub and HPC password and group file into new files in the `merged` directory.
- compares the new password and group file with the ones installed in `/etc`.
- If a newer version of a file is available, the old one is backed up as a time-stamped file in the backup directory, and the new one is installed into `/etc`.

The script is invoked by cron every hour by installing the cron entry file `/etc/cron.d/pwdmrg.cron`:

>  30 * * * * root /root/pwdmrg/pwdsync.sh

# Installing GsiSSH

GsiSSH allows users to log on to a SSH terminal session with their X509 credentials.

GsiSSH is available as an VDT package that can be installed with:

>  pacman -pretend-platform linux-rhel-4 -get [http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:GSIOpenSSH](http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:GSIOpenSSH)

After the pacman installation, `/opt/vdt/post-install/sshd` has to be installed as `/etc/rc.d/init.d/sshd` and modified to source the full VDT environment - see patch below.  After killing the old `sshd`, start the new sshd (`/opt/vdt/globus/sbin/sshd`) with `service sshd start`

``` 

--- /opt/vdt/post-install/sshd	2008-10-31 11:44:14.000000000 +1300
+++ /etc/rc.d/init.d/sshd	2008-10-31 14:01:03.000000000 +1300
@@ -18,6 +18,10 @@
 # Description: Start the sshd daemon
 ### END INIT INFO
 
+# extra: Vladimir Mencl
+VDT_LOCATION="/opt/vdt"
+. $VDT_LOCATION/setup.sh
+
 GLOBUS_LOCATION="/opt/vdt/globus"
 export GLOBUS_LOCATION
 

```

Note: gsissh logins will fail for accounts that are marked as disabled - have `!!` as the password hash in `/etc/shadow`.  But it will succeed if `/etc/shadow` has no record for the account... so to enable login, perhaps delete entries like this one:

>  grid-adm:!!:13969:0:99999:7:::

# TODO

- check with someone if it is worth looking at the Axis complaint in globus/var/container-real.log

``` 
2007-07-11 16:02:20,598 WARN  utils.JavaUtils [main,isAttachmentSupported:1218] Unable to find required classes (javax.activation.DataHandler and javax.mail.internet.MimeMultipart). Attachment support is disabled.
```
- .... likely only Axis complaining, not needed.

Optionally:

- disable GRAM+RFT service registration from SecureMDS
- Get job uniq_id (for logging) from the GLOBUS_GRAM_JOB_HANDLE
- Remove temporary submission log in loadleveler.pm even if submission fails

Done:

- move loadleveler log file to /hpc/gridusers/var/
- prevent LoadLeveler from deleting empty stdErr
- setup audit (to send JobID-DNs to VPAC)
- setup PBS log equivalent to be sent to VPAC (JobID CPU usage)
- JobDN-subm is logged with Unix time (int); switch to readable date
