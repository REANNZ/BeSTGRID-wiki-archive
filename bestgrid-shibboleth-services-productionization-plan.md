# BeSTGRID Shibboleth services productionization plan

# Issues

- confirm all web apps are running on new production Xen server
- check all external access in place for all web apps
- finalise LDAP import
- finalise certificates
- check backups complete
- add monitoring
	
- http tests - [http://www.webinject.org/](http://www.webinject.org/) with Nagios and MRTG) to each web application
- disk space, CPU, Network, ports open - Nagios
- JIRA email can come later

# Introduction

This is a [working plan for productionizing BeSTGRID Shibboleth services](http://support.csi.ac.nz:8080/browse/BG-120) and it covers from new servers setup, existing services migration, communication and system backup. The plan can be divided into several sections due to the different natures of each service. A working plan diagram has cut down to several pieces and attached [below](#BeSTGRIDShibbolethservicesproductionizationplan-Workingplandiagrams).

# [BeSTGRID Federation Metadata Central Repository](http://support.csi.ac.nz:8080/browse/BG-121)

This metadata central repository is to store the latest Shibboleth SAML metadata for all BeSTGRID Shibboleth related services.

(I am not sure where are we going to locate this metadata repository, should we place it at a separate VM or locate in some services below, for example WAYF. Please make some comment on that)  

- External Access

(Submit the following firewall rules change to ITS)
- Allows inbound and outbound access for HTTP, HTTPS and FTP (some users may be preferred to download by FTP).

;Backup procedure

- Create a cron job to submit the latest copy of the metadata to backup server.

# [BeSTGRID OpenIdP|http

//support.csi.ac.nz:8080/browse/BG-122]

- System Requirements

Disk Space: 4~5 GigaBytes

***Plan***

1. Install OpenIdP - [Installation procedure](/wiki/spaces/BeSTGRID/pages/3818228882)
2. Confirm External Access (Submit the following firewall rules change to ITS)
	
- Allows inbound and outbound access for HTTP and HTTPS
- Allows outbound access for FTP (Not quite sure if we need that)
- Allows inbound access for port 8443 (TCP)
3. Setup Backup procedure
	
- Setup backup server for OpenIdP
- Create a PHP script to import user information from the LDAP directory to a LDIF file.
- Setup a cron job to run above script daily.
- Transfer the LDIF backup files to OpenIdP backup servers daily.
- Backup the Shibboleth IdP configuration files (e.g idp.xml, resolver.ldap.xml, arp.xml)
4. Communicate Change
	
- Communication Plan: Notify user with the new created password and recommend users to update their passwords in OpenIdP registry. (I think we could do this one a day or two before shibbolizing BeSTGRID wiki.)

# [BeSTGRID WAYF](http://support.csi.ac.nz:8080/browse/BG-121)

(It could be the place to stores BeSTGRID Shibboleth metadata)

- Installation procedure
- Create SSL certificate request for wayf.bestgrid.org and submit to CA by Grix
- Setup a new VM with CentOS 4.4 installed
- Submit request to ITS to register DNS name wayf.bestgrid.org for the new setup VM.
- Install Java
- Install Apache Tomcat
- Download BeSTGRID Shibboleth metadata from metadata repository
- Install Shibboleth WAYF with BeSTGRID skin

;System Requirements

- Disk Space

4 GigaBytes

- External Access

(ubmit the following firewall rules change to ITS)
- Allows inbound and outbound access for FTP, HTTP and HTTPS

;Backup procedure

- Backup the Shibboleth WAYF configuration files and BeSTGRID Skin

# [BeSTGRID Wiki|http

//support.csi.ac.nz:8080/browse/BG-123]

;Installation procedure

- Create SSL certificate request for wiki.bestgrid.org and submit to CA by Grix
- Create SSL certificate request for www.bestgrid.org to AAF level 2 CA
- Setup two new VMs with CentOS 4.4 installed
- Submit DNS name wiki.bestgrid.org change request to ITS
- Install Java
- Install Apache Tomcat
- Install PHP 5.1
- Install MySQL 5.0
- Install Mediawiki
- Copy all skins, images, extension and LocalSetting.php to the new server.
- Download BeSTGRID Shibboleth metadata from metadata repository
- Download AAF Level 2 metadata
- Install Shibboleth Service Provider

;[Deployment procedure](/wiki/spaces/BeSTGRID/pages/3818228587)

- Create a staging server.
- Create a database deployment script to process the following actions:

1. Create a MySQL dump for the current BeSTGRID wiki

2. Transfer (scp) the SQL dump to staging server

3. Deploy the dump into a database instance in staging server

4. Trigger the update.php script (usually maintenance/update.php) to upgrade the database schema from Mediawiki 1.6 to 1.10

5. Create another MySQL dump for the Mediawiki 1.10 database instance.

6. Transfer (scp) the SQL dump to new server (wiki.bestgrid.org or www.bestgrid.org in the future).

7. Deploy the dump into the new production wiki database;

8. Run a PHP script to automatically update the user name from "username" to "username@scope". For example: yjia032 to yjia032@bestgrid.org.
- Create a cron job in staging server to run this script regularly until the release of production of BeSTGRID Shibbolized wiki.

(Setup a server that has similar environment as current BeSTGRID Wiki, and then practice the changes between the simulated environment and wiki.bestgrid.org few times before the real production deployment process) 

- Communication plan
- Post a note in front page of www.bestgrid.org to notify user the coming upgrade.

;System requirements

- Disk Space

6~7 GigaBytes

- External Access
- Allows all inbound and outbound FTP, HTTP and HTTPS access

;Backup procedure

- Setup a backup server.
- Backup the Shibboleth SP configuration (e.g. shibboleth.xml)
- Backup the BeSTGRID Wiki skin, images and extensions.
- Create a backup script to perform the following tasks

1. Create an MySQL dump daily at mid-night.

2. Transfer the MySQL dump to the backup server.

3. Backup the BeSTGRID Wiki images weekly (or monthly?).

# BeSTGRID VRE

;Installation procedure

- Create SSL certificate request for vre.bestgrid.org and submit to CA by Grix
- Setup a new VM with CentOS 4.4 installed
- Submit request to ITS to register DNS name vre.bestgrid.org for the new setup VM.
- Create an alias DNS (or C name?) sakai.bestgrid.org for this server.
- Install Java
- Install Apache Tomcat
- Install Maven1.0
- Install MySQL 5.0
- Install Sakai2.4
- Copy BeSTGRID Sakai skin, images, to the new server.

;Deployment procedure

Similar as above [BeSTGRID Wiki](#BeSTGRIDShibbolethservicesproductionizationplan-BeSTGRIDWiki) deployment procedure since they are all using MySQL database.

;System requirements

- Disk Space

8+ GigaBytes
- RAM: 2+ GigaBytes (for production)

;Backup procedure

Similar as above [BeSTGRID Wiki](#BeSTGRIDShibbolethservicesproductionizationplan-BeSTGRIDWiki) backup procedure

# Working plan diagrams




