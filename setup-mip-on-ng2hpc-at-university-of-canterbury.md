# Setup MIP on NG2HPC at University of Canterbury

Setting up MIP on Ng2Hpc was a rather complex task done after Ng2Hpc was [Setup NG2HPC set up](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=Vladimir&title=Setup%20NG2HPC%20set%20up), and hence deserves a standalone page.

The installation consisted of:

1. Extending MIP to support LoadLeveler as LRMSType
2. Configuring MIP to export data via *MIP remote* to `ng2`
3. Configuring MIP on `ng2` to merge the MIP remote information from Ng2Hpc into the data constructed for RPProvider.
4. Configuring MIP to advertise multiple clusters (AIX and Linux) and multiple compute elements for the queues available on the HPC

# Installing MIP

Similarly as for [Setup_NG2#Installing_MIP installing MIP on Ng2](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=Vladimir&title=Setup_NG2):

>  wget -P /etc/yum.repos.d/ [http://ng0.hpc.jcu.edu.au/apac/gateway/rpms/jcu-apac.repo](http://ng0.hpc.jcu.edu.au/apac/gateway/rpms/jcu-apac.repo)
>  yum install APAC-mip-module-py APAC-mip-globus

# Basic MIP configuration

## Configuring interaction with LoadLeveler

In `apac_config.py`, set:

>       computeElement.JobManager = 'Loadleveler'
>       computeElement.LRMSType = 'LoadLeveler' # Torque|PBSPro|ANUPBS
>       ###computeElement.qstat = '/usr/bin/qstat'
>       ###computeElement.pbsnodes = '/usr/bin/pbsnodes'
>       computeElement.llstatus = '/opt/ibmll/LoadL/full/bin/llstatus'
>       computeElement.llq = '/opt/ibmll/LoadL/full/bin/llq'
>       computeElement.llclass = '/opt/ibmll/LoadL/full/bin/llclass'

and continue as you would do otherwise in your MIP installation.

For LoadLeveler, the difficult part here was extending `computeelement.py` to support LoadLeveler as the job manager.  Please contact me if you are interested in the extension.  The extension invokes the `llstatus`, `llq`, and `llclass` command to obtain the same information as the PBS `qstat` and `pbsnodes` commands would yield, and to feed the information into the ComputeElement fields in a similar way as the PBS part would.

Some of the major differences are listed below:

- The LoadLeveler code *safely ignores*
	
- checking if Queue is Execution, Started, Enabled
- checking host and user ACLs

## Additional configuration details

### Directory names

Create directories for App Tmpdir, WNTmpDir

>  cd /hpc/gridusers/grid
>  mkdir app appdata tmp
>  chmod 3775 app appdata tmp
>  chown daemon.grid000 app appdata tmp

In `apac_config.py`, set:

>   cluster.WNTmpDir = '/tmp' # local to work-node
>   cluster.TmpDir = '/hpc/gridusers/grid/tmp' # shared directory on HPC cluster(s)
> 1. note: cluster.TmpDir is frequently ~/.globus/scratch
>   computeElement.ApplicationDir = '/hpc/gridusers/grid/app'
> 2. directory available for application installation
>   computeElement.DataDir = '/hpc/gridusers/grid/appdata' # cluster.TmpDir
> 3. directory available for application data (shared)

### Configure Storage Element name

For each StorageElement, the UniqueID is by convention its hostname.  Change the UniqueID to follow this convention and make sure all references to the SE in the ComputeElements and their VOViews refer to the StorageElement by the correct UniqueID. 

>   storageElement = package.StorageElement['ng2hpc.canterbury.ac.nz'](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%27ng2hpc.canterbury.ac.nz%27&linkCreation=true&fromPageId=3818228466) = StorageElement()

  computeElement.DefaultSE = 'ng2hpc.canterbury.ac.nz'

>   voview.DefaultSE = 'ng2hpc.canterbury.ac.nz'

Remember also to set proper voview information for all ComputingElements and StorageElements.

### Misc

For compute elements, set their status to 'Production' (running and queueing jobs).

>  computeElement.Status = 'Production'

# Multiple clusters and MIP integrator

MIP supports multiple clusters handled by a single MIP instance, and MIP supports integrating data produced in remote MIP instances via MIP integrator.  There is however a number of pitfalls to be avoided, and it's important to understand MIP's design limitations to structure the configuration so that all the data can be integrated correctly.

MIP uses the concept of a **package** for creating a one-level namespace for the MIP data entities.  The package name is used in two ways: (1) to identify the MIP module that would produce the data, and (2) to scope the entity IDs for the data entities produced by that module for that package.

An module (a standalone executable, usually a script) is invoked with the three arguments: the package name, the data entity ID and the MIP configuration directory to produce the data for the given entity defined within the given package.

Example: to produce the GLUE data for the ComputingElement `compute1` defined in package `default`, one would invoke the following commands:

>  cd /usr/local/mip
>  export PYTHONPATH="/usr/local/mip/modules/apac_py:$PYTHONPATH"
>  /usr/local/mip/modules/apac_py/ComputingElement/computingelement.py default compute1 /usr/local/mip/config/

***Important***: The key issue is that if there is data for multiple clusters, each cluster should have its own namespace (i.e., its own package).  If there are multiple clusters defined within the same package namespace, the data would be mixed together - each cluster would contain all compute elements and storage elements defined by all clusters.

## MIP package schema

In my setting, I needed to define the following GLUE data entities:

1. Cluster HPC-AIX with several ComputingElements (LoadLeveler job classes `par4_6` and `serial_6`) and a SubCluster defining the architecture as Power5+/AIX
2. Cluster HPC-Linux with a ComputingElements (LoadLeveler job class `linux_all`) and a SubCluster defining the architecture as Power5+/Linux
3. Cluster NG2 with a single ComputingElement (PBS job queue `small`) and the corresponding SubCluster and StorageElement entities.

The first two clusters have to be defined at Ng2Hpc to collect the status information there, and cluster Ng2 would be defined at Ng2 itself to gather the PBS status information there.

The reason to define a separate cluster for the AIX and Linux parts is twofold: to define a proper SubCluster element with correct architecture specification for each of them, and to have a correct list of installed software for each of them (some software may be installed on only one of AIX or Linux, or may be installed in different locations).

The first two clusters have their data produced by the apac_py module at Ng2Hpc (as packages `ng2hpcInt` and `ng2hpcIntLinux`), and the data is regularly fed to Ng2 via MIP remote.  On Ng2, the two Ng2Hpc clusters are defined again, under the same names, but handled by the MIP remote module.  This way, they are merged together with the local information for Ng2 and are fed into the MIP RPProver in the Globus WS container.

## Defining MIP packages

Defining a MIP package (called `mypackage`) consists of a few steps:

- listing the package in `/usr/local/mip/config/source.pl` in the `pkgs` array

``` 
pkgs       => ['mypackage', 'myotherpackage',],
* creating a file called <tt>/usr/local/mip/config/mypackage.pl</tt> listing the UIDs in the package.
** see <tt>/usr/local/mip/config/default.pl</tt> for an example
** the package name (<tt>mypackage</tt>) must be included in clusterlist array in the package file
* creating a ''module directory'' for the package.  The module implementation used would be either <tt>apac_py</tt> or <tt>int</tt> (integrator), so you'd symlink one of these directories.  See the directory structure in the existing modules.

Step 1: On Ng2Hpc, define MIP packages <tt>ng2hpcInt</tt> and <tt>ng2hpcIntLinux</tt>.
* copy <tt>/usr/local/mip/config/default.pl</tt> to <tt>/usr/local/mip/config/ng2hpcInt.pl</tt> and <tt>/usr/local/mip/config/ng2hpcInt.pl</tt>
** edit the new files and change Ids accordingly
* edit <tt>/usr/local/mip/config/source.pl</tt><pre>pkgs       => ['ng2hpcInt','ng2hpcIntLinux',],
```
- use `apac_py` as the implementation for the two new packages


>    cd /usr/local/mip/modules
>    ln -s apac_py ng2hpcInt
>    ln -s apac_py ng2hpcIntLinux
>    cd /usr/local/mip/modules
>    ln -s apac_py ng2hpcInt
>    ln -s apac_py ng2hpcIntLinux

- create initialization file for SoftwareInformationProvider (SIP) - see additional instructions later.


>    cd /usr/local/mip/config
>    cp default_sub1_SIP.ini ng2hpcInt_subNg2HpcAIX_SIP.ini
>    cp default_sub1_SIP.ini ng2hpcIntLinux_subNg2HpcLinux_SIP.ini
>    cd /usr/local/mip/config
>    cp default_sub1_SIP.ini ng2hpcInt_subNg2HpcAIX_SIP.ini
>    cp default_sub1_SIP.ini ng2hpcIntLinux_subNg2HpcLinux_SIP.ini

Check that your configuration is valid with 

>  ng2hpc# /usr/local/mip/config/globus/mip-exec.sh -validate

Step 2: On Ng2 (the integrator host), define MIP packages `ng2hpcInt` and `ng2hpcIntLinux` as packages handled by the `int` module.

- use `int` as the package implementation


>    cd /usr/local/mip/modules
>    ln -s int ng2hpcInt
>    ln -s int ng2hpcIntLinux
>    cd /usr/local/mip/modules
>    ln -s int ng2hpcInt
>    ln -s int ng2hpcIntLinux

- the integrator stores UIDs of all received entities in `/usr/local/mip/config/int.pl`.  Use this file as the definition list for the two new packages.


>    cd /usr/local/mip/config
>    ln -s int.pl ng2hpcInt.pl
>    ln -s int.pl ng2hpcIntLinux.pl
>    cd /usr/local/mip/config
>    ln -s int.pl ng2hpcInt.pl
>    ln -s int.pl ng2hpcIntLinux.pl

- add the two packages to the source list: edit `/usr/local/mip/config/source.pl`

``` 
pkgs       => ['default','ng2hpcInt', 'ng2hpcIntLinux', ],
```
- make sure that for each data type, the integrator script is linked as a module in 

``` 
/usr/local/mip/modules/int/<datatype>
```

 (the links are broken in the default installation)

## Setting up integrator

MIP integrator:

- edit config/int-conf.pl on remote publisher (Ng2Hpc) and set integrator IP
- edit config/int-conf.pl on integrator host (Ng2) and list permitted publishers
- set the integrator cache direcotory on the integrator host and set the permission on that directory to allow MIP to delete old files.  Note that MIP is ran from the Globus WS container under the `daemon` uid.


>  mkdir -p /usr/local/mip/var/intcache
>  cd /usr/local/mip/var/intcache
>  mkdir Cluster ComputingElement Site StorageElement SubCluster
>  chown daemon.daemon *
>  mkdir -p /usr/local/mip/var/intcache
>  cd /usr/local/mip/var/intcache
>  mkdir Cluster ComputingElement Site StorageElement SubCluster
>  chown daemon.daemon *

- run "/usr/local/mip/mip -integrator" as a service
- run "/usr/local/mip/mip -remote" periodically to push data

To run mip intergator as a service, create `/etc/rc.d/init.d/mip-integrator` starting `/usr/local/mip/integrator.pl /usr/local/mip/config` and enable it with

``` 

chkconfig --add mip-integrator
chkconfig mip-integrator on
service mip-integrator start

```

To add MIP remote as a cron job on Ng2Hpc, run

>  crontab -e

and add the following file as the cron job definition

>  */5 * * * * /usr/local/mip/mip -remote >/dev/null 2>&1

## Special considerations for the SITE element

Note that even the remote host must publish a SITE element, even though it would be desirable to have this host defined only once, on Ng2.  However, without a Site element, no content would be transmitted from Ng2Hpc.  If the Site elements produced at Ng2 and Ng2Hpc would have a different UID, the content would not be merged together.  Thus, Ng2Hpc must define a Site element, with the same UID as Ng2.

MIP has a priorities mechanism, which unfortunately does not work as documented.  Depending on yet unknown factors, either the local site ore remote content would take priority.  Further, fields not set in the selected Site element would be merged from the other Site element.  Both MIP instances must produce a Site element, with identical content, to remedy the nondeterminism in the selection mechanism.

## Software definitions

Some software would be installed on both AIX and Linux in the same locations, some software would be installed on only one of the clusters, or would be installed in different locations.  To provide correct information and avoid redundancy, I have created three separate software definition files in `/usr/local/mip/modules/apac_py/SubCluster/softwareInfoData`:

- `subNg2Hpc-localSoftware.xml` for software installed on both AIX and Linux parts of the HPC
- `subNg2HpcAIXonly-localSoftware.xml` for software installed only on AIX
- `subNg2HpcLinuxonly-localSoftware.xml` for software installed only on Linux

The respective SIP ini files then each merge the shared software information file with the cluster specific one:

`ng2hpcInt_subNg2HpcAIX_SIP.ini`

``` 

[source1]
uri: file:softwareInfoData/subNg2Hpc-localSoftware.xml
format: APACGLUE1.2

[source2]
uri: file:softwareInfoData/subNg2HpcAIXonly-localSoftware.xml
format: APACGLUE1.2

```

`ng2hpcIntLinux_subNg2HpcLinux_SIP.ini`

``` 

[source1]
uri: file:softwareInfoData/subNg2Hpc-localSoftware.xml
format: APACGLUE1.2

[source2]
uri: file:softwareInfoData/subNg2HpcLinuxonly-localSoftware.xml
format: APACGLUE1.2

```

# Important problems discovered

- Set correct operational state in computeElement.Status


>   computeElement.Status = 'Production'
>   computeElement.Status = 'Production'


>                 push(@list,"$dirname/$file") if ! -d "$dirname/$file" && -x "$dirname/$file";
>                 push(@list,"$dirname/$file") if ! -d "$dirname/$file" && -x "$dirname/$file";

- Problem: AvailableSpace > maxInt32 (2TB) triggers validation error when deserializing XML into Casper Java objects.

Workaround: patch StorageElement/storageelement.py to cap space (Avail and Used) to MaxInt32

- GLUE 1.2 does not allow to express resource constraints such as maximal number of CPUs allowed per job
	
- and Max Running Jobs has very unclear semantics "per user"
- unclear FreeJobSlots - when multiple CEs compete for the same resources
- ***Note:** Gerson has pointed me to two links on plans for extending the (APAC) GLUE schema:
	
- 
- [http://www.vpac.org/twiki/bin/view/APACgrid/NCRISInformationServicesRequirements](http://www.vpac.org/twiki/bin/view/APACgrid/NCRISInformationServicesRequirements)
- [http://www.vpac.org/twiki/bin/view/APACgrid/AdditionalFieldsForTheAPACSoftwareMap](http://www.vpac.org/twiki/bin/view/APACgrid/AdditionalFieldsForTheAPACSoftwareMap)

- AssignedJobSlots and JobManager not handled/printed
	
- JobManager is also ignored by current tools....

- MaxTime is not parsed: PDFspec+APACwiki says "MaxWallTime", XSD+code says "MaxWallClockTime". Will change to MaxWallClockTime.


>        if ce.MaxTotalJobs is not None and ce.TotalJobs is not None and ce.FreeJobSlots is None:
>        if ce.MaxTotalJobs is not None and ce.TotalJobs is not None and ce.FreeJobSlots is None:

- Broken symlinks in `/usr/local/mip/modules/int/`

# Local modifications

TODO

# Useful commands

- To see the MIP output and check validity


>  /usr/local/mip/config/globus/mip-exec.sh -validate 2>&1 | less
>  /usr/local/mip/config/globus/mip-exec.sh -validate 2>&1 | less

- To see output of a single MIP module invocation


>  cd /usr/local/mip
>  export PYTHONPATH="/usr/local/mip/modules/apac_py:$PYTHONPATH"
>  /usr/local/mip/modules/apac_py/ComputingElement/computingelement.py default compute1 /usr/local/mip/config/
>  cd /usr/local/mip
>  export PYTHONPATH="/usr/local/mip/modules/apac_py:$PYTHONPATH"
>  /usr/local/mip/modules/apac_py/ComputingElement/computingelement.py default compute1 /usr/local/mip/config/

- To see the gathered data on the integrator host


>  export PERL5LIB=$PERL5LIB:/usr/local/mip::
>  /usr/local/mip/modules/int/Site/Site default TEST /usr/local/mip/config/
>  /usr/local/mip/modules/int/Site/Site default CANTERBURY /usr/local/mip/config/
>  export PERL5LIB=$PERL5LIB:/usr/local/mip::
>  /usr/local/mip/modules/int/Site/Site default TEST /usr/local/mip/config/
>  /usr/local/mip/modules/int/Site/Site default CANTERBURY /usr/local/mip/config/

- To see the actual owner of a running grid job (if tagged)

``` 

 llq -l -x <LoadLevelerJobStepID>

```
- To see the status of your globus job from the outside

``` 

 wsrf-query -s 'https://ng2hpc.canterbury.ac.nz:8443/wsrf/services/ManagedExecutableJobService'  \
     -k '{http://www.globus.org/namespaces/2004/10/gram/job}ResourceID' <job-resource-ID>

```
