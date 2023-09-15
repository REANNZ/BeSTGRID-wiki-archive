# Configuring BeSTGRID systems to accept PRAGMA users

In PRAGMA grid, a VOMRS server will be used to manage user membership in groups corresponding to individual projects.

This page documents how to configure mappings from the VOMRS project groups to local accounts on a grid gateway.

This page documents two alternative methods: either using a `edg-mkgridmap` to generate a `grid-mapfile`, or using a callout to a GUMS server.

This page assumes that the [PRAGMA CAs](configuring-a-vdt-system-to-include-pragma-cas-when-updating-igtf-ca-bundle.md) are already installed on the grid gateway (and also by the GUMS server if used).

# Configuring edg-mkgridmap

Configuring mappings with edg-mkgridmap is easier to configure (and easier to merge with existing manual mappings).  However, each user is confined to only a single mapping, even if being a member of multiple project groups.  As an alternative solution, a GUMS server allows a user to choose each time which project group membership should be used in the mapping.

## Installing edg-mkgridmap

edg-mkgridmap is a program that can generate the `/etc/grid-security/grid-mapfile` file based on information from a number of sources, including VOMS servers and a list of local mappings.

Depending on the system, one may choose multiple ways to install edg-mkgridmap.

For VDT-based systems, one would install and start edg-mkgridmap just with:

>  pacman -pretend-platform linux-rhel-4 -get [http://vdt.cs.wisc.edu/vdt_1100_cache:EDG-Make-Gridmap](http://vdt.cs.wisc.edu/vdt_1100_cache:EDG-Make-Gridmap)
>  vdt-control --on edg-mkgridmap # this enables cron job

One might also install from an RPM package.  The following steps were necessary to install edg-mkgridmap on a CentOS-4 system.  Similar steps should work on other RedHat-based system (or Scientific Linux), with possibly slightly different packages needed for dependencies.

- As recommended by [VDT edg-mkgridmap documentation](http://vdt.cs.wisc.edu/components/edg-mkgridmap.html), retrieve the edg-mkgridmap package from [http://eticssoft.web.cern.ch/eticssoft/repository/org.glite/edg-mkgridmap/](http://eticssoft.web.cern.ch/eticssoft/repository/org.glite/edg-mkgridmap/) - files `edg-mkgridmap-3.0.0-1.noarch.rpm` and `edg-mkgridmap-conf-3.0.0-1.noarch.rpm`.


>  ***Important Note (2008-07-17)**: use version at least 3.0.0 (from  to interact with VOMSAdmin 2.0 services, used at the PRAGMA VOMRS server.
>  ***Important Note (2008-07-17)**: use version at least 3.0.0 (from  to interact with VOMSAdmin 2.0 services, used at the PRAGMA VOMRS server.

- Install dependencies


>  yum install perl-Crypt-SSLeay perl-DateManip perl-LDAP perl-URI perl-libwww-perl perl-libxml-enno
>  yum install perl-Crypt-SSLeay perl-DateManip perl-LDAP perl-URI perl-libwww-perl perl-libxml-enno

- Install additional dependencies from the addons repository


>  yum --enablerepo=addons --enablerepo=extras install perl-IO-Socket-SSL perl-Net-SSLeay
>  yum --enablerepo=addons --enablerepo=extras install perl-IO-Socket-SSL perl-Net-SSLeay


>  rpm -Uvh edg-mkgridmap-3.0.0-1.noarch.rpm edg-mkgridmap-conf-3.0.0-1.noarch.rpm
>  rpm -Uvh edg-mkgridmap-3.0.0-1.noarch.rpm edg-mkgridmap-conf-3.0.0-1.noarch.rpm

## Configuring edg-mkgridmap

The configuration files will be either in `/opt/edg/etc`

- Create edg-mkgridmap configuration: edit `/opt/edg/etc/edg-mkgridmap.conf` and allow all the groups your gateway should allow - so far, for PRAGMA it's

``` 

group vomss://vomrs-pragma.sdsc.edu:8443/voms/PRAGMA?/PRAGMA/Avian-Flu-Grid grid-afu
group vomss://vomrs-pragma.sdsc.edu:8443/voms/PRAGMA?/PRAGMA/USERS grid-pgu

gmf_local /opt/edg/etc/grid-mapfile-local

```
- Create empty `/opt/edg/etc/grid-mapfile-local` - or populate with your existing `/etc/grid-security/grid-mapfile`


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

- Setup a cron job to run edg-mkgridmap periodically: as root, run `crontab -e` and put the following entries into the crontab:


>  41 3,9,15,21 * * * /opt/edg/sbin/edg-mkgridmap --output=/etc/grid-security/grid-mapfile >> /opt/edg/log/edg-mkgridmap.log 2>&1
>  41 3,9,15,21 * * * /opt/edg/sbin/edg-mkgridmap --output=/etc/grid-security/grid-mapfile >> /opt/edg/log/edg-mkgridmap.log 2>&1

# Installing and configuring PRIMA

## PRIMA for GT4

I assume you already have Globus configured and I assume you've installed from VDT.  In that case, you can install PRIMA from VDT as well and configure it to use a GUMS server.

For Globus Toolkit 4, the command to install PRIMA would be

>  pacman -pretend-platform linux-rhel-4 -get [http://vdt.cs.wisc.edu/vdt_1100_cache:PRIMA-GT4](http://vdt.cs.wisc.edu/vdt_1100_cache:PRIMA-GT4)

and the command to enable PRIMA and make it use your GUMS server would be

>   /opt/vdt/vdt/setup/configure_prima_gt4 --enable --gums-server $Gums_Server

This installs and configures libraries both for GT4 and GT2 (including the PRIMA package described below).

For more information, please refer to the [VDT configure_prima_gt4 documentation](http://vdt.cs.wisc.edu/releases/1.10.1/config/configure_prima_gt4.html).

## PRIMA for GT2

For Globus Toolkit 2, the command to install PRIMA would be

>  pacman -pretend-platform linux-rhel-4 -get [http://vdt.cs.wisc.edu/vdt_1100_cache:PRIMA](http://vdt.cs.wisc.edu/vdt_1100_cache:PRIMA)

and the command to enable PRIMA SHOULD BE

>   /opt/vdt/vdt/setup/configure_prima

I have not been configuring prima for GT2 - please see the [VDT configure_prima documentation](http://vdt.cs.wisc.edu/releases/1.10.1/config/configure_prima.html) - and please post back and experience you have with this.

The steps you'd likely have to do would be:

1. Edit `/opt/vdt/post-install/prima-authz.conf` and change the hostname on the `imsContact` line from your gateway's name to the hostname of your GUMS server.
2. Copy `/opt/vdt/post-install/gsi-authz.conf` and `/opt/vdt/post-install/prima-authz.conf` to `/etc/grid-security`.

When installing both PRIMA and PRIMA-GT4, the `configure_prima_gt4` script will correctly configure the PRIMA libraries for both GT4 and GT2 and the above steps are not necessary.

# Configuring GUMS

The main advantage of a GUMS server is that it allows a user to choose each time which project group membership should be used in the mapping - or whether to map to a local account instead, if the user has one.

Other pages already document detailed instructions on how to [setup a GUMS server](setup-nggums-at-university-of-canterbury.md), and how to [configure local account mappings](/wiki/spaces/BeSTGRID/pages/3818228894).

Assuming a GUMS server is already setup, and the Globus on the grid gateway is configured to ask the GUMS server with user authorization requests via the PRIMA call-outs, the following will configure the GUMS server to accept the PRAGMA user mappings:

- Configure the GUMS server to talk to PRAGMA VOMRS server (note: the GUMS server must trust the PRAGMA VOMS server certificate, issued by the PRAGMA CA, included in the IGTF bundle since release 1.24):


>  VOMS Server: PRAGMA
>  Description: PRAGMA VOMS SERVER
>  Base URL: https://vomrs-pragma.sdsc.edu:8443/voms\{remainder url}
>  Persistence Factory: mysql 
>  SSL key: /etc/grid-security/http/httpkey.pem
>  SSL Cert File: /etc/grid-security/http/httpcert.pem
>  SSL CA Files: /etc/grid-security/certificates/*.0
>  VOMS Server: PRAGMA
>  Description: PRAGMA VOMS SERVER
>  Base URL: https://vomrs-pragma.sdsc.edu:8443/voms\{remainder url}
>  Persistence Factory: mysql 
>  SSL key: /etc/grid-security/http/httpkey.pem
>  SSL Cert File: /etc/grid-security/http/httpcert.pem
>  SSL CA Files: /etc/grid-security/certificates/*.0

- Create VOMS user groups for the PRAGMA VOs supported - example here is for /PRAGMA/USERS and /PRAGMA/Avian-Flu-Grid


>  VOMS User Group:  PRAGMA USERS
>  Description: PRAGMA USERS
>  VOMS Server: PRAGMA
>  URL: {base url}/PRAGMA/services/VOMSAdmin
>  Accept non-VOMS certificates: true
>  VOMS certificate's FQAN is matched as: vogroup
>  VO/Group: /PRAGMA/USERS
>  GUMS Access: read self
>  VOMS User Group:  PRAGMA USERS
>  Description: PRAGMA USERS
>  VOMS Server: PRAGMA
>  URL: {base url}/PRAGMA/services/VOMSAdmin
>  Accept non-VOMS certificates: true
>  VOMS certificate's FQAN is matched as: vogroup
>  VO/Group: /PRAGMA/USERS
>  GUMS Access: read self

 VOMS User Group:  PRAGMA Avian-Flu-Grid

>  Description: PRAGMA Avian Flu Grid Group
>  VOMS Server: PRAGMA
>  URL: {base url}/PRAGMA/services/VOMSAdmin
>  Accept non-VOMS certificates: true
>  VOMS certificate's FQAN is matched as: vogroup
>  VO/Group: /PRAGMA/Avian-Flu-Grid
>  GUMS Access: read self

- Create *Group account mappers* for each of the the VOS.  There should be a local account created for each of the groups, and each group account mapper should map to a single account.

>  Group Account Mapper:  PRAGMAAvianFluGridHPCAccountMapper
>  Description: PRAGMA Avian-Flu-Grid HPC AccountMapper
>  Account: grid-afu

 Group Account Mapper: PRAGMAUsersHPCAccountMapper

>  Description: PRAGMA Users HPC AccountMapper
>  Account: grid-pgu

- Now create *Group to account mappings* that would link the VO groups to their respective group account mappers:


>  Name:  PRAGMA Avian-Flu-Grid on HPC to grid-afu
>  Description: PRAGMA Avian-Flu-Grid on HPC to grid-afu
>  User Group: PRAGMA Avian-Flu-Grid
>  Account Mapper: PRAGMAAvianFluGridHPCAccountMapper	
>  Name:  PRAGMA Avian-Flu-Grid on HPC to grid-afu
>  Description: PRAGMA Avian-Flu-Grid on HPC to grid-afu
>  User Group: PRAGMA Avian-Flu-Grid
>  Account Mapper: PRAGMAAvianFluGridHPCAccountMapper	

 Name: PRAGMA Users on HPC to grid-pgu

>  Description: PRAGMA Users on HPC to grid-pgu
>  User Group: PRAGMA USERS
>  Account Mapper: PRAGMAUsersHPCAccountMapper

- Finally, add these two *Group to account mappings* to the Host to group mappings for your gateway:


>  Host to Group Mapping:  **hpc**.canterbury.ac.nz
>  Description: ng2hpc and hpcgrid1 (p520 GridFTP server)
>  Group To Account Mappings: ManualMapperHPC, ..., BeSTGRID on HPC to grid-bgd, **PRAGMA Avian-Flu-Grid on HPC to grid-afu, PRAGMA Users on HPC to grid-pgu**, NGAdmin on HPC to grid-adm
>  Host to Group Mapping:  **hpc**.canterbury.ac.nz
>  Description: ng2hpc and hpcgrid1 (p520 GridFTP server)
>  Group To Account Mappings: ManualMapperHPC, ..., BeSTGRID on HPC to grid-bgd, **PRAGMA Avian-Flu-Grid on HPC to grid-afu, PRAGMA Users on HPC to grid-pgu**, NGAdmin on HPC to grid-adm

# Installing VOMS-Client

In order for users to pick between differnt VOs they might be members of, they'd need to use `voms-proxy-init` (usage is documented below in [#Using the system](#ConfiguringBeSTGRIDsystemstoacceptPRAGMAusers-Usingthesystem).

In VDT, voms-proxy-init is included in the VOMS-Client package.  The command to install the `VOMS-Client` package on a VDT system would be:

>  pacman -pretend-platform linux-rhel-4 -get [http://vdt.cs.wisc.edu/vdt_1100_cache:VOMS-Client](http://vdt.cs.wisc.edu/vdt_1100_cache:VOMS-Client)

# Installing GsiSSH

GsiSSH allows users to log on to a SSH terminal session with their X509 credentials.

GsiSSH is available as an VDT package that can be installed with:

>  pacman -pretend-platform linux-rhel-4 -get [http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:GSIOpenSSH](http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:GSIOpenSSH)

After the pacman installation, `/opt/vdt/post-install/sshd` has to be installed as `/etc/rc.d/init.d/sshd` and modified to source the full VDT environment - see patch below.  After killing the old `sshd`, start the new sshd (`/opt/vdt/globus/sbin/sshd`) with `service sshd start`

``` 

--- /opt/vdt/post-install/sshd	2008-10-31 11:44:14.000000000 +1300
+++ /etc/rc.d/init.d/sshd	2008-10-31 14:01:03.000000000 +1300
@@ -18,6 +18,10 @@
 # Description: Start the sshd daemon
 ### END INIT INFO
 
+# extra: Vladimir Mencl
+VDT_LOCATION="/opt/vdt"
+. $VDT_LOCATION/setup.sh
+
 GLOBUS_LOCATION="/opt/vdt/globus"
 export GLOBUS_LOCATION
 

```

# Using the system

Now, users should be able to access the system with their grid certificate.

They may do a plain `grid-proxy-init` and start submitting the jobs immediately.

For the case of BeSTGRID HPC cluster at the University of Canterbury, it would be:

>  grid-proxy-init
>  GLOBUS_TCP_PORT_RANGE=40000,41000
>  export GLOBUS_TCP_PORT_RANGE
>  globusrun-ws -submit -s -F ng2hpc.canterbury.ac.nz -Ft Loadleveler -c /usr/bin/id

To pick between different group memberships and two request a specific mapping to the respective project account, users may create a voms-proxy instead:

- Create a *vomses* file for the PRAGMA VOMRS server:  `/opt/vdt/glite/etc/vomses/PRAGMA` containing


>  "PRAGMA" "vomrs-pragma.sdsc.edu" "15001" "/DC=NET/DC=PRAGMA-GRID/OU=SDSC/CN=vomrs-pragma.sdsc.edu" "PRAGMA" "https://vomrs-pragma.sdsc.edu:443/vomrs/PRAGMA/services/VOMRS?WSDL"
>  "PRAGMA" "vomrs-pragma.sdsc.edu" "15001" "/DC=NET/DC=PRAGMA-GRID/OU=SDSC/CN=vomrs-pragma.sdsc.edu" "PRAGMA" "https://vomrs-pragma.sdsc.edu:443/vomrs/PRAGMA/services/VOMRS?WSDL"

- Run


>  voms-proxy-init -voms PRAGMA -order /PRAGMA/USERS
>  voms-proxy-init -voms PRAGMA -order /PRAGMA/USERS

- or


>  voms-proxy-init -voms PRAGMA -order /PRAGMA/Avian-Flu-Grid
>  voms-proxy-init -voms PRAGMA -order /PRAGMA/Avian-Flu-Grid

Jobs submitted with a VOMS-proxy will then run under the account corresponding to the VO selected to be the first listed with the `-order` parameter.

Related: Configured [Tomcat on PRAGMA VOMRS server to accept proxies](configuring-pragma-vomrs-server-to-work-with-bestgrid.md), otherwise voms-proxy-init won't work.
