# Setup NGGums at University of Canterbury

**NOTE: This page is a historic relict and is not up to date.  If you are looking for instructions on how to setup a GUMS server for BeSTGRID, please see the ****[Setting up a GUMS server](/wiki/spaces/BeSTGRID/pages/3818228918)**** page instead.** |

A GUMS server serves as authorization server for other virtual machines in the Globus Toolkit based grid infrastructure, namely job submission gateways (ng2, ng2hpc) and GridFTP servers (ngportal, hpcgrid1).  The GUMS server receives inquiries from grid services each time an authorization decision or local account mapping has to be made, and decides based on the:

1. the credential
2. VO information possibly embedded in the credential
3. local server configuration
4. current information from the VOMS server

Using a GUMS server will completely eliminate the need for and the use of the `gridmap-file`.  The advantages of that are:

1. Centralized configuration: all the mapping configuration is in the single gums configuration file.
2. Up-to-date information: GUMS server decides based on the current information in the VOMS server, not the possibly outdated information in the `gridmap-file`.
3. Lower communication overhead: only the GUMS server needs to fetch information from the VOMS server, and the other virtual machines communicate directly with the GUMS server.

The GUMS configuration mechanism is fairly flexible, and with multiple `HostGroup` elements, it is possible to specify different mappings for individual hosts (such as mapping everyone to `tomcat` on `ngportal`, or using different usernames (`grid-bgd`, `grid-adm`) on `ng2hpc`).

The installation was based on the [ARCS NgGums installation](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums) page, and was rather simple.  Afterwards, it was necessary to configure the GUMS server with local authorization policies.  Finally, it was necessary to install [AuthTool for the University of Canterbury HPC facility](/wiki/spaces/BeSTGRID/pages/3818228894).

# System Install

Note: I installed the server by upgrading from a VDT 1.6.1 installation of GUMS.  The old installation is backed up in `/opt/vdt161` and `/etc/grid-security-161`.  The system is a CentOS Xen VM [bootstrapped in a standard way](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Bootstrapping%20a%20virtual%20machine&linkCreation=true&fromPageId=3818228678), and [updated](/wiki/spaces/BeSTGRID/pages/3818228636) to CentOS 4.6.

The basic install proceeds with the instructions at [http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums), and also with the instructions for [upgrading a gateway from VDT 1.6.1 to VDT 1.8.1](http://projects.arcs.org.au/trac/systems/wiki/ReleaseNotes/080125).

- Install Gbuild and Gupulse:


>  yum install Gbuild
>  yum remove Gpulse
>  yum install APAC-gateway-gridpulse
>  yum install Gbuild
>  yum remove Gpulse
>  yum install APAC-gateway-gridpulse

Stop and move away the old VDT 1.6.1 GUMS installation:

``` 

vdt-control --force --off
mv /opt/vdt /opt/vdt161
mv /etc/grid-security /etc/grid-security-161
mkdir /etc/grid-security
cp -p /etc/grid-security-161/host{cert,key}.pem /etc/grid-security

```

# Install GUMS from VDT

- Download VDT 1.8.1 GUMS build script:


>  wget -P /usr/local/bin [http://www.vpac.org/~sam/build_nggums_vdt181.sh](http://www.vpac.org/~sam/build_nggums_vdt181.sh)
>  wget -P /usr/local/bin [http://www.vpac.org/~sam/build_nggums_vdt181.sh](http://www.vpac.org/~sam/build_nggums_vdt181.sh)

- Edit `/usr/local/bin/build_nggums_vdt181.sh`:
	
- pass rhel-4 instead of rhel-5 in pretend-platform
- chmod +x /usr/local/bin/build_nggums_vdt181.sh

- Add server's address to `/etc/hosts`:


>  132.181.39.18   nggums.canterbury.ac.nz nggums
>  132.181.39.18   nggums.canterbury.ac.nz nggums

- Run the build script, answer "y" when asked, and save output in `/root/inst/instlog-gums-vdt181.log`:


>  /usr/local/bin/build_nggums_vdt181.sh
>  /usr/local/bin/build_nggums_vdt181.sh

- And do the following VDT post-configuration steps:

## Change MySQL root password

>  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('secret-password');
>  SET PASSWORD FOR 'root'@'nggums.canterbury.ac.nz' = PASSWORD('secret-password');

## Add myself as GUMS admin

>  cd $VDT_LOCATION/tomcat/v55/webapps/gums/WEB-INF/scripts/
>  ./gums-add-mysql-admin "/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl"

## Miscellaneous `gums.config` issues

Following configuration instructions for editing `gums.config`:

- Nothing to do: `hibernate.connection.url` was already fine (FQDN, `nggums.canterbury.ac.nz`)
- Nothing to do: leave GUMS configuration to be done via the web-based interface.
- Note: hostGroup cn already contains our domain (`canterbury.ac.nz`).

## Adjust VOMS-GUMS synchronization interval

To make GUMS synchronize with the VOMS server every 12 minutes, edit `/opt/vdt/tomcat/v55/webapps/gums/WEB-INF/web.xml` with the following:

>     updateGroupsMinutes
>     java.lang.Integer
>     **12**

# Configuring GUMS server

To create the GUMS configuration, draw from the [VOMRS migration instructions](http://wiki.arcs.org.au/bin/view/Main/VomrsMigration) and from the sample [gums.config](http://projects.arcs.org.au/trac/systems/attachment/wiki/HowTo/InstallNgGums/gums.config).

Please note that during the transition period when both APACGrid and ARCS servers are in use, the GUMS server has to be configured to recognize the respective groups on both of the servers, and merge them into the same mapping.  It slightly complicates the setup, but is rather straightforward to follow - and the configuration is easy to navigate via the web-based interface.

The steps to create a configuration that would map users from a VO group to a local account are:

1. define a VOMS servre
2. define a vomsUserGroup on the VOMS server
3. define a groupAccountMapper that would map to a local account
4. define a groupToAccountMapping that maps members of the vomsUserGroup to the local account defined by the groupAccountMapper
5. define a hostToGroupMapping that would list the groupToAccountMappings that apply to a host (selected by a CN pattern).

The entry point to the WWW interface is [https://nggums.canterbury.ac.nz:8443/gums/](https://nggums.canterbury.ac.nz:8443/gums/)

## Create VOMS servers

Create two VOMS servers, APACGrid and ARCS:

new VOMS server:

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

new VOMS server:

``` 

Name: APACGrid
Desc: APACGrid
Base URL: https://vomrs.apac.edu.au:8443/voms
Persist Fact: mysql
SSL Key:  /etc/grid-security/http/httpkey.pem
SSL Cert: /etc/grid-security/http/httpcert.pem
SSL Key Password: blank
SSL CA Files: /etc/grid-security/certificates/*.0

```

## Create User Groups

Start with the NGAdmin group on the ARCS server: choose to add a new UserGroup:

``` 

Name: ARCSNGAdminUserGroup
Desc: ARCS NGAdmin
Type: VOMS
VOMS Server: ARCS
Remainder URL: /ARCS/services/VOMSAdmin
Accept non-VOMS certs: true
Match VOMS certificate as: vogroup
VO/Group: /ARCS/NGAdmoin
Role: blank
GUMS ACCESS: Read Self

```

And following the same pattern, create also a BeSTGRID group, and create both BeSTGRID and NGAdmin also for the APACGrid server (with Remainder URL `/APACGrid/services/VOMSAdmin`).

## Create AccountMappers

Create a new AccountMapper:

``` 

Name: NGAdminAccountMapper
Desc: NGAdmin Account Mapper
Type: group
Account: grid-admin

```

And following this pattern, create also account mapper for `grid-bestgrid`, and also HPC-specific mappers for `grid-bgd` and `grid-adm` (with Name:  NGAdminHPCAccountMapper, BeSTGRIDHPCAccountMapper).

## Create GroupToAccount mappings

Create a new GroupToAccount:

``` 

Name: NGAdmin to grid-admin
Desc: NGAdmin to grid-admin
User Group(s): ARCSNGAdminUserGroup and APACGridUserGroup
Account Mapper: NGAdminAccountMapper
Accounting VO Subgroup: blank
Accounting VO: blank

```

Create a similar  mapping for BeSTGRID (both ARCS and APACGrid groups to `grid-bestgrid`)

Create a similar pair of mappings mapping the NGAdmin and BeSTGRID groups to the HPC account mappers (`grid-adm` and `grid-bgd` respectively).

``` 

Name: NGAdmin on HPC to grid-adm
Name: BeSTGRID on HPC to grid-bgd
Account Mapper: NGAdminHPCAccountMapper, BeSTGRIDHPCAccountMapper

```

## Create HostToGroup mappings

Create the host to group mappings for the hosts which will need a mapping on this server.  Originally, GUMS contains a single mapping for `/?``.canterbury.ac.nz`, which applies to all hosts in the canterbury domain (with or without the `host/` prefix).

With GUMS matching hosts according to *"first match counts"* (and not *most specific match counts*), I can't afford to have a wildcard host mapping.  I have thus removed host mapping for the wildcard `/?``.canterbury.ac.nz`, and instead, I have a mapping for each gateway separately (so far, `ng2.canterbury.ac.nz`, `ng2hpc.canterbury.ac.nz`, and `ng2sge.canterbury.ac.nz`).

## Mapping to local user accounts

In order to allow users to map to their local accounts, we need to install a separate program, AuthTool, and make GUMS accept the mapping from the program.  AuthTool is a PHP script, typically reachable under the `/auth` path on the GUMS server.  The AuthTool requires two lays of authentication: the users must authenticate with their certificate (loaded into their browser), and must also authenticate with the username and password for logging to their cluster (the login details are verified by an external authentication tool).  If the PHP script receives both the user's Distinguished Name (DN) and the cluster login name, it offers the user to request a local mapping, and if the user requests so, the PHP adds the user's mapping to a local `mapfile`.

Afterwards, a Python script ([gumsmanualmap.py](http://projects.arcs.org.au/trac/systems/attachment/wiki/HowTo/InstallAuthTool/gumsmanualmap.py.txt)) propagates the mapping from the mapfile into GUMS server's internal MySQL database.  After this done, the mapping is active, and is the user's default mapping if no VO mapping is requested (i.e., when the user authenticates with plain proxy with no VOMS attribute certificate).

I describe the [AuthTool installation for the HPC cluster](/wiki/spaces/BeSTGRID/pages/3818228894) on a separate page - before doing so, please configure the following GUMS server entries as prerequisites for installing AuthTool:

Note that I am installing AuthTool for mapping users from distinct administrative domains, the HPC and SGE (Oldesparky) clusters.  If you are installing AuthTool for just a single cluster, drop the "HPC" component from the names of the configuration entries.

- Create a *"manual"* group to contain users with a local mapping - with the following settings:

``` 

name: mappedUsersHPC
desc: Mapped users with a local HPC account
Type: manual
Persistence factory: mysql
GUMS access: read self

```

- Create a *"manual"* accountMapper that would map users to their local account:

``` 

name: manualGroupHPC
desc: Local HPC users
type: manual
persistency factory: mysql

```

- Create a groupToAccount mapping that links the manual userGroup with the manual accountMapper:

name: ManualMapperHPC

desc: Map local HPC users

UserGroup: mappedUsersHPC

AccoutMapper: manualGroupHPC

Accounting VO Subgroup: blank

Accounting VO: blank

- Finally, add the groupToAccount mapping (ManualMapperHPC) as first mapping in HostToGroup mapping for `ng2hpc.canterbury.ac.nz`.

Now, proceed to [install the AuthTool](/wiki/spaces/BeSTGRID/pages/3818228894), and check that the user's can create mappings in the GUMS server.

To check this, a GUMS admin can visit the **Manual User Group Members** and **Manual Account Mappings** pages.

A user can check their own mapping by going to the **Map Grid Identity to Account** page.  On this page, the user should fill in the server's DN (it is OK to just include the server's CN, as in `/CN=ng2hpc.canterbury.ac.nz`) and the user's DN (which can be conveniently copied from the bottom of the page).

**Important**: note that in order for local mappings to work, the user's account must exist also on the job submission gateway.  This can be an issue if the gateway does not share accounts with the cluster - a mechanism must be put in place to make sure the accounts do exist on the gateway.

# Configuring GUMS clients

On a VDT-based gateway system, you switch to using a GUMS server with:

>  /opt/vdt/vdt/setup/configure_prima_gt4 --enable --gums-server nggums.canterbury.ac.nz

And you can revert back to using a `gridmap-file` with 

>  /opt/vdt/vdt/setup/configure_prima_gt4 --disable

# Whitespace problem

On VDT 1.6.1, there was an encoding problem in the C client library used to communicate with the GUMS server.  The problem has been solved in VDT 1.8.1 (I may take some credit in the work on the fix).  If you need to use GUMS with a VDT 1.6.1 (or earlier) GridFTP server, you need to install a new version of PRIMA.  Please contact me should you need to get that working - but do consider upgrading to VDT 1.8.1.

Below is my original description of the whitespace problem:

The C client library is in particular used by the GridFTP server.  When a GridFTP server is using the callouts to GUMS (via PRIMA), and the DN in the host certificate of the server contains whitespace (such as in Organization or Organizational Unit name), any authentication attempted by the server will fail, with the following message displayed on the console of the GridFTP server (if attached):

>  1188515069 ERROR SAML.XML.ParserPool handleError: error on line 1, column 568, message: Datatype error: Type:InvalidDatatypeValueException, 
>  Message:Value '/C=AU/O=APACGrid/O=BeSTGRID/OU=University of Canterbury/CN=ng2.canterbury.ac.nz' is NOT a valid URI .
>  PID: 8085 – PRIMA ERROR  prima_saml_support.cpp:490  Unable to process received decision statement: 
>  XML::Parser detected an error during parsing: Datatype error: 
>  Type:InvalidDatatypeValueException, Message:Value '/C=AU/O=APACGrid/O=BeSTGRID/OU=University of Canterbury/CN=ng2.canterbury.ac.nz' is NOT a valid URI .
>  PID: 8085 – PRIMA ERROR  prima_module.c:408  Identity Mapping Service did not permit mapping

Exactly this error message is displayed even:

1. when the GUMS server's privilege.jar is modified to encode the host DN in XML-style encoding.
2. when the SAML response is modified to replace the host DN with a different string.  Even in this case, the error message contains the original host DN.

The latter finding suggests that this is a problem with how the C client library handles the DN stored in the host certificate internally, and has to be fixed in this library.

This problem is still under investigation.  If the DN in your VM's host certificates contains whitespace, I recommend you refrain from switching to a GUMS server until this problem is resolved.

# Notes and tricks

>  **If the CN in the host certificates of the client machines contains a **`"host/"`** prefix, the machine won't match the pattern **`cn='``.your.domain'` in the predefined `hostGroup`.  You probably should get a certificate without a `host/` prefix, but you can get around this by adding an additional `hostGroup` entry with `cn='host/*.your.domain'`.

- If you need different mapping rules for different hosts, you can have multiple `hostGroup` entries, each referencing its own `groupMapping` rules.

- GUMS comes with two "manual" user groups predefined.  "admins" is a local group with the list of GUMS server administrators.  gums-test appears to be a group with a single member with DN "/GIP-GUMS-Probe-Identity" - that looks quite harmless 🙂 Just don't give these groups any mappings 🙂
	
- Hmm, gums-test has a mapping to a VO account called "GumsTestUserMappingSuccessful" - which does not exist on any system.  But I can apparently "ask" with the DN "/GIP-GUMS-Probe-Identity" and see if I get a reply back with this account - for systems where this mapping is included in HostToGroup mapping.

## Configuring different http front-end certificate

It is preferrable to have a *"commercial"* certificate on the https port 443, exposed to clients - a certificate issued by a CA recognized by users' browsers.  On the other hand, port 8443 must use a certificate issued by a CA trusted by the grid gateways, i.e., and IGTF accredited one.

Also, port 443 should be configured not to require a certificate (so that it can display an explanatory page even to a user with no certificate loaded in the browser), while port 8443 would require a certificate (host certificate of the grid gateway requesting a mapping).

Configuring a separate server socket at port 443 has been documented in [Step 5: Friendly Auth Tool page](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool#Step5:FriendlyAuthToolpage) of the ARCS AuthTool installation documentation.

To change the Apache configuration to use a different certificate on the front-end, edit `/opt/vdt/apache/conf/extra/httpd-ssl.conf` and change the SSL paramters in the 

``` 
<VirtualHost :443>
```

  definition to the following:

>  SSLCertificateFile /etc/grid-security/http-front/http-front-cert.pem
>  SSLCertificateKeyFile /etc/grid-security/http-front/http-front-key.pem
>  SSLCertificateChainFile /etc/grid-security/http-front/http-front-chain.pem

## Configuring Apache to use CRLs

The VDT Apache is by default not configured to use the CRLs

Just add the `SSLCARevocationPath` directive below `SSLCACertificatePath`

>  SSLCACertificatePath /opt/vdt/globus/TRUSTED_CA
> 1. **SSLCARevocationPath /opt/vdt/globus/TRUSTED_CA**

**Note**: this experiment did not work out well.  The Apache installed with VDT 1.8.1 (Apache/2.2.4) does not reload the CRLs when they are updated by `fetch-crl`. This change has been reverted and the directive has been commented out.

## Configure Apache to avoid the 90 CA limit

Because of the [Apache 90 CA limit](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Configuring_a_VDT_system_to_include_PRAGMA_CAs_when_updating_IGTF_CA_bundle&linkCreation=true&fromPageId=3818228678) triggered after adding the PRAGMA CAs, I had to configure NGGUMS to send an empty list of CA names, so that the browser lets user pick from all certificates:

``` 

# VLADIMIR: We need Apache not to send any CA names at all - sending all of the
# trusted CAs would trigger a bug and Apache would lock up.  And sending only
# some of them would prevent users with certificates from other CAs from using
# their certificates - their browser would not offer that certificate.
# The safest thing to do is thus to send an empty list of CA names.
# And the only way to do that is to use the SSLCADNRequestPath directive
# pointing to an empty directory.  
# It is safe to assume /opt/vdt/apache/conf won't contain any certificates...
SSLCADNRequestPath /opt/vdt/apache/conf

```

Alternatively, I could configure Apache to use just the APACGrid CA in the list of acceptable CAs - but that would prevent users with certificates from other CAs from accessing the server:

>  SSLCADNRequestFile /etc/grid-security/certificates/1e12d831.0

## Configuring correct shutdown

Make sure tomcat-55 shuts down before MySQL - and that happens rather soon during the shutdown process:

``` 

sed '/^# chkconfig:/c # chkconfig: 345 97 09' --in-place=.ORI /etc/rc.d/init.d/mysql 
sed '/^# chkconfig:/c # chkconfig: 345 98 04' --in-place=.ORI /etc/rc.d/init.d/tomcat-55
sed '/^# chkconfig:/c # chkconfig: 345 99 03' --in-place=.ORI /etc/rc.d/init.d/apache
chkconfig tomcat-55 reset
chkconfig mysql reset
chkconfig apache reset

```

- Make sure MySQL auto starts/stops (see [my notes on fixing shutdown on grid gateways](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir%27s%20grid_notes&linkCreation=true&fromPageId=3818228678)).
- Make sure Tomcat-55 auto starts/stops - similar modification.

``` 

--- tomcat-55.orig	2009-02-23 17:35:46.000000000 +1300
+++ tomcat-55	2009-02-24 12:21:00.000000000 +1300
@@ -84,7 +84,7 @@
 
         RETVAL=$?
         echo
-        [ $RETVAL = 0 ] && touch $TOMCAT_LOCK
+        [ $RETVAL = 0 ] && touch $TOMCAT_LOCK && touch /var/lock/subsys/tomcat-55
         return $RETVAL
 }
 
@@ -121,7 +121,7 @@
             fi
         fi
     
-        rm -f $TOMCAT_LOCK $TOMCAT_PID
+        rm -f $TOMCAT_LOCK $TOMCAT_PID /var/lock/subsys/tomcat-55
       
       fi
 

```
- Make sure Apache auto/starts:

``` 

--- apache.orig	2009-02-23 17:35:55.000000000 +1300
+++ apache	2009-02-24 14:09:59.000000000 +1300
@@ -108,6 +108,11 @@
 
 case $1 in
 start|stop|restart|graceful|graceful-stop)
+    if [ "$1" == "start" ] ; then
+        touch /var/lock/subsys/apache
+    elif [ "$1" == "stop" ] ; then
+        rm /var/lock/subsys/apache
+    fi
     $HTTPD -k $ARGV
     ERROR=$?
     ;;

```

- And if you did this while the server's running, do also:


>  touch /var/lock/subsys/{mysql,tomcat-55,apache}
>  touch /var/lock/subsys/{mysql,tomcat-55,apache}
