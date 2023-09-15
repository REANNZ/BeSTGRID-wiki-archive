# Setup NGPortal at University of Canterbury

- [BeSTGRID Bioportal|http

//ngportal.canterbury.ac.nz/gridsphere/gridsphere]

hosted at the University of Canterbury


---

NGPortal is the machine running the GridSphere portal with the job submission portlet.  Tomcat, GridSphere and core grid infrastructure parts are setup based on the [APAC NGPortal setup instructions](http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsNgportal), now migrated to [http://www.grid.apac.edu.au/repository/trac/systems/wiki/HowTo/InstallNgPortal](http://www.grid.apac.edu.au/repository/trac/systems/wiki/HowTo/InstallNgPortal).

On top of that, the job submission portlet is installed following the [Usefulportlet Installation Guide](https://www.hpc.jcu.edu.au/trac/apac/wiki/UsefulPortletInstallationGuide), and the server also has a number of local configuration tweaks (such as a chrooted gridftp-server).

# Installing NGPortal distribution and GridSphere

- Install and update the Xen VM

## Installing NGPortal RPMs

- Enable APAC development repo (was needed at time of initial writing).


>  vi /etc/yum.repos.d/APAC-Grid.repo
>  vi /etc/yum.repos.d/APAC-Grid.repo

>  [apacdevel]
>  ...
>  **enabled=1**

- Configure EUGRID-PMA repository


>  wget -P /etc/yum.repos.d [http://www.vpac.org/grid/files/eugridpma.repo](http://www.vpac.org/grid/files/eugridpma.repo)
>  wget -P /etc/yum.repos.d [http://www.vpac.org/grid/files/eugridpma.repo](http://www.vpac.org/grid/files/eugridpma.repo)

- Import RPM keys for the PMA repository


>  rpm --import [http://dist.eugridpma.info/distribution/igtf/current/GPG-KEY-EUGridPMA-RPM-3](http://dist.eugridpma.info/distribution/igtf/current/GPG-KEY-EUGridPMA-RPM-3)
>  rpm --import [http://dries.ulyssis.org/rpm/RPM-GPG-KEY.dries.txt](http://dries.ulyssis.org/rpm/RPM-GPG-KEY.dries.txt)
>  rpm --import [http://dist.eugridpma.info/distribution/igtf/current/GPG-KEY-EUGridPMA-RPM-3](http://dist.eugridpma.info/distribution/igtf/current/GPG-KEY-EUGridPMA-RPM-3)
>  rpm --import [http://dries.ulyssis.org/rpm/RPM-GPG-KEY.dries.txt](http://dries.ulyssis.org/rpm/RPM-GPG-KEY.dries.txt)

- Setup local host certificates:


>  mkdir /etc/grid-security
> 1. put hostcert.pem hostkey.pem into /etc/grid-security/
> 2. (and make hostkey.pem readable only to root)
>  mkdir /etc/grid-security
> 1. put hostcert.pem hostkey.pem into /etc/grid-security/
> 2. (and make hostkey.pem readable only to root)

- Install host certificate place-holder RPM - only checks if certificate modulus matches the key


>  rpm -ivh [http://hpc-aw.its.tils.qut.edu.au/files/portal/APAC-gateway-host-certificates-0.1-1.noarch.rpm](http://hpc-aw.its.tils.qut.edu.au/files/portal/APAC-gateway-host-certificates-0.1-1.noarch.rpm)
>  rpm -ivh [http://hpc-aw.its.tils.qut.edu.au/files/portal/APAC-gateway-host-certificates-0.1-1.noarch.rpm](http://hpc-aw.its.tils.qut.edu.au/files/portal/APAC-gateway-host-certificates-0.1-1.noarch.rpm)

- Now... install ngportal


>  yum install APAC-gateway-ngportal
>  yum install APAC-gateway-ngportal

- Install RPMs for all IGTF approved CAs


>  yum install ca_policy_igtf-classic
>  yum install ca_policy_igtf-classic

- Install GridSphere and GridSphere-portlets source code (necessary to compile the UsefulPortlet)


>  yum install APAC-gridsphere-devel APAC-gridportlets-devel
>  yum install APAC-gridsphere-devel APAC-gridportlets-devel

## Post-install configuration

- Disable services `gridpulse.sh` would complain about:


>  chkconfig cpuspeed off
>  chkconfig lvm2-monitor off
>  chkconfig cpuspeed off
>  chkconfig lvm2-monitor off

- Fetch CRLs (for the so far installed CAs):


>  /etc/cron.daily/05-get-crl
>  /etc/cron.daily/05-get-crl


## Enabling SSL in Apache

- Install Apache SSL module


>  yum install mod_ssl 
>  yum install mod_ssl 


## Configuring commercial https-frontend certificate

- Put the certificates into `/etc/grid-security/http-front` and symlink them as `http-front-{cert,key,chain}.pem`


>  ln -s ngportal.canterbury.ac.nz-cert.pem http-front-cert.pem
>  ln -s ngportal.canterbury.ac.nz-key.pem http-front-key.pem
>  ln -s IPS-IPSCABUNDLE.CRT http-front-chain.pem
>  ln -s ngportal.canterbury.ac.nz-cert.pem http-front-cert.pem
>  ln -s ngportal.canterbury.ac.nz-key.pem http-front-key.pem
>  ln -s IPS-IPSCABUNDLE.CRT http-front-chain.pem

- Edit `/etc/httpd/conf.d/ssl.conf` to point to these files


>  SSLCertificateFile /etc/grid-security/http-front/http-front-cert.pem
>  SSLCertificateKeyFile /etc/grid-security/http-front/http-front-key.pem
>  SSLCertificateChainFile /etc/grid-security/http-front/http-front-chain.pem
>  SSLCertificateFile /etc/grid-security/http-front/http-front-cert.pem
>  SSLCertificateKeyFile /etc/grid-security/http-front/http-front-key.pem
>  SSLCertificateChainFile /etc/grid-security/http-front/http-front-chain.pem


# Configuring GridFTP on ngportal

The portal needs a subtree of the local file system accessible via GridFTP - so that the gateways receiving the job submissions can stage the jobs' files in from the portal and out back to the portal.

To run the GridFTP server, one needs to install at least the basic parts of the Globus Toolkit.  We have chosen to use the VDT RPM distribution for this.

- From [http://vdt.cs.wisc.edu/](http://vdt.cs.wisc.edu/), download the following packages for the current VDT release (the list below is for VDT1.6.1 on CentOS 4 on x86):


>  vdt_globus_essentials-VDT1.6.0x86_rhas_4-2
>  vdt_globus_data_server-VDT1.6.0x86_rhas_4-3
>  gpt-VDT1.6.0x86_rhas_4-1
>  vdt_globus_essentials-VDT1.6.0x86_rhas_4-2
>  vdt_globus_data_server-VDT1.6.0x86_rhas_4-3
>  gpt-VDT1.6.0x86_rhas_4-1

 rpm -Uvh {vdt_globus,gpt}*.rpm

- Configuring Globus

- Globus needs some local configuration files to be created - the following command sequence does that:


>   cd /opt/globus/setup/globus
>   export GPT_LOCATION=/opt/gpt GLOBUS_LOCATION=/opt/globus
>   ./findshelltools
>   ./setup-tmpdirs
>   ./setup-globus-common 
>   cd /opt/globus/setup/globus
>   export GPT_LOCATION=/opt/gpt GLOBUS_LOCATION=/opt/globus
>   ./findshelltools
>   ./setup-tmpdirs
>   ./setup-globus-common 

- Add GSIFTP protocol to `/etc/services`


>  gsiftp          2811/tcp        # added 2007-07-18 by Vladimir Mencl 
>  gsiftp          2811/tcp        # added 2007-07-18 by Vladimir Mencl 

- Add gsiftp entry to xinetd configuration: create `/etc/xinetd.d/gsiftp` with:

``` 

service gsiftp
{
    socket_type = stream
    protocol    = tcp
    wait        = no
    user        = root
    instances   = UNLIMITED
    cps         = 400 10
    server      = /opt/globus/sbin/globus-gridftp-server-start.sh
    disable     = no
}

```

- Create a gridftp configuration file: create `/opt/globus/etc/gridftp.conf` with the following contents:

``` 

# manual configuration for GridFTP server

inetd 1

log_level ERROR,WARN,INFO
log_single /opt/globus/var/log/gridftp-auth.log
log_transfer /opt/globus/var/log/gridftp.log 

```
- We need a wrapper to source the Globus environment variables before starting the gridftp-server binary.  Create `/opt/globus/sbin/globus-gridftp-server-start.sh` with:

``` 

#!/bin/bash

export GPT_LOCATION=/opt/gpt
export GLOBUS_LOCATION=/opt/globus
export GLOBUS_TCP_PORT_RANGE=40000,41000 
. $GLOBUS_LOCATION/etc/globus-user-env.sh
exec /opt/globus/sbin/globus-gridftp-server -inetd "$@"

```
- Note: setting GLOBUS_TCP_PORT_RANGE is necessary to avoid firewall problems when jobs are submitted to remote sites (the default Globus configuration does not set this variable).

- Restart xinetd - this enables the GridFTP server


>  service xinetd restart 
>  service xinetd restart 

- The GridFTP server should now start when a client connects to port 2811.  We still however need to setup authorization (via `gridmap-file`), and chroot the GridFTP server to /home/tomcat/portal.

## Grid-mapfile configuration

We found it easier to use grid-mapfile as the authorization mechanism for the GridFTP server (even though a GUMS server is an option).  To we have chosen to use an RPM-based edg-mkgridmap package to generate the grid-mapfile.  This section describes the steps to install this package.

As recommended by [VDT edg-mkgridmap documentation](http://vdt.cs.wisc.edu/components/edg-mkgridmap.html), we have retrieved the edg-mkgridmap package from [http://grid-deployment.web.cern.ch/grid-deployment/RpmDir_i386-sl3/lcg/](http://grid-deployment.web.cern.ch/grid-deployment/RpmDir_i386-sl3/lcg/) - files `edg-mkgridmap-2.8.1-1.noarch.rpm` and `edg-mkgridmap-conf-2.8.1-1.noarch.rpm`.

>  ***Note (2008-07-17)**: use version at least 3.0.0 (from [http://eticssoft.web.cern.ch/eticssoft/repository/org.glite/edg-mkgridmap/](http://eticssoft.web.cern.ch/eticssoft/repository/org.glite/edg-mkgridmap/)) to interact with VOMSAdmin 2.0 services.

- 
- Note: after ARCS updated their VOMS server, updating edg-mkgridmap to 3.0.1

- Install dependencies


>  yum install perl-Crypt-SSLeay perl-DateManip perl-LDAP perl-URI perl-libwww-perl perl-libxml-enno
>  yum install perl-Crypt-SSLeay perl-DateManip perl-LDAP perl-URI perl-libwww-perl perl-libxml-enno

- Install additional dependencies from the addons repository


>  yum --enablerepo=addons --enablerepo=extras install perl-IO-Socket-SSL perl-Net-SSLeay
>  yum --enablerepo=addons --enablerepo=extras install perl-IO-Socket-SSL perl-Net-SSLeay


>  rpm -Uvh edg-mkgridmap-2.8.1-1.noarch.rpm edg-mkgridmap-conf-2.8.1-1.noarch.rpm
>  rpm -Uvh edg-mkgridmap-2.8.1-1.noarch.rpm edg-mkgridmap-conf-2.8.1-1.noarch.rpm

- Create edg-mkgridmap configuration: edit `/opt/edg/etc/edg-mkgridmap.conf` and allow all VOs BeSTGRID gateways would allow

``` 

group vomss://vomrs.apac.edu.au:8443/voms/APACGrid?/APACGrid/BeSTGRID tomcat
group vomss://vomrs.apac.edu.au:8443/voms/APACGrid?/APACGrid/NGAdmin tomcat

gmf_local /opt/edg/etc/grid-mapfile-local

```
- Create empty /opt/edg/etc/grid-mapfile-local


>  touch /opt/edg/etc/grid-mapfile-local
>  touch /opt/edg/etc/grid-mapfile-local

- Create empty edg-mkgridmap logfile


>  mkdir /opt/edg/log
>  touch /opt/edg/log/edg-mkgridmap.log
>  mkdir /opt/edg/log
>  touch /opt/edg/log/edg-mkgridmap.log

- Run edg-mkgridmap for the first time


>  /opt/edg/sbin/edg-mkgridmap --output=/etc/grid-security/grid-mapfile
>  /opt/edg/sbin/edg-mkgridmap --output=/etc/grid-security/grid-mapfile

- If chrooted GridFTP server is already set up (see below), also run


>  /opt/edg/sbin/edg-mkgridmap --output=/home/tomcat/portal/etc/grid-security/grid-mapfile
>  /opt/edg/sbin/edg-mkgridmap --output=/home/tomcat/portal/etc/grid-security/grid-mapfile

- Setup a cron job to run edg-mkgridmap periodically: as root, run `crontab -e` and put the following entries into the crontab:


>  41 3,9,15,21 * * * /opt/edg/sbin/edg-mkgridmap --output=/etc/grid-security/grid-mapfile >> /opt/edg/log/edg-mkgridmap.log 2>&1
>  41 3,9,15,21 * * * /opt/edg/sbin/edg-mkgridmap --output=/home/tomcat/portal/etc/grid-security/grid-mapfile >> /opt/edg/log/edg-mkgridmap.log 2>&1
>  41 3,9,15,21 * * * /opt/edg/sbin/edg-mkgridmap --output=/etc/grid-security/grid-mapfile >> /opt/edg/log/edg-mkgridmap.log 2>&1
>  41 3,9,15,21 * * * /opt/edg/sbin/edg-mkgridmap --output=/home/tomcat/portal/etc/grid-security/grid-mapfile >> /opt/edg/log/edg-mkgridmap.log 2>&1

## Configuring chrooted GridFTP server

We need to run the GridFTP server in a chrooted environment.  The main reason for that is that all users accessing the portal via GridFTP (to get job input files or upload results back) will be mapped to the user `tomcat`.  The mapping has to be done this way because all the input files (and their containing directories) are stored in the local filesystem by the portlet code running as `tomcat`, and are thus owned by `tomcat`.  Consequently, to have permission to upload files to these directories, each user has to be mapped to `tomcat`.  This would however give the users the ability to tamper with the portlet code, and also to access the portal SSL private key.  To avoid this, the GridFTP server has to run chrooted to a directory hierarchy containing only the portal job files, `/home/tomcat/portal`.

The following command sequence creates a chrooted environment sufficient to run the GridFPT server:

``` 

cd /home/tomcat/portal
chown root.root .
mkdir -p etc/grid-security
ln /etc/grid-security/grid-mapfile etc/grid-security/
mkdir -p opt/globus/sbin
mkdir -p opt/globus/lib
ln /opt/globus/sbin/globus-gridftp-server* opt/globus/sbin
ln /opt/globus/lib/lib*.so.* opt/globus/lib
mkdir -p lib/i686
ln /lib/i686/lib{c,m}* lib/i686/
ln /lib/libdl* lib
ln /lib/ld-* lib
mkdir tmp
chmod 1777 tmp
mkdir dev
cp /dev/MAKEDEV dev
./dev/MAKEDEV -d ./dev -x console zero null random urandom
mkdir -p etc/grid-security/certificates
ln /etc/{resolv.conf,passwd,localtime,termcap,nsswitch.conf} etc
ln /etc/grid-security/host{cert,key}.pem etc/grid-security/
ln /etc/grid-security/certificates/* etc/grid-security/certificates/
### make sure CRLs are updated
# setup /opt/globus/etc/gridftp.conf
mkdir -p opt/globus/var/log/
mkdir -p opt/globus/etc
ln /opt/globus/etc/gridftp.conf opt/globus/etc/
ln -s . home
ln -s . tomcat
ln -s . portal
mkdir portaldata
chmod 1777 portaldata
chmod 755 .
ln /lib/libnss_dns* lib
ln /lib/libresolv* lib
ln /etc/host.conf etc
ln /lib/libnss_files* lib
ln /etc/group etc

```

Now edit the `/opt/globus/sbin/globus-gridftp-server-start.sh` file and make GridFTP server start in this chrooted environment - change the final line to:

>  exec chroot /home/tomcat/portal /opt/globus/sbin/globus-gridftp-server -inetd "$@"

## Updating certificates for chrooted GridFTP server

The `APAC-gateway-crl-update` RPM package installs a cron job file in `/etc/cron.daily/05-get-crl{{.  This assures that certificates are daily updated in {{/etc/grid-security/certificates/`.  To update them also in the chrooted environment (in `/home/tomcat/portal/etc/grid-security/certificates/`), the following script has to be installed into `/etc/cron.daily/06-get-crl-portal-tomcat`:

``` 

#!/bin/sh

BASE=/home/tomcat/portal/etc/grid-security
INPUT_DIR=$BASE/certificates
CERT_DIR=$INPUT_DIR

/usr/sbin/fetch-crl --loc $INPUT_DIR --out $CERT_DIR --quiet

```

# GridSphere Configuration

General considerations: the Usefulportlet code was written to use GridPortlets 2.5, but Tobias has adjusted the code to run with GridSphere 2.2.7 / GridPortlets 1.3.

- Change password for the Tomcat user `gridsphere` - in Tomcat's `tomcat-users.xml` and in GridSphere configuration (`/usr/local/apache-tomcat/webapps/gridsphere/WEB-INF/GridSphereServices.xml`).
- Add `emptySessionPath="true"` to the }}Connector}} (AJP/1.3 connector at 8009) definition in Tomcat `conf/server.xml`
	
- Recommended by the UsefulPortlet installation guidelines.

Note: GridSphere is installed into `/usr/local/apache-tomcat/webapps/gridsphere/`, while the GridSphere source code is in `/usr/local/gridsphere`

## Configuration aspects to be aware of

### Certificates

1. Tomcat needs access to the host certificate - to use it for retrieving credentials from myproxy, and to use it for SSL sockets opened by Tomcat.
	
- The RPM post-install scriptlets copy the certificate into `/etc/grid-security/portal{cert,key}.pem` owned by `tomcat`.
- Also, when first started, tomcat creates `/etc/grid-security/truststore`, a Java keystore containing the certificate.

In case the host certificate is replaced, **it is essential to remove the **`truststore`** file**, otherwise, Tomcat would not trust its own certificate when it opens an SSL connection to itself.  When Tomcat is restarted, the `truststore` file will be re-created.

### GridSphere Groups

A GridSphere group is a collection of portlets to be made available to selected users.  GridSphere allows to create an arbitrary number of groups, and assing users to these groups.  In this portal, we create a single group BeSTGRID containing the portlets *Credentials*, *Jobs and Results*, and *Remote files* (in this order).

GridSphere allows to choose the selection of portlets at the time the group is created, and has editing features to change this information at a later time.  However, the editing features do not work, and any attempts to modify the group will be ignored.  Thus, it is important to get everything right when creating the group.

Specifically, a group has to be re-created after any change to

- Group name
- Selection of portlets
- Renaming a portlet

At least minor changes can later be done manually by directly editing the group definition file in `/usr/local/apache-tomcat/webapps/gridsphere/WEB-INF/CustomPortal/layouts/groups`.  In this portal, we did reorder and rename the portlets by editing the file to display the portlets under names more intuitively understandable to novice users.

# Configuring UsefulPortlet

Installation of the UsefulPortlet has well been documented in the [UsefulPortlet Installation Guide](http://www.hpc.jcu.edu.au/projects/apac/wiki/UsefulPortletInstallationGuide).

My install notes have been focusing on what was done differently then documented in these notes; hence, this guide may not be complete.

## Checkout and compile

Installation of the UsefulPortlet consists of installing and compiling three parts: the GT4Helper, the Interpreter and Interpreter Client (the portlet itself), and Interpreter Shell (a helper web application providing static configuration pages).

- Checkout all the source code

``` 

mkdir portlets
cd portlets
svn co http://www.hpc.jcu.edu.au/projects/hpc/svn/xjse/GT4Helper/trunk GT4Helper
svn co http://www.hpc.jcu.edu.au/projects/hpc/svn/portlets/interpreter/trunk interpreter
svn co http://www.hpc.jcu.edu.au/projects/hpc/svn/portlets/interpreter_client/trunk interpreter_client

```

- Generate Java XML bindings (for configuration file and for the MDS information)


>  cd interpreter
>  ./castor.sh
>  cd interpreter
>  ./castor.sh

- Update jars:
	
- Extract [http://ng0.hpc.jcu.edu.au/apac/dependencies-4.0.3.tgz](http://ng0.hpc.jcu.edu.au/apac/dependencies-4.0.3.tgz) into `/usr/local/apache-tomcat/shared/lib`

``` 
wget http://ng0.hpc.jcu.edu.au/apac/dependencies-4.0.3.tgz -O - | tar -C /usr/local/apache-tomcat/shared/lib -zxf -
```
- Note: this includes gram-stubs.jar needed to compile interpreter


- Compile each of the three parts (GT4Helper, interpreter, interpreter_client) with:


>  GRIDSPHERE_HOME=/usr/local/gridsphere/ ant deploy
>  GRIDSPHERE_HOME=/usr/local/gridsphere/ ant deploy

## Install Interpreter Shell

The Interpreter Shell is a small web application consisting of JSPs and static content served by the portal.  The configuration file `configuration.xml` asks for the Interpreter Shell to be accessible at [http://localhost:8080/interpreter_shell](http://localhost:8080/interpreter_shell).  The following two commands make it accessible there:

>  svn co [http://www.hpc.jcu.edu.au/projects/hpc/svn/portlets/interpreter_shell/trunk](http://www.hpc.jcu.edu.au/projects/hpc/svn/portlets/interpreter_shell/trunk) interpreter_shell
>  cp -R -p interpreter_shell /usr/local/apache-tomcat/webapps

## Configure GridPorlets Resources

The Registry portlet coming with GridPortlets allows to declare a number of grid resources that should be available to the portlets.  It is necessary to define at least a MyProxy resource, and it is recommended to also define a GridFTP resource for each gateway where the users would submit their jobs.  Adding the GridFTP resource allows users to use the built-in GridFTP client (*Remote files* portlet) to access their files while a job is running (and also after the job completes if they were not staged out at job completion time due to expired credentials).

The following configuration fragment shows the resources defined at `ngportal.canterbury.ac.nz`

``` 

   <hardware-resource label="MyProxy APAC"
       description="APAC MyProxy server"
       hostname="myproxy.apac.edu.au">
     <myproxy-resource 
         portalCertFile="/etc/grid-security/portalcert.pem"
         portalKeyFile="/etc/grid-security/portalkey.pem"
         usePortalCredential="true"
         port="7512"
         label="myproxy"
         description="myproxy" />
    </hardware-resource>

    <hardware-resource label="GatewayNG2"
        description="Grid Gateway NG2" 
        hostname="ng2.canterbury.ac.nz">
      <ws-gram-resource />
      <gridftp-resource />
      <gram-job-manager name="PBS">
        <job-queue name="small" nodes="4"/>
      </gram-job-manager>
   </hardware-resource>

   <hardware-resource label="GatewayNG2HPC"
       description="Grid Gateway NG2HPC" 
       hostname="ng2hpc.canterbury.ac.nz">
     <ws-gram-resource />
     <gridftp-resource />
   </hardware-resource>

```

Note that in the MyProxy resource definition, `usePortalCredential` allows to make credentials in the repository retrievable only by the portal (and not just by anyone who has the username and password).  However, one has to avoid using the directive `portalProxyFile`, as it renders the resource unusable.

## Apache Tomcat connector

To make the Tomcat web applications Interpreter Client (part of the UsefulPortlet) and Interpreter Shell (static content) available via the Apache frontend, the following to lines have to be added to `/etc/httpd/conf.d/mod_jk.conf`:

>      JkMount /interpreter_shell/* ajp13
>      JkMount /interpreter_client/* ajp13

## Configuring file-space URLs

It is necessary to enter into the UsefulPortlet configuration the base URL for the portal data filespace, and the local path to the root of that directory.  In our configuration, the URL is `gsiftp://ngportal.canterbury.ac.nz/portaldata/` and the local filesystem path is `/home/tomcat/portal/portaldata/`.  This configuration information is entered in the file `/usr/local/apache-tomcat/webapps/interpreter_client/config/configuration.xml` in the `persistence-base-for-*` attributes of the root element:

``` 

<group-configuration
   persistence-base-for-portal="/home/tomcat/portal/portaldata/"
   persistence-base-for-gridftp="gsiftp://ngportal.canterbury.ac.nz/portaldata/"
   prefix="https://ngportal.canterbury.ac.nz/interpreter_shell"
   assistance-message="Please contact the administrator at tobias@biomatters.com">

```

Note that previously, this was configured in the `interpreter.properties` file.  This file no longer exists, and the settings have been merged into the `configuration.xml` file.

Note also that the file interpreter_client/webapp/WEB-INF/portlet.xml contains the location for downloading the configuration.xml file - which in our case is:

>  [https://ngportal.canterbury.ac.nz/interpreter_client/config/configuration.xml](https://ngportal.canterbury.ac.nz/interpreter_client/config/configuration.xml)

## Necessary library updates

To avoid having names of upload files converted to lowercase (which can then cause problems in applications like MrBays where the input file has to contain its correct full name), it ins necessary to update the file upload library: replace `commons-fileupload-1.1.jar` in `$CATALINA_HOME/shared/lib` with version 1.2.

## Installing applications on target cluster

To install an application already know by the portal onto a cluster, the steps are:

- install the application on the cluster and record the path to the executable (if the cluster does not support *modules* yet, make sure the executable is in the default `PATH`
- register the application in the cluster's software information file (like `/usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/ngcompute-localSoftware.xml`) on the gateway.
- in the registration, use the exact name and version as used by the portal - see version details in `/usr/local/apache-tomcat/webapps/interpreter_client/config/configuration.xml` (and the executable directory and name) - see the MrBayes sample configuration in the [NG2 setup instructions](setting-up-an-ng2.md).
- After the MDS information propagates (10-20 min), the application registration should be visible in `/home/tomcat/portal/preferences/mds.xml` (restart

tomcat if not updated)

## Miscellaneous Notes

- The following characters are filtered out from user supplied file names now:

``` 
~;!"''`$@/\\{}
```
- For job status, while "unknown" means that the job status couldn't be determined by the GT4Helper library (e.g. GT4Helper couldn't load the job from the .globus.xml file, or the getStatus() call failed after loading the job), "unsubmitted" means that the .globus.xml file is missing altogether.

# Miscellaneous Configuration Items

- To allow hosting Java Web Start applications in the Apache server, the Apache configuration defines the MIME type for jnlp files.  The newly created file `/etc/httpd/conf.d/jnlp.conf` contains


>   AddType application/x-java-jnlp-file .jnlp
>   AddType application/x-java-jnlp-file .jnlp


## Configuring Tomcat logging

Create `/usr/local/apache-tomcat/shared/lib/logging.properties` with

``` 

.level=ERROR

handlers=java.util.logging.ConsoleHandler

java.util.logging.ConsoleHandler.level = ERROR

```

This sets Tomcat logging to error only.  An unfiltered debug log could be created by instead using 

``` 

.level=ALL
handlers=java.util.logging.ConsoleHandler
java.util.logging.ConsoleHandler.level = ALL 

```

but this is *too* verbose and not recommended.

Check `/usr/local/apache-tomcat/webapps/interpreter_client/WEB-INF/classes/log4j.properties` to contain

>  log4j.rootCategory=ERROR, A1
>  log4j.logger.au.edu.jcu.hpc=DEBUG

- avoid turning on system-wide DEBUG logging for all of tomcat (would swamp the logfile)
- turn logging on only for UsefulPortlet

Check also logging in `/usr/local/apache-tomcat/webapps/gridsphere/WEB-INF/classes/log4j.properties`

## Configure Mod_Jk logging

ModJk by default logs at debug level, and produces large (>1GB) logs in `/var/log/httpd/mod_jk.log`.

Reduce the logging level by editing `/etc/httpd/conf.d/mod_jk.conf` and add

>  JkLogLevel      info

# TODO: persisting issues

- get a From address for gridsphere notification emails (now is me)
- change text of email "account was created"
- note: when auto-creating account, gridsphere says: "wait for email", but the email goes to site administrator(s)

- try extra configuring an SSL port (in Apache OR Tomcat) with a user certificate required, see if gridsphere accept it as authentication.

- change Tomcat logging configuration to a RollingFileAppender to avoid logfile size overflow. Sample:

``` 

log4j.appender.LOGFILE=org.apache.log4j.RollingFileAppender
log4j.appender.LOGFILE.layout=org.apache.log4j.PatternLayout
log4j.appender.LOGFILE.File=log.txt
log4j.appender.LOGFILE.MaxFileSize=4096KB
log4j.appender.LOGFILE.MaxBackupIndex=3
log4j.appender.LOGFILE.layout.ConversionPattern=%r:%p:(%F:%M:%L)%n< %m >%n%n

```

- ????? maybe update bounce castle jce library from 125 to 133 (Tobias needs for a library for obtaining VO information from certificates)
	
- Note: There is a number of versions of this library installed:

``` 

/usr/local/apache-tomcat/common/lib/jce-jdk13-131.jar
/usr/local/apache-tomcat/common/lib/gridportlets-wsrf-4.0.1-jce-jdk13-125.jar
/usr/local/apache-tomcat/shared/lib/jce-jdk13-131.jar
/usr/local/gridportlets/lib/ogsa-3.2.1/jce-jdk13-120.jar
/usr/local/gridportlets/lib/wsrf-4.0.1/jce-jdk13-125.jar

```


- commit the [GT4Helper changes](attachments/Gt4helper-ports-credlifetime.patch.txt) (
!Gt4helper-ports-credlifetime.patch.txt!
) to David Laing (GT4Helper)
	
- the patch allows alternative port types and extends default credential life time for duration of job + 24 hours

# Maintenance

## Certificate renewal

When renewing the host front-end https certificate, run the following commands to import the new certificate into the keystore used by Tomcat:

>  TRUST_STORE=/etc/grid-security/truststore
>  TRUST_CERTIFICATE=/etc/grid-security/http-front/http-front-cert.pem
>  rm /etc/grid-security/truststore 
>  keytool -import -noprompt -alias localhost -keystore $TRUST_STORE -file $TRUST_CERTIFICATE -storepass "supersecure"

## Updating hard-coded URLs

Update hard-coded URLs from decommissined ARCS/APAC servers to NZ/nesi:

- Make the following changes in `/home/vme28/portlets/interpreter`

``` 

Index: src/au/edu/jcu/hpc/portlet/interpreter/discovery/DiscoveryService.java
===================================================================
--- src/au/edu/jcu/hpc/portlet/interpreter/discovery/DiscoveryService.java	(revision 730)
+++ src/au/edu/jcu/hpc/portlet/interpreter/discovery/DiscoveryService.java	(working copy)
@@ -14,7 +14,8 @@
 public abstract class DiscoveryService {
     public static final Set<String> DEFAULT_VOS = Collections.unmodifiableSet(
             new HashSet<String>(Arrays.asList(
-                    "/APACGrid/BeSTGRID"
+                    "/nz/bestgrid"
+                    // "/ARCS/BeSTGRID"
                     // , "/VO1"
             )));
 
Index: src/au/edu/jcu/hpc/portlet/interpreter/discovery/MdsDiscoveryService.java
===================================================================
--- src/au/edu/jcu/hpc/portlet/interpreter/discovery/MdsDiscoveryService.java	(revision 730)
+++ src/au/edu/jcu/hpc/portlet/interpreter/discovery/MdsDiscoveryService.java	(working copy)
@@ -46,7 +46,8 @@
  */
 class MdsDiscoveryService extends DiscoveryService {
     EngineConfigurationFactoryDefault r;
-    public static final String DEFAULT_URL = "https://mds.sapac.edu.au:8443/wsrf/services/DefaultIndexService";
+    public static final String DEFAULT_URL = "https://grid.canterbury.ac.nz:8443/wsrf/services/DefaultIndexService";
+    //public static final String DEFAULT_URL = "https://mds.sapac.edu.au:8443/wsrf/services/DefaultIndexService";
     //public static final String DEFAULT_QUERY = "//*[local-name()='Site' and @UniqueID='CANTERBURY']";
     public static final String DEFAULT_QUERY = "//*[local-name()='Site']";
 

```

Update MrBayes job definition:

- stop trying to set Mcmcdiagn=no (does not work before loading data in 3.2.x)
- remove the extra quit command from the generated stdin (causing jobs to segfault)

``` 

Index: src/MrBayesPreparation.java
===================================================================
--- src/MrBayesPreparation.java	(revision 729)
+++ src/MrBayesPreparation.java	(working copy)
@@ -55,7 +55,8 @@
         final String stdinFileName = "stdin";
         final String uploadedFilename = operations.getRemoteFileName(operations.getInputFileName("input.nex"));
         PrintWriter out = new PrintWriter(new FileOutputStream(baseDirectory + stdinFileName));
-        out.println("set autoclose=yes\nset nowarn=yes\nmcmcp mcmcdiagn=no\nexecute " + uploadedFilename + "\nquit\n");
+        // out.println("set autoclose=yes\nset nowarn=yes\nmcmcp mcmcdiagn=no\nexecute " + uploadedFilename + "\nquit\n");
+        out.println("set autoclose=yes\nset nowarn=yes\nexecute " + uploadedFilename + "\n");
         out.close();
         operations.setStdinFileName(stdinFileName);
         operations.addStageIn(stdinFileName);

```

(changes not committed to SVN - repository had been decommissioned)

- Recompile with: 

``` 
GRIDSPHERE_HOME=/usr/local/gridsphere JAVA_HOME=/usr/lib/jvm/java CATALINA_HOME=/var/lib/tomcat5 ant deploy
```
- Warning, this zaps any changes to `/var/lib/tomcat5/webapps/interpreter_client/config/configuration.xml`, make sure you first have the changes imported back into /home/vme28/portlets/interpreter_client/webapp/config/configuration.xml
- Restart tomcat: 

``` 
service tomcat5 restart
```
