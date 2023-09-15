# Audit Database

Data provided by enabling [globus audit](http://www.globus.org/toolkit/docs/4.0/execution/wsgram/WS_GRAM_Audit_Logging.html) is already used in [Grid Operations Center](http://status.arcs.org.au/). 

But having this data locally gives us the ability to perform various queries to analyse performance of the cluster, create usage reports and identify potential problems. Of course, it would be even better to have this functionality in status.arcs directly...

# Collecting data from globus 

original auditquery script deletes data form gram_audit_table after sending it to status.arcs

Just retaining this data is not good because the size of data sent is only going to increase. Therefore we create backup_gram_audit_table and modify auditquery to move data into it before deleting:

>  CREATE TABLE `backup_gram_audit_table` (
>   `job_grid_id` text NOT NULL,
>   `local_job_id` text,
>   `subject_name` text NOT NULL,
>   `username` varchar(16) NOT NULL default *,*

*`idempotence_id` varchar(128) default NULL,*

*`creation_time` varchar(40) NOT NULL default*,

>   `queued_time` varchar(40) default NULL,
>   `stage_in_grid_id` text,
>   `stage_out_grid_id` text,
>   `clean_up_grid_id` text,
>   `globus_toolkit_version` varchar(16) NOT NULL default *,*

*`resource_manager_type` varchar(16) NOT NULL default*,

>   `job_description` text NOT NULL,
>   `success_flag` varchar(5) NOT NULL default *,*

*`finished_flag` varchar(5) NOT NULL default*,

>   PRIMARY KEY  (`job_grid_id`(256)),
>   KEY `idxLocalJobId` (`local_job_id`(50))
>  )

example auditquery (because mysql audit database is also password-protected, I removed read permission from this script).

``` 

 #!/bin/sh
 # auditquery    Queries the VDT Globus-WS Audit database and emails
 #               Job-Id/DN records to a monitoring address. Records
 #               are also logged via syslog, then dropped from the
 #               database. Intended for invocation at hourly intervals.
 #               Graham Jenkins <grahjenk@vpac.org> Last changed: 20061220
 #
 # Specify PATH, initiallise scratch-file
 PATH=/usr/bin:/bin:/usr/sbin:/usr/sbin:/sbin:$PATH
 . /etc/profile >/dev/null 2>&1
 File=/tmp/`basename $0`.$$
 trap 'rm -f $File; exit 0' 0 1 2 3 14 15
 echo "use auditDatabase;" >$File
 #
 # Read and log records, create delete statements and send email
 mysql -u grid-mysql --port 3306 -h mysql-bg.ceres.auckland.ac.nz -p***** <<EOF 2>/dev/null | sed -n '2,$p' |
 use ng2_auditDatabase;
 select concat_ws(' ',local_job_id, subject_name)
 from gram_audit_table;
 EOF
 while read Line; do
   logger -t Job-DN "$Line"
   echo     "Job-DN: $Line"
   JobId="`echo $Line | awk '{print $1}'`"
   echo "insert into backup_gram_audit_table select * from gram_audit_table where local_job_id = '$JobId';" >> $File
   echo "delete from  gram_audit_table " >>$File
   echo "where local_job_id = '$JobId';">>$File
 #done | /bin/mail -s "`hostname` JobID `date +%Y%m%d`" a.kharuk@auckland.ac.nz >/dev/null 2>&1
 done | /bin/mail -c a.kharuk@auckland.ac.nz -s "`hostname` JobID `date +%Y%m%d`" grid_pulse@lists.arcs.org.au >/dev/null 2>&1
 #
 # Perform deletions
 ( cat $File
   echo "delete from  gram_audit_table "
   echo "where local_job_id is NULL;" ) | mysql -u grid-mysql --port 3306 -h mysql-bg.ceres.auckland.ac.nz -p***** ng2_auditDatabase >/dev/null 2>&1
 exit 0

```

# Collecting data from torque 

This section is specific to torque resource manager. Resources with other RMS will need different scripts.

We need some extra tables:

>  CREATE TABLE `pbs` (
>   `local_job_id` text NOT NULL,
>    `queued_time` varchar(40) NOT NULL default *,*

*`start_time` varchar(40) NOT NULL default*,

>    `end_time` varchar(40) NOT NULL default '',
>    `cpu_count` int(11) default NULL,
>    `queue` text,
>    PRIMARY KEY  (`local_job_id`(256)),
>    KEY `idxLocalJobId` (`local_job_id`(50))
>  ); 

 CREATE TABLE `exit_status` (

>    `local_job_id` varchar(256) NOT NULL,
>    `exit_status` int(11) NOT NULL,
>    PRIMARY KEY  (`local_job_id`)
>  );

This is ftp.bestgrid.org/pub/torque2mysql.py sample python script to convert torque logs into SQL. It can be used as 

>  cat /opt/torque/server_priv/accounting/**|python torque2mysql.py |mysql -h mysql-bg.ceres.auckland.ac.nz --port=3306 -u grid-mysql -p***** ng2_auditDatabase

to populate our tables. Duplicate entries are ignored so it is ok to run with old data. A bit slow with all logs, so may be worthwhile to run only with latest logs.  

# Example Queries

## Usage for individual users over the last N days (example for 7 days)

>  select subject_name,
>         count⭐ as count,
>         sum((unix_timestamp(str_to_date(pbs.end_time,"%a %b %d %H:%i:%s %Y"))- 
>           unix_timestamp(str_to_date(pbs.start_time,"%a %b %d %H:%i:%s %Y")))* pbs.cpu_count) / 60.0 / 60.0 as dif 
>  from backup_gram_audit_table,pbs 
>  where  pbs.local_job_id = backup_gram_audit_table.local_job_id and 
>         backup_gram_audit_table.subject_name LIKE '%' and  
>         str_to_date(pbs.end_time,"%a %b %d %H:%i:%s %Y") > subdate(now(), interval 7 day) 
>  group by subject_name order by dif;

|  subject_name                                                                             |   count |  dif            |
| ----------------------------------------------------------------------------------------- | ------- | --------------- |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Yuriy Halytskyy                        |     10  |     0.00000000  |
|  /C=AU/O=APACGrid/OU=VPAC/CN=Markus Binsteiner                                            |     54  |     0.00027778  |
|  /DC=au/DC=org/DC=arcs/DC=slcs/O=ARCS IdP/CN=Antoine Fouquet cpTxacQy-chYzfVDjjuAEWLyriM  |      1  |    65.70916667  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Peter Shao-Wei Tsai                    |     10  |   114.40944444  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Jack Flanagan                          |     11  |   152.33694444  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Peter Wills                            |      2  |   161.89111111  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Sidney Markowitz                       |    331  |   205.25861111  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Steven Wu                              |    115  |   287.16194444  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Asad Ali                               |     69  |   451.54666667  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Brian Browning                         |      8  |   497.19055556  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Joseph Heled                           |   1600  |   534.40166667  |
|  /C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Sharon Browning                        |    537  |  1473.76027778  |

## Log last jobs from individual user

Example over the last 7 days

>  select substr(subject_name, instr(subject_name,'CN=') + 3) as name,
>         pbs.local_job_id,
>         idempotence_id,
>         pbs.queued_time as queued,
>         (unix_timestamp(str_to_date(pbs.end_time,"%a %b %d %H:%i:%s %Y")) - 
>          unix_timestamp(str_to_date(pbs.queued_time,"%a %b %d %H:%i:%s %Y"))) / 60.0 / 60.0 as total,
>         (unix_timestamp(str_to_date(pbs.end_time,"%a %b %d %H:%i:%s %Y")) - 
>          unix_timestamp(str_to_date(pbs.start_time,"%a %b %d %H:%i:%s %Y"))) / 60.0 / 60.0 as run,
>         exit_status 
>  from backup_gram_audit_table,pbs,exit_status 
>  where subject_name LIKE '%Brian Browning%' and 
>       str_to_date(pbs.queued_time,"%a %b %d %H:%i:%s %Y") >  
>        subdate(now(), interval 7 day) and 
>       backup_gram_audit_table.local_job_id LIKE '%.hpc-bestgrid.auckland.ac.nz%' and 
>       pbs.local_job_id = backup_gram_audit_table.local_job_id and 
>       pbs.local_job_id = exit_status.local_job_id  
>  order by str_to_date(backup_gram_audit_table.queued_time,"%Y-%m-%d %H:%i:%s %Y");

|  name            |  local_job_id                        |  idempotence_id                        |  queued                    |  total        |  run          |  exit_status  |
| ---------------- | ------------------------------------ | -------------------------------------- | -------------------------- | ------------- | ------------- | ------------- |

|  Brian Browning  |  101526.hpc-bestgrid.auckland.ac.nz  |  a4d427fa-7b04-11de-90b4-e2e160fc8bd9  |  Tue Jul 28 11:24:37 2009  |  24.01000000  |  18.49138889  |          271  |
| ---------------- | ------------------------------------ | -------------------------------------- | -------------------------- | ------------- | ------------- | ------------- |
|  Brian Browning  |  101527.hpc-bestgrid.auckland.ac.nz  |  a8b212ba-7b04-11de-a4f3-e2e160fc8bd9  |  Tue Jul 28 11:24:43 2009  |  24.01027778  |  18.46694444  |          271  |
|  Brian Browning  |  102814.hpc-bestgrid.auckland.ac.nz  |  d928de24-7cad-11de-bc0f-e2e160fc8bd9  |  Thu Jul 30 14:08:21 2009  |  24.00166667  |  24.00138889  |          271  |
|  Brian Browning  |  102815.hpc-bestgrid.auckland.ac.nz  |  dd9200da-7cad-11de-a111-e2e160fc8bd9  |  Thu Jul 30 14:08:29 2009  |  24.01888889  |  24.01861111  |          271  |
|  Brian Browning  |  102816.hpc-bestgrid.auckland.ac.nz  |  df649f58-7cad-11de-9848-e2e160fc8bd9  |  Thu Jul 30 14:08:31 2009  |  24.02000000  |  24.01972222  |          271  |
|  Brian Browning  |  103973.hpc-bestgrid.auckland.ac.nz  |  eb43ec7e-7e39-11de-8548-e2e160fc8bd9  |  Sat Aug  1 13:23:32 2009  |  24.07500000  |   0.00138889  |          271  |
