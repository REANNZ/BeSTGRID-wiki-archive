# Setup MyProxy at University of Canterbury

I have set up a production MyProxy server, `myproxy.canterbury.ac.nz`.  This server is available for use, however, to make NGPortal accessible also for the APACGrid community, we have made the decision to configure both **NGPortal** and **BeSTGRID Customized Grix** to use the APACGrid MyProxy, `myproxy.apac.edu.au`.

This page documents how the BeSTGRID MyProxy server was setup.

# General considerations

## Selecting MyProxy distribution

As at the time of installing the server, MyProxy 4.0 was already available, with a number of security fixes, I had decided to install the newer version from source, instead of relying on the MyProxy 3.6 available with VDT 1.6.  To install MyProxy from source, I've decided to install the VDT package Globus-Base-SDK, which gives me enough tools and libraries to be able to compile MyProxy.

Given the rather low load expected on the MyProxy server, I have assigned it less resources of the host system: 6GB filesystem, 1GB swap, and 512M RAM.

# Basic Install

Installing the OS: [Install a Xen Virtual Machine](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Bootstrapping_a_virtual_machine&linkCreation=true&fromPageId=3818228445) and [Update the Xen Virtual Machine](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Updating%20a%20virtual%20machine&linkCreation=true&fromPageId=3818228445).

Next, the install follows how `BuildNg2Vdt161.sh` would install a Ng2 machine - but the install was done by cut-n-pasting only the relevant parts into a terminal session.  The following steps were done:

# Installing VDT Globus SDK

- Set environment variables for the VDT install:

``` 

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin      \
VDTSETUP_AGREE_TO_LICENSES=y  VDTSETUP_EDG_CRL_UPDATE=y       \
VDTSETUP_EDG_MAKE_GRIDMAP=y   VDTSETUP_ENABLE_GATEKEEPER=n    \
VDTSETUP_ENABLE_GRIDFTP=y     VDTSETUP_ENABLE_GRIS=n          \
VDTSETUP_ENABLE_ROTATE=y      VDTSETUP_GRIS_AUTH=n            \
VDTSETUP_INSTALL_CERTS=r      VDTSETUP_ENABLE_WS_CONTAINER=y

```
- Install packages from BuildNg2 (except Gpulse, Ggateway)

``` 

yum install vim-minimal dhclient openssh-clients vim-enhanced \
    iptables ntp yp-tools mailx nss_ldap libXp                \
    tcsh openssh-server sudo lsof slocate bind-utils telnet   \
    gcc vixie-cron anacron crontabs diffutils xinetd tmpwatch \
    sysklogd logrotate man pbs-telltail compat-libstdc++-33   \
    compat-libcom_err perl-DBD-MySQL openssl097a gcc-c++

```
- Setup pacman

``` 

mkdir -p /opt/vdt/post-setup
cd /opt/vdt
wget http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-3.19.tar.gz 
tar xzf pacman-3.19.tar.gz
cd pacman-3.19
source setup.sh
cd ..

```
- Install Globus-Base-SDK (necessary to compile MyProxy)


>  pacman -pretend-platform linux-rhel-4 -get [http://vdt.cs.wisc.edu/vdt_161_cache:Globus-Base-SDK](http://vdt.cs.wisc.edu/vdt_161_cache:Globus-Base-SDK)
>  pacman -pretend-platform linux-rhel-4 -get [http://vdt.cs.wisc.edu/vdt_161_cache:Globus-Base-SDK](http://vdt.cs.wisc.edu/vdt_161_cache:Globus-Base-SDK)

- Link globus environment setup into /etc/profile.d

``` 

for File in setup.sh setup.csh ; do
  [ ! -s /etc/profile.d/vdt_$File ] &&
    ln -s /opt/vdt/$File /etc/profile.d/vdt_$File &&
    echo "==> Created: /etc/profile.d/vdt_$File"
done

```

# Installing MyProxy

- Install MyProxy (downloaded from [http://grid.ncsa.uiuc.edu/myproxy/download.html](http://grid.ncsa.uiuc.edu/myproxy/download.html))


>  gpt-build -force -verbose /root/myproxy-4.0.tar.gz gcc32dbg
>  gpt-build -force -verbose /root/myproxy-4.0.tar.gz gcc32dbg

- Configure MyProxy passphrase policy


>  cp /opt/vdt/globus/share/myproxy/myproxy-passphrase-policy /opt/vdt/globus/etc
>  chmod +x /opt/vdt/globus/etc/myproxy-passphrase-policy
>  cp /opt/vdt/globus/share/myproxy/myproxy-passphrase-policy /opt/vdt/globus/etc
>  chmod +x /opt/vdt/globus/etc/myproxy-passphrase-policy

- Install perl Cracklib from `myproxy-perl-Cracklib.tar.gz` (my private distribution).  Assuming `myproxy-perl-Cracklib.tar.gz` into current dir (`/root/inst`)


>  vdt-begin-install MyProxy-Perl-Cracklib
>  cp myproxy-perl-Cracklib.tar.gz /opt/vdt
>  vdt-untar myproxy-perl-Cracklib.tar.gz #removes the tar file from /opt/vdt
>  vdt-end-install
> 1. uninstall with: vdt-uninstall MyProxy-Perl-Cracklib
>  vdt-begin-install MyProxy-Perl-Cracklib
>  cp myproxy-perl-Cracklib.tar.gz /opt/vdt
>  vdt-untar myproxy-perl-Cracklib.tar.gz #removes the tar file from /opt/vdt
>  vdt-end-install
> 1. uninstall with: vdt-uninstall MyProxy-Perl-Cracklib

- Edit `/opt/vdt/globus/etc/myproxy-passphrase-policy` to mark PERL5LIB as trusted source for perl running in Taint mode.

``` 

#!/usr/bin/perl -T

## to allow using tainted mode but load Cracklib.pm from PERL5LIB

use Config;
use lib map { /(.*)/ } split /$Config{path_sep}/ => $ENV{PERL5LIB};

## courtesy perl5lib.pm :-)
## http://search.cpan.org/dist/perl5lib/lib/perl5lib.pm


```

# Configuring MyProxy

- Enable cleaning up expired credentials


>  cp /opt/vdt/globus/share/myproxy/myproxy.cron /opt/vdt/globus/etc
>  chmod +x /opt/vdt/globus/etc/myproxy.cron
>  vi /opt/vdt/globus/etc/myproxy.cron
> 1. set GLOBUS_LOCATION="/opt/vdt/globus"
>  cp /opt/vdt/globus/share/myproxy/myproxy.cron /opt/vdt/globus/etc
>  chmod +x /opt/vdt/globus/etc/myproxy.cron
>  vi /opt/vdt/globus/etc/myproxy.cron
> 1. set GLOBUS_LOCATION="/opt/vdt/globus"

- Create MyProxy configuration file, `/opt/vdt/globus/etc/myproxy-server.config`


>  cp /opt/vdt/globus/share/myproxy/myproxy-server.config /opt/vdt/globus/etc
>  vi /opt/vdt/globus/etc/myproxy-server.config
>  cp /opt/vdt/globus/share/myproxy/myproxy-server.config /opt/vdt/globus/etc
>  vi /opt/vdt/globus/etc/myproxy-server.config

``` 

accepted_credentials "*"
authorized_retrievers "*"
default_retrievers "/C=AU/O=APAC-GRID/*"
passphrase_policy_program /opt/vdt/globus/etc/myproxy-passphrase-policy
authorized_renewers  "/C=NZ/O=BeSTGRID/*"
authorized_renewers  "/C=AU/O=APAC-GRID/*"
default_renewers "none"
authorized_key_retrievers "*"
default_key_retrievers "none"

```

Note that my configuration file as comments justifying the selection of the options.

- Add MyProxy server to `/etc/services`


>  myproxy-server  7512/tcp                        # Myproxy server
>  myproxy-server  7512/tcp                        # Myproxy server

- Create MyProxy server startup script


>  cp /opt/vdt/globus/share/myproxy/etc.init.d.myproxy /etc/rc.d/init.d/myproxy
>  chmod +x /etc/rc.d/init.d/myproxy
>  vi /etc/rc.d/init.d/myproxy
>    => GLOBUS_LOCATION="/opt/vdt/globus"
>    => . /opt/vdt/setup.sh
> 1. The VDT environment (the PERL5LIB variable) is needed needed for the passphrase policy tool
>  chkconfig --add myproxy
>  service myproxy start
>  cp /opt/vdt/globus/share/myproxy/etc.init.d.myproxy /etc/rc.d/init.d/myproxy
>  chmod +x /etc/rc.d/init.d/myproxy
>  vi /etc/rc.d/init.d/myproxy
>    => GLOBUS_LOCATION="/opt/vdt/globus"
>    => . /opt/vdt/setup.sh
> 1. The VDT environment (the PERL5LIB variable) is needed needed for the passphrase policy tool
>  chkconfig --add myproxy
>  service myproxy start

- Enable Fetch-CRL cron-job


>  vdt-control --on
>  vdt-control --on

- Run fetch-crl for the first time


>  /opt/vdt/fetch-crl/share/doc/fetch-crl-2.6.2/fetch-crl.cron
>  /opt/vdt/fetch-crl/share/doc/fetch-crl-2.6.2/fetch-crl.cron

# Remaining tasks

- Setup a rather restrictive firewall to secure the myproxy server - allow only TCP connections to 7512 (and SSH connections from a nominated IP address), disable everything else.

- Secure myproxy system config
