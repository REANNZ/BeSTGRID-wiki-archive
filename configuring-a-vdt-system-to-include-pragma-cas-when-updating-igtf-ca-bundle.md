# Configuring a VDT system to include PRAGMA CAs when updating IGTF CA bundle

# VDT certificates updater

On systems where the grid tools are installed as a part of [VDT](http://vdt.cs.wisc.edu/), the best way to keep the IGTF Certification Authorities (CA) bundle up to date is to use the VDT CA updater.

VDT CA updater can be simply installed and activated with:

>  pacman -pretend-platform linux-rhel-4 -get [http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:CA-Certificates-Updater](http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:CA-Certificates-Updater)
>  vdt-control --on vdt-update-certs

- more details on this are at the [automatic install update notes](/wiki/spaces/BeSTGRID/pages/3818228905#GridgatewayenhancementsatUniversityofCanterbury-AutomaticCertificateUpdates)

# Configuring VDT updater to include PRAGMA CA bundle

The updater however replaces the certificates directory with a new one with fresh content.  To keep additional certificates added on top of the IGTF CA bundle installed even after the update, the CA updater must be configured to include the additional files.  This is achieved by adding a line of the following form to `/opt/vdt/vdt/etc/vdt-update-certs.conf`.

>   include=/full/path/to/certificate/or/other/file

The following sequence of commands extracts the PRAGMA CA bundle into `/etc/grid-security/pragma-certificates`, and adds an `include` line for each file extracted into `/opt/vdt/vdt/etc/vdt-update-certs.conf`.

``` 

mkdir -p /etc/grid-security/pragma-certificates/inst
cd /etc/grid-security/pragma-certificates/inst
wget --no-check-certificate https://goc.pragma-grid.net/secure/certificates/pragma-certs.tar.gz
tar xzf pragma-certs.tar.gz -C ..
vi mk-update-certs-conf.sh

```

Contents of `mk-update-certs-conf.sh`

``` 

#!/bin/bash

for I in /etc/grid-security/pragma-certificates/*.* ; do
# {0,crl_url,info,signing_policy,namespace}
  echo "include=$I"
done

```

Finally, run the script once to append to `/opt/vdt/vdt/etc/vdt-update-certs.conf`:

>  chmod +x mk-update-certs-conf.sh
>  ./mk-update-certs-conf.sh >> /opt/vdt/vdt/etc/vdt-update-certs.conf

Next time `vdt-update-certs` runs, it will include the PRAGMA CA bundle in the list.

Note that to get the PRAGMA CA certificates bundle installed immediately, one has to also do

>  cp /etc/grid-security/pragma-certificates/**.** /etc/grid-security/certificates

# Updating PRAGMA CA bundle

- Download a new PRAGMA CA bundle into `/etc/grid-security/pragma-certificates/inst`


>  wget --no-check-certificate -O /etc/grid-security/pragma-certificates/inst/pragma-certs.tar.gz [https://goc.pragma-grid.net/secure/certificates/pragma-certs.tar.gz](https://goc.pragma-grid.net/secure/certificates/pragma-certs.tar.gz)
>  wget --no-check-certificate -O /etc/grid-security/pragma-certificates/inst/pragma-certs.tar.gz [https://goc.pragma-grid.net/secure/certificates/pragma-certs.tar.gz](https://goc.pragma-grid.net/secure/certificates/pragma-certs.tar.gz)

- Move the old bundle from `/etc/grid-security/pragma-certificates` to `/etc/grid-security/pragma-certificates/old`


>  mkdir /etc/grid-security/pragma-certificates/old
>  mv /etc/grid-security/pragma-certificates/**.** /etc/grid-security/pragma-certificates/old
>  mkdir /etc/grid-security/pragma-certificates/old
>  mv /etc/grid-security/pragma-certificates/**.** /etc/grid-security/pragma-certificates/old

- Extract the new bundle


>  tar xzf /etc/grid-security/pragma-certificates/inst/pragma-certs.tar.gz -C /etc/grid-security/pragma-certificates
>  tar xzf /etc/grid-security/pragma-certificates/inst/pragma-certs.tar.gz -C /etc/grid-security/pragma-certificates

- Update the VDT updater configuration: create a small script `refresh-update-certs-conf.sh`

``` 

#!/bin/bash

TMPFILE=/opt/vdt/vdt/etc/vdt-update-certs.conf.tmp.$$
cat /opt/vdt/vdt/etc/vdt-update-certs.conf | grep -v '^include=/etc/grid-security/pragma-certificates' > $TMPFILE

if [ ! -f $TMPFILE ] ; then
  echo "Error: could not create $TMPFILE"
  exit 1
fi

cat $TMPFILE > /opt/vdt/vdt/etc/vdt-update-certs.conf
/etc/grid-security/pragma-certificates/inst/mk-update-certs-conf.sh >> /opt/vdt/vdt/etc/vdt-update-certs.conf

rm $TMPFILE

```
- Make the script executable and run it


>  cd /etc/grid-security/pragma-certificates/inst
>  chmod +x refresh-update-certs-conf.sh
>  ./refresh-update-certs-conf.sh
>  cd /etc/grid-security/pragma-certificates/inst
>  chmod +x refresh-update-certs-conf.sh
>  ./refresh-update-certs-conf.sh

- This so far only tells VDT update certs to include the right set of PRAGMA certificates when it the next time updates the IGTF bundle.
- Update the new PRAGMA certificates now


>  cp /etc/grid-security/pragma-certificates/**.** /etc/grid-security/certificates
>  cp /etc/grid-security/pragma-certificates/**.** /etc/grid-security/certificates

- Remove the PRAGMA certificates that have been removed.


>  cd /etc/grid-security/pragma-certificates/old
>  for FILE in **.** ; do
>     if [\! -f /etc/grid-security/pragma-certificates/$FILE](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%5C%21%20-f%20%2Fetc%2Fgrid-security%2Fpragma-certificates%2F%24FILE&linkCreation=true&fromPageId=3818228518) ; then
>       echo "Deleting /etc/grid-security/certificates/$FILE"
>       rm -f /etc/grid-security/certificates/$FILE
>     fi
>  done
>  cd /etc/grid-security/pragma-certificates/old
>  for FILE in **.** ; do
>     if [\! -f /etc/grid-security/pragma-certificates/$FILE](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%5C%21%20-f%20%2Fetc%2Fgrid-security%2Fpragma-certificates%2F%24FILE&linkCreation=true&fromPageId=3818228518) ; then
>       echo "Deleting /etc/grid-security/certificates/$FILE"
>       rm -f /etc/grid-security/certificates/$FILE
>     fi
>  done

# Important Fix

Installing PRAGMA certificates on top of the IGTF bundle reaches a threshold in Apache mod_ssl: when there are more then 90 CAs in a directory specified with `SSLCACertificatePath`, Apache hangs (apparently when constructing the list of CA DNs to send the the client.

This problem can be worked-around by configuring Apache to return just one CA (APACGrid) to the client - the client will know which certificate to use.

If you are running Apache (as on a VDT GUMS server), add the following into the SSL Virtual Host configuration:

>  SSLCADNRequestFile /etc/grid-security/certificates/1e12d831.0
