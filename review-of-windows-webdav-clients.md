# Review of Windows webDAV clients

# Introduction

There are four webDAV clients recommended by BeSTGRID for Windows, not including using a web browser, and it may cause Data Fabric users some confusion about which client would be most suitable. Each of these clients have their merits, and their flaws. This article intends to collect details where these clients work well, and more importantly, where they fail.

If you have comments you wish to add to this article, you can log into the BeSTGRID wiki using your institute's Identity Provider service via NZFed. BeSTGRID would really appreciate your feedback on these clients.

# The Standard Clients

These are the clients that are already installed in Windows. They provide a basic level of access to the BeSTGRID Data Fabric, and will meet most users needs. These clients do have limitations, in particular they do not handle large (>2GB) files.

# Web interface

# Windows XP default webDAV client

# The Alternative Clients

NetDrive and WebDrive are incompatible, both clients can not be installed at the same time.

# NetDrive

# WebDrive

[WebDrive](http://www.webdrive.com/) is a commercial product, but it can be installed on a free 20 day trial. The commercial product costs around USD85 for the current version plus 1 year of updates. There are discounts for bulk licenses, and for increasing the update period.

Overall WebDrive is a a good product that integrates well in your windows environment. WebDrive uses a on-disc cache to speed up data transactions between the local workstation and the remote webDAV site. Configuring this cache is very important to WebDrive's performance and reliability, see [below](#ReviewofWindowswebDAVclients-WebDriveConfigurationNotes). WebDrive caching does not truely speed up data transfer, it copies files to the cache and uses this cache to do the data transfer process in the background, this can lead to mistakenly believing that a data transfer process, particularly the uploading of large files, has completed. When in reality the process is still working in the background, and may be interrupted by logging off or shutting down the workstation.

WebDrive automatically retries uploading files up to 5 times if they are interrupted or fail, unless the cache is cleared by either logging off or shutting down.

## WebDrive Configuration Notes

WebDrive uses an on-disk cache to buffer data transfers. Normally this cache is set to a folder in your Windows profile. If your profile is on a network drive, has limited space, or has a space quota, it is recommended that this cache moved to a temporary folder on a local hard drive that does not have such restrictions. e.g. D:/temp/

The WebDrive cache should be large enough to hold the files you wish to upload.

WebDrive does not automatically detect HTTP proxy settings, and they have to be configured manually.

# BitKinex

# Client comparison table


***Mount as drive:** this client allows you to mount the data fabric as a drive and assign it a drive letter

***Handles large (>2GB) files:** This client has no issues dealing with files larger than 2 Gigabytes

***Handles special characters:** This client handles all UTF-8 characters, some clients will not handle 

``` 
/ \ : * " < >
```

 | in file or directory names

***Drag'n'drop:** Files can be dragged and dropped to and from the Windows Explorer interface to transfer files

***Transfer multiple files:** Multiple files can be selected using shift-click and ctrl-click for transfer

***Transfer directories:** Whole directories can be selected for transfer

***Free:** This client can be used at no cost

***Open Souce:** The source code for this client is publicly available and contribution is welcomed

# Summary

BeSTGRID recommends:

- using the web interface for casual users
- using the Windows default client or one of the alternative clients for multiple file transfers
- using WebDrive or NetDrive to mount the data fabric as a Windows drive or the Windows default to mount the data fabric as a Network Place
- using BitKinex for power users, for transferring large files, or to troubleshoot data fabric issues
