# Backup procedure

# 7 days Backup of NZSSDS data

## Software:

Windows Server Backup Utility has been used to make backups.

## Backup pattern:

- Sunday, 2am - Full Backup of NZSSDS Server
	
- C:\Nesstar-Server-3.50\
- Sunday-Saturday, 2am - Incremental Data Backup (backing up only updated files from previous backup)
	
- C:\Nesstar-Server-3.50\data
- C:\Nesstar-Server-3.50\mysql\data

## Storage:

>  **All backup files reside on the BeSTGRID DataStorage Server in**/data/ssdash/Backup* folder

- This folder is mounted as Samba share on NZSSDS Server as Y:\Backup disk

## Problem:

MS Windows disconnects mounted network disks after 15 minutes inactivity. If scheduled backup job starts when network drive is disconnected then job doesn't run at all. To fix that problem a script runs every day at 1am (before any backup job starts) to reconnect network drive to the server. This script resides in **C:\Documents and Settings\Administrator\My Documents\wakeup.bat** file:

>  net use y: /delete
>  net use y: \\data.bestgrid.org\ssdash

**It didn't help to solve the problem**

## Solution:

Backup Utility stores all backup files in C:/Backup on the local hard drive.

Example of a backup command for Monday's backup at 2am:

``` 

C:\WINDOWS\system32\ntbackup.exe backup \
   "@C:\Documents and Settings\Administrator\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data\Monday's Inc Backup.bks" \
   /n "Day1-Inc.bkf created 4/10/2007 at 1:29 PM" /d "Set created 4/10/2007 at 1:29 PM" \
   /v:yes /r:no /rs:no /hc:off /m incremental /j "Monday's Inc Backup" /l:s /f "C:\Backup\1-Monday.bkf"

```

Commands for other days are similar.

Then at 3am the server runs a script which copies all backup files to the DataStorage and makes a log:

``` 

date /T >> log.txt
time /T >> log.txt
net use y: /delete >> log.txt
net use y: \\data.bestgrid.org\ssdash >> log.txt
echo "Copying backup files to Samba drive" >> log.txt
copy /V /Y c:\backup\*.* y:\backup >> log.txt
echo "==================================================" >> log.txt

```

**Now backup files are created without problems.**
