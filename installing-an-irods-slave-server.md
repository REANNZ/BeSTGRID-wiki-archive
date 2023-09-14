# Installing an iRODS slave server

The BeSTGRID DataFabric has been deployed as a single iRODS zone.  Institutions are welcome to join the BeSTGRID DataFabric by providing a local storage resource.  To link the resource into the BeSTGRID single iRODS zone, the institution would have to deploy a local iRODS server acting as a slave server in the BeSTGRID zone - and handling requests for that resource.  The institution can then install a local copy of the Davis web-and-webDAV interface on top of the local iRODS server.  Optionally, the institution could also install a GridFTP server as an additional entry point into the DataFabric.

This guide covers the following:

- Deployment considerations for the local iRODS server.
- Step-by-step guide for installing the local iRODS server.
- Step-by-step guide for a local Davis installation (optional but recommended)
- Step-by-step guide for (optionally) installing a GridFTP server with the iRODS DSI (Data Storage Interface) module connected to iRODS.

While this document was original written to assist in deploying a Slave server to join the BeSTGRID DataFabric, it has become the authoritative document for installing an iRODS server - including the master.  The parts specific to a master are clearly marked so.

In addition, when setting up a fresh iRODS zone, several steps are to be taken as one-off steps (e.g., granting read access to the pre-created top-level directories).  These have been merged from the now obsolete [IRODS deployment plan document](/wiki/spaces/BeSTGRID/pages/3818228549) into the [Public and Anonymous access section](#InstallinganiRODSslaveserver-PublicandAnonymousaccess).

# Deployment considerations

We recommend each site deploys first a test server, to test the whole installation process, polish off the rough edges, and be prepared for the real deployment.  The test server would aim to test software interoperability and network settings - so all of the prerequisites would apply as well, except for the amount of storage and hardware performance requirements.

The recommended naming conventions:

- For a test server: irodsdev.your.site.name (TBD)
- For a production server: 'irods.your.site.name (if the system is not running Davis)
- An additional CNAME for a production server if the site is running Davis:  'df.your.site.name

## Host system selection

The deployment is primarily dependent on the location and connectivity of the actual storage resource to be made available.  For performance reasons, iRODS should be as close to the storage resource as possible.  Also, the network connections should be as fast as possible (dedicated 1Gbps).

The implication of this is that iRODS should not be installed on a standard virtual machine mounting the storage resource over NFS.  NFS writes are painfully slow and this would make storing a large file into the system unacceptably slow.  Ideally, iRODS should be installed on a system "as close to the data as possible".  E.g., at Canterbury, iRODS is running on an IBM p520 running AIX, directly linked into the GPFS filesystem where the storage resource resides.   For a deployment in a virtual machine, a direct fibre-channel HBA dedicated to the VM is a good solution. iSCSI over a fast network connection (see below) would also work.  

If deploying inside a virtual machine, it's highly recommended to use a dedicated Ethernet adapters, used exclusively by the virtual machine.  From the experience with Xen, high throughput data traffic over the bridged network was straining the CPU in the `dom0` host too much.  Using a dedicated Ethernet adapter (allocated to the VM at the PCI level) has removed the excessive CPU load.  Similar rules apply to other virtualization platform.

Note that these recommendations are the "ideal case".  If you can't meet them at your site, do your best to get as close as possible.  But it is still better to have an a bit slower resource linked into the BeSTGRID DataFabric than not having a resource linked - these recommendations are not a dogma.

For a test server, installing iRODS in a standard virtual machine, using only a local directory as a storage resource is perfectly fine.

## Software selection

Each institution's iRODS server should be running:

- iRODS server.  All of the sites must be running the same version, at the time of writing, it is version 3.1 (with a selection of patches, see below).  The purpose of running a local iRODS server is two-fold: ℹ provide access to a local storage resource and (ii) provide a local entry point into the DataFabric.  The iRODS server will be configured as a slave server without support database interaction and metadata catalogue (these functions will be handled by the master server). A special case of this, a slave server with a local replica of the master database, is covered in a [separate Article](https://wiki.auckland.ac.nz/display/nesiproj/Installing+an+iRODS+Hot+Standby+Server).
- Davis (version 0.9.6 (dev) at the time of writing).  Davis provides the web and webDAV interface into iRODS - both to files on the local storage resource, and to the whole contents of the BeSTGRID DataFabric.  Installing Davis is optional - local users can still use the central Davis instance.  For performance and easier accessibility, an institutions can choose to deploy a local copy of Davis and recommend that to local users as the preferred entry point into the DataFabric.
- GridFTP: A GridFTP server connected to the iRODS virtual filesystem via the iRODS DSI module allows to access the iRODS contents from GridFTP clients, including [Globus.org](https://globus.org/).  Deploying a GridFTP server is optional - and probably unnecessary to be done at each institutions.

- Note: it is possible to run Davis and iRODS (and a GridFTP server) on separate systems - please interpret the relevant sections of the guide accordingly.
- Note also that theoretically, it would be possible to install only Davis and point it to the central master iRODS server - but, there would be little benefit from doing the whole exercise, and this guide does not recommend it.

# Prerequisites

## OS requirements

iRODS itself is supported on a number of systems, and the selection is more a matter of what integrates well with the storage system and with the institutional ICT infrastructure.  iRODS is known to run well on a number of Linux distributions, as well as other POSIX systems (AIX,...).  Unless there's another reason, the first recommendation would be to go for Linux, and within that, for CentOS 6.  But other choices would be very well acceptable for iRODS itself.

Davis is a web application, and should be installed together with the Shibboleth Service Provider software to facilitate Shibboleth login into Davis.  Installing (and possibly compiling) Shibboleth on some exotic architectures (such as AIX) could be a very challenging task - and that could be a reason for splitting Davis and iRODS into separate hosts (as it was done at Canterbury).

GridFTP comes in binary form from [and is available for a number of Linux distributions (as well as in source for any other POSIX-compliant platform).  Linux / CentOS 6 again recommended.

A 64-bit OS is preferred if available.

## Hardware requirements

- RAM (minimum/recommended):
	
- iRODS only:  1024MB / 2048MB
- iRODS+Davis: 2048MB / 4096MB
- Davis only:  1024MB / 2048MB

(The memory requirements can be halved for a test server).

- CPU: a reasonable up to date dual-core system.
- Swap: twice the RAM (recommended)

## Data resource integration

Your iRODS server needs to have direct filesystem access to the storage resource (as discussed above, performance matters and NFS mounts are highly discouraged).  All of the files stored on the resource will be owned by a single unix account (`rods`), and the permission setup should be simple (no need to grant root access to the filesystem).

## Network requirements

- The server needs a public (and static) IP address.
- The hostname must resolve to this IP address and the IP address must resolve back to the system's hostname.
- The server needs to be able to open INcoming and OUTgoing TCP connections to ports 80(http), 443(https), 1247(irods), 5432(postgres), 3306(MySQL), 8443(Shibboleth), 2811(gridftp), 7512(myproxy), and 50000-51000 (a range of 1001 ports).
- In addition to that, is requires INcoming + OUTgoing UDP to ports 50000-51000 (again a range of 1001 ports).
- In addition to that, INcoming TCP connections to port 5666 (Nagios NRPE monitoring)
- Note: The outgoing TCP traffic to ports 80 and 443 MAY go through a proxy (if the `http_proxy environment` variable is properly set), but all other traffic must be a direct connection.
- Note: the port 7512 (myproxy) can be OUTgoing only (used by Davis to fetch a proxy certificate for a user).
- Note: the port 8443 (Shibboleth) can be OUTgoing only (used by Shibboleth Service Provider for back-channel connections to Tuakiri IdPs).
- Note: the port 5432 (postgres) is for database replication (of the iRODS iCAT) across sites
- Note: the port 3306 (MySQL) is for database connections tracking user accounts.

**Note:** Remember to check the firewall settings on the server itself, as your default installation may restrict the use of these ports.

## Other requirements

- The system is setup to send outgoing email (i.e., typically, default SMTP relay would be set to the site's local SMTP server).
	
- Note: it is a requirement that the SMTP server does not overwrite the sender domain (in the From: address) - the domain must stay as the full hostname.

- The system is configured for time synchronization with a reliable time source.

## Certificates

Before proceeding with the certificate, [obtain a grid host certificate](/wiki/spaces/BeSTGRID/pages/3818228502)] for this system from the [APACGrid CA](http://wiki.arcs.org.au/bin/view/Main/HostCertificates).  The name in this certificate should be how other systems on the grid call your system (and must be the same as what your IP address resolves back to).  If installing Davis on a separate system, get also a separate grid certificate for this box (again with the CN matching the reverse lookup of the system's IP).

For Davis, **get a "commercial" certificate** that would be trust in major browsers.  This may depend on your site's policies and supplier preferences - just follow them, there's nothing special about this certificate, it only has to be trusted by browsers.  The name in this certificate should be how your users will call this system.  This may be the same as the irods system, or it can be a CNAME alias, or it can be a different hostname if Davis is installed on a separate system.

#### Installing host certificate

- Install your host certificate into `/etc/grid-security` as `hostcert.pem` / `hostkey.pem`


>  mkdir -p /etc/grid-security
>  chown -R root:root /etc/grid-security
>  chmod 755 /etc/grid-security
>  ...
>  chmod 644 /etc/grid-security/hostcert.pem
>  chmod 600 /etc/grid-security/hostkey.pem
>  chown root.root /etc/grid-security/hostcert.pem /etc/grid-security/hostkey.pem
>  mkdir -p /etc/grid-security
>  chown -R root:root /etc/grid-security
>  chmod 755 /etc/grid-security
>  ...
>  chmod 644 /etc/grid-security/hostcert.pem
>  chmod 600 /etc/grid-security/hostkey.pem
>  chown root.root /etc/grid-security/hostcert.pem /etc/grid-security/hostkey.pem

# Installing Globus

iRODS will be built with support for Globus and GSI (Grid Security Infrastructure).  Hence, the first part is to install Globus, including the development headers and libraries.  Besides installing Globus, it will also be necessary to properly setup GSI (host certificate, CA certificates, CRLs...)

Probably the easiest way to install Globus if using linux is from the package repositories that are available for a number of popular distributions.

Alternatively, Globus can be installed from VDT. These methods include tools for handling CA certificates and all the related tasks.  An alternative is to install Globus from source and install CA certificates separately.

## Installing Globus from package repository

- Add the repository for your distribution from [here](http://www.globus.org/toolkit/downloads/).


>  yum localinstall [http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo-latest.noarch.rpm](http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo-latest.noarch.rpm)
>  yum localinstall [http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo-latest.noarch.rpm](http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo-latest.noarch.rpm)

- Modify the priority of both repositories in `/etc/yum.repos.d/globus-toolkit-6-stable-el6.repo` (Globus-Toolkit-6-el6, Globus-Toolkit-6-Source-el6) to 90 (to avoid clashes with the OSG repo installed later):


>  priority=90
>  priority=90


- Install required packages


>  yum install globus-common-progs globus-gass-copy-progs globus-gsi-cert-utils-progs globus-proxy-utils myproxy uberftp 
>  yum install globus-common-progs globus-gass-copy-progs globus-gsi-cert-utils-progs globus-proxy-utils myproxy uberftp 

- And development packages needed for compiling iRODS:


>  yum install globus-gss-assist-devel
>  yum install libtool-ltdl-devel
>  yum install globus-gss-assist-devel
>  yum install libtool-ltdl-devel

- Create /etc/profile.d/globus.sh with


>  GLOBUS_TCP_PORT_RANGE="50000,51000"
>  export GLOBUS_TCP_PORT_RANGE
>  GLOBUS_TCP_PORT_RANGE="50000,51000"
>  export GLOBUS_TCP_PORT_RANGE

## Configure CA certificates

Install IGTF CA certificates from OSG repo

- First, install the OSG repo:


>  yum localinstall [http://repo.grid.iu.edu/osg/3.2/osg-3.2-el6-release-latest.rpm](http://repo.grid.iu.edu/osg/3.2/osg-3.2-el6-release-latest.rpm)
>  yum localinstall [http://repo.grid.iu.edu/osg/3.2/osg-3.2-el6-release-latest.rpm](http://repo.grid.iu.edu/osg/3.2/osg-3.2-el6-release-latest.rpm)

- And now install the IGTF certificates bundle from this repo.


>  yum install igtf-ca-certs
>  yum install igtf-ca-certs

- Install [Fetch-CRL](http://dist.eugridpma.info/distribution/util/fetch-crl/): your OS very likely has fetch-crl in the repositories, so:


>  yum install fetch-crl
>  service fetch-crl-cron start
>  chkconfig fetch-crl-cron on
>  yum install fetch-crl
>  service fetch-crl-cron start
>  chkconfig fetch-crl-cron on

- Install the Myproxyplus CA bundle to trust the NeSI MyProxy OAuth server (myproxyplus.nesi.org.nz)


>  mkdir /etc/grid-security/myproxyplus
>  cd /etc/grid-security/myproxyplus
>  wget -O - [https://myproxyplus.nesi.org.nz/certs/myproxyplus.nesi.org.nz_certificates.tar.gz](https://myproxyplus.nesi.org.nz/certs/myproxyplus.nesi.org.nz_certificates.tar.gz) | tar xzf -
>  cp -d * /etc/grid-security/certificates
>  mkdir /etc/grid-security/myproxyplus
>  cd /etc/grid-security/myproxyplus
>  wget -O - [https://myproxyplus.nesi.org.nz/certs/myproxyplus.nesi.org.nz_certificates.tar.gz](https://myproxyplus.nesi.org.nz/certs/myproxyplus.nesi.org.nz_certificates.tar.gz) | tar xzf -
>  cp -d * /etc/grid-security/certificates

# Installing Kerberos authentication for iRODS

- Create Kerberos service principle in the kerberos database (or have the sites Kerberos admin do this for you).


>  /usr/sbin/kadmin.local -r NESI.ORG.NZ -q "addprinc -randkey irods/irods.nesi.org.nz""
>  /usr/sbin/kadmin.local -r NESI.ORG.NZ -q "ktadd -k /tmp/irods.keytab irods/irods.nesi.org.nz"
>  scp /tmp/irods.keytab you@irods.nesi.org.nz:
>  /usr/sbin/kadmin.local -r NESI.ORG.NZ -q "addprinc -randkey irods/irods.nesi.org.nz""
>  /usr/sbin/kadmin.local -r NESI.ORG.NZ -q "ktadd -k /tmp/irods.keytab irods/irods.nesi.org.nz"
>  scp /tmp/irods.keytab you@irods.nesi.org.nz:

- On your iRODS server, copy the keytab somewhere rods can access it and make it secure so only rods can read it.


>  cp ~you/irods.keytab /etc/irods.keytab
>  chown rods:rods /etc/irods.keytab
>  chmod 600 /etc/irods.keytab
>  cp ~you/irods.keytab /etc/irods.keytab
>  chown rods:rods /etc/irods.keytab
>  chmod 600 /etc/irods.keytab

- /etc/krb5.conf needs NESI.ORG.NZ added to the list of Kerberos Realms. Aucklands looks like this

``` 

 [logging]
  default = FILE:/var/log/krb5libs.log
  kdc = FILE:/var/log/krb5kdc.log
  admin_server = FILE:/var/log/kadmind.log

 [libdefaults]
  default_realm = NESI.ORG.NZ
  dns_lookup_realm = false
  dns_lookup_kdc = false
  ticket_lifetime = 24h
  renew_lifetime = 7d
  forwardable = true
	 

 [realms]
  EC.AUCKLAND.AC.NZ = {
  kdc = kerberos.ec.auckland.ac.nz
  admin_server = kerberos.ec.auckland.ac.nz
 }

 NESI.ORG.NZ = {
  kdc = kerberos.nesi.org.nz
  admin_server = kerberos.nesi.org.nz
  default_domain = nesi.org.nz
 }

 [domain_realm]
  ec.auckland.ac.nz = EC.AUCKLAND.AC.NZ
  .ec.auckland.ac.nz = EC.AUCKLAND.AC.NZ
  nesi.org.nz = NESI.ORG.NZ
 .nesi.org.nz = NESI.ORG.NZ

```



- iRODS server/config/server.config needs KerberosName defined to be service principle from step 1


>  KerberosName irods/irods.nesi.org.nz@NESI.ORG.NZ
>  KerberosName irods/irods.nesi.org.nz@NESI.ORG.NZ

- Environment need to be setup so irods server can find the irods.keytab file (example is for bash environment).


>   KRB5_KTNAME=/etc/irods.keytab
>   export KRB5_KTNAME
>   irodsctl start
>   KRB5_KTNAME=/etc/irods.keytab
>   export KRB5_KTNAME
>   irodsctl start

- A user should have either NESI.ORG.NZ kerberos tickets, or NESI.ORG.NZ should trust the users home domain.
- Tickets could be obtained at login.


>  kinit -p user@NESI.ORG.NZ
> 1. OR
>  kinit -p user@EC.AUCKLAND.AC.NZ
>  kinit -p user@NESI.ORG.NZ
> 1. OR
>  kinit -p user@EC.AUCKLAND.AC.NZ

- Users DNs need to be set to their Kerberos principle


>  iadmin aua example.user user@NESI.ORG.NZ
>  iadmin aua example.user user@NESI.ORG.NZ

- Multiple Kerberos principles can be set for a user.


>  iadmin aua example.user user@EC.AUCKLAND.AC.NZ
>  iadmin aua example.user user@EC.AUCKLAND.AC.NZ

- User's ~/.irods/.irodsEnv file should be like this


>  irodsHost 'irods.nesi.org.nz'
>  irodsPort 1247
>  irodsDefResource 'nesi'
>  irodsZone 'nesi'
>  irodsAuthScheme 'KRB'
>  irodsServerDn 'irods/irods.nesi.org.nz@NESI.ORG.NZ'
>  irodsUserName a.user
>  irodsHost 'irods.nesi.org.nz'
>  irodsPort 1247
>  irodsDefResource 'nesi'
>  irodsZone 'nesi'
>  irodsAuthScheme 'KRB'
>  irodsServerDn 'irods/irods.nesi.org.nz@NESI.ORG.NZ'
>  irodsUserName a.user

- The users machine needs it's krb5.conf file to include NESI.ORG.NZ
- For Linux or Mac OS X the /etc/krb5.conf should have these entries (Replace EC.AUCKLAND.AC.NZ with your domain)

``` 

 [realms]
 NESI.ORG.NZ = {
   kdc = kerberos.nesi.org.nz
   admin_server = kerberos.nesi.org.nz
 }

 EC.AUCKLAND.AC.NZ = {
   kdc = kerberos.ec.auckland.ac.nz
 }

 [domain_realm]
  nesi.org.nz = NESI.ORG.NZ
  .nesi.org.nz = NESI.ORG.NZ
  ec.auckland.ac.nz = EC.AUCKLAND.AC.NZ
  .ec.auckland.ac.nz = EC.AUCKLAND.AC.NZ

```


# Kerberos Trust

- NESI.ORG.NZ trusts tickets issued by EC.AUCKLAND.AC.NZ (Both are MIT Kerberos5 Servers)

- 
- On kerberos.nesi.org.nz

``` 

 /usr/sbin/kadmin.local -r NESI.ORG.NZ -q "addprinc -pw <shared-secret> krbtgt/NESI.ORG.NZ@EC.AUCKLAND.AC.NZ"

```

- 
- On kerberos.ec.auckland.ac.nz

``` 

 /usr/sbin/kadmin.local -r EC.AUCKLAND.AC.NZ -q "addprinc -pw <shared-secret> krbtgt/NESI.ORG.NZ@EC.AUCKLAND.AC.NZ"

```

# Installing iRODS FUSE Client




- Expired tickets leave Fuse mounts inaccessible, but still mounted.
- Renew them on time

``` 

 kinit -R
 #or 
 kinit -r <time>

```

- Linux and Mac OS X users can mount with irodsFs

``` 

 irodsFs <directory>

```

- If not renewed on time (will need fusermount to be executable, or a setgid version for a user to unmount their directory)

``` 

 /bin/fusermount -uz <directory>

```

- To keep fusermount not directly executable compile this code and setguid fuse on the binary

``` 

cat > irodsFu.c
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	if(argc != 2)
          exit(-1);
	execl("/bin/fusermount", "/bin/fusermount", "-uz", argv[1], NULL);
        exit(-2); //should never get here
}

```

- Compile and setguid

``` 

cc -o irodsFu irodsFu.c
cp irodsFu /usr/local/bin
chgrp fuse /usr/local/bin/irodsFu
chmod g+s /usr/local/bin/irodsFu

```

- Even easier for users, is this script which finds and unmounts their iRODS Fuse mounts. (Nb. /bin/mount on different systems have slightly different formats, so this may need modifying)

``` 

#!/usr/bin/ruby
require 'etc'

`/bin/mount`.each_line do |l|
  if l =~ /^irodsFs/
    if Etc.getlogin == l.gsub(/^.*user=(.*)\)$/,'\1').chomp
      `/usr/local/bin/irodsFu #{l.gsub(/irodsFs on (.*) type .*/,'\1')}`
    end
  end
end

```

# Installing Postgres

*This step is only required if the server is going to be the master server, will hold a replica of the master database, or should have the ability to stand in as the master server in a high availability scenario.*

iRODS uses a database as storage for metadata (directories, permissions, etc.). Out of the box the iRODS distribution suggests to download the Postgres SQL sources and compile it during installation. From a system administration point of view this is not a good solution. The following instructions show how to install iRODS with a Postgres SQL database installed from a distribution repository.

As for the Postgres SQL version selection:

- iRODS 3.3.1 supports 8.4 or 9.2.
- [Discussion on iROD-chat on iRODS 3.3.x and external PostgreSQL 9.x database](https://groups.google.com/d/topic/irod-chat/Rq9MJgCGnP4/discussion) shows a very hackish solution is needed.
- As outcome of that, key patches for setup script are in [https://wiki.irods.org/index.php/iRODS_3.3_Patch_1](https://wiki.irods.org/index.php/iRODS_3.3_Patch_1)
- But that is not really needed at all, as the iRODS 3.3.1 setup scripts do the (almost) right job when provided the correct path to Postgres:

``` 
   Existing Postgres directory? /usr/pgsql-9.4
```
- The script will fail with creating an empty odbc.ini on the first run but will succeed on on a second try.


- Edit `/etc/yum.repos.d/CentOS-Base.repo`, add the following to the [base](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=base&linkCreation=true&fromPageId=3818228552) and [updates](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=updates&linkCreation=true&fromPageId=3818228552) sections:

``` 

exclude=postgresql*

```

- If needed: edit `/etc/yum.repos.d/pgdg-94-centos.repo` to  excluded libmemcached (which may create conflict with requirements of the shibboleth package)  (NOTE: Surprisingly, CentOS 6 shibboleth requires libmemcached while RHEL 6 shibboleth does not...)


>  exclude=libmemcached
>  exclude=libmemcached

- Pull in a few updates from pgdg repo:


>  yum update
>  yum update



>  chkconfig oidentd on
>  service oidentd start
>  chkconfig oidentd on
>  service oidentd start

- Initialize postgreSQL database:


>  service postgresql-9.4 initdb
>  service postgresql-9.4 initdb


- Configure service:


>  service postgresql-9.4 start
>  chkconfig postgresql-9.4 on
>  service postgresql-9.4 start
>  chkconfig postgresql-9.4 on


- When later configuring iRODS, entry the following response when prompted:

>     Existing Postgres directory? /usr/pgsql-9.4

## Increase Postgres connection limit

- Increase Postgres connection limit: edit `/var/lib/pgsql/9.4/data/postgresql.conf` (and restart Postgres):

``` 
max_connections = 1500
```
- Postgres connection settings are documented at [http://www.postgresql.org/docs/9.4/static/runtime-config-connection.html](http://www.postgresql.org/docs/9.4/static/runtime-config-connection.html)
- The connection settings must match the SysV IPC limits: [http://www.postgresql.org/docs/9.4/static/kernel-resources.html#SYSVIPC](http://www.postgresql.org/docs/9.4/static/kernel-resources.html#SYSVIPC)
- SEMMNS is the second parameter in output of `cat /proc/sys/kernel/sem` (default value 32000)
- SEMMNI is the last parameter there, default value 128 - this is the limiting factor - SEMMNI must be at least `at least ceil(max_connections / 16)`
- The number 1500 recommended enough is high enough for expected use and load, but still small enough to fit into the default Linux kernel SYSVIPC semaphore limit settings.
- More at [http://www.puschitz.com/TuningLinuxForOracle.shtml#TheSEMMNSParameter](http://www.puschitz.com/TuningLinuxForOracle.shtml#TheSEMMNSParameter)
- Note: any further increase of `max_connections` would require increasing SEMMNI: override `kernel.sem` in `/etc/sysctl.conf`: 

``` 
kernel.sem='250        32000   32      256'
```

- After editing the file, restart the PostgreSQL server - and watch logs to catch any errors (the server would refuse to start if the semaphore limits were not high enough for the requested connection limit):


>  tail f /var/lib/pgsql/9.4/data/pg_log/postgresql* /var/lib/pgsql/9.4/pgstartup.log 
>  service postgresql-9.4 restart
>  tail f /var/lib/pgsql/9.4/data/pg_log/postgresql* /var/lib/pgsql/9.4/pgstartup.log 
>  service postgresql-9.4 restart

# Installing iRODS

- Download iRODS from the [iRODS Downloads page](https://www.irods.org/index.php/Downloads) (as of May 2013, BeSTGRID DF is running iRODS 3.1)

- Create rods group and user (provide custom uid/gid as suitable for your environment)


>  groupadd rods
>  useradd -g rods -m -d /home/rods -c "iRODS" rods
>  groupadd rods
>  useradd -g rods -m -d /home/rods -c "iRODS" rods

 ***Note**: it is necessary to have full Globus env setup while running irodssetup (else finishSetup breaks with Cannot scramble password)

- Create /opt/iRODS owned by the `rods` user:


>  mkdir /opt/iRODS
>  chown rods.rods /opt/iRODS/
>  mkdir /opt/iRODS
>  chown rods.rods /opt/iRODS/

- Extract the downloaded tarball into /opt/iRODS as the `rods` user:


>  cd /opt/iRODS
>  tar xzf ~rods/inst/irods3.1.tgz
>  mv iRODS iRODS-3.1
>  ln -s iRODS-3.1 iRODS
>  cd iRODS
>  cd /opt/iRODS
>  tar xzf ~rods/inst/irods3.1.tgz
>  mv iRODS iRODS-3.1
>  ln -s iRODS-3.1 iRODS
>  cd iRODS

**Warning:** There is a bug that can cause the loss of data **without any error message or warning** when an **irods 3.2 slave server** is connected to an **irods 3.1 master server**. Therefore do not try to connect an irods 3.2 slave server to a 3.1 master.

**Warning** Authentication breaks between a 3.3.1 master and a 3.2 slave.

**Warning** due to the above and also other yet-not-known bugs, always deploy a server running **exactly the same version** as the current master - and when upgrading, upgrade all nodes at the **same time**. |

>  ***For iRODS 3.1**, apply the following patches:

- 
- [iRODS_3.1_Patch_2](https://www.irods.org/index.php/iRODS_3.1_Patch_2), locally available as [irods-3.1-patch-2-Naur.diff](/wiki/download/attachments/3818228552/Irods-3.1-patch-2-Naur.diff.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2)
- [Irods-3.1-fileOpr-race.patch](/wiki/download/attachments/3818228552/Irods-3.1-fileOpr-race.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), Rob Burrows' fix to a race condition (iRODS 3.1 version)
- [Irods-3.1-igsi-intsize-n-format-typecast.patch.txt](/wiki/download/attachments/3818228552/Irods-3.1-igsi-intsize-n-format-typecast.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), fixing mismatched int sizes in igsi.c
- [Irods-3.1-sec-no-anon-exec.patch.txt](/wiki/download/attachments/3818228552/Irods-3.1-sec-no-anon-exec.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2) to ℹ make server deny access on failed server-server authentication and (ii) deny script execution to ANONYMOUS user (as user rods)

>  ***For iRODS 3.2**, apply the following patches:

- 
- [iRODS_3.2_Patch_3](https://www.irods.org/index.php/iRODS_3.2_Patch_3) - needed for GSI builds
- [Irods-3.2-fileOpr-race.patch](/wiki/download/attachments/3818228552/Irods-3.2-fileOpr-race.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), Rob Burrows' fix to a race condition (iRODS 3.2 version)
- [Irods-3.2-igsi-format-typecast.patch.txt](/wiki/download/attachments/3818228552/Irods-3.2-igsi-format-typecast.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), fixing mismatched int sizes in igsi.c

>  ***For iRODS 3.3.1**, apply the following patches:

- 
- [Irods-3.3.1-fileOpr-race.patch](/wiki/download/attachments/3818228552/Irods-3.3.1-fileOpr-race.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), Rob Burrows' fix to a race condition (iRODS 3.3.1 version)
- [Irods-3.3.1-igsi-format-typecast.patch](/wiki/download/attachments/3818228552/Irods-3.3.1-igsi-format-typecast.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), fixing mismatched int sizes in string formatting in igsi.c
- [Irods-3.3.1-reInit-delay.patch](/wiki/download/attachments/3818228552/Irods-3.3.1-reInit-delay.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), fixing irods initialization (needed for correct ACL settings)
- [Irods-3.3.1-rule-exec-patches.patch](/wiki/download/attachments/3818228552/Irods-3.3.1-rule-exec-patches.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), fixing rule execution engine not to drop recurring rules - see https://groups.google.com/forum/#\!topic/irod-chat/fiR9swpScIo (original patches are [and [https://github.com/irods/irods-legacy/commit/033469ce88d1589c19c415aca85ca3632b44262a](https://github.com/irods/irods-legacy/commit/58078900d8da68ac12594874db34a58ed9d84267)])
- [Irods-3.3.1-patch1.patch](/wiki/download/attachments/3818228552/Irods-3.3.1-patch1.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), iRODS 3.3.1 patch as per [https://wiki.irods.org/index.php/iRODS_3.3.1.Patch_1](https://wiki.irods.org/index.php/iRODS_3.3.1.Patch_1) and https://groups.google.com/forum/#\!topic/irod-chat/cJy1pyyqxQk
- [Irods-3.3.1-gsi-proxy-auth-fed.patch](/wiki/download/attachments/3818228552/Irods-3.3.1-gsi-proxy-auth-fed.patch.txt?version=1&modificationDate=1539354156000&cacheVersion=1&api=v2), to correctly search for client user in GSI proxy authentication.

- Prepare answers to the questions asked by the iRODS installer. Namely:
- ***Make this Server ICAT-Enabled**.  Answering "yes" makes this server the master server.  Answer yes if either installing (or re-installing) the master server, or if installing a server to be ready to step-in for the master.  (In that case, change the configuration manually to point to the actual master afterwards).
- ***Host running iCAT-enabled iRODS server**.  For a test server, this is irods-dev.1.nesi.org.nz.  For a production server, this is df-data.uoo.nesi.org.nz
- ***Resource name for the resource created on your host**.  A recommended convention is to use your hostname as the name of the resource.
- ***Resource storage area directory** - this should be the filesystem path to your storage resource.  On a test server, it's acceptable to use the Vault directory created within the iRODS tree - but recommended to greate the directory elsewhere (files will not get lost in an iRODS upgrade).
- ***Existing iRODS admin login name (and password)**.  The login name is `rods`.  The author of this manual can tell you the password (which is different for the test server and for the production server).
- ***iRODS zone name**.  This is `BeSTGRID-DEV` for a test server and `BeSTGRID` for a production server.

- Run `./irodssetup` and enter the following non-default answers:

``` 

    Include additional prompts for advanced settings [no]? ''(leave the default as '''no''')''
    Build an iRODS server [yes]? ''(leave the default as '''yes''')''
    Make this Server ICAT-Enabled [yes]? '''no''' ''('''yes''' if you have installed a Postgres SQL database above)''
    Host running iCAT-enabled iRODS server? '''gridgwtest.canterbury.ac.nz'''
    iRODS zone name? '''BeSTGRID''' (or '''BeSTGRID-DEV''')
    iRODS login name [rods]? ''(leave the default as '''rods''')''
    Password [rods]? '''*irods_admin_password*'''
    Download and build a new Postgres DBMS? '''no'''
    Database type (postgres or mysql or oracle)? '''postgres'''
    Existing Postgres directory? '''/usr/pgsql-9.2'''
    ODBC type (unix or postgres)? '''unix'''
    Existing database login name? '''rods'''
    Password? '''*irods_db_password*'''
    Start and stop the database along with iRODS? '''no'''
    Include GSI [no]? '''yes'''
    GLOBUS_LOCATION? '''/usr/lib64/globus'''
    GSI Install Type to use? '''none'''
    Include Kerberos? '''yes'''
    KRB_LOCATION? '''/usr/include/krb5'''
    Include the NCCS Auditing extensions? '''no'''
    Save configuration (irods.config) [yes]? '''yes''' 
    Start iRODS build [yes]? '''no'''

```

- Edit /opt/iRODS/iRODS/config/irods.config and add: 

``` 
$CCFLAGS = '-fPIC';
```
- Run `./irodsdsetup` again and this time, start the build.

- Create a copy of the host certificate as irodscert/key.pem, readable by the rods user:

``` 

 cd /etc/grid-security/
 cp hostcert.pem irodscert.pem
 cp hostkey.pem irodskey.pem
 chown rods.rods irods{cert,key}.pem
 chmod 600 irodskey.pem
 chmod 644 irodscert.pem

```

- Configure irods environment `/etc/profile.d/irods.sh`

``` 

# if Globus installed in non-standard location
GLOBUS_LOCATION=/opt/globus	 
export GLOBUS_LOCATION	 
. $GLOBUS_LOCATION/etc/globus-user-env.sh

IRODS_HOME=/opt/iRODS/iRODS
if ! echo ${PATH} | /bin/grep -q ${IRODS_HOME}/clients/icommands/bin ; then
   PATH=${IRODS_HOME}/clients/icommands/bin:${PATH}
fi
export LD_LIBRARY_PATH IRODS_HOME PATH

MYPROXY_SERVER=myproxy.nesi.org.nz
export MYPROXY_SERVER

```

- Reload the environment


>  . /etc/profile
>  . /etc/profile

- iRODS should have already been started by the setup script.  As `rods`, first check if iRODS is already running with:

``` 
/opt/iRODS/iRODS/irodsctl status
```
- Note: on a slave server, you only want an iRODS server running (not a database server)
- And if not running, start irods with:

``` 
/opt/iRODS/iRODS/irodsctl start
```

# iRODS post-configuration

## Public and Anonymous access

There are two ways of making data "publicly" available in iRODS - either making them available to all iRODS users (anyone with a valid login), and making them available without requiring a login.

The first is achieved by giving access to group `public` - where each iRODS user is automatically a member.

The latter is achieved by giving access to user `anonymous` (which is **NOT** included in the group `public`), and tuning the Davis and iRODS configuration appropriately.

The following steps need to be implemented once after creating the iRODS zone to give appropriate read permissions at top level:

- Setup directory permissions

``` 

 imkdir /BeSTGRID/projects
 ichmod read public /
 ichmod read public /BeSTGRID
 ichmod read public /BeSTGRID/home
 ichmod read public /BeSTGRID/projects
 ichmod read public /BeSTGRID/trash   
 ichmod read public /BeSTGRID/trash/home
 ichmod read public /BeSTGRID/trash/projects
 imkdir /BeSTGRID/home/__INBOX  
 imkdir /BeSTGRID/home/__PUBLIC
 ichmod read public /BeSTGRID/home/__INBOX  
 ichmod read public /BeSTGRID/home/__PUBLIC

```

- Create the `anonymous` user (reserved name), login will work with any password (run the following as the rods user):


>  iadmin mkuser anonymous rodsuser
>  iadmin mkuser anonymous rodsuser

The following steps make the collections under [https://df.bestgrid.org/BeSTGRID/projects/public](https://df.bestgrid.org/BeSTGRID/projects/public) available without a login:

- Create /BeSTGRID/projects/public and /BeSTGRID/projects/open as publicly AND anonymously browsable:
	
- Give the directories read-only permissions to group `public` and user `anonymous`
- **Mark it recursive to give permissions to all*existing** files
- **Mark it STICKY to give permissions to all*future** files

``` 

imkdir /BeSTGRID/projects/public
imkdir /BeSTGRID/projects/open
ichmod read anonymous /BeSTGRID/projects/public
ichmod read public /BeSTGRID/projects/public
ichmod read anonymous /BeSTGRID/projects/open
ichmod read public /BeSTGRID/projects/open
ichmod inherit /BeSTGRID/projects/public
ichmod inherit /BeSTGRID/projects/open

```


## iRODS Security Enhancements

These enhancements are based on [these](https://www.irods.org/index.php/Secure_Installation) notes.

- Edit `$IRODS_HOME/config/irods.config`. Find all instances of `$DATABASE_ADMIN_PASSWORD` and `$IRODS_ADMIN_PASSWORD` and replace the plain text passwords with `REMOVED`. (Do not delete / comment out the lines however, this will break scripts like `irodsctl`. **Attention:** This will break `$IRODS_HOME/irodssetup`, and make it overwrite the scrambled admin password if it is run. Make sure you store your admin password in a save place.)

- Edit `$IRODS_HOME/installLogs/finishSetup.log`. Find all instances of `$PGPASSWORD` and replace the plain text passwords with `REMOVED`.

- Create the directory `$IRODS_HOME/server/bin/cmd_disabled`. Move all example files that are in `$IRODS_HOME/server/bin/cmd` to `$IRODS_HOME/server/bin/cmd_disabled`.

- Enable server - server authentication:
	
- Edit `$IRODS_HOME/server/config/server.config`, add

``` 

 LocalZoneSID <this zone's server id>

```

The author of this manual can provide you with the correct server id.

## User Management

- Install default iRODS rules for BeSTGRID
	
- Download [bestgrid.re](https://raw.githubusercontent.com/nesi/BeSTGRID-legacy/master/df/scripts/bestgrid.re) and install it as `$IRODS_HOME/server/config/reConfigs/bestgrid.re`
- Edit the file and replace all occurrences of `DEFAULT_RESOURCE` with the name of your local iRODS resource and all occurrences of `DEFAULT_RESOURCE_GROUP` with the name of the resource group (either `BeSTGRID-DEV-REPLISET` or `BeSTGRID-REPLISET`).
- Edit `$IRODS_HOME/server/config/reConfigs/core.re` and comment out the following lines (they are superseded by corresponding settings in `$IRODS_HOME/server/config/reConfigs/bestgrid.re`):

``` 

 acAclPolicy { }
 acGetUserByDN(*arg,*OUT) { }
 acPreprocForDataObjOpen { }
 acSetVaultPathPolicy {msiSetGraftPathScheme("no","1"); }
 acSetReServerNumProc {msiSetReServerNumProc("default"); }

```
- Activate the changes by editing $IRODS_HOME/server/config/server.config: add bestgrid to the reRuleSet line: 

``` 
reRuleSet   bestgrid,core
```

Note: at a later stage, we will be setting up automatic updates of rule files.  But not now.

- Install the BeSTGRID [createUser](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/createUser) script into `$IRODS_HOME/server/bin/cmd/createUser`

1. Install [createInbox.sh](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/createInbox.sh) as `$IRODS_HOME/server/bin/createInbox.sh`

- Install the BeSTGRID [createUser.config](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/createUser.config) file into `$IRODS_HOME/server/config/createUser.config` and customize this file accordingly:
	
- change the path to the iCommands and to the createInbox script if you installed iRODS into a different location (and had a good reason for doing so)
- configure the email address where account creation notifications should go.  Direct it to yourself for a test server and leave `help at bestgrid.org` for a production server.
- if your server's hostname is not suitable to be used as the From: domain in the notifications (`rods@`hostname``), provide an alternative hostname in the `H` directive (and uncomment it)
- configure the iRODS master server hostname in the `M` directive (gridgwtest.canterbury.ac.nz for a test server, ngdata.canterbury.ac.nz for a production server) (and uncomment the directive)
		
- Note: in order for account creation to work on a slave (with setting a password), createUser must issue the `iadmin moduser password` command to the Master server: e.g.

``` 
irodsHost=ngdata.canterbury.ac.nz iadmin moduser vladimir.mencl password test
```

- If your server has alternative hostnames to be referred to, configure all of them as aliases to `localhost` by listing them (with the proper one first) on a single line in `server/config/irodsHost`.  Example (!!!use your irods hostname here):

``` 
localhost hpcgrid1.canterbury.ac.nz hpcgrid1 hpcgrid1-c
```

## File autodeletion

An additional feature rolled out into the DataFabric (as of June 2015) is file autodeletion.

The requirement came from one of the user groups to have a specific directory where any files uploaded get automatically deleted after a certain period of time.

The directory is `_``autodelete``_` and the time period is one week (168 hours).

Any new user created on the DataFabric gets a directory called `_``autodelete``_` created in their home directory by the `createInbox.sh` script (invoked from `createUser`).

Any file uploaded into such a directory would get it's expiry (system metadata) set to the current time plus 168 hours; this is done via an acPostProcForPut rule in [bestgrid.re](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/bestgrid.re).

The automatic purging is done via a period rule stored in [setup_purge_expired_files.r](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/autodelete/setup_purge_expired_files.r).

This file needs to be loaded once (for the whole DataFabric) with:

>  irule -F setup_purge_expired_files.r

The rule gets executed periodically (hourly) on the master node in the rule execution server.

To query the status of the period rule, use: 

>  iqstat 

To remove the rule (if ever needed), use:

``` 
 iqdel <id>
```

To check the system metadata on a file, use: 

>  isysmeta ls /BeSTGRID/home/user.name/_*autodelete*_/Filename.ext

## Turning iRODS on

- Download and install the [irods service control script](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/init-d/irods) into `/etc/rc.d/init.d` as `irods` - and make it executable


>  wget -O /etc/rc.d/init.d/irods [https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/init-d/irods](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/init-d/irods)
>  chmod +x /etc/rc.d/init.d/irods
>  wget -O /etc/rc.d/init.d/irods [https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/init-d/irods](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/init-d/irods)
>  chmod +x /etc/rc.d/init.d/irods

- Add irods as a service automatically started with:


>  chkconfig --add irods
>  chkconfig irods on
>  chkconfig --add irods
>  chkconfig irods on

- This script starts irods as the `rods` user and sets the X509_USER_CERT / X509_USER_KEY variables to the host certificate/key.

- If running Postgres (this would be the case only on a master server, or in a replicated database setup), do the same for the postgres service control script:

``` 

 chkconfig --add postgresql-<version>
 chkconfig postgresql-<version> on

```

- If running Postgres, then also tweak your /etc/rc.d/init.d/irods to point to the correct location (should be `/opt/iRODS/Postgres/pgsql/lib`) in the `LD_LIBRARY_PATH` settings).

- If your server is having a problem initializing GSI (cannot find the certificate), set this variable also in the internal perl startup script: edit `$IRODS_HOME/scripts/perl/irodsctl.pl` and add (around line 258, after section "Overrides", before section "Check usage")

``` 

 $ENV{'X509_USER_CERT'} = '/etc/grid-security/irodscert.pem';
 $ENV{'X509_USER_KEY'} =  '/etc/grid-security/irodskey.pem';

```

- Restart iRODS so that it's running with the proper environment:
	
- First as `rods`, stop the already running iRODS server:

``` 
/opt/iRODS/iRODS/irodsctl stop
```
- Then as `root`, start iRODS via the service control script:

``` 
service irods start
```

# Configure iRODS High Availability

If you are configuring a set of servers for iRODS high availability, this is the point to use the instructions in [Installing an iRODS Hot Standby Server](https://wiki.auckland.ac.nz/display/nesiproj/Installing+an+iRODS+Hot+Standby+Server) to configure database replication.

# Install PHP

>  yum install php

- On CentOS/RHEL 6, enable short syntax (used by various PHP scripts): edit `/etc/php.ini` and set: 

``` 
short_open_tag = On
```
- Note: while most PHP code is now correctly prefixed with 

``` 
<?php .. ?>
```

, expressions with 

``` 
<?= ... ?>
```

 would not work without `short_open_tag`.  From [PHP 5.4 onwards](http://php.net/manual/en/ini.core.php#ini.short-open-tag), we should be able to go with keeping `short_open_tag = Off`.

# Deploying Davis

Davis is deployed as a standalone web application (it comes with the Jetty web applications container).  It is recommended to deploy Davis behind Apache - in this case, Apache can take care of the https socket, and also of providing the Shibboleth login on the plain http interface.  Hence, as a prerequisite to this section, the system where Davis will be installed should have Apache (and mod_ssl) already installed.  Also, one of the first steps will be installing the Shibboleth SP software and registering the system into Tuakiri - this is covered in a separate guide linked below.  It is possible to skip this part and go without Shibboleth.  Davis would be still providing the web and webDAV interface on https (authenticating via a MyProxy username and password) - and the Shibboleth interface can be added later.

Davis normally resets the internal iRODS password associated with an iRODS user account during a Shibboleth login - so that Davis can then connect as a user.

- An alternative login method has been implemented as an extension to Davis for the BeSTGRID DataFabric
- Please read more at [DataFabric Davis enhancement - not resetting iRODS password on Shibboleth login](/wiki/spaces/BeSTGRID/pages/3818228914)

The following section describes the installation of a patched version of Davis that includes this patch. This way, users logging into the data fabric with Shibboleth can set an iRODS password of their own choice and use it to access the data fabric from outside a web browser.

Before proceeding with this section, agree on the hostname users would using for accessing this system (e.g., bestgrid-df.site.domain).  For the rest of this section, the name would be referred to as DAVIS-HOSTNAME.  Please substitute accordingly.

You will need X509 certificates issued in the name of DAVIS-HOSTNAME before proceeding.  For a production server, these certificates MUST be issued by a CA trusted by the major web browsers.

**Note**: To upgrade Davis to a newer release, follow the notes on [upgrading davis](/wiki/spaces/BeSTGRID/pages/3818228549#IRODSdeploymentplan-UpgradingDavis) - which extract the steps that need to be re-applied to a new Davis installation.

- Shibboleth: setup the system running Davis as a [Shibboleth 2.x SP](https://tuakiri.ac.nz/confluence/display/Tuakiri/Installing+Shibboleth+2.x+SP+on+RedHat+based+Linux), using DAVIS-HOSTNAME in the URLs and in the entityID.
	
- When registering into the federation, ask for the following attributes:
		
- required: auEduPersonSharedToken, commonName, email (needed for user account creation)
- optional: (tracked in user database): eduPersonAffiliation organizationName
- optional: future access control: assurance
- As the lifetime of the Davis session directly depends on the Shibboleth session, do not reduce the timeouts - and even leave cookies not marked as secure, so that they are sent over the plain http connection to Davis.

- Configure Apache:
- **SSL: use*DAVIS-HOSTNAME**:443 as the ServerName in the SSL virtual host and use the proper certificates

``` 

@@ -85,2 +85,3 @@
#ServerName www.example.com:443
+ServerName DAVIS-HOSTNAME:443

@@ -111,3 +112,3 @@
 # certificate can be generated using the genkey(1) command.
-SSLCertificateFile /etc/pki/tls/certs/localhost.crt
+SSLCertificateFile /etc/pki/tls/certs/DAVIS-HOSTNAME.crt
 
@@ -118,3 +119,3 @@
 #   both in parallel (to also allow the use of DSA ciphers, etc.)
-SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
+SSLCertificateKeyFile /etc/pki/tls/private/DAVIS-HOSTNAME.key
 
@@ -128,2 +129,3 @@
 #SSLCertificateChainFile /etc/pki/tls/certs/server-chain.crt
+SSLCertificateChainFile /etc/pki/tls/certs/CA-CERTIFICATE-CHAIN.crt
 

```

- Install prerequisites (Davis runs well under OpenJDK, but would also run under Sun JDK):


>  yum install git java-1.7.0-openjdk java-1.7.0-openjdk-devel ant
>  yum install git java-1.7.0-openjdk java-1.7.0-openjdk-devel ant

- Create a `davis` account Davis will run under


>  groupadd davis
>  useradd -g davis -m -d /home/davis -c "Davis webDAV" davis
>  groupadd davis
>  useradd -g davis -m -d /home/davis -c "Davis webDAV" davis

- Create `/opt/davis` and make it owned by `davis`


>  mkdir /opt/davis
>  chown davis.davis /opt/davis
>  mkdir /opt/davis
>  chown davis.davis /opt/davis


- Copy /opt/davis/davis/bin/jetty.sh into /etc/rc.d/init.d/davis


>  ln -s /opt/davis/davis/bin/jetty.sh /etc/rc.d/init.d/davis
>  chmod +x /opt/davis/davis/bin/jetty.sh
>  ln -s /opt/davis/davis/bin/jetty.sh /etc/rc.d/init.d/davis
>  chmod +x /opt/davis/davis/bin/jetty.sh

- Create /etc/default/jetty with configuration for Jetty (the web apps container Davis runs in).  Change values as needed for your environment.


>  JETTY_HOME=/opt/davis/davis
>  JETTY_USER=davis
>  JAVA_HOME=/usr/lib/jvm/java
>  JAVA_OPTIONS="-server -Xms512m -Xmx768m"
>  JETTY_HOME=/opt/davis/davis
>  JETTY_USER=davis
>  JAVA_HOME=/usr/lib/jvm/java
>  JAVA_OPTIONS="-server -Xms512m -Xmx768m"

- Configure jetty: make sure SSL is disabled and AJP enabled in `/opt/davis/davis/etc/jetty.xml` (ref: [http://docs.codehaus.org/display/JETTY/Configuring+Connectors](http://docs.codehaus.org/display/JETTY/Configuring+Connectors))

- Rather than modifying the default `httpd.conf` configuration file, we create a separate configuration file for the DataFabric-specific Apache configuration directives.  By putting the file into `/etc/httpd/conf.d`, this file will be automatically included in the Apache configuration.
	
- Create `/etc/httpd/conf.d/davis.conf` and with following contents (and with more local configuration to follow later):
		
- Make Apache pass requests for `/BeSTGRID` (on a production server) or `/BeSTGRID-DEV` (on a test server), and also pass requests for /quickshare:
- Also require Shibboleth for /BeSTGRID on http frontend - skip the Location snippet if not installing Shibboleth yet

``` 

ProxyRequests Off
ProxyPreserveHost On

ProxyPass /BeSTGRID ajp://localhost:8009/BeSTGRID flushpackets=on
ProxyPass /quickshare ajp://localhost:8009/quickshare flushpackets=on

<VirtualHost *:80>
  ServerName DAVIS-HOSTNAME
  DocumentRoot "/var/www/html"

  <Location /BeSTGRID>
  AuthType shibboleth
  ShibRequireSession On
  ShibUseHeaders On
  require shibboleth
  </Location>
</VirtualHost>

```

- Note: because we are configuring ProxyPass only for the iRODS zone, we must make the `dojoroot`, `images`, and `include` directories visible to Apache


>  ln -s /opt/davis/davis/webapps/dojoroot /var/www/html
>  ln -s /opt/davis/davis/webapps/images /var/www/html
>  ln -s /opt/davis/davis/webapps/include /var/www/html
>  ln -s /opt/davis/davis/webapps/dojoroot /var/www/html
>  ln -s /opt/davis/davis/webapps/images /var/www/html
>  ln -s /opt/davis/davis/webapps/include /var/www/html

- Davis (or rather the Jetty web service container it's running its)  wants to store the web server request log into `$HOME/logs`.  To have all the logs in one place, make this a symbolic link into the davis log directory.  Run the following command as `davis`:


>  ln -s /opt/davis/davis/logs ~davis/logs
>  ln -s /opt/davis/davis/logs ~davis/logs

- Enable auto startup (start later after configuring):


>  chkconfig --add davis
>  chkconfig --add davis

## Customize Davis

- Create `/opt/davis/davis/webapps/root/WEB-INF/davis-host.properties`

- Modify the configuration accordingly):
- ***zone-name** - `BeSTGRID` for a production server and `BeSTGRID-DEV` for a test server
- ***server-name**: your iRODS server hostname
- ***default-resource**: your preferred default iRODS resource (typically our local iRODS resource)
- ***favicon**: replace DAVIS-HOSTNAME with proper value
- ***insecureConnection**: change to `shib` if you have successfully installed Shibboleth

``` 

webdavis.Log.threshold=WARNING
#webdavis.Log.threshold=DEBUG

shared-token-header-name=auEduPersonSharedToken
cn-header-name=cn
admin-cert-file=/etc/grid-security/daviscert.pem
admin-key-file=/etc/grid-security/daviskey.pem

organisation-name=BeSTGRID
authentication-realm=BeSTGRID Data Fabric
# use new logo from BeSTGRID branding
organisation-logo=/images/bestgrid_logo.png
organisation-logo-geometry=347x65
#organisation-logo=/images/bestgrid-logo-32x32.gif
#organisation-logo-geometry=32x32
favicon=http://DAVIS-HOSTNAME/favicon.ico
organisation-support=NeSI staff at datafabric@nesi.org.nz
helpURL=http://technical.bestgrid.org/index.php/Using_the_DataFabric

anonymousCredentials=irods\\anonymous:anything
anonymousCollections=/BeSTGRID/projects/public,/BeSTGRID/projects/open,/BeSTGRID-DEV/projects/public,/BeSTGRID-DEV/projects/open

myproxy-server=myproxy.nesi.org.nz
server-type=irods
server-port=1247
#default-idp=arcs idp
#default-idp=myproxy
default-idp=irods
zone-name=BeSTGRID

server-name=iRODS-HOSTNAME # ngdata.canterbury.ac.nz
default-resource=iRODS-RESOURCE-NAME # griddata.canterbury.ac.nz
insecureConnection=block

# new options in Davis 0.9.3
shib-init-path=/Shibboleth.sso/Login
disable-replicas-button=true
ui-include-head=<!-- Google Analytics code -->    \
<!-- put the code snippet here  with -->          \
<!-- trailing backslashes on all but last line -->          

administrators=firstname.lastname,joe.otheradmin

#to allow MacOS computers connect using finder
webdavUserAgents=WebDAVFS
browserUserAgents=

login-image=/images/bestgrid_logo.png

# configure later: QuickShare

# not loading: PID objects

```
- Disable ARCS default configuration:


>  cd /opt/davis/davis/webapps/root/WEB-INF
>  mv davis-organisation.properties davis-organisation.properties.disabled
>  cd /opt/davis/davis/webapps/root/WEB-INF
>  mv davis-organisation.properties davis-organisation.properties.disabled

- Install BeSTGRID logo and favourite icon: download the gif files from [https://github.com/nesi/BeSTGRID-legacy/tree/master/df/UI/images](https://github.com/nesi/BeSTGRID-legacy/tree/master/df/UI/images) and
	
- Put bestgrid-logo-16x16.gif into `/var/www/html` and symlink it as `favicon.ico` 

``` 
ln -s bestgrid-logo-16x16.gif favicon.ico
```
- Put bestgrid-logo-32x32.gif and bestgrid_logo.png into `/opt/davis/davis/webapps/images`

- Install BeSTGRID branding and UI addons:
	
- Get the latest BeSTGRID branding and UI addons from Git: 

``` 
git clone https://github.com/nesi/BeSTGRID-legacy.git ~/BeSTGRID-legacy
```
- Note: there also used to be a (now unmaintained) tarball at [http://df.bestgrid.org/BeSTGRID/home/technical/branding.tar.gz](http://df.bestgrid.org/BeSTGRID/home/technical/branding.tar.gz)
- Overwrrite default stylesheet:

``` 
cp ~/inst/df-ui/include/davis.css /opt/davis/davis/webapps/include/
```
- Install images:

``` 
cp ~/inst/df-ui/images/* /opt/davis/davis/webapps/images/
```

- Make the host certificate available to the davis user as daviscert.pem + daviskey.pem (this is only needed if installing Shibboleth - Davis then uses it's own certificate to talk to iRODS)


>  cd /etc/grid-security
>  cp hostcert.pem daviscert.pem
>  cp hostkey.pem daviskey.pem
> 1. for ASGCCA keys, recode them instead with
>  openssl rsa -in /etc/grid-security/hostkey.pem -out /etc/grid-security/daviskey.pem
>  chown davis.davis daviscert.pem daviskey.pem
>  cd /etc/grid-security
>  cp hostcert.pem daviscert.pem
>  cp hostkey.pem daviskey.pem
> 1. for ASGCCA keys, recode them instead with
>  openssl rsa -in /etc/grid-security/hostkey.pem -out /etc/grid-security/daviskey.pem
>  chown davis.davis daviscert.pem daviskey.pem


## Monitoring Davis use with Google Analytics

To monitor the Davis use (via a browser) with Google Analytics, use the Davis `ui-include-head` configuration directive in davis-host.properties to insert the javascript code snippet into the UI HTML just before the closing 

``` 
</head
```

 tag (note that this is preferred over modifying `/opt/davis/davis/webapps/root/WEB-INF/ui.html`).

Example:

``` 

ui-include-head=<!-- Google Analytics -->       \n\
<script type="text/javascript">                 \n\
  var _gaq = _gaq || [];                        \n\
  _gaq.push(['_setAccount', 'UA-1896366-16']);  \n\
  _gaq.push(['_trackPageview']);                \n\
  (function() {                                 \n\
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; \n\
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';    \n\
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);    \n\
  })();                                         \n\
</script>

```

## Adding hook for user registration

Edit `davis-host.properties` again and add the additional code to `ui-include-head` for registering users as documented in the [DataFabric Administrator's guide - Registering users](/wiki/spaces/BeSTGRID/pages/3818228984#AdministeringtheDataFabric-RegisteringDataFabricusers).

## Adding ZenDesk support tab

If this site is to have the ZenDesk support tab, add an entry in `davis-host.properties` for `ui-include-body` with the following code:

``` 

<script type="text/javascript">
if (typeof(Zenbox) !== "undefined") {
Zenbox.init({
dropboxID: "20113316",
url: "https://nesi.zendesk.com",
tabID: "Support",
tabColor: "#2ba0c2",
tabPosition: "Right"
});
}
</script>
<style media="screen, projection" type="text/css">
#zenbox_tab #feedback_tab_text {
font-size: .9em;
font-weight: bold;
margin: 25px auto;
text-align: center;
color: #fff;
letter-spacing: .09em;
font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
}
 
#zenbox_tab {
font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
border: 0;
margin: 0;
cursor: pointer;
overflow: hidden;
position: fixed;
top: 120px;
height: 15px;
min-width: 90px;
z-index: 10000;
white-space: nowrap;
padding: 0 10px 35px 10px;
background-color: #2ba0c2;
right: 0px;
}
</style>

```

- This is a slightly modified version of the original code provide by Nat at [https://gist.github.com/natted/4107963](https://gist.github.com/natted/4107963)
	
- On 2013-02-08, the top margin has been changed from 150px to 120px to match the changes done to davis.css
- Further information can be found at [https://wiki.auckland.ac.nz/display/nesiproj/Embedding+ZenDesk+into+web+applications](https://wiki.auckland.ac.nz/display/nesiproj/Embedding+ZenDesk+into+web+applications) and [https://jira.auckland.ac.nz/browse/NESI-622](https://jira.auckland.ac.nz/browse/NESI-622)

## Davis GSI configuration

Davis needs proper GSI configuration for authenticating to the iRODS server - not only the host certificate configured above, but also the full set of trusted CAs, and CRLs.  If you are installing Davis on the same system as iRODS, this has already been done when installing Globus.  

If you are installing Davis on a standalone system, install the CA certificate as per above in the [#Installing Globus](#InstallinganiRODSslaveserver-InstallingGlobus) section.

## Configuring Shibboleth login not to reset user password


- Activate this extension by adding the following two lines to the davis-host.properties file.


>  admin-creds-dir=/opt/davis/cred
>  shib-use-admin-login=true
>  admin-creds-dir=/opt/davis/cred
>  shib-use-admin-login=true

## Installing additional pages - landing page and setting and changing an iRODS password

These pages are part of the [enhancement discussed in the previous section](/wiki/spaces/BeSTGRID/pages/3818228914).

- A Shibboleth-protected page for setting a password.
	
- This page is typically at: /dfpassword/
- There is also a page that allows changing password based on an existing iRODS login (suitable for people without a Shibboleth login).
	
- This page is typically at: /dfchangepw/

Get the source code for these pages from Git: 

``` 
git clone https://github.com/nesi/BeSTGRID-legacy.git ~/BeSTGRID-legacy
```

- Install dfpassword code under /var/www/html/dfpassword
- Install dfchangepw code under /var/www/html/dfchangepw

- Add the following code into `/etc/httpd/conf.d/davis.conf` - to:
	
1. Protect the dfpassword page with Shibboleth (session required)
2. Protect the iRODS credentials directory under that page so that noone can access the directory via Apache.
3. Disable directory listing.

``` 

<Location /dfpassword>
  AuthType shibboleth
  ShibRequestSetting requireSession 1
  require shibboleth
  Options -Indexes
</Location>

<Location /dfpassword/.htirods>
  order deny,allow
  deny from all
</Location>

```

- Create iRODS credentials accessible by Apache


>  mkdir -p /var/www/html/dfpassword/.htirods   
>  chown apache.apache /var/www/html/dfpassword/.htirods
>  chmod 700 /var/www/html/dfpassword/.htirods
>  su -s /bin/bash - apache
>  HOME=/var/www/html/dfpassword/.htirods iinit
> 1. fill in all details for a rods login TO THE MASTER SERVER
>  mkdir -p /var/www/html/dfpassword/.htirods   
>  chown apache.apache /var/www/html/dfpassword/.htirods
>  chmod 700 /var/www/html/dfpassword/.htirods
>  su -s /bin/bash - apache
>  HOME=/var/www/html/dfpassword/.htirods iinit
> 1. fill in all details for a rods login TO THE MASTER SERVER

- Create a log directory and a log file writable by Apache:


>  mkdir /var/www/html/dfpassword/.htirods/.htlog/              
>  touch /var/www/html/dfpassword/.htirods/.htlog/passwordchange.log
>  chown apache.apache /var/www/html/dfpassword/.htirods/.htlog/passwordchange.log
>  mkdir /var/www/html/dfpassword/.htirods/.htlog/              
>  touch /var/www/html/dfpassword/.htirods/.htlog/passwordchange.log
>  chown apache.apache /var/www/html/dfpassword/.htirods/.htlog/passwordchange.log

- Configure the config.php files in both dfpassword and dfchangepw to match your site specific details.

- Apply [ui.html-096-password-button.diff](https://raw.githubusercontent.com/nesi/BeSTGRID-legacy/master/df/UI/html/ui.html-096-password-button.diff) to `/opt/davis/davis/webapps/root/WEB-INF` to enable buttons pointing to the dfpassword and dfchangepw pages.

``` 

 cd /opt/davis/davis/webapps/root/WEB-INF
 patch < /home/davis/BeSTGRID-legacy/inst/df/UI/html/ui.html-096-password-button.diff

```

The pages should be ready to go now.

Also remember to deploy the landing page:

- Install the following files from [https://github.com/nesi/BeSTGRID-legacy/tree/master/df/UI/html/frontpage](https://github.com/nesi/BeSTGRID-legacy/tree/master/df/UI/html/frontpage) into `/var/www/html`:


>  bg_style.css
>  config.php
>  index.php
>  read-properties.php
>  bg_style.css
>  config.php
>  index.php
>  read-properties.php

- Customize `config.php` if needed (the default values should be ready to use on the production BeSTGRID DataFabric):
	
- For BeSTGRID-DEV, use:

``` 

$df_servers = "gridgwtest.canterbury.ac.nz:ngdata.vuw.ac.nz";

```
- Other parameters (df_zone, df_path, df_title are read from the Davis properties file).
- Please note that as of 2014-11-21, this page no longer uses the geoip binary on the server and instead measures the connection tothe configured servers from the browser.  For this, all servers must be configured with [CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) enabled for /favicon.ico.
- Add the following snippet to `/etc/httpd/conf.d/davis.conf` on all servers involved:
	
- For Apache 2.2.9  and later (CentOS 6 and later), use:

``` 

<Location /favicon.ico>
    Header merge "Access-Control-Allow-Origin" "*"
</Location>

```
- For older versions of Apache (CentOS 5), use:

``` 

<Location /favicon.ico>
    Header append "Access-Control-Allow-Origin" "*"
</Location>

```

Install user registration page (as originally documente in [Administering the DataFabric#Registering DataFabric users](/wiki/spaces/BeSTGRID/pages/3818228984#AdministeringtheDataFabric-RegisteringDataFabricusers))


- If your system is running with SELinux enabled and in enforcing mode, make the following changes so that Apache can invoke iCommands (and GeoIP):

- Allow Apache to exec scripts:


>  setsebool -P httpd_ssi_exec=1
>  setsebool -P httpd_ssi_exec=1

- Allow Apache (scripts) to make outside connections:


>  setsebool -P httpd_can_network_connect=1
>  setsebool -P httpd_can_network_connect=1

- Allow Apache (scripts) to send mail


>  setsebool -P httpd_can_sendmail=1
>  setsebool -P httpd_can_sendmail=1

- Put proper SELinux labels on iRODS binaries and GeoIP:


>  fixfiles restore /opt
>  fixfiles restore /opt

## Battling firewall connections drop problem for irods/davis

The University of Auckland firewall presents a problem for irods because of the way the connections are terminated - the buckets for them are silently removed, so that the TCP sides receive no notification about the connection being terminated. As such, anything sent across will be devoured by a firewall sink and both sides will be left dangling and without any mean to obtain the real status of the connection. In order to counteract this beahviour, keep alives for TCP can be used to keep the TCP connections to the CAT server active.

The following data is to be added to /etc/syslog.conf on the slave side:

>  net.ipv4.tcp_keepalive_time=60
>  net.ipv4.tcp_keepalive_intvl=5
>  net.ipv4.tcp_keepalive_probes=5

and then sysctl -p command to be issued to propagate the changes. Unfortunately, keepalives are only sent when a socket actively configured to do so by the application using setsockopt interface. In order to utilise keepalives it was decided to use libkeepalive [library, which is preloaded into applications that need it. The library wraps a call to socket() by setting setsockopt/KEEPALIVE automatically. 

- Install the library into `/opt/keepalive/lib/libkeepalive.so`
- Configure the environment for the iRODS server to load the library: add the LD_PRELOAD environment variable to the variable settings in `irodsctl.pl`:

``` 
$ENV{'LD_PRELOAD'} =  '/opt/keepalive/lib/libkeepalive.so' . ( defined($ENV{'LD_PRELOAD'}) ? ':' . $ENV{'LD_PRELOAD'} : "" );
```

iRODS server should restarted in order to force libkeeplive into its address space:

``` 
service restart
```

## User database update

The main DataFabric server (df.bestgrid.org) is hosting a local MySQL database that is storing additional information about users on top of what iRODS stores in the user table.  This information particularly covers the affiliation and contact details of the users and is collected from the Shibboleth headers when the user accesses the web interface to the DataFabric - see [Administering_the_DataFabric#Registering_DataFabric_users](http://libkeepalive.sourceforge.net/)] for more information.

On a slave server, install the same script as documented at this link, but instead of creating a local database on the slave server, configure the script to access the remote MySQL at df.bestgrid.org directly.  Talk to the master server administrator about getting a MySQL account setup for that.

## Deployment considerations

When deploying a new slave server running Davis, the following configuration may need to be revisited:

- List of service configured on the landing page across all servers (for GeoIP redirects)
- MySQL grants for the user-tracking database.

# Deploying a GridFTP server

One optional task when installing an iRODS server is to also install a GridFTP server to provide a GridFTP interace into iRODS.

For the DataFabric, there should be only one central GridFTP server, running at gsiftp://df.bestgrid.org:2811/BeSTGRID

So when deploying a resource server, please carefully consider whether to also deploy a GridFTP server.

Please note: historically, the instructions were to install [Griffin](https://datafabric-griffin.googlecode.com/), a GridFTP server connecting to iRODS interface developed by ARCS's Shunde Zhang.

As of June 2015, the recommendation has been changed to run a standard Globus GridFTP server running the iRODS DSI (Data Storage Interface) module developed by CINECA, [https://hpc-forge.cineca.it/trac/iRODS-Tools](https://hpc-forge.cineca.it/trac/iRODS-Tools) (code at [https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP](https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP) and a local fork at [https://github.com/nesi/B2STAGE-GridFTP](https://github.com/nesi/B2STAGE-GridFTP))

To deploy a Globus GridFTP server with the iRODS module, please follow the steps below.  This roughly matches the instructions in the iRODS DSI module [README.md](https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP/blob/master/README.md) file.

## Installing Globus GridFTP server software

As root, install the Globus GridFTP server software, as well as all of the packages required to build the iRODS module

- Install GridFTP server


>  yum install globus-gridftp-server-progs
>  yum install globus-gridftp-server-progs

- Install dependencies for developing code against Globus


>  yum install globus-common-devel globus-gridftp-server-devel globus-gridmap-callout-error-devel
>  yum install globus-common-devel globus-gridftp-server-devel globus-gridmap-callout-error-devel

- Install git (for getting module source code)


>  yum install git
>  yum install git

- Install cmake (2.8+) for building the module


> 1. CentOS/RHEL6:
>  yum install cmake
> 2. CentOS/RHEL5:
>  yum install cmake28
> 1. CentOS/RHEL6:
>  yum install cmake
> 2. CentOS/RHEL5:
>  yum install cmake28

## Making sure iRODS (3.3.1) is compiled with -fPIC

As rods: make sure iRODS is compiled with -fPIC.  If the iRODS_DSI module build (further below) fails with linker error (libRodsAPIs.a not compiled with -fPIC), return here and:

- Edit /opt/iRODS/iRODS/config/irods.config and add:


>  $CCFLAGS = '-fPIC';
>  $CCFLAGS = '-fPIC';

- Rebuild iRODS:


>  cd /opt/iRODS/iRODS
>  ./irodssetup 
>  cd /opt/iRODS/iRODS
>  ./irodssetup 

## Building iRODS DSI module

Under a user account

- Checkout the code repository


>  git clone [https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP.git](https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP.git)
>  cd B2STAGE-GridFTP
>  git clone [https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP.git](https://github.com/EUDAT-B2STAGE/B2STAGE-GridFTP.git)
>  cd B2STAGE-GridFTP


- Compile with


>  . setup.sh
>  cmake CMakeLists.txt
> 1. on CentOS5, call cmake as cmake28:
> 2. cmake28 CMakeLists.txt
>  make
>  . setup.sh
>  cmake CMakeLists.txt
> 1. on CentOS5, call cmake as cmake28:
> 2. cmake28 CMakeLists.txt
>  make

- As root: create the deployment hierarchy:


>  mkdir /opt/iRODS_DSI
>  mkdir /opt/iRODS_DSI/iRODS_DSI-1.7
>  ln -s iRODS_DSI-1.7 /opt/iRODS_DSI/iRODS_DSI
>  mkdir /opt/iRODS_DSI
>  mkdir /opt/iRODS_DSI/iRODS_DSI-1.7
>  ln -s iRODS_DSI-1.7 /opt/iRODS_DSI/iRODS_DSI

- As root in the source directory:


>  make install
>  make install

## Configuring iRODS DSI module


## Configuring Globus GridFTP server

- Add the following to /etc/gridftp.conf (or a file in /etc/gridftp.d such as `/etc/gridftp.d/irods`):

>  $GLOBUS_TCP_PORT_RANGE 50000,51000
>  $irodsEnvFile "/opt/iRODS_DSI/iRODS_DSI/.irodsEnv"
>  load_dsi_module iRODS
>  auth_level 4
>  $LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/opt/iRODS_DSI/iRODS_DSI"
>  $homeDirPattern "/%s/home/%s"
>  $irodsConnectAsAdmin "rods"
>  $GSI_AUTHZ_CONF /opt/iRODS_DSI/iRODS_DSI/gridmap_iRODS_callout.conf
>  $irodsDnCommand "createUser"
>  sharing_dn      "/C=US/O=Globus Consortium/OU=Globus Online/OU=Transfer User/CN=_*transfer*_"

- Configure logging - with the default settings, logging would be turned off.  Configure basic logging by creating `/etc/gridftp.d/logging` with:


>  log_module stdio
>  log_level info,warn,error
>  log_single /var/log/gridftp.log
>  log_module stdio
>  log_level info,warn,error
>  log_single /var/log/gridftp.log

- Install sharing certs and enable sharing as per [Setting up a Data Transfer Node#Enable Globus.org Sharing](/wiki/spaces/BeSTGRID/pages/3818226832#SettingupaDataTransferNode-EnableGlobus.orgSharing)

- iRODS configuration


>  Make sure the GridFTP server certificate DN is associated with the rods account (or some other rodsadmin account)
>  Make sure the GridFTP server certificate DN is associated with the rods account (or some other rodsadmin account)

- Enable & start globus-gridftp-server service


>  chkconfig globus-gridftp-server on
>  service globus-gridftp-server start
>  chkconfig globus-gridftp-server on
>  service globus-gridftp-server start

## Registering a Globus.org endpoint


- Note: in order for CD with absolute paths to work, the root of the filesystem must be readable to all.


>  ichmod read public /
>  ichmod read public /

# Monitoring a DataFabric node with Nagios

To early detect system outages, it may be desirable to monitor DataFabric nodes with a monitoring system.  This section documents setting up NRPE (Nagios Remote Plugin Execution) to accept monitoring requests.  For this to work across network boundaries, firewalls must let in incoming connections to TCP port 5666 (at least from the Nagios server, in this case, pan-monitor.uoa.nesi.org.nz, 130.216.161.159).

The checks invoked via NRPE are:

- check_load: standard NRPE check, defined by default
- check_disks: custom NRPE check defined based on the check_disk plugin
- check_swap: custom NRPE check defined based on the check_swap plugin
- check_https: standard Nagios check executed remotely directly from the Nagios server
- check_ssl_certificate: custom NRPE check, defined in a script stored in the BeSTGRID SVN repository; this checks the local grid certificate (as opposed to the public-facing https certificate checked by check_https)

The steps to deploy NRPE on the DataFabric node are:

- Install nrpe


>   yum install nrpe
>   yum install nrpe

- Keep original copy of configuration file:


>   cp /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg.dist
>   cp /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg.dist


- Install plugins for the checks to be performed plus perl needed for check_ssl_certificate:

``` 

 yum install nagios-plugins-{disk,swap,load} nagios-plugins-perl

```

- Install check_ssl_certificate:


>   mkdir -p /usr/local/lib/nagios/plugins
>   wget -P /usr/local/lib/nagios/plugins/ [https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/check_ssl_certificate](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/check_ssl_certificate)
>   chmod +x /usr/local/lib/nagios/plugins/check_ssl_certificate 
>   mkdir -p /usr/local/lib/nagios/plugins
>   wget -P /usr/local/lib/nagios/plugins/ [https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/check_ssl_certificate](https://github.com/nesi/BeSTGRID-legacy/raw/master/df/scripts/check_ssl_certificate)
>   chmod +x /usr/local/lib/nagios/plugins/check_ssl_certificate 

Fix permissions for check_ssl_certificate on SELinux hosts:

- First, Install SEManage:


>   yum install policycoreutils-python
>   yum install policycoreutils-python

- Now, set the SELinux context


>   chcon -t nagios_unconfined_plugin_exec_t /usr/local/lib/nagios/plugins/check_ssl_certificate 
>   semanage fcontext -a -t nagios_unconfined_plugin_exec_t '/usr/local/lib/nagios/plugins/check_ssl_certificate'
>   chcon -t nagios_unconfined_plugin_exec_t /usr/local/lib/nagios/plugins/check_ssl_certificate 
>   semanage fcontext -a -t nagios_unconfined_plugin_exec_t '/usr/local/lib/nagios/plugins/check_ssl_certificate'

- Add firewall rule permitting incoming connections to port 5666

In addition to that, the checks need to be configured in the Nagios server - this is outside the scope of this documentation.

# Linux TCP Buffer Settings (Auckland irods server)

- /etc/sysctl.conf


>  net.core.rmem_default=262144    # Default setting in bytes of the  socket receive buffer
>  net.core.wmem_default=262144    # Default setting in bytes of the socket send buffer
>  net.core.rmem_max=33554432      # Maximum socket receive buffer size which may be set by using SO_RCVBUF
>  net.core.wmem_max=33554432      # Maximum socket send buffer size which may be set by using SO_SNDBUF
>  hnet.ipv4.tcp_rmem = 4096 87380 33554432
>  net.ipv4.tcp_wmem = 4096 65536 33554432
>  net.core.netdev_max_backlog = 30000
>  net.core.rmem_default=262144    # Default setting in bytes of the  socket receive buffer
>  net.core.wmem_default=262144    # Default setting in bytes of the socket send buffer
>  net.core.rmem_max=33554432      # Maximum socket receive buffer size which may be set by using SO_RCVBUF
>  net.core.wmem_max=33554432      # Maximum socket send buffer size which may be set by using SO_SNDBUF
>  hnet.ipv4.tcp_rmem = 4096 87380 33554432
>  net.ipv4.tcp_wmem = 4096 65536 33554432
>  net.core.netdev_max_backlog = 30000

- command line


>  ifconfig eth0 txqueuelen 5000
>  ifconfig eth0 txqueuelen 5000
