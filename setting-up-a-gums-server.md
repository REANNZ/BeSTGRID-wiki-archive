# Setting up a GUMS server

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

The GUMS configuration mechanism is fairly flexible, and with multiple `HostGroup` elements, it is possible to specify different mappings for individual hosts (such as for multiple grid gateways for multiple clusters with different sets of accounts).(grid-bgd, grid-adm) on ng2hpc).

The installation is based on the [ARCS NgGums installation guide](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums), and adds some VDT 2.0 specific instructions (and refines the installation steps).

When users have personal accounts on the cluster and it's desired to let them access the personal accounts via the grid, then this installation should be followed by installing the AuthTool and the [Shibbolized AuthTool](/wiki/spaces/BeSTGRID/pages/3818228565).

As a "parallel companion" to this page, setup instructions are given for GUMS on an Ubuntu server base system: [Setting up a GUMS server on Ubuntu](/wiki/spaces/BeSTGRID/pages/3818228431)

**NOTE:** The original method described on this page results in all BeSTGRID users using a common username and home directory, which is a security risk. It is recommended that all production sites switch to using [pooled and individual accounts](/wiki/spaces/BeSTGRID/pages/3818228955).

# Preliminaries

## OS requirements

This guide assumes the system where GUMS will be installed has already been configured.

The following is recommended:

- Minimum hardware requirements (VM configuration): 512MB RAM, 1 CPU, 8GB filesystem, 1GB swap.

- OS: Linux CentOS 5 (or RHEL 5).  Other Linux distributions (or other operating systems) may work, please check the [VDT system requirements](http://vdt.cs.wisc.edu/releases/2.0.0/requirements.html).
	
- Both i386 (32-bit) and x86_64 (64-bit) distributions are supported.

>  **Hostname: it is recommended to use*nggums.*****your.site.domain***

- The system is setup to send outgoing email (i.e., typically, default SMTP relay would be set to the site's local SMTP server).
	
- Note: it is a requirement that the SMTP server does not overwrite the sender domain (in the From: address) - the domain must stay as the full hostname.

- The system is configured for time synchronization with a reliable time source.

- If the GUMS server will be setup with support for mapping users to their local personal accounts, the OS *should* be configured to recognize the accounts local accounts (e.g., via the appropriate PAM module).  But this is not a hard requirement and can be worked around later

## Network requirements

- The server needs a public (and static) IP address.
- The hostname must resolve to this IP address and the IP address must resolve back to the system's hostname.
- The server needs to be able to open outgoing TCP connections to ports 80, 443, 8443.
	
- The traffic to ports 80 and 443 MAY go through a proxy (if the `http_proxy environment` variable is properly set), but port 8443 traffic must be a direct connection.
- If setup with the Auth Tool, the server also needs to accept incoming TCP connections on ports 443 and 8443.

## Certificates

Before proceeding with the certificate, [obtain a host certificate](/wiki/spaces/BeSTGRID/pages/3818228502) for this system from the [APACGrid CA](http://wiki.arcs.org.au/bin/view/Main/HostCertificates)

- If no other software has created the directories `/etc/grid-security` and `/etc/grid-security/http` then they need to be created

``` 

mkdir -p /etc/grid-security/http
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security
chmod 755 /etc/grid-security/http

```

- Install the certificate and private key as `/etc/grid-security/hostcert.pem` and `/etc/grid-security/hostkey.pem` respectively
	
- The files should be owned by root
- The private key should be readable only to root

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

# GUMS install

## Clean CentOS Install

Make sure httpd/Apache is not installed by removing it with:

>  yum remove httpd

Remove mysql is not previously installed with:

>  yum remove mysql

## Check Firewall

CentOS may have the firewall enabled by default. Check that ports 8443 and 443 are open when listing the iptable rules with:

>  iptables -L

If these ports are not open edit `/etc/sysconfig/iptables` and check that the following lines occur before the final `REJECT` statement:

>  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
>  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT

Then reload the iptables with:

>  service iptables restart

## Prerequisite Packages

First, we setup the ARCS repository and install GridPulse (the ARCS system monitoring tool) from the ARCS repository:

- Configure ARCS RPM repository


>  cd /etc/yum.repos.d && wget [http://projects.arcs.org.au/dist/arcs.repo](http://projects.arcs.org.au/dist/arcs.repo)
>  cd /etc/yum.repos.d && wget [http://projects.arcs.org.au/dist/arcs.repo](http://projects.arcs.org.au/dist/arcs.repo)

- Install the system monitoring tool GridPulse


>  yum install APAC-gateway-gridpulse
>  yum install APAC-gateway-gridpulse

- Email help@arcs.org.au and have your GUMS server added to your site on the [Grid Operations Centre](http://status.arcs.org.au/)

## Pacman and VDT

The installation is done via pacman, the package manager used by VDT.

- As root, download and setup pacman:

``` 

mkdir /opt/vdt
cd /opt/vdt
wget http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz
tar xf pacman-*.tar.gz
cd pacman-*/ && source setup.sh && cd ..

```

- Install GUMS from VDT

>  cd /opt/vdt
>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
>  pacman -get $VDTMIRROR:GUMS

- Wait about a minute or two for the installer to prompt you to agree to licenses.
- Have a cup of coffee - the download and installation may take 15-30 minutes.

- Make the environment variable setup script created by VDT load in the default profile


>  ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
>  . /etc/profile
>  ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
>  . /etc/profile

## Configure VDT certificate distribution

VDT comes with a tool to download and update a certificate distribution, but requires the user to make an (informed) choice on which certificate distribution to trust.  The VDT team is also creating a convenient distribution based on IGTF - but we do need to configure this tool to point to this distribution.

- Run the following command to select the VDT distribution and install it into /etc/grid-security/certificates

``` 
vdt-ca-manage setupca --location root --url vdt
```
- Note: behind the scenes, the tool adds the following line to `$VDT_LOCATION/vdt/etc/vdt-update-certs.conf`: 

``` 
cacerts_url = http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version
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

# Post-install configuration

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

## Set MySQL root password

Change the MySQL root password to a password of your choice. For this issue the following on the command line with the `mysql` client:

>  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('secret-password');
>  SET PASSWORD FOR 'root'@'gums.otago.ac.nz' = PASSWORD('secret-password');

**Note:** Do not forget to remove the `~/.mysql_history` file afterwards to remove readable clear text traces of the password

## Check privileges for gums user

This can be tricky for gums servers that have multiple IP addresses. Additional gums users at different hosts may need to be created and granted all privileges over the GUMS_1_3 database.

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

Here, configure the GUMS server to at least:

- Connect to the ARCS VOMS server
- Pull membership information for some VO groups on the server
- Map the groups to a local account.

**NOTE**: This section assumes you are setting up your GUMS server for a single administrative domain - i.e., only one set of user accounts, valid for all systems authenticating against this server.  It is also possible to setup your GUMS server to handle multiple administrative domains - you may contact the [author of these pages](vladimirbestgridorg.md) for more information on that.

On BeSTGRID, you would be typically mapping `/ARCS/BeSTGRID` to `grid-bestgrid` and `/ARCS/NGAdmin` to `grid-admin`.

In the GUMS web configuration menu, do the following steps:

- Add a VOMS server (VOMS Servers -> Add) with the following details:

``` 

Name: ARCS
Desc: ARCS
Base URL: https://vomrs.arcs.org.au:8443/voms
Persist Fact: mysql
SSL Key:  /etc/grid-security/http/httpkey.pem
SSL Cert: /etc/grid-security/http/httpcert.pem
SSL Key Password:                                     (leave blank)
SSL CA Files: /etc/grid-security/certificates/*.0

```

- Add a User Group for each VO Group to be supported.  Typically, this would include /ARCS/NGAdmin and on BeSTGRID also /ARCS/BeSTGRID
	
- Add each group by selecting User Group -> Add and filling in details following this template for NGAdmin

``` 

Name: ARCSNGAdminUserGroup
Desc: ARCS NGAdmin
Type: VOMS
VOMS Server: ARCS
Remainder URL: /ARCS/services/VOMSAdmin
Accept non-VOMS certs: true
Match VOMS certificate as: exact
VO/Group: /ARCS/NGAdmin
Role: <blank>
GUMS ACCESS: Read Self

```

**NOTE: If installing a new GUMS server, instead of creating a "group" account mapper mapping all users to the same account, it is adviced to use a pooled account mapper instead.  Please see the documentation on ****[Configuring a GUMS server with pooled accounts](/wiki/spaces/BeSTGRID/pages/3818228955)**** for more instructions on doing that.** |

- Add an Account Mapper for each local grid (shared) account that would be mapped to a VO Group.  Typically, this would include `grid-admin` for /ARCS/NGAdmin and on BeSTGRID also `grid-bestgrid` for /ARCS/BeSTGRID
	
- Add each account mapper by selecting Account Mappers -> Add and filling in details following this template for NGAdmin

``` 

Name: NGAdminAccountMapper
Desc: NGAdmin Account Mapper
Type: group
Account: grid-admin

```

- Now, for each of the pair of User Groups and Account Mappers created, create a GroupToAccount mapping linking them together.  Select Group To Account Mappings -> Add and follow this template for NGAdmin:

``` 

Name: NGAdmin to grid-admin
Desc: NGAdmin to grid-admin
User Group(s): ARCSNGAdminUserGroup
Account Mapper: NGAdminAccountMapper
Accounting VO Subgroup:              (leave blank)
Accounting VO:                       (leave blank)

```

>  **Finally, select Host To Group Mappings section - which should contain one entry for **`/?*.your.domain` (which applies to all hosts in your domain).  Edit this entry and add each of the GroupToAccount mappings created above.

``` 

Host to Group Mapping:  */?*.your.domain
Description:
Group To Account Mappings: NGAdmin to grid-admin, BeSTGRID to grid-bestgrid, gums-test

```

- You are now good to go.  Test your mappings now.
- **First update all membership information by selecting*Update VO Members -> Update VO Members** Database
- **Now select*Generate Grid-Mapfile** and enter `/CN=ng2.yoursite` as the Service DN.  You should get a list of users being mapped to local grid accounts.

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

- For more information, see my description of the [problem](/wiki/spaces/BeSTGRID/pages/3818228535#Vladimir&#39;sgridnotes-RFTstagingfails).

# Next: Install Auth Tool

If you want to allow users to map their grid identity with their local personal accounts they already have at the system, install both the Auth Tool and the Shibbolized Auth Tool.

Prior to that, extend the GUMS configuration with:

## GUMS configuration for Auth Tool

- Create a *"manual"* User Group to contain users with a local mapping - with the following settings:

``` 

name: mappedUsers
desc: Mapped users with a local account
Type: manual
Persistence factory: mysql
GUMS access: read self

```

- Create a *"manual"* Account Mapper that would map users to their local account:

``` 

name: manualGroup
desc: Local users
type: manual
persistency factory: mysql

```

- Create a groupToAccount mapping that links the manual userGroup with the manual accountMapper:

``` 

name: ManualMapper
desc: Map local users
UserGroup: mappedUsers
AccoutMapper: manualGroup
Accounting VO Subgroup: blank
Accounting VO: blank

```

- Finally, add the groupToAccount mapping (ManualMapperHPC) as first mapping in the HostToGroup mapping for your site.

## Installing PHP

- The Auth Tool is implemented in PHP - which needs to be installed as an additional VDT package so that it loads into VDT Apache:


>  cd /opt/vdt
>  . setup.sh
>  pacman -get [http://vdt.cs.wisc.edu/vdt_200_cache:PHP](http://vdt.cs.wisc.edu/vdt_200_cache:PHP) 
>  cd /opt/vdt
>  . setup.sh
>  pacman -get [http://vdt.cs.wisc.edu/vdt_200_cache:PHP](http://vdt.cs.wisc.edu/vdt_200_cache:PHP) 

## Installing Auth Tool

Now, proceed to installing the Auth Tool:

- First, follow the ARCS instructions on installing the Auth Tool: [https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool](https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool)
	
- This allows the users to authenticate with an APACGrid certificate loaded in their browser and link their DN with a local account.
- Note: when installing the `gumsmanualmap.py` script, use the VDT 2.0 specific version.

- Next, [install the Shibbolized Auth Tool](/wiki/spaces/BeSTGRID/pages/3818228565)
	
- This allows users using a SLCS certificate to authenticate with their Shibboleth login and link their SLCS DN with a local account.

**Note:** This may require the installation of the Development Tools package group with:

>  yum groupinstall "Development Tools"

More information can be found in the [Canterbury local accounts setup](http://www.bestgrid.org/index.php/Setup_NGGums_at_University_of_Canterbury#Mapping_to_local_user_accounts) and [Canterbury Auth Tool setup](/wiki/spaces/BeSTGRID/pages/3818228894) - including advanced topics like using ssh to verify local account credentials.
