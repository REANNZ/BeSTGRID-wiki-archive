# Setup GridFTP on IBM p520

The IBM p520 (named `hpcgrid1.canterbury.ac.nz` was designed to be the server for the BeSTGRID storage system, integrated into the p575 HPC cluster.  Installing GridFTP on the p520 is the first step in using this server to make the storage system available on the grid.  Up to now, it was only accessible via [NG2HPC](/wiki/spaces/BeSTGRID/pages/3816950735), which is a Linux x86 Xen virtual machine with the storage system mounted via NFS.  GridFTP running on hpcgrid1 will be significantly more efficient, as hpcgrid1 has direct connection to the GPFS filesystem used on the BeSTGRID storage.

HpcGrid1 runs AIX (on Power5+), and the Globus Toolkit has binaries available for this platform.  This page documents the steps necessary to get GridFTP running on hpcgrid1.

# Basic Globus Installation

The [Globus download page](http://www.globus.org/toolkit/downloads/4.0.6/#ppc_aix) has AIX binaries available at [http://www-unix.globus.org/toolkit/survey/index.php?download=gt4.0.6-ppc_aix_5.2-installer.tar.gz](http://www-unix.globus.org/toolkit/survey/index.php?download=gt4.0.6-ppc_aix_5.2-installer.tar.gz)

First, unpack the installer

>  tar xzf gt4.0.6-ppc_aix_5.2-installer.tar.gz
>  cd gt4.0.6-ppc_aix_5.2-installer

And then, run the configure script.  I first tried installing all of Globus, and that failed:

``` 

/usr/local/pkg/globus/4.0.6/setup/globus/setup-globus-gram-job-manager
==>ERROR: Required perl module XML::Parser not found

```

Hence, I decided to eliminate everything not needed, and install just gridftp and myproxy (with the motivation to have a gridftp server, gridftp client tools, and myproxy client tools for users to retrieve a proxy from a MyProxy server).

Together with setting variables needed by the globus installer, the commands to configure and install globus were:

``` 

export JAVA_HOME=/usr/java14
PATH=/usr/local/bin:$PATH
# needs GNU tar first
mkdir /usr/local/pkg/globus /usr/local/pkg/globus/4.0.6
ln -s 4.0.6 /usr/local/pkg/globus/version
./configure --prefix=/usr/local/pkg/globus/4.0.6 --disable-prewsgram --disable-wsjava --disable-wsmds  --disable-wsdel --disable-wsrft --disable-wsgram --disable-wscas --disable-wsc --disable-myproxy --disable-gsiopenssh --disable-webmds --disable-rendezvous
gmake
gmake install

```

This installed the globus binaries and libraries for GridFTP and MyProxy into `/usr/local/pkg/globus /usr/local/pkg/globus/4.0.6`.

# Running globus: initializing environment

To run any of the globus commands, one must first initialize several environment variables.  Globus provides two scripts for that, `$GLOBUS_LOCATION/libexec/globus-script-initializer` and `$GLOBUS_LOCATION/etc/globus-user-env.sh`.  The latter in addition adds the Globus `bin` and `sbin` directories to PATH, so it is preferred.  However, both scripts require that at least `GLOBUS_LOCATION` must be set first.  In addition, the variables `GLOBUS_TCP_PORT_RANGE` and `GLOBUS_HOSTNAME` must be set (to provide list of TCP ports open on the firewall, and the proper hostname to use instead of what the machine thinks).  For using MyProxy client tools, it is convenient to have the `MYPROXY_SERVER` variable set.

All of this has been captured in `/usr/local/pkg/globus/4.0.6/custom/globus-init-env.sh`:

``` 

#!/bin/bash

GLOBUS_LOCATION=/usr/local/pkg/globus/4.0.6
GPT_LOCATION=/usr/local/pkg/globus/4.0.6
export GPT_LOCATION GLOBUS_LOCATION

. $GLOBUS_LOCATION/libexec/globus-script-initializer
. $GLOBUS_LOCATION/custom/globus-custom-env.sh

PATH=$PATH:$GLOBUS_LOCATION/bin:$GLOBUS_LOCATION/sbin

```

which imports locally customized environment variables from `$GLOBUS_LOCATION/custom/globus-custom-env.sh`

``` 

export GLOBUS_TCP_PORT_RANGE=40000,41000
export GLOBUS_HOSTNAME=hpcgrid1.canterbury.ac.nz
export MYPROXY_SERVER=myproxy.arcs.org.au

```

Now, a user can start using globus by issuing

>  . /usr/local/pkg/globus/4.0.6/custom/globus-init-env.sh

And commands like `grid-proxy-init`, `grid-proxy-info`, `myproxy-logon` and `globus-url-copy` can be used.

# Getting GridFTP server running

In order to get GridFTP server running, it is necessary to setup the following components:

- Install host certificate
- Install CA certificates
- Setup automatic downloads of Certificate Revocation Lists (CRLs)
- Configure authentication - for now via a grid-mapfile, and we automatic updates for that.
- Create a GridFTP configuration file `gridftp.conf`
- Setup automatic startup of the GridFTP server from `inetd`

## Install host certificate

Globus looks for a certificate in:

1. env. var. `X509_USER_CERT`
2. `/etc/grid-security/hostcert.pem`
3. `$GLOBUS_LOCATION/etc/hostcert.pem`
4. {{$HOME/.globus/hostcert.pem}}If gridftp-server is run with the UID of an ordinary user, Globus also looks for
5. a user proxy in `/tmp`
6. a user certificate in `$HOME/.globus/usercert.pem`

For a proper server configuration, we have installed the host certificate (and host key) in `/etc/grid-security/host{cert,key}.pem`.

## Install CA certificates

Globus looks for the CA bundle in:

1. env. var. `X509_CERT_DIR`
2. `$HOME/.globus/certificates`
3. `/etc/grid-security/certificates`
4. `$GLOBUS_LOCATION/share/certificates`

I have downloaded the current IGTF distribution (v. 1.19) in the .tar.gz format, and extracted it to `/etc/grid-security` (with the downside that I don't have automatic updates of the IGTF bundle, and it's not managed by a package management tool).  After unpacking the bundle, I had to recursively change ownership to `root.root`.

>  wget [http://www.apgridpma.org/distribution/igtf/1.19/accredited/igtf-preinstalled-bundle-classic-1.19.tar.gz](http://www.apgridpma.org/distribution/igtf/1.19/accredited/igtf-preinstalled-bundle-classic-1.19.tar.gz)
>  cd /etc/grid-security/certificates
>  gtar xzf /hpc/home/vme28/grid/igtf-preinstalled-bundle-classic-1.19.tar.gz
>  chown -R root.root /etc/grid-security/certificates

## Downloading Certificate Revocation Lists (CRLs)

To have up to date CRLs, I have installed the fetch-crl script, normally installed as a part of VDT.  Based on the information on the VDT Fetch-CRL page [http://vdt.cs.wisc.edu/components/fetch-crl.html](http://vdt.cs.wisc.edu/components/fetch-crl.html), I did:

>  mkdir /usr/local/pkg/globus/4.0.6/fetch-crl
>  cd /usr/local/pkg/globus/4.0.6/fetch-crl
>  wget [http://dist.eugridpma.info/distribution/util/fetch-crl/fetch-crl-2.6.6.tar.gz](http://dist.eugridpma.info/distribution/util/fetch-crl/fetch-crl-2.6.6.tar.gz)
>  gtar xzf fetch-crl-2.6.6.tar.gz
>  cp ./fetch-crl-2.6.6/edg-fetch-crl

To get the `edg-fetch-crl` script running, I had to install these packages:

- `wget` - from AIX RPM collection at [http://www-03.ibm.com/systems/p/os/aix/linux/toolbox/download.html](http://www-03.ibm.com/systems/p/os/aix/linux/toolbox/download.html)
	
- `mktemp` command (version 1.5) from [ftp://ftp.mktemp.org/pub/mktemp/](ftp://ftp.mktemp.org/pub/mktemp/) - installed using linkpkg in `/usr/local/bin`

And I had to do a few modifications to the `edg-fetch-crl` script:

- change getopt invocation to conform to AIX getopt syntax (no long options)
- change mktemp location to /usr/local/bin/mktemp

The following patch (download as [edg-fetch-crl-aix-nolongopt-mktemp.diff](/wiki/download/attachments/3816950497/Edg-fetch-crl-aix-nolongopt-mktemp.diff.txt?version=1&modificationDate=1539354084000&cacheVersion=1&api=v2)) documents all the changes made to the `edg-fetch-crl` script:

``` 

--- fetch-crl-2.6.6/edg-fetch-crl       2007-09-17 00:51:32.000000000 +1200
+++ edg-fetch-crl       2008-02-26 11:41:49.959724103 +1300
@@ -67,7 +67,7 @@
 date=/bin/date
 sed=/bin/sed
 grep=/bin/grep
-mktemp=/bin/mktemp
+mktemp=/usr/local/bin/mktemp
 stat=/usr/bin/stat
 
 #
@@ -209,6 +209,10 @@
    echo "   $FETCH_CRL_SYSCONFIG (resettable via the FETCH_CRL_SYSCONFIG environment"
    echo "   variable, see manual for details)."
    echo
+   echo "WARNING: this version of fetch-crl DOES NOT understand LONG options."
+   echo "(due to limitations of the AIX getopt utility)."
+   echo "Use only short options!"
+   echo
 }
 
 #
@@ -413,7 +417,10 @@
 #
 # Parse the command line
 #
-getoptResult=`${getopt} -o hl:o:qa:nf -a -l help,loc:,out:,quiet,agingtolerance,no-check-certificate,syslog-facility,check-server-certificate -n ${programName} -- "$@"`
+### AIX getopt does not support long options
+### Usage: getopt Flag-string Command-string
+getoptResult=`${getopt} hl:o:qa:nf "$@"`
+### getoptResult=`${getopt} -o hl:o:qa:nf -a -l help,loc:,out:,quiet,agingtolerance,no-check-certificate,syslog-facility,check-server-certificate -n ${programName} -- "$@"`
 if [ $? != 0 ] ; then
    ShowUsage
    exit 1

```

Then, I created the script `$GLOBUS_LOCATION/fetch-crl/fetch-crl-cron`  to be invoked by cron, which sets all environment and parameters to be passed to `edg-fetch-crl`:

``` 

#!/bin/bash

# temporary
# export http_proxy=http://gridws1.canterbury.ac.nz:3128

/usr/local/pkg/globus/4.0.6/fetch-crl/edg-fetch-crl -l /etc/grid-security/certificates/ -o /etc/grid-security/certificates/ -q

```

Note that temporarily, this script was setting the `http_proxy` variable before HpcGrid1 had firewall rules established.

Finally, I added the invocation of this script to root's crontab (with `crontab -e`):

>  33 5 * * * /usr/local/pkg/globus/4.0.6/fetch-crl/fetch-crl-cron 1>/usr/local/pkg/globus/4.0.6/var/log/fetch-crl.log 2>&1

## Gridmap

When run by a non-root user, gridftp-server uses `$HOME/.gridmap` - and when run as root, it uses `/etc/grid-security/grid-mapfile`.

- would be too hard to get mkgridmap running there
- let's copy from ng2hpc via a local (NFS) copy
- on hpcgrid1

cd /usr/local/pkg/globus/4.0.6/etc

touch grid-mapfile

chown bin.z001 grid-mapfile

1. id bin
2. uid=2(bin) gid=2(bin) groups=3(sys),4(adm)

- on ng2hpc
- one-off copy:

1. id daemon
2. uid=2(daemon) gid=2(daemon) groups=2(daemon),1(bin),4(adm),7(lp)
3. su -s /bin/bash daemon

cp /etc/grid-security/grid-mapfile 

/hpc/projects/packages/local.aix/pkg/globus/4.0.6/etc/grid-mapfile

ln -s /hpc/projects/packages/local.aix/pkg/globus/4.0.6/etc/grid-mapfile 

/etc/grid-security/grid-mapfile

1. crontab -u daemon -e

53 5,11,17,23 * * * /bin/cp /etc/grid-security/grid-mapfile 

/hpc/projects/packages/local.aix/pkg/globus/4.0.6/etc/grid-mapfile
2. every 5 minutes after edg-mkgridmap runs

## GridFTP configuration file

Create GridFTP configuration file `$GLOBUS_LOCATION/etc/gridftp.conf` with the following content:

``` 

inetd 1
port 2811

log_level ERROR,WARN,INFO
log_single /usr/local/pkg/globus/4.0.6/var/log/gridftp-auth.log
log_transfer /usr/local/pkg/globus/4.0.6/var/log/gridftp.log
grid_mapfile /etc/grid-security/grid-mapfile

```

This configuration file:

- Uses same log files as the VDT-created config does
- Specifies grid-mapfile location which is ignored.

## GridFTP startup

- Create `/usr/local/pkg/globus/4.0.6/custom/run-gridftp-server.sh` which sets up the environment (in a similar way as `globus-init-env.sh` above does), and invokes `globus-gridftp-server`:

``` 

#!/bin/bash

GLOBUS_LOCATION=/usr/local/pkg/globus/4.0.6
GPT_LOCATION=/usr/local/pkg/globus/4.0.6
export GPT_LOCATION GLOBUS_LOCATION

. $GLOBUS_LOCATION/libexec/globus-script-initializer
. $GLOBUS_LOCATION/custom/globus-custom-env.sh


exec $GLOBUS_LOCATION/sbin/globus-gridftp-server -c $GLOBUS_LOCATION/etc/gridftp.conf

```

- Configure `inetd` to invoke this script for incoming gsiftp TCP connections: put the following line into `/etc/inetd.conf`


>  gsiftp  stream  tcp     nowait  root    /usr/local/pkg/globus/4.0.6/custom/run-gridftp-server.sh        globus-gridftp-server
>  gsiftp  stream  tcp     nowait  root    /usr/local/pkg/globus/4.0.6/custom/run-gridftp-server.sh        globus-gridftp-server

This completes the gridftp configuration.  Just refresh inetd with `kill -1 InetdPID` and keep fingers crossed - it should be running.

# Client Tools

## UberFTP

- Download [UberFTP](http://dims.ncsa.uiuc.edu/set/uberftp/) source tar-ball (follow [Download](http://dims.ncsa.uiuc.edu/set/uberftp/download.html) link for most recent version, 1.27 as of 2008-03-04)


>  wget [http://dims.ncsa.uiuc.edu/set/uberftp/download/uberftp-client-1.27.tar.gz](http://dims.ncsa.uiuc.edu/set/uberftp/download/uberftp-client-1.27.tar.gz)
>  wget [http://dims.ncsa.uiuc.edu/set/uberftp/download/uberftp-client-1.27.tar.gz](http://dims.ncsa.uiuc.edu/set/uberftp/download/uberftp-client-1.27.tar.gz)

- Find out which GPT flavors are available:


>  . /usr/local/pkg/globus/4.0.6/custom/globus-init-env.sh
>  gpt-query -name=globus_ftp_control -pkgtype=rtl
>  . /usr/local/pkg/globus/4.0.6/custom/globus-init-env.sh
>  gpt-query -name=globus_ftp_control -pkgtype=rtl

- Build for `vendorcc64` (AIX on Power5+)


>  gpt-build uberftp-client-1.27.tar.gz vendorcc64
>  gpt-build uberftp-client-1.27.tar.gz vendorcc64

That's it - UberFTP is now in `$GLOBUS_LOCATION/bin`. Invoke it with `uberftp`.

# Client authentication: use PRIMA callouts

Historic note: For configuring PRIMA, the following message (printed at the end of `gmake install`) may be helpful:

``` 

running /usr/local/pkg/globus/4.0.6/setup/globus/setup-globus-gaa-authz-callout-message..[ Changing to /usr/local/pkg/globus/4.0.6/setup/globus ]

If you wish to configure the optional GAA-based Globus Authorization
callouts, run the setup-globus-gaa-authz-callout setup script.

```

Well, I had to compile PRIMA from source code, and on AIX, it was a very painful process, documented on a [separate page on compiling PRIMA](/wiki/spaces/BeSTGRID/pages/3816950640).

Switching to use PRIMA to call out to the GUMS server has made the architecture much simpler.  Otherwise, I would have to keep a mechanism in place to update the `grid-mapfile` file on the p520.

Two mechanisms were used over time:

## Getting grid-mapfile from Ng2HPC

While Ng2HPC was still using `edg-mkgridmap` to generate a grid-mapfile, it was enough to have a separate cron job that would copy the file over to the HPC shortly after it is generated on Ng2HPC.  This cron command, now commented-out, was installed in `daemon`'s crontab:

>  53 3,9,10,11,12,13,14,15,16,17,21 * * * /bin/cp /etc/grid-security/grid-mapfile /hpc/projects/packages/local.aix/pkg/globus/4.0.6/etc/grid-mapfile
> 1. every 5 minutes after edg-mkgridmap runs

## Getting grid-mapfile from the GUMS server

I was considering to use a grid-mapfile that would be generated by the GUMS server.  This would at least allow users who have a mapping to a local account to access their local account via the GridFTP server on p520.  However, via a grid-mapfile, they would always be mapped to their default account (as if using a non-voms proxy), and any VOMS attribute certificates in their credentials would be ignored.

I considered fetching the mapfile with wget:

>  wget --ca-directory=/etc/grid-security/certificates/ --certificate=/etc/grid-security/hostcert.pem --private-key=/etc/grid-security/hostkey.pem  [https://nggums.canterbury.ac.nz/gums/generateGridMapfile.jsp?host=%2FCN%3Dng2hpc.canterbury.ac.nz](https://nggums.canterbury.ac.nz/gums/generateGridMapfile.jsp?host=%2FCN%3Dng2hpc.canterbury.ac.nz)' -O gridmap.html

But this command generates an HTML file containing the mapping, would need screen-scraping to extract just the mapping.

I could not find a way to easily access the GUMS service remotely without installing GUMS also on the p520 (which I would rather avoid).  The GUMS service is a web service, and it might work to HTTP POST the (static) service request with `wget`.

But I realized I can more easily run the GUMS service client command `gums-service` on `nggums`

>  gums-service generateGridMapfile '/CN=ng2hpc.canterbury.ac.nz' 

This works under the condition that:

1. NgGums's host certificate is copied over to `/root/.globus/user{cert,key}.pem`
2. NgGums's DN is added as an admin of the GUMS server: add `/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=nggums.canterbury.ac.nz` to the group `admins`.

Note that I was also considering whether I could use FQAN in a grid-mapfile: if so, this would get us *exactly* the PRIMA/GUMS functionality - but the 3-column grid-mapfile format is not recognized by AIX Globus GridFTP.  Note also that the FQAN format is hard to get from `gums-service` (no command-line option for that, it's only available via a check box on the web form) - and as it doesn't work with GlobusGridFTP, I don't have to work on getting the FQAN's out of GUMS.

So as a temporary measure, I was generating a grid-mapfile with gums-service and copying that over to the HPC (automated SSH login via the ictsbgrd account):

- On hpcgrid1:


>  chown ictsbgrd /etc/grid-security/grid-mapfile.from-gums
>  chown ictsbgrd /etc/grid-security/grid-mapfile.from-gums

- On NgGums:


>  ssh-keygen -t rsa
>  => /root/.ssh/id_bestgridpwd_rsa
>  ssh-keygen -t rsa
>  => /root/.ssh/id_bestgridpwd_rsa

- Put `nggums:/root/.ssh/id_bestgridpwd_rsa.pub` into `hpcgrid1:/hpc/gridusers/ictsbgrd/.ssh/authorized_keys`
- Setup cron-job on nggums:


>  1,9,17,25,33,41,49,57 * * * * /root/gumsmapfile/syncmapfile-hpcgrid1.sh
> 1. 1 minute after python gumsmanualmap
>  1,9,17,25,33,41,49,57 * * * * /root/gumsmapfile/syncmapfile-hpcgrid1.sh
> 1. 1 minute after python gumsmanualmap

- Create a shell-script to synchronize the map-file: `/root/gumsmapfile/syncmapfile-hpcgrid1.sh`:

``` 

#!/bin/bash

MAPFILE=/root/gumsmapfile/mapfile-ng2hpc
. /opt/vdt/setup.sh

gums-service generateGridMapfile -f $MAPFILE '/CN=ng2hpc.canterbury.ac.nz'

scp -i /root/.ssh/id_bestgridpwd_rsa -o PasswordAuthentication=no $MAPFILE ictsbgrd@hpcgrid1.canterbury.ac.nz:/etc/grid-security/grid-mapfile.from-gums < /dev/null > /dev/null 2>&1

```

Both these measures have been temporary: disable the cron jobs:

- on nggums, disable root's cron-job calling `/root/gumsmapfile/syncmapfile-hpcgrid1.sh`.
- on ng2hpc, disable daemon's cron-job copying ng2hpc's grid-mapfile to `/hpc/projects/packages/local.aix/pkg/globus/4.0.6/etc/grid-mapfile`
- leave host cert in `/root/.globus` (no risk, and gives me gums-service running)

The configuration now in place is using PRIMA - see the section on [activating PRIMA](/wiki/spaces/BeSTGRID/pages/3816950640#SetupPRIMAonIBMp520-ConfiguringandactivatingPRIMA).
