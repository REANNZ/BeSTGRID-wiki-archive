# MyProxy Test Install

MyProxy installation has been fairly easy, following the [APAC recommended installation procedure](http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsMyproxy).

# Installation Steps

The installation is quite easy — MyProxy is installed as a VDT package.  For configuration, I followed [http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsMyproxy](http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsMyproxy)

These are the detailed steps I did:

## Setup passphrase policy

Passphrase policy is a perl script packaged with MyProxy.  The script must be installed to `$GLOBUS_LOCATION/etc`, and the dependency on `Crypt::Cracklib.pm` must be satisfied.

>   cp /opt/vdt/globus/share/myproxy/myproxy-passphrase-policy /opt/vdt/globus/etc/
>   chmod +x /opt/vdt/globus/etc/myproxy-passphrase-policy

### Cracklib.pm

The perl script myproxy-passphrase-policy depends on library `Crypt::Cracklib`, which in turn depends on `Test::Pod::Coverage`.  Neither of these is available as an RPM.  The recommended step is (as root):

>   perl -MCPAN -e 'install Test::Pod::Coverage'
>   perl -MCPAN -e 'install Crypt::Cracklib'

This would work, and would install unregistered packages into `/usr/lib/perl5`.  The module `Test::Pod::Coverage` is needed to compile (test) the Cracklib module, and would install as dependencies also modules `Pod::Coverage` and `Devel-Symdump`.  These files are not available in RMPs: Coverage.pm, Symdump.pm are not provided as RPMs in CentOS; in Fedora, only Symdump.pm exists in perl-Devel-Symdump.

I did not want to mess up local installation and instead only installed the files (`Cracklib.pm` and `Cracklib.{bs,so`}) created in `~/.cpan` when running the `install Crypt::Cracklib` command as a non-root user.

This can be converted into a local installation - I installed into `~mencl/myperl`, and could use the packages with

>   export PERL5LIB=~/myperl/:$PERL5LIB

To make the installation easier, I have packaged these files as `myproxy-perl-Cracklib.tar.gz`, which can be installed (and registered) into VDT with:

>   vdt-begin-install MyProxy-Perl-Cracklib
>   cp ~/myproxy-perl-Cracklib.tar.gz /opt/vdt
>   vdt-untar myproxy-perl-Cracklib.tar.gz #removes the tar file from /opt/vdt
>   vdt-end-install

## Compiling MyProxy

I have tried to compile a more recent version of MyProxy (3.7).  The recommendation is to first find out what Globus *flavors* are installed:

>   $GPT_LOCATION/sbin/gpt-query globus_gssapi_gsi

And then, choosing flavor `gcc32` run

>   $GPT_LOCATION/sbin/gpt-build -force -verbose myproxy-3.7.tar.gz gcc32

Unfortunately:

>   WARNING: The following flavors are not supported for this platform:
>           gcc32
>   ERROR: At least one flavor needs to be defined for package myproxy

And I had no better luck with the configure script:

>   $ ./configure --with-flavor=gcc32dbg --with-voms /opt/vdt/glite/
>   configure: WARNING: you should use --build, --host, --target
>   configure: WARNING: invalid host type: /opt/vdt/glite/
>   checking whether to enable maintainer-specific portions of Makefiles... no
>   ERROR: Flavor gcc32dbg has not been installed

This may be only a problem I have with my VDT-1.5.2 installation - but in my setting, I cannot recompile MyProxy.

## MyProxy configuration

Create `/opt/vdt/globus/etc/myproxy-server.config` based on template in `/opt/vdt/globus/share/myproxy`

APAC recommended configuration:

>   accepted_credentials  "/C=AU/O=APAC-GRID/*"
>   authorized_retrievers "*"
>   default_retrievers "/C=AU/O=APAC-GRID/*"
>   passphrase_policy_program /etc/myproxy-passphrase-policy

The configuration I used in my test install:

>   accepted_credentials  "/C=NZ/O=BeSTGRID/*"
>   accepted_credentials  "/C=AU/O=APAC-GRID/*"
>   authorized_retrievers "*"
>   default_retrievers "/C=NZ/O=BeSTGRID/*"
>   passphrase_policy_program /opt/vdt/globus/etc/myproxy-passphrase-policy
>   authorized_renewers "*"
>   default_renewers "none"
>   authorized_key_retrievers "*"
>   default_key_retrievers "none"

## Unix service configuration

MyProxy comes with script `etc.init.d.myproxy`.  This may be either manually installed into `/etc/init.d/myproxy`, or registered with `vdt-register-service`.  Note that the script uses `grep` to find myproxy pid ...

**Note:** before installing, edit `GLOBUS_LOCATION` in the script.

## Additional installation steps

- Install `myproxy.cron` into `/etc/cron.daily/` to regularly delete expired proxies.


>  ***Disable everything else** - this should be an extremely secure machine.
>  ***Disable everything else** - this should be an extremely secure machine.

- Setup unison for synchronization with back myproxy server.
- Optionally: change storage from `/var/myproxy` to `/opt/vdt/var/myproxy` .... ?

## Start MyProxy

To see what's happening (i.e., see MyProxy debugging output), run myproxy-server attached to your console in debug mode:

>   while true ; do myproxy-server -d -v ; sleep 1 ; done

# Usage scenarios

# Pending Issues

# Related reading

## Proxy Certificates

- [RFC 3280](http://www.ietf.org/rfc/rfc3280.txt) — X509 Public Key Infratstructure
- [RFC 3820](http://www.ietf.org/rfc/rfc3820.txt) — X509 Proxy Certfificates
- OpenSSL howto on Proxy Certificates [http://www.openssl.org/docs/HOWTO/proxy_certificates.txt](http://www.openssl.org/docs/HOWTO/proxy_certificates.txt)

OpenSSL considers proxies a security risk - if an application gets "verify() h1. OK", would trust the proxy certificate, completely in hands of the issuer - and an unaware application would not look into the issuer's certificate for restrictions. 

Setting `OPENSSL_ALLOW_PROXY` should permit proxy certificates - but does not work neither in 0.9.7d (VDT 1.5.2), nor 0.9.8a (FC5)

## MyProxy paper

- Jason Novotny, Steven Tuecke, Von Welch: An Online Credential Repository for the Grid: MyProxy. [HPDC 2001](http://www.informatik.uni-trier.de/~ley/db/conf/hpdc/hpdc2001.html#NovotnyTW01), [PDF](http://www.globus.org/alliance/publications/papers/myproxy.pdf) Tech Notes h1. Look for setup config files for myproxy in /opt/vdt/globus/share/myproxy

install configs from /opt/vdt/globus/share/myproxy to /opt/vdt/globus/etc

> - check with
>         myproxy-server -d

## MyProxy configuration options

My notes about relevant options in the myproxy.server.config file

>   accepted_credentials - what can be stored here
>   authorized_retrievers
> - who in general can contact the server to retrieve credentials
> - further restricted by permission on each credentials stored
>   default_retrievers — default permissions to set on a key
>   authorized_renewers
> - who can ask for renewal in general
>   default_renewers 
> - default permissions on each credential stored
>   key_retrievers (authorized/default)
> - retrieve keys from repository (instead of having a proxy generated)
>   trusted_retrievers (authorized/default)
> - retrieve without passphrase
>    +++ PAM authentication configuration (authenticate via PAM for retrieve logons)
>    +++ configuration of an online CA
> - authenticate username with PAM, map username to DN
>    CA-LDAP integration
>    master/slave server (myproxy failover replication)
>    pubcookie - ??? alternative authentication, [http://www.pubcookie.org/](http://www.pubcookie.org/)
>    accepted_credentials_mapfile - avoid storing credentials under a different name, may be different from grid_mapfile
>    #check_multiple_credentials - better avoid this option Unsorted ==

---------------------

User playing with myproxy-{init,info,logon}

export MYPROXY_SERVER=vdtcentos.bestgrid

Make my credentials accessible to anyone (with a recognized certificate) who knows the passphrase:

mencl$ myproxy-init -l vladimir.mencl --allow_anonymous_retrievers

griduser$ myproxy-logon -l vladimir.mencl

1. 
1. 
1. 
1. creates a local proxy certficate

Make my credentials accessible to a given person (*/CN=Given Family)

>    myproxy-init -l vladimir.mencl --retrievable_by "John Q Public"

IMPORTANT:  myproxy-logon uses a local proxy certificate if it exists.  

To be sure you are using your user certificate, remember to run grid-proxy-destroy before myproxy-logon.

1) myproxy-init creates a L2 proxy in myproxy  

>    ??? why not L1 ???

2) myproxy-logon creates a L+1 proxy (L3 if myproxy has L2 proxy)

3) myproxy-store copies private key and certficate from .globus to myproxy

>     !!!! DOES NOT ASK FOR PASSPHRASE
> - passphrase used to encrypt the private key is considered to be the credentials passphrase
> - with an unencrypted key, there is no passphrase and only a trusted retriever may access the key
> - myproxy-* cannot ask for a passphrase, a local proxy must be created first with grid-proxy-init (or voms-proxy-init)

4) myproxy-retrieve should retrieve that (if key_retrievers permitted)

> - yes it does (if there is a passphrase associated with the key)

4b) myproxy-retrieve cannot retrieve proxy created by myproxy-init:

> - myproxy-init has now paramater to specify key retriever
> - unless permitted by default policy, server won't allow key retrieval
> - it is possible to manually alter credential data in /var/myproxy
> - add KEYRETRIEVERS=*

5) ??? should myproxy-logon create L1 proxy from stored credentials?

> - YES - there must be a passphrase with the stored key

XXX does not work:

>    -T, --trustroots (Retrieve CA certificates directory from server) 
> - does not do anything
>    X509_CERT_DIR (or ~/.globus/certificates) must contain CA cert for myproxy server - more on [http://grid.ncsa.uiuc.edu/myproxy/trustroots/](http://grid.ncsa.uiuc.edu/myproxy/trustroots/)

XXX try renewing

>    myproxy-retrieve --authorization file
>      (in addition to own identity)

store with --allow-anonymous-renewers:

myproxy-init -l vladimir.mencl --allow_anonymous_retrievers --allow_anonymous_renewers --credname weekcert

retrieve with

myproxy-logon -l vladimir.mencl -k weekcert -a /tmp/x509up_u13238

IMPORTANT FACT: 

>   1) passphrase protecting credentials is used to encrypt the private key as stored in /var/myproxy
>   2) renewable credentials cannot have a passphrase
>   3) renewable credentials cannot be retrieved anonymously

??? myproxy-get-delegation 

>    ???? EPR
> - nope, it's only a synonym for myproxy-login

try myproxy with service certificate (generate)

> - as documented: clients are happy with {host/,myproxy/,}hostname
> - http certificate did not make client happy

could be fixed with 

MYPROXY_SERVER_DN="/C=NZ/O=BeSTGRID/OU=Advanced Technologies Group/CN=http/vdtcentos.bestgrid"
