# Setup GRAM5.2 with LoadLeveler

This page provides the LoadLeveler specific details for setting up a GRAM5.2 grid gateway.

**Note: This page is a GRAM 5.2 rehash of ****[Setup GRAM5 with LoadLeveler](/wiki/spaces/BeSTGRID/pages/3818228499)** |

Start by first installing a plain GRAM5.2, following the instructions on the [Setup GRAM5 on CentOS 5](setup-gram5-on-centos-5.md) page (skipping all PBS-specific steps), then proceed from here.

This procedure for setting up a LoadLeveler grid gateway is based on the `llgrid.tar` module that comes with LoadLeveler, and adapts it for GT5.2 with a patch coming from the EU IGE project and additinal locally developed extensions.  Hence, you will need the LoadLeveler distribution available to proceed.

The steps in setting up gateway are:

1. Configuring the grid gateway as a submit-only node in LoadLeveler cluster
2. Installing GRAM5.2
3. Downloading and applying the IGE patch
4. Applying additonal local modifications
5. Compiling and installing the llgrid module
6. Finishing up the GRAM5.2 configuration

# Linking into LoadLeveler cluster

Configure the grid gateway as a submit-only node in the LoadLeveler cluster.  This in particular includes:


## Installing LoadLeveler binaries on a RedHat host

>  **To access a LoadLeveler cluster from a grid gateway (job submission gateway), it is neccessary to install the LoadLeveler binaries for the right platform (RHEL 5 or 6, i386 or x86_64) on the host.  For llsubmit to work correctly (especially at sites with account validation or complex job submission filters), it is necessary to install the*full** version (not just **so** (submit-only)) of the binaries.  

- 
- LoadLeveler 4.1 splits the binaires into *scheduler* and *resource manager*.  The core package is *scheduler*, but to be able to run llsummary (for reporting), it is also necessary to install resmgr (llsummary needs libllrapi.so from LoadL-full-resmgr)

This section covers installing LoadLeveler 3.5 and 4.1 - which differ in some steps.  But both require a license package to install the binaries.  And for both, the license package would first install the base-level revision from the installation media - and only after that, we can manually update to a downloaded update package.

So first, copy the Java package + the original RPM (base version) into the current directory...

The steps to install LoadLeveler 4.x binaries are:

- Install license package: 

``` 
yum localinstall LoadL-full-license-RH6-X86_64-4.1.1.0-0.x86_64.rpm
```
- Install hidden dependency of the license package: 

``` 
yum install libXp
```
- Run install package, accepting license and installing scheduler+resmgr (no -c argument) from current directory:

``` 
/opt/ibmll/LoadL/sbin/install_ll -y -d .
```
- Now update to the latest update: 

``` 
yum localinstall LoadL-scheduler-full-RH6-X86_64-4.1.1.9-0.x86_64.rpm LoadL-resmgr-full-RH6-X86_64-4.1.1.9-0.x86_64.rpm
```

For LoadLeveler 3.5: 

- Install the license package: 

``` 
yum localinstall LoadL-full-license-RH5-X86_64-3.5.1.0-0.x86_64.rpm
```
- Install packages needed for 32-bit Java app accepting the license: 

``` 
yum install libXmu.i686 libXtst.i686 libXp.i686 libgcc.i686
```
- Run the installer to install from the local directory:

``` 
/opt/ibmll/LoadL/sbin/install_ll -y -d .
```
- Update to the latet point-release: 

``` 
yum localinstall LoadL-full-RH5-X86_64-3.5.1.16-0.x86_64.rpm
```

Post-install:

- Create /etc/LoadL.cfg with:


>  LoadLConfig  = /hpc/home/loadlbgp/LoadL_config
>  LoadLUserid  = loadl
>  LoadLGroupid = loadl
>  LoadLConfig  = /hpc/home/loadlbgp/LoadL_config
>  LoadLUserid  = loadl
>  LoadLGroupid = loadl

- Create /etc/profile.d/loadl.sh:


>  PATH=$PATH:/opt/ibmll/LoadL/full/bin/
>  export PATH
>  PATH=$PATH:/opt/ibmll/LoadL/full/bin/
>  export PATH

# Installing GRAM5.2

Install a generic GRAM5.2 gateway.  Note: as of 5.2, the Globus Toolkit is distributed in an RPM distribution.  Most of the steps for setting up the gateway are covered in [Setup GRAM5 on CentOS 5](setup-gram5-on-centos-5.md) - but as opposed to the compile-from-source instructions there (relevant for GRAM5.0), install from RPMs.

# Installing Globus LoadLeveler module

## Installing required Globus packages

In addition to the basic Globus packages, this module will need:

- The Globus SEG module for SEG functionality
- GPT and a number the SEG -devel package for compiling the LoadLeveler SEG module.

Install all of the dependecies with:

>  yum install globus-scheduler-event-generator globus-scheduler-event-generator-progs globus-scheduler-event-generator-doc globus-scheduler-event-generator-devel grid-packaging-tools 

## Getting module source code 

Installing LoadLeveler binaries (as per above) installs llgrid.tar (either as `/opt/ibmll/LoadL/resmgr/full/lib64/llgrid.tar` (LL 4.1) or /opt/ibmll/LoadL/full/lib/llgrid.tar (LL 3.5).

The llgrid.tar file contains all the necessary scripts and configuration file templates.  However, in LoadLeveler 3.5 and newer (including 4.1), llgrid.tar only contains binary forms of the SEG module (for Linux i386 and for AIX, both only 32-bit, both linked against Globus 4.0).  Only llgrid.tar distributed with LoadLeveler 3.4 contains the  source code for the SEG module.  Hence, it is necessary to get this version of llgrid.tar.

# Patching and Compiling llgrid module

- Download the patch from [http://www.ige-project.eu/patches/ll-adaptor-patch-for-gt5](http://www.ige-project.eu/patches/ll-adaptor-patch-for-gt5)
	
- Even though the "Get the patch here" link asks you to sign into the "ige-project.eu" Google Docs space, any Google account is accepted (use the *Sign in with a different account* link)
- The commands below assume you've downloaded it into `~llgrid.tar.patch.gt5.0.4`

- Extract and patch the module:

``` 

 tar xf /opt/ibmll/LoadL/full/lib/llgrid.tar
 mv gt4 llgrid-gt5
 cd llgrid-gt5
 patch < ../llgrid.tar.patch.gt5.0.4 -p 0
 > patching file deploy.sh
 > patching file seg-src/configure

```

## Update files to GT 5.2

The process so far creates LoadLeveler module that would fit in with GT5.0.x.  As GT5.0.x was compiled from source, it would install into a single hierarchy (e.g., /opt/globus) and the deploy.sh script that comes with this module was heavily relying on this (and using GLOBUS_LOCATION).  However, GRAM5.2 (rpm-based) integrates into the OS distribution - config files under /etc, binaries under /usr/bin, logs under /var.  This section details the changes that had to be made to these files to work with GRAM5.2

The changes primarily change file locations due to the shift from $GLOBUS_LOCATION into the main system directories - but there are other minor changes as well.

The following changes assume deploy.sh will be invoked with GLOBUS_LOCATION=/usr

In deploy.sh, make the following changes - as per patch file:  [llgrid-tar-gt50-to-52.diff](attachments/Llgrid-tar-gt50-to-52.diff.txt)


In `seg-src/configure` (the configure script for the SEG module), make the following changes (covered in the patch file linked above):

- Change the path to Globus flavor definitions to: 

``` 
$GLOBUS_LOCATION/share/globus/flavors/flavor_$GLOBUS_FLAVOR_NAME.gpt
```
- Change the path to GPT_INCLUDES (use `lib` instead of `lib64` if on a 32-bit system): 

``` 
GPT_INCLUDES="-I$GLOBUS_LOCATION/include/globus -I$GLOBUS_LOCATION/lib64/globus/include $GPT_CONFIG_INCLUDES"
```
- If on a 64-bit system, use `lib64` in GPT_LDFLAGS: 

``` 
GPT_LDFLAGS="$GPT_CONFIG_STATIC_LINKLINE -L$GLOBUS_LOCATION/lib64 $GPT_LDFLAGS"
```
- Change path to the globus-build-env script: 

``` 
. $GLOBUS_LOCATION/share/globus/globus-build-env-$GLOBUS_FLAVOR_NAME.sh
```
- Use system libtool instead of Globus libtool (and explicitly tell it to use the C compiler): 

``` 
LIBTOOL='$(SHELL) libtool --tag=CC'
```

In `seg-src/seg_loadleveler_module.c`, make the following changes (covered in the patch file linked above):

- Change the module definition to match the new headers (and drop last NULL argument): 

``` 
GlobusExtensionDefineModule(globus_seg_loadleveler) =
```
- Change the location of the configuration file to `/etc/globus/globus-loadleveler.conf`:

``` 
globus_common_get_attribute_from_config_file("/etc/globus", "globus-loadleveler.conf", "log_path", &state->path);
```

In `loadleveler.pm`, make at least the following changes - as per the patch snippet below - or download the patch file [loadleveler-pm-50-to-52.diff](attachments/Loadleveler-pm-50-to-52.diff.txt)

- Correct the path to the globus-loadleveler configuration file: 

``` 
my $log_conf_file = "/etc/globus/globus-loadleveler.conf";
```
- Remove dependency on `Globus::Core::Paths::tmpdir` (which no longer exists) - use "/tmp" if this property returns null
- Set PATH to default environment + LL binaries if PATH not set (within gatekeeper)

``` 

--- loadleveler.pm      2008-03-05 12:18:05.000000000 +1300
+++ /hpc/home/vme28/sys/inst/LL-34-llgrid/llgrid-gt5.2/loadleveler.pm   2012-09-27 16:59:39.741283970 +1200
@@ -27,6 +27,17 @@
        $llq      = '/opt/ibmll/LoadL/full/bin/llq';
    }
 
+   # IMPORTANT: add $llpath/bin to PATH so that submit filters can find llclass in PATH
+   # If PATH is not defined at all yet, populate it with something meaningful first.
+   if (!defined($ENV{"PATH"})) {
+       $ENV{"PATH"} = "/bin:/sbin:/usr/bin:/usr/sbin";
+       if (defined ($ENV{"GLOBUS_LOCATION"})) {
+           my $GLOBUS_LOCATION = $ENV{"GLOBUS_LOCATION"};
+           $ENV{"PATH"} = $ENV{"PATH"}.":$GLOBUS_LOCATION/bin:$GLOBUS_LOCATION/sbin";
+       };
+   };
+   $ENV{"PATH"} = $ENV{"PATH"}.":$llpath"; 
+
    $ll_poe   = '/bin/poe';
 }
 
@@ -35,9 +46,11 @@
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);
-   $self->{loadleveler_logfile} = $Globus::Core::Paths::tmpdir
-      . "/gram_loadleveler_log." . $self->{JobDescription}->uniq_id();
-   bless $self, $class;
+   my $log_uniq_id =  $self->{JobDescription}->uniq_id();
+   if ( ! $log_uniq_id ) { $log_uniq_id = "" . time() . ".$$"; };
+   $self->{loadleveler_logfile} = ( not_null($Globus::Core::Paths::tmpdir) ? 
+         $Globus::Core::Paths::tmpdir : "/tmp" )
+      . "/gram_loadleveler_log." . $log_uniq_id; #$self->{JobDescription}->uniq_id();   bless $self, $class;
    return $self;
 }
 
@@ -417,7 +430,7 @@
    $script_file->print("#   GLOBUS_NOTIFY_USER=YES; \\\n");
 
    # check log file location
-   my $log_conf_file = $ENV{'GLOBUS_LOCATION'}."/etc/globus-loadleveler.conf";
+   my $log_conf_file = "/etc/globus/globus-loadleveler.conf";
    my $script_response = new IO::File($log_conf_file);
 
    if($script_response) {

```

# Deploy and Configure the module

Deploy the module

- Edit `globus-loadleveler.conf` - point to point to your shared LoadLeveler job status file (e.g., `/hpc/home/loadl/globus-loadleveler.log`)

- Run:

``` 
GLOBUS_LOCATION=/usr ./deploy.sh root
```
- This deployes the following key files:
	
- loadleveler.pm goes into /usr/share/perl5/vendor_perl/Globus/GRAM/JobManager
- jobmanager-loadleveler goes into /etc/grid-services/available (and then symlink to /etc/grid-services)
- globus-loadleveler.conf goes into /etc/globus

- Now, this installs only the 32-bit version of the SEG module - precompiled for an old version of Globus.  Remove them: 

``` 
rm -f /usr/lib/libglobus_seg_loadleveler_gcc32dbg.*
```

- Compile, run and install the SEG module (note: make install breaks on missing gpt files, let us ignore this and install exe+lib only with make install-exec):


>  cd seg-src
>  GLOBUS_LOCATION=/usr ./configure --with-flavor=gcc64
>  make
>  make install-exec
>  cd ..
>  cd seg-src
>  GLOBUS_LOCATION=/usr ./configure --with-flavor=gcc64
>  make
>  make install-exec
>  cd ..

- Symlink flavour-specific library files without the flavour name (so that Globus can see them):


>  ( cd /usr/lib64 ; for LIB in libglobus_seg_loadleveler_gcc64.* ; do TARGET=`echo $LIB | sed -e 's/_gcc64//'` ; ln -s $LIB $TARGET ; done )
>  ( cd /usr/lib64 ; for LIB in libglobus_seg_loadleveler_gcc64.* ; do TARGET=`echo $LIB | sed -e 's/_gcc64//'` ; ln -s $LIB $TARGET ; done )

## Install and Activate Scheduler Event Generator

The scheduler event generator package translates the LoadLeveler-specific job event log files to the Globus LRM-neutral notation (which happens to be the same as LoadLeveler...)

- Install the SEG package: 

``` 
yum install globus-scheduler-event-generator
```
- Tell Scheduler-Event-Generator we want to use SEG with LoadLeveler:


>  mkdir /etc/globus/scheduler-event-generator
>  touch /etc/globus/scheduler-event-generator/loadleveler
>  service globus-scheduler-event-generator start
>  chkconfig globus-scheduler-event-generator on
>  mkdir /etc/globus/scheduler-event-generator
>  touch /etc/globus/scheduler-event-generator/loadleveler
>  service globus-scheduler-event-generator start
>  chkconfig globus-scheduler-event-generator on

- NOTE: to launch the SEG manually, -TESTING: this command starts SEG for LL:


>   /usr/sbin/globus-scheduler-event-generator -s loadleveler -p /var/run/globus-scheduler-event-generator-loadleveler.pid -d /var/lib/globus/globus-seg-loadleveler -b
>   /usr/sbin/globus-scheduler-event-generator -s loadleveler -p /var/run/globus-scheduler-event-generator-loadleveler.pid -d /var/lib/globus/globus-seg-loadleveler -b

- Edit /etc/grid-services/available/jobmanager-loadleveler and add the following to the list of arguments:


>   -seg-module loadleveler
>   -seg-module loadleveler

# Customizing LoadLeveler.pm

- Customize your loadleveler.pm - contact the [author of this documentation](vladimirbestgridorg.md)

- Note: if you are using LoadLeveler submit filters that depend on LoadLeveler binaries being in the PATH, you will need to modify `loadleveler.pm` by adding the following (Globus drops PATH when executing the perl job manager (loadleveler.pm) so this may be the simplest way):


>  $ENV{"PATH"} = "/bin:/sbin:/usr/bin:/usr/sbin";
>  $ENV{"PATH"}=$ENV{"PATH"}.":$llpath"; # Linux: $llpath = '/opt/ibmll/LoadL/full/bin';
>  $ENV{"PATH"} = "/bin:/sbin:/usr/bin:/usr/sbin";
>  $ENV{"PATH"}=$ENV{"PATH"}.":$llpath"; # Linux: $llpath = '/opt/ibmll/LoadL/full/bin';

# TODO

- Report to Globus team: job manager LRM-interface script (loadleveler.pm) not getting PATH in environment from GRAM5 job manager
