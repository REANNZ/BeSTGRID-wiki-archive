# Upgrading NG2

Production gateway **ng2.auckland.ac.nz** has been upgraded to the latest version of **VDT 1.10.1b** and reconfigured to use it with production cluster **hpc-bestgrid.auckland.ac.nz**.

The following steps have been performed:

# Upgrading of APAC scripts and packages:

>  yum remove Gpilse
>  yum install APAC-gateway-gridpulse
>  yum update APAC-mip
>  yum update APAC-mip-module-py
>  yum update Gbuild
>  yum remove pbs-telltail
>  yum install pbs-telltail

# Installing VDT 1.10.1b

This process based on VDT installation procedure described [here](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Auckland_Test_Gateway&linkCreation=true&fromPageId=3816950709)

There weren't special issues.

# PBS configuration

>  **NG2: Service*pbs-logmaker** has been configured to save PBS logs to 
>  usr/spool/PBS/server_logs
>  **NG2: File**/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm* has been edited:

``` 

18,19c18,19
<     $mpiexec = 'no';
<     $mpirun = 'no';
---
>     $mpiexec = '/usr/bin/mpiexec';   #### Andrey Kharuk 4/06/2008: there was no
>     $mpirun = '/usr/bin/mpirun';     #### Andrey Kharuk 4/06/2008: there was no
159a160,164
> #### Andrey Kharuk 4/06/2008
>     chomp($submit_host = `/bin/hostname -s`);   # APAC-specific job-name, email
>     print JOB '#PBS -N Grid_', $submit_host, "_", $description->jobname(), "\n";
> #### Andrey Kharuk 4/06/2008
>

```

- NG2: /usr/spool/PBS/server_name should consist FQDN of the headnode


>  hpc-bestgrid.auckland.ac.nz
>  hpc-bestgrid.auckland.ac.nz

- HPC-Bestgrid: The head node has been configured to submit PBS logs according ARCS [recommendations](http://wiki.arcs.org.au/bin/view/APACgrid/NgTwoConfigInstructions#PBS_Configuration)

# Auditing for ARCS GOC

Grid accounting is described [here](http://wiki.arcs.org.au/bin/view/APACgrid/PlanAccounting).

- To add audit subsystem on NG2 run script:


>  /usr/local/bin/AddAuditNg2Vdt181.sh
>  /usr/local/bin/AddAuditNg2Vdt181.sh

- HPC-Bestgrid: create file /usr/local/sbin/send_grid_usage

``` 

#! /bin/bash
#
# This script emails the grid usage report for yesterday
# to the grid operations centre.
# It should be called from crontab daily
# Please note the email subject, its is in the format of :
#   <cluster_name> <site_Name> <date>
# Please keep this consistent, we need it like that.

YESTERDAY=`date --date=yesterday +%Y%m%d`

# echo "Yesterday is $YESTERDAY"

cd /opt/torque/server_priv/accounting;
grep  Grid_ "$YESTERDAY" | mail -s "hpc-bestgrid NZ-UoA $YESTERDAY" grid_pulse@arcs.org.au
logger -t GridAccounting "Grid usage from /opt/torque/server_priv/accounting/$YESTERDAY emailed to grid_pulse@arcs.org.au"

```
- HPC-Bestgrid: change permission


>  chmod a+x /usr/local/sbin/send_grid_usage
>  chmod a+x /usr/local/sbin/send_grid_usage

- HPC-Bestgrid: create cronjob:


>  3 1 * * * /usr/local/sbin/send_grid_usage >/dev/null 2>&1
>  3 1 * * * /usr/local/sbin/send_grid_usage >/dev/null 2>&1

# MIP reconfiguration
