# Installing iRODS and Davis - test

This package documents a test install of iRODS and Davis, done at gridgwtest.canterbury.ac.nz in November 2009.  The version of iRODS used at that time was 2.2, the version of Davis was 0.8.1.  The installation was largely based on then-available [ARCS Data Services team documentation](https://projects.arcs.org.au/trac/systems/wiki/DataServices) - but this page contains additional information on steps that were not that obvious.

Obviously, this documentation is now likely obsolete - but it may be useful to other people deploying iRODS and Davis.  Use at your own risk.

Start with
[https://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS_Server](https://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS_Server)

# Install iRODS

- Check VDT installed, with Globus-Base-SDK
- ***LATER NOTE**: it's not required to install VDT, it may make sense to install Globus directly from globus.org (and install CA certificates and CRLs separately)
	
- Globus (and VDT) are needed for GSI authentication to iRODS.

- Add rods user and group as requested

- create rods directory - but call it rods 2.2


>   mkdir /opt/iRODS-2.2v
>   chown rods:rods /opt/iRODS-2.2v/
>   ln -s /opt/iRODS-2.2v /opt/iRODS
>   mkdir /opt/iRODS-2.2v
>   chown rods:rods /opt/iRODS-2.2v/
>   ln -s /opt/iRODS-2.2v /opt/iRODS

- create data vault, keep directory name /data/Vault
- as "rods", untar source code

- not applying ARCS-specific patches:
	
- assuming they are already integrated in 2.2
- they would not really apply cleanly (they were for 2.1)
- the patch download URL does not work (FTP Could not chdir)

- build iRODS

``` 

rods@gridgwtest:/opt/iRODS-2.2v/iRODS$ mkdir ../Postgres
. /opt/vdt/setup.sh
./irodssetup
==> Advanced: YES
==> iRODS zone name: BeSTGRID-DEV
==> rods password: <PASSWORD>
==> Starting Server Port [20000]? 40000
==> Ending Server Port [20199]? 40199
==> Resource name: gridgwtest.canterbury.ac.nz
==> (Resource) Directory: /data/Vault
==> Postgress directory: /opt/iRODS-2.2v/Postgres
    New database login name [rods]?
    Password? <PASSWORD>  # same as for iRODS user rods
  # port number: leave as 5432 - but shutdown SRB's postgress first.
==> GSI: yes
==> GLOBUS_LOCATION: /opt/vdt/globus
    GSI Install Type to use? gcc32dbg

```

- Done (~ 20 minutes)

Notes from output:

- configure network interfaces in server/config/irodsHost (define alternative local and remote host names)
- Set `PATH=/opt/iRODS-2.2v/iRODS/clients/icommands/bin:$PATH`
- Ports can be configured in `svrPortRangeStart` ENV var or `svrPortRangeStart` line in irodsctl.pl
- Use


>     irodsctl start
>     irodsctl stop
>     irodsctl restart
>     irodsctl start
>     irodsctl stop
>     irodsctl restart

- debugging: increase spLogLevel in scripts/perl/irodsctl.pl - maximum output is with:

``` 

$spLogLevel = "10";
$spLogSql = "1";

```

# Additional Configuration

- Local user creation: install "createUser" script (attached to the ARCS install guide) into /opt/iRODS-2.2v/iRODS/server/bin/cmd (with +rx permissions and owned by rods:rods)
	
- Also install createUser.config into /opt/iRODS-2.2v/iRODS/server/config
		
- Remember to change email address in the config file

- Automatic rules updating
	
- NOTE: We'll need a BeSTGRID specific version of the updateRules.sh script.  We don't want to be just blindly do what ARCS do (some projects won't be relevant).  But, we for example do need a rule to invoke the createUser script...
- Edit the script to match BeSTGRID-DEV with ARCSDEV
- The script would be rewriting itself with the freshly downloaded version (inhibitting any local changes).  Comment that feature out.
- Rules (and the script) are downloaded from [http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/Rules/](http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/Rules/)

- 
- Download the updateRules.sh script into newly created server/bin/local
- create a rods crontab entry for the script (with local resource name)
- run the script once:

``` 
/opt/iRODS/iRODS/server/bin/local/updateRules.sh gridgwtest.canterbury.ac.nz
```

- Edit server/config/server.config and set the reRuleSet to


>  reRuleSet   arcs,core
>  reRuleSet   arcs,core

**IMPORTANT**: user auto-creation

``` 


when attempting GSI login with empty username, server log says:

ERROR: executeRuleAction Failed for
msiExecCmd(createUser,'"*arg"',null,null,null,*OUT) status = -344000
EXEC_CMD_ERROR
> > ./server/bin/cmd/createUser '/DC=nz/DC=org/DC=bestgrid/DC=slcs/O=University of Canterbury/CN=Vladimir Mencl -2vdKb_4CoiSg1P_uGfB9YTRJLo'
> > Environment variable: $irodsConfigDir  not defined!

!!! use

 iadmin aua vlad  '/DC=nz/DC=org/DC=bestgrid/DC=slcs/O=University of Canterbury/CN=Vladimir Mencl ....'
instead of
 iadmin moduser vlad DN '/DC=nz/DC=org/DC=bestgrid/DC=slcs/O=University of Canterbury/CN=Vladimir Mencl -2vdKb_4CoiSg1P_uGfB9YTRJLo'

:::: add the following to /opt/iRODS-2.2v/iRODS/scripts/perl/irodsctl.pl


???
$irodsConfigDir='/opt/iRODS/iRODS/server/config';


???? huh - this is printed even during a plain "iadmin mkuser username"
> > Oct 13 16:27:43 pid:20799 ERROR: addMsParam: Two params have the same label vladimir.mencl
> > Oct 13 16:27:43 pid:20799 ERROR: addMsParam: old string value = vladimir.mencl
> > Oct 13 16:27:43 pid:20799 ERROR: addMsParam: new string value = vladimir.mencl

OK, works now with.

Need Graham's iupdate script to update .irodsEnv with actual username -
can be found with

> > iquest "SELECT USER_NAME where USER_DN = '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl'"
Get the iupdate script from
https://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS_Client

```

# Finalizing installation

- Copy host certificate for irods
- Install and enable "irods" and "postgres" system services.
- Create /etc/profile.d/irods.sh

# iRODS extensions

Skipping for now:

- iphybun extension
- log file management
- group administration

# Try now: permissions

imkdir /BeSTGRID-DEV/projects

imkdir /BeSTGRID-DEV/projects/public

1. note: /BeSTGRID-DEV/home/public already exists

imkdir /BeSTGRID-DEV/home/public/funnypictures

iadmin mkuser anonymous rodsuser

ichmod read anonymous /BeSTGRID-DEV/home/public/funnypictures

ichmod inherit /BeSTGRID-DEV/home/public/funnypictures

1. also for /projects/public

ichmod read anonymous /BeSTGRID-DEV/projects/public

ichmod inherit /BeSTGRID-DEV/projects/public

**NOTE**: with default permissions: irods won't let me (as a user) list /zone/home

Security model:

- if a user "anonymous" exists, it's let in without a password (and has access to whatever was granted)
- there is a group public where everyone is by default (but NOT the anonymous user - and not the hippopotamus)

Huh - so I need to grant read to public on /home and /projects - with inhertitance left as disabled ?

CRUCIALLY IMPORTANT (AND NOT DOCUMENTED):

``` 

ichmod read public /BeSTGRID-DEV/projects
ichmod read public /BeSTGRID-DEV/home
ichmod read public /BeSTGRID-DEV
ichmod read public /BeSTGRID-DEV/trash
ichmod read public /BeSTGRID-DEV/trash/home

```

!!!! PROBLEM:

``` 

iRODS won't let me in via Davis (with empty username): returns errorcode
-808000 : CAT_NO_ROWS_FOUND

- OK, this looks intereting - the irods server logs a failure with the createUser rule....
so, try removing all accounts and see what happens (keep vlad/heslo for direct login testing)
..... no - not sure what casued the createUser failure
and not sure at all what's wrong
- the createUser script is NOT invoked again on subsequent login attempts

STUCK...

huh - seems to be the problem: the query run by the server to get the user
account from the DN returns an empty set.

CAN BE FIXED:
> > iadmin moduser vladimir.mencl comment '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl'


TODO: for future federating within zone:
> > rsAuthCheck: Warning, cannot authenticate this server to remote server, no LocalZoneSID defined in server.config

```

# Installing DAVIS

Decided to install latest Davis

- Get DAVIS source code


>  svn co [http://projects.arcs.org.au/svn/davis/davis/trunk/](http://projects.arcs.org.au/svn/davis/davis/trunk/) davis-trunk
>  svn co [http://projects.arcs.org.au/svn/davis/davis/trunk/](http://projects.arcs.org.au/svn/davis/davis/trunk/) davis-trunk

- Get Dojo Toolkit from [http://www.dojotoolkit.org/downloads](http://www.dojotoolkit.org/downloads)

- Extrat Dojo Toolkit into Davis's WebContent directory:

``` 

cd davis-trunk/WebContent
tar xzf ../dojo-release-1.3.2.tar.gz
mv dojo-release-1.3.2 dojoroot
cd .. # davis-trunk
ant
# creates dist/davis-0.8.1.tar.gz

```
- Create davis account


>  groupadd -g 499 davis
>  useradd -u 499 -g 499 -m -d /home/davis -c "Davis webDAV" davis
>  mkdir -p /opt/davis
>  chown davis.davis /opt/davis/
>  groupadd -g 499 davis
>  useradd -u 499 -g 499 -m -d /home/davis -c "Davis webDAV" davis
>  mkdir -p /opt/davis
>  chown davis.davis /opt/davis/

- As davis: install davis - follow [https://projects.arcs.org.au/trac/davis/wiki/HowTo/Install](https://projects.arcs.org.au/trac/davis/wiki/HowTo/Install)


>  cd /opt/davis
>  tar xzf /tmp/davis-0.8.1.tar.gz
>  ln -s davis-0.8.1 davis
>  cd /opt/davis
>  tar xzf /tmp/davis-0.8.1.tar.gz
>  ln -s davis-0.8.1 davis

- copy /opt/davis/davis-0.8.1/bin/jetty.sh into /etc/rc.d/init.d/davis


>  ln -s /opt/davis/davis-0.8.1/bin/jetty.sh /etc/rc.d/init.d/davis
>  chmod +x /opt/davis/davis-0.8.1/bin/jetty.sh
>  ln -s /opt/davis/davis-0.8.1/bin/jetty.sh /etc/rc.d/init.d/davis
>  chmod +x /opt/davis/davis-0.8.1/bin/jetty.sh

- Create /etc/default/jetty (home dir, run as, use VDT java)


>  JETTY_HOME=/opt/davis/davis
>  JETTY_USER=davis
>  JAVA_HOME=/opt/vdt/jdk1.5
>  JETTY_HOME=/opt/davis/davis
>  JETTY_USER=davis
>  JAVA_HOME=/opt/vdt/jdk1.5

- Make the config file executable


>  chmod +x /etc/default/jetty
>  chmod +x /etc/default/jetty


- enable proxy pass: create /etc/httpd/conf.d/davis.conf


>  ProxyRequests Off
>  ProxyPreserveHost On
>  ProxyPass / ajp://localhost:8009/ flushpackets=on
>  ProxyRequests Off
>  ProxyPreserveHost On
>  ProxyPass / ajp://localhost:8009/ flushpackets=on

- Alternative: ProxyPass only the zone, first copy dojoroot to /var/www/html (so that Apache serves dojo)

- Davis wants to log into $HOME/logs


>  mkdir ~davis/logs
>  mkdir ~davis/logs

- Start it up


>  service httpd start
>  service davis start
>  service httpd start
>  service davis start

- Enable auto startup:


>  chkconfig httpd on
>  chkconfig --add davis
>  chkconfig httpd on
>  chkconfig --add davis

TODO LATER: real-shib

``` 

PROBLEM: blank screen
try: edit $JETTY_HOME/webapps/root/WEB-INF/web.xml
- enable init-param's server-type server-name zone-name
still the same problem:
> > java.lang.NullPointerException: The host string cannot be null
> >         at edu.sdsc.grid.io.RemoteAccount.setHost(Unknown Source)
> >         at edu.sdsc.grid.io.RemoteAccount.<init>(Unknown Source)
> >         at edu.sdsc.grid.io.irods.IRODSAccount.<init>(Unknown Source)
> >         at webdavis.AuthorizationProcessor.login(AuthorizationProcessor.java:287)
Note:
> > WARNING: Can't load config file '/WEB-INF/davis-config-host.txt' - skipping
> > WARNING: Can't load config file '/WEB-INF/davis-config-dev.txt' - skipping
Aha - must create one of these, that seems to supercede the web.xml entries

```

TODO:

- create custom file for host / org
	
- hostname, zone name, branding?

- install bestgrid-logo.gif and  bestgrid-logo-32x32.gif into /opt/davis/davis-0.8.1/webapps/images
- install bestgrid-favicon.ico into /


>  ProxyPass /favicon.ico !
>  ProxyPass /favicon.ico !

- create davis-config-host.txt

- one more exception:


>  java.lang.NullPointerException: The default storage resource cannot be null
>  java.lang.NullPointerException: The default storage resource cannot be null

huh - looked broken (IOException), but turns out to be likely just a permission error - could not read the home directory listing but could read my personal home dir ....

EXTRA davis doc:

- get current source code + compile
- /etc/default/jetty: JETTY_USER
- Java: OK to run with VDT's JDK5 ?
- configure site to actually get it going
	
- mandatory: server-name, default resource?

???? can we somehow switch timezone from GMT?

- 
- tried "export TZ=Pacific/Auckland" and JAVA_OPTIONS=-Duser.timezone=Pacific/Auckland but did not help

FIXME/TODO: only direct irods login works, myproxy/shibboleth login broken

# TODO

- Federation:
[https://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS_User_Sync](https://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS_User_Sync)

- Usage scripts
[https://projects.arcs.org.au/trac/systems/wiki/DataServices/Install_Usage_Scripts](https://projects.arcs.org.au/trac/systems/wiki/DataServices/Install_Usage_Scripts)

???? try later

- real shib in parallel with basic auth under differnet URLs (both https)
- shib-require all needed attributes
- explanatory error page

??? can default-idp be set to myproxy?

??? can we disable builtin shib-SLCS-client - and just leave it to myproxy

+ real shib?

TODO: set default timezone for Davis

DEBUG Davis with: davis-config-host.txt:

>  webdavis.Log.threshold=DEBUG
>  jargon.debug=4

# Davis / shib

See [https://projects.arcs.org.au/trac/davis/wiki/HowTo/Configuration](https://projects.arcs.org.au/trac/davis/wiki/HowTo/Configuration)

- Install Shib 2.x SP


>  [http://www.bestgrid.org/index.php/Installing_a_Shibboleth_2.x_SP](http://www.bestgrid.org/index.php/Installing_a_Shibboleth_2.x_SP)
>  [http://www.bestgrid.org/index.php/Installing_a_Shibboleth_2.x_SP](http://www.bestgrid.org/index.php/Installing_a_Shibboleth_2.x_SP)

- Exclude logos and secure and dojoroot from ProxyPass: in `/etc/httpd/conf.d/davis.conf`


>  ProxyPass /shibboleth-sp/ !
>  ProxyPass /Shibboleth.sso !
>  ProxyPass /secure !
>  ProxyPass /dojoroot !
>  ProxyPass /shibboleth-sp/ !
>  ProxyPass /Shibboleth.sso !
>  ProxyPass /secure !
>  ProxyPass /dojoroot !

- Copy dojoroot from /opt/davis/davis-0.8.1/webapps/dojoroot into /var/www/html/dojoroot
- Tell davis to use a certfile readable by davis: in `davis-config-organisation.txt` set


>  admin-cert-file=/etc/grid-security/daviscert.pem
>  admin-key-file=/etc/grid-security/daviskey.pem
>  shared-token-header-name=shared-token
>  insecureConnection=shib
>  admin-cert-file=/etc/grid-security/daviscert.pem
>  admin-key-file=/etc/grid-security/daviskey.pem
>  shared-token-header-name=shared-token
>  insecureConnection=shib

- let davis come in as rodsuser


>  iadmin moduser rods DN "**SERVER_DN**" - or equivalent
>  iadmin aua rods '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=gridgwtest.canterbury.ac.nz'
>  iadmin moduser rods comment '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=gridgwtest.canterbury.ac.nz'
>  iadmin moduser rods DN "**SERVER_DN**" - or equivalent
>  iadmin aua rods '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=gridgwtest.canterbury.ac.nz'
>  iadmin moduser rods comment '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=gridgwtest.canterbury.ac.nz'

- configure mod_ship to pass attribute values in headers - that's where Davis expects them (not in Apache env)

``` 

 <Location /BeSTGRID-DEV>
   AuthType shibboleth
   ShibRequireSession On
   ShibUseHeaders On
   require valid-user
 </Location>

```

- !!! configure Shib only for plain http - enclose the above in 

``` 
<VirtualHost _default_:80>
```
``` 

<VirtualHost _default_:80>
<Location /BeSTGRID-DEV>
  AuthType shibboleth
  ShibRequireSession On
  ShibUseHeaders On
  require valid-user
</Location>
</VirtualHost>

```
