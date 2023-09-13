# Setup Globus 4.2 on CentOS 5

This page documents an experimental setup of Globus 4.2.1 on CentOS x86_64.

The setup was done from precompiled Globus binaries (for RHAS 4 x86_64), the OS version difference was not an issue (after installing compatibility libraries for openssl and readline), but an install from source is also possible (documented further below).

Note: Globus 4.2 comes with a built in Derby file-based database - so it's fully self-contained and does not need MySQL.

# OS install

- CentOS 5 x86_64

- Add EPEL


>  rpm -Uvh [http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm](http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm)
>  rpm -Uvh [http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm](http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm)

- install grid-pulse


>  yum install APAC-gateway-gridpulse
>  yum install APAC-gateway-gridpulse

# NFS + PBS Setup

- Mount shared home directories (site specific)

- Create local accounts (site specific)

- install PBS client


>  yum install --enablerepo=arcs-i386 Gtorque-client
>  yum install --enablerepo=arcs-i386 Gtorque-client

- Configure PBS job submission to PBS server (ngcompute.canterbury.ac.nz in this case)

- 
- Edit `/usr/spool/pbs/server_name` and set it to PBS server name: `ngcompute.canterbury.ac.nz`

- Add PBS port numbers into /etc/services (if needed)

- Add this host (ng2dev.canterbury.ac.nz) into /etc/hosts.equiv on the PBS server
	
- add ng2dev's /etc/ssh/ssh_host_rsa_key.pub into ssh_known_hosts on the PBS server
- ng2dev: /etc/ssh/sshd_config:

``` 
HostbasedAuthentication yes
```
- ng2dev: /etc/ssh/shosts.equiv

``` 
+ngcompute.canterbury.ac.nz
```

- Configure PBS log replication from PBS server to this host:

``` 
yum --enablerepo=arcs-i386 install pbs-telltail
```
- (starts and enables the service)

- Edit `/etc/rc.d/init.d/pbs-telltail` on the PBS server and send logs to both ng2 and ng2dev

# Globus Setup

## Prerequisites

- According to Globus documentation, the prerequisites are: JDK, Ant, zlib, openssl


>  yum install zlib-devel openssl-devel java-1.6.0-openjdk java-1.6.0-openjdk-devel ant 
>  yum install zlib-devel openssl-devel java-1.6.0-openjdk java-1.6.0-openjdk-devel ant 


## Download

- Download 4.2.1 x86_64 RHAS 4 - and also source from globus.org

## Installing binary x86_64 RHAS 4 on CentOS 5

Globus hints from the `INSTALL` documentation file

1. Enable schedulers needed - like "`--enable-wsgram-pbs`"
2. set JAVA_HOME to actual java
	
- solved by creating `/etc/profile.d/java.sh` with

``` 
JAVA_HOME=/usr/lib/jvm/java ; export JAVA_HOME
```
3. run installation as new user "globus"
	
- created with -r as a system account): 

``` 
adduser globus -r --create-home
```
4. (not really documented) - setup PBS_HOME first
	
- Create /etc/profile.d/pbs.sh:

``` 
PBS_HOME=/usr/spool/PBS ; export PBS_HOME
```

Run:

./configure --prefix=/opt/globus --enable-wsgram-pbs

make

make install

## Host certificates

- Put certificates into /etc/grid-security/hostcert/key and container cert/key (owned by root and globus resp.)

- Install IGTF CA certificates from VDT-RPM


>  wget -P /etc/yum.repos.d/ [http://vdt.cs.wisc.edu/vdt_rpms/vdt-ca-certs/vdt-ca-certs.repo](http://vdt.cs.wisc.edu/vdt_rpms/vdt-ca-certs/vdt-ca-certs.repo)
>  yum install vdt-ca-certs
>  wget -P /etc/yum.repos.d/ [http://vdt.cs.wisc.edu/vdt_rpms/vdt-ca-certs/vdt-ca-certs.repo](http://vdt.cs.wisc.edu/vdt_rpms/vdt-ca-certs/vdt-ca-certs.repo)
>  yum install vdt-ca-certs

- Install Fetch-CRL (2.8.2) from RPM
	
- Download RPM from [http://dist.eugridpma.info/distribution/util/fetch-crl/](http://dist.eugridpma.info/distribution/util/fetch-crl/)

- Run the following command regularly from a cron job:

``` 
/usr/sbin/fetch-crl --loc /etc/grid-security/certificates --out /etc/grid-security/certificates --quiet
```
- Put the following line into root's crontab (run `crontab -e`):

``` 
3 1,7,13,19 * * * /usr/sbin/fetch-crl --loc /etc/grid-security/certificates --out /etc/grid-security/certificates --quiet >/dev/null 2>&1
```

# Authorization

- PRIMA for later.

- Create `/etc/grid-security/grid-mapfile` (manually created from GUMS) for now

# Sudo

- remove

``` 
Defaults    requiretty
```

- Allow usual stuff (both gridmap and PRIMA), but:
	
- the user is "globus"
- path to Globus is /opt/globus
- Keeping these two in mind, take the sudo lines from an existing VDT setup:

``` 

Runas_Alias GLOBUSUSERS = ALL, !root
globus ALL=(GLOBUSUSERS) \
       NOPASSWD: /opt/globus/libexec/globus-job-manager-script.pl *
globus ALL=(GLOBUSUSERS) \
       NOPASSWD: /opt/globus/libexec/globus-gram-local-proxy-tool *

# Globus mappings with grid-mapfile
globus ALL=(GLOBUSUSERS) \
       NOPASSWD: /opt/globus/libexec/globus-gridmap-and-execute \
       -g /etc/grid-security/grid-mapfile \
       /opt/globus/libexec/globus-job-manager-script.pl *
globus ALL=(GLOBUSUSERS) \
       NOPASSWD: /opt/globus/libexec/globus-gridmap-and-execute \
       -g /etc/grid-security/grid-mapfile \
       /opt/globus/libexec/globus-gram-local-proxy-tool *

```

# GridFTP

- Copy /opt/globus/etc/gridftp.gfork into /etc/xinetd.d and change base path


>  sed 's,/home/condor/execute/dir_13214/userdir/install,/opt/globus,g' /opt/globus/etc/gridftp.gfork > /etc/xinetd.d/gsiftp
>  sed 's,/home/condor/execute/dir_13214/userdir/install,/opt/globus,g' /opt/globus/etc/gridftp.gfork > /etc/xinetd.d/gsiftp

- xinetd name should not contain a "." and should be found in /etc/services, hence "gsiftp"
- rename service to gsiftp


>  **comment out attributes log_level and master** (not understood by xinetd)
>  **comment out attributes log_level and master** (not understood by xinetd)

- merge server_args into one definition
- add


>     protocol = tcp
>     wait = no
>     user = root
>     protocol = tcp
>     wait = no
>     user = root

- That's quite a bit of changes ... so the final xinetd entry in /etc/xinetd.d/gsiftp is:

``` 

service gsiftp
{
    disable = no
    port = 2811

    protocol = tcp
    wait = no
    user = root

    instances = 100
    #log_level = 0
    env = GLOBUS_LOCATION=/opt/globus
    env += LD_LIBRARY_PATH=/opt/globus/lib:/opt/globus/prima/lib
    env += PATH=/opt/globus/sbin:/opt/globus/bin
#   might need additional envs for security
    server = /opt/globus/sbin/globus-gridftp-server
    server_args = -i -aa -l /opt/globus/gridftp.log -d WARN
    nice = -20
    #master = /opt/globus/libexec/gfs-gfork-master
    #master_args = -G y
    #master_args += -l /opt/globus/gridftp-master.log
#   undoc the following for memory limiting
#   master_args += -m
}

```

# Running Globus 4.2

- To start the container, as `globus`, run:


>  /opt/globus/etc/init.d/globus-ws-java-container start
>  /opt/globus/etc/init.d/globus-ws-java-container start

- As a user, run:


>  export GLOBUS_LOCATION=/opt/globus/
>  . /opt/globus/etc/globus-user-env.sh
>  export GLOBUS_LOCATION=/opt/globus/
>  . /opt/globus/etc/globus-user-env.sh

# PRIMA

## Rationale

To configure (and first compile) PRIMA for Globus, it's better to first know what won't work:

- It won't work to pull "opensaml-devel" from the Shibboleth repository - because PRIMA needs SAML1 and not SAML2
- It won't work to pull xerces-c-devel and xmlsecurity-c-devel from EPEL - because PRIMA needs older versions of these packages.
- It won't work to pull log4cpp-devel from CentOS 5 base - because PRIMA needs older version of this packag.

## Globus configuration

- Force a GPT rebuild on the Globus installation.  Somehow, the Globus comes with no globus_config.h and the PRIMA build would fail with: 

``` 
/opt/globus/include/gcc64dbg/globus_common_include.h:24:27: error: globus_config.h: No such file or directory
```
- This can be fixed by rebuilding GPT - many thanks to [https://savannah.cern.ch/bugs/?8860](https://savannah.cern.ch/bugs/?8860).  Run the following as the `globus` user: 

``` 
gpt-build -force -nosrc -builddir=/tmp/globus_core.$$ gcc64 gcc64dbg gcc64dbgpthr gcc64pthr
```

## Dependencies

What in the end works is to get exactly the right versions of all dependencies and then PRIMA install fine.

The exact dependencies are:

>  curl=curl-7.11.1
>  log4cpp=log4cpp-0.3.4b
>  xerces=xerces-c-src_2_6_0
>  xmlsecurity=xml-security-c-1.1.0.1

- Get the dependencies (as tarballs) from [http://computing.fnal.gov/docs/products/voprivilege/prima/prima_build/](http://computing.fnal.gov/docs/products/voprivilege/prima/prima_build/)

- PRIMA also depeends on a number of packages from the GLITE project - namely lcmaps and xacml libraries.
	
- The CVS root location, project names and sticky tags are given in externalcvs.cmd
- The CVS web interface is at [http://glite.cvs.cern.ch/cgi-bin/glite.cgi/](http://glite.cvs.cern.ch/cgi-bin/glite.cgi/)
- I could not access the CVS pserver locations listed in PRIMA - so instead download the dependencies as tarballs via CVSweb:

``` 

wget 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.saml2-xacml2-c-lib.tar.gz?view=tar&pathrev=glite-security-saml2-xacml2-c-lib_R_0_0_13_2'
wget 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.lcmaps.tar.gz?view=tar&pathrev=glite-security-lcmaps_R_1_4_5_1'
wget 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.lcmaps-plugins-s~client.tar.gz?view=tar&pathrev=glite-security-lcmaps-plugins-scas-client_R_0_2_2_3'
wget 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.scas.tar.gz?view=tar&pathrev=glite-security-scas_R_0_2_2_3'

```

## PRIMA


- Modify the build script `fnal-build.sh`


>  export PRIMA_BASE_DIR=/opt/globus/prima
>  export VDT_LOCATION=/opt/globus
>  export GLOBUS_LOCATION=/opt/globus
>  export OPENSSL_DIR=/usr
>  export INSTALLDIR="${PRIMA_BASE_DIR}"
>  export PRIMA_BASE_DIR=/opt/globus/prima
>  export VDT_LOCATION=/opt/globus
>  export GLOBUS_LOCATION=/opt/globus
>  export OPENSSL_DIR=/usr
>  export INSTALLDIR="${PRIMA_BASE_DIR}"

NOTE:

- This configures PRIMA to build against Globus in `/opt/globus` and put PRIMA into /opt/globus/prima
- VDT_LOCATION is not really true
- We'll be linking against default OpenSSL.  Globus is linked against compat openssl097a - for which we have no devel packages.  Fingers crossed no clash.

- Copy all the downloaded dependencies (curl, log4cpp, xerces-c, xmlsecurity-c) into the current directory (nmi-prima)

- Extract the downloaded gLite dependencies into the current directory (tar xzf...)

- Create destination directory, make writeable to the user running the compilation.


>  mkdir /opt/globus/prima
>  chown vme28.vme28 /opt/globus/prima
>  mkdir /opt/globus/prima
>  chown vme28.vme28 /opt/globus/prima

- Run the build script


>  ./fnal-build.sh
>  ./fnal-build.sh

- Go get a cup of coffee (10-15 minutes to compile)

- PRIMA libraries should now be installed in `/opt/globus/prima/lib`

## Deploying PRIMA for GridFTP

- Grab a prima-authz.conf from somewhere else and put int into /etc/grid-security
	
- Modify samlSchemaDir to point to /opt/globus/prima/etc/opensaml

- Create /etc/grid-security/gsi-authz.conf with


>  globus_mapping /opt/globus/prima/lib/libprima_authz_module_gcc64dbg globus_gridmap_callout
>  globus_mapping /opt/globus/prima/lib/libprima_authz_module_gcc64dbg globus_gridmap_callout

- Modify /etc/xinet.d/gsiftp to include PRIMA in LD_LIBRARY_PATH:


>   env += LD_LIBRARY_PATH=/opt/globus/lib:**/opt/globus/prima/lib**
>   env += LD_LIBRARY_PATH=/opt/globus/lib:**/opt/globus/prima/lib**

## Deploy PRIMA in Globus-WS container

This is a setup which does not fully work and breaks the Globus 4.2 setup.  The Globus 4.2 security interface has changed substantially, and it's not possible to use the GT4 PRIMA implementation.  Instead, it's necessary to use the VOMS PIP interceptor (a Globus incubator project).  This code base is however not mature enough and can't properly handle proxy certificates with VOMS attributes - it successfully extracts the VO information **only** if it's embedded **in the first proxy certificate** in the chain.  The VOMS PIP code ignores the VO attributes further down the proxy chain - and this would break many of the intended workflows.

To deploy the VOMS PIP code, follow the below steps: based on the [Globus WSAA documentation](http://www.globus.org/toolkit/docs/4.2/4.2.1/security/wsaajava/developer/#wsaajava-developer-scenarios-authz-gums-voms) and the [VOMS PIP deployment guide](http://docs.google.com/Doc?id=dfkt44p2_2frf7n3cq)

### Recompile Globus from source

In order for this project to work, Globus must be recompiled with "GRAM XACML" support (not enabled in the default binaries.

The command-line to compile Globus is:

>  ./configure --prefix=/opt/globus --enable-wsgram-pbs --enable-gramxacml
>  make
>  make install

- note: there is an additional feature `--enable-xacml` - it doesn't appear to be related to this feature set.

### Get and deploy VOMS PIP source code

- Get VOMS PIP source code


>  mkdir voms-pip
>  cd voms-pip/
>  export CVSROOT=:pserver:anonymous@cvs.globus.org:/home/globdev/CVS/globus-packages
>  cvs co authz-interceptors/voms
>  mkdir voms-pip
>  cd voms-pip/
>  export CVSROOT=:pserver:anonymous@cvs.globus.org:/home/globdev/CVS/globus-packages
>  cvs co authz-interceptors/voms

- Compile VOMS PIP and deploy it into Globus


>  cd authz-interceptors/voms/
>  export GLOBUS_LOCATION=/opt/globus
>  PATH=/opt/ant/bin:$PATH ; ANT_HOME=/opt/ant ; export ANT_HOME
>  ant deploy
>  cd authz-interceptors/voms/
>  export GLOBUS_LOCATION=/opt/globus
>  PATH=/opt/ant/bin:$PATH ; ANT_HOME=/opt/ant ; export ANT_HOME
>  ant deploy

### Configure Globus: enable publishHostname

- Enable "publishHostname": in `$GLOBUS_LOCATION/etc/globus_wsrf_core/server-config.wsdd`, under `globalConfiguration` add:


### Configure Globus security descriptors

- WS GRAM Factory configuration
	
- Copy example file into WS-GRAM configuration:

``` 
cp  $GLOBUS_LOCATION/etc/globus_exec_authz_xacml/factory-xacml-voms.xml $GLOBUS_LOCATION/etc/globus_wsrf_gram/factory-xacml-voms-security-config.xml
```
- and configure this descriptor

``` 

                     <nvparam:nameValueParam>
                               <nvparam:parameter name="vomsTrustStore"
                 value="/etc/grid-security/certificates"/>
 
                               <nvparam:parameter name="caTrustStore"
                 value="/etc/grid-security/certificates"/>
                     </nvparam:nameValueParam>

```

... and

``` 

                            <param:authzService url="https://nggums.canterbury.ac.nz:8443/gums/services/GUMSXACMLAuthorizationServicePort"/>
                            <param:authzServiceIdentity value="/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=nggums.canterbury.ac.nz"/>

```

- Activate the descriptor: edit `globus_wsrf_gram/server-config.wsdd` and set `securityDescriptor` to 

``` 
"etc/globus_wsrf_gram/factory-xacml-voms-security-config.xml"
```

- WS GRAM Job Resource configuration:
	
- Copy example file into WS-GRAM configuration:

``` 
cp $GLOBUS_LOCATION/etc/globus_exec_authz_xacml/job-xacml-voms.xml $GLOBUS_LOCATION/etc/globus_wsrf_gram/job-xacml-voms-security-config.xml<pre>
** Modify this descriptor
<pre>
                     <nvparam:nameValueParam>
                               <nvparam:parameter name="vomsTrustStore"
                 value="/etc/grid-security/certificates"/>
 
                               <nvparam:parameter name="caTrustStore"
                 value="/etc/grid-security/certificates"/>
                     </nvparam:nameValueParam>

```

... and

``` 

                            <param:authzService url="https://nggums.canterbury.ac.nz:8443/gums/services/GUMSXACMLAuthorizationServicePort"/>
                            <param:authzServiceIdentity value="/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=nggums.canterbury.ac.nz"/>

```

- Activate the descriptor: edit `globus_wsrf_gram/jndi-config.xml` and set `resourceSecurityDescriptorFile` to:

``` 
"etc/globus_wsrf_gram/job-xacml-voms-security-config.xml"
```

### Limitations

- The main limitation is a likely bug in the VOMS PIP Globus incubator project.  The code fails to extract VO attributes in our most common scenario.  It only works when the VO attributes are in a proxy directly signed by the end-entity certificate.  When the VO attributes are included in a proxy further down the chain, they are "discovered" by the code, but are rejected with the error message "VOMS attribute cert found, but holder checking failed".  This message comes from the VOMSValidator class - which is a dependency of the authz VOMS interceptor and comes only in binary form.
- I've been also getting a number of failures in the XACML calls - where the XACML call was likely issued on an existing HTTPS connection at the time it was shut down.  Globus throws a lengthy

``` 
NoHttpResponseException: "The server nggums.canterbury.ac.nz failed to respond"
```
- I've also seen the server run out of memory on a 1GB VM, when only testing it with a very light load.

>  ***Note**:  RFT and Delegation Service have not been modified to use GUMS/VOMS as yet. So WS GRAM cannot be used with file transfer. Refer to Enabling WS GRAM for OSG/EGEE for details.

- 
- Does that mean Delegating a credential won't work, unless we also setup a gridmapfile?  And then, the credential may end up in the work directory?

# Building Globus from Source

>  **Note: openjdk & default ant don't support the*xmlvalidate** task - (either run Sun Java ???) or install a newer release of Ant

- 
- "ant -diagnostics" reports task xmlvalidate as not available (... and complains about java version.  Not happy with openjdk)

- Downloading Ant 1.7.1 from ant.apache.org


>  cd /opt
>  tar xzf /root/inst/apache-ant-1.7.1-bin.tar.bz2
>  ln -s apache-ant-1.7.1 ant
>  cd /opt
>  tar xzf /root/inst/apache-ant-1.7.1-bin.tar.bz2
>  ln -s apache-ant-1.7.1 ant

- As the `globus` user:


>  PATH=/opt/ant/bin:$PATH ; ANT_HOME=/opt/ant ; export ANT_HOME
>  PATH=/opt/ant/bin:$PATH ; ANT_HOME=/opt/ant ; export ANT_HOME

- Download Globus source distribution from globus.org
	
- untar the distribution

- Configure, compile & install Globus


>  ./configure --prefix=/opt/globus --enable-wsgram-pbs
>  make
>  make install
>  ./configure --prefix=/opt/globus --enable-wsgram-pbs
>  make
>  make install

- Configure the rest of services as if installing from binaries

# Pending issues

- PRIMA - WS container
