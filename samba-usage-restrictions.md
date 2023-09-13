# SAMBA usage restrictions

One of the clients for Samba is the Windows family, therefore Samba has to support these requirements:

- In the Windows API, the maximum length for a path is MAX_PATH, which is defined as 260 characters [http://msdn2.microsoft.com/en-us/library/aa365247.aspx](http://msdn2.microsoft.com/en-us/library/aa365247.aspx)
- Files should not have illegal characters (? - question mark) in their names [http://www.portfoliofaq.com/pfaq/FAQ00352.htm](http://www.portfoliofaq.com/pfaq/FAQ00352.htm)

For access to a Samba / SMB server, the following ports are required to be open outbound from the institution accessing the storage, and inbound to the institution hosting the storage:

>  Port 135/TCP - used by smbd
>  Port 137/UDP - used by nmbd
>  Port 138/UDP - used by nmbd
>  Port 139/TCP - used by smbd
>  Port 445/TCP - used by smb
