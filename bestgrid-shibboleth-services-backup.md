# BeSTGRID Shibboleth services backup

# Introduction

This article describes all backup procedures for BeSTGRID Shibboleth services. Please have a look [here](/wiki/spaces/BeSTGRID/pages/3816950982) for more details. At the time of writing, the services that requires to backup are mediawiki, wayf and idp. 

# Common backup procedures

NOTE: Please referred "service server" as the server that hosted BeSTGRID Shibboleth services, e.g. wayf, idp. The "backup server" is referred to the host that stored the backup data.

- Create a user account called backup with uid 98 at service server.

``` 
adduser backup -u 98
```

- Create SSH public key for backup user, don't enter password for it

``` 
su - backup
ssh-keygen -t rsa
```

- Copy the content of ~/.ssh/id_rsa.pub from service server and then paste them at ~/.ssh/authorized_keys in backup server

- Test it by ssh login from the service server to the backup server without password. e.g.

``` 
 ssh data.bestgrid.org:/data/grid/backup 
```

# Backup WAYF

- Backup the WAYF installation package (including ant build file, source code, BeSTGRID customizations). Only requires a single copy of backup after the installation

>  **Create a backup script to copy both BeSTGRID test and pilot metadata files to backup server by using*scp**. Appended the current date into the file name for archive. This backup script should be run by **backup** user.

``` 

#This is a script to backup bestgrid metadata
NOW=$(date +"%Y-%m-%d_%I-%M%P")

#Copy latest bestgrid metadata to /var/backup
rm -rf /var/backup/bestgrid-*
cp /var/www/html/metadata/bestgrid-test-metadata.xml /var/backup/
cp /var/www/html/metadata/bestgrid-metadata.xml /var/backup/
mv /var/backup/bestgrid-test-metadata.xml /var/backup/bestgrid-test-metadata.xml.$NOW
mv /var/backup/bestgrid-metadata.xml /var/backup/bestgrid-metadata.xml.$NOW
scp /var/backup/bestgrid-test-metadata.xml.$NOW data.bestgrid.org:/data/grid/backup/wayf/metadata
scp /var/backup/bestgrid-metadata.xml.$NOW data.bestgrid.org:/data/grid/backup/wayf/metadata

```

- Create a cron job to run it daily. We may adjust this in the future as changing of needs

``` 

30 3 * * * /var/backup/scripts/backupWayf.sh

```

# Backup OpenIdP

- Backup the OpenIdP registry web application and Shibboleth configurations after installation

>  **Create the following backup script as*root** user

 #Backup script for BeSTGRID OpenIdP

>  NOW=$(date +"%Y-%m-%d_%I-%M%P")

>  #Go to backup directory and create backup LDAP
>  cd /var/backup
>  rm -rf backup-bestgrid-idp.*
>  slapcat > backup-bestgrid-idp.$NOW.ldif
>  chown backup:backup /var/backup -R

- Create a cron job to run it periodically.

>  **Create the following backup script as*backup** user 
>  scp  /var/backup/backup-bestgrid-idp.* data.bestgrid.org:/data/grid/backup/idp/LDIF

- Create a cron job to run it periodically and after the backup script that run as root user.

# Backup Wiki

- Backup the Shibboleth configuration after it goes to live.

>  **create the following backup script as*backup** user

``` 

#This script is to backup new shibbolized mediawiki for bestgrid
NOW=$(date +"%Y-%m-%d_%I-%M%P")

rm -rf /var/backup/bestgrid-wiki-*
tar -cf  /var/backup/bestgrid-wiki-images.$NOW.tar /var/www/html/images
mysqldump -u root --single-transaction bestgrid >  /var/backup/bestgrid-wiki-.$NOW.sql

scp  /var/backup/bestgrid-wiki-images.$NOW.tar data.bestgrid.org:/data/grid/backup/wiki/shibbolethWiki
scp  /var/backup/bestgrid-wiki-.$NOW.sql data.bestgrid.org:/data/grid/backup/wiki/shibbolethWiki

```

- Create cron job to run it periodically. However, we have to discuss how often do we have to run it.
