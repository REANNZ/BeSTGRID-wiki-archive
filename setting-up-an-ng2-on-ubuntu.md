# Setting up an NG2 on Ubuntu

This guide is tightly meshed with the [Setting up an NG2](/wiki/spaces/BeSTGRID/pages/3816950633) guide. It tries to avoid redundancies and refers back frequently to its parent. Please refer to the parent and the LRM-specific pages additionally to this guide.

At time of writing the descriptions are based on the (64 bit) server release of Ubuntu 10.04 LTS (Long Term Support, code name "Lucid Lynx"). It is likely to work equally well with slightly older or newer releases, 32 bit releases and with (some minor) modifications with current Debian releases as well.

**Note:** Some of these notes may not be 100% in proper chronological order. The order has been retained from the [original NG2 install notes](/wiki/spaces/BeSTGRID/pages/3816950633) to keep them in sync. But it should be quite obvious that certain configuration can only be integrated into VDT once VDT has been installed. Please, keep this in mind when using this guide.

# Preliminaries

See also [Setting up an NG2#Preliminaries](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-Preliminaries).

## OS requirements


>  #127.0.1.1      ng2.your.site.domain ng2
>  #127.0.1.1      ng2.your.site.domain ng2

# Preparing the installation

## Adding machine users

Add the machine users for the host, they do not need a login shell, so we'll give them /bin/false:

>  $ sudo useradd grid-bestgrid -s /bin/false
>  $ sudo useradd grid-admin -s /bin/false

Set up the users' home directory by configuring the host for NFS mounts (and potentially the auto mounter), if these users' home directories are "living" on the NFS.

## Configuring local scheduler access

See also [Setting up an NG2#Configuring local scheduler access](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-Configuringlocalscheduleraccess).

This is dependent on the LRM used. The description given here is for Torque/PBS.

This host (NG2) is to submit computation jobs to the Torque/PBS cluster head node. For this, the Torque/PBS client tools have to be installed, which are then used by the Grid submission tools from VDT.

- Install the `torque-client` package.
- Edit/enter the PBS head node name in `/var/lib/torque/server_name`
- Set up ports for PBS in `/etc/services` (in "Local Services"):

>  pbs_server      15000/tcp       # added for Grid services
>  pbs_dis         15001/tcp       # added for Grid services
>  pbs_dis         15001/udp       # added for Grid services
>  pbs_mom         15002/tcp       # added for Grid services
>  pbs_mom         15003/tcp       # added for Grid services
>  pbs_mom         15003/udp       # added for Grid services
>  pbs_sched       15004/tcp       # added for Grid services

## GridPulse

Get and install the APAC GridPulse system monitor:

- Get the RPM from the ARCS RPM repository, in this case here: [http://projects.arcs.org.au/dist/production/5/i386/noarch/APAC-gateway-gridpulse-0.3-4.noarch.rpm](http://projects.arcs.org.au/dist/production/5/i386/noarch/APAC-gateway-gridpulse-0.3-4.noarch.rpm)
- Convert it with the `alien` tool to a Debian package (do not use the `--scripts` option), copy the Debian package to the host and install it.


>  ***Hack the script **`/usr/local/bin/gridpulse`** to fit Ubuntu!**  This one should work for a start: [gridpulse](/wiki/download/attachments/3816950445/Gridpulse.sh?version=1&modificationDate=1539354080000&cacheVersion=1&api=v2) (Note: renamed for upload on the wiki.)
>  ***Hack the script **`/usr/local/bin/gridpulse`** to fit Ubuntu!**  This one should work for a start: [gridpulse](/wiki/download/attachments/3816950445/Gridpulse.sh?version=1&modificationDate=1539354080000&cacheVersion=1&api=v2) (Note: renamed for upload on the wiki.)

- Create a file `/usr/local/lib/gridpulse/system_packages.pulse` and add the following line to it:


>  apac-gateway-gridpulse
>  apac-gateway-gridpulse

- Add further installed RPM packages during the course of this guide to it. For this full guide the list will look like this:


>  apac-gateway-gridpulse
>  ggateway
>  pbs-telltail
>  apac-mip
>  apac-mip-module-py
>  apac-mip-globus
>  apac-mip-module-py-config
>  apac-glue-schema
>  apac-gateway-gridpulse
>  ggateway
>  pbs-telltail
>  apac-mip
>  apac-mip-module-py
>  apac-mip-globus
>  apac-mip-module-py-config
>  apac-glue-schema

- Add a `crontab` entry for executing the script every 20 minutes:


>  3,23,43 * * * * /usr/local/bin/gridpulse grid_pulse@lists.arcs.org.au >/dev/null 2>&1
>  3,23,43 * * * * /usr/local/bin/gridpulse grid_pulse@lists.arcs.org.au >/dev/null 2>&1

## Ggateway

Get and install the `Ggateway` package:

- Get the RPM from here: [http://projects.arcs.org.au/dist/production/5/i386/noarch/Ggateway-1.0.2-2.noarch.rpm](http://projects.arcs.org.au/dist/production/5/i386/noarch/Ggateway-1.0.2-2.noarch.rpm)
- Convert it with the `alien` tool to a Debian package (do not use the `--scripts` option), copy the Debian package to the host and install it.
- Copy the APAC job manager gateway script into the VDT setup


>  $ sudo cp /usr/local/src/pbs.pm.APAC /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm
>  **Edit the script **`/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm`** to suit the local setup (particularly the **`mpiexec`** invocation and the paths to the PBS "q**" tools, which are under `/usr/bin` for the Ubuntu packages):
>  BEGIN
>  {
>      $mpiexec = 'mpiexec';
>      $qsub =   '/usr/bin/qsub';
>      $qstat =  '/usr/bin/qstat';
>      $qdel = '/usr/bin/qdel';
>      $cluster = 1;
>      $cpu_per_node = 1;
>      $remote_shell = '/usr/bin/ssh';
>  }
>  $ sudo cp /usr/local/src/pbs.pm.APAC /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm
>  **Edit the script **`/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm`** to suit the local setup (particularly the **`mpiexec`** invocation and the paths to the PBS "q**" tools, which are under `/usr/bin` for the Ubuntu packages):
>  BEGIN
>  {
>      $mpiexec = 'mpiexec';
>      $qsub =   '/usr/bin/qsub';
>      $qstat =  '/usr/bin/qstat';
>      $qdel = '/usr/bin/qdel';
>      $cluster = 1;
>      $cpu_per_node = 1;
>      $remote_shell = '/usr/bin/ssh';
>  }

- Some further configuration for PBS may be necessary here. See: [Setting up an NG2/PBS specific parts](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setting%20up%20an%20NG2%2FPBS%20specific%20parts&linkCreation=true&fromPageId=3816950445)
- Add the installed `ggateway` packages to a line in the gridpulse checker configuration (`/usr/local/lib/gridpulse/system_packages.pulse`)

## Configure LRM log replication from LRM server to the NG2

See also [Setting up an NG2#Configure LRM log replication from LRM server to the NG2](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-ConfigureLRMlogreplicationfromLRMservertotheNG2).

## Configuring local scheduler access

See also [Setting up an NG2#Configuring local scheduler access](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-Configuringlocalscheduleraccess).

To link up the Torque/PBS log output to the local NG2, a "log sender" (`pbs-telltail`) on the Torque/PBS head node is required to pick up the logs and "send" them, and on the NG2 a local "log maker" (`pbs-logmaker`) is required.


**Note:** Using the Ubuntu Torque/PBS install, the PBS log is located under `/usr/spool/pbs/server_logs`.(The CentOS based BeSTGRID documentation uses `/usr/spool/PBS/server_logs`.)

# Installing VDT

See also [Setting up an NG2#Installing VDT](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-InstallingVDT).

Most of these steps are *much* more easily performed with a root shell. To obtain one use the following:

>  $ sudo su -

Following steps using a root shell use a preceding shell prompt "`#`".


> 1. mkdir -p /opt/vdt
> 1. mkdir -p /opt/vdt

- Download and setup `pacman` (the packager used)


> 1. cd /opt/vdt
> 2. wget [http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz](http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz)
> 3. tar xfz pacman-latest.tar.gz
> 4. cd pacman-3.29 && source setup.sh && cd ..
>  **Install Grid tools from VDT (*Note:** It is *very* important to use the `-pretend-platform` switch at the first usage of `pacman`. For Ubuntu Karmic (9.10) and Lucid (10.04) "Debian-5" worked well.)
> 5. cd /opt/vdt
> 6. export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
> 7. pacman -pretend-platform Debian-5 -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4 $VDTMIRROR:Globus-WS-PBS-Setup
> 8. # To also get the recommended packages for the install:
> 9. pacman -get $VDTMIRROR:VOMS-Client $VDTMIRROR:MyProxy-Client $VDTMIRROR:UberFTP $VDTMIRROR:Globus-Base-SDK $VDTMIRROR:GSIOpenSSH
> 1. cd /opt/vdt
> 2. wget [http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz](http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz)
> 3. tar xfz pacman-latest.tar.gz
> 4. cd pacman-3.29 && source setup.sh && cd ..
>  **Install Grid tools from VDT (*Note:** It is *very* important to use the `-pretend-platform` switch at the first usage of `pacman`. For Ubuntu Karmic (9.10) and Lucid (10.04) "Debian-5" worked well.)
> 5. cd /opt/vdt
> 6. export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
> 7. pacman -pretend-platform Debian-5 -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4 $VDTMIRROR:Globus-WS-PBS-Setup
> 8. # To also get the recommended packages for the install:
> 9. pacman -get $VDTMIRROR:VOMS-Client $VDTMIRROR:MyProxy-Client $VDTMIRROR:UberFTP $VDTMIRROR:Globus-Base-SDK $VDTMIRROR:GSIOpenSSH

- Make the environment variable setup script created by VDT load in the default profile


> 1. ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
> 2. . /etc/profile
> 1. ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
> 2. . /etc/profile


>  service gsiftp
>  {
>      socket_type = stream
>      protocol    = tcp
>      wait        = no
>      user        = root
>      instances   = UNLIMITED
>      cps         = 400 10
>      server      = /opt/vdt/vdt/services/vdt-run-gsiftp.sh
>      disable     = no
>  }
>  service gsiftp
>  {
>      socket_type = stream
>      protocol    = tcp
>      wait        = no
>      user        = root
>      instances   = UNLIMITED
>      cps         = 400 10
>      server      = /opt/vdt/vdt/services/vdt-run-gsiftp.sh
>      disable     = no
>  }

# Post-install configuration

Follow all steps according to [Setting up an NG2#Post-install configuration](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-Post-installconfiguration).

# Setup job reporting

Follow all steps according to [Setting up an NG2#Setup job reporting](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-Setupjobreporting).

# Setup MDS/MIP

See also [Setting up an NG2#Setup MDS/MIP](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-SetupMDS/MIP).

The steps described here approach the configuration of the MIP script in a slightly different manner than the NG2 install guide. Here, we are following the steps given in the ARCS documentation, by installing the `APAC-mip-module-py-config` package, and then configuring a "master configuration Perl script" (`/usr/local/mip/config/apac_py/mip-config.pl`). The complete MIP configuration then should be generated through this script without manual touchups necessary. It has worked, but the approach seems a bit "filthy" to me. But hey, you make a choice and try it out. Here is the link to the ARCS documentation in question: [https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/InstallConfigSteps](https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/InstallConfigSteps)

## Install/Configure

- Install the `python-lxml` Ubuntu package.
- Get the RPM packages `APAC-mip`, `APAC-mip-module-py`, `APAC-mip-globus`, `APAC-mip-module-py-config` and `APAC-glue-schema` in their latest version from: [http://projects.arcs.org.au/dist/production/5/i386/noarch/](http://projects.arcs.org.au/dist/production/5/i386/noarch/)
- Convert them with the `alien` tool to a Debian package (do not use the `--scripts` option), copy the Debian package to the host and install them.Packages: `apac-mip`, `apac-mip-module-py`, `apac-mip-globus` and `apac-glue-schema`
- Add the installed packages to a line in the gridpulse checker configuration (one per line, use the Debian package name): `/usr/local/lib/gridpulse/system_packages.pulse`
- Correct the script `/usr/local/mip/mip` according to the following diff:


>  — mip~        2008-01-24 18:50:12.000000000 +1300
>  +++ mip 2010-05-25 16:00:58.789952820 +1200
>  @@ -1,12 +1,12 @@
>   #!/bin/bash
>   LANG=C
>  -. /usr/local/osg/setup.sh
>  -cd /home/eshook/Projects/MIP/mip
>  +export PYTHONPATH="/usr/local/mip/modules/apac_py:$PYTHONPATH"
>  +cd /usr/local/mip
>   if [\! -z "$1"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%5C%21%20-z%20%22%241%22&linkCreation=true&fromPageId=3816950445); then
>      if ["$1" h1. "-remote"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22%241%22%20h1.%20%22-remote%22&linkCreation=true&fromPageId=3816950445); then
> - ./mip-remote.pl /home/eshook/Projects/MIP/mip/config
>  +      ./mip-remote.pl /usr/local/mip/config
>      elif ["$1" "-int" -o "$1" h1. "-integrator"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22%241%22%20%22-int%22%20-o%20%22%241%22%20h1.%20%22-integrator%22&linkCreation=true&fromPageId=3816950445); then
> - ./integrator.pl /home/eshook/Projects/MIP/mip/config
>  +      ./integrator.pl /usr/local/mip/config
>      else
>         ./mip.pl $1
>      fi
>  — mip~        2008-01-24 18:50:12.000000000 +1300
>  +++ mip 2010-05-25 16:00:58.789952820 +1200
>  @@ -1,12 +1,12 @@
>   #!/bin/bash
>   LANG=C
>  -. /usr/local/osg/setup.sh
>  -cd /home/eshook/Projects/MIP/mip
>  +export PYTHONPATH="/usr/local/mip/modules/apac_py:$PYTHONPATH"
>  +cd /usr/local/mip
>   if [\! -z "$1"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%5C%21%20-z%20%22%241%22&linkCreation=true&fromPageId=3816950445); then
>      if ["$1" h1. "-remote"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22%241%22%20h1.%20%22-remote%22&linkCreation=true&fromPageId=3816950445); then
> - ./mip-remote.pl /home/eshook/Projects/MIP/mip/config
>  +      ./mip-remote.pl /usr/local/mip/config
>      elif ["$1" "-int" -o "$1" h1. "-integrator"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22%241%22%20%22-int%22%20-o%20%22%241%22%20h1.%20%22-integrator%22&linkCreation=true&fromPageId=3816950445); then
> - ./integrator.pl /home/eshook/Projects/MIP/mip/config
>  +      ./integrator.pl /usr/local/mip/config
>      else
>         ./mip.pl $1
>      fi

- Generate and edit a MIP configuration file (see [Setting up an NG2#Configuring MIP](/wiki/spaces/BeSTGRID/pages/3816950633#SettingupanNG2-ConfiguringMIP) for further information on this):
	
- Check the MIP generated configuration file for the requirements `/usr/local/mip/config/apac_config.py`, and make sure the listed element names in `/usr/local/mip/config/default.pl` are matching!
- Continue configuring as described.
- Before testing, define the "default" location (with a sym link) and install MIP using the provided install script:


>  $ cd /usr/local/mip/modules
>  $ sudo ln -s apac_py default
>  $ cd ..
>  $ sudo ./install_mip
>  $ cd /usr/local/mip/modules
>  $ sudo ln -s apac_py default
>  $ cd ..
>  $ sudo ./install_mip


## Integrating MIP for Globus

See also these two resources:

- [https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/IntegrateGridAusInfoServiceProvider](https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/IntegrateGridAusInfoServiceProvider)

The "boiled down" instructions:

- In this case of the stream of these instructions `$GLOBUS_LOCATION` is `/opt/vdt/globus`
- Activate the Globus integration of MIP


>  $ sudo /usr/local/mip/config/globus/mip-globus-config -l /opt/vdt/globus install
>  $ sudo /usr/local/mip/config/globus/mip-globus-config -l /opt/vdt/globus install

- Restart the Globus service

## Testing MDS

