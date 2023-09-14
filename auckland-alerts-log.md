# Auckland Alerts Log

# 05.01.2009, Nagios Alert, MediaWiki BeSTGRID problem

A message from Nagios:

>  Additional Info: WebInject CRITICAL - BeSTGRID IdP urn:mace:bestgrid.org:idp failed

Cause: Tomcat is down (thanks Yifan (Eric) Jiang)

Status: fixed by starting Tomcat. Syslog recorded "Low of memory" event and then system killed java:Tomcat process. Amount of memory increased up to 1GB. 

# 02.09.2008, BeSTGRID OpenIdP problem

Logging in to BeSTGRID Media Wiki was impossible via BesTGRID OpenIdP Provider 

Cause: a host certificate of idp.bestgrid.org is expired.

Status: fixed by replacing the expired certificate for fresh one.

[Technical details](/wiki/spaces/BeSTGRID/pages/3818228627)

# Friday, 22nd August from 7pm

First full backup is scheduled on this Friday, 22nd August from 7pm and very likely will be lasting over this weekend.

To have all your files backed up we would suggest you do not have access to them. That doesn’t mean that they will be inaccessible. But if a file is open it won’t be backed up. Though such file will be backed up later during an incremental backup procedure but it would be better to have all files backed up during this first full backup.

All BeSTGRID Auckland supported DATA services will be affected during this period. 

Following is a complete list of these services: 

- New Zealand Biomirror
- New Zealand Social Sciences Data Service
- Austronesian Basic Vocabulary and Bantu Language Databases
- Ocean Biogeographic Information System (OBIS)
- Ecology and Animal Behaviour
- Human Immunology
- Genomics
- NZ NEES @ Auckland
- Bio-engineering’s SRS Service
- Passive DNS Project in ITS
- Quantum Optics
- The Polyhedrin Project
- Statistics
- SBSBS-LDAP Service
- NDSG services - Gridsphere, R solver
- BeSTGRID Services NG2, NGData
- BeSTGRID FTP Server

All BeSTGRID Auckland supported Network services won't be affected during this period. 
