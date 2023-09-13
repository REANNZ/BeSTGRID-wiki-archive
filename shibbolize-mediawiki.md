# Shibbolize MediaWiki

# Introduction

[MediaWiki](http://www.mediawiki.org/wiki/MediaWiki) is a common and popular wiki for the collaborative sharing of knowledge.

MediaWiki traditionally authenticate users from a locally maintained database, where users can

self-register to personalise content and receive alerts. Out of the box, Mediawiki doesn't restrict

anonymous users from editing content, but this can be configured.

Using the local database for authentication and authorisation relies on users to self-register, but when

combined with [Shibboleth](http://shibboleth.internet2.edu/) the authentication and authorisation burden can be removed from

the user and the wiki.

This article describes how one might go about shibbolising the MediaWiki.

# Aim

The aim of this article is to document and communication the configuration of MediaWiki in

order to meet the following security requirements:

- Reading of articles is available to the public users.
- Editing of articles and discussions is available to registered users (via Shibboleth) only.
- Shibboleth is the only available authentication mechanism for MediaWiki.

# Prerequisites

This instruction is for MediaWiki 1.7

- PHP 5.x
- MySQL 4.x
- Apache 2.x
- Shibboleth Service Provider 1.3, successfully installed and correctly configured (see the [Shibboleth Service Provider Setup](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Shibboleth_Service_Provider_Setup_-_RHEL4&linkCreation=true&fromPageId=3816950921) article for more details)

# Lazy Sessions

The MediaWiki extension is designed to use Lazy Session which allows for the public reading of articles. The next paragraph is directly quoted from [Shibboleth Deployment Background](https://spaces.internet2.edu/display/SHIB/DeploymentBackground):

*Shibboleth >=1.2 also supports so-called lazy session establishment, in which the resource may be accessed without prior authentication. This means the application must be intelligent enough to determine whether authentication is necessary, and then construct the proper URL to initiate a browser redirect to request authentication; if the application determines none is necessary or uses other authorization mechanisms, then the request for authentication may not need to be triggered. This complex functionality is mostly useful to protect a single URL with different access mechanisms, or to require authenticated access only in instances where the application deems it necessary.*

# Shibboleth Service Provider Configuration

## Configure the Shibboleth Service Provider

Where Are You From (WAYF) is optional for the installation. Edit the shibboleth.xml file (usually in */etc/shibboleth*) to configure a *Session Initiator* for your federation. The examples below illustrate how to configure it with or without a WAYF service.

### With WAYF installed

An example configuration with WAYF service is shown below:

``` 

...
 <SessionInitiator id="UoATestFedWayf" Location="/WAYF/testfed.auckland.ac.nz"
                                Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
                                wayfURL="https://testfed.auckland.ac.nz/shibboleth-wayf/WAYF"
                                wayfBinding="urn:mace:shibboleth:1.0:profiles:AuthnRequest"/>
...

```

### Without WAYF installed

An example configuration without WAYF service is shown below:

``` 

...
<SessionInitiator  id="UoATestFedDirect" Location="/WAYF/idp.auckland.ac.nz"
                                Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
                                wayfURL="https://idp.auckland.ac.nz/shibboleth-idp/SSO"
                                wayfBinding="urn:mace:shibboleth:1.0:profiles:AuthnRequest"/>
...

```

Configure your application (i.e. MediaWiki) and enable Lazy Sessions using the shibboleth.xml.

The example configuration snippit is shown below, with the following notes/assumptions:

>  **MedaiWiki directory is installed into*web_root**/wiki. e.g. /var/www/html/wiki

- Lazy Session : requireSession="false"
- Full Session : requireSession="true"
- Only allow HTTPS access : redirectToSSL="443"

Configure the parts of the web content on the server you wish to protect using Shibboleth.

This is done in the shibboleth.xml also.

An example configuration snippit is shown below:

``` 

<Host name="scooby.enarc.auckland.ac.nz" redirectToSSL="443">
    <Path name="wiki" authType="shibboleth" requireSession="false"/>
</Host>

```

## Configure Apache Web Server

You must now configure Apache to handle shibboleth authentication for MediaWiki, and this is done

in the apache configuration, which might be specific to shibboleth (i.e. in etc/httpd/conf.d/shib.conf

or in etc/httpd/conf/httpd.conf).

``` 

<Location /wiki>
  AuthType shibboleth
  ShibRequireSession Off
  require shibboleth
</Location>

```

You must restart Apache for these changes to take effect.

# Install MediaWiki

- Download MediaWiki from [http://www.mediawiki.org/wiki/Download](http://www.mediawiki.org/wiki/Download) (Only version 1.7 and 1.10 have been tested)


>  **Extract it at*web_root**/wiki
>  **Extract it at*web_root**/wiki

- Browse the index.php page at 

``` 
https://<your_domain>/wiki/index.php
```
- Follow the MediaWiki setup instruction.

# The Shibboleth Auth Extension

## Acknowledgment

The extension below was originally written by the Administrative Computing and Telecommunications Dept of the University of California and documented at [Shibboleth Authentication -Meta](http://meta.wikimedia.org/wiki/Shibboleth_Authentication)

## Installation

Download [ShibAuthPlugin.php](/wiki/spaces/BeSTGRID/pages/3816950660) and save this extension into **web_root**/wiki/extensions/

## Configuration

Place the following code into LocalSettings.php file.

``` 

##Shibboleth Authentication Stuff
#Load ShibAuthPlugin
require_once('extensions/ShibAuthPlugin.php');

#Last portion of the shibboleth WAYF url for lazy sessions.
#This value is found in your shibboleth.xml file on the setup for your SP
#WAYF url will look something like: /Shibboleth.sso/WAYF/$shib_WAYF
$shib_WAYF = "wayf.bestgrid.org";

#Is the assertion consumer service located at an https address (highly recommended)
# Default for compatibility with previous version: false
$shib_Https = true;

#Prompt for user to login
$shib_LoginHint = "Login via BeSTGRID Federation";

# Where is the assertion consumer service located on the website?
# Default: "/Shibboleth.sso"
$shib_AssertionConsumerServiceURL = "/Shibboleth.sso";

#Do you want to map in names from Shibboleth data?
#Feel free to use extra PHP code to munge the variables if you'd like
#Additionally if you wish to only map some of the name data, set this to true
#and either blank shib_RN and shib_email or comment them out entirely.
$shib_map_info = "true";

#Ssssh.... quiet down errors
$olderror = error_reporting(E_ALL ^ E_NOTICE);

#Map Real Name to what Shibboleth variable(s)?
$shib_RN = ucfirst(strtolower($_SERVER['HTTP_SHIB_INETORGPERSON_GIVENNAME'])) . ' '
         . ucfirst(strtolower($_SERVER['HTTP_SHIB_PERSON_SURNAME']));

#Map e-mail to what Shibboleth variable?
$shib_email = $_SERVER['HTTP_SHIB_INETORGPERSON_MAIL'];

#This is required to map to something
#You should beware of possible namespace collisions, it is best to chose
#something that will not violate MW's usual restrictions on characters
#Map Username to what Shibboleth variable?
#$shib_UN = $_SERVER['HTTP_SHIB_PERSON_COMMONNAME'];
$shib_UN = $_SERVER['REMOTE_USER'];
#Shibboleth doesn't really support logging out very well.  To take care of
#this we simply get rid of the logout link when a user is logged in through
#Shib.  Alternatively, you can uncomment and set the variable below to a link
#that will either clear the user's cookies or log the user out of the Idp and
#instead of deleting the logout link, the extension will change it instead.
//$shib_logout = $wgScriptPath."/logout.php";

#Turn error reporting back on
error_reporting($olderror);

$wgGroupPermissions['*']['read'] = true;
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['createpage'] = false;
$wgGroupPermissions['*']['createtalk'] = false;

$shib_Register_hint = 'Create a new account';
$shib_Register_url = 'https://idp.bestgrid.org/registry/';

#Activate Shibboleth Plugin
SetupShibAuth();

```

# Shibboleth Extension Functionality

The Shibboleth extension allows user to authenticate using Shibboleth in two ways

- by using the 'Login via Shibboleth SSO' link at the top right of the wiki, or
- when editing an article or discussion

# Disable Cache Function for MediaWiki

- Edit the LocalSetting.php and add the following definition ($wgMainCacheType is defined already)

1. 
1. Shared memory settings

$wgMainCacheType = CACHE_NONE;

$wgMemCachedServers = CACHE_NONE;

$wgMessageCacheType = CACHE_NONE;

$wgParserCacheType = CACHE_NONE;

$wgCachePages = false;

# Disable "Discussion" tab for MediaWiki

- Open up the \includes\SkinTemplate.php file and look for:

``` 

 $content_actions['talk'] = $this->tabAction(
                                $talkpage,
                                'talk',
                                $this->mTitle->isTalkPage() && !$prevent_active_tabs,
                                '',
                                true);


```

and comment this as the followings:

``` 

/*
 $content_actions['talk'] = $this->tabAction(
                                $talkpage,
                                'talk',
                                $this->mTitle->isTalkPage() && !$prevent_active_tabs,
                                '',
                                true);

*/

```

# Use HTTP on front-end communication while maintaining attribute assertion on HTTPS

HTTPS would slow down the server performance because SSL overhead. Therefore it might be useful to use HTTP protocol on front-end communication while maintaining the attribute assertion on HTTPS for security reason.

## Modification on mediawiki

Replace the original **$personal_urls****['login'](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%27login%27&linkCreation=true&fromPageId=3816950921)** value in SSOLinkAdd method with following, (i.e. change the target from https:// to http://:

``` 

     $personal_urls['login'] = array(
                'text' => $shib_LoginHint,
                'href' => ($shib_Https ? 'https' :  'http') .'://' . $_SERVER['HTTP_HOST'] . $shib_AssertionConsumerServiceURL . 
"/WAYF/" . $shib_WAYF . '?target=http://' . $_SERVER['HTTP_HOST'] . $pageurl, );


```

Change original **$target** value in getShibSSOLink method from ($shib_Https ? 'https' :  'http').'://' to 'http://'.

## Modification on Shibboleth SP configuration

Edit Shibboleth SP configuration (usually is /etc/shibboleth/shibboleth.xml) and set handlerSSL="true".

# References

- [Shibboleth Home - Internet 2](http://shibboleth.internet2.edu/)
- [Shibboleth](/wiki/spaces/BeSTGRID/pages/3816951017)
- [Shibboleth Service Provider Setup - RHEL4](/wiki/spaces/BeSTGRID/pages/3816950611)
- [MediaWiki](http://www.mediawiki.org/wiki/MediaWiki)
- [Shibboleth Deployment Background](https://spaces.internet2.edu/display/SHIB/DeploymentBackground)
- [Shibboleth Authentication -Meta](http://meta.wikimedia.org/wiki/Shibboleth_Authentication)
