# Drupal5-Installation

# Introduction

This article summarized my installation steps of Drupal 5.2. For a detailed and up-to-date installation instruction, please look at the [Drupal online documentation](http://drupal.org/node/258)

# Prerequisites

**NOTE:** The followings requirements are the system setup for New Zealand Social Science Data Service (NZSSDS, formerly known as SSDASH). However you have check the [Drupal online system requirments](http://drupal.org/requirements) to make sure your system are matched the requirments.

- OS
- CentOS release 4.4 (Equivalent to Red Hat Enterprise Linux AS release 4)

;Web Server

- Apache 2.0.52

;PHP

- 5.1.6

;Database

- MySQL 5.0.48

# Installing Drupal

- Download Drupal 5.2 (the latest version at the time of writing)

``` 
http://ftp.drupal.org/files/projects/drupal-5.2.tar.gz
```

- Extract Drupal and move to /var/www/html

``` 

tar -xfz drupal-5.2.tar.gz
mv drupal-5.2 drupal-5.2/.htaccess /var/www/html

```

>  **Note

- Remember to keep a clean copy of drupal-5.2/sites/default/settings.php for multiple-sites setup in the later section

# Create Database

``` 

$mysql -u root -p
mysql>create database ssrgDatabase;
mysql>GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON ssrgDatabase.* TO
'username'@'localhost' IDENTIFIED BY 'password';
mysql>exit

```

# Install and configure Drupal

- Open your browser to the base URL of your website (e.g. www.nzssds.org). You will be presented with the "Database Configuration" page. Follow the instruction and complete the installation steps
- Please go to [http://drupal.org/node/176034](http://drupal.org/node/176034) for detailed information.
- Detailed configuration information: [http://drupal.org/node/176038](http://drupal.org/node/176038)
