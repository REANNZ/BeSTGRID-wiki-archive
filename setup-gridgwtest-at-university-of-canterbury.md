# Setup GridGwTest at University of Canterbury

Setup `gridgwtest` - a test Xen virtual machine for testing (client) grid software.

- Basic Xen Install - [Vladimir__Bootstrapping a virtual machine](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Bootstrapping%20a%20virtual%20machine&linkCreation=true&fromPageId=3818228974)

- Install pacman 3.19, source pacman

- Start pacman

>  pacman -pretend-platform linux-rhel-4 -http-proxy [http://gridws1.canterbury.ac.nz:3128](http://gridws1.canterbury.ac.nz:3128) 
>  pacman -pretend-platform linux-rhel-4 -http-proxy [http://gridws1.canterbury.ac.nz:3128](http://gridws1.canterbury.ac.nz:3128) 
>  pacman -pretend-platform linux-rhel-4 -get [http://vdt.cs.wisc.edu/vdt_161_cache:VDT-Client](http://vdt.cs.wisc.edu/vdt_161_cache:VDT-Client)

- Questions:
	
- licenses Yes
- Condor No
- Logrotate Yes
- Cron CA CRLs Yes
- CAs Root

- Install VPAC GBuild (even though not used here)


>   http_proxy=[http://gridws1:3128](http://gridws1:3128) wget --proxy [http://www.grid.apac.edu.au/repository/dist/APAC-Grid.repo](http://www.grid.apac.edu.au/repository/dist/APAC-Grid.repo)
>   http_proxy=[http://gridws1:3128](http://gridws1:3128) yum --disablerepo="*" --enablerepo=apacgrid install Gbuild
>   http_proxy=[http://gridws1:3128](http://gridws1:3128) wget --proxy [http://www.grid.apac.edu.au/repository/dist/APAC-Grid.repo](http://www.grid.apac.edu.au/repository/dist/APAC-Grid.repo)
>   http_proxy=[http://gridws1:3128](http://gridws1:3128) yum --disablerepo="*" --enablerepo=apacgrid install Gbuild

- Install "Full" CA Bundle (CA, sslconf, symlinks) from [http://www.vpac.org/twiki/bin/view/APACgrid/InstallCABundleAPACGridCA](http://www.vpac.org/twiki/bin/view/APACgrid/InstallCABundleAPACGridCA)


>  cd /etc
>  tar xvzf /root/APACGrid_CA_Bundle_Full.tar.gz
>  cd /etc
>  tar xvzf /root/APACGrid_CA_Bundle_Full.tar.gz

- Customize to agreed BeSTGRID certificate DN form: edit `/etc/grid-security/certificates/globus-{host,user}-ssl.conf.1e12d831`
	
- Add Level 1 Organization.  Set defaults for Level 1 Organization and Level 0 Organizational Unit:

>  diff -u /etc/grid-security/certificates/globus-user-ssl.conf.1e12d831.orig /etc/grid-security/certificates/globus-user-ssl.conf.1e12d831
>  — /etc/grid-security/certificates/globus-user-ssl.conf.1e12d831.orig  2007-04-24 13:33:36.000000000 +1200
>  +++ /etc/grid-security/certificates/globus-user-ssl.conf.1e12d831       2007-04-24 13:34:12.000000000 +1200
>  @@ -69,8 +69,10 @@
>   0.countryName_default           = AU
>   0.organizationName              = Level 0 Organization
>   0.organizationName_default      = APACGrid
>  -0.organizationalUnitName        = Level 0 Organizational Unit
>  -0.organizationalUnitName_default = VPAC
>  +1.organizationName              = Grid Organization
>  +1.organizationName_default      = BeSTGRID
>  +0.organizationalUnitName        = Organizational Unit
>  +0.organizationalUnitName_default = University of Canterbury
>   commonName                      = Name (e.g., John M. Smith)
>   commonName_max                  = 64
>   emailAddress                    = Email

 diff -u /etc/grid-security/certificates/globus-host-ssl.conf.1e12d831.orig /etc/grid-security/certificates/globus-host-ssl.conf.1e12d831

>  — /etc/grid-security/certificates/globus-host-ssl.conf.1e12d831.orig  2007-04-24 13:33:27.000000000 +1200
>  +++ /etc/grid-security/certificates/globus-host-ssl.conf.1e12d831       2007-04-24 13:33:47.000000000 +1200
>  @@ -69,8 +69,10 @@
>   0.countryName_default          = AU
>   0.organizationName              = Grid Organization
>   0.organizationName_default      = APACGrid
>  +1.organizationName              = Grid Organization
>  +1.organizationName_default      = BeSTGRID
>   0.organizationalUnitName        = Organizational Unit
>  -0.organizationalUnitName_default = VPAC
>  +0.organizationalUnitName_default = University of Canterbury
>   commonName                      = hostname.vpac.edu.au
>   commonName_max                  = 64
>   emailAddress                    = Email

- Modified `grid-cert-request` to put email address into openssl input stream (after Common Name)


>  diff -u /opt/vdt/globus/bin/grid-cert-request grid-cert-request
>  — /opt/vdt/globus/bin/grid-cert-request       2007-04-24 14:06:57.000000000 +1200
>  +++ grid-cert-request   2007-04-24 14:48:23.000000000 +1200
>  @@ -326,6 +326,10 @@
>                   INTERACTIVE="TRUE"
>                   shift
>                   ;;
>  +            -email)
>  +                emailAddress="$2"
>  +                shift ; shift
>  +                ;;
>               -force)
>                   FORCE="TRUE"
>                   shift
>  @@ -425,6 +429,7 @@
>   '
>  diff -u /opt/vdt/globus/bin/grid-cert-request grid-cert-request
>  — /opt/vdt/globus/bin/grid-cert-request       2007-04-24 14:06:57.000000000 +1200
>  +++ grid-cert-request   2007-04-24 14:48:23.000000000 +1200
>  @@ -326,6 +326,10 @@
>                   INTERACTIVE="TRUE"
>                   shift
>                   ;;
>  +            -email)
>  +                emailAddress="$2"
>  +                shift ; shift
>  +                ;;
>               -force)
>                   FORCE="TRUE"
>                   shift
>  @@ -425,6 +429,7 @@
>   '

>       echo ${_common_name}
>  +    echo ${emailAddress}
>   }

- Generated host cert requests with

for I in grid ngcompute gridgwtest ng1 ng2 ngdata ngportal myproxy vomrs nggums ; do ./grid-cert-request -host ${I}.canterbury.ac.nz -ca 1e12d831 -nopw -dir /root/hostcerts/$I -email vladimir.mencl@canterbury.ac.nz ; done

- Start CRL updates:


>  vdt-control --on fetch-crl
>  vdt-control --on fetch-crl

- Run CRL updates once through squid proxy:


>  http_proxy=[http://gridws1:3128](http://gridws1:3128) /opt/vdt/fetch-crl/share/doc/fetch-crl-2.6.2/fetch-crl.cron
>  http_proxy=[http://gridws1:3128](http://gridws1:3128) /opt/vdt/fetch-crl/share/doc/fetch-crl-2.6.2/fetch-crl.cron

- Create /opt/vdt/glite/etc/vomses and put vomses specifications for APACGrid and gin.ggf.org there:

>  "APACGrid" "vomrs.apac.edu.au" "15001" "/C=AU/O=APACGrid/OU=APAC/CN=vomrs.apac.edu.au" "APACGrid"

 "gin.ggf.org" "kuiken.nikhef.nl" "15050" "/O=dutchgrid/O=hosts/OU=nikhef.nl/CN=kuiken.nikhef.nl" "gin.ggf.org"
