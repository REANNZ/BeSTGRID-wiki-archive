# Setting up an NG2 PBS specific parts

This page contains the PBS(/Torque)-specific supplementary material for the instructions on [Setting up an NG2](/wiki/spaces/BeSTGRID/pages/3818228585)

# LRM access

- Install PBS client - either from the same distribution as your cluster or use the Gtorque-client package from the ARCS repository:

``` 
yum install Gtorque-client
```
- In this case, edit `/usr/spool/pbs/server_name` and set it to your PBS server name.
- Add PBS port numbers into /etc/services (if needed)

- Add this host (ng2.your.site) into /etc/hosts.equiv on the PBS server

- Configure all cluster nodes to use "cp" instead of "scp" to deliver output files: add the following line to the node configuration file on each node (usually `/var/spool/torque/mom_priv/config`, you may have to create the file if it doesn't exist yet):

``` 
$usecp *:/home /home
```
- Note: the line will be different if home directories are not mounted under `/home`

- An alternative to the `usecp` directive would be to setup password-less login from each node in the cluster to NG2:
- add ng2's /etc/ssh/ssh_host_rsa_key.pub into ssh_known_hosts on the PBS server
	
- ng2: /etc/ssh/sshd_config: add 

``` 
HostbasedAuthentication yes
```
- ng2: /etc/ssh/shosts.equiv: add a line for each node in the cluster like:

``` 
+compute-01.your.site
```

# Log replication

**Note**: See documentation on updated pbs-telltail tool at [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PBSTelltail](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PBSTelltail)

- On NG2, install the pbs-telltail package:

``` 
yum install pbs-telltail
```
- Installing the package automatically starts and configures the pbs-logmaker packages, listening on port 2822

- On the cluster headnode, install and start the pbs-telltail script to watch the PBS logs and send them to the ng2.
	
- Install /usr/local/pbs-telltail/pbs-telltail (the actual script) into the same location on the headnode.
- Install /usr/local/pbs-telltail/pbs-telltail.RH as /etc/rc.d/init.d/pbs-telltail on the headnode.
- If installing NG2 under a different hostname (or installing an additional NG2 as a development box), edit the service control script `/etc/rc.d/init.d/pbs-telltail` and configure the REMOTES line like:

``` 
REMOTES="ng2:2812 ng2dev:2812 ng1:2812"
```
- Enable and start the script (on the headnode):

``` 
chkconfig pbs-telltail on ; service pbs-telltail start
```

# Globus integration

- Tell the Globus PBS Scheduler-Event-Generator where to find PBS logs:


>  echo "log_path=/usr/spool/PBS/server_logs" >> /opt/vdt/globus/etc/globus-pbs.conf
>  echo "log_path=/usr/spool/PBS/server_logs" >> /opt/vdt/globus/etc/globus-pbs.conf

- Replace the Globus default PBS LRM module with one specific for ARCS grid (part of Ggateway package)


>  cp /usr/local/src/pbs.pm.APAC /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm
>  cp /usr/local/src/pbs.pm.APAC /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm

- You may have to customize this module for your site: particularly, the location of `qsub` and `qstat` and the exact way to invoke `mpiexec`
	
- See [Grid gateway enhancements at University of Canterbury](/wiki/spaces/BeSTGRID/pages/3818228905) and [PBS job tagging](/wiki/spaces/BeSTGRID/pages/3818228870) for more enhancements to put into `pbs.pm` - these should however be configured after the gateway is fully setup.
- You may wish to keep the original Globus pbs.pm and pbs.pm.APAC under different filenames for future reference.

# Usage reporting

- Install the following script on the cluster headnode (by convention as /usr/local/sbin/send_grid_usage) to be run daily (1am is a good time...) ... so you may also do this by creating this cron-job file as: `/etc/cron.d/send_grid_usage.cron`:

``` 
3 1 * * * root /usr/local/sbin/send_grid_usage
```
- Replace *clustername* with the name of your cluster.
- Replace *SITE-NAME* with the name assigned to your site on the GOC.
- The contents of `/usr/local/sbin/send_grid_usage` is:

``` 

#!/bin/bash
# This script emails the grid usage report for yesterday
# to the grid operations centre.
# It should be called from crontab daily
# Please note the email subject, its is in the format of :
#   <cluster_name> <site_Name> <date>
# Please keep this consistent, we need it like that.

YESTERDAY=`date --date=yesterday +%Y%m%d`
cd /var/spool/torque/server_priv/accounting
grep Grid_ "$YESTERDAY" | mail -s "clustername SITE-NAME $YESTERDAY" grid_pulse@lists.arcs.org.au
logger -t GridAccounting "Grid usage from /var/spool/torque/server_priv/accounting/$YESTERDAY emailed to grid_pulse@lists.arcs.org.au"

```

# MIP configuration

Not much to do for PBS.

Make sure `/usr/local/mip/config/apac_config.py` has the correct path to the PBS client binaries.  E.g.:

>  computeElement.qstat = '/usr/local/bin/qstat'
>  computeElement.pbsnodes = '/usr/local/bin/pbsnodes'
