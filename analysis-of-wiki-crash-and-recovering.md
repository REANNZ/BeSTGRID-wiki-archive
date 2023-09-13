# Analysis of Wiki Crash and Recovering

ua

# Symptoms of possible crash

Though web site **www.bestgrid.org** was accessible and it was possible to edit Wiki content, nobody was able to login to Wiki VM neither by ssh nor trough XenCenter console. Thus it was impossible to perform any administrative actions of the VM. This problem has been encountered on **7th May**. There were several unsuccessful attempts to login to the VM. Then a preparation for scheduled restart of the VM had been planned. But suddenly at **10:49pm on 13th May** Nagios "Host DOWN alert" notification for the Wiki had been received.

A decision to reboot the Wiki VM in XenConsole has been admitted. 

Later, after checking logs and backups, another problem has been found: backup files haven't been copied to the DataStorage since **5th May**.

# Attempt to reboot the Wiki Server

BeSTGRID Wiki VM is resided on Xen Enterprise Server (pleyads.bestgrid.org) and XenCenter tool had been used to reboot the VM. First attempt to use plain reboot option of XenCenter wasn't successful. Progress bar of the rebooting process frozen at about 30%. Then an option "Force Reboot" had been activated.

During booting the VM stopped with the following messages on a console screen:

>  INIT: version 2.85 booting
>  INIT: PANIC: segmentation violation at 0x420! sleeping for 30 seconds.

No useful information had been found in the Internet using Google.

Xen's logical volume which was allocated for the Wiki VM had been mounted into Xen host filesystem. Thus it was possible to have full access to all files and folders of the dead VM.

# Recovering actions

## "Template" way

To recover the VM on first stage a "template" way had been chosen. In Xen Enterprise Environment there is a VM which was cloned and the clone was used as a recipient of Wiki's file system (earlier BeSTGRID Wiki was resided on one of servers of Math Department. The VM had been migrated to Xen by copying its filesystem). The same approach had been used: Wiki's files system replaced a filesystem of a new clone. 

No success was on this way. We tried to copy the whole filesystem of the dead VM and only /etc, /usr, /var folders but in both cases the new VM crashed on the same stage as original Wiki VM.

## Building new VM

Then we decided to build a new VM from scratches, install all appropriate components and copy Wiki's html folder and data from the dead VM. 

### Operation system

A new VM in Xen Enterprise Environment had been created and CentOS 4.6 had been installed in a Server configuration with Web Server and MySQL components. No special issue on this stage.

### Apache server

Apache server (httpd) is a standard part of server installation and no special actions had been performed.

### MySQL Server

During OS installation only MySQL client had been installed. Thus mysql-server, mysql-devel packages had been installed manually. 

### PHP with mysql support

On default php 4.3.9 is accessible for installation (yum). But MediaWiki requires php 5.0.0 and higher. The following command had been used to install php 5.1.6. 

>   yum install php --enablerepo=centosplus

php.386 and php-mysql had been installed.

## Wiki recovering

### Html structure

The whole html and php set of files has been recovered from the filesystem of the dead VM and copied to the new one. No troubles.

### Database

There were two sources of the wiki data: the latest backup dated 5th May and the wiki database from the dead VM. Initially the latest backup had been loaded into the database of the new Wiki. 

To recover data from the dead Wiki the whole mysql folder had been copied on wiki.test.bestgrid.org machine. A dump of the wiki database had been prepared by mysqldump. Then this dump had been loaded into the new wiki database. All data had been recovered. 

### Shibboleth

The simple copy of all shibb related directories to the new VM was unsuccessful. Thanks to Vladimir Mencl for installation and setting Shibboloeth on the new Wiki VM.

# Summary and analysis

Full crash of a VM requires a creation of new VM with installation all required software and backup recovering. In case of Wiki: Apache, PHP with MySQL support, MySQL, Shibboleth. 

Possible cause of the crash is installation of Opnet Capture Agent for monitoring network activities of a VM. The Capture Agent had been installed on 5th May at about 3pm. It didn't require a reboot. The latest record in the system log was just before installation. What exactly happened was unknown. But Wiki VM became unaccessible by ssh and in XenCenter console. The Capture Agent had been installed on 33 VMs more and no one had the similar problems. Thus its very unlikely that the Capture Agent was harmful itself but probably it interfered with one of installed component.

# Future Actions

1. Perform Xen's Export option to create copies of all VMs. In case of crash it allows to recover a VM with all software installed and just to load the latest data.
2. Prepare a cron script on the DataStorage to check a backup chain and to alarm if any backup file is missed.
3. Review backup scripts to be sure cron sends notification if something goes wrong.
