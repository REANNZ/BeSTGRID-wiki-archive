# IoSCC KMBs iRODS Notes

A page to host the WIP dynamic content of an iRODS install, ahead of

anything reasonably static, and hence actually being of use to anyone,

being placed within the BeSTGRID web presence that most casual

enquirers should find.

If you are reading this, please do not use what it says as a basis

for anything BeSTGRID related: it WILL change !

# WIP: For Demonstration Purposes Only: Do not use 

This is effectively a template of an iRODS install page that seeks to

use the common information from existing pages detailing the setting

up of an NG2 and an NGGUMS server as part of BeSTGRID's gateway 

infrastructure.

Initially there'll be little iRODS specific stuff here but the 

underlying parts of the install will be visible.

It should also serve to tease out the commonalities across the

various individual gateway component install instructions.  

# Top of the actual stuff

This stuff is based on an [ARCS iRODS Server installtion guide](http://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS_Server)

although note that that is currently out-of-date with respect to the information found in the [iRODS installtion guide](https://www.irods.org/index.php/Installation)

# Prequisites

## OS requirements

This guide assumes the system where the iRODS server will be installed has already been configured.

The following is recommended:

- Some Hardware requirements
	
- CPU
- Memory
- HDD

- OS: Linux CentOS 5 (or RHEL 5).  Other Linux distributions (or other operating systems) may work, please check the [VDT system requirements](http://vdt.cs.wisc.edu/releases/2.0.0/requirements.html).
	
- Are both  i386 (32-bit) and x86_64 (64-bit) distributions supported ?

- Hostname: is there a  recommended hostname?
	
- Vlad had suggested that ARCS were now using `ngdata` for data-specfic services.

- Software
- **Some software will need to be built from source, so a generic development environment will be required during the installtion, along with some specific packages (*Note**: the ARCS script does not specify `openssl-devel` ?)
	
- 
- compat-libstdc++-33
- openssl-devel

- Usernames
	
- The iRODS software will be required to run under a specific user account, typically with the username `rods`, it will also be installed by that username, so the account should be a login account with a password meeting your local standards.

## Network requirements

- The server needs a public IP address.

- The following ports are required to be open
- ***TCP** **IN+OUT**
	
- 
- 1247 (irods)
- 40000-41000 (ARCS-defined range for Globus-related communication: iRODS within ARCS uses a subset)
- ***UDP** **IN+OUT**
	
- 
- 40000-41000 (ARCS-defined range for Globus-related communication: iRODS within ARCS uses a subset)

- If database replication is to be done with other iRODS servers, then a `PostgreSQL` port will need to be opened for access to/from those other servers.
- ***TCP** **IN+OUT**
	
- 
- 5432

- GridFTP access may be required ?
- ***TCP** **IN+OUT**
	
- 
- 2811

## Certificates

In order to operate the host machine within ARCS, there are requirements to:

>  ***install the ARCS SLCS1 CA bundle**
>  ***install a host certificate** for this system
>  ***install a copy of the host certificate** for use by iRODS

### ARCS SLCS1 CA bundle

Based on the instructions at [http://wiki.arcs.org.au/bin/view/Main/SLCS](http://wiki.arcs.org.au/bin/view/Main/SLCS)

The `ARCS SLCS1 CA` bundle needs to be installed on top of the **IGTF Global** bundle (this includes the `APACGrid CA`) that will be installed as part of the VDT.

The VDT CA setup process will overwrite any certificates that have been added so we can just download the `ARCS SLCS1 CA` bundle

- If no other software has created the directory `/etc/grid-security` then it needs to be created

``` 

mkdir -p /etc/grid-security
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security

```

- Get the ARCS SLCS1 CA bundle and extract it into `/etc/grid-security` (creates `arcs-slcs-ca` subdirectory)
	
- The files should be owned by root

``` 

cd /etc/grid-security  
wget --no-check-certificate https://slcs1.arcs.org.au/arcs-slcs-ca.tar.gz -O - | tar xvz  
chown -R root:root /etc/grid-security/arcs-slcs-ca

```

The installed files should be similar (identical ??) to these

``` 

ls -l /etc/grid-security/arcs-slcs-ca/
-rw-r--r-- 1 root root 1996 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.0
-rw-r--r-- 1 root root  217 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.namespaces
-rw-r--r-- 1 root root  193 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.signing_policy

```

### Host Certificate

If a **host certificate** has not already been installed on the system then  **obtain a host certificate** for this system from the [APACGrid CA](http://wiki.arcs.org.au/bin/view/Main/HostCertificates)

- If no other software has created the directory `/etc/grid-security` then it needs to be created

``` 

mkdir -p /etc/grid-security/
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security

```

- Install the certificate and private key as `/etc/grid-security/hostcert.pem` and `/etc/grid-security/hostkey.pem` respectively
	
- The files should be owned by root
- The private key should be readable only to root

``` 

ls -l /etc/grid-security/host* /etc/grid-security/irods*
-rw-r--r-- 1 root   root   2634 Mar 13  2009 /etc/grid-security/hostcert.pem
-rw------- 1 root   root   1675 Mar 13  2009 /etc/grid-security/hostkey.pem

```

### Host Certificate Copies for iRODS

- Install a copy of the host certificate and private key pair as `/etc/grid-security/irodscert.pem` and `/etc/grid-security/irodskey.pem` respectively
	
- The files should be owned by the iRODS userame
- The private key should be readable only to the iRODS username

``` 

ls -l /etc/grid-security/host* /etc/grid-security/irods*
-rw-r--r-- 1 root   root   2634 Mar 13  2009 /etc/grid-security/hostcert.pem
-rw------- 1 root   root   1675 Mar 13  2009 /etc/grid-security/hostkey.pem
-rw-r--r-- 1 rods   rods   2634 Mar 13  2009 /etc/grid-security/irodscert.pem
-rw------- 1 rods   rods   1675 Mar 13  2009 /etc/grid-security/irodskey.pem

```

## External Software

Setting up this server will require us to install software

- from the ARCS repository, using `yum`
- from a VDT mirror, using `pacman`
- by compiling source code downloaded from the iRODS project website.

### Configure ARCS RPM repository

``` 
cd /etc/yum.repos.d && wget http://projects.arcs.org.au/dist/arcs.repo
```

- Note: on a 64-bit system, change the repository file to use ARCS i386 repository itself (the ARCS 64-bit repository is not populated).  I.e., change the `baseurl` for the *arcs* repository in `/etc/yum.repos.d/arcs.repo` to: 

``` 
baseurl=http://projects.arcs.org.au/dist/production/$releasever/i386
```

### Setup pacman access to a VDT mirror

``` 

mkdir -p /opt/vdt
cd /opt/vdt
wget http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz
tar xf pacman-latest.tar.gz

```

- Untarring the `pacman-latest` tarball will actually create a directory with the version number of the latest pacman in, eg `pacman-3.29`. You may wish to inspect the version you have but the following command will work, provided you do not have an older version of pacman lying around.

``` 

cd pacman-*/ && source setup.sh && cd ..

```

- Set an environmental variable for the VDTMIRROR that will be used

All of the instructions below should ensure the following environmental variable is set,

ahead of any `pacman` operations.

``` 
export VDTMIRROR=http://vdt.cs.wisc.edu/vdt_200_cache
```

## VDT components

- Required packages:
- ***Globus-Core** - the ?
- ***Globus-Base-SDK** - the ?

- Note that even though it is not mentioned in the list of requirements, the ARCS script also installs
	
- Globus-Base-Data-Server
- PRIMA

- Recommended packages:
	
- Are there any recommended packages ?

## Install VDT components

- If you do not have `pacman` setup, for example, you are returning to a partially installed system, you may need to set it up again

>  source /opt/vdt/pacman-*/setup.sh

- Assuming you have `pacman` setup for the current session

>  cd /opt/vdt
>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)

Note that the ARCS instructions suggest, rather, imply by omission, that

the iRODS install script will get any Gloubs GSI components if one

tells it to use GSI - is that actually the case ?

- Once there are some `VDT` components installed, this convenience link should be made and, as we are in a session where we will not currently have added things to the environment, we add them.

``` 

ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
. /etc/profile

```

From now on, every user will pick up the `VDT` environment on login.

**Note** (This is not really explaned anywhere - is this actually correct) 

If one adds packages to a VDT install the `/opt/vdt/setup.sh` script will be altered

to match the 

- most recent set of installed packages only, thereby losing the old one
- most recent set of installed packages plus any existing ones

**Potential Gotcha !!!**

It seems that Globus, as installed by VDT, does not create a config file that most things that build against it expect to see for compilation

This bug report [https://savannah.cern.ch/bugs/?8860](https://savannah.cern.ch/bugs/?8860) suggests that the problem can be fixed by re-running a `gpt-build` command against the various compilation environments that your Globus environment supports.

The simplest way to get the list of supported environments is (results obviously may differ) to look at the 

`/opt/vdt/globus/include/` and use that list as the arguments to the `gpt-build` command

So, having seen these compilation environments

``` 

$ ls /opt/vdt/globus/include/
gcc64  gcc64dbg  gcc64dbgpthr  gcc64pthr

```

one would run, as the `globus` user, the following command: 

``` 

gpt-build -force -nosrc -builddir=/tmp/globus_core.$$ gcc64 gcc64dbg gcc64dbgpthr gcc64pthr

```

after which, the missing file will be found in the following locations

``` 

# find /opt/vdt -name globus_config.h
/opt/vdt/globus/include/gcc64dbgpthr/globus_config.h
/opt/vdt/globus/include/gcc64dbg/globus_config.h
/opt/vdt/globus/include/gcc64/globus_config.h
/opt/vdt/globus/include/gcc64pthr/globus_config.h

```

Might be worth checking for this ahead of a build.

## Post-install VDT configuration

### Grid Certificates

Certificate-based grid security with BeSTGRID relies upon the APACGrid CA.

The APACGrid CA is part of a global certificate distribution maintained by the IGTF.

VDT comes with a tool to download and update a certificate distribution, but requires the user to make an (informed) choice on which certificate distribution to trust.  The VDT team is also creating a convenient distribution based on IGTF - but we do need to configure this tool to point to this distribution.

- Run the following command to select the VDT distribution and install it into `/etc/grid-security/certificates`

``` 
vdt-ca-manage setupca --location root --url vdt
```

- Note: behind the scenes, the tool will
	
- Backup and rename any exsting `/etc/grid-security/certificates`
- Add the following line to `$VDT_LOCATION/vdt/etc/vdt-update-certs.conf`: 

``` 
cacerts_url = http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version
```

- Note: Other installation notes can suggest getting the APACGrid CA Cert directly, eg 

``` 
wget https://ca.apac.edu.au/pub/cacert/cacert.crt
```
- However the APACGrid CA Cert is this one from the IGTF bundle 

``` 
/etc/grid-security/certificates/1e12d831.0
```

In order to have the ARCS SLCS1 CA bundle available we need to copy that bundle into the main certificates directory

and ensure that VDT includes those files in any subsequent updates:

- Copy the ARCS SLCS1 CA bundle files into `/etc/grid-security/certificates`

``` 

 cd /etc/grid-security/arcs-slcs-ca 
 cp * /etc/grid-security/certificates  

```

- Tell the VDT certificates updater to include the files in the next certificates update: edit `/opt/vdt/vdt/etc/vdt-update-certs.conf` and add:

``` 

 include=/etc/grid-security/arcs-slcs-ca/1ed4795f.0 
 include=/etc/grid-security/arcs-slcs-ca/1ed4795f.namespaces 
 include=/etc/grid-security/arcs-slcs-ca/1ed4795f.signing_policy

```

# Walk Through

I should have placed all the commands and notes I made here as I went along prior

to trying to make them fit the common pattern above - they are here now.

## iRODS

>  ***Rods user**

Going to use `rods:rods 320:320` for the initial roll-out.

``` 

sudo /usr/sbin/groupadd -g 320 rods
sudo /usr/sbin/useradd  -u 320 -g 320 -m -d /home/rods -c "iRODS Administrator" rods

```

>  ***Rods software**

Downloading the iRODS tarball is a bit of a pain, as you have to fill in a form and click an agree button but you'll end up with `irods2.2.tgz`

There's also a simple patch listed at the iRODS site:

``` 

psql ICAT
   create unique index idx_coll_main3 on R_COLL_MAIN (coll_name);

```

In order to allow for different versions of iRODS, ARCS suggest installing into a versioned directory and linking to a generic directory.

``` 

mkdir /opt/iRODS-2.2
ln -s /opt/iRODS-2.2 /opt/iRODS
cp ~kevin/ITS-VM-Extras/irods2.2.tgz /opt/iRODS-2.2
chown -R rods:rods /opt/iRODS-2.2
chown -h rods:rods /opt/iRODS

```

The ARCS install notes have an appended "v" on the directory name even though the tarball

doesn't expand with one - significance of the "v" ?

then there's the Vault

``` 

mkdir -p /mnt/IRODS_01/Vault
chown rods:rods /mnt/IRODS_01/Vault

```

Can do some independent bits

``` 

su - rods
cd /opt/iRODS-2.2/
tar xf irods2.2.tgz
cd iRODS/

```

>  ***Host Certs**

 ***ARCS SLCS1 CA Bundle**

>  ***Explicity add all the RHEL packages we need for the devel environment**

Let's try

``` 
yum install gcc gcc-c++ compat-libstdc++-33 openssl-devel
```

and see what happens.

``` 

Loaded plugins: rhnplugin, security
http://projects.arcs.org.au/dist/production/5Server/i386/repodata/repomd.xml: [Errno 14] HTTP Error 404: Not Found
Trying other mirror.
Error: Cannot retrieve repository metadata (repomd.xml) for repository: arcs. Please verify its path and try again

```

This must be because our RHEL YUM is giving out `$releasever` as `5server` and not `5`

Have emailed ARCS and suggested they link their CentOS **5** to **5server**

``` 

yum install gcc gcc-c++ compat-libstdc++-33 openssl-devel \
 glibc-devel glibc-headers libstdc++-devel \
 zlib-devel e2fsprogs-devel openssl-devel  \
 keyutils-libs-devel krb5-devel libselinux-devel libsepol-devel

```

>  ***iRODS Setup/Compilation**

Have only noted the questions where the defaults were not accepted and/or the

answers given differ from the ARCS page

``` 

$ ./irodssetup

Include additional prompts for advanced settings [no]? yes

iRODS zone name [tempZone]? VUW

Starting Server Port [20000]? 40000
Ending Server Port [20199]? 40199

iRODS DB password scramble key [123]? ***  (It's a password, why use the default!)

Resource name [demoResc]? ngdata.vuw.ac.nz
Directory [/opt/iRODS-2.2/iRODS/Vault]? /mnt/IRODS_01/Vault

New Postgres directory? /opt/iRODS-2.2/Postgres

PostgreSQL version [postgresql-8.3.5.tar.gz]? postgresql-8.4.2.tar.gz   (iRods website says)

Include GSI [no]? yes

GSI Install Type to use? gcc64dbg


```

There's a install log here `/opt/iRODS/iRODS/installLogs/installPostgres.log`

It puts the downloaded tarball in `/opt/iRODS/iRODS/Postgres/`

and has created `/opt/iRODS/iRODS/Postgres/pgsql`

Not clear where is puts and builds `unixODBC`, looks like `/opt/iRODS-2.2/Postgres/postgresql-8.4.2/src/interfaces/odbc`

Note that the compilation initially failed

``` 

...
Compile core igsi.o...
In file included from /opt/vdt/globus/include/gcc64dbg/globus_common.h:58,
                 from /opt/vdt/globus/include/gcc64dbg/gssapi.h:44,
                 from /opt/iRODS-2.2/iRODS/lib/core/src/igsi.c:32:
/opt/vdt/globus/include/gcc64dbg/globus_common_include.h:19:27: error: globus_config.h: No such file or directory
...

```

because of Globus not having that config file as a matter of course.

Quite nice that you can run `$ ./irodssetup` again and it will go with the

answer you have already given, and not ask them all over again.

I have sen something that suggested that if one wished not not use the same 

username and password for all three of the:

- system logon account
- PostgresQL user
- iRODS system user

as suggested by the ARCS install notes then there were "issues".

>  ***Post installtion**

After this point we can see the following running as rods.

``` 

rods      7991     1  0 14:41 pts/0    00:00:00 /opt/iRODS-2.2/Postgres/pgsql/bin/postgres -i
rods      7993  7991  0 14:41 ?        00:00:00 postgres: writer process
rods      7994  7991  0 14:41 ?        00:00:00 postgres: wal writer process
rods      7995  7991  0 14:41 ?        00:00:00 postgres: autovacuum launcher process
rods      7996  7991  0 14:41 ?        00:00:00 postgres: stats collector process
rods      8098     1  0 14:42 ?        00:00:00 /opt/iRODS-2.2/iRODS/server/bin/irodsServer
rods      8100  8098  0 14:42 ?        00:00:00 irodsReServer

```

Note that `irodsctl` is in the top of the iRODS installation, not in a 

`bin` or `sbin` directory.

``` 

$ ./irodsctl status
iRODS servers:
    Process 8098
iRODS rule servers:
    Process 8100
Database servers:
    Process 7991
iRODS Servers associated with this instance, port 1247:
    Process 8098
    Process 8100

```

As the rods user in a new session

``` 

LD_LIBRARY_PATH=/opt/vdt/globus/lib:$LD_LIBRARY_PATH
IRODS_HOME=/opt/iRODS/iRODS
PATH=$IRODS_HOME/clients/icommands/bin:$PATH
export LD_LIBRARY_PATH IRODS_HOME PATH
$
$ iinit
Enter your current iRODS password:
$ ils
/VUW/home/rods:

```

Ok, so what about as me kevin

``` 

LD_LIBRARY_PATH=/opt/vdt/globus/lib:$LD_LIBRARY_PATH
IRODS_HOME=/opt/iRODS/iRODS
PATH=$IRODS_HOME/clients/icommands/bin:$PATH
export LD_LIBRARY_PATH IRODS_HOME PATH
$
$ iinit
One or more fields in your iRODS environment file (.irodsEnv) are
missing; please enter them.
Enter the host name (DNS) of the server to connect to:ngdata.vuw.ac.nz
Enter the port number:1247
Enter your irods user name:kevin
Enter your irods zone:VUW
Those values will be added to your environment file (for use by
other i-commands) if the login succeeds.

Enter your current iRODS password:
rcAuthResponse failed with error -827000 CAT_INVALID_USER

```

and of course kevin does not have one.

the rods user has this file now:

``` 

$ cat .irods/.irodsEnv
# iRODS personal configuration file.
#
# This file was automatically created during iRODS installation.
#   Created Mon Mar  8 14:41:59 2010
#
# iRODS server host name:
irodsHost 'ngdata.vuw.ac.nz'
# iRODS server port number:
irodsPort 1247

# Default storage resource name:
irodsDefResource 'ngdata.vuw.ac.nz'
# Home directory in iRODS:
irodsHome '/VUW/home/rods'
# Current directory in iRODS:
irodsCwd '/VUW/home/rods'
# Account name:
irodsUserName 'rods'
# Zone:
irodsZone 'VUW'

```

>  ***Access (Non-GSI) from an external machine**

Try out a normal (non-GSI) access from a remote machine.

Using an old CentOS VM within ECS, I followed

``` 
http://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS_Client_Packages/CentOS_GSI
```

which gives one enough of a Globus environment without needing to use VDT

``` 

wget http://vdt.cs.wisc.edu/vdt_rpms/1.10.1/release-1/x86_rhap_5/gpt-3.2autotools2004_NMI_9.0_x86_rhap_5-1.i386.rpm
wget http://vdt.cs.wisc.edu/vdt_rpms/1.10.1/release-1/x86_rhap_5/vdt_globus_essentials-VDT1.10.1x86_rhap_5-1.i386.rpm
wget http://vdt.cs.wisc.edu/vdt_rpms/1.10.1/release-1/x86_rhap_5/vdt_compile_globus_core-VDT1.10.1_x86_rhap_5-1.i386.rpm
wget http://vdt.cs.wisc.edu/vdt_rpms/1.10.1/release-1/x86_rhap_5/vdt_globus_sdk-VDT1.10.1x86_rhap_5-1.i386.rpm

wget http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/iRODS-Client-RPMS/2.2/iRODS-clients-gsi-2.2-1.i386.rpm\?format=raw -O iRODS-clients-gsi-2.2-1.i386.rpm

```

``` 

# rpm -ivh *
Preparing...                ########################################### [100%]
   1:vdt_globus_sdk         ########################################### [ 20%]
   2:gpt                    ########################################### [ 40%]
Using system tar and gzip programs to unpack packages
GNU tar located at /bin/tar
GNU zip located at /bin/gzip
GNU unzip located at /bin/gunzip
GNU make located at /usr/bin/make
Perl located at /usr/bin/perl
rpm located at /bin/rpm
rpmbuild located at /usr/bin/rpmbuild
RPM Package License set to GNU
RPM Package Vendor set to NCSA
RPM Package FTP Site set to ftp.ncsa.uiuc.edu
RPM Package URL set to http://www.gridpackaging.org
RPM Packager set to NCSA
RPM Prefix set to /usr/grid
GNU target platform set to i686-pc-linux-gnu
   3:vdt_globus_essentials  ########################################### [ 60%]
   4:iRODS-clients-gsi      ########################################### [ 80%]
   5:vdt_compile_globus_core########################################### [100%]
gpt-build ====> Changing to /tmp/globus_core.29016/globus_core-4.30/
gpt-build ====> BUILDING FLAVOR gcc32
gpt-build ====> Changing to /tmp/globus_core.29016
gpt-build ====> REMOVING empty package globus_core-gcc32-pgm_static
gpt-build ====> REMOVING empty package globus_core-noflavor-doc
gpt-build ====> Changing to /tmp/globus_core.29016/globus_core-4.30/
gpt-build ====> BUILDING FLAVOR gcc32dbg
gpt-build ====> Changing to /tmp/globus_core.29016
gpt-build ====> REMOVING empty package globus_core-gcc32dbg-pgm_static
gpt-build ====> REMOVING empty package globus_core-noflavor-doc
gpt-build ====> Changing to /tmp/globus_core.29016/globus_core-4.30/
gpt-build ====> BUILDING FLAVOR gcc32pthr
gpt-build ====> Changing to /tmp/globus_core.29016
gpt-build ====> REMOVING empty package globus_core-gcc32pthr-pgm_static
gpt-build ====> REMOVING empty package globus_core-noflavor-doc
gpt-build ====> Changing to /tmp/globus_core.29016/globus_core-4.30/
gpt-build ====> BUILDING FLAVOR gcc32dbgpthr
gpt-build ====> Changing to /tmp/globus_core.29016
gpt-build ====> REMOVING empty package globus_core-gcc32dbgpthr-pgm_static
gpt-build ====> REMOVING empty package globus_core-noflavor-doc

```

Interestingly, the [http://www.gridpackaging.org](http://www.gridpackaging.org) mentioned doesn't exist.

There are now a load of stuff under `/opt/iCommands-2.2v`

and there's an `/etc/profile.d/iCommands.sh`

``` 

#!/bin/bash
export LD_LIBRARY_PATH=/opt/globus/lib:$LD_LIBRARY_PATH
export IRODS_HOME=/opt/iCommands-2.2v
export PATH=$IRODS_HOME/bin:$PATH

```

As me on the remote machine

``` 

$ iinit
One or more fields in your iRODS environment file (.irodsEnv) are
missing; please enter them.
Enter the host name (DNS) of the server to connect to:ngdata.vuw.ac.nz
Enter the port number:1247
Enter your irods user name:kevin
Enter your irods zone:VUW
Those values will be added to your environment file (for use by
other i-commands) if the login succeeds.

Enter your current iRODS password:
ERROR: _rcConnect: connectToRhost error, server on ngdata.vuw.ac.nz is probably down status = -347000 USER_SOCK_CONNECT_TIMEDOUT
ERROR: Saved password, but failed to connect to server ngdata.vuw.ac.nz

```

So, no access and we know there's no me over there either !

Back on the iRODS server

``` 

$ sudo su - rods
[rods@ngdata ~]$
$ iadmin mkuser kevin rodsuser password ChangeMe2

```

Still no access? 

For some reason I needed to add the password seperately 

``` 

$ sudo su - rods
[rods@ngdata ~]$
$ iadmin 
iRODS Version 2.2                  Oct 2009                      iadmin
iadmin>lua
kevin password
iadmin>luan
No rows found
iadmin>moduser kevin password Changeme2

```

and we have local access.

Over on the remote machine

``` 

kevin$ ils
/VUW/home/kevin:
$  iput  file_from_grid_ecs.txt
ERROR: putUtil: put error for /VUW/home/kevin/file_from_grid_ecs.txt, status = -78000 status = -78000 SYS_RESC_DOES_NOT_EXIST

```

That's the result of not using the default resource name when installing and either

not specifying it in future iRODS commands or not setting it to be the default by

some other means.

``` 

iput -R ngdata.vuw.ac.nz file_from_grid_ecs.txt

# AND NOT JUST

iput file_from_grid_ecs.txt

```

## GSI Access

Once again, following the original ARCS documentation as the starting point

and refering to Vlad's notes.

Actually rebuilt the iRODS installtion here, so as to rename the zone to

BeSTGRID-DEV. (Note the capitalisation there !)

This is simpler than you might think. Stopping all the related services

(hhtpd, davis and irods) and removing the PostgresQL installtion

`rm -fr /opt/iRODS-2.2/Postgres/pgsql`

allows on to re-run the 

`./irodssetup`

which is clever enough to realise you already have the PostgresQL sources

left over from the original install.

One must, however delete any files from the Vault as these no longer have

references within the newly built database.

The final piece in the renaming of the zone is to edit 

`/opt/davis/webapps/root/WEB-INF/davis-host.properties`

``` 

server-name=ngdata.vuw.ac.nz
zone-name=BeSTGRID-DEV
default-domain=ngdata.vuw.ac.nz
default-resource=ngdata.vuw.ac.nz

```

Also need to follow Vlad's crucially important stuff, as rods

``` 

ichmod read public /BeSTGRID-DEV
ichmod read public /BeSTGRID-DEV/home
ichmod read public /BeSTGRID-DEV/trash
ichmod read public /BeSTGRID-DEV/trash/home

```

so as to give usernames other than `rods` access remotely.

`updateRules.sh`

that script only seems to pull over

`arcs.irb  imos.irb`

whereas the source directory at ARCS

[http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/Rules](http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/Rules)

contains the following rules files

``` 

Monash_updateRules.sh
arcs.irb
arcsInbox.irb
arcsdev.irb
arcsextra.irb
arcstest.irb
chgInboxPerm
emxray.irb
group.irb
groupextra.irb
imos.irb
imosdev.irb
imosextra.irb
imostest.irb
updateRules.sh
userextra.irb

```

What seems to be happening is that Vlad's old instructions map a zone name

of `BeSTGRID-DEV` to a glob `*dev.irb` and only `arcs` and

`imos` have devel versions now.

When we pull all of the files and look to install by hand it would seem that

all we really need is the `arcs.irb` file, as that contains the rule

that calls the createUser script that we want to invoke for first-time GSI

users.

The `arcs.irb` script would seem to have a load of stuff potentially not relevant

to a test environment so edit it, including taking out guest and anonymous access,

and all replication for now, to end up with:

``` 

# iRODS local rules for BeSTGRID sites
# Default-resource must be set appropriately for your site (e.g. ngdata.vuw.ac.nz)
#
acGetUserByDN(*arg,*OUT)||msiExecCmd(createUser,'"*arg"',null,null,null,*OUT)|nop
acPreprocForDataObjOpen||msiSetDataObjPreferredResc(ngdata.vuw.ac.nz)|nop
acSetRescSchemeForCreate||msiSetDefaultResc(ngdata.vuw.ac.nz,preferred)|nop
acSetVaultPathPolicy||msiSetGraftPathScheme(no,0)|nop
acAclPolicy||msiAclPolicy(STRICT)|nop
acTrashPolicy||nop|nop
#KMB no replication for now
#Adding rules to replicate

```

We can then copy this to `$IRODS_HOME/server/config/reConfigs` as `bestgrid.irb`

and edit the `$IRODS_HOME/server/config/server.config` to say

`reRuleSet bestgrid,core`

instead of

`reRuleSet arcs,core`

as we won't be running an automatic update of the rules script just yet whilst

in testing mode.

The `iupdate` script that is used to get the username corrsponding to the

certicate's `DN` makes use of `myproxy-logon` and `myproxy-info`

They seem to come from the VDT `MyProxy-Client` package which is available from

[http://vdt.cs.wisc.edu/vdt_rpms/1.10.1/release-1/x86_rhap_5/](http://vdt.cs.wisc.edu/vdt_rpms/1.10.1/release-1/x86_rhap_5/)

for our remote client as

`myproxy-VDT1.10.1x86_rhap_5-4.2.i386.rpm`

It seems you need to set some EnvVars in the `irodsctl.pl` script, that

an `irodsctl start|stop` invokes, in order to  get the iRODS server to

come up with knowlegde about the GSI infrastructure

For me this is the unified diff

``` 

--- /opt/iRODS/iRODS/scripts/perl/irodsctl.pl.000       2010-03-26 15:06:59.000000000 +1300
+++ /opt/iRODS/iRODS/scripts/perl/irodsctl.pl   2010-03-30 15:16:45.000000000 +1300
@@ -220,6 +220,10 @@
 # pre and post rule processing for general query.
 # note that this can lead to slower performance
 # $PREPOSTPROCFORGENQUERYFLAG=1;
+#
+$ENV{'X509_CERT_DIR'}  = "/etc/grid-security/certificates" ;
+$ENV{'X509_USER_CERT'} = "/etc/grid-security/irodscert.pem" ;
+$ENV{'X509_USER_KEY'}  = "/etc/grid-security/irodskey.pem" ;
 
                                  $ENV{'irodsConfigDir'}      = $irodsServerConfigDir;
 if ($irodsEnvFile)             { $ENV{'irodsEnvFile'}        = $irodsEnvFile; }

```

Had a couple of problems with `MyProxy`

Vlad suggests that if you use Grix to upload a myproxy cert first then you can

upload on from a remote machine with myproxy-logon but if you try to do it just

from the remote machine, there are intermittent failures in the process ??

How the iupdate script  works

1. Does a myproxy-login to download a local credential (`/tmp/x509_uNNN`, where NNN is the user's UID)
2. Does a grid-proxy-info -identity to get the DN in that credential
3. Remove any `irodsUserName` line from `~/.irods/.irodsEnv`
4. Does an iuserinfo
5. Does an `iquest` to get the actual username by searching on the DN it got from the credential and appends this to the `~/.irods/.irodsEnv`

### Problem with the ARCS `createUser` script

There's also a problem with the `createUser` script that you download from ARCS.

There's a block in it that creates new users on the fly

``` 

  `$path/iadmin mkuser  $user_name rodsuser         >/dev/null 2>&1 && \
   $path/iadmin moduser $user_name DN   $dn_plus    >/dev/null 2>&1 && \
   $path/iadmin moduser $user_name info $st_plus    >/dev/null 2>&1 && \
   $path/iadmin moduser $user_name password "$pass" >/dev/null 2>&1`;

```

however the second line of that no longer works (I tried this out at the 

command line)

It needs to be (Vlad's notes refer to the same problem but don't mention altering the script ?)

``` 

   $path/iadmin aua     $user_name      $dn_plus    >/dev/null 2>&1 && \

```

After making that change, things work as expected.

## DAVIS

On ngdata following

[https://projects.arcs.org.au/trac/davis/wiki/HowTo/Install](https://projects.arcs.org.au/trac/davis/wiki/HowTo/Install)

Install `jre1.6.0_18/` into `/opt`

Untar the DAVIS as `/opt/davis-0.8.3` and symlink to `/opt/davis`

``` 

# cp /opt/davis/bin/jetty.sh /etc/init.d/davis
# chmod +x /etc/init.d/davis
# echo JETTY_HOME=/opt/davis > /etc/default/jetty
# echo JAVA_HOME=/opt/jre1.6.0_18 >>  /etc/default/jetty

```

It looks as though the APAC CA Cert is `/etc/grid-security/1e12d831.0`

Vlad suggest using `Jetty6+Apache` anyway.

``` 

yum install mod_ssl
Installing:
 mod_ssl       x86_64     1:2.2.3-31.el5_4.2     rhel-x86_64-server-5      89 k
Installing for dependencies:
 distcache     x86_64     1.4.5-14.1             rhel-x86_64-server-5     121 k

```

Probably need to change these config files

``` 

# cp -p /opt/davis/etc/jetty.xml /opt/davis/etc/jetty.xml.000
# # NO DIFFS
# cp -p /etc/httpd/conf.d/proxy_ajp.conf /etc/httpd/conf.d/proxy_ajp.conf.000
# cp -p /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.000

```

**Diffs from the APAC Notes**

1. (1.) Looks like the AJP listener is there by default
2. (2.) The `jetty-ajp-6.1.xx.jar` referred to is possibly at `$JETTY_HOME/lib/ext` and not `$JETTY_HOME/etc/lib/ext` ?
3. (4.) Might not actually need a chain file ? There's no chain ?
4. (5.) Apache now uses `/etc/httpd/conf.d/proxy_ajp.conf` as a place for AJP proxy config.

Start up httpd and davis

Probably need access to some ports

After which we get an Authentication Required dialog

``` 

A username and password are being requested by https://ngdata.vuw.ac.nz. The site
says: "ARCS Data Fabric"

```

Try my auth credentials?

Get this Jetty error

``` 

HTTP ERROR 500

Problem accessing /. Reason:

    The host string cannot be null

Caused by:
...

```

That error is down to not having the Davis/Jetty fully configured.

``` 

WARNING: Can't load config file '/WEB-INF/davis-host.properties' - skipping
WARNING: Can't load config file '/WEB-INF/davis-dev.properties' - skipping

```

Those listed files should be in `/opt/davis/webapps/root/WEB-INF/` if they

are to be read.

Not clear whether we need the `davis-dev` ? Maybe that's just ARCS adding

an devel environment host as a default?

Whatever, adding a file `davis-host.properties` and removing the other

warning entry from the list of files to be read, in `web.xml`, does the

right thing, so presumably, one or more of the properties are being added to

the request strings.

``` 

# cat davis-host.properties
server-name=ngdata.vuw.ac.nz
zone-name=VUW
default-domain=ngdata.vuw.ac.nz
default-resource=ngdata.vuw.ac.nz

```

### MyProxy Access

Seems to be an issue with needing to do a `myproxy-init -a` but 

when that issue had finally been sussed by Vlad, that gave me access to

his Data Fabric through a web browser.

Now need to configure the VUW-local davis for that access.

Gotcha! The `Jargon` shipped with current `Davis` releases does

not allow one to make GSI access. Either upgrade or wait for the version that

includes the right `Jargon`.

Can still do command line GSI access though.

# Miscellaneous Notes

## Make a note of the resource

When you set up the iRODS server, you are asked a number of questions, including

the name for the **resource**.

The ARCS instructions suggest you use the FDQN of the server rather than the default `demoResc`

What is not made clear there is that although you have set the resource for the server, if you come

to access the server from the command line, even on the server itself, unless you tell the `iput`

utility that you explicitly want to use that resource, you'll end up **silently** trying to 

access the default `demoResc` resource, which does not exist because you didn't accept it!

What happens is something like this

``` 

$ iput a_new_file.txt
ERROR: putUtil: put error for /VUW/home/kevin/a_new_file.txt, status = -78000 status = -78000 \
SYS_RESC_DOES_NOT_EXIST

```

What you need to do is this

``` 

$ iput -R your_resource_name a_new_file.txt

```

Oddly, once the file is on the server

``` 

$ ils
/VUW/home/kevin:
  a_new_grid_ecs_file.txt
  file_from_grid_ecs.txt
  file_from_ngdata.txt

```

you can get it without needing to specify the resource

``` 

$ iget  file_from_ngdata.txt
$ ls file_from_ngdata.txt
file_from_ngdata.txt

```

Presumably there is a way to set the default resource for `iput` **???**

## Unified diff for arcs.repo

Just for completeness and clarity, here's the unified diff 

``` 

--- arcs.repo.orig   2010-03-04 11:51:48.000000000 +1300
+++ arcs.repo   2010-03-04 11:53:19.000000000 +1300
@@ -16,6 +16,6 @@
 
 [arcs]
 name=ARCS Production Release
-baseurl=http://projects.arcs.org.au/dist/production/$releasever/$basearch
+baseurl=http://projects.arcs.org.au/dist/production/$releasever/i386
 enabled=1
 gpgcheck=0

```

## Unified diff for VDT Certifcate Update Configuration

Just for completeness and clarity, here's the unified diff 

``` 

--- /opt/vdt/vdt/etc/vdt-update-certs.conf.orig  2010-03-08 11:29:29.000000000 +1300
+++ /opt/vdt/vdt/etc/vdt-update-certs.conf       2010-03-08 11:29:56.000000000 +1300
@@ -13,6 +13,10 @@
 ## include specifies files (full pathnames) that should be copied
 ## into the certificates installation after an update has occured.
 
+include=/etc/grid-security/arcs-slcs-ca/1ed4795f.0 
+include=/etc/grid-security/arcs-slcs-ca/1ed4795f.namespaces 
+include=/etc/grid-security/arcs-slcs-ca/1ed4795f.signing_policy
+
 ## exclude_ca specifies a CA (not full pathnames, but just the hash
 ## of the CA you want to exclude) that should be removed from the
 ## certificates installation after an update has occured.

```

## Setting up openssl

When one comes to request certificates using `OpenSSL` to create the request,

a vanilla install of an `openssl` package will see one prompted, with the

following defaults, to answer these questions:

``` 
Country Name (2 letter code) [GB]:
State or Province Name (full name) [Berkshire]:
Locality Name (eg, city) [Newbury]:
Organization Name (eg, company) [My Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

```

however, when working within BeSTGRID, not only does one not need to provide all

of the information asked for, but the defaults are obviously incorrect, a combination  

that can lead to some confusion.

It is possible to always be prompted as follows

``` 
Country Name (2 letter code) [NZ]:
Organization Name (eg, company) [BeSTGRID]:
Organizational Unit Name (eg, section) [Victoria University of Wellington]:
Common Name (eg, your name or your server's hostname) []:
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:

```

which provides a much more sensible set of defaults whilst removing the

unecessary questions that might cause confusion.

To achieve this, one merely needs to edit the file `/etc/pki/tls/openssl.cnf`

The result of patching the file for use at VUW (`RHEL 5.4`, `openssl-0.9.8e-12.el5_4.1`) resulted in this unified diff, which may be informative:

``` 

--- /etc/pki/tls/openssl.cnf.orig    2010-03-03 16:13:13.000000000 +1300
+++ /etc/pki/tls/openssl.cnf    2010-03-03 16:29:15.000000000 +1300
@@ -133,25 +133,25 @@
 
 [ req_distinguished_name ]
 countryName                    = Country Name (2 letter code)
-countryName_default            = GB
+countryName_default            = NZ
 countryName_min                        = 2
 countryName_max                        = 2
 
-stateOrProvinceName            = State or Province Name (full name)
-stateOrProvinceName_default    = Berkshire
+#stateOrProvinceName           = State or Province Name (full name)
+#stateOrProvinceName_default   = Berkshire
 
-localityName                   = Locality Name (eg, city)
-localityName_default           = Newbury
+#localityName                  = Locality Name (eg, city)
+#localityName_default          = Newbury
 
 0.organizationName             = Organization Name (eg, company)
-0.organizationName_default     = My Company Ltd
+0.organizationName_default     = BeSTGRID
 
 # we can do this but it is not needed normally :-)
 #1.organizationName            = Second Organization Name (eg, company)
 #1.organizationName_default    = World Wide Web Pty Ltd
 
 organizationalUnitName         = Organizational Unit Name (eg, section)
-#organizationalUnitName_default        =
+organizationalUnitName_default = Victoria University of Wellington
 
 commonName                     = Common Name (eg, your name or your server\'s hostname)
 commonName_max                 = 64
@@ -166,7 +166,7 @@
 challengePassword_min          = 4
 challengePassword_max          = 20
 
-unstructuredName               = An optional company name
+#unstructuredName              = An optional company name
 
 [ usr_cert ]
 

```

and though obviously that patch is specific to VUW, the principles remain the same.

- modify `countryName_default` to be `NZ`
- comment out `stateOrProvinceName` and its default
- comment out `localityName` and its default
- modify `0.organizationName_default` to be `BeSTGRID`
- uncomment `organizationalUnitName_default` and make it be your institution
- comment out `unstructuredName`

Along similar lines, if all certifcate requests are made using a "catch-all" email

address then an `emailAddress_default` line could be added into the file.

## Certificates

Gathering together of the various certificate-related info

- Many of the certificates required live below the directory `/etc/grid-security`

``` 

mkdir -p /etc/grid-security
chown root:root /etc/grid-security
chmod 755 /etc/grid-security

```

### Host Certificates

The host certificate and private key pair are installed as

- `/etc/grid-security/hostcert.pem`
- `/etc/grid-security/hostkey.pem`
	
- The files should be owned by root
- The private key should be readable only to root

### Host Certificate Copies for NG2

**Just for NGG2 or used by other services/facilities??**

Copies of the host certificate and private key pair for use by NG2 are installed as 

- `/etc/grid-security/containercert.pem`
- `/etc/grid-security/containerkey.pem`
	
- The files should be owned by daemon
- The private key should be readable only to daemon

### Host Certificate Copies for iRODS

Copies of the host certificate and private key pair for use by iRODS are installed as 

- `/etc/grid-security/irodscert.pem`
- `/etc/grid-security/irodskey.pem` respectively
	
- The files should be owned by the iRODS userame
- The private key should be readable only to the iRODS username

### Host Certificate Copies for NGGUMS

**Just for NGGUMS or used by other services/facilities??**

Copies of the host certificate and private key pair for use by NGGUMS are installed as 

- `/etc/grid-security/http/httpcert.pem`
- `/etc/grid-security/http/httpkey.pem`
	
- The files should be owned by daemon
- The private key should be readable only to daemon

``` 

mkdir -p /etc/grid-security/http
chown root:root /etc/grid-security
chown root:root /etc/grid-security/http
chmod 755 /etc/grid-security
chmod 755 /etc/grid-security/http

```

### The IGTF CA bundle

This contains the APACGrid CA Cert.

Needs more info

Note: Other installation notes can suggest getting the APACGrid CA Cert directly, eg

>     wget [https://ca.apac.edu.au/pub/cacert/cacert.crt](https://ca.apac.edu.au/pub/cacert/cacert.crt)

- However the APACGrid CA Cert is this one from the IGTF bundle

>       /etc/grid-security/certificates/1e12d831.0

so if you need to do something that requires it, you can use that file.

### The ARCS SLCS1 CA bundle

Needs info

### A "complete" listing

``` 

drwxr-xr-x 5 root root  4096 Mar  8 10:54 /etc/grid-security/

/etc/grid-security:

drwxr-xr-x 2 root   root    4096 Mar  8 12:08 arcs-slcs-ca/
lrwxrwxrwx 1 root   root      17 Mar  8 10:54 certificates -> certificates-54-1
drwxr-xr-x 2 root   root   20480 Mar  8 11:28 certificates-54-1/
drwxr-xr-x 2 root   root    4096 Mar  8 12:08 http/

-rw-r--r-- 1 daemon daemon  2512 Mar  5 13:52 containercert.pem
-rw------- 1 daemon daemon  1815 Mar  5 13:43 containerkey.pem
-rw-r--r-- 1 root   root    2512 Mar  5 13:52 hostcert.pem
-rw------- 1 root   root    1815 Mar  5 13:43 hostkey.pem
-rw-r--r-- 1 rods   rods    2512 Mar  5 13:52 irodscert.pem
-rw------- 1 rods   rods    1815 Mar  5 13:43 irodskey.pem

/etc/grid-security/http:

-rw-r--r-- 1 daemon daemon  2512 Mar  5 13:52 httpcert.pem
-rw------- 1 daemon daemon  1815 Mar  5 13:43 httpkey.pem

/etc/grid-security/arcs-slcs-ca:

-rw-r--r-- 1 root   root    1996 Sep 16  2008 1ed4795f.0
-rw-r--r-- 1 root   root     217 Sep 18  2008 1ed4795f.namespaces
-rw-r--r-- 1 root   root     193 Sep  9 12:23 1ed4795f.signing_policy

/etc/grid-security/certificates-54-1:

Too many other to mention but these are the APAC ones

-rwxr-xr-x 1 root   root    2594 Sep 23  2008 1e12d831.0
-rwxr-xr-x 1 root   root      40 Sep 23  2008 1e12d831.crl_url
-rwxr-xr-x 1 root   root     265 Feb 19 04:50 1e12d831.info
-rwxr-xr-x 1 root   root     821 Jun  4  2009 1e12d831.namespaces
-rwxr-xr-x 1 root   root     600 Jun  4  2009 1e12d831.signing_policy


```

Not clear why the IGTF ones have the executable bit set ?
