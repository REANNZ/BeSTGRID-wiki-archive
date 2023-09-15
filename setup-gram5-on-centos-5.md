# Setup GRAM5 on CentOS 5

The Globus project has recently released Globus Toolkit 5.0.0, introducing GRAM 5 (based on GT2's gatekeeper) as the submission tool of choice.

This page documents a test setup of a GT5 grid gateway.  While the other documentation for ARCS Grid / BeSTGRID assumes an install based on VDT, this page bypasses VDT (not supporting GT5 yet) and installs all packages directly from their source.

This page is targeted at PBS/Torque clusters - as a proof of concept.  For other Local Resource Managers (LRMs) like SGE or LoadLeveler, please refer to the LRM-specific supplementary documentation, to be linked from the [Setting up a grid gateway](/wiki/spaces/BeSTGRID/pages/3818228546) page.  If not available there, you may also find useful LRM-specific pages written for GT4, linked from the [NG2 setup page](setting-up-an-ng2.md).

The LRM-specific pages available for GRAM5 so far are:

- [Setup GRAM5 with LoadLeveler](/wiki/spaces/BeSTGRID/pages/3818228499) (LoadLeveler specific details)
- [Setup GRAM5.2 with LoadLeveler](/wiki/spaces/BeSTGRID/pages/3818228694) (LoadLeveler specific details)

# Preliminaries

The *OS requirements*, *Network requirements* and requirements for *Cluster integration* host *Certificate* are the same as when [installing an NG2](setting-up-an-ng2.md#SettingupanNG2-preliminaries).

- The conventional name for a GT5 based gateway is NG1 (as it replaces a GT2 based gateway).

- All the required network ports hould be open
- Host should be setup as a submit-only node in the cluster
	
- PBS logs must be replicated to this host.

The only notable differences are:

- GT5 will be installed under the `globus` account - and so:
	
- This account must be created beforehand (as a system account with a home directory created): 

``` 
adduser globus -r --create-home
```
- There is no need to copy the host certificate into containercert.pem/containerkey.pem
- Because GT5 uses file locking, the service `nfslock` must be running (if home directories are mounted over NFS):


>  service nfslock start
>  chkconfig nfslock on
>  service nfslock start
>  chkconfig nfslock on

# Pre-install

## Prerequisites

First, we setup the ARCS repository and install GridPulse (the ARCS system monitoring tool) from the ARCS repository:

- Configure ARCS RPM repository

``` 
cd /etc/yum.repos.d && wget http://projects.arcs.org.au/dist/arcs.repo
```
- Note: on a 64-bit system, change the repository file to use ARCS i386 repository itself (the ARCS 64-bit repository is not populated).  I.e., change the `baseurl` for the [arcs] repository in `/etc/yum.repos.d/arcs.repo` to: 

``` 
baseurl=http://projects.arcs.org.au/dist/production/$releasever/i386
```

- Install the system monitoring tool GridPulse, ARCS Gateway addons, and network services launcher xinetd (if not yet installed)


>  yum install APAC-gateway-gridpulse Ggateway xinetd
>  yum install APAC-gateway-gridpulse Ggateway xinetd

- globus prerequisites


>  yum install openssl-devel gcc-c++
>  yum install openssl-devel gcc-c++

## Configure log replication to this system

Globus will assume it's running on the headnode of the cluster and has access to all logs.  If this is not the case, we need to configure the replication.  For PBS, we recommend to use the pbs-logmaker/pbs-telltail packages.

- Install the `pbs-logmaker` package: 

``` 
yum install pbs-logmaker
```
- Edit `/etc/sysconfig/pbs-logmaker` and set 

``` 
PBS_HOME="/usr/spool/PBS/server_logs"
```
- Start the service:


>  service pbs-logmaker start
>  chkconfig pbs-logmaker on
>  service pbs-logmaker start
>  chkconfig pbs-logmaker on

For further instructions, see the [LRM access](setting-up-an-ng2-pbs-specific-parts.md) and [Log replication](setting-up-an-ng2-pbs-specific-parts.md) sections in [Setting up an NG2/PBS specific parts](setting-up-an-ng2-pbs-specific-parts.md)

# Installing Globus

GT5 so far provides no pre-built binaries - hence, we'll be installing from source.  The following notes assume installing GT5 into `/opt/globus`

- Create /opt/globus owned by globus


>  mkdir /opt/globus
>  chown globus.globus /opt/globus
>  mkdir /opt/globus
>  chown globus.globus /opt/globus

## Getting Globus and building from source

- Download the source installer for the most recent 5.x release (e.g., `gt5.0.2-all-source-installer.tar.bz2`) from [http://www.globus.org/toolkit/downloads/](http://www.globus.org/toolkit/downloads/)

- If building the PBS modules now (`make gram5-pbs gram5-pbs-thr` in the snippet below), set the `PBS_HOME` environment variable to point to the PBS log files:

``` 
export PBS_HOME=/usr/spool/PBS
```

- As `globus` user, run:


>  ./configure --prefix=/opt/globus
>  make
> 1. Note: it is important to have C++ compiler before starting the build process otherwise the second make command
> 2. results in very strange errors such as
> 3. configure: error: C++ preprocessor " -E" fails sanity check
>  #
> 4. Note: compiling Globus may take several hours
>  #
> 5. At this point, it's also recommended to make any extra packages installed further down the track - hence:
>  make udt gram5-pbs gram5-pbs-thr
>  make install
>  ./configure --prefix=/opt/globus
>  make
> 1. Note: it is important to have C++ compiler before starting the build process otherwise the second make command
> 2. results in very strange errors such as
> 3. configure: error: C++ preprocessor " -E" fails sanity check
>  #
> 4. Note: compiling Globus may take several hours
>  #
> 5. At this point, it's also recommended to make any extra packages installed further down the track - hence:
>  make udt gram5-pbs gram5-pbs-thr
>  make install

# Install PRIMA

- We will need to use the PRIMA libraries to make callouts to a GUMS server - and we will need to build PRIMA from source.

- Note: the PRIMA build process installs binaries into /opt/globus/prima throughout the build.  The easiest way to make sure permissions don't break is to run the whole process as the `globus` user - including all the steps in downloading and extracting PRIMA source code and dependencies.

## Get PRIMA source code and dependencies

Get PRIMA source code (as also documented at [Setup PRIMA on IBM p520#Getting PRIMA](/wiki/spaces/BeSTGRID/pages/3818228592#SetupPRIMAonIBMp520-GettingPRIMA))

- Download `prepare_nmi.sh` from [http://computing.fnal.gov/docs/products/voprivilege/prima/nmi_build.html](http://computing.fnal.gov/docs/products/voprivilege/prima/nmi_build.html)
- Edit the script and comment out the line `rm -fr "$outdir/cvs_nmi` (cleanup at the end of the file)
- Make sure your machine is allowed to open outgoing connections to an CVS server
- Run `prepare_nmi.sh`: 

``` 
sh prepare_nmi.sh -e vladimir.mencl@canterbury.ac.nz
```
- This creates prima_nmi.tar.
- Untar the file and move into the directory:


>  tar xzf nmi-prima.tgz
>  cd nmi-prima
>  tar xzf nmi-prima.tgz
>  cd nmi-prima

- Get required dependencies: download the following tarballs (exact versions) from [http://computing.fnal.gov/docs/products/voprivilege/prima/prima_build/](http://computing.fnal.gov/docs/products/voprivilege/prima/prima_build/)
	
- [curl-7.11.1.tar.gz](http://computing.fnal.gov/docs/products/voprivilege/prima/prima_build/curl-7.11.1.tar.gz)
- [log4cpp-0.3.4b.tar.gz](http://computing.fnal.gov/docs/products/voprivilege/prima/prima_build/log4cpp-0.3.4b.tar.gz)
- [xerces-c-src_2_6_0.tar.gz](http://computing.fnal.gov/docs/products/voprivilege/prima/prima_build/xerces-c-src_2_6_0.tar.gz)
- [xml-security-c-1.1.0.1.tar.gz](http://computing.fnal.gov/docs/products/voprivilege/prima/prima_build/xml-security-c-1.1.0.1.tar.gz)

- Get and extract glite dependencies


>  wget -O org.glite.security.saml2-xacml2-c-lib.tar.gz 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.saml2-xacml2-c-lib.tar.gz?view=tar&pathrev=glite-security-saml2-xacml2-c-lib_R_0_0_13_2'
>  wget -O org.glite.security.lcmaps.tar.gz 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.lcmaps.tar.gz?view=tar&pathrev=glite-security-lcmaps_R_1_4_5_1'
>  wget -O org.glite.security.lcmaps-plugins-scas-client.tar.gz 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.lcmaps-plugins-scas-client.tar.gz?view=tar&pathrev=glite-security-lcmaps-plugins-scas-client_R_0_2_2_3'
>  wget -O org.glite.security.scas.tar.gz 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.scas.tar.gz?view=tar&pathrev=glite-security-scas_R_0_2_2_3'
>  for I in org.glite.*.tar.gz ; do tar xzf $I ; done
>  wget -O org.glite.security.saml2-xacml2-c-lib.tar.gz 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.saml2-xacml2-c-lib.tar.gz?view=tar&pathrev=glite-security-saml2-xacml2-c-lib_R_0_0_13_2'
>  wget -O org.glite.security.lcmaps.tar.gz 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.lcmaps.tar.gz?view=tar&pathrev=glite-security-lcmaps_R_1_4_5_1'
>  wget -O org.glite.security.lcmaps-plugins-scas-client.tar.gz 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.lcmaps-plugins-scas-client.tar.gz?view=tar&pathrev=glite-security-lcmaps-plugins-scas-client_R_0_2_2_3'
>  wget -O org.glite.security.scas.tar.gz 'http://glite.cvs.cern.ch/cgi-bin/glite.cgi/org.glite.security.scas.tar.gz?view=tar&pathrev=glite-security-scas_R_0_2_2_3'
>  for I in org.glite.*.tar.gz ; do tar xzf $I ; done

## Prepare the PRIMA build

- Modify fnal-build.sh with the following patch (assuming PRIMA is installed into /opt/globus/prima)

``` 

--- fnal-build.sh.orig  2009-12-15 16:52:19.000000000 +1300
+++ fnal-build.sh       2010-03-08 16:41:56.000000000 +1300
@@ -4,21 +4,22 @@
 #################################################################
 
 #---- Base dir ----------------
-export PRIMA_BASE_DIR=/home/sfiligoi/prima
-export VDT_LOCATION=${PRIMA_BASE_DIR}/vdt
+
+export PRIMA_BASE_DIR=/opt/globus/prima
+export VDT_LOCATION=/opt/globus
 
 #---- installation directory ---
 PRIMA_VERSION=prima-0.4
-export INSTALLDIR="${PRIMA_BASE_DIR}/${PRIMA_VERSION}"
+export INSTALLDIR="${PRIMA_BASE_DIR}"
 
 #----- globus location
-export GLOBUS_LOCATION=${VDT_LOCATION}/globus
+export GLOBUS_LOCATION=/opt/globus
 
 #----- gpt location
 export GPT_LOCATION=${VDT_LOCATION}/gpt
 
 #---- openssl directory ---------
-export OPENSSL_DIR=${PWD}/globus
+export OPENSSL_DIR=/usr
 
 #---- gcc version -------
 export PRIMA_GCC_VERSION=gcc64dbg

```

>  ***Note**:

- 
- This configures PRIMA to build against Globus in `/opt/globus` and put PRIMA into /opt/globus/prima
- VDT_LOCATION is not really true
- We'll be linking against default system OpenSSL.

>  ***IMPORTANT**: Modify `prima-autz-module/Makefile` in prima-autz-module.tar.gz and remove the `gssapi_error` library from `GLOBUS_LIBS`
>  tar xzf prima-autz-module.tar.gz
>  sed -i -e 's/-lgssapi_error_$(PRIMA_GCC_VERSION)//' prima-autz-module/Makefile
>  mv prima-autz-module.tar.gz prima-autz-module.tar.gz.orig
>  tar czf prima-autz-module.tar.gz prima-autz-module
>  rm -rf prima-autz-module

- Create destination directory


>  mkdir /opt/globus/prima
>  mkdir /opt/globus/prima

## Building PRIMA

- Run the build script


>  ./fnal-build.sh
>  ./fnal-build.sh

- Go get a cup of coffee (10-15 minutes to compile)

- PRIMA libraries should now be installed in `/opt/globus/prima/lib`

## Deploying PRIMA

- Create `/etc/grid-security/prima-authz.conf` based on the following sample and - change the GUMS URLs to point to your GUMS server:

``` 

imsContact https://nggums.canterbury.ac.nz:8443/gums/services/GUMSAuthorizationServicePort
xacmlContact https://nggums.canterbury.ac.nz:8443/gums/services/GUMSXACMLAuthorizationServicePort
issuerCertDir  /etc/grid-security/vomsdir
verifyAC false
serviceCert /etc/grid-security/hostcert.pem
serviceKey  /etc/grid-security/hostkey.pem
caCertDir   /etc/grid-security/certificates
logLevel    info
samlSchemaDir /opt/globus/prima/etc/opensaml

```

- Create `/etc/grid-security/gsi-authz.conf` with


>  globus_mapping /opt/globus/prima/lib/libprima_authz_module_gcc64dbg globus_gridmap_callout
>  globus_mapping /opt/globus/prima/lib/libprima_authz_module_gcc64dbg globus_gridmap_callout

- Make sure the environment gridftp-server and gatekeeper run it included the PRIMA library directory in LD_LIBRARY_PATH: this may include putting the following line into `gsiftp` and `gatekeeper` in `/etc/xinetd.d`


>   env += LD_LIBRARY_PATH=/opt/globus/lib:**/opt/globus/prima/lib**
>   env += LD_LIBRARY_PATH=/opt/globus/lib:**/opt/globus/prima/lib**

# Enable GridFTP

- Check /etc/services has:


>  gsiftp          2811/tcp                        # GSI FTP
>  gsiftp          2811/tcp                        # GSI FTP

- Create /etc/xinetd.d/gsiftp with

``` 

service gsiftp
              {
              instances               = 100
              per_source              = UNLIMITED
              socket_type             = stream
              wait                    = no
              user                    = root
              env                     += GLOBUS_LOCATION=/opt/globus
              env                     += LD_LIBRARY_PATH=/opt/globus/lib:/opt/globus/prima/lib
              env                     += GLOBUS_TCP_PORT_RANGE=40000,41000
              server                  = /opt/globus/sbin/globus-gridftp-server
              server_args             = -i
              log_on_success          += DURATION
              nice                    = 10
              disable                 = no
              }

```

grisu backend libraries create a lot of connections, that is why per_source is set to unlimited. 

**Note**:

- This is based on  xinetd snippet: from [http://www.globus.org/toolkit/docs/5.0/5.0.0/data/gridftp/admin/#gridftp-admin-inetd](http://www.globus.org/toolkit/docs/5.0/5.0.0/data/gridftp/admin/#gridftp-admin-inetd)
	
- Don't confuse with GFork snippets in /opt/globus/etc - GFork (an xinetd replacement) uses an extension of xinetd syntax

- Customizations:
	
- GLOBUS_LOCATION (/opt/globus + in other paths)
- PRIMA in LD_LIBRARY_PATH
- env GLOBUS_TCP_PORT_RANGE=40000,41000

>  ***Note**: VDT uses the following parameters - should we use them as well?

``` 

    instances   = UNLIMITED
    cps         = 400 10
    per_source  = 300

```

# Configure CA certificates

- Install IGTF CA certificates from VDT-RPM


>  wget -P /etc/yum.repos.d/ [http://vdt.cs.wisc.edu/vdt_rpms/vdt-ca-certs/vdt-ca-certs.repo](http://vdt.cs.wisc.edu/vdt_rpms/vdt-ca-certs/vdt-ca-certs.repo)
>  yum install vdt-ca-certs
>  wget -P /etc/yum.repos.d/ [http://vdt.cs.wisc.edu/vdt_rpms/vdt-ca-certs/vdt-ca-certs.repo](http://vdt.cs.wisc.edu/vdt_rpms/vdt-ca-certs/vdt-ca-certs.repo)
>  yum install vdt-ca-certs

- Install Fetch-CRL (2.8.2) from RPM
	
- Get the most recent RPM from [http://dist.eugridpma.info/distribution/util/fetch-crl/](http://dist.eugridpma.info/distribution/util/fetch-crl/)

- Run the following command regularly from a cron job:

``` 
/usr/sbin/fetch-crl --loc /etc/grid-security/certificates --out /etc/grid-security/certificates --quiet
```
- Put the following line into root's crontab (run `crontab -e`):

``` 
3 1,7,13,19 * * * /usr/sbin/fetch-crl --loc /etc/grid-security/certificates --out /etc/grid-security/certificates --quiet >/dev/null 2>&1
```


# Enable gatekeeper

- Check /etc/services has:


>  gsigatekeeper   2119/tcp                        # GSIGATEKEEPER
>  gsigatekeeper   2119/tcp                        # GSIGATEKEEPER

- Create /etc/xinetd.d/gsigatekeeper with

``` 

service gsigatekeeper
{
    socket_type = stream
    protocol = tcp
    wait = no
    user = root
    env += GLOBUS_LOCATION=/opt/globus
    env += LD_LIBRARY_PATH=/opt/globus/lib:/opt/globus/prima/lib
    env += GLOBUS_TCP_PORT_RANGE=40000,41000
    server = /opt/globus/sbin/globus-gatekeeper
    server_args = -conf /opt/globus/etc/globus-gatekeeper.conf
    disable = no
}

```

**Note**:

- This is based on  xinetd snippet: from [http://www.globus.org/toolkit/docs/5.0/5.0.0/execution/gram5/admin/#gram5-admin-deploying-servicesconf](http://www.globus.org/toolkit/docs/5.0/5.0.0/execution/gram5/admin/#gram5-admin-deploying-servicesconf)
	
- Don't confuse with GFork snippets in /opt/globus/etc - GFork (an xinetd replacement) uses an extension of xinetd syntax

- Customizations:
	
- GLOBUS_LOCATION (/opt/globus + in other paths)
- PRIMA in LD_LIBRARY_PATH
- env GLOBUS_TCP_PORT_RANGE=40000,41000

>  ***Note**: same as for gridFTP, should we use other parameters for tuning the number of server instances?

- When we are starting gatekeeper from xinetd, the gatekeeper configuration file should say so: check that `/opt/globus/etc/globus-gatekeeper.conf` includes 

``` 
  -inetd
```

- Restart xinetd to pick up the new services


>  service xinetd restart
>  service xinetd restart

# Setup environment variables

- Create /etc/profile.d/globus.sh with the following contents:

``` 

GLOBUS_LOCATION=/opt/globus
GLOBUS_TCP_PORT_RANGE=40000,41000
export GLOBUS_LOCATION
export GLOBUS_TCP_PORT_RANGE

. $GLOBUS_LOCATION/etc/globus-user-env.sh
PATH=$GLOBUS_LOCATION/prima/bin:$PATH
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GLOBUS_LOCATION/prima/lib

```

# Enable PBS in GRAM5

By default, GRAM 5 gets configured to use the local Fork scheduler only - and makes the Fork scheduler the default scheduler.

To install support for PBS, do the following steps (all of them as the `globus` user):

1. Set the `PBS_HOME` environment variable to point to the PBS log files:

``` 
export PBS_HOME=/usr/spool/PBS
```
2. Return back to the GT5 source code directory (`gt5.0.0-all-source-installer`) and compile (and install) PBS support with:

``` 
make gram5-pbs
```
3. Compile also the threaded version of the interface:

``` 
make gram5-pbs-thr
```
4. Load the globus environment with:

``` 
. /etc/profile.d/globus.sh
```
5. Run the configurator script:

``` 
/opt/globus/setup/globus/setup-globus-job-manager-pbs.pl
```
- This script creates: `/opt/globus/etc/grid-services/jobmanager-pbs` and `/opt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm`
- When creating pbs.pm, the script looks for the following executables in the current environment: `mpiexec mpirun qdel qstat qsub`
- You will want to replace your pbs.pm with the site-customized one used at your NG2 - but for testing, you may also pass additional parameters to the setup-globus-job-manager-pbs.pl script to customize how pbs.pm gets created: [--non-cluster]` `[--cpu-per-node=COUNT]
6. **Note that in pbs.pm,*all variables must be initialized before use** - see [#Notable Issues](#SetupGRAM5onCentOS5-NotableIssues) below
7. Now, the PBS job manager is available as "jobmanager-pbs"

- Make PBS job manager the default job manager

``` 
ln -sf jobmanager-pbs $GLOBUS_LOCATION/etc/grid-services/jobmanager
```

# Making sure queue names are valid

By default, the above `setup-globus-job-manager-pbs.pl` script sets up the LRM interface to validate queue names, and lists all the PBS queues that exist at the time the script is run as the only valid values for the `queue` RSL element.

- To add a newly created queue as a permissible value, either re-run the script, or edit the RSL validation file `$GLOBUS_LOCATION/share/globus_gram_job_manager/pbs.rvf` and add the queue to the space-separated list of values:

``` 

Attribute: queue
Values: small gt5test

```
- To switch this behavior off (and disable queue validation), pass the following argument to `setup-globus-job-manager-pbs.pl`:

``` 
--validate-queues=no
```

**Note**: re-running the script causes the following two files to get overwritten: be careful to back them up:

- `$GLOBUS_LOCATION/lib/perl/Globus/GRAM/JobManager/pbs.pm`
- `$GLOBUS_LOCATION/etc/grid-services/jobmanager-pbs`
- `$GLOBUS_LOCATION/share/globus_gram_job_manager/pbs.rvf`

References:

- gt-user explanation of this issue: [http://lists.globus.org/pipermail/gt-user/2010-March/008978.html](http://lists.globus.org/pipermail/gt-user/2010-March/008978.html)
- Validation file format: [http://www.globus.org/api/c-globus-5.0.0/globus_gram_job_manager/html/globus_gram_job_manager_rsl_validation_file.html](http://www.globus.org/api/c-globus-5.0.0/globus_gram_job_manager/html/globus_gram_job_manager_rsl_validation_file.html)

# Supporting RSL extensions

Globus job manager verifies all elements received in the job RSL against the specification in `$GLOBUS_LOCATION/share/globus_gram_job_manager/pbs.rvf`.

Add the following entries at the end of this file to enable the RSL extensions commonly used in ARCS grid / BeSTGRID:

- Note: in GRAM 5.2, the file to modify is /usr/share/globus/globus_gram_job_manager/globus-gram-job-manager.rvf

``` 

# NeSI extensions
Attribute: jobname
Description: "job name, up to 6 characters"
ValidWhen: GLOBUS_GRAM_JOB_SUBMIT

Attribute: module
Description: "module string"
ValidWhen: GLOBUS_GRAM_JOB_SUBMIT

Attribute: emaildebug
Description: "send script"
ValidWhen: GLOBUS_GRAM_JOB_SUBMIT

Attribute: vo
Description: "voname for accounting"
ValidWhen: GLOBUS_GRAM_JOB_SUBMIT

Attribute: email_address
Description: "Email address for notifications"
ValidWhen: GLOBUS_GRAM_JOB_SUBMIT

Attribute: email_on_abort
Description: "Send email notifications when job aborts"
ValidWhen: GLOBUS_GRAM_JOB_SUBMIT

Attribute: email_on_execution
Description: "Send email notifications when job starts"
ValidWhen: GLOBUS_GRAM_JOB_SUBMIT

Attribute: email_on_termination
Description: "Send email notifications when job terminates"
ValidWhen: GLOBUS_GRAM_JOB_SUBMIT

```

# Switch to using Scheduler Event Generator

- The PBS LRM interface by default uses polling to query job status.  We want to use SEG instead - it's more efficient.  This consists of three steps, documented at [http://www.globus.org/toolkit/docs/5.0/5.0.2/execution/gram5/admin/#id2545817](http://www.globus.org/toolkit/docs/5.0/5.0.2/execution/gram5/admin/#id2545817)
- **Important:*BE CAREFUL WHEN IMPLEMENTING THIS** - if you get it wrong, your jobs would appear to be hung (you would not see any progress on the job state).
	
1. Configure the SEG with the path to the PBS server logs: create `$GLOBUS_LOCATION/etc/globus-pbs.conf` by running

``` 
/opt/globus/setup/globus/setup-seg-pbs.pl --path /usr/spool/PBS/server_logs
```
2. Edit `$GLOBUS_LOCATION/etc/grid-services/jobmanager-pbs` and add the following to the list of arguments:

``` 
-seg-module pbs
```
3. Make sure we are using the non-thread version of the SEG (the threaded version tends to lock up):

``` 
cp $GLOBUS_LOCATION/libexec/gcc64dbg/shared/globus-scheduler-event-generator $GLOBUS_LOCATION/libexec
```
- See the [GRAM5 and PBS SEG](http://lists.globus.org/pipermail/gt-user/2010-March/thread.html#8903) thread on [gt-user](https://lists.globus.org/mailman/listinfo/gt-user) for more information.
4. Run the following command once to start the SEG:

``` 
$GLOBUS_LOCATION/sbin/globus-job-manager-event-generator -scheduler pbs -background -pidfile /opt/globus/var/job-manager-seg-pbs.pid
```
5. Make sure it runs automatically - configure as a service.  Create `/etc/rc.d/init.d/globusseg` with:

``` 

#!/bin/bash
# Startup script for globus scheduler event generator
#
# chkconfig: 345 99 06
#
# description: Start globus-job-manager-event-generator launching
#              globus-scheduler-event-generator

. /etc/profile.d/globus.sh
# or do 
# export GLOBUS_LOCATION=/opt/globus ; . $GLOBUS_LOCATION/etc/globus-user-env.sh

servicename=globusseg
pidfile=/opt/globus/var/job-manager-seg-pbs.pid
RETVAL=0

start () {
  $GLOBUS_LOCATION/sbin/globus-job-manager-event-generator -scheduler pbs -background -pidfile $pidfile
  RETVAL=$?
  [ $RETVAL -eq 0 ] && touch /var/lock/subsys/$servicename
}

stop () {
  RETVAL=1
  if [ -f $pidfile ] ; then
    PID=`cat $pidfile`
    if ps -p $PID > /dev/null ; then
      kill $PID
      RETVAL=$?
      rm /var/lock/subsys/$servicename
    fi
  fi
}

status () {
  if [ -f $pidfile ] ; then
    PID=`cat $pidfile`
    if ps -p $PID > /dev/null ; then
      echo "PID $PID running"
      RETVAL=0
    else
      echo "PID file exists but process not running"
      RETVAL=1
    fi
  else
    echo "Not running"
    RETVAL=1
  fi
}

case "$1" in
        start)
            start
            ;;
        stop)
            stop
            ;;
        status)
            status
            ;;
        restart)
            stop
            sleep 3
            start
            ;;
        *)
            echo $"Usage: $0 {start|stop|status|restart|condrestart}"
            ;;
esac
exit $RETVAL

```
- Enable the script with chkconfig: 

``` 
chkconfig --add globusseg
```

# Increase Open Files Limit

limit of 1024 is enough to run about 500 jobs - after that the job manager becomes unresponsive and user has to wait for proxy expiration or machine reboot. To increase this limit, 

edit `/etc/security/limits.conf`

> - -        nofile         32000

And replace job manager by wrapper script in `/opt/globus/etc/grid-services/jobmanager`

>  stderr_log,local_cred - **/opt/globus/libexec/globus-job-manager-script.sh** globus-job-manager -conf /opt/globus/etc/globus-job-manager.conf -type pbs

The wrapper script `/opt/globus/libexec/globus-job-manager-script.sh` should contain:

>  #!/bin/bash
>  ulimit -Sn 32000
>  /opt/globus/libexec/globus-job-manager "$@"

Also modify `/etc/sysconfig/xinetd`:

>  ulimit -n 32000

# Job Audit Logging

To make Globus record the association between a local job ID and the user DN, implement the auditing as described in this section.  It provides audit records compatible with records produced by GRAM4 Audit Logging

- Main doc: [http://www.globus.org/toolkit/docs/5.0/5.0.0/execution/gram5/admin/#gram5-audit-logging](http://www.globus.org/toolkit/docs/5.0/5.0.0/execution/gram5/admin/#gram5-audit-logging)
- Configuration file: $GLOBUS_LOCATION/etc/globus-job-manager-audit.conf
- By default, $GLOBUS_LOCATION/setup/globus/setup-globus-gram-auditing is run with default parameters when installing globus and configures audit logging into a SQLite3 database - /opt/globus/var/gram_audit_database/gram_audit.db (the database is NOT created by default)

- Programs: $GLOBUS_LOCATION/setup/globus/setup-globus-gram-auditing - setup script
- $GLOBUS_LOCATION/libexec/globus-gram-audit - push information from local directory into database
- -audit-directory option to job manager (in either LRM-only or global conf)

- Basic workflow is: job manager is storing records in an "audit directory", globus-gram-audit is then pushing the records into a database.  Note: job manager is running as a local user and the audit directory must be writable to the user.

- Database: let's use MySQL (MySQL, PostgreSQL, and SQLite3) to be compatible with auditquery (SQLite3 might not really like concurrent access)

Enable Audit:

- Create an audit directory and make it world-writable sticky:


>  mkdir /opt/globus/var/gram-audit
>  chmod 1777  /opt/globus/var/gram-audit
>  mkdir /opt/globus/var/gram-audit
>  chmod 1777  /opt/globus/var/gram-audit

- Turn on audit for all job managers: edit /opt/globus/etc/globus-job-manager.conf and add


>  -audit-directory /opt/globus/var/gram-audit
>  -audit-directory /opt/globus/var/gram-audit

- Get MySQL going:


>  yum install mysql-server
>  service mysqld start
>  yum install mysql-server
>  service mysqld start

- Create MySQL database and user: run `mysql` and run


>  create database auditDatabase;
>  create user 'audit'@'localhost' identified by 'Audi12345';
>  grant all privileges on auditDatabase.* to 'audit'@'localhost';
>  create database auditDatabase;
>  create user 'audit'@'localhost' identified by 'Audi12345';
>  grant all privileges on auditDatabase.* to 'audit'@'localhost';

- Create GRAM audit configuration file (`$GLOBUS_LOCATION/etc/globus-job-manager-audit.conf`) and create MySQL table (if using `--create`):


>  $GLOBUS_LOCATION/setup/globus/setup-globus-gram-auditing --driver mysql --database auditDatabase --username audit --password Audi12345 --create
>  $GLOBUS_LOCATION/setup/globus/setup-globus-gram-auditing --driver mysql --database auditDatabase --username audit --password Audi12345 --create

- Run


>  $GLOBUS_LOCATION/libexec/globus-gram-audit
>  $GLOBUS_LOCATION/libexec/globus-gram-audit

- Create /etc/cron.hourly/auditpush with

``` 

#!/bin/bash

. /etc/profile.d/globus.sh
$GLOBUS_LOCATION/libexec/globus-gram-audit

```
- Note: auditpush comes before auditquery!!!

- Install auditquery:


>  yum install Ggateway
>  yum install Ggateway

# Setup MIP - register in MDS

This section goes briefly through the MDS setup.  One major difference is that GT5.0.0 does not include MDS, so we would be piggy-backing on an NG2's MDS and pushing the registration there via MIP remote / MIP integrator.

- Enable EPEL


>  rpm -Uvh [http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm](http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm)
>  rpm -Uvh [http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm](http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm)

- Install MIP and it's python module


>  yum install APAC-mip APAC-mip-module-py
>  yum install APAC-mip APAC-mip-module-py

- Configuring MIP for use with MIP integrator with multiple packages.  Use:


>   package name: ng1.canterbury.ac.nz
>   package name: ng1.canterbury.ac.nz

- Element IDs:


>   Site: canterbury.ac.nz
>   Cluster: ng1.canterbury.ac.nz-cluster-GT5
>   SubCluster: ng1.canterbury.ac.nz-subcluster-GT5
>   ComputeElement: ng1.canterbury.ac.nz-ce-GT5
>   StorageElement: ng1.canterbury.ac.nz
>   Site: canterbury.ac.nz
>   Cluster: ng1.canterbury.ac.nz-cluster-GT5
>   SubCluster: ng1.canterbury.ac.nz-subcluster-GT5
>   ComputeElement: ng1.canterbury.ac.nz-ce-GT5
>   StorageElement: ng1.canterbury.ac.nz

- Advertising elements for NGAdmin only

- Define the ng1.canterbury.ac.nz package as a MIP module


>  ln -s apac_py /usr/local/mip/modules/ng1.canterbury.ac.nz
>  ln -s apac_py /usr/local/mip/modules/ng1.canterbury.ac.nz

- Edit source.pl:


>  pkgs       => ['ng1.canterbury.ac.nz',],
>  pkgs       => ['ng1.canterbury.ac.nz',],

- Create new package config file with element IDs: create /usr/local/mip/config/ng1.canterbury.ac.nz.pl with the following content (use default.pl as a template)


>   clusterlist => ['ng1.canterbury.ac.nz'],
>   uids =>  {
>     Site => ["canterbury.ac.nz",],
>     SubCluster => ["ng1.canterbury.ac.nz-subcluster-GT5",],
>     Cluster => ["ng1.canterbury.ac.nz-cluster-GT5",],
>     ComputingElement => ["ng1.canterbury.ac.nz-ce-GT5",],
>     StorageElement => ["ng1.canterbury.ac.nz",],
>   }
>   clusterlist => ['ng1.canterbury.ac.nz'],
>   uids =>  {
>     Site => ["canterbury.ac.nz",],
>     SubCluster => ["ng1.canterbury.ac.nz-subcluster-GT5",],
>     Cluster => ["ng1.canterbury.ac.nz-cluster-GT5",],
>     ComputingElement => ["ng1.canterbury.ac.nz-ce-GT5",],
>     StorageElement => ["ng1.canterbury.ac.nz",],
>   }


>  *nat
>  -I OUTPUT -p tcp --dst ng1.canterbury.ac.nz --dport 8443 -j REDIRECT --to-ports=2119
>  -I PREROUTING -p tcp --dst ng1.canterbury.ac.nz --dport 8443 -j REDIRECT --to-ports=2119
>  COMMIT
>  *nat
>  -I OUTPUT -p tcp --dst ng1.canterbury.ac.nz --dport 8443 -j REDIRECT --to-ports=2119
>  -I PREROUTING -p tcp --dst ng1.canterbury.ac.nz --dport 8443 -j REDIRECT --to-ports=2119
>  COMMIT

- Note: in order for the firewall rules to load at boot time, the hostname of this host must be resolvable via /etc/hosts (before network is up): add to `/etc/hosts`:

``` 
132.181.39.12   ng1.canterbury.ac.nz ng1
```

- Create `/usr/local/mip/config/ng1.canterbury.ac.nz_ng1.canterbury.ac.nz-subcluster-GT5_SIP.ini` (named *package*-*subcluster*_SIP.ini)

``` 

[source2]
uri: file:softwareInfoData/localSoftware.xml
format: APACGLUE1.2

[action]
type: log

[log]
location: /usr/local/mip/var/log/mip.log

[definitionMapulations]
APACSchemaDirectory: /usr/local/share/

```

- Create MIP log file and make it writable:


>  mkdir -p /usr/local/mip/var/log
>  touch /usr/local/mip/var/log/mip.log
>  chmod a+rw /usr/local/mip/var/log/mip.log
>  mkdir -p /usr/local/mip/var/log
>  touch /usr/local/mip/var/log/mip.log
>  chmod a+rw /usr/local/mip/var/log/mip.log

- Define software packages in /usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/localSoftware.xml
- **So far, define only package*UnixCommands**

- Check the output with /usr/local/mip/mip


- On NG2 (master MIP):
	
- Edit /usr/local/mip/config/int-conf.pl  and add NG1's IP address to hostlist.
- Create an additional link to `int.pl` under the new package name (`ng1.canterbury.ac.nz`):

``` 
ln -s int.pl /usr/local/mip/config/ng1.canterbury.ac.nz.pl
```
- Create an additional link to the `int` module under the new package name (`ng1.canterbury.ac.nz`):

``` 
ln -s int /usr/local/mip/modules/ng1.canterbury.ac.nz
```
- Add the new package name (`ng1.canterbury.ac.nz`) to `pkgs` in /usr/local/mip/config/source.pl

- Setup a crontab entry on NG1 to run "mip -remote" every 5 minutes: as root, run "crontab -e" and add


>  */5 * * * * /usr/local/mip/mip -remote >/dev/null 2>&1
>  */5 * * * * /usr/local/mip/mip -remote >/dev/null 2>&1

# Fix: tag job managers with DN hash

**NO LONGER NEEDED**

The problem was: In default settings, the Globus job manager could not handle multiple DNs being mapped to the same user account. Joseph Bester has provided a [patch](http://lists.globus.org/pipermail/gt-user/2010-March/009008.html) for this.

This patch has been integrated into 5.0.2 (and the DN tagging has been made the default behavior).

# Extra: getting UDT working

For improved throughput, it may be useful to get UDT going on the GridFTP server.

For that, you need to:

1. Run the threaded version of gridftp server: 

``` 
cp $GLOBUS_LOCATION/sbin/gcc64dbgpthr/shared/globus-gridftp-server $GLOBUS_LOCATION/sbin/globus-gridftp-server
```
2. Compile UDT drive: back as `globus` in the source tree, run:

``` 
make udt
```
3. Whitelist the UDT driver: add this to gridftp-server startup parameters (in `/etc/xinetd.d/gsiftp`): 

``` 
-dc-whitelist udt,gsi,tcp
```
4. Also, make sure you are using threaded globus-url-copy client: 

``` 
cp $GLOBUS_LOCATION/bin/gcc64dbgpthr/shared/globus-url-copy $GLOBUS_LOCATION/bin/globus-url-copy
```

- Now, transfer files with the `-u` argument:

``` 
globus-url-copy -u gsiftp://ng1.canterbury.ac.nz/etc/termcap file:///tmp/tc-ng1
```

References: 

- [Configuring GridFTP to use UDT instead of TCP](http://www.globus.org/toolkit/docs/5.0/5.0.0/data/gridftp/admin/#gridftp-config-udt)
- [Switching between threaded and non-threaded flavors](http://www.globus.org/toolkit/docs/5.0/5.0.0/data/gridftp/admin/#gridftp-admin-installing-threaded)

# Using Globus

Now, GridFTP and gatekeeper should be all setup - so try submitting your first jobs.  Use `globusrun`, either from this GT5 installation, or from a GT2 installation (available also via VDT)

**Note**: when using the GT5 version of `globusrun`, you **MUST** have an RFC 3820 compliant proxy: i.e., do

``` 

$ grid-proxy-init -rfc
Your identity: /C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl
Enter GRID pass phrase for this identity:
Creating proxy ........................................... Done
Your proxy is valid until: Tue Mar 16 03:00:55 2010
$ grid-proxy-info
subject  : /C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl/CN=1449531504
issuer   : /C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl
identity : /C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl
type     : RFC 3820 compliant impersonation proxy
strength : 512 bits
path     : /tmp/x509up_u12458
timeleft : 11:59:58

```

**Note**: the globusrun client is also opening TCP LISTEN ports.  You should ensure your firewall allows your system to accept incoming TCP connections in the agreed Globus port range (40000-41000) and you must set the GLOBUS_TCP_PORT_RANGE variable to this range to tell the client to use ports in this range:

``` 
export GLOBUS_TCP_PORT_RANGE=40000,41000
```

- Run a simple job and wait for completion:

``` 
globusrun -r ng1 '&(executable=/bin/sleep)(arguments=5)'
```
- Run a simple job and watch streaming output:

``` 
globusrun -o -r ng1 '&(executable=/bin/hostname)'
```
- Run a 2-CPU MPI job

``` 
 globusrun -o -r ng1 '&(executable=mb)(count=2)(job_type=mpi)'
```
- Run a BGP job specifying email notification options, multiple environment variables with custom BG/P options (mode & connect) and multiple arguments:

``` 
globusrun -o -r gram5bgpdev.canterbury.ac.nz/jobmanager-loadleveler '&(executable=/bin/echo)(arguments=Hello World)(queue=bgp)(email_address=vladimir.mencl@canterbury.ac.nz)( email_on_abort = "yes" )( email_on_execution = "yes" )( email_on_termination = "yes" )(jobname="my BGP test job")(count=256)(jobtype=mpi)(environment=(BG_MODE DUAL) (BG_CONNECT MESH))'
```
- Run a job in batch mode (detach from the job)

``` 
globusrun -r ng1 -batch '&(executable=/bin/sleep)(arguments=60)'
```
- Produces:

``` 

globus_gram_client_callback_allow successful
GRAM Job submission successful
https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/
GLOBUS_GRAM_PROTOCOL_JOB_STATE_PENDING
GLOBUS_GRAM_PROTOCOL_JOB_STATE_ACTIVE

```
- Check background job status


>  globusrun -status [https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/](https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/)
>  globusrun -status [https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/](https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/)

- Kill background job


>  globusrun -kill [https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/](https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/)
>  globusrun -kill [https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/](https://ng1.canterbury.ac.nz:40383/16073842043226195841/123149967014513588/)

 ***Note**: when the job manager for the background job is no longer running (and the port in the job URL is thus refusing connections):


# Debugging

- Globus in general


>  export SEG_PBS_DEBUG=255 GLOBUS_ERROR_VERBOSE=1 GLOBUS_ERROR_OUTPUT=1
>  export SEG_PBS_DEBUG=255 GLOBUS_ERROR_VERBOSE=1 GLOBUS_ERROR_OUTPUT=1


>         -log-levels 'FATAL|ERROR|WARN|INFO|DEBUG|TRACE'
>         -log-levels 'FATAL|ERROR|WARN|INFO|DEBUG|TRACE'

# Extra: getting source code from CVS

Before GT 5.0.0 was released, I had to fetch the source code from CVS.  This might be still useful to preview the source code of the next release.

- Use Sun Java (ant has had some problems loading XML parser libraries with openjdk)


>  export JAVA_HOME=/usr/java/latest ; PATH=$JAVA_HOME/bin:$PATH
>  export JAVA_HOME=/usr/java/latest ; PATH=$JAVA_HOME/bin:$PATH

- Get the source code: follow instructions at [http://www.globus.org/toolkit/docs/development/remote-cvs.html](http://www.globus.org/toolkit/docs/development/remote-cvs.html)


>  export CVSROOT=:pserver:anonymous@cvs.globus.org:/home/globdev/CVS/globus-packages
>  cvs co -r globus_5_0_branch packaging
>  cd packaging
>  ./fait_accompli/installer.sh --anonymous
>  export CVSROOT=:pserver:anonymous@cvs.globus.org:/home/globdev/CVS/globus-packages
>  cvs co -r globus_5_0_branch packaging
>  cd packaging
>  ./fait_accompli/installer.sh --anonymous

- success (except for a minor glitch):


>  Bootstrapping done, about to copy source trees into installer.
>  This may take a few minutes.
>  Use of uninitialized value in concatenation (.) or string at /home/globus/inst/gt500/packaging/source-trees/autotools/share/autoconf/Autom4te/XFile.pm line 229.
>  cp: cannot copy cyclic symbolic link `source-trees/database/c/sqliteodbc/sqliteodbc-0.74/source'
>  Done creating installer.
>  Bootstrapping done, about to copy source trees into installer.
>  This may take a few minutes.
>  Use of uninitialized value in concatenation (.) or string at /home/globus/inst/gt500/packaging/source-trees/autotools/share/autoconf/Autom4te/XFile.pm line 229.
>  cp: cannot copy cyclic symbolic link `source-trees/database/c/sqliteodbc/sqliteodbc-0.74/source'
>  Done creating installer.

- created output in gt5.0.0-rc3-all-source-installer
	
- continue from there as if building from downloaded source installer

# More doc

- GRAM5 Administrator's guide: [http://www.globus.org/toolkit/docs/5.0/5.0.0/execution/gram5/admin/](http://www.globus.org/toolkit/docs/5.0/5.0.0/execution/gram5/admin/)
- GT5 command reference: [http://www.globus.org/toolkit/docs/5.0/5.0.0/commands/#gtcommands](http://www.globus.org/toolkit/docs/5.0/5.0.0/commands/#gtcommands)
- GRAM5 RSL reference: [http://www.globus.org/toolkit/docs/5.0/5.0.0/execution/gram5/pi/#gram5-rsl](http://www.globus.org/toolkit/docs/5.0/5.0.0/execution/gram5/pi/#gram5-rsl)

# Maintenance

- Update IGTF certificates with


>  yum --disablerepo=* --enablerepo=vdt-ca-certs update
>  yum --disablerepo=* --enablerepo=vdt-ca-certs update

# Non-standard paths

Locations decided at installation time:

- Globus base install directory: 

``` 
GLOBUS_LOCATION=/opt/globus
```
- globus-job-manager-event-generator pid file: 

``` 
/opt/globus/var/job-manager-seg-pbs.pid
```

# Optional considerations

To run gatekeeper as daemon: 

- edit /opt/globus/etc/globus-gatekeeper.conf, comment out "-inetd" and add "-f"
- start with

``` 
globus-gatekeeper -conf $GLOBUS_LOCATION/etc/globus-gatekeeper.conf
```

# Notable Issues

- GT5 Globusrun only works with RFC 3820 proxy (grid-proxy-init -rfc)
- Globusrun opens TCP LISTEN sockets and must be run with GLOBUS_TCP_PORT_RANGE=40000,41000
- globus-scheduler must be run in non-threaded mode (use binary from shared/gcc64dbg, not gcc64dbgthr)
- Grisu breaks if ContactString does not have :8443 past the hostname - so right now, we are registering with a ContactString: 

``` 
ng1.canterbury.ac.nz:8443/jobmanager-pbs
```
- (and redirecting port 8443 to 2119)

>  ***All variables in pbs.pm must be initialized**: There's a big difference between how pbs.pm runs in GT4 and GT5: GT4 ALWAYS launches pbs.pm in a new process (because it's java and it's invoking PERL externally), while as GT5 is running in perl (the job manager is), the invocations to pbs.pm are done internally within the same process - and reuse the environment.  Consequently, if a variable is not initialized in a new run (assuming it's blank), this assumption fails on the next run because the variable contains the last value it had in the previous run.  This can result in very weird behavior: e.g., jobs being invoked with a list of arguments that is a concatenation of arguments passed to all previous jobs.


- In default settings, the Globus job manager cannot handle multiple DNs being mapped to the same user account - this has been [fixed with a patch](#SetupGRAM5onCentOS5-Fix___tagjobmanagerswithDNhash)
