# Setup AUT NG2

This page documents the setup of the NG2 grid gateway at AUT.

The installation follows the guide at [https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2](https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2)

This page documents only the interesting parts.

# Linking NG2 into the Nautilus cluster

- mount home directories from Nautilus on NG2

- manually create grid-bestgrid, grid-admin and grid-cloud accounts on NG2

- add ng2.aut.ac.nz to /etc/hosts.equiv on nautilus headnode

- configure all Nautilus nodes to use "cp" instead of "scp" to deliver output files: add the following line to `/var/spool/torque/mom_priv/config`:

``` 
$usecp *:/home /home
```

- Configure PBS log replication from Nautilus to NG2
	
- Install pbs-telltail on Nautilus
- Start pbs-logmaker on NG2

# Install Globus

- Create /opt/vdt and install Pacman


>  mkdir -p /opt/vdt
>  cd /opt/vdt
>  wget [http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz](http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz)
>  tar xf pacman-*.tar.gz
>  cd pacman-*/ && source setup.sh && cd ..
>  mkdir -p /opt/vdt
>  cd /opt/vdt
>  wget [http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz](http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz)
>  tar xf pacman-*.tar.gz
>  cd pacman-*/ && source setup.sh && cd ..

Install Globus into /opt/vdt

>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_1101_cache](http://vdt.cs.wisc.edu/vdt_1101_cache)
>  pacman -get $VDTMIRROR:Globus-WS $VDTMIRROR:PRIMA-GT4 $VDTMIRROR:Globus-WS-PBS-Setup

# Configure Globus

- Do all configuration edits as documented at [https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2](https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2)

- Install IGTF certificates bundle as documented in /opt/vdt/post-install/README

>  ***Important**: enable GridFTP in tcp_wrap: add the following to /etc/hosts.allow
>  vdt-run-gsiftp.sh: ALL

# Install MDS/MIP

Follow [https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/InstallConfigSteps](https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/InstallConfigSteps)

- Install MIP


>  yum install APAC-mip-module-py
>  yum install APAC-mip-module-py

- Edit /usr/local/mip/config/apac_config.py
	
- Fill in Site informationas reasonable.
- Define compute element `workq`
- Manually define CPU, Memory and OS properties - they are different for Nautilis nodes and for NG2
- Define VOView and StorageArea elements for BeSTGRID, NGAdmin and Cloud VOs.

- Create /usr/local/mip/config/default_sub1_SIP.ini

``` 

[source2]
uri: file:softwareInfoData/localSoftware-nautilus.xml
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

- Create local software configuration


>  cd /usr/local/mip/modules/apac_py/SubCluster/softwareInfoData
>  cp localSoftware.xml localSoftware-nautilus.xml 
>  cd /usr/local/mip/modules/apac_py/SubCluster/softwareInfoData
>  cp localSoftware.xml localSoftware-nautilus.xml 

- Define software packages in /usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/localSoftware-nautilus.xml

- Define the MIP elements produced locally in `/usr/local/mip/config/default.pl`:

``` 

  clusterlist => ['default'],
  uids =>  {
    Site => [ "aut.ac.nz", ],
    SubCluster => [ "sub1", ],
    Cluster => [ "cluster1", ],
    ComputingElement => [ "compute1", ],
    StorageElement => [ "ng2.aut.ac.nz", ],
  }


```

- Activate MIP in Globus


>  yum install APAC-mip-globus
>  yum install APAC-mip-globus

- Secure your MDS - so that it's not open to the world for writing.  This contents would get posted to the central index.
	
- Create empty `/etc/grid-security/mds-grid-mapfile`: 

``` 
touch /etc/grid-security/mds-grid-mapfile
```
- The rest has been done by the APAC-mip-globus install scriptlet (editing `/opt/vdt/globus/etc/globus_wsrf_mds_index/index-security-config.xml` and `/opt/vdt/globus/etc/globus_wsrf_mds_index/server-config.wsdd`)

>  **Disable auto-registration of RFT and GRAM services - they won't be able to authenticate now and we don't want them in the central index.  Edit **`/opt/vdt/globus/etc/gram-service/jndi-config.xml`** and **`/opt/vdt/globus/etc/globus_wsrf_rft/jndi-config.xml`** and set the*reg** parameter to `false`.

- Restart globus


>  service globus-ws stop
>  service globus-ws start
>  service globus-ws stop
>  service globus-ws start

# Polishing Globus

- Make Globus publish hostname (and not IP address) in URLs: edit /opt/vdt/globus/etc/globus_wsrf_core/server-config.wsdd and add the following line at the start of the `GlobalConfiguration` element (formerly, this was done by the build script)

- Fix startup and shutdown of gateway services for MySQL and Globus-WS

1. To start in this order
2. To shutdown in reverse order
3. To create a lock in /var/lock/subsys when started - so that a system shutdown knows to close down these services gracefully.

See my description of the [problem](/wiki/spaces/BeSTGRID/pages/3816950583#Vladimir&#39;sgridnotes-RFTstagingfails), a fix to [startup order](/wiki/spaces/BeSTGRID/pages/3816950583#Vladimir&#39;sgridnotes-Fixingstartuporder), and a fix for [correct shutdown](/wiki/spaces/BeSTGRID/pages/3816950583#Vladimir&#39;sgridnotes-Fixingshutdown)

# Install SLCS certificates

- As documented at [http://wiki.arcs.org.au/bin/view/Main/SLCS](http://wiki.arcs.org.au/bin/view/Main/SLCS)

# Install job audit extensions

- Download the AddAudit script from [https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2](https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2)


>  cd /usr/local/bin 
>  wget [http://projects.arcs.org.au/trac/systems/raw-attachment/wiki/HowTo/InstallNg2/AddAuditNg2Vdt1101y.sh](http://projects.arcs.org.au/trac/systems/raw-attachment/wiki/HowTo/InstallNg2/AddAuditNg2Vdt1101y.sh)
>  cd /usr/local/bin 
>  wget [http://projects.arcs.org.au/trac/systems/raw-attachment/wiki/HowTo/InstallNg2/AddAuditNg2Vdt1101y.sh](http://projects.arcs.org.au/trac/systems/raw-attachment/wiki/HowTo/InstallNg2/AddAuditNg2Vdt1101y.sh)

- Run the script


>  chmod +x AddAuditNg2Vdt1101y.sh 
>  /AddAuditNg2Vdt1101y.sh
>  chmod +x AddAuditNg2Vdt1101y.sh 
>  /AddAuditNg2Vdt1101y.sh

- Restart globus

# PBS.pm

Install customized pbs.pm into /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager

See [Canterbury NG2 installation](/wiki/spaces/BeSTGRID/pages/3816950735) and [Canterbury gateway enhancements for a list of features](/wiki/spaces/BeSTGRID/pages/3816950953).

- Retrieving User DN from early audit database - needs `GetJobDN.sh` script + sudo access in /etc/sudoers:

``` 
ALL ALL=(daemon)               NOPASSWD: /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/GetJobDN.sh *
```
- Logging job submission: create /opt/vdt/globus/var/pbs-acct/jobdn-subm.log
- Remove feature: don't need a hack used at Canterbury, it's OK to pass the task count as nodes=n


>  lamclean
>  lamhalt -H
>  lamclean
>  lamhalt -H

# Job Accounting

On Nautilus, install /usr/local/sbin/send_grid_usage (as documented at [https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2#AddAudit](https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNg2#AddAudit)) and launch it from a cron job in /etc/cron.d/send_grid_usage.cron containing:

>  3 1 * * * root /usr/local/sbin/send_grid_usage

- Edit the file to put "nautilus.aut.ac.nz NZ-AUT" into the subject line.

- This sends daily reports of grid jobs from /var/spool/torque/server_priv/accounting/ to the [GOC](http://status.arcs.org.au).

- Configure sendmail to send youtgoing mail: put the following into /etc/mail/mailertable


>  .       smtp:[ulduar.aut.ac.nz](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=ulduar.aut.ac.nz&linkCreation=true&fromPageId=3816950620)
>  .       smtp:[ulduar.aut.ac.nz](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=ulduar.aut.ac.nz&linkCreation=true&fromPageId=3816950620)

- And run


>  cd /etc/mail
>  make
>  service sendmail start
>  chkconfig --add sendmail
>  cd /etc/mail
>  make
>  service sendmail start
>  chkconfig --add sendmail

# TODO
