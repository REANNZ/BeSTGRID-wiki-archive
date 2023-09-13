# Upgrade BeSTGRID Wiki

# Introduction

This article represents how to upgrade BeSTGRID Wiki from a clean VM. The VM has CentOS 4.5 installed

# Install Apache, MySQL and PHP

There are many ways to install above softwares, such as install from source. However, these softwares can be install ed by using yum.

``` 
yum -y install httpd mysql-server php php-mysql php-gd --enablerepo=centosplus
```

Perform the following steps to make sure the installation is successful.

- Edit /etc/httpd/conf/httpd.conf by append "index.php" to the "DirectoryIndex" attribute, so Httpd server is enable to recognize index.php as an index page.
- Start Httpd server /etc/init.d/httpd start
- Start MySQL server /etc/init.d/mysql start
- Write a php script and place it in the web root (usually at /var/www/html). This page will displays all PHP-related information, make sure MySQL is enabled

``` 

<?php
   phpinfo();
?>

```

# Install Mediawiki

## Download Mediawiki

- Download the latest Mediawiki from [http://www.mediawiki.org/wiki/Download](http://www.mediawiki.org/wiki/Download)
- The latest release version of Mediawiki is 1.10.0 at the time of writing

## Setup Mediawiki database

- Check up the mysqldump script (bestgrid.sql) from SVN

``` 
https://support.e-learnings.co.nz/svn/bestgrid/themes/collab grid/BeSTGrid Wiki
```
- Create a database instance for BeSTGRID Wiki as the following

``` 

#mysql -u root -p
(here I enter 'my_root_password' to get through the mysql prompt)

mysql> create database bestgrid;
Query OK, 1 row affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON bestgrid.* to 'bestgriduser'@'localhost' identified by 'password' with grant option;
Query OK, 0 rows affected (0.00 sec)

mysql> exit
Bye

```
- Login to MySQL server as bestgriduser and import the bestgrid.sql file (assume it stores at /home/shib/bestgrid.sql)

``` 

#mysql -u bestgriduser -p

Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 53 to server version: 5.0.27

Type 'help;' or '\h' for help. Type '\c' to clear the buffer.
mysql> use bestgrid
Database changed
mysql> source /home/shib/bestgrid.sql
.....

```

## Install Wiki

- Extract MediaWiki file

``` 
tar xvfz mediawiki-1.10.0.tar.gz
```

- Move it to the web root (/var/www/html).

- Setup your wiki through your web browser

## Upgrade the existing wiki

- Check out the old MediaWiki from SVN
- Copy the files under extension/ skins/ and MathSettings.php from the old wiki directory to the new wiki directory
- Add the following lines to the LocalSettings.php of new wiki

``` 
# My modification
# Math Settings
require_once( "MathSettings.php" );

$wgStylePath        = "$wgScriptPath/skins";
$wgStyleDirectory   = "$IP/skins";
$wgLogo             = "$wgStylePath/common/images/BeSTGRID.png";

$wgUploadPath       = "$wgScriptPath/images";
$wgUploadDirectory  = "$IP/images";

```
