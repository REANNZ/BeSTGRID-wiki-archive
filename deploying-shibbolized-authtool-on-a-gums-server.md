# Deploying Shibbolized AuthTool on a GUMS server

The AuthTool allows a user to map their grid identity (X509 certificate DN) to their local personal account at a site (if the user has one).

The Shibbolized Auth Tool caters for the needs of users using a SLCS certificate (issued based on a Shibboleth login) as their grid identity.  Instead of authenticating with their certificate loaded into the browser, users authenticate directly via Shibboleth - and then they proof possession of their local account with the local username and password.

This page specifically documents the setup of the Shibbolized Auth Tool on top of a GUMS server, installed based on the [ARCS GUMS install instructions](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums) from VDT.

# Basic assumptions

GUMS server running CentOS 5, with GUMS software installed from VDT, following [http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums) - or setup following the BeSTGRID instructions for [Setting up a GUMS server](/wiki/spaces/BeSTGRID/pages/3816950966)

GUMS server already configured with the basic Auth Tool. For this, use the [ARCS AuthTool](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool) documentation as the primary source, and the [Canterbury Auth Tool install notes](/wiki/spaces/BeSTGRID/pages/3816950942) as additional source of information.

# Setup Shibboleth

The first step is to setup the GUMS server as a Shibboleth Service Provider - and register the host in AAF.

This part is based on general instructions for [Installing a Shibboleth 2.x SP](/wiki/spaces/BeSTGRID/pages/3816950790), but differs in that the Shibboleth module is to be loaded by VDT Apache and not system Apache.

- Install latest Shibboleth SP via YUM


>  wget [http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo](http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo) -P /etc/yum.repos.d
>  yum install shibboleth
>  wget [http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo](http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo) -P /etc/yum.repos.d
>  yum install shibboleth

## Federation membership

- Register the host in the federation.
	
- For AAF, go to [https://manager.aaf.edu.au/rr/](https://manager.aaf.edu.au/rr/)
- Preferrably, use an entityID based on the host name - such as [https://sp.example.org/shibboleth](https://sp.example.org/shibboleth)
- Manually add a SAML1 Browser POST, with a URL like [https://sp.example.org/Shibboleth.sso/SAML/POST](https://sp.example.org/Shibboleth.sso/SAML/POST)

>  **Note: the AAF RR requires that your self-signed certificate*includes** the entityID as subject altName URI.  When installing the Shibboleth RPM, the certificate got generated without the entityID.  You have to re-generate the self-signed certificate with
>  cd /etc/shibboleth
>  ./keygen.sh -f -e https://`hostname`/shibboleth
>  **When asked about required attributes, mark*cn** and **sharedToken** as required.

- Save and approve the resource registration.

## Configuration

- Download AAF metadata signing certificate 

``` 
wget https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem -O /etc/shibboleth/aaf-metadata-cert.pem
```
- Note: download the file from [https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem](https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem), not [https://manager.aaf.edu.au/metadata/metadata-cert.pem](https://manager.aaf.edu.au/metadata/metadata-cert.pem)

- Edit `/etc/shibboleth/shibboleth2.xml`
	
- Replace all instances of `sp.example.org` with your hostname.
- Add the following or relevant section into `/etc/shibboleth/shibboleth2.xml` under 

``` 
<MetadataProvider type="Chaining">
```
``` 

            <MetadataProvider type="XML" uri="https://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml"
                 backingFilePath="metadata.aaf.xml" reloadInterval="7200">
               <MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>
               <MetadataFilter type="Signature" certificate="aaf-metadata-cert.pem"/>
            </MetadataProvider>

```

>  **Make session handler use SSL: in*Sessions** element, set `handlerSSL="true"`

- Configure Session Initiator
	
- Configure the URL for the SAMLDS initiator to [https://ds.aaf.edu.au/discovery/DS](https://ds.aaf.edu.au/discovery/DS)
- Move the `isDefault="true"` from the `Intranet` session initiator to the `DS` session Initiator

- Change attribute map.  Instead of editing attribute-map.xml manually to accept attributes, configure Shibboleth to pull a pre-configured one from the ARCS website (courtesy Sam Morrison).  Edit `/etc/shibboleth/shibboleth2.xml` and change the `AttributeExtractor` definition to:

``` 

        <AttributeExtractor type="XML" uri="http://static.arcs.org.au/sp/attribute-map.xml"
                            backingFilePath="attribute-map.xml" reloadInterval="7200"
                            validate="false"/>

```

- Optionally, change the `SupportContact` attribute in the `Errors` element to something more meaningful then `root@localhost`

## Finishing up

This should get you going.

- Start up shibd:


>  service shibd start
>  chkconfig shibd on
>  service shibd start
>  chkconfig shibd on

- Configure Apache to protect a the ShibAuthTool directory with Shibboleth: add the following to `/etc/shibboleth/apache22.config`

``` 

<Location /auth-shib>
  AuthType shibboleth
  ShibRequestSetting requireSession 1
  require shibboleth
</Location>

```
- Optionally, if you leave in the file the same entry for "`/secure`", create the directory:

``` 
mkdir /opt/vdt/apache/htdocs/secure
```
- And for easier debugging, create `/opt/vdt/apache/htdocs/secure/index.php` with

``` 

<?
phpinfo();
?>

```

>  ***IMPORTANT**: If you are running in 64-bit mode, you **MUST** change the `LoadModule` in `/etc/shibboleth/apache22.config` to
>  LoadModule mod_shib /usr/**lib64**/shibboleth/mod_shib_22.so

- Load the Shibboleth module into VDT Apache: add the following line to /opt/vdt/apache/conf/httpd.conf


>  Include /etc/shibboleth/apache22.config
>  Include /etc/shibboleth/apache22.config

- Check Apache is happy with the configuration with


>  httpd -f $VDT_LOCATION/apache/conf/httpd.conf -t
>  httpd -f $VDT_LOCATION/apache/conf/httpd.conf -t

- Restart VDT Apache to load the module


>  service apache restart
>  service apache restart

- And try accessing your server at [http://nggums.your.site/secure](http://nggums.your.site/secure)
	
- You should see Shibboleth login - and if you have installed the secure/index.php file, you should see your whole session listed....

# Install Shib Auth Tool

Here, we assume you already have the Auth Tool deployed in /opt/vdt/apache/htdocs/auth, according to the [ARCS Auth Tool install guides](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool) and [Setup AuthTool for HPC at University of Canterbury](/wiki/spaces/BeSTGRID/pages/3816950942).  The ShibAuthTool will be configured to use the same mapfile, `/opt/vdt/apache/htdocs/mapfile/mapfile`

- Create a directory for Shib Auth Tool


>  mkdir /opt/vdt/apache/htdocs/auth-shib
>  mkdir /opt/vdt/apache/htdocs/auth-shib

- Download the AuthTool from [https://nggums.canterbury.ac.nz/hpc/auth-toy-shib/index-php.txt](https://nggums.canterbury.ac.nz/hpc/auth-toy-shib/index-php.txt) into `/opt/vdt/apache/htdocs/auth-shib/index.php`
- Create a config file for the ShibAuthTool: create /opt/vdt/apache/htdocs/auth-shib/config.php with:

``` 

<?php

$mapfile = "../mapfile/mapfile";
$tempfile = "mapfile.tmp";
$lockfile = "lockfile";
$external_auth = "/opt/vdt/apache/bin/pwauth";
$site_name = "Your HPC site";

?>

```
- Here, external_auth should be set to a program that reads the username and the password from the standard input (each on a separate line) and returns 0 on success and non-zero on error.  If you already have installed the AuthTool, you would very likely have configured `pwauth` to do this task.  Look into /opt/vdt/apache/conf/httpd.conf and check which program is used in the `AddExternalAuth` directive.
- `site_name` should be the name of your site (such as "VPAC" or "University of Canterbury HPC")

- Make the directory and all files owned by daemon:


>  chown -R daemon.daemon /opt/vdt/apache/htdocs/auth-shib
>  chown -R daemon.daemon /opt/vdt/apache/htdocs/auth-shib

- You are done: try accessing [https://nggums.your.site/auth-shib](https://nggums.your.site/auth-shib)
