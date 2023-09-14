# Shibboleth IdP Test Installation at the University of Canterbury

This installation was done following the [MAMS IdP installation instructions](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallIdP).  The installation was done on a CentOS 5 machine; main differences were in locations of various Tomcat files and directories, and manual installation of LDAP.

This installation is followed up by the [ShARPE installation](/wiki/spaces/BeSTGRID/pages/3818228793).

# Installing Identity Provider

## Basic installation

- Setting up Java environment: `/etc/profile.d/java.sh`:

``` 
export JAVA_HOME=/usr/java/jdk1.5.0_12
```
- When installing Shibboleth IdP (`./ant`), the tomcat directory to enter is `/var/lib/tomcat5`.
- Setting up Shibboleth environment: `/etc/profile.d/shib.sh`:

``` 
export SHIB_HOME=/usr/local/shibboleth-idp
```

## Configuring Apache

The way Apache configuration files are structured on CentOS is very different (and simpler) then how it's done on Debian.

We have just put all Shibboleth-specific Apache configuration into `/etc/httpd/conf.d/shib-vhosts.conf`.  This file contains both `VirtualHost` definitions and the 

``` 
<Location /shibboleth-idp/SSO>
```

 authentication declaration.

The file has three separate VirtualHost sections:

- Create a section also for the default HTTP port 80 document space.  This section will be a container for location-specific authorization directives.

``` 

 <VirtualHost 132.181.4.4:80>
     <Location /secure>
        AuthType shibboleth
        ShibRequireSession On
        require valid-user
     </Location>
 </VirtualHost>

```

- Create a section defining the HTTPS port 443 virtual host.  This section defines the SSL parameters (as instructed by the MAMS instructions), and also contains the location-specific authorization directives.  These may be the same as for the :80 virtual host.

``` 

 <VirtualHost 132.181.4.4:443>
    SSLEngine on
    ...
     <Location /shibboleth-idp/SSO>
        AuthType Basic
        AuthBasicProvider ldap
        ...

```
- Create a virtual host section for HTTPS port 8443.  This will be used for the back-channel communication for Attribute Authority.

``` 

 <VirtualHost 132.181.4.4:8443>
    SSLEngine on
    ...

```

## Use mod_proxy instead of mod_jk

There is no mod_jk available for apache in CentOS repositories, but there is mod_proxy. The [ModProxy page](http://www.federation.org.au/twiki/bin/view/Federation/ModProxy) describes how to set this up - a short entry in the http configuration (`/etc/httpd/conf.d/proxy_ajp.conf`) does the job.

``` 

ProxyRequests Off
<Proxy *>
  Order deny,allow
  Allow from all
</Proxy>
ProxyPass /shibboleth-idp ajp://localhost:8009/shibboleth-idp

```

## Setting up HTTP authentication

The MAMS instructions for setting up [HTTP authentication](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallIdP#Configure_Shibboleth_IdP_with_Ap) are missing one important bit (included in the [Workshop instructions](http://www.federation.org.au/twiki/bin/view/Federation/Workshop_ManualInstallIdP))

After `AuthType Basic`, the following two lines should be inserted: 

``` 

        AuthBasicProvider ldap
        AuthzLDAPAuthoritative OFF

```

# Alternative considerations

The above setup Jk-Mounts the locations for all virtual hosts, and thus creates the need to protect them in all the virtual hosts.  Embedding the `ProxyPass` directive into the `VirtualHost` section would lead to a leaner and cleaner setup.

Hmmm, just taking into consideration: In some settings, the `workers2.properties` file would mount all directories globally.  It may just not make sense to try to restrict the mountpoints only into selected virtual hosts.

## Consolidating JkMounts and Location protections

JkMounts:

>  `/shibboleth-idp` should be mounted for 443 and 8443 (not 80)

- ``` 
<Location /shibboleth-idp/SSO>
```

 should be protected only for 443 (hmm, not 8443?)
- ``` 
<Location /secure>
```

 (or any page/resoruce to be protected) should be protected in 443 (instructions), but in reality, top-level would be the best (all virtual hosts)
- ShARPE mountpoints should be mounted in all vhosts (global is thus OK).
- Supposedly, ShARPE should be protected only in 443 virtual host. Hmm...

Summary:


# Metadata updates

The IdP needs to periodically download metadata - and after each download, check that the XML document contains a correct signature from the `www.federation.org.au`.  As described at the [MAMS metadata update guide](http://www.federation.org.au/twiki/bin/view/Federation/UpdateMetadata), IdP comes with a java tool to do that (`metadatatool`) and MAMS provides a Java keystore with the certificate used to sign the metadata.  We thus only get the java keystore:

>  wget [http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/testfed-keystore.jks](http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/testfed-keystore.jks) -P /etc/certs

And create a cron job that would update the metadata periodically - `/etc/cron.hourly/idp-metadata`

``` 

#!/bin/bash

# get JAVA_HOME and SHIB_HOME and SHIB_SP_HOME
. /etc/profile.d/java.sh
. /etc/profile.d/shib.sh

export METADATA_URL=https://www.federation.org.au/level-1/level-1-metadata.xml
export IDP_HOME=${SHIB_HOME}
export OUTPUT_FILE=${IDP_HOME}/etc/level-1-metadata.xml
## export JAVA_HOME=/usr/local/jdk1.5.0_03
## export IDP_HOME=/usr/local/shibboleth-idp
## export OUTPUT_FILE=/usr/local/shibboleth-idp/etc/level-1-metadata.xml

$IDP_HOME/bin/metadatatool -i $METADATA_URL \
    -k /etc/certs/testfed-keystore.jks -a www.federation.org.au -p testfed \
    -o $OUTPUT_FILE

```

# Installing LDAP

To run a test IdP, we need an LDAP server with test data.  We installed one on localhost.  

- Install the server and client binaries:


>  yum install openldap-servers openldap-clients
>  yum install openldap-servers openldap-clients

- Install the eduPerson schema
	
1. Get eduPerson schema definition

``` 
wget http://www.federation.org.au/software/TextFiles/eduperson.schema.txt -O /etc/openldap/schema/eduperson.schema
```
2. Edit `/etc/openldap/slapd.conf` and add 

``` 
include         /etc/openldap/schema/eduperson.schema
```
- Set the database suffix, root DN and root password in `/etc/openldap/slapd.conf`:

``` 

suffix          "dc=idp-test,dc=canterbury,dc=ac,dc=nz"
rootdn          "cn=Manager,dc=idp-test,dc=canterbury,dc=ac,dc=nz"
rootpw          "<password>"

```
- Populate the database (following `/usr/share/doc/openldap-servers-2.3.27/guide.html`)
	
1. get initial data from [http://www.federation.org.au/software/TextFiles/init.ldif.txt](http://www.federation.org.au/software/TextFiles/init.ldif.txt)
2. edit the data to match local domain name
		
1. change all occurences of `dc=mams,dc=org,dc=au` to `dc=idp-test,dc=canterbury,dc=ac,dc=nz`
2. change the name of the `dc` entry to the innermost component of the domain name (`idp-test` in our case)
3. change the name of the `o` entry from `mams` to our `ou` (again `idp-test`)
3. run the LDAP import 

``` 
ldapadd -x -D "cn=Manager,dc=idp-test,dc=canterbury,dc=ac,dc=nz" -W -f init.ldif.txt
```
- Start the LDAP daemon

``` 
service ldap start
```
- Make sure it always starts 

``` 
chkconfig ldap on
```
