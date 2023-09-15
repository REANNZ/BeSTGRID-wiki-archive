# PBS job tagging

I have modified the PBS.pm job-manager script to tag PBS jobs with PBS a environment variable containing the Distinguished Name (DN) of the user who submitted the job.  This makes the owner of a job clearly visible in the `qstat -f` output, and gives the cluster administrator a better chance to respond if something goes wrong with a job.  

**This page has been recently updated, and the new method described here retrieves the user's  information from the GRAM audit database**.  Contrary to the previous method (retrieving the information from the credentials delegated to the job, which worked only for a job submitted with job credentials delegated, `-J` option for `globusrun-ws`), the new method should be reliable and should not depend on a particular method of submitting the job.

In addition to tagging the job, I have also modified pbs.pm to log the JobId-DN mapping at the time the job is submitted, to have an audit trail in case the Globus  audit message is lost.

As the new method retrieves only the DN but not the email address, I have removed references to the email address from this page.  Apologies if you stumble upon one - the new method won't obtain the user's email address.

Also, while developing this new method, I found one issue with the `/etc/cron.hourly/auditquery}}script which might have been causing loss of records from the {{auditDatabase` - a fix for this issue is described further below.

# Retrieving DN from the GRAM audit database

The job environment passed in the job description to `pbs.pm` contains the environment variable `GLOBUS_GRAM_JOB_HANDLE`, which contains the job endpoint reference in the form [https://ng2maggie.otago.ac.nz:8443/wsrf/services/ManagedExecutableJobService?2828a540-e0bf-11dc-8ba8-ffac443c90f7](https://ng2maggie.otago.ac.nz:8443/wsrf/services/ManagedExecutableJobService?2828a540-e0bf-11dc-8ba8-ffac443c90f7).

The `auditDatabase.gram_audit_table` table contains user DN in field `subject_name`, and is indexed by `job_grid_id` of the form [https://ng2maggie.otago.ac.nz:8443/wsrf/services/ManagedExecutableJobService?3ozaQzjbyYKPXJAKWMMfn3iqGho](https://ng2maggie.otago.ac.nz:8443/wsrf/services/ManagedExecutableJobService?3ozaQzjbyYKPXJAKWMMfn3iqGho).

As described in the [Globus Audit Logging](http://www.globus.org/toolkit/docs/4.0/execution/wsgram/WS_GRAM_Audit_Logging.html) page and in the [EPRUtil.java](http://viewcvs.globus.org/viewcvs.cgi/wsrf/java/core/source/src/org/globus/wsrf/impl/security/util/EPRUtil.java?view=markup) class, the ResourceId is just replaced with a Base64 encoding of its SHA1 hash.

pbs.pm then has to be modified to (the modifications are detailed in the patch linked below):

- Retrieve the GRAM job reference from the `GLOBUS_GRAM_JOB_HANDLE` job environment variable.
- Convert this to the format used in `auditDatabase.job_grid_id` - replace the ResourceId with it's base64-encoded SHA-1 digest:

``` 
$globus_job_epr =~ s/\?([-0-9a-f]*)/'?' . main::encode_base64(main::sha1($1),"")/e;
```
- Retrieve the `subject_name` associated with this job in the `auditDatabase`.  This is done by invoking an external script via sudo - so that the mysql credentials used by the script to access the `auditDatabase` are not visible by local accounts on the gateway machine.
- Add variables `GLOBUS_USER_DN` to the job environment.
- Add these variables also as PBS variables with `#PBS -v VARNAME=value` in the job script.

The script retrieving the `subject_name` from the `auditDatabase` for a `job_grid_id` (assumed to be in `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/GetJobDN.sh`) can be very brief - it's essence is just to invoke MySQL with a single query, and the rest is just setting environment variables to safely invoke MySQL even in a SUID environment.  The script does sanitize the job EPR passed, and it also sets the `MYSQL_CONF` to a MySQ configuration with the password stored (see below).  Either copy the file from its inline version below, or download from here: [GetJobDN.sh](/wiki/download/attachments/3818228870/GetJobDN.sh.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2)

``` 

#!/bin/bash
#
# We are in a potentially SUID script - be very careful about what we trust
#

VDT_LOCATION=/opt/vdt
GLOBUS_LOCATION=$VDT_LOCATION/globus
MYSQL=$VDT_LOCATION/mysql/bin/mysql
JOB_MANAGER_DIR=$GLOBUS_LOCATION/lib/perl/Globus/GRAM/JobManager
MYSQL_CONF=$JOB_MANAGER_DIR/audit-mysql.conf
LD_LIBRARY_PATH="$VDT_LOCATION/mysql/lib/mysql:$GLOBUS_LOCATION/lib:$LD_LIBRARY_PATH" # necessary when SUID
export LD_LIBRARY_PATH

SAFE_EPR=$( echo $1 | tr -d "'"'\`${}()*!%^&' )
$MYSQL --defaults-file=$MYSQL_CONF --user audit --skip-column-names auditDatabase<<EOF
select subject_name from gram_audit_table where job_grid_id='$SAFE_EPR';
EOF

```

The script references the `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/audit-mysql.conf` configuration file, containing the password for the `audit` MySQL user.  The password can be found in `$GLOBUS_LOCATION/etc/gram-service/jndi-config.xml` (where it is stored when installing the Audit extension), and the `audit-mysql.conf` file should contain just the following two lines (with the proper password):

``` 

[client]
password=auditpassword

```

To prevent grid users from accessing this file, the file should be readable only by the `daemon` account.

Finally, the script should be executed via sudo: the pbs.pm patch referenced above does this with:

>  $globus_user_dn = `sudo -u daemon \$GLOBUS_LOCATION/lib/perl/Globus/GRAM/JobManager/GetJobDN.sh '$globus_job_epr'  2> /dev/null`;

And the `/etc/sudoers` line to permit this script to be invoked as daemon is:

>  ALL ALL=(daemon)               NOPASSWD: /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/GetJobDN.sh *

# Old method: Tagging PBS jobs with information from job delegated certificates

The functions for extracting the DN and email address from the delegated credentials are implemented in a separate module `getcertdn.pm`.  pbs.pm then has to be modified to:

- Import the getcertdn.pm module.
- Retrieve the file name of the delegated proxy certificate from the job environment
- Use the module's `getCertDNEmail` to retrieve the user's distinguished name and email address from the proxy certificate.
- Use the user's email address as the PBS notification email.
- Add variables `GLOBUS_USER_DN` and `GLOBUS_USER_EMAIL` to the job environment.
- Add these variables also as PBS variables with `#PBS -v VARNAME=value` in the job script.

# Recording Job-DN mapping at job submission time

When a job is successfully submitted, an additional modification to pbs.pm emits a single line with current date, job id and user's DN to `/opt/vdt/globus/var/pbs-acct/jobdn-subm.log` (and also invokes `logger` to emit the message to syslog).

This gives an audit trail in case Globus fails to produce the audit message at the time the job completes.

# Fixing auditquery: avoid loss of JobDN data

Originally (in VDT1.6.1 / Globus 4.0.3), the `auditDatabase` record was generated only at the time the job completed, and at that point, the record contained all the information it could have contained - the record would not be modified.  Based on these assumptions, the `auditquery` script was designed in a way that it:

1. walks through all records in `auditDatabase`, emits a Job-DN entry in the email to GOC for each record, and deletes the record (based on the local job ID).
2. to cleanup records for jobs that were rejected by the local scheduler, `auditquery` also deletes all records that don't have a `local_job_id` (it is NULL) - such jobs fail to be deleted in the previous step.

However, in VDT 1.8.1 / Globus 4.0.5, the audit mechanism has been significantly changed.  An auditDatabase record is created for a job at the time the job is submitted to Globus, with information available at that time filled in (grid_job_id, user_name), and yet unknown fields set to NULL - this includes `local_job_id`.  As additional information becomes available, it is filled into the record.  After a job is successfully submitted to the local scheduler, the job id assigned by the local scheduler is entered into the job_id field.  The fields `success_flag` and `finished_flag` can be used to monitor the progress and status of the job.

This is not compatible with the algorithm implemented in the auditquery script, and a race condition is introduced.  If auditquery is run after the job is submitted to Globus but before Globus submits the job to the local scheduler (this time-window can be quite large for jobs with a StageIn stage), step 1 emits an erroneous message for such job, and step 2 deletes the job's record from auditDatabase.  Globus won't re-create the auditDatabase record again, and the pairing information between the subject_name and the local job ID is lost.  This would cause a failure of the PBS job tagging mechanism described here, but would also cause the Job-DN information to be missing in the Grid Operations Centre.

The `auditquery` script can be fixed by:

- changing step 1. to only process records with `local_job_id` field already set:


>  select concat_ws(' ',local_job_id, subject_name) from gram_audit_table **where local_job_id is not NULL**;
>  select concat_ws(' ',local_job_id, subject_name) from gram_audit_table **where local_job_id is not NULL**;

- changing step 2. (deleting records with `local_job_id` unset) to only delete records which have the `finished_flag` set to `'true'`:


>  delete from  gram_audit_table where local_job_id is NULL **and finished_flag = 'true**';
>  delete from  gram_audit_table where local_job_id is NULL **and finished_flag = 'true**';

These changes are summarized by the following patch to `/etc/cron.hourly/auditquery` ([auditquery-fix-NULL-id.diff](/wiki/download/attachments/3818228870/Auditquery-fix-NULL-id.diff.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2), file info: 

!Auditquery-fix-NULL-id.diff.txt!

):



``` 

--- /root/inst/pbs-acct/auditquery-gridaus-logfile      2008-02-19 16:14:47.000000000 +1300
+++ auditquery  2008-02-25 11:15:23.000000000 +1300
@@ -18,7 +18,7 @@
 mysql <<EOF 2>/dev/null | sed -n '2,$p' |
 use auditDatabase;
 select concat_ws(' ',local_job_id, subject_name)
-from gram_audit_table;
+from gram_audit_table where local_job_id is not NULL;
 EOF
 while read Line; do
   echo     "`date` Job-DN: $Line" >> /opt/vdt/globus/var/pbs-acct/jobdn.log
@@ -33,5 +33,5 @@
 # Perform deletions
 ( cat $File
   echo "delete from  gram_audit_table"
-  echo "where local_job_id is NULL;" ) | mysql >/dev/null 2>&1
+  echo "where local_job_id is NULL and finished_flag = 'true';" ) | mysql >/dev/null 2>&1
 exit 0

```

For the curious: I found this while developing the new audit-based method. I was looking into the `auditquery` script to see if there is any risk that the script would delete the auditDatabase record before the subject_name is extracted to be used for tagging the job.  I found that yes, and I realized that in such a case, the Job-DN pairing information would be also lost for the GOC - this is where the fix came from.

# Recording Job-DN mapping in auditquery

I have also modified `/etc/cron.hourly/auditquery` to log each JobId-DN pair it emits to GOC in 

`/opt/vdt/globus/var/pbs-acct/jobdn.log`. (See the one line modification below in t[Installation](#PBSjobtagging-Installation)

# Installation

- Create empty log files for logging the JobId-DN mapping:

``` 

mkdir /opt/vdt/globus/var/pbs-acct
touch /opt/vdt/globus/var/pbs-acct/jobdn.log
touch /opt/vdt/globus/var/pbs-acct/jobdn-subm.log
chmod 666 /opt/vdt/globus/var/pbs-acct/jobdn-subm.log 

```
- Note: the `jobdn-subm.log` must be world-writable, because pbs.pm runs with the permission of the local user account to which the grid user is mapped.  On the contrary, jobdn.log is written to only by auditquery running as root, so no access permissions have to be granted.
- Download the script [GetJobDN.sh](/wiki/download/attachments/3818228870/GetJobDN.sh.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2) and store it as `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/GetJobDN.sh`
- Create `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/audit-mysql.conf`, readable only by daemon, containing the following two lines (with password replaced with the actual `audit` MySQL password, stored in `$GLOBUS_LOCATION/etc/gram-service/jndi-config.xml`):


>  [client]
>  password=auditpassword
>  [client]
>  password=auditpassword

- Make the `GetJobDN.sh` script executable as `daemon` via `sudo`: add the following line to `/etc/sudoers` (edit with `visudo`):


>  ALL ALL=(daemon)               NOPASSWD: /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/GetJobDN.sh *
>  ALL ALL=(daemon)               NOPASSWD: /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/GetJobDN.sh *

- Download the patch [pbs.pm-tag-dn-from-audit.diff](/wiki/download/attachments/3818228870/Pbs.pm-tag-dn-from-audit.diff.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2) and use it to patch `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm`
- Modify auditquery as indicated above: insert the following line at the beginning of the while loop, just above the logger command:

``` 
echo     "`date` Job-DN: $Line" >> /opt/vdt/globus/var/pbs-acct/jobdn.log
```
- Install the fix to `auditquery` described above in [Avoid loss of JobDN data](#PBSjobtagging-Fixingauditquery___avoidlossofJobDNdata) - apply the patch [auditquery-fix-NULL-id.diff](/wiki/download/attachments/3818228870/Auditquery-fix-NULL-id.diff.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2) to `/etc/cron.hourly/auditquery`
- Try submitting a job - the extension should work now, and you should be able see the additional information as described [below](#PBSjobtagging-Accessinguserjobinformation).

# Old method: Installation

- Create empty log files for logging the JobId-DN mapping:

``` 

mkdir /opt/vdt/globus/var/pbs-acct
touch /opt/vdt/globus/var/pbs-acct/jobdn.log
touch /opt/vdt/globus/var/pbs-acct/jobdn-subm.log
chmod 666 /opt/vdt/globus/var/pbs-acct/jobdn-subm.log 

```
- Note: the `jobdn-subm.log` must be world-writable, because pbs.pm runs with the permission of the local user account to which the grid user is mapped.  On the contrary, jobdn.log is written to only by auditquery running as root, so no access permissions have to be granted.
- Download the perl module [getcertndn.pm](/wiki/download/attachments/3818228870/Getcertdn.pm.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2) and store it as `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/getcertdn.pm`
- Download the patch [pbs.pm-tag-dn-email-log-jobdn.diff](/wiki/download/attachments/3818228870/Pbs.pm-tag-dn-email-log-jobdn.diff.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2) and use it to patch `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm`
- Modify auditquery as indicated above: insert the following line at the beginning of the while loop, just above the logger command:

``` 
echo     "`date` Job-DN: $Line" >> /opt/vdt/globus/var/pbs-acct/jobdn.log
```
- Try submitting a job - the extension should work now, and you should be able see the additional information as described [below](#PBSjobtagging-Accessinguserjobinformation).

# Accessing user job information

The above extension provides the following information:

- The DN and email address of owners of currently running jobs can be accessed with

``` 
qstat -f
```
- The DN and email address of all jobs (submitted, running, completed) is in `/opt/vdt/globus/var/pbs-acct/jobdn-subm.log`
- The DN for completed jobs, as sent by auditquery, is in `/opt/vdt/globus/var/pbs-acct/jobdn.log` (this may be useful to trace what information was sent to GOC).

# pbs.pm patch

The patch based on GRAM audit database is [pbs.pm-tag-dn-from-audit.diff](/wiki/download/attachments/3818228870/Pbs.pm-tag-dn-from-audit.diff.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2).

The old patch, based on certificates, is [pbs.pm-tag-dn-email-log-jobdn.diff](/wiki/download/attachments/3818228870/Pbs.pm-tag-dn-email-log-jobdn.diff.txt?version=1&modificationDate=1539354082000&cacheVersion=1&api=v2) 
