# Setup AUT GUMS server

This page documents the setup of a GUMS server at AUT, as a part of their grid gateway.  There's nothing atypical at this server and the installation primarily follows [https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums](https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums).  See the [Otago GUMS installation notes](/wiki/spaces/BeSTGRID/pages/3818228928) for more verbose documentation of a similar install.

## Preliminaries

- Configure ARCS RPM repository


>  cd /etc/yum.repos.d && wget [http://projects.arcs.org.au/dist/arcs.repo](http://projects.arcs.org.au/dist/arcs.repo)
>  cd /etc/yum.repos.d && wget [http://projects.arcs.org.au/dist/arcs.repo](http://projects.arcs.org.au/dist/arcs.repo)

- Install GridPulse


>  yum install APAC-gateway-gridpulse
>  yum install APAC-gateway-gridpulse

- Configure outgoing SMTP server

``` 
cd /etc/mail
```
- **edit **`mailertable`** and configure a default SMTP relay that*will not** overwrite From: address:

``` 
 .       smtp:[ulduar.aut.ac.nz]
```
- update binary form

``` 
make
```

- Make GridPulse happy


>  chkconfig cpuspeed off
>  chkconfig mdmonitor off
>  chkconfig irqbalance off
>  chkconfig ip6tables off
>  chkconfig iptables off
>  chkconfig mcstrans off # selinux is already disabled
>  chkconfig cpuspeed off
>  chkconfig mdmonitor off
>  chkconfig irqbalance off
>  chkconfig ip6tables off
>  chkconfig iptables off
>  chkconfig mcstrans off # selinux is already disabled

- Install host certificate in `/etc/grid-security`
- Create grid-security directory:

``` 
mkdir -p /etc/grid-security
```
- Copy host certificate into `http/http{cert,key}.pem`


>   chown daemon:daemon /etc/grid-security/http/http{cert,key}.pem
>   chown daemon:daemon /etc/grid-security/http/http{cert,key}.pem

## Pacman and GUMS

- Install pacman

``` 

mkdir /opt/vdt
cd /opt/vdt
wget http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz
tar xf pacman-*.tar.gz
cd pacman-*/ && source setup.sh && cd ..

```
- Run pacman to install GUMS

``` 

cd /opt/vdt
export VDTMIRROR=http://vdt.cs.wisc.edu/vdt_1101_cache
pacman -get $VDTMIRROR:GUMS

```
- Load VDT configuration


>  . /opt/vdt/setup.sh
>  . /opt/vdt/setup.sh

- Enable loading the configuration by default


>  ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
>  ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh

- Configure Cert URL:

``` 
vi $VDT_LOCATION/vdt/etc/vdt-update-certs.conf
```
- Uncomment

``` 
cacerts_url = http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version
```
- Run

``` 
. $VDT_LOCATION/vdt-questions.sh; $VDT_LOCATION/vdt/sbin/vdt-setup-ca-certificates
```

- Configure Apache to use a small CA bundle instead of `SSLCACertificatePath`
	
- Download [http://staff.vpac.org/~sam/arcs-bundle.crt](http://staff.vpac.org/~sam/arcs-bundle.crt) into `/etc/grid-security/`
- Edit `/opt/vdt/apache/conf/extra/httpd-ssl.conf` and replace `SSLCACertificatePath` with 

``` 
SSLCACertificateFile /etc/grid-security/arcs-bundle.crt
```

- Turn services on


>  vdt-control --on
>  vdt-control --on

## Configuring GUMS

- Add myself as Admin


>  /opt/vdt/tomcat/v55/webapps/gums/WEB-INF/scripts/gums-add-mysql-admin "/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl"
>  /opt/vdt/tomcat/v55/webapps/gums/WEB-INF/scripts/gums-add-mysql-admin "/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl"

- Install the ARCS SLCS CA bundle - follow
[http://wiki.arcs.org.au/bin/view/Main/SLCS](http://wiki.arcs.org.au/bin/view/Main/SLCS)


- Configure the VOMS-GUMS synchronization interval in `$VDT_LOCATION/tomcat/v55/webapps/gums/WEB-INF/web.xml` - change `updateGroupsMinutes` from **720** to **12**

- GUMS is now live at [https://nggums.aut.ac.nz:8443/gums](https://nggums.aut.ac.nz:8443/gums)

- Configure VOMS Server, Account Mappers, User Groups, GroupToAccount mappings, HostToGroup mapping.

## Polishing Globus

- Fix startup and shutdown of gateway services for MySQL, Tomcat-55 and Apache

1. To start in this order
2. To shutdown in reverse order
3. To create a lock in /var/lock/subsys when started - so that a system shutdown knows to close down these services gracefully.

See my description of the [problem](vladimirs-grid-notes.md#Vladimir&#39;sgridnotes-RFTstagingfails), a fix to [startup order](vladimirs-grid-notes.md#Vladimir&#39;sgridnotes-Fixingstartuporder), and a fix for [correct shutdown](vladimirs-grid-notes.md#Vladimir&#39;sgridnotes-Fixingshutdown)
