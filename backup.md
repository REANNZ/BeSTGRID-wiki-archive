# Backup

## The following machines require regular backup:

- BeSTGrid Wiki server
- Sakai Server
- Language Server
- some more

## Each of those machines are in BeSTGrid farm and must have following settings:

- System user backup:backup (98:98) with nopassword and nologin options


>  in /etc/passwd:  backup:x:98:98:Backup Operator:/var/backup:/sbin/nologin
>  in /etc/group:   backup:x:98:
>  in /etc/shadow:  backup:!!:13524:0:99999:7:::
>  in /etc/passwd:  backup:x:98:98:Backup Operator:/var/backup:/sbin/nologin
>  in /etc/group:   backup:x:98:
>  in /etc/shadow:  backup:!!:13524:0:99999:7:::

- Folder /var/backup with ownership for backup user


>  mkdir /var/backup
>  chown backup:backup /var/backup
>  **Script file .**/var/backup/backup.sh* to perform backup procedure in (i.e. on Sakai server. For other servers commands to create backup files and rotation/copy commands might be different)
> 1. Backup script by Andrey Kharuk
> 2. User backup:backup should exist on the farm
> 3. v0.1 24 April 2007
>  mkdir /var/backup
>  chown backup:backup /var/backup
>  **Script file .**/var/backup/backup.sh* to perform backup procedure in (i.e. on Sakai server. For other servers commands to create backup files and rotation/copy commands might be different)
> 1. Backup script by Andrey Kharuk
> 2. User backup:backup should exist on the farm
> 3. v0.1 24 April 2007

> 1. remove old local backup files
>  cd /var/backup
>  rm f sakai*

> 1. create new local backup files and change ownership
>  tar -czf sakai-www.tar.bz2 /opt/sakai
>  mysqldump -u root --password=**password** --single-transaction sakai > sakai-db.sql
>  chown backup:backup sakai*

> 1. mount remote backup storage
>  mount gateway.bestgrid.org:/var/backup/sakai /mnt

> 1. remove the oldest backup files
>  sudo -u backup rm -f /mnt/sakai-db-3.sql /mnt/sakai-www-3.tar.bz2

> 1. rotate backup files
>  sudo -u backup mv /mnt/sakai-db-2.sql /mnt/sakai-db-3.sql
>  sudo -u backup mv /mnt/sakai-db-1.sql /mnt/sakai-db-2.sql
>  sudo -u backup mv /mnt/sakai-www-2.tar.bz2 /mnt/sakai-www-3.tar.bz2
>  sudo -u backup mv /mnt/sakai-www-1.tar.bz2 /mnt/sakai-www-2.tar.bz2

> 1. copy local backup file to remote backup storage
>  sudo -u backup cp sakai-db.sql /mnt/sakai-db-1.sql
>  sudo -u backup cp sakai-www.tar.bz2 /mnt/sakai-www-1.tar.bz2

> 1. loggin
>  cp /mnt/backup-log .
>  sudo -u backup date >> backup-log
>  sudo u backup ls -l sakai* >> backup-log
>  sudo -u backup mv backup-log /mnt

>  umount /mnt

- Crontab file for root user:


>  SHELL=/bin/sh
>  MAILTO=root
>  0 2 * * * /var/backup/backup.sh
>  SHELL=/bin/sh
>  MAILTO=root
>  0 2 * * * /var/backup/backup.sh

## BeSTGrid Wiki Server configuration

Wiki Server has had **backup:backup** user:group and **/var/backups** folder. 

Wiki Server lives in 33 subnet but Backup Storage Server in 189 subnet. 189 subnet is untrusted one to 33. So it wasn't possible to mount NFS from 189 to 33 subnets. A request to open a hole for NFS access has been submitted to ITS and CS. CS opened a hole between those two machines. ITS stated that there aren't firewalls between subnets in their side. But it's still impossible to mount NFS volume from 189 to 33 subnets (on 1/05/2007). To finalize "Backup Task" a decision to use trusted ssh/scp between Wiki Server and Backup Storage Server has been adopted. The main difference is in backup script file **/var/backup/backup.sh**:

> 1. Backup script by Andrey Kharuk
> 2. User backup:backup should exist on the farm
> 3. v0.1 1 May 2007

> 1. remove old local backup files
>  cd /var/backups
>  rm f wiki*

> 1. create new local backup files and change ownership
>  tar -czf wiki-www.tar.bz2 /var/www/bestgrid
>  mysqldump -u root --single-transaction bestgrid > wiki-db.sql

> 1. remove the oldest backup files
>  ssh gateway.bestgrid.org rm -f /var/backup/wiki/wiki-db-3.sql /var/backup/wiki/wiki-www-3.tar.bz2

> 1. rotate backup files
>  ssh gateway.bestgrid.org mv /var/backup/wiki/wiki-db-2.sql /var/backup/wiki/wiki-db-3.sql
>  ssh gateway.bestgrid.org mv /var/backup/wiki/wiki-db-1.sql /var/backup/wiki/wiki-db-2.sql
>  ssh gateway.bestgrid.org mv /var/backup/wiki/wiki-www-2.tar.bz2 /var/backup/wiki/wiki-www-3.tar.bz2
>  ssh gateway.bestgrid.org mv /var/backup/wiki/wiki-www-1.tar.bz2 /var/backup/wiki/wiki-www-2.tar.bz2

> 1. copy local backup file to remote backup storage
>  scp wiki-db.sql gateway.bestgrid.org:/var/backup/wiki/wiki-db-1.sql
>  scp wiki-www.tar.bz2 gateway.bestgrid.org:/var/backup/wiki/wiki-www-1.tar.bz2

> 1. loggin
>  scp gateway.bestgrid.org:/var/backup/wiki/backup-log .

>  sudo -u backup date >> backup-log
>  sudo u backup ls -l wiki* >> backup-log

>  scp backup-log gateway.bestgrid.org:/var/backup/wiki/backup-log
>  ssh  gateway.bestgrid.org chown backup:backup /var/backup/wiki/*
>  rm -f backup-log

## Backup Storage Server configuration

Currently it's GateWay machine. All backup files are stored to other RAID (not RAID which has VMs' disks).

Later other machine will be used.

- System user backup:backup (98:98) with nopassword and nologin options


>  in /etc/passwd:  backup:x:98:98:Backup Operator:/var/backup:/sbin/nologin
>  in /etc/group:   backup:x:98:
>  in /etc/shadow:  backup:!!:13524:0:99999:7:::
>  in /etc/passwd:  backup:x:98:98:Backup Operator:/var/backup:/sbin/nologin
>  in /etc/group:   backup:x:98:
>  in /etc/shadow:  backup:!!:13524:0:99999:7:::

- Folder /var/backup with ownership for backup user and separate folder for each backed up server


>  mkdir /var/backup
>  mkdir /var/backup/sakai
>  chown -R backup:backup /var/backup
>  mkdir /var/backup
>  mkdir /var/backup/sakai
>  chown -R backup:backup /var/backup

- Export NFS folder


>  in /etc/exports: /var/backup/sakai sakai.bestgrid.org(rw,sync)
>  in /etc/exports: /var/backup/sakai sakai.bestgrid.org(rw,sync)

- Create dummy backup files


>  touch /var/backup/sakai/sakai-db-1.sql
>  touch /var/backup/sakai/sakai-db-2.sql 
>  touch /var/backup/sakai/sakai-db-3.sql
>  touch /var/backup/sakai/sakai-www-1.tar.bz2
>  touch /var/backup/sakai/sakai-www-2.tar.bz2
>  touch /var/backup/sakai/sakai-www-3.tar.bz2
>  touch /var/backup/sakai/backup-log
>  touch /var/backup/sakai/sakai-db-1.sql
>  touch /var/backup/sakai/sakai-db-2.sql 
>  touch /var/backup/sakai/sakai-db-3.sql
>  touch /var/backup/sakai/sakai-www-1.tar.bz2
>  touch /var/backup/sakai/sakai-www-2.tar.bz2
>  touch /var/backup/sakai/sakai-www-3.tar.bz2
>  touch /var/backup/sakai/backup-log

>  chown backup:backup *
