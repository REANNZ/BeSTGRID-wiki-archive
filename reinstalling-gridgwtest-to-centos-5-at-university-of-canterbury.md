# Reinstalling GridGwTest to CentOS 5 at University of Canterbury

I have decided to use GridGwTest also as a test system for SRB.  For this, I had to upgrade the system from CentOS 4 to CentOS 5 - and at the same time, upgrade VDT from 1.6.1 to 1.10.1.  I have done a fresh install, keeping the old root in a separate directory.  This page thus describes an install of a new system (preserving some host-specific information like ssh keys), and the installation of VDT and SRB.

# System installation

- Shut the system down.
- Mount the system's partition in the Xen host.
- Move everything to `/centos4-vdt161-backup`
- [Install CentOS 5](/wiki/spaces/BeSTGRID/pages/3816950789) - see notes, it's more than 

``` 
./bootstrapvm /mnt/vmRoot/ gridgwtest CentOS-5
```

- Copy over from backup to new sys what should be preserved:

1. ssh keys (`/etc/ssh/ssh_host*`)
2. X509 host certificate: `/etc/grid-security/host{cert,key}.pem`
3. Home directories: `/root` and `/home/vme28`

- Re-create users (after booting the system)


>  adduser -u 12458 vme28
>  adduser -u 1005 loadl
>  passwd vme28
>  adduser -u 12458 vme28
>  adduser -u 1005 loadl
>  passwd vme28

# Installing VDT 1.10.1

Modify BuildClientVdt181.sh as follows:

- Install from VDT 1.10.1 cache at [http://vdt.cs.wisc.edu/vdt_1101_cache/](http://vdt.cs.wisc.edu/vdt_1101_cache/)
- With `-pretend-platform linux-rhel-5`
- Add VDT packages UberFTP, Globus-Base-Data-Server
- Remove Gclients from RPM packages (don't need

Run

>  BuildClientVdt181.sh

# Additional VDT configuration

## Pick a certificate distribution (IGTF)

VDT now forces the user to manually pick a CA certificates distribution.  Instructions are included in `/opt/vdt/post-install/README`:

- Edit the value of `cacerts_url` in the configuration file `$VDT_LOCATION/vdt/etc/vdt-update-certs.conf` and set it to [http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version](http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version)
- Run the following command: 

``` 
. $VDT_LOCATION/vdt-questions.sh; $VDT_LOCATION/vdt/sbin/vdt-setup-ca-certificates
```
- Yes, that works well!

## voms-proxy-init

- Note: `voms-proxy-init` works only after creating `/opt/vdt/glite/etc/vomses`.  The file should contain 1-line per VOMS server (ARCS,APACGrid,PRAGMA,gin.ggf.org):

``` 

"APACGrid" "vomrs.apac.edu.au" "15001" "/C=AU/O=APACGrid/OU=APAC/CN=vomrs.apac.edu.au" "APACGrid"
"ARCS" "vomrs.arcs.org.au" "15001" "/C=AU/O=APACGrid/OU=ARCS/CN=vomrs.arcs.org.au" "ARCS"
"gin.ggf.org" "kuiken.nikhef.nl" "15050" "/O=dutchgrid/O=hosts/OU=nikhef.nl/CN=kuiken.nikhef.nl" "gin.ggf.org"
"PRAGMA" "vomrs-pragma.sdsc.edu" "15001" "/DC=NET/DC=PRAGMA-GRID/OU=SDSC/CN=vomrs-pragma.sdsc.edu" "PRAGMA" "https://vomrs-pragma.sdsc.edu:8443/vomrs/PRAGMA/services/VOMRS?WSDL"

```
- Note: one must first create the directory `/opt/vdt/glite/etc` as well...

***Additional notes***

Instaling GridFTP did minor changes to /etc/services (remove and renter

the same entry for gsiftp at tcp/2811)

GridFTP is now running (though no mapping has been configured)

# Installing SRB

- Following [http://projects.arcs.org.au/trac/systems/wiki/DataServices/SRBQuickStart](http://projects.arcs.org.au/trac/systems/wiki/DataServices/SRBQuickStart)

- Install SRB binary packages:

``` 
yum install gridFTP_SRB_DSI.i386
```
- All OK

- Copy host cert/key to srb{cert,key}.pem owned by srb.srb


>  cp hostcert.pem srbcert.pem
>  cp hostkey.pem srbkey.pem
>  chown srb.srb srb{cert,key}.pem
>  cp hostcert.pem srbcert.pem
>  cp hostkey.pem srbkey.pem
>  chown srb.srb srb{cert,key}.pem

- Edit `/usr/srb/bin/runsrb` to use the this certificate and key (around line 170):


>  X509_USER_KEY=/etc/grid-security/srbkey.pem
>  X509_USER_CERT=/etc/grid-security/srbcert.pem
>  X509_USER_KEY=/etc/grid-security/srbkey.pem
>  X509_USER_CERT=/etc/grid-security/srbcert.pem


- Configure and start SRB:


>  yum install srb-install.i386
>  yum install srb-install.i386

**Note:** Things have gone really bad here.  In the end, I found that I had hit a hard-coded SRB limit: the fully qualified username (username@domain) must not be longer then 35 - mine was 36, `srbAdmin@gridgwtest.canterbury.ac.nz`.  The installation failed from the point where the srbAdmin user would first authenticate - so the installation scriptlet could not even rename the zone.

The following snippet of output from the srb-install scritplet has all the indicative symptoms:

``` 

NOTICE:Oct 29 14:34:00: Connection from 132.181.39.11 by PUser srbAdmin@gridgwtest.canterbury.ac.nz Cuser @, pid = 31380
svrCheckAuth: Auth error for srbAdmin@gridgwtest.canterbury.ac.nz-demozone. status = -1121
srbServerMain: svrCheckAuth error. Status = -1121
srb      31376     1  0 14:33 ?        00:00:00 ./srbMaster-3.5.0 -d 1 -S
srb      31391 31372  0 14:34 ?        00:00:00 grep srbMaster
connectPort() --  Connection Error from server: status=-2772
connectSvr: connectPort error. status =-2772
Connection to srbMaster failed.
USER_NAME_NOT_FOUND: USER_NAME_NOT_FOUND


clAuth.c:clSendEncryptAuth(), socket read error, errno=0, bytes read = 4, bytes expected = 64
Success

Connection to srbMaster failed.
clAuth.c:clSendEncryptAuth(), socket read error, errno=0, bytes read = 4, bytes expected = 64
Success
AUTH_ERR_MDAS_AUTH: MDAS auth failed

```

- Client authentication (Sinit) fails with a socket read error
- Server prints an `Auth error` message with code `-1121`
- Server prints a `Connection` log message with garbled `Cuser` string (should be same as `PUser`, the full user name).

The solution is to use a shorter domain name than the rather long hostname of the test installation host.

I will reinstall SRB from scratch on the system.
