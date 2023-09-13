# DataFabric Improvements

This page outlines suggested improvements to the BeSTGRID DataFabric.  Some are ideas that have already been used by ARCS, some are ideas coming locally from within the BeSTGRID community.  This page can also be seen as a wish-list maintained by the BeSTGRID operators.  And in particular, it's a list of things that Vladimir Mencl has had on his TODO-list for a long time.

# Rule-based file replication

So far, we are doing replication through a shell script that periodically scans the iCAT for files that need replication (i.e., have only one fresh replica).  And the shell script for example cannot handle files that have back-slashes in their name.

ARCS have developed an alternative implementation (in Python) that:

1. reliably replicates files that are missing replicas
2. reliably replicates files as soon as the file is uploaded (via a rule)

Use `replicate.py` and `replicateBacklog.py` from [http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/utils/](http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/utils/)

Put the following into `bestgrid.irb` to activate the scripts:

``` 

#Replication Rules
acPostProcForPut||delayExec(<PLUSET>30s</PLUSET>,msiExecCmd(replicate.py,$dataId,null,null,null,*REPLI_OUT),nop)|nop
acPostProcForCopy||delayExec(<PLUSET>30s</PLUSET>,msiExecCmd(replicate.py,$dataId,null,null,null,*REPLI_OUT),nop)|nop

```

Additional documentation:

- [http://wiki.arcs.org.au/foswiki/bin//view/Main/ChangeNote201012-002](http://wiki.arcs.org.au/foswiki/bin//view/Main/ChangeNote201012-002)
- [http://wiki.arcs.org.au/foswiki/bin//view/Main/ChangeNote201012-004](http://wiki.arcs.org.au/foswiki/bin//view/Main/ChangeNote201012-004)

# Proper iCAT backups

Instead of just doing periodic iCAT backups (a full SQL dump stored offsite), we should be using Postgres support for archiving Write-Ahead-Log (WAL) files offsite.

Instructions at [http://wiki.arcs.org.au/foswiki/bin//view/Main/ChangeNote201003-003](http://wiki.arcs.org.au/foswiki/bin//view/Main/ChangeNote201003-003)

Additional information:

``` 

Make sure you have enabled WAL archiving on postgres as below, to make IcatBackup.sh script to work.

    * archive_mode = on
    * archive_command = 'ssh arcs-df.ac3.edu.au test ! -f /data/DataFabric_Backups/Current_Wal_Archives/%f && rsync -az %p arcs-df.ac3.edu.au:/data/DataFabric_Backups/Current_Wal_Archives/%f'
    * checkpoint_timeout = 1h
    * archive_timeout = 12h

IcatBackup.sh, this script will take backup of whole database cluster
pgdump.sh is basic pg_dump backup script
Let me know If you need any further information.

```

Additional links:

- [https://projects.arcs.org.au/trac/systems/wiki/DataServices/RestoreDatabase](https://projects.arcs.org.au/trac/systems/wiki/DataServices/RestoreDatabase)
- [https://projects.arcs.org.au/trac/systems/wiki/DataServices/Postgres](https://projects.arcs.org.au/trac/systems/wiki/DataServices/Postgres)
- [http://wiki.arcs.org.au/bin/view/Main/ChangeNote201003-003](http://wiki.arcs.org.au/bin/view/Main/ChangeNote201003-003) (backup scripts are attached here)
- [http://wiki.arcs.org.au/foswiki/bin/view/Main/ChangeNote200907-011](http://wiki.arcs.org.au/foswiki/bin/view/Main/ChangeNote200907-011) (another take on copying WAL files off-site)
- Postgres database backups: [http://www.network-theory.co.uk/docs/postgresql/vol3/MakingaBaseBackup.html](http://www.network-theory.co.uk/docs/postgresql/vol3/MakingaBaseBackup.html)

# iCAT streaming replication

Postgres9 supports synchronous mode - implement this and deploy slave database servers at other sites.  iRODS would be using the local database replica for read-only operations.

- Postgres documentation: [http://wiki.postgresql.org/wiki/Streaming_Replication](http://wiki.postgresql.org/wiki/Streaming_Replication)
- ARCS ChangeNote (upgrade to Postgres9): [http://wiki.arcs.org.au/foswiki/bin/view/Main/ChangeNote201104-002](http://wiki.arcs.org.au/foswiki/bin/view/Main/ChangeNote201104-002)
- ARCS page on Postgres database service: [https://projects.arcs.org.au/trac/systems/wiki/DataServices/Postgres](https://projects.arcs.org.au/trac/systems/wiki/DataServices/Postgres)

# iRODS Resource monitoring

- iRODS can monitor whether a resource server is available and automatically mark the resource as down (avoiding timeouts in accessing the server).

- Description at: [https://www.irods.org/index.php/Resource_Monitoring_System](https://www.irods.org/index.php/Resource_Monitoring_System)
- Script at: [http://projects.arcs.org.au/trac/systems/browser/trunk/dataFabricScripts/iRODS/utils/rsmond.sh](http://projects.arcs.org.au/trac/systems/browser/trunk/dataFabricScripts/iRODS/utils/rsmond.sh)
	
- Automatically skip off-line resources for read and write operations
- See also `iadmin help modresc`

# Nagios monitoring of DataFabric services

- Monitor Griffin (GridFTP interface to the DataFabric) with [http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/BulkDataTransfer/check_gridftp.sh](http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/BulkDataTransfer/check_gridftp.sh) (TCP connect, check response)
- Monitor Davis with [http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/utils/check_davis.sh](http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/utils/check_davis.sh) (fetching a world readable file)

# WebDAV over Shibboleth

Experiment with setting up IdP-specific URLs at the ShibSP for webDAV over Shibboleth: see [https://wiki.shibboleth.net/confluence/display/SHIB2/WebDAV](https://wiki.shibboleth.net/confluence/display/SHIB2/WebDAV)

# BeSTGRID frontpage

- Additional features for the HTML frontpage at [http://df.bestgrid.org/](http://df.bestgrid.org/)
	
- Instead of giving links just to the closest server (GeoIP), give also links to all other servers available (test first at gridgwtest.canterbury.ac.nz)
