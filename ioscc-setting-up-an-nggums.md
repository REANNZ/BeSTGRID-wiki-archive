# IoSCC Setting up an NGGUMS

# WIP: For Demonstration Purposes Only: Do not use 

This'll be a modified version of Vlad's information that will 

tease out the commonality between it's NGGUMS-related info and 

that within the NG2-related page.

Most of the modifications arise from the IoSCC work looking

to map the current BeSTGRID landscape and provide a Q&A format

on top of the actual information itself, more specifically in

the first instance, the deployment of a BeSTGRID gateway to

an SGE compute cluster, operated by Landcare Research using

Rocks for teh sysadmin side.

Initially, this will be a straight cut and paste of the source

from Vlad's "Setting up a GUMS server" page

# Top of Vlad's stuff

A GUMS (Grid User Management System) server serves as authorization server for other systems in the Globus Toolkit based grid infrastructure, namely job submission gateways (NG2, NG1) and GridFTP servers (NG2, NG1, NGData). The GUMS server receives authorization requests from grid services each time an authorization decision or local account mapping has to be made, and decides based on the:

1. the distinguished name (DN) the user is passing in the certificate
2. VO information possibly embedded in the certificate
3. local server configuration
4. current group membership information from the VOMS server

Using a GUMS server will completely eliminate the need for and the use of the gridmap-file. The advantages of that are:

1. Centralized configuration: all the mapping configuration is in the single gums configuration file.
2. Up-to-date information: GUMS server decides based on the current information in the VOMS server, not the possibly outdated information in the gridmap-file.
3. Lower communication overhead: only the GUMS server needs to fetch information from the VOMS server, and the other virtual machines communicate directly with the GUMS server.

The installation is based on the [Virtual Data Tookit (VDT)](http://vdt.cs.wisc.edu/), at the time of writing, version 2.0.0.

The GUMS configuration mechanism is fairly flexible, and with multiple **HostGroup** elements, it is possible to specify different mappings for individual hosts (such as for multiple grid gateways for multiple clusters with different sets of accounts).(grid-bgd, grid-adm) on ng2hpc).

The installation is based on the [ARCS NgGums installation guide](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums), and adds some VDT 2.0 specific instructions (and refines the installation steps).

When users have personal accounts on the cluster and it's desired to let them access the personal accounts via the grid, then this installation should be followed by installing the AuthTool and the [Shibbolized AuthTool](deploying-shibbolized-authtool-on-a-gums-server.md).

# Prerequsites

## OS requirements

This guide assumes the system where GUMS will be installed has already been configured.

- Hardware requirements (VM configuration)
	
- Minimum: 512MB RAM, 1 CPU, 8GB filesystem, 1GB swap.

- OS: Linux CentOS 5 (or RHEL 5).  Other Linux distributions (or other operating systems) may work, please check the [VDT system requirements](http://vdt.cs.wisc.edu/releases/2.0.0/requirements.html).
	
- Both i386 (32-bit) and x86_64 (64-bit) distributions are supported.

>  **Hostname: it is recommended to use*nggums.*****your.site.domain***

- The system is setup to send outgoing email (i.e., typically, default SMTP relay would be set to the site's local SMTP server).
	
- Note: it is a requirement that the SMTP server does not overwrite the sender domain (in the From: address) - the domain must stay as the full hostname.

- The system is configured for time synchronization with a reliable time source.

- If the GUMS server will be setup with support for mapping users to their local personal accounts, the OS *should* be configured to recognize the accounts local accounts (e.g., via the appropriate PAM module).  But this is not a hard requirement and can be worked around later

## Network requirements

- The server needs a public IP address.
- The hostname must resolve to this IP address and the IP address must resolve back to the system's hostname.
- The server needs to be able to open outgoing TCP connections to ports 80, 443, 8443.
	
- The traffic to ports 80 and 443 MAY go through a proxy (if the `http_proxy environment` variable is properly set), but port 8443 traffic must be a direct connection.
- If setup with the Auth Tool, the server also needs to accept incoming TCP connections on ports 443 and 8443.

## Certificates

In order to operate the host machine within ARCS, there are requirements to:

>  ***install the ARCS SLCS1 CA bundle**
>  ***install a host certificate** for this system
>  ***install a copy of the host certificate** for use by GUMS

### ARCS SLCS1 CA bundle

Based on the instructions at [http://wiki.arcs.org.au/bin/view/Main/SLCS](http://wiki.arcs.org.au/bin/view/Main/SLCS)

The `ARCS SLCS1 CA` bundle needs to be installed on top of the **IGTF Global** bundle (this includes the `APACGrid CA`) that will be installed through tools within the VDT.

The VDT CA setup process will overwrite any certificates that have been added so we can just download the `ARCS SLCS1 CA` bundle

- If no other software has created the directory `/etc/grid-security` then it needs to be created

``` 

mkdir -p /etc/grid-security
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security

```

- Get the ARCS SLCS1 CA bundle and extract it into `/etc/grid-security` (creates `arcs-slcs-ca` subdirectory)
	
- The files should be owned by root

``` 

cd /etc/grid-security  
wget --no-check-certificate https://slcs1.arcs.org.au/arcs-slcs-ca.tar.gz -O - | tar xvz  
chown -R root:root /etc/grid-security/arcs-slcs-ca

```

The installed files should be similar (identical ??) to these

``` 

ls -l /etc/grid-security/arcs-slcs-ca/
-rw-r--r-- 1 root root 1996 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.0
-rw-r--r-- 1 root root  217 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.namespaces
-rw-r--r-- 1 root root  193 Mar  5 16:00 /etc/grid-security/arcs-slcs-ca/1ed4795f.signing_policy

```

### Host Certificate

If a **host certificate** has not already been installed on the system then  **obtain a host certificate** for this system from the [APACGrid CA](http://wiki.arcs.org.au/bin/view/Main/HostCertificates)

- If no other software has created the directory `/etc/grid-security` then it needs to be created

``` 

mkdir -p /etc/grid-security/
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security

```

- Install the certificate and private key as `/etc/grid-security/hostcert.pem` and `/etc/grid-security/hostkey.pem` respectively
	
- The files should be owned by root
- The private key should be readable only to root

``` 

ls -l /etc/grid-security/host* /etc/grid-security/irods*
-rw-r--r-- 1 root   root   2634 Mar 13  2009 /etc/grid-security/hostcert.pem
-rw------- 1 root   root   1675 Mar 13  2009 /etc/grid-security/hostkey.pem

```

### Host Certificate Copies for NGGUMS

- Install a copy of the certificate and the private key as `/etc/grid-security/http/httpcert.pem` and `/etc/grid-security/http/httpkey.pem` respectively
	
- The files should be owned by daemon
- The private key should be readable only to daemon

``` 

ls -l /etc/grid-security/host* /etc/grid-security/http/http*
-rw-r--r-- 1 root   root   2634 Mar 13  2009 /etc/grid-security/hostcert.pem
-rw------- 1 root   root   1675 Mar 13  2009 /etc/grid-security/hostkey.pem
-rw-r--r-- 1 daemon daemon 2634 Mar 13  2009 /etc/grid-security/http/httpcert.pem
-rw------- 1 daemon daemon 1675 Mar 13  2009 /etc/grid-security/http/httpkey.pem

```

>  **If setting up the Auth Tool,*get a "commercial" certificate** that would be trust in major browsers.  This may depend on your site's policies and supplier preferences - just follow them, there's nothing special about this certificate, it only has to be trusted by browsers.

## External Software

Setting up this server will require us to install software, from both the ARCS repository,

using `yum`, and from a VDT mirror, using `pacman`.

- Configure ARCS RPM repository

``` 
cd /etc/yum.repos.d && wget http://projects.arcs.org.au/dist/arcs.repo
```
- Note: on a 64-bit system, change the repository file to use ARCS i386 repository itself (the ARCS 64-bit repository is not populated).  I.e., change the `baseurl` for the *arcs* repository in `/etc/yum.repos.d/arcs.repo` to: 

``` 
baseurl=http://projects.arcs.org.au/dist/production/$releasever/i386
```

- Download and setup pacman

``` 

mkdir /opt/vdt
cd /opt/vdt
wget http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz
tar xf pacman-*.tar.gz
cd pacman-*/ && source setup.sh && cd ..

```

- Set an environmental variable for the VDTMIRROR that will be used

All of the instructions below should ensure the following environmental variable is set,

ahead of any `pacman` operations.

``` 
export VDTMIRROR=http://vdt.cs.wisc.edu/vdt_200_cache
```

# Preparing the installation

## Prerequisites

- Install the ARCS system monitoring tool GridPulse


>  yum install APAC-gateway-gridpulse
>  yum install APAC-gateway-gridpulse

## VDT components

- Required packages:
- ***GUMS** - GUMS is a self contained package

**Q** Why are there no recommeded packages for the GUMS server- can it not be used as a grid client for testing ?

>  **Recommended packages:**?*

- ***GSIOpenSSH** - GSI-enabled ssh server and client

## Installing VDT components

- If you do not have `pacman` setup, for example, you are returning to a partially installed system, you may need to set it up again

>  source /opt/vdt/pacman-*/setup.sh

- Assuming you have `pacman` setup for the current session

>  cd /opt/vdt
>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)

- Prepare and run the installation command-line: Start with {{pacman -get }} and add each package prefixed by '$VDTMIRROR:'

- The base system for a GUMS server merely require the GUMS package


>  pacman -get $VDTMIRROR:GUMS
>  pacman -get $VDTMIRROR:GUMS

- Wait about a minute or two for the installer to prompt you to agree to licenses.
- Have a cup of coffee - the download and installation may take 15-30 minutes.

- Make the environment variable setup script created by VDT load in the default profile


>  cp /opt/vdt/setup.sh  /etc/profile.d/vdt.sh
>  cp /opt/vdt/setup.csh /etc/profile.d/vdt.csh
>  . /etc/profile.d/vdt.sh
>  cp /opt/vdt/setup.sh  /etc/profile.d/vdt.sh
>  cp /opt/vdt/setup.csh /etc/profile.d/vdt.csh
>  . /etc/profile.d/vdt.sh

## Post-install VDT configuration

### Configure VDT certificate distribution

Certificate-based grid security with BeSTGRID relies upon the APACGrid CA.

The APACGrid CA is part of a global certificate distribution maintained by the IGTF.

VDT comes with a tool to download and update a certificate distribution, but requires the user to make an (informed) choice on which certificate distribution to trust.  The VDT team is also creating a convenient distribution based on IGTF - but we do need to configure this tool to point to this distribution.

- Run the following command to select the VDT distribution and install it into /etc/grid-security/certificates

``` 
vdt-ca-manage setupca --location root --url vdt
```
- Note: behind the scenes, the tool will
		
- Backup and rename any exsting /etc/grid-security/certificates
- Add the following line to $VDT_LOCATION/vdt/etc/vdt-update-certs.conf: 

``` 
cacerts_url = http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version
```

- Note: Other installation notes can suggest getting the APACGrid CA Cert directly, eg 

``` 
wget https://ca.apac.edu.au/pub/cacert/cacert.crt
```
- However the APACGrid CA Cert is this one from the IGTF bundle 

``` 
/etc/grid-security/certificates/1e12d831.0
```

In order to have the ARCS SLCS1 CA bundle available we need to copy that bundle into the main certificates directory

and ensure that VDT includes those files in any subsequent updates:

- Copy the ARCS SLCS1 CA bundle files into `/etc/grid-security/certificates`

``` 

 cd /etc/grid-security/arcs-slcs-ca 
 cp * /etc/grid-security/certificates  

```


## Set ServerName in Apache

In order to prevent Apache from throwing warnings like:

>  [23:47 2010] [warn] RSA server certificate CommonName (CN) `my.server.name' does NOT match server name!?

Server Name has to be set appropriately in `/opt/vdt/apache/conf/extra/httpd-ssl.conf` and `/opt/vdt/apache/conf/httpd.conf`, locate the `ServerName` entry in the file and change it to match the CN used in the certificate request.

## MOD_SSL Bug

- There is a bug in the mod_ssl Apache module bundled with VDT: Apache locks up when it's supposed to prompt user for a certificate.  Apache somehow cannot handle more then 90 CA names to be passed in the list - and it would be by default listing all CAs found in the `/etc/grid-security/certificates` directory.
- A workaround for this bug is to change Apache config to only pass selected CA names in the prompt for a client certificate: the APACGrid CA and ARCS SLCS1 CA.

- Download a certificate bundle only listing the APACGrid CA and the ARCS SLCS1 CA


>  wget -O /etc/grid-security/arcs-bundle.crt [http://staff.vpac.org/~sam/arcs-bundle.crt](http://staff.vpac.org/~sam/arcs-bundle.crt)
>  wget -O /etc/grid-security/arcs-bundle.crt [http://staff.vpac.org/~sam/arcs-bundle.crt](http://staff.vpac.org/~sam/arcs-bundle.crt)

- Edit the VDT Apache configuration file `/opt/vdt/apache/conf/extra/httpd-ssl.conf` and add the following line (below the `SSLCACertificatePath` line):

``` 
SSLCADNRequestFile /etc/grid-security/arcs-bundle.crt
```
- Note: this is slightly different from the ARCS instructions to comment out the `SSLCACertificatePath` line and instead put in `SSLCACertificateFile /etc/grid-security/arcs-bundle.crt`.  The ARCS solution tells Apache to only trust 2 certification authorities - and Apache then returns their names in the SSL client certificate prompt.  This solution instead leaves Apache to trust the whole /etc/grid-security/certificates directory, and only tells Apache to send a restricted set of CA names in the SSL prompt.  Works around the bug as well and preserves the trust for other CAs.  Even though they do not get included in the prompt, they are still trusted - and that might possibly help a user with a foreign grid certificate access our system.

>  **For completeness: original ARCS instructions were (*DO NOT IMPLEMENT THIS** if you have implemented the SSLCADNRequestFile option above)

- 
- Comment out: 

``` 
#SSLCACertificatePath /opt/vdt/globus/TRUSTED_CA
```
- Add: 

``` 
SSLCACertificateFile /etc/grid-security/arcs-bundle.crt
```

# Post-install configuration

## Turn VDT services on

- Mark all services as enabled:

``` 

vdt-control --enable fetch-crl
vdt-control --enable vdt-rotate-logs
vdt-control --enable vdt-update-certs
vdt-control --enable apache
vdt-control --enable tomcat-55
vdt-control --enable mysql5
vdt-control --enable gums-host-cron

```
- Turn all services on


>  vdt-control --on
>  vdt-control --on

## GUMS Administrator

Add yourself as an administrator of the GUMS server.  

- You will need to know your exact DN in your user certificate.  If you have your user certificate on a Linux (or Mac) system, you may find the DN with: 

``` 
openssl x509 -subject -noout -in ~/.globus/usercert.pem
```
- Add yourself as an admin with the following command (passing your DN as the argument)

``` 
/opt/vdt/tomcat/v55/webapps/gums/WEB-INF/scripts/gums-add-mysql-admin "/C=NZ/O=BeSTGRID/OU=your institution/CN=your name"
```

**KMB Note** I did not have my user cert on this machine.

## Set MySQL root password

Change the MySQL root password to a password of your choice. For this issue the following on the command line with the `mysql` client:

>  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('secret-password');
>  SET PASSWORD FOR 'root'@'gums.otago.ac.nz' = PASSWORD('secret-password');

**Note:** Do not forget to remove the `~/.mysql_history` file afterwards to remove readable clear text traces of the password

## Adjust GUMS-VOMS synchronization frequence

GUMS periodically fetches the group membership information from each VOMS server.  The default interval is 720 minutes (12 hours) - which is too long.

- Edit `/opt/vdt/tomcat/v55/webapps/gums/WEB-INF/web.xml` and change the interval from 720 to 12 minutes:


>     updateGroupsMinutes
>     java.lang.Integer
>     **12**
>     updateGroupsMinutes
>     java.lang.Integer
>     **12**

- Restart Tomcat


>  service tomcat-55 restart
>  service tomcat-55 restart

# Populate GUMS configuration

- GUMS is now live at [https://nggums.your.site:8443/gums](https://nggums.your.site:8443/gums)

Make sure your APACGrid certificate is loaded in your browser and connect to GUMS with your browser.

**KMB Note** I got this far but then could not access the GUMS config from the database (see below)

Here, configure the GUMS server to at least:

- Connect to the ARCS VOMS server
- Pull membership information for some VO groups on the server
- Map the groups to a local account.

**NOTE**: This section assumes you are setting up your GUMS server for a single administrative domain - i.e., only one set of user accounts, valid for all systems authenticating against this server.  It is also possible to setup your GUMS server to handle multiple administrative domains - you may contact the [author of these pages](vladimirbestgridorg.md) for more information on that.

On BeSTGRID, you would be typically mapping `/ARCS/BeSTGRID` to `grid-bestgrid` and `/ARCS/NGAdmin` to `grid-admin`.

**KMB Note** I went with `arcsvo01` and `arcsvo02`, respectively.

In the GUMS web configuration menu, do the following steps:

- Add a VOMS server (VOMS Servers -> Add) with the following details:

``` 

Name: ARCS
Desc: ARCS
Base URL: https://vomrs.arcs.org.au:8443/voms
Persist Fact: mysql
SSL Key:  /etc/grid-security/http/httpkey.pem
SSL Cert: /etc/grid-security/http/httpcert.pem
SSL Key Password: blank
SSL CA Files: /etc/grid-security/certificates/*.0

```

- Add a User Group for each VO Group to be supported.  Typically, this would include /ARCS/NGAdmin and on BeSTGRID also /ARCS/BeSTGRID
	
- Add each group by selecting User Group -> Add and filling in details following this template for NGAdmin

``` 

Name: ARCSNGAdminUserGroup                                             Name: ARCSBeSTGRIDUserGroup
Desc: ARCS NGAdmin                                                     Desc: ARCS BeSTGRID
Type: VOMS
VOMS Server: ARCS
Remainder URL: /ARCS/services/VOMSAdmin
Accept non-VOMS certs: true
Match VOMS certificate as: exact
VO/Group: /ARCS/NGAdmin                                                VO/Group: ARCS/BeSTGRID
Role: <blank>
GUMS ACCESS: Read Self

```

- Add an Account Mapper for each local grid (shared) account that would be mapped to a VO Group.  Typically, this would include `grid-admin` for /ARCS/NGAdmin and on BeSTGRID also `grid-bestgrid` for /ARCS/BeSTGRID
	
- Add each account mapper by selecting Account Mappers -> Add and filling in details following this template for NGAdmin

``` 

Name: NGAdminAccountMapper                                             Name: BeSTGRIDAccountMapper
Desc: NGAdmin Account Mapper                                           Desc: BeSTGRID Account Mapper
Type: group
Account: grid-admin                                                    Account: grid-bestgrid

```

- Now, for each of the pair of User Groups and Account Mappers created, create a GroupToAccount mapping linking them together.  Select Group To Account Mappings -> Add and follow this template for NGAdmin:

``` 

Name: NGAdmin to grid-admin                                           Name: BeSTGRID to grid-bestgrid
Desc: NGAdmin to grid-admin                                           Desc: BeSTGRID to grid-bestgrid
User Group(s): ARCSNGAdminUserGroup                                   User Group(s): ARCSBeSTGRIDUserGroup
Account Mapper: NGAdminAccountMapper                                  Account Mapper: BeSTGRIDAccountMapper
Accounting VO Subgroup: blank
Accounting VO: blank

```

>  **Finally, select Host To Group Mappings section - which should contain one entry for **`.yourdomain` (which applies to all hosts in your domain).  Edit this entry and add each of the GroupToAccount mappings created above.

- You are now good to go.  Test your mappings now.
- **First update all membership information by selecting*Update VO Members -> Update VO Members** Database
- **Now select*Generate Grid-Mapfile** and enter `/CN=ng2.yoursite` as the Service DN.  You should get a list of users being mapped to local grid accounts.

The output should look something like

``` 

Grid-mapfile for /CN=ng2.your.site

#---- members of vo: ARCSNGAdminUserGroup ----#
/C=AU/O=APACGrid/OU=..
... list of DNs ...
#---- members of vo: gums-test ----#
"/GIP-GUMS-Probe-Identity" GumsTestUserMappingSuccessful


```

# Polishing Globus

VDT originally came with two defects in the service control scripts installed in `/etc/rc.d/init.d`:

1. All services were marked to be started at order rank 99, making them start in alphabetic order - and this was particularly breaking `globus-ws` if `mysql` wasn't running at the time Globus tried accessing it during start up.
2. The services don't register themselves as running in `/var/lock/subsys`.  Consequently, on system shutdown, the service control scripts don't get invoked to shutdown the services gracefully.

- In VDT 2.0, the first issue has been partly delt with by making `mysql5` start at order rank 90 (starting before all other VDT services) - but it's still desirable to start Tomcat before Apache.
- The second issue has not been addressed yet.

To address these issues, apply the following patches to the master copies of the scripts in `/opt/vdt/post-install`:

- mysql5:

``` 

--- mysql5.orig	2010-02-18 10:13:45.000000000 +1300
+++ mysql5	2010-02-18 11:57:41.000000000 +1300
@@ -332,6 +332,7 @@
       then
         touch /opt/vdt/mysql5/var/mysqlmanager
       fi
+      touch /var/lock/subsys/mysql5
       exit $return_value
     elif test -x $bindir/mysqld_safe
     then
@@ -346,6 +347,7 @@
       then
         touch /opt/vdt/mysql5/var/mysql
       fi
+      touch /var/lock/subsys/mysql5
       exit $return_value
     else
       log_failure_msg "Couldn't find MySQL manager ($manager) or server ($bindir/mysqld_safe)"
@@ -379,6 +381,7 @@
       then
         rm -f $lock_dir
       fi
+      rm -f /var/lock/subsys/mysql5
       exit $return_value
     else
       log_failure_msg "MySQL manager or server PID file could not be found!"

```
- tomcat-55

``` 

--- tomcat-55.orig	2010-02-18 10:12:48.000000000 +1300
+++ tomcat-55	2010-02-18 11:51:09.000000000 +1300
@@ -4,5 +4,5 @@
 # VDT_LOCATION = /opt/vdt
 #
-# chkconfig: 345 99 10
+# chkconfig: 345 97 10
 # description: Tomcat v55
 ### BEGIN INIT INFO
@@ -85,5 +85,5 @@
         RETVAL=$?
         echo
-        [ $RETVAL = 0 ] && touch $TOMCAT_LOCK
+        [ $RETVAL = 0 ] && touch $TOMCAT_LOCK && touch /var/lock/subsys/tomcat-55
         return $RETVAL
 }
@@ -122,5 +122,5 @@
         fi
     
-        rm -f $TOMCAT_LOCK $TOMCAT_PID
+        rm -f $TOMCAT_LOCK $TOMCAT_PID /var/lock/subsys/tomcat-55
       
       fi

```
- apache

``` 

--- apache.orig	2010-02-18 10:12:34.000000000 +1300
+++ apache	2010-02-18 11:59:17.000000000 +1300
@@ -108,6 +108,11 @@
 
 case $1 in
 start|stop|restart|graceful|graceful-stop)
+    if [ "$1" == "start" ] ; then
+        touch /var/lock/subsys/apache
+    elif [ "$1" == "stop" ] ; then
+        rm -f /var/lock/subsys/apache
+    fi
     $HTTPD -k $ARGV
     ERROR=$?
     ;;

```

- Make VDT start using these scripts (install them into /etc/rc.d/init.d) with:


>  vdt-control --off
>  vdt-control --on
>  vdt-control --off
>  vdt-control --on

- For more information, see my description of the [problem](vladimirs-grid-notes.md#Vladimir&#39;sgridnotes-RFTstagingfails).

# Next: Install Auth Tool

If you want to allow users to map their grid identity with their local personal accounts they already have at the system, install both the Auth Tool and the Shibbolized Auth Tool.

Prior to that, extend the GUMS configuration with:

## GUMS configuration for Auth Tool

- Create a *"manual"* group to contain users with a local mapping - with the following settings:

``` 

name: ugLocalAccounts 
desc: Mapped users with a local account
Type: manual
Persistence factory: mysql
GUMS access: read self

```

- Create a *"manual"* accountMapper that would map users to their local account:

``` 

name: amLocalAccounts 
desc: Local users
type: manual
persistency factory: mysql

```

- Create a groupToAccount mapping that links the manual userGroup with the manual accountMapper:

``` 

name: gtaLocalAccounts
desc: Map local users
UserGroup: ugLocalAccounts
AccoutMapper: amLocalAccounts
Accounting VO Subgroup: blank
Accounting VO: blank

```

- Finally, add the groupToAccount mapping (ManualMapperHPC) as first mapping in the HostToGroup mapping for your site.
	
- Mine looks like this

``` 

Host to Group Mapping:  */?*.your.domain
Description:
Group To Account Mappings: gtaLocalAccounts, NGAdmin to grid-admin, BeSTGRID to grid-bestgrid, gums-test

```

## Installing PHP

- The Auth Tool is implemented in PHP - which needs to be installed as an additional VDT package so that it loads into VDT Apache:


>  cd /opt/vdt
>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
>  pacman -get $VDTMIRROR:PHP
>  cd /opt/vdt
>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
>  pacman -get $VDTMIRROR:PHP

## Installing Auth Tool

Now, proceed to installing the Auth Tool:

### Prerequisites

You can get this far without a compiler but the install of 

- `mod_authnz_external` needs access to `GCC`
- `pwauth             }} needs {{make`, the `PAM` development tools and the `Apache` development tools
	
- Note that the ARCS instructions say `http-devel` when current OSes might use `httpd-devel`

It seems that the hourly cron script `gumsmanualmap.py` has a requirement on `MySQL-python`

### Install

- First, follow the ARCS instructions on installing the Auth Tool: [https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool](https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool)
	
- This allows the users to authenticate with an APACGrid certificate loaded in their browser and link their DN with a local account.
- Note: when installing the `gumsmanualmap.py` script, use the VDT 2.0 specific version.

``` 

cd /opt/vdt/apache/htdocs
tar xf /path/to/arcs-sam-authtool-20071204.tar.gz
mv authtool/* .
rm -fr authtool
chown -R daemon:daemon auth mapfile 
chmod 755 auth mapfile 
chmod 644 auth/*
chmod 644 mapfile/*

cd /tmp
tar xf /path/to/mod_authnz_external-3.2.3.tar.gz
cd mod_authnz_external-3.2.3
apxs -c mod_authnz_external.c
apxs -i -a mod_authnz_external.la
cd ..
rm -fr mod_authnz_external-3.2.3

tar xf /path/to/pwauth-2.3.8.tar.gz
cd pwauth-2.3.8/
vim config.h
vim Makefile
cp pwauth /opt/vdt/apache/bin
chown daemon /opt/vdt/apache/bin/pwauth
chmod 700 /opt/vdt/apache/bin/pwauth

cp /path/to/nggums-etc-pam.d-pwauth /etc/pam.d/pwauth
chown root:root /etc/pam.d/pwauth
chmod 644 /etc/pam.d/pwauth

vim /opt/vdt/apache/conf/httpd.conf
cd ..
rm -fr pwauth-2.3.8

```

**Note** the last part of the last change suggested there

``` 

<Directory />
    Options FollowSymLinks
    AllowOverride All
</Directory>

```

places an override throughout the whole of your VDT apache tree.

Now for the cron script

``` 

cd /etc/cron.hourly/
cp /path/to/gumsmanualmap.py-vdt20.txt gumsmanualmap-vdt20.py
chown daemon:daemon gumsmanualmap-vdt20.py
chmod 755 gumsmanualmap-vdt20.py

```

**There's a note** in Sam's instructions that says you have to call your Account Mapper "`manualGroup`"

That string only seems to occur in one place in all of the stuff you install

``` 

# grep manualGroup gumsmanualmap-vdt20.py 
MANUALGROUP = 'manualGroup'
# find pwauth-2.3.8 -type f -print | xargs grep manualGroup
# find mod_authnz_external-3.2.3 -type f -print | xargs grep manualGroup
# find authtool -type f -print | xargs grep manualGroup

```

So I edited the hourly cron script to match my Account Mapper name `amLocalAccounts`

but then I **also found** that it hardcodes "`mappedUsers`" as a GROUP_NAME as well.

I edited that to match my User Group name `ugLocalAccounts`

Personally, I find the names in the hourly cron script confusing.

``` 

MANUALGROUP='manualGroup' is used in a SELECT ... FROM ... WHERE MAP = %s  ... MANUALGROUP

MAPPEDUSERS='mappedUsers' is used in a SELECT ... FROM ... WHERE GROUP_NAME = %s ... MAPPEDUSERS

```

why not use MAP and GROUP_NAME, and name the GROUP with "Group" and the MAPS with "Map" **???**

#### MySQL-python Pre-requisite for Authtool

I **also found** that hourly cron script starts, when it starts running complains about not having

access to the MySQLdb module.

You can chmod it 644 until you really want it to start.

But you obviously also need to get the MySQLdb module. (**from VDT** or **YUM** ???)

It is possible to build the required module from source, using the `MySQL` from VDT and 

the `python` from the host OS.

The current source is here

>  [http://pypi.python.org/pypi/MySQL-python/1.2.3c1](http://pypi.python.org/pypi/MySQL-python/1.2.3c1)

I needed to add the following 'devel' packages so as to effect the build:

``` 

yum install python-setuptools
yum install python-devel.x86_64
yum install zlib-devel.x86_64
yum install openssl-devel.x86_64

```

all of which can, of course, be removed after building, which I did as follows.

``` 

# cd /tmp
# tar xf /path/to/MySQL-python-1.2.3c1.tar.gz 
# cd MySQL-python-1.2.3c1
# python setup.py build
# python setup.py install
# cd ..
# rm -fr MySQL-python-1.2.3c1

```

You may need to install as a package and not just an `.egg` archive as the `cron`

environment doesn't seem to handle the archive.

**Here's the catch:** and the reason why the dependency upon `MySQL` exists.

If you do not have a `MySQL` on the host then when you run the `gumsmanualmap-vdt20.py` 

the `MySQL-python` that it invokes will not get any of the `MySQL` symbols fixed up.

The way round this is to run a cron script in which you can set the envrionment required, eg

``` 

chmod 644 /etc/cron.hourly/gumsmanualmap-vdt20.py
cat  /etc/cron.hourly/run-gumsmanualmap
#!/bin/bash

env LD_LIBRARY_PATH=/opt/vdt/mysql5/lib/mysql python /etc/cron.hourly/gumsmanualmap-vdt20.py

```

I guess that means that you needn't have the script in the cron directories at all but could 

install it elsewhere.

After,

``` 

grant ALL PRIVILEGES ON GUMS_1_3.* TO 'gums'@'localhost' IDENTIFIED BY 'SECRET';

```

don't forget to wipe the `/root/.mysql_history` again, as there's a password in it.

- Next, [install the Shibbolized Auth Tool](deploying-shibbolized-authtool-on-a-gums-server.md)
	
- This allows users using a SLCS certificate to authenticate with their Shibboleth login and link their SLCS DN with a local account.

More information can be found in the [Canterbury local accounts setup](http://www.bestgrid.org/index.php/Setup_NGGums_at_University_of_Canterbury#Mapping_to_local_user_accounts) and [Canterbury Auth Tool setup](setup-authtool-for-hpc-at-university-of-canterbury.md) - including advanced topics like using ssh to verify local account credentials.

## Extra Notes

### Failure to access GUMS config after set up

Not clear what happened but, possibly as a result of not having the FQDN appearing as the hostname during the 

install, I did not end up with a database user/host pair of `root@nggums.your.domain` merely `root@nggums`.

I tried to cure this in a number of ways but to no avail.

I then went back to removing the GUMS installtion and reinstalling. Interestingly, GUMS must be able to be removed

without removing the `MySQL` installtion completely as, when GUMS was reinstalling, I was prompted for the root password I had set up previously.

It would seem that a 

>  pacman -remove GUMS

only removes the packages, not the data, which, in the case of the MySQL installtion, is still there in 

> 1. ls -F /opt/vdt/vdt-app-data/mysql5/var/
>  GUMS_1_3/  ib_logfile0  mysql/      nggums.log            test/
>  ibdata1    ib_logfile1  nggums.err  nggums.vuw.ac.nz.err

However, if you remove the data after having `pacman` remove `GUMS` and then reinstall,

you do end up with the `user` table populated as it should be.

You then need to start again from the `mod_ssl` bug section and edit `/opt/vdt/apache/conf/extra/httpd-ssl.conf`
