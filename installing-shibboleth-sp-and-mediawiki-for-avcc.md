# Installing Shibboleth SP and MediaWiki for AVCC

This page documents setting up the shibbolized media wiki website for the [AVCC project](http://avcc.karen.net.nz/).  This consisted of installing Shibboleth SP (on Ubuntu), the MediaWiki shibboleth authentication plugin, and integrating the SP into both AAF-L2 and BeSTGRID federations.  

# Prepare and Compile SP

Shibboleth SP is installed as described in the [MAMS instructions](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallSP).  As this system is running the Ubuntu Linux distribution, based on Debian, there was even less difference from the MAMS instructions than when installing on a RedHat based system (CentOS).  However, as the system was installed only with a minimum package selection, the installation included installing quite a number of packages, both to fulfill the installation requirements and for convenience of future system administration.

## Packages installed

This system is based on Debian, and thus packages are installed with `apt-get install`.  However, as the system is Ubuntu and not just basic Debian, I have omitted the parameter `t unstable`, assuming that Ubuntu has up to date repositories.  Also, I have commented out the CD-ROM apt source from `/etc/apt/sources.list`, to point the system to the up-to-date package source (and I initially did not have access to the VMware console to insert the Ubuntu CD as virtual media).

- Packages installed as requirement for installing Shibboleth SP:


>  apt-get install gcc g++
>  apt-get install libcurl3 libcurl3-dev
>  apt-get install gcc-3.3 g++-3.3
>  apt-get install make zip unzip
>  apt-get install libssl-dev
>  apt-get install apache2-dev 
>  apt-get install gcc g++
>  apt-get install libcurl3 libcurl3-dev
>  apt-get install gcc-3.3 g++-3.3
>  apt-get install make zip unzip
>  apt-get install libssl-dev
>  apt-get install apache2-dev 

- Notes:
	
- xml-security and opensaml need SSL and CURL development libraries.  libcurl3-dev and libssl-dev have been both superseded by libcurl4-openssl-dev - which apt-get offers to install when asked for libcurl3-dev.

- Packages installed as convenience:


>  apt-get install mc
>  apt-get install vim-runtime
>  apt-get install vim-full
>  apt-get install mc
>  apt-get install vim-runtime
>  apt-get install vim-full

- Notes:
	
- By default, `vim-tiny` is istalled as the editor - compiled with minimal features, without syntax highlighting.  Installing `vim-full` brings in these features - even though it pulls in gnome and x11-common as dependencies.

## Compiling Shibboleth SP

- Create target directory and set the environment: target prefix, use gcc 3.x


>  mkdir /usr/local/shibboleth-sp/
>  export SHIB_SP_HOME=/usr/local/shibboleth-sp
>  export CC=gcc-3.3 CXX=g++-3.3
>  mkdir /usr/local/shibboleth-sp/
>  export SHIB_SP_HOME=/usr/local/shibboleth-sp
>  export CC=gcc-3.3 CXX=g++-3.3

- Follow instructions at [http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallSP](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallSP)
- Compile log4cpp: no changes
- Compile xerces: use the following to configure (compiler selection)


>  ./runConfigure -p linux -c gcc-3.3 -x g++-3.3 -r pthread -P $SHIB_SP_HOME 
>  ./runConfigure -p linux -c gcc-3.3 -x g++-3.3 -r pthread -P $SHIB_SP_HOME 

- Compile xml-security: no changes (needs libssl-dev)
- Compile opensaml: no changes (needs libcurl-dev)
- Compile shibboleth-sp: apache is 2.2 (needs apache2-dev)


>    ./configure --prefix=$SHIB_SP_HOME --with-log4cpp=$SHIB_SP_HOME --enable-apache-22 --with-apxs2=/usr/bin/apxs2 --disable-mysql
>    ./configure --prefix=$SHIB_SP_HOME --with-log4cpp=$SHIB_SP_HOME --enable-apache-22 --with-apxs2=/usr/bin/apxs2 --disable-mysql

# Initial SP configuration

In the first stage, the SP was configured as a member of the AAF Level-1 federation.  The individual steps were:


- Configure `shibboleth.xml`
	
- Download template from [http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/shibboleth.xml](http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/shibboleth.xml)
- Replace MY_DNS with hostname (`uc-avcc.canterbury.ac.nz`), check certificate locations (the above default locations are same as in the openssl command above).

- Get `AAP.xml` from [http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/AAP.xml](http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/AAP.xml)

- Setup time synchronization - NTP.  In `/etc/ntp.conf`, setup:

``` 
server clock1.canterbury.ac.nz
```
- Get initial AAF Level-1 metadata into `/usr/local/shibboleth-sp/etc/shibboleth/level-1-metadata.xml`

- Configure automatic startup of Shibboleth daemon.


>  wget [http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/shibboleth](http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/shibboleth) -P /etc/init.d/
>  chmod +x /etc/init.d/shibboleth
>  update-rc.d shibboleth defaults 95 95
> 1. default rank 20 would be too soon
> 2. use "update-rc.d -f shibboleth remove" to remove the links
> 3. use "invoke-rc.d" instead of "service" to start and stop the service
>  wget [http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/shibboleth](http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/shibboleth) -P /etc/init.d/
>  chmod +x /etc/init.d/shibboleth
>  update-rc.d shibboleth defaults 95 95
> 1. default rank 20 would be too soon
> 2. use "update-rc.d -f shibboleth remove" to remove the links
> 3. use "invoke-rc.d" instead of "service" to start and stop the service

## Configure and enable Shibboleth Apache module (for Apache 2.2)

- Create `/etc/apache2/mods-available/mod_shib.load`: note that the file has to reference version 22 of the Shibboleth Apache module, so the crucial line is: 

``` 
/usr/local/shibboleth-sp/libexec/mod_shib_22.so
```
- Create `/etc/apache2/mods-available/mod_shib.conf`: should include directives as instructed, and also should make the [logo and stylesheet available for inclusion](vladimirs-general-shibboleth-notes.md) in error pages.  Thus, the contents of the file should be:

``` 

# Shibboleth SP 1.3
##
# Shibboleth SP 1.3 config
ShibConfig /usr/local/shibboleth-sp/etc/shibboleth/shibboleth.xml
ShibSchemaDir /usr/local/shibboleth-sp/share/xml/shibboleth

# Necessary for the Shibboleth SP error page to correctly display with the
# Shibboleth logo and stylesheet.
<IfModule mod_alias.c>
  <Location /shibboleth-sp>
    Allow from all
  </Location>
  Alias /shibboleth-sp/main.css /usr/local/shibboleth-sp/doc/shibboleth/main.css  Alias /shibboleth-sp/logo.jpg /usr/local/shibboleth-sp/doc/shibboleth/logo.jpg</IfModule>

<Files *.sso>
   SetHandler shib-handler
</Files>

```
- Enable the Shibboleth Apache module (create symlinks in `/etc/apache2/mods-enabled/`)


>   a2enmod mod_shib
>   a2enmod mod_shib

- Configure Apache variables in `/etc/apache2/envvars` (necessary to load the module properly):


>   SHIB_HOME=/usr/local/shibboleth-sp
>   LD_LIBRARY_PATH=${SHIB_HOME}/libexec:${SHIB_HOME}/lib:$LD_LIBRARY_PATH
>   export LD_LIBRARY_PATH
>   export SHIB_HOME 
>   SHIB_HOME=/usr/local/shibboleth-sp
>   LD_LIBRARY_PATH=${SHIB_HOME}/libexec:${SHIB_HOME}/lib:$LD_LIBRARY_PATH
>   export LD_LIBRARY_PATH
>   export SHIB_HOME 

- Restart Apache:


>  invoke-rc.d apache2 force-reload
>  invoke-rc.d apache2 force-reload

## Federation Membership

Register the service with the AAF federation:

- Organization EntityId: `urn:mace:federation.org.au:testfed:uc-avcc.canterbury.ac.nz`
- Service Provider hostname: uc-avcc.canterbury.ac.nz
- Service URL: [http://uc-avcc.canterbury.ac.nz/](http://uc-avcc.canterbury.ac.nz/)
- SPDescription: leave for later (see below).

>  **For BeSTGRID federation membership, manually edit **`wayf.bestgrid.org/var/www/html/metadata/bestgrid-metadata.xml`** and insert the same*EntityDescriptor** element as generated for the AAF federation.

 **Edit **`/usr/local/shibboleth-sp/etc/shibboleth/shibboleth.xml`** to configure membership in the BeSTGRID Federation (second*MetadataProvider** provider for `"/usr/local/shibboleth-sp/etc/shibboleth/bestgrid-metadata.xml"`) and change the `SessionInitiator` `wayfURL` attribute to `"https://wayf.bestgrid.org/shibboleth-wayf/WAYF"`.

- For both federations, setup automatic metadata updating as documented in this page on [Updating Federation Metadata](/wiki/spaces/BeSTGRID/pages/3818228810).

Note that initially, the BeSTGRID WAYF server may display an empty selection, possibly due to metadata on the server not being updated.  This issue should disappear after the metadata is updated.

## Updating membership to Level 2

A request to upgrade the membership to Level 2 can processed very soon.  Afterwards, the following has to be done:

- Edit `shibboleth.xml`:
	
- If still using AAF WAYF server, change the URL to `level-2`
- Download level-2 metadata
- Switch MetadataProvider to Level-2
- Use certificates suitable for Level 2: edit the 

``` 
<Credentials>/<FileResolver>
```

 element.
		
- Note that `shibboleth.xml` does not support certificate file locations specified as `file:/path`, only as `/path`.
- Store the certificates as `/etc/certs/aa-{cert,key}.pem`
- Store certificates comprising the CA certificate chain in `/etc/certs/CA/`
- Change ownership of certificates used by Apache to be owned by `www-data:www-data` (applies only to HTTPS virtual host certificates, `shibd` runs as root).

- Note that at this stage, the server *should* have commercial https front-end certificate - but we *may* still go with AAF-L1 certificate for testing...

For requesting an ipsCA, use the following

> 1. openssl req  -new -nodes -key `hostname`-key.pem -out `hostname`-csr.pem
> 2. not, this does not work: -key expects key already exists.
> 3. instead:
>   openssl req  -new -nodes -newkey rsa:2048 -out `hostname`-csr.pem
>   mv privkey.pem `hostname`-key.pem

## Configuring an HTTPS virtual host

Even if the SP does not provide any services that would need HTTPS, it is necessary to configure an HTTPS virtual host at least for receiving the SAML assertions.  The assertion and artifact consumer services are *not* available on the plain HTTP virtual host.

Setup an HTTPS virtual host following the MAMS instructions - create `/etc/apache2/sites-available/003-ssl-vhost.conf`.  Initially, it is fine to configure the SSL virtual host with AAF certificates.  For production, it should be using a commercial certificate, accepted by a broad range of clients' browsers.

With the Debian Apache configuration tools, enable the virtual host with:

>  a2ensite 003-ssl-vhost.conf
>  a2enmod ssl
>  invoke-rc.d apache2 restart

Note: It is also possible to receive the SAML assertions via plain HTTP - but it is generally recommended not to do so.  In the Shibboleth Apache module configuration, the handler directive maps Shib-handler to any URL matching "**.sso".  However, the Shibboleth SP configuration file (**`/usr/local/shibboleth-sp/etc/shibboleth/shibboleth.xml`**) specifies what URLs will actually be used to initiate a session.  In the **`Sessions`** element, the elements **`*handlerURL="/Shibboleth.sso" handlerSSL="true"` state that (with these default settings), only the path /Shibboleth.sso accessed via HTTPS will be actually used to process SAML assertions.  It is possible, though not recommended, to change these settings - but for now, let's keep with an HTTPS virtual host.

## Protecting a directory

Simple exercise: test that Shibboleth is working and protect a single directory (`/secure`) with Shibboleth.

This can be done by inserting the following Apache configuration snippet into `/etc/apache2/sites-enabled/000-default`

``` 

<Location /secure>
   AuthType shibboleth
   ShibRequireSession On
   require valid-user
</Location>

```

After an `invoke-rc.d apache2 restart`, the location [https://uc-avcc.canterbury.ac.nz/secure/](https://uc-avcc.canterbury.ac.nz/secure/) requests Shibboleth authentication.

# Advanced Apache Configuration

## Enforcing Canonical Hostname

As the machine had been known under two distinct hostnames, it has become necessary to enforce the use of it's canonical hostname - otherwise, logins via the non-canonical hostname fail, as described in this section on [canonical hostnames](vladimirs-general-shibboleth-notes.md) in my grid notes.

To enforce the use of canonical hostnames, it is not sufficient to use the Apache directive

>  UseCanonicalName on

This directive applies only when the server needs to construct a self-referencing URL - but would not initiate a redirect to the canonical hostname when the URL requested does not explicitly need a redirect.

A way to redirect URLs, documented in the [Apache URL Rewriting Guide](http://httpd.apache.org/docs/2.2/rewrite/rewrite_guide.html), is to use the Rewrite Engine.

To redirect URLs arriving to both ports 80 and 443, the following changes were made:

- In `003-ssl-vhost.conf` (inside 

``` 
<VirtualHost 132.181.2.42:443>
```

)

``` 

    # redirects to enforce canonical name:                                                                                                                                 
    RewriteEngine On                                                                                                                                                       
    RewriteCond %{HTTP_HOST}   !^avcc\.karen\.net\.nz [NC]                                                                                                                 
    RewriteCond %{HTTP_HOST}   !^$                                                                                                                                         
    RewriteRule ^/(.*)         https://avcc.karen.net.nz/$1 [L,R]

```
- In the `default` host file, I was necessary to make sure this change applies only to the port 80 virtual host, so I changed the VirtualHost configuration to apply only to 

``` 
<VirtualHost 132.181.2.42:80>
```

 instead of 

``` 
<VirtualHost *>
```

:
- **Comment out: **`NameVirtualHost`
	
- Change 

``` 
<VirtualHost *>
```

 to 

``` 
<VirtualHost 132.181.2.42:80>
```
- Add the following block to this VirtualHost:

``` 

    RewriteEngine On
    RewriteCond %{HTTP_HOST}   !^avcc\.karen\.net\.nz [NC]
    RewriteCond %{HTTP_HOST}   !^$
    RewriteRule ^/(.*)         http://avcc.karen.net.nz/$1 [L,R]

```

- Enable the Rewrite module:


>  a2enmod rewrite
>  a2enmod rewrite

- Check Apache configuration file syntax:


>  apache2 -t
>  apache2 -t

- Reload Apache:


>  /etc/init.d/apache2 force-reload
>  /etc/init.d/apache2 force-reload

## Fixing HTTPS redirects

The default MAMS instructions ask for a line in the HTTPS Virtual host configuration which redirects the URL path `"/"` to `/apache2-default/` - which however breaks access to the wiki via https with no path entered (or just using "/", as in "https://avcc.karen.net.nz/").  Comment this line out:

> 1. 
> 1. 
> 1. RedirectMatch ^/$ /apache2-default/

# Configuring MediaWiki for Shibboleth authentication

Following the guide on [shibbolizing mediawiki](/wiki/spaces/BeSTGRID/pages/3818228873), I could get this done pretty easily.  The very essence is just the matter of installing the [ShibAuthPlugin.php](/wiki/spaces/BeSTGRID/pages/3818228612) into `/var/www/extensions`, and configuring `LocalSettings.php` to use the plugin for authentication.

- ShibAuthPlugin: even though at MediaWiki, version 1.1.6 is already available ([http://www.mediawiki.org/wiki/Extension:Shibboleth_Authentication](http://www.mediawiki.org/wiki/Extension:Shibboleth_Authentication), with an older version at [http://meta.wikimedia.org/w/index.php?title=Shibboleth_Authentication&oldid=401874](http://meta.wikimedia.org/w/index.php?title=Shibboleth_Authentication&oldid=401874)), this version is smaller and "looks older" than the version 1.1.3 at www.bestgrid.org, so I'm installing the BeSTGRID one instead.

- Configuring the `$shib_WAYF` variable is tricky: in `shibboleth.xml` in `SessionInitiator Location=...`, the Location attribute (by default `"/WAYF/level-1.federation.org.au"`) must match `"/WAYF/$shib_WAYF"` with the `$shib_WAYF` variable expanded.  Following the name used in case of BeSTGRID wiki, I am using `wayf.bestgrid.org` as the location for the SessionInitiator.

I.e., `/usr/local/shibboleth-sp/etc/shibboleth/shibboleth.xml` says:

``` 

  <SessionInitiator id="wayf.bestgrid.org" <strong>Location="/WAYF/wayf.bestgrid.org"</strong>
      Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
      <strong>wayfURL="https://wayf.bestgrid.org/shibboleth-wayf/WAYF"</strong>
      wayfBinding="urn:mace:shibboleth:1.0:profiles:AuthnRequest" />

```

and `LocalSettings.php` says:

>  $shib_WAYF = "wayf.bestgrid.org";

## Additional configuration

- modified ShibAuthPlugin.php: SSOAddLink: change target URL to plain http
- disable discussions: comment out 'talk' tab definition in `includes/SkinTemplate.php` 661-669
- [disable caching](shibbolize-mediawiki.md): modify `LocalSettings.php`:


>  $wgMainCacheType = CACHE_NONE; 
>  $wgMemCachedServers = CACHE_NONE; 
>  $wgMessageCacheType = CACHE_NONE; 
>  $wgParserCacheType = CACHE_NONE; 
>  $wgCachePages = false;
>  $wgMainCacheType = CACHE_NONE; 
>  $wgMemCachedServers = CACHE_NONE; 
>  $wgMessageCacheType = CACHE_NONE; 
>  $wgParserCacheType = CACHE_NONE; 
>  $wgCachePages = false;

- setup lazy sessions for whole namespace.
	
- while most pages are accessed via `/wiki`, page editing is done via `/index.php`, and other scripts in the top-level namespace may be accessed as well.  Consequently, the whole namespace must be protected with Shibboleth:

``` 

<Location />
  AuthType shibboleth
  ShibRequireSession Off
  require shibboleth
</Location>

```

Note that if other URLs would be protected as well (with more restrictive access control), they must be specified after this Location element (see the [discussion here](vladimirs-general-shibboleth-notes.md)).

- to accept `eduPersonTargetedID` (should we ever need it), I have removed `Scoped="true"` from `/usr/local/shibboleth-sp/etc/shibboleth/AAP.xml`.

## Required attributes: creating service provider description

The absolutely necessary attribute is `eduPersonPrincipalName`.  This attribute is used to initialize the `$shib_UN` (username) variable, used by ShibAuthPlugin to determine whether a user is logged in.  If the attribute is not present, the ShibAuthPlugin will not find out that a Shibboleth session has been established, and MediaWiki will treat the user as if not logged in (and will again display a link to log in).

The additional Shibboleth attributes used by ShibAuthPlugin are `givenName` and `sn` (to construct the user's real name), and `mail` to get the user's email address.

|  Used for        |                          |                                     |               |                  |
| ---------------- | ------------------------ | ----------------------------------- | ------------- | ---------------- |
|  Principal name  |  eduPersonPrincipalName  |  REMOTE_USER                        |  $shib_UN     |  Wiki user name  |
|  Given name      |  givenName               |  HTTP_SHIB_INETORGPERSON_GIVENNAME  |  $shib_RN     |  Real name       |
|  Surname         |  sn                      |  HTTP_SHIB_PERSON_SURNAME           |  $shib_RN     |  Real name       |
|  Email address   |  mail                    |  HTTP_SHIB_INETORGPERSON_MAIL       |  $shib_email  |  Email address   |

Notes:

- all attribute names are in the namespace `urn:mace:dir:attribute-def:` (such as `urn:mace:dir:attribute-def:mail`
- The email address (urn:mace:dir:attribute-def:mail) is by default accepted to `Shib-Person-mail`, we have modified the `AAP.xml` to accept it into `Shib-InetOrgPerson-mail` instead.

``` 
<AttributeRule Name="urn:mace:dir:attribute-def:mail" Header="Shib-InetOrgPerson-mail" Alias="mail">
```

Based on the above list of attributes, the [AVCC SPDescription file](http://www.federation.org.au/FedManager/viewServiceDescriptionFile.do?id=308) ([local download](attachments/Urn_mace_federation_org_au_testfed_uc-avcc_canterbury_ac_nz.xml.txt)) defines *Basic* and *Full* service level for use with ShARPE and Autograph.

# Plan for moving to production

In production, the system should be visible as avcc.karen.net.nz.

Pre-requisites:

- AAF back-channel certificates for avcc.karen.net.nz: done
- ipsCA front-channel HTTPS certificates for avcc.karen.net.nz: pending to be issued.

Plan: phase 1: rename Shibbolized system locally:

- rename host in AAF metadata
- rename host in `hostname` configuration (`/etc/hostname` and the `hostname` command)
- rename host in Apache configuration (ServerName in virtual host definitions)
- change providerId in Shibboleth SP configuration, and change all occurrences of old hostname.
- switch to new certificates in Shibboleth SP configuration
- switch to new certificates in Apache configuration
- add new hostname to `/etc/hosts`

Plan: phase 2: switch over


# Local MediaWiki enhancements

## Logout

Shibboleth supports logging out by means of deleting the shibboleth cookies.

The `ShibUserLogout` function does the job.  There are two steps to enabling a Logout button:

1. In `LocalSettings.php`, uncomment the initialization of the shib_logout variable, and assign it a URL the Logout button should point to.  The URL should call the `logout.php` script with a parameter giving the target URL to return to.

``` 
$shib_logout = $wgScriptPath."/logout.php?target=".$_SERVER['REQUEST_URI'];
```
2. Create `/var/www/logout.php` that calls the `ShibUserLogout` function and redirects the user to the original URL (or displays the front page if no URL was given:

``` 

<?php
# Initialise common code
require_once( './includes/WebStart.php' );

# Initialize MediaWiki base class
require_once( "includes/Wiki.php" );
$mediaWiki = new MediaWiki();

ShibUserLogout();

if (isset($_GET['target'] )) {
   header("Location: ".$_GET['target']);
   # header("Location: ".$wgScript."?title=".$_GET['returnto']);
} else {
   require_once( "index.php" );
}

?>

```

## AccessControl

Install the [AccessControl extension](http://www.mediawiki.org/wiki/Extension:Group_Based_Access_Control).  Most recent version can be downloaded from [http://blog.pagansoft.de/](http://blog.pagansoft.de/)  ([accesscontrol-0.8.zip](http://www.pagansoft.de/download/accesscontrol-0.8.zip) as of January 2008).

Access to pages would be controlled with /accesscontrol/um,,uc,,ua,,sc//accesscontrol/ (replace / with angular brackets)

Group membership would be controlled via pages named Usergroup:groupname

Installation of the extension is described at [BeSTGRID Shibbolized Wiki Group Control](/wiki/spaces/BeSTGRID/pages/3818228907).

Note: when comparing the accesscontrol package source distribution and the version installed at the BeSTGRID wiki, there are no modifications to the code itself, and only minor modifications to the configuration:

- removed variables `$wgUseMediaWikiGroups` and `$wgAccessControlAnonymousGroupName`
- commented-out German labels and uncommented English labels

## Autologin with AccessControl

When a user is not logged in and tries to open a restricted page, he is redirected to the No_Access page.  Even after the user logs in, he still stays on the redirected page, and has to re-enter the URL to the protected page to get there.

While looking at the source code of the AccessControl extension it seemed to me it would be quite easy to modify the doRedirect() function to redirect users who are not logged in to the WAYF server instead... and after logging in, the users would get the desired page.

Yes indeed, it was sufficient to modify the `doRedirect` function to redirect to `getShibSSOLink()` if `$shib_UNh1. null`.  Note that in order to access the global variable `$shib_UN`, one must declare it's use with 

``` 
global $shib_UN;
```

## Properly disable login via local account

The ShibAuthPlugin catches requests targeted to `/Special:Userlogin` and redirects them to the Shibboleth SSO instead.  However, there are other ways of accessing the Userlogin special page, in particular by passing the page name as the `title` argument to the wiki php script.  To avoid circumventing the protection, I have modified `ShibAuthPlugin.php` to check for the page also in the `title` argument, as illustrated below.  Note that the check is done at two different locations in the code, and hence this modification had to be applied twice.

``` 

-               if (strpos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false) {
+               if (strpos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false ||
+                   ( isset($_GET['title']) && $_GET['title']=='Special:Userlogin' ) ) {

```

## Sessions without PrincipalName attribute

If a user logs via Shibboleth, but does not disclose the `eduPersonPrincipalName` attribute, ShibAuthPlugin would consider this user as not logged in.  This could lead to quite unpleasant user experience if the user attempted an action which would redirect him to the Shibboleth SSO.  After logging in without the `eduPersonPrincipalName` attribute, the user would be redirected again to the SSO, resulting into an infinite chain of redirects to the Shibboleth SSO.

I have extended the ShibAuthPlugin to be aware of a Shibboleth session established, even if the session does not provide the `eduPersonPrincipalName` attribute. In this case, the ShibAuthPlugin (and also the accesscontrol extension) won't redirect the user to login again, and will instead proceed with the user staying unauthenticated, and the action declined.  Also, the text on the login button is changed to make the user aware of the problem.  

The redirects affected are the automatic login when editing a page (in ShibAuthPlugin), and the automatic login when accessing a restricted page (in accesscontrol.php as deccribed above).  The information whether a session exists is stored in the `$shib_IdP` variable, set to a non-null value (the entityId of the IdP where the user authenticated).

This value is initialized from the `Shib-Identity-Provider` http header, as shown in the following fragment of code documenting the modifications made to `LocalSettings.php`

>    $shib_UN = $_SERVER\['REMOTE_USER'\];
>  + $shib_IdP = $_SERVER\['HTTP_SHIB_IDENTITY_PROVIDER'\];
>  + if (($shib_UN null) && ($shib_IdP != null)) $shib_LoginHint = 'No PrincipalName attribute received.  Please obtain the attribute and try logging in again.';

## Overview of changes

This section overviews the changes made to the MediaWiki software and its extensions in the changes described in the previous sections:

- Allow Logout (delete Shibboleth session cookie)
- Install AccessControl extension
- Disable Login via local accounts
- Autologin for restricted pages (AccessControl extension)
- Avoid infinite SSO redirects

The changes relative to the standard BeSTGRID instructions for installing Shibbolized MediaWiki are:

In `LocalSettings.php`

``` 

--- LocalSettings.php-sav-2008-01-29    2008-02-01 11:56:35.000000000 +1300
+++ LocalSettings.php   2008-02-01 11:50:48.000000000 +1300
@@ -333,4 +333,7 @@
 #$shib_UN = $_SERVER['HTTP_SHIB_PERSON_COMMONNAME'];
 $shib_UN = $_SERVER['REMOTE_USER'];
+$shib_IdP = $_SERVER['HTTP_SHIB_IDENTITY_PROVIDER'];
+
+if (($shib_UN == null) && ($shib_IdP != null)) $shib_LoginHint = 'No PrincipalName attribute received.  Please obtain the attribute and try logging in again.';

 #Shibboleth doesn't really support logging out very well.  To take care of
@@ -340,4 +343,5 @@
 #instead of deleting the logout link, the extension will change it instead.
 //$shib_logout = $wgScriptPath."/logout.php";
+$shib_logout = $wgScriptPath."/logout.php?target=".$_SERVER['REQUEST_URI'];

 #Turn error reporting back on
@@ -355,2 +359,7 @@
 SetupShibAuth();

+
+######### activate AccessControl extension
+require_once("extensions/accesscontrolSettings.php");
+include("extensions/accesscontrol.php");
+

```

In `accesscontrol.php`:

``` 

--- accesscontrol.php-0.8.orig  2007-09-29 12:20:00.000000000 +1200
+++ accesscontrol.php   2008-01-31 16:15:20.000000000 +1300
@@ -232,23 +232,33 @@
        function doRedirect()
        {
                global $wgOut;
                global $wgAccessControlNoAccessPage;
+               global $shib_UN;
+               global $shib_IdP;

                // some first initialisations
                if (trim($wgAccessControlNoAccessPage)=="") $wgAccessControlNoAccessPage="/index.php/No_Access";

                // make direct redirect, if $wgOut isn't already set (bypassing the cache), bad hack
                if ((is_object( $wgOut )) && (is_a( $wgOut, 'StubObject' )))
                {
-                       header("Location: ".$wgAccessControlNoAccessPage);
+                        if ($shib_UN != null || $shib_IdP != null ) {
+                         header("Location: ".$wgAccessControlNoAccessPage);
+                        } else {
+                          header("Location: ".getShibSSOLink());
+                        }
                        exit;
                }
                else
                {
                        // redirect to the no-access-page if current user doesn't match the
                        // accesscontrol list
-                       $wgOut->redirect($wgAccessControlNoAccessPage);
+                        if ($shib_UN != null || $shib_IdP != null ) {
+                         $wgOut->redirect($wgAccessControlNoAccessPage);
+                        } else {
+                         $wgOut->redirect(getShibSSOLink());
+                        }
                }
        }

        // The callback function for user access

```

In `ShibAuthPlugin.php`:

``` 

--- /root/work/mediawiki/ShibAuthPlugin-1.1.3.php       2008-02-01 12:03:41.000000000 +1300
+++ ShibAuthPlugin.php  2008-02-01 11:05:49.000000000 +1300
@@ -283,6 +283,7 @@
 function SetupShibAuth()
 {
         global $shib_UN;
+        global $shib_IdP;
         global $wgHooks;
         global $wgAuth;
        global $shib_Register_url;
@@ -295,7 +296,8 @@
                 $wgHooks['AutoAuthenticate'][] = 'AutoAuth'; /* Hook for magical authN */
                 $wgHooks['PersonalUrls'][] = 'KillLogout'; /* Disallow logout link */
                 $wgAuth = new ShibAuthPlugin();
-               if (strpos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false) {
+               if (strpos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false ||
+                   ( isset($_GET['title']) && $_GET['title']=='Special:Userlogin' ) ) {
                         header("Location: ".$wgScriptPath);
                        exit;
                }
@@ -305,17 +307,27 @@
                 $wgHooks['PersonalUrls'][] = 'SSOLinkAdd';
                 if(isset($_GET['action']))
                 {
-                        if($_GET['action']=='edit')
+                        if($_GET['action']=='edit' && $shib_IdP==null)
                         {
                          header("Location: ".getShibSSOLink());
                          exit;
                         }
                 }
-               if (strpos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false) {
-                        header("Location: ".getShibSSOLink());
+               if (strpos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false ||
+                   ( isset($_GET['title']) && $_GET['title']=='Special:Userlogin' ) ) {
+                        if ($shib_IdP == null) {
+                           header("Location: ".getShibSSOLink());
+                        } else {
+                            if (isset($_GET['returnto'])) {
+                                header("Location: " . $wgScriptPath."index.php?title=".$_GET['returnto']);
+                            } else {
+                               header("Location: ". $wgScriptPath );
+                            };
+                        };
                        exit;
                 }
-               ShibUserLogout();
+               // not really necessary to kill the session if no attributes are received
+                // ShibUserLogout();
        }

        if(isset($_GET['title']) && isset($_GET['type']))

```

Created `logout.php` in MediaWiki root (`/var/www`):

``` 

<?php
# Initialise common code
require_once( './includes/WebStart.php' );

# Initialize MediaWiki base class
require_once( "includes/Wiki.php" );
$mediaWiki = new MediaWiki();

ShibUserLogout();

if (isset($_GET['target'] )) {
   header("Location: ".$_GET['target']);
   # header("Location: ".$wgScript."?title=".$_GET['returnto']);
} else {
   require_once( "index.php" );
}

?>

```

# Upgrade to MediaWiki 1.13

Please see the detailed notes on [Re-installing ShibAuthPlugin after upgrading AVCC MediaWiki to 1.13](/wiki/spaces/BeSTGRID/pages/3818228786)

# Debian notes

I am new to administering a Debian system.

I found the following commands useful as equivalents of their RedHat counterparts:

>  **To start and stop system services, use**`invoke-rc.d`* instead of `service`
>  **To manage system services (symlinks in **`/etc/rc``.d`), use `update-rc.d`

- **To remove the symlinks, use**`update-rc.d -f shibboleth remove`*

>  **Install packages from a repository:**`apt-get install`* instead of `yum install`
>  **List all installed packages:**`dpkg -l`* instead of `rpm -qa` 
>  **List all files in an installed package:**`dpkg -L package`* instead of `rpm -ql package`
>  **Find package owning a file:*{{dpkg -S filepattern}}** instead of `rpm -qf filename`

- Add a new user with administrator privileges
	
- Adding a new user is simple:

``` 
adduser -u 12458 vme28
```
- Sudo allows all users in group `admin` to run any command.  Make the new user be a member of ever ygroup an existing administrator (`avcc`) is (expect for his home group): 

``` 
usermod -G "$( echo $( grep avcc /etc/group  | cut -d : -f 1 | grep -v avcc ) | tr ' ' ',' )" vme28
```
