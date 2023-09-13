# Setup Anonymous FTP on NGData at University of Canterbury

This page documents the setup of an anonymous FTP with upload enabled on NGData.  The setup is more complicated than otherwise necessary, as the data directory was shared over NFS, and the NFS client used did not pass the effective user ID to the server.  Consequently, as the **chown** operation was failing due to an permission error, we could not use the setup where all uploaded files would be made owned by another user, and we instead make the FTP server do a **chmod** operation on all uploaded files, making them unreadable until an administrator attends to them.

# Basic OS install

- Install CentOS 5.  Install VSFTPD

``` 
yum install vsftpd
```

# Create user accounts

VSFTPD will map anonymous users to `anonftp`.  Uploaded files are intended to be owned by `anonfile`.

>  groupadd -g 1072 ftpusers
>  adduser -u 95041 -g 1072 anonftp # home /upload
>  adduser -u 95042 -g 1072 anonfile

# Setup NFS share

Files should be uploaded into /hpc/griddata/ftp/upload

- Export that filesystem from hpcgrid-1 via NFS: put this line into `/etc/exports`

``` 
/hpc/griddata -access=ng2hpc-c:ng2hpcdev-c:ngdata-c,root=ngdata-c
```

# Setup VSFTPD

Edit the configuration in `/etc/vsftpd/vsftpd.conf` the following way:

- Change


>  local_enable=NO #(no local logins, just anon)
>  local_enable=NO #(no local logins, just anon)

- Add


>  anon_upload_enable=YES
>  anon_mkdir_write_enable=YES
>  anon_umask=022
>  file_open_mode=000
>  ftp_username=anonftp
>  anon_root=/hpc/griddata/ftp
>  ftpd_banner=Welcome to BlueFern anonymous FTP site
>  xferlog_std_format=NO
>  anon_upload_enable=YES
>  anon_mkdir_write_enable=YES
>  anon_umask=022
>  file_open_mode=000
>  ftp_username=anonftp
>  anon_root=/hpc/griddata/ftp
>  ftpd_banner=Welcome to BlueFern anonymous FTP site
>  xferlog_std_format=NO

- Comment out


>  xferlog_std_format=YES
>  xferlog_std_format=YES

- Keep


>  anonymous_enable=YES
>  xferlog_enable=YES
>  listen=YES
>  write_enable=YES
>  anon_world_readable_only
>  anon_other_write_enable=NO #(rename/delete)
>  anonymous_enable=YES
>  xferlog_enable=YES
>  listen=YES
>  write_enable=YES
>  anon_world_readable_only
>  anon_other_write_enable=NO #(rename/delete)

- Optional Directives for alternative configuration (file ownership changed to anonfile on upload)


>  chown_uploads=YES
>  chown_username=anonfile
>  anon_umask=077
>  chown_uploads=YES
>  chown_username=anonfile
>  anon_umask=077

# Enable and start the server

>  chkconfig vsftpd on
>  service vsftpd start
