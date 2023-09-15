# Productionize BeSTGRID Wiki

# Introduction

This step-by-step document describes how to productionize BeSTGRID Wiki.

# Prerequisites

- An empty machine with [CentOS 3/4 Linux](http://www.centos.org/) installed. CentOS is an open source free GNU Linux distribution which aims to be 100% compatible with and based on Red Hat Enterprise Linux.

- PHP 5.

``` 
yum install php php-mysql --enablerepo=centosplus
```

- MySQL Server 5.

``` 
yum install mysql-server --enablerepo=centosplus
```

- Apache 2

``` 
yum install httpd --enablerepo=centosplus
```

- Diff

``` 
yum install diffstat diffutils --enablerepo=centosplus
```

- Check out the archive production wiki, Shibbolized and re-branded wiki and MySQL dump file from BeSTGRID subversion repository 

``` 
https://svn.csi.ac.nz/svn/bestgrid/themes/collab grid/BeSTGrid Wiki
```

- Download the latest version [Mediawiki](http://www.mediawiki.org). At the time of writing, it is [1.10.1](http://download.wikimedia.org/mediawiki/1.10/mediawiki-1.10.1.tar.gz)

# Install MediaWiki

- Start MySQL Server and login as a root user

``` 

[root@wikiprod ~]# /etc/init.d/mysqld start
Starting MySQL:                                            [  OK  ]
[root@wikiprod ~]# mysql -u root
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.0.44 Source distribution

Type 'help;' or '\h' for help. Type '\c' to clear the buffer.

mysql>

```

- Create a MySQL database instance and a database user account for BeSTGRID Wiki

``` 

mysql> create database bestgrid;
Query OK, 1 row affected (0.00 sec)

mysql> grant all privileges on bestgrid.* to 'bestgriduser'@'localhost' identified by 'bestgridpassword';
Query OK, 0 rows affected (0.00 sec)

mysql> exit
Bye


```

- Import the wiki data from the MySQL dump file(assume the file is stored at /home/wiki/bestgrid.sql)

``` 

[root@wikiprod ~]# mysql -p -h localhost bestgrid -u bestgriduser < /home/wiki/bestgrid.sql
Enter password:

```

- Confirm if the file has been successful imported.

``` 

[root@wikiprod ~]# mysql -p -h localhost bestgrid -u bestgriduser
Enter password:
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.0.44 Source distribution

Type 'help;' or '\h' for help. Type '\c' to clear the buffer.

mysql> show tables;
+--------------------+
| Tables_in_bestgrid |
+--------------------+
| archive            |
| categorylinks      |
| externallinks      |
| hitcounter         |
| image              |
| imagelinks         |
| interwiki          |
| ipblocks           |
| job                |
| logging            |
| math               |
| objectcache        |
| oldimage           |
| page               |
| pagelinks          |
| querycache         |
| recentchanges      |
| revision           |
| searchindex        |
| site_stats         |
| templatelinks      |
| text               |
| trackbacks         |
| transcache         |
| user               |
| user_groups        |
| user_newtalk       |
| validate           |
| watchlist          |
+--------------------+
29 rows in set (0.00 sec)

mysql>

```

- Extract the new downloaded MediaWiki

``` 
tar xvfz mediawiki-1.10.1.tar.gz
```

- Move the extracted MediaWiki directory to web root directory

``` 
mv mediawiki-1.10.1 /var/www/html
```

- Open your browser and go to the server and then follow the setup instruction in order to complete the setup.

- Copy the extensions, skins, images directories from archive production wiki directory to the new installed wiki directory

- Merge both LocalSettings.php and copy the MathSettings.php to the web root. Add the following configurations to LocalSetting.php.

``` 

$wgStylePath        = "$wgScriptPath/skins";
$wgStyleDirectory   = "$IP/skins";
$wgLogo             = "$wgStylePath/common/images/lg_temp-wiki.gif";

$wgEmergencyContact = "bestgrid@math.auckland.ac.nz";
$wgPasswordSender       = "bestgrid@math.auckland.ac.nz";

# Math Settings
require_once( "MathSettings.php" );

```

- Change the permission for images directory that allows Apache to write to it.

# Post-install configuration

## Disable user to select other skins

- Remove all PHP files excepts MonoBook.php MonoBook.deps.php in /var/www/html/skins directory

## Editing the main title in front page

Replace 

``` 
{| style="position:absolute; top:130px; left:170px; width:100%; background: white; color:#888;" valign="middle"
```

with

``` 
{| style="position:absolute; top:130px; left:170px; width:100%; background: white; color:#888;" valign="middle"
```

## Remove 'Discussion' tab

- Edit includes/SkinTemplate.php file and look for:

``` 

 $content_actions['talk'] = $this->tabAction(
                                $talkpage,
                                'talk',
                                $this->mTitle->isTalkPage() && !$prevent_active_tabs,
                                '',
                                true);


```

and then comment this as followings:

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

# Shibbolize MediaWiki

- [Install Shibboleth Service Provider and configure it](shibboleth-service-provider-setup-rhel4.md)

- Setup a cron job to download AAF level-1-metadata regularly.

``` 

*/10    *       *       *       *  wget http://www.federation.org.au/level-1/level-1-metadata.xml -O /etc/shibboleth/level-1-metadata.xml

```

- Copy ShibAuthPlugin.php to extension directory

- Add the following line to LocalSettings.php

``` 

#Load ShibAuthPlugin
require_once('extensions/ShibAuthPlugin.php');

#Last portion of the shibboleth WAYF url for lazy sessions.
#This value is found in your shibboleth.xml file on the setup for your SP
#WAYF url will look something like: /Shibboleth.sso/WAYF/$shib_WAYF
$shib_WAYF = "wayf.test.bestgrid.org";
//$shib_WAYF = "openidp.auckland.ac.nz";

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
$shib_Register_url = 'https://openidp.test.bestgrid.org/registry/';

#Activate Shibboleth Plugin
SetupShibAuth();



```

# Common Problems

## Image Upload Problems

There are number of possible reasons that may cause the image upload problem for MediaWiki. 

- Make sure MediaWiki is allowed this type of extension, i.e. added the format extension in LocalSettings.php

``` 
$wgFileExtensions = array( 'png', 'gif', 'jpg', 'jpeg', 'ppt', 'doc', 'pdf' );
```

- Allow upload

``` 

$wgEnableUploads                = true;
$wgUseImageResize               = true;
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";
$wgUploadPath       = "$wgScriptPath/images";
$wgUploadDirectory  = "$IP/images";

```

- Add image format to MIME.type (The example below is to add PNG image format type). You've to insert the following line to  /etc/httpd/conf/magic

``` 

# PNG
1       string          PNG             image/png

```

- Install ImageMagick

``` 

yum install ImageMagick --enablerepo=centosplus

```

- Setup correct timezone by insert the following configuration at LocalSettings.php

``` 

$wgLocaltimezone = 'NZDT';
$wgLocalTZoffset = date("Z") / 60;

```
