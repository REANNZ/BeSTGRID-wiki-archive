# Setup NGCompute at University of Canterbury

This virtual machine was an experimental deployment at the University of Canterbury.  You typically won't need to *create* this virtual machine in your grid setup.  You will be typically setting up an NG2 to link an existing cluster.  

This VM was deployed to create a prototype PBS cluster with just one node with 4 virtual CPUs (making use of actual 4 physical CPUs) to test the grid infrastructure deployment at the University of Canterbury.  In all sensible scenarios, you will be linking an existing cluster and you won't need to *create* an NGCompute virtual machine.

This page however documents what it takes to link a cluster to the grid - and many of the steps should be implemented at the cluster headnode.  Use your own discretion to skip the steps that have already been done as a part of your cluster setup, and implement only those step that link the cluster headnode to the NG2.

# Create VM

Follow general rules - [Vladimir__Bootstrapping a virtual machine](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Bootstrapping%20a%20virtual%20machine&linkCreation=true&fromPageId=3816950795)

# Setup PBS

## Local PBS configuration

- Download `torque-2.1.8.tar.gz` from [http://www.clusterresources.com/pages/products/torque-resource-manager.php](http://www.clusterresources.com/pages/products/torque-resource-manager.php)
- `./configure && make && make install`
- `/etc/profile.d/pbs.sh`:


>   PBS_HOME=/var/spool/torque/
>   export PBS_HOME
>   PBS_HOME=/var/spool/torque/
>   export PBS_HOME

- Add to `/etc/services`

>   pbs             15000/tcp       # added by Vladimir Mencl
>   pbs_dis         15001/tcp       # added by Vladimir Mencl
>   pbs_dis         15001/udp       # added by Vladimir Mencl
>   pbs_mom         15002/tcp       # added by Vladimir Mencl
>   pbs_mom         15003/udp       # added by Vladimir Mencl
>   pbs_mom         15003/tcp       # added by Vladimir Mencl
>   pbs_sched       15004/tcp       # added by Vladimir Mencl

- Define a single cluster (non-shared) node with four CPUs in `$PBS_HOME/server_priv/nodes`


>   ngcompute np=4
>   ngcompute np=4


- Initialize db


>   pbs_server -t create
>   pbs_server -t create

- start server


>   pbs_mom 
>   pbs_sched
>   pbs_server # skip running for the first time
>   pbs_mom 
>   pbs_sched
>   pbs_server # skip running for the first time

- Qmgr:

>   set server managers=vme28@ngcompute.canterbury.ac.nz 
> 1. note: must match hostname reverse lookup
> 2. BIG NOTE: /etc/hosts has temporary entry to ensure correct reverse lookup
>   create queue small
>   active queue small
>   set queue small queue_type=execution
>   set queue small enabled=true
>   set server scheduling=true
>   set queue small started=true
>   set server default_queue=small
> 1. set PBS queue restrictions
>   set queue small resources_max.cput=168:00:00
>   set queue small resources_default.cput=72:00:00
> 1. Limit the number of jobs run by a single user at the same time
>   set queue small max_user_run=2
>   set queue small resources_default.nodes=1
> 1. needed: otherwise, pbs_sched keeps crashing
>   set server submit_hosts = ngcompute.canterbury.ac.nz
>   set server submit_hosts += grid.canterbury.ac.nz
>   set server submit_hosts += ng2.canterbury.ac.nz
> 1. does not really work (see below), but we want these machines to submit

 **Edit **`/var/spool/torque/sched_priv/sched_config`** and set **`help_starving_jobs`** to*false** (Credits: [http://comments.gmane.org/gmane.comp.clustering.torque.user/2423):](http://comments.gmane.org/gmane.comp.clustering.torque.user/2423):)

``` 
help_starving_jobs      false   ALL
```

## Permit `grid` and `ng2` to submit jobs to `ngcompute`

- permit the hosts to submit jobs: `submit_hosts` property does not work (ignored??), instead, use `/etc/hosts.equiv`

>   grid.canterbury.ac.nz
>   ng2.canterbury.ac.nz


## Rationale on configuration

- To properly allocate jobs to the 4 available CPUs, host has to be set up as cluster (non-shared) with np=4.  Initially, pbs_sched kept crashing, and it is necessary for each job to specify the number of nodes it needs.  This has been achieved with `resources_default.nodes=1`. (Individually, job's resources can be specified like `qsub -l nodes=1`).

>  **For pbs_server to return results to the submitting machine (no overriding solution for shared filesystem was found), it was necessary to permit ssh access from ngcompute to submission hosts - **`grid`** and **`ng2`**.  To permit submission from these hosts, they have to be included in **`/etc/hosts.equiv`** on **`ngcompute`**.  This however does not permit password-less logins from these hosts to **`ngcompute`** - as long as **`HostbasedAuthentication`** is*not** turned on in `sshd_config`.

## Install MPI

### Choosing an MPI implementation

First, I thought I would use LAM/MPI - because it's free, and it's available as an RPM package in CentOS.  However, LAM/MPI needs custom startup procedure (`lamboot` / `lamhalt`), and, more importantly, due to the way `lamd` is started by `lamboot`, CPU usage accounting does not work with LAM/MPI.

Lamd is started as an orphaned process, and consequently, cpu usage of lamd (and of the computation processes started by lamd) does not get into job's cpu total time.

MPICH2 does not suffer from these problems, and it was chosen as the preferred MPI implementation (at least for `ngcompute`)

### Installing MPICH2

Key trick - make gforker the default Process Manager:

>  ./configure --with-pm=gforker:mpd:remshell
>  make
>  make install

To start a program, no daemon startup/shutdown is necessary - only use

>  mpiexec -np "`cat $PBS_NODEFILE | wc -l `" program

Issue: PATH in PBS

MPICH2 installs into `/usr/local/bin`, and this directory is *not* in the default PATH available for PBS jobs.  PBS defaults (in `$PBS_HOME/pbs_environment`) contain only `/bin:/usr/bin`, and `/etc/profile` does not add `/usr/local/bin`.

The solution was to create `/etc/profile.d/mpich2.sh`:

>  #!/bin/sh

>  export MPICH2_HOME=/usr/local

>  MPICH2_BIN="$MPICH2_HOME/bin"
>  if ! echo $PATH | /bin/egrep -q "(^|🙂$MPICH2_HOME($|🙂" ; then
>    PATH=$PATH:$MPICH2_BIN
>  fi

### Old: installing LAM/MPI

http_proxy=[http://gridws1:3128](http://gridws1:3128) yum install lam

To run MPI jobs, use:

>   qsub -N mrbayes2 -l nodes=1:ppn=2 run-mrbayes-mp.sh

with `run-mrbayes-mp.sh` containing

>   lamboot $PBS_NODEFILE
>   mpiexec -ssi rpi sysv C ~/inst/mrbayes-3.1.2-lammpi/mb mytaxa.NEX
>   lamclean
>   lamhalt

Note: SSI RPI modules available are:

- tcp - TCP communication
- crtcp - Checkpointable Restartable TCP
- sysv - SHM with semaphore blocking - for overcommitted nodes
- usysv - SHM and spinlocks - more efficient on non-overcommitted nodes

More information (and `gm` and `lamd`) can be found in `lamssi_rpi(7)`

The recommended configuration is sysv - shared memory is more efficient for single-node setup, and we want blocking synchronization here - otherwise, the other virtual machines would be unnecessarily starving.

Hack: changed `/etc/lam/lam-conf.lamd` to report time usage:

>   /usr/bin/time lamd $inet_topo $debug $session_prefix $session_suffix

## Allow incoming mail

In `/etc/mail/sendmail.cf` change the following:

>  O DaemonPortOptions=Port=smtp,Addr=0.0.0.0, Name=MTA
> 1. O DaemonPortOptions=Port=smtp,Addr=127.0.0.1, Name=MTA

Reason: PBS occasionally send email back to submitting user.

## Start up PBS server automatically

`/etc/rc.d/init.d/pbs-server`

>  #!/bin/bash

>  case $1 in

>  start)
>     /usr/local/sbin/pbs_mom
>     /usr/local/sbin/pbs_sched
>     sleep 1
>     /usr/local/sbin/pbs_server

> 1. 
> 1. 
> 1. /usr/local/bin/qmgr -c "set server scheduling = True"
>  ;;

>  stop)
>      /usr/local/bin/qterm -t quick
>      sleep 3
>      killall pbs_server pbs_sched pbs_mom
>  ;;

>  esac

# Setup NFS client

To mount directories [provided by ](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20Grid&linkCreation=true&fromPageId=3816950795)[grid](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20Grid&linkCreation=true&fromPageId=3816950795), the following has to be turned on:

Edit `/etc/fstab`

>  grid.canterbury.ac.nz:/export/home       /home         nfs   fg,retry=20,hard  0  0
>  grid.canterbury.ac.nz:/export/opt/shared /opt/shared   nfs   fg,retry=20,hard  0  0

Arrange for mount points (empty `/home` and `/opt/shared`) to exist and then run:

>  chkconfig portmap on
>  chkconfig netfs on  

>  service portmap start
>  service netfs start

# Job accounting reporting

To report grid usage to [Grid Operations Center](http://goc.grid.apac.edu.au/) (according to the [Accounting Plan](http://www.vpac.org/twiki/bin/view/APACgrid/PlanAccounting), a script has to be called daily (after midnight).

- Create:

`/usr/local/sbin/send_grid_usage`

``` 

#! /bin/bash
# This script emails the grid usage report for yesterday
# to the grid operations centre.
# It should be called from crontab daily
# Please note the email subject, its is in the format of :
#   <cluster_name> <site_Name> <date>
# Please keep this consistent, we need it like that.

. /etc/profile.d/pbs.sh

YESTERDAY=`date --date=yesterday +%Y%m%d`
# cd /usr/spool/PBS/server_priv/accounting;
cd $PBS_HOME/server_priv/accounting;
grep Grid_ "$YESTERDAY" | mail -s "ngcompute NZ-Cant $YESTERDAY" grid_pulse@arcs.org.au
logger -t GridAccounting "Grid usage from $PBS_HOME/server_priv/accounting/$YESTERDAY emailed to grid_pulse@arcs.org.au"

```

>  ****Note***: When this job is run from `cron`, the `PBS_HOME` envrionment variable is not set - hence, it's necessary to source either `/etc/profile` (complete environment), or at least `/etc/profile.d/pbs.sh`

- Create `/etc/cron.d/send_grid_usage.cron`

``` 
3 1 * * * root /usr/local/sbin/send_grid_usage
```
- `service crond restart`

# Documenttation

- PBS: [http://www.clusterresources.com/wiki/doku.php?id=torque:torque_wiki](http://www.clusterresources.com/wiki/doku.php?id=torque:torque_wiki)
- OpenSSH host-based authentication: [http://cert.uni-stuttgart.de/doc/openssh/host-based.php](http://cert.uni-stuttgart.de/doc/openssh/host-based.php) and [http://tiger.la.asu.edu/Quick_Ref/OpenSSH_quickref.pdf](http://tiger.la.asu.edu/Quick_Ref/OpenSSH_quickref.pdf)

- Tricks:


>  set server operators += username@headnode
>  set server operators += username@headnode

