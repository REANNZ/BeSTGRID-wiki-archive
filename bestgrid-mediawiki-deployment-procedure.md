# BeSTGRID Mediawiki Deployment procedure

# Introduction

This article describes how to deploy the BeSTGRID Mediawiki from current production site to a new Shibbolized Mediawiki

# Prerequisites

- Shibboleth SP installed
- Latest Shibbolized Mediawiki installed (1.10.1 is the latest version at the time of writing)
- New skin patched

Please have a look [here](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Shibbolize_MediaWiki&linkCreation=true&fromPageId=3816950635) for more details

# Setup automated SSH

This section explains the steps required to setup automated SSH between old production (remote) server and new production (local) server. Please substitute the server url belows with appropriate values. In this case:

- remote server = www.bestgrid.org
- local server = wiki.bestgrid.org

- Generate a private/public key pair in local server

``` 
ssh-keygen -t rsa
```

Note

Leave file name to default and passphrase empty so that can be access by script without password.

;Copy the public key to the remote server

``` 
scp ~/.ssh/id_rsa.pub www.bestgrid.org: 
```

;Add local key to remote server trusted key

**Log on to the remote server and if there has never been a key created for this user on the remote machine, run the *ssh-keygen -t rsa** just to get the key directory and stuff set up

- Concatenate the new key to the authorized_keys file:

``` 
cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
```
- You may have to do this to the keys file:

``` 
chmod 644 ~/.ssh/authorized_keys
```

;Test it by logging into the remote machine without password

``` 
ssh wiki@www.bestgrid.org
```

;Setup the similar way from remote server to local server

# Create deployment procedure

- Create a working directory
- Copy the new installed Shibbolized wiki to the working directory

``` 
cp -r /var/www/html wiki
```
- Edit AdminSettings.php to reflect local settings.
- Copy [addScopeToMediaWikiUsers.php](/wiki/spaces/BeSTGRID/pages/3816950886) to the working directory and  modified username, password and database to reflect correct local settings.
- Copy [upgradeScript.sh](/wiki/spaces/BeSTGRID/pages/3816950805) to the working directory and then grant execution privilege to owner

``` 
chmod u+w upgradeScript.sh 
```
- You can setup a cron job to run this script or run it manually.
