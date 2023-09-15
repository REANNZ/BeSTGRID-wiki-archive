# Administering the DataFabric

This page should document tasks system administrators may be required to do on the DataFabric.

An additional resource one should consult when seeking more information beyond what's documented here is:

- ARCS DataServices iRODS documentation: [http://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS](http://projects.arcs.org.au/trac/systems/wiki/DataServices/iRODS)
- ARCS "DataFabricScripts" svn repository:
	
- browser access [http://projects.arcs.org.au/trac/systems/browser/trunk/dataFabricScripts](http://projects.arcs.org.au/trac/systems/browser/trunk/dataFabricScripts)
- svn access [http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts](http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts)

# User administration

## Linking DN and sharedToken in a single account

The DataFabric automatically creates an account for a user on first access - and if users have multiple identities (such as a Shibboleth login AND an APACGrid certificate), the DataFabric would create two separate accounts.

It is possible to list the two identities together.  Ideally, the user should request linking the two identities before the second iRODS account is created - but that still can be worked around (by deleting the other account) and adding the authentication information for both identities to the user's primary account.

Before proceeding, gather information on both user identities and **make sure** these two identities represent the same person.

The information to be gathered is:

1. User's full DN from the X509 APACGrid certificate.
	
- Can be retrieved with 

``` 
openssl x509 -subject -noout -in $HOME/.globus/usercert.pem
```
2. User's Common Name (CN) and the Shared Token from the Shibboleth login.
	
- Can be gathered by asking the user to access [http://df.bestgrid.org/shared-token/](http://df.bestgrid.org/shared-token/)
		
- After visiting this page, the Shibboleth attributes received by the DataFabric are stored in `ngdata.canterbury.ac.nz:/var/www/html/shared-token/.htlog/sharedtoken-sso.log`
3. User's iRODS username (displayed in the web interface, can be looked up in iRODS)

The following steps would link the user's two identities together - and must be performed with an iRODS administrator login (typically the `rods` account).

- If the user's iRODS username is not known, look it up by listing all user accounts:

``` 
iadmin lu
```
- Display detailed information about the user with:

``` 
iadmin lu <username>
```
- List all authentication information associated with the user:

``` 
iadmin lua <username>
```

- If the user got accidentally two accounts created, agree with the user on which of the accounts to delete - and delete the account with:

``` 
iadmin rmuser <username>
```
- Note: the account must not own any files in order to be deleted.  Make sure all files are deleted (or moved to a different account) and also empty the trash for the user - can be done with:

``` 
irmtrash -M -u <username>
```

- To add a user's DN to an existing account (typically created for a Shibboleth login), run:

``` 
iadmin aua <username> <userDN>
```
- The user DN would have to be quoted to be passed as a single argument.  Example:

``` 
iadmin aua vladimir.mencl '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl'
```

- To add a user's Shibboleth identity to an existing account (typically created for an X509 certificate):
	
- Add the user's SLCS-based DN to the irods account with 

``` 
iadmin aua <username> <userDN>
```
- Example:

``` 
iadmin aua vladimir.mencl '/DC=nz/DC=org/DC=bestgrid/DC=slcs/O=University of Canterbury/CN=Vladimir Mencl -2vdKb_4CoiSg1P_uGfB9YTRJLo'
```
- Note: to construct the exact DN from the CN and SharedToken (and the user's institution), refer to [https://slcs1.arcs.org.au/idp-acl.txt](https://slcs1.arcs.org.au/idp-acl.txt) for the institution-specific prefix.  The SLCS DN is then constructed as `"$institutionPrefix/CN=$cn $sharedToken"`
- Add the user's shared token to the account information with:

``` 
iadmin moduser <username> info '<ST>shared-token-value</ST>'
```
- Example:

``` 
iadmin moduser stuart.charters info '<ST>sEKLKTK5obsy6qGN4GsF1PFJy3w</ST>'
```

Now the user should be able to login with either of the two identities and both should map to the same DataFabric/iRODS account.

## Deleting a user account

Note: there should in general be no reason for this task - unless the account was created in error.  An account can only be deleted when it has no files in the home directory, so this operation in general can only be done on accounts that were just created - in an incorrect way.  (E.g., when the username that got assigned to the account, e.g. because the input parameter (CN) had an incorrect value).

After an account is deleted, it may become impossible (even for the iRODS administrators) to access files (or collections) that **only** this account had access to - i.e., if this account was the only account allowed to access the files.  Therefore, carefully examine the account's home directory (and other directories where it might own collections, see below).

Run the following commands as the "rods" user to make sure at least the home directory and other known directories do not contain any files or collections:

``` 

irodsuser=<username>
clientUserName=$irodsuser ils /BeSTGRID/home/__PUBLIC/$irodsuser
clientUserName=$irodsuser ils /BeSTGRID/home/__INBOX/$irodsuser
clientUserName=$irodsuser ils /BeSTGRID/trash/home/$irodsuser
clientUserName=$irodsuser ils /BeSTGRID/home/$irodsuser

```

Assuming all the directories are clean (OK if they do not exist):

1. Remove the first two of the directories manually (if they exist), then delete the user (this removes the home directory and the trash folder):

``` 

irodsuser=<username>
clientUserName=$irodsuser irm -f -r /BeSTGRID/home/__PUBLIC/$irodsuser
clientUserName=$irodsuser irm -f -r /BeSTGRID/home/__INBOX/$irodsuser
clientUserName=$irodsuser irm -f -r /BeSTGRID/home/$irodsuser/__autodelete__
iadmin rmuser $irodsuser

```

Even simpler:

``` 

irodsuser=<username>
irm -f -r /BeSTGRID/home/__PUBLIC/$irodsuser
irm -f -r /BeSTGRID/home/__INBOX/$irodsuser
iadmin rmuser $irodsuser

```

# Setting up a project

**Note: Mounted collections (an iRODS 2.3+ feature allowing e.g. to link a project directory from /BeSTGRID/home to /BeSTGRID/projects) are not supported by the Jargon library (and consequently Davis) yet (Davis 0.9.2 as of 2010-08-10, ).  Hence, the users should be instructed to access their project solely via /BeSTGRID/home, and the collections under /BeSTGRID/projects should not be used.** |

The DataFabric is suitable for hosting the data for collaborative projects.  In this setting, the project data should be stored in a collection under `BeSTGRID/home`, named after the project.  All of the users collaborating on the project would be members of a project group, and the group membership would give them access to the project directory.

Setting up a project consists of:

- Creating the project group (this also creates a home directory for the group, which will be the project directory).
- Adding all the users to the project group
- Giving the project full control over the directory (and setting the inherit flag to make the same permissions apply to newly created files and folders).

Before setting up the project, get the following information from the project leader:

- Project acronym/codename: this would be used both for the iRODS group and for the project collection (directory).
- List of project members.
	
- Ask the project leader and all project members to login to the DataFabric at least once - so that their account gets created.
- Optionally: get an estimate of the total space used for the project.

Record the project in [List of DataFabric projects](/wiki/spaces/BeSTGRID/pages/3818228617)

The following commands should be run as an iRODS administrator (typically the `rods` user):

1. Create the project group:

``` 
iadmin mkgroup <project group name>
```
2. Add the users to the project group: run this command for each user working on the project:

``` 
iadmin atg <project group name> <username>
```
- Note: if not all project members haven an iRODS account yet, add them to the group later - no problem with that.
3. The project group got a home collection created as `/BeSTGRID/home/``project group name`, with the group having ownership on that group. Make the permissions propagate to all subfolders / files:

``` 
ichmod inherit /BeSTGRID/home/<project group name>
```
- If this fails, with an error message saying rods user does not have access to that directory, tell `ichmod` to do the operation *as* one of the users already in that group:

``` 
clientUserName=<username> ichmod inherit /BeSTGRID/home/<project group name>
```
4. Check the permissions with 

``` 
ils -A /BeSTGRID/home/<project group name>
```
- The output should list the project group as having the `own` privilege (all member user accounts will be listed too) and should say: `Inheritance - Enabled`

Example: setting up the BCprognosis project for Mik Black, so far making Mik Black the only member of the group:

>  iadmin mkgroup *BCprognosis*
>  iadmin atg *BCprognosis* *mik.black*
>  clientUserName=*mik.black* ichmod inherit /BeSTGRID/home/*BCprognosis*
>  ils -A /BeSTGRID/home/*BCprognosis*

The output from `ils -A /BeSTGRID/home/``BCprognosis` is:

``` 

/BeSTGRID/home/BCprognosis:
        ACL - BCprognosis#BeSTGRID:own   mik.black#BeSTGRID:own   
        Inheritance - Enabled

```

## Making a project publicly accessible

To make a the files and directories in a project publicly readable:

- give the group `public` and the user `anonymous` read access to the project collection:

``` 
clientUserName=<username> ichmod read public /BeSTGRID/home/<project collection name> ; clientUserName=<username> ichmod read anonymous /BeSTGRID/home/<project collection name>
```
- add the project collection to anonymously accessible collections: add this project home directory to the list of collections in `anonymousCollections` (comma separated) in `/opt/davis/davis/webapps/root/WEB-INF/davis-host.properties`.  Example:


>  anonymousCollections=**/BeSTGRID/home/GeoFabric,**/ARCS/projects/public,/ARCS/projects/open,/BeSTGRID/projects/public,/BeSTGRID/projects/open,/BeSTGRID-DEV/projects/public,/BeSTGRID-DEV/projects/open
>  anonymousCollections=**/BeSTGRID/home/GeoFabric,**/ARCS/projects/public,/ARCS/projects/open,/BeSTGRID/projects/public,/BeSTGRID/projects/open,/BeSTGRID-DEV/projects/public,/BeSTGRID-DEV/projects/open

- configure Shibboleth not to require a session when accessing the project collection directly: add the following snippet into the 

``` 
<VirtualHost *:80>
```

 section in `/etc/httpd/conf.d/df.conf`:

``` 

  <Location <b>/BeSTGRID/home/GeoFabric</b>>
  ShibRequireSession Off
  </Location>

```

>  ***Note:** these changes require reloading Apache and restarting Davis.  We apologize for the inconvenience and hope Jargon+Davis will support mounted collections soon.

# Upgrading iRODS

On a slave server, this process is quite simple: stopping iRODS, building new iRODS version, starting iRODS.

On a master server, this process has to also include updates to the ICAT database.  Updates on a master server should be done first, either followed or in parallel with update on slave servers.

For more information, please see:

- The iRODS documentation on [upgrading iRODS](https://www.irods.org/index.php/Installation#iRODS_Upgrade_Instructions)
- The [Release Notes](https://www.irods.org/index.php/Release_Notes) for the iRODS version being upgraded to

## Stop iRODS and make backup

As rods:

- Stop the iRODS server


>  cd /opt/iRODS/iRODS
>  ./irodsctl istop
>  cd /opt/iRODS/iRODS
>  ./irodsctl istop


- Backup iRODS configuration


>  cp /opt/iRODS/iRODS/config/irods.config /tmp/irods.config-backup
>  cp /opt/iRODS/iRODS/config/irods.config /tmp/irods.config-backup

## Create new iRODS directory & unpack

- the iRODS tarball will extract all files into "iRODS" - let's make that a symlink to an "iRODS-2.4" directory.


>  cd /opt/iRODS
>  mkdir iRODS-2.4
>  ln -snf iRODS-2.4 iRODS
>  tar xzf ~/inst/irods2.4.tgz
>  cd /opt/iRODS
>  mkdir iRODS-2.4
>  ln -snf iRODS-2.4 iRODS
>  tar xzf ~/inst/irods2.4.tgz

- 
- Patch the newly extracted source tree as needed

## Run irodsconfig in upgrade mode

- Go into the NEW iRODS directory


>  cd /opt/iRODS/iRODS
>  cd /opt/iRODS/iRODS

- Copy in the original config file


>  cp ../iRODS-OLD-VERSION/config/irods.config config/irods.config
>  cp ../iRODS-OLD-VERSION/config/irods.config config/irods.config

- Run


>  ./irodssetup --upgrade
>  ./irodssetup --upgrade

You may get a prompt asking if you have already installed database patches.  Answering "no" will terminate the process, but we learn the patches to apply.  For upgrading from 2.3 to 2.4, the patch is: psg-patch-v2.3tov2.4.sql.

- If upgrading a master server, install the patches now (next section)
- If upgrading a slave server, make sure the master has been already upgraded (and the database patched) and skip the next section and continue building iRODS.

## Apply database patch

This is only relevant when upgrading a master server.

- Switch the iRODS symlink back to previous version


>  cd /opt/iRODS
>  ln -snf iRODS-2.3 iRODS
>  cd /opt/iRODS
>  ln -snf iRODS-2.3 iRODS

- Bring up database server for old iRODS


>  cd /opt/iRODS/iRODS
>  ./irodsctl dbstart
>  cd /opt/iRODS/iRODS
>  ./irodsctl dbstart


- Stop database again


>  ./irodsctl dbstop
>  ./irodsctl dbstop

- Switch the iRODS symlink again to the new version


>  cd /opt/iRODS
>  ln -snf iRODS-2.4 iRODS
>  cd /opt/iRODS
>  ln -snf iRODS-2.4 iRODS

## Upgrade - take 2

Copy irods.config from the old version into the new one

>  cp /opt/iRODS/iRODS-2.3/config/irods.config /opt/iRODS/iRODS/config/ 

- Run the installer again


>  cd /opt/iRODS/iRODS
>  ./irodssetup --upgrade
>  cd /opt/iRODS/iRODS
>  ./irodssetup --upgrade

- Answer the three questions with default "yes" answers:


>     Have you run one of those? \[yes\]? yes
>     Use the existing iRODS configuration without changes \[yes\]? yes
>     Start iRODS build \[yes\]? yes
>     Have you run one of those? \[yes\]? yes
>     Use the existing iRODS configuration without changes \[yes\]? yes
>     Start iRODS build \[yes\]? yes

This completes the setup and starts iRODS.

## Reapply local iRODS changes

Reapply all the steps from [iRODS post-configuration](installing-an-irods-slave-server.md)


>  reRuleSet   bestgrid,core
>  reRuleSet   bestgrid,core


## Restoring database from backup

If during the database upgrade it becomes necessary to restore from backup: drop the database and restoring from backup:

``` 

 /opt/iRODS/Postgres/pgsql/bin/dropdb ICAT
 /opt/iRODS/Postgres/pgsql/bin/createdb ICAT
 /opt/iRODS/Postgres/pgsql/bin/psql ICAT < /tmp/irods-backup.sql 

```

# Setting up an outage notice

To make Apache display an outage notice while Davis is not running (e.g., because Davis or iRODS are being upgraded):

- Put the outage notice text into: `/var/www/html/SystemOutage.html`
- Add the following into `/etc/httpd/conf.d/df.conf`:

``` 
ErrorDocument 503 /SystemOutage.html
```
- Reload Apache configuration:

``` 
service httpd reload</tt>

The outage notice activates once Davis becomes unreachable - i.e., after <pre>service davis stop
```

>  **An ****[ARCS extension](http://wiki.arcs.org.au/foswiki/bin/view/Main/ChangeNote201104-001)**** to this: temporarily apply the Outage notice also while Davis is running but exclude sys-admin boxes and let them access Davis directly (using*Deny** to block access to Davis and setting up the same outage document as the error document for HTTP 403):

``` 

#
# Enables 'Outage' mode where normal users see an outage notice but admins in the list below can see
# the website.
#
<Location />
    Order deny,allow
# Enable this line during outage so that users will see outage page but IPs listed can see DF
    Deny from all
# Put all admin addresses here. These addresses will see the website rather than an outage message.
    Allow from scad.hpsc.csiro.au obstler.ivec.org
</Location>


ErrorDocument 503 /SystemError.html
ErrorDocument 403 /SystemOutage.html
ProxyPass /SystemError.html !
ProxyPass /SystemOutage.html !
<Location /SystemOutage.html>
  Allow from all
</Location>
<Location /SystemError.html>
  Allow from all
</Location>

```

## Emailing out an outage notice

When there is a need to contact all DataFabric user, we can use the information collected in the MySQL database - which includes email addresses.

A convenient script for that is `ngdata.canterbury.ac.nz:/home/rods/bin/emailUsers.sh`

- Invocation:

``` 
emailUsers.sh email-text.txt [SQL expression]
```
- The `email-text.txt` file would include the Subject: header (separated by a blank line from the body).
- The SQL expression can be used instead of the default (all users) and I've used it for testing what the mailing would look like:

``` 
emailUsers.sh outage-2011-08-24.txt "select duEmail from dfUser WHERE duCN='Vladimir Mencl';"
```

We might possibly use it also to select users from a particular institution or users who have logged in in the last 3 months...

# Registering DataFabric users

The DataFabric automatically creates user accounts on first access - via Shibboleth or GSI.  As a temporary workaround before we get a BeSTGRID user management tool in place, the following service has been setup as an extension of Davis to collect additional information about users - namely, their institutional affiliation and email address.  

The service runs on the same host and Davis, and lives at a separate Shibboleth protected URL.  The URL is loaded from within the Davis UI, and by "touching" the URL, the services gets to collect the attributes present in the Davis session.

As of July 2014, this service also tracks individual sessions (originally, it was only tracking the last login + account creation).

The (PHP-based) service stores the user database in a local MySQL table, so first:

- Install MySQL and the PHP MySQL module:


>  yum install mysql-server
>  yum install php-mysql
>  service mysqld start
>  chkconfig mysqld on
>  yum install mysql-server
>  yum install php-mysql
>  service mysqld start
>  chkconfig mysqld on

- Create the MySQL table:

``` 

CREATE DATABASE dfUsers;
CREATE USER 'dfTracker'@'localhost' IDENTIFIED BY 'DB-PASSWORD';
GRANT ALL PRIVILEGES ON dfUsers.* TO 'dfTracker'@'localhost';
ALTER DATABASE dfUsers DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

use dfUsers;

create table dfUser (
 duSharedToken VARCHAR(50) NOT NULL,
 duCN varchar(100),
 duEmail varchar(100),
 duIdP varchar(100),	
 duUsername varchar(100),
 duOrgName varchar(100),
 duAffiliation varchar(100),
 duFirstAccess timestamp default 0,
 duLastAccess timestamp default 0,
 PRIMARY KEY  (duSharedToken)
) ENGINE=InnoDB;

create table dfUserLogin (
 duLoginId BIGINT(20) NOT NULL AUTO_INCREMENT,
 duSharedToken VARCHAR(50) NOT NULL,
 duLoginTime timestamp DEFAULT 0,
 duIPAddress VARCHAR(15),
 duServerName varchar(100),
 duUserAgent VARCHAR(100),
 PRIMARY KEY  (duLoginId),
 FOREIGN KEY fkUser (duSharedToken) REFERENCES dfUser(duSharedToken) 
) ENGINE=InnoDB;

```

- Note: replace DB-PASSWORD with the database password

- Note: adding duAffiliation later: modify structure with:

``` 
alter table dfUser add column duAffiliation varchar(100) after duOrgName;
```

- Note: the foreign key definition is ignored if the database is created with the MySQL MyISAM engine (MySQL supports foreign keys only with the InnoDB engine).  Therefore, create the tables enforcing the InnoDB engine.  The following sequence converts MyISAM tables to InnoDB and adds the foreign key constraint:

``` 

alter table dfUser ENGINE=InnoDB;
alter table dfUserLogin ENGINE=InnoDB;
alter table dfUserLogin add constraint ct_fk_SharedToken FOREIGN KEY fkUser (duSharedToken) REFERENCES dfUser(duSharedToken) ;

```

- As for the database schema: we may hold DNs in the future in a separate table (linked via... shared token?)

>  **Add Shibboleth protection for this service (not requiring a session): add the following to **`/etc/httpd/conf.d/davis.conf`** (*outside** a `VirtualHost` section!)

``` 

<Location /dfusers>
  AuthType shibboleth
  ShibRequestSetting requireSession 0
  require shibboleth
</Location>

```

- Create `/var/www/html/dfusers` and put the `userreg.php` script there.  The script is in SVN at [https://subversion.ceres.auckland.ac.nz/BeSTGRID/df/usermgmt/dfusers/](https://subversion.ceres.auckland.ac.nz/BeSTGRID/df/usermgmt/dfusers/) (together with config.php defining database connections).

- Use the Davis `ui-include-head` configuration directive in `davis-host.properties` to load the URL from the Davis UI (this directive injects the script just before the closing `head` tag).
	
- Note that this is preferred over modifying `/opt/davis/davis/webapps/root/WEB-INF/ui.html`
- Note also that if also using this directive for Google Analytics, both scriplets need to be specified in a single `ui-include-head` value:

``` 

ui-include-head=<!-- DataFabric user registration -->           \n\
<script language="javascript">                  \n\
  if (typeof XMLHttpRequest != "undefined") {   \n\
    var userreg_client = new XMLHttpRequest();  \n\
    userreg_client.open("POST", "/dfusers/userreg.php");   \n\
    userreg_client.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");   \n\
    userreg_client.send("username=<parameter account/>");  \n\
  };                                            \n\
</script>

```

- Note: the username itself is not available via Shibboleth and is passed to the service via the username attribute.  Davis substitutes 

``` 
<parameter account/>
```

 with the account name when rendering the UI to the user.  This processing is done also on the value of `ui-include-head`, so relying on the this substitution inside the snippet is all fine.

- Request the following attributes from AAF:
	
- SharedToken (required)
- CommonName (required)
- Email address (required)
- Organization Name
- Affiliation

## Making list of users available

This section talks about browsing the MySQL database with BeSTGRID users through a very simple HTML interface, protected by Shibboleth and accessible only to the DataFabric administrators.

- Create `/var/www/html/dfuseradmin`
	
- Put view.php there - this script, based on example from [http://www.anyexample.com/programming/php/php_mysql_example__display_table_as_html.xml](http://www.anyexample.com/programming/php/php_mysql_example__display_table_as_html.xml), is available at [https://subversion.ceres.auckland.ac.nz/BeSTGRID/df/usermgmt/dfuseradmin/](https://subversion.ceres.auckland.ac.nz/BeSTGRID/df/usermgmt/dfuseradmin/).  Please note this script relies on `../dfusers/config.php`.

>  **Make this directory protected by Shibboleth, allowing only the administrators in (based on their shared token values).  Add the following to /etc/httpd/conf.d/davis.conf (*outside** a `VirtualHost` section!) and reload Apache:

``` 

<Location /dfuseradmin>
  AuthType shibboleth
  ShibRequireSession On
  require shared-token "Y7rpGFpSV8z7TRK288wcQo9Eo_M" "-2vdKb_4CoiSg1P_uGfB9YTRJLo" "FxreQkk5UID8ZzwxpKR9tB7Tw1Q"
  # shared token values: Nick Jones | Vlad | Gene (UoA)
</Location>

```

# Tracking direct irods logins

The above documentation on registering DataFabric users only tracks logins to the Davis web interface, and of those, only logins with Shibboleth authentication.

It is also possible to track direct irods logins by parsing irods logs.  Due to how iRODS handles authentication, any logins to Slave servers need also a connection to the master, so the iRODS logs on master will see all user logins.

Note that iRODS logs are rotated by starting a new log on days 1, 6, 11, 16, 21, 26 - and 31 if exists in the month.  Howver, log entries from already running processes keep being added to the old log even after the new log has been started.  The new session message we are interested in however gets (almost) always logged in the new log.  With enough empirical observation, by midnight after rotating the logs, all activity to the old log ceases.

Therefore, we run the log parsing script at 23:00 on days 1, 6, 11, 16, 21, 26 and 31.

To deploy the log parsing, do these steps on the **master server** (only):

- Deploy pre-requisites for this script:


>  yum install perl-DateTime
>  yum install perl-DateTime

- Create the MySQL table (under the existing dfUsers database):

``` 

create table dfIrodsLogin (
 duLoginId BIGINT(20) NOT NULL AUTO_INCREMENT,
 duLoginTime timestamp DEFAULT 0,
 duUsername varchar(100),
 duIPAddress VARCHAR(15),
 duServerName varchar(100),
 PRIMARY KEY  (duLoginId)
) ENGINE=InnoDB;

```

- Deploy the following scripts from [https://subversion.ceres.auckland.ac.nz/BeSTGRID/df/scripts/reports/](https://subversion.ceres.auckland.ac.nz/BeSTGRID/df/scripts/reports/) (ideally into `~rods/bin`):
	
- parseUserLogins.pl (parser script)
- dbconfig.pm (configuration file for the parser script)
- parse_last_irods_log.sh (master script to be invoked from cron to drive the parser script)

- Configure the database connection details in `dbconfig.pm`

- Setup a cronjob to invoke the parser script - run `crontab -e` as `rods` and enter this line to invoke the script at 23:00 on days 1,6,11,16,21,26,31:

``` 
0 23 1,6,11,16,21,26,31 * * /home/rods/bin/parse_last_irods_log.sh
```

- Note: the script is configured to ignore all logins for `rods` and `rodsBoot` - but not `anonymous` and `QuickShare`.  Can be changed in dbconfig.pm

- Note: due to how iRODS logs the date in the log files, the year is dropped - and needs to be reconstructed from the current system time when parsing.  Therefore, the script can only parse log files that are no older then a year.

# Upgrading Davis

To upgrade Davis (do these steps preferrably as user `davis`):

- unpack the new distribution into a version-specific directory in /opt/davis (e.g, `/opt/davis/davis-0.9.0b`)


>  cd /opt/davis
>  tar xzf /home/davis/inst/davis-0.9.0b-vlad.tar.gz
>  cd davis-0.9.0b
>  cd /opt/davis
>  tar xzf /home/davis/inst/davis-0.9.0b-vlad.tar.gz
>  cd davis-0.9.0b

- Reapply all of the changes done to the current Davis installation.  These instructions assume:
	
- The currently running version of Davis is in `/opt/davis/davis` (a symbolic link)
- The new version of Davis is in the current directory (e.g, `/opt/davis/davis-0.9.0b`)

- Make `bin/jetty.sh` executable again


>  chmod +x bin/jetty.sh
>  chmod +x bin/jetty.sh

- again, disable ARCS specific configuration


>  ( cd webapps/root/WEB-INF ; mv davis-organisation.properties davis-organisation.properties.disabled )
>  ( cd webapps/root/WEB-INF ; mv davis-organisation.properties davis-organisation.properties.disabled )

- copy the Davis configuration file from the current Davis installation


>  cp /opt/davis/davis/webapps/root/WEB-INF/davis-host.properties webapps/root/WEB-INF/davis-host.properties
>  cp /opt/davis/davis/webapps/root/WEB-INF/davis-host.properties webapps/root/WEB-INF/davis-host.properties

- Update BeSTGRID branding (local svn working copy)


>  cd  ~/inst/df-ui
>  svn up
>  cd  ~/inst/df-ui
>  svn up

- Overwrrite default stylesheet:


>  cp ~/inst/df-ui/include/davis.css webapps/include/
>  cp ~/inst/df-ui/include/davis.css webapps/include/

- Install images:


>  cp ~/inst/df-ui/images/* webapps/images/
>  cp ~/inst/df-ui/images/* webapps/images/

- Reapply any changes to `/opt/davis/davis/webapps/root/WEB-INF/ui.html` if applicable.  Check the for the current list in the [instructions on customizing a new Davis install](installing-an-irods-slave-server.md#InstallinganiRODSslaveserver-CustomizeDavis).
- **Example (*non-authoritative list**)

``` 

 (cd webapps/root/WEB-INF ; patch -p0 < ~/inst/df-ui/html/ui.html-096-password-button.diff )

```
- Make sure all the files are owned by `davis.davis` (e.g., if the above steps were done as root)


>  chown -R davis.davis .
>  chown -R davis.davis .

- Shut the old version down, switch the symbolic link, bring the new version up (do these as `root`):


>  service davis stop
>  ln -snf davis-0.9.0b /opt/davis/davis
>  service davis start
>  service davis stop
>  ln -snf davis-0.9.0b /opt/davis/davis
>  service davis start

## Reloading Davis configuration

- Use a Davis URL with the `?reload-config` query string appended - like [http://df.bestgrid.org/BeSTGRID?reload-config](http://df.bestgrid.org/BeSTGRID?reload-config)
	
- Note that your iRODS user name must be listed in the Davis `administrators` directive to get access to this feature

# Replicating files across multiple resources

In iRODS, a file can have multiple replicas across multiple resources.  In the default configuration, a file is created with only one replica on the default resource.  It may be later replicated (with the `irepl`) command, or iRODS rules may be configured to automatically replicate the file upon creation (either synchronously or via delayExec).  Due to issues with the instantaneous replication, the safer solution is to replicate files afterwards explicitly.  This section documents configuring a replication script that scans the whole DataFabric (or a subtree) and replicates files that do not have the minimal amount (2) of replicas.

There have been some considerations about how to run the script.  The script can be run either in a loop mode, or as one-off invocations, possibly from a cron-job.  For independent invocations (such as from cron), it is crucial to make sure a new one is started only after the previous one completes.  We achieve this by wrapping the replication script invocations with a wrapper run-cycle.sh script that does appropriate locking.

To get the replication script going:

- Create /home/rods/bin if it doesn't exist yet:


>  mkdir -p /home/rods/bin
>  mkdir -p /home/rods/bin

- Download the [replicator.sh](https://subversion.ceres.auckland.ac.nz/BeSTGRID/df/scripts/replicator.sh) script and [run-cycle.sh](https://subversion.ceres.auckland.ac.nz/BeSTGRID/df/scripts/run-cycle.sh) scripts into /home/rods/bin

- Create the locking directory used by the script:


>  mkdir /opt/iRODS/lockdir/
>  mkdir /opt/iRODS/lockdir/



- Replicate all of the BeSTGRID DataFabric


>  ./replicator.sh -s BeSTGRID-REPLISET /BeSTGRID
>  ./replicator.sh -s BeSTGRID-REPLISET /BeSTGRID

- Note: this script is as of July, 2015 being used for replications invoked from cron in three overnight invocations, guarded by the run-cycle.sh script.

## Replication across multiple resources

As of November 2014, with three sites in the production DataFabric, it has become essential provide a way to associate some projects (iRODS directories) with target resources for replication.

This unfortunately could not be done with iRODS rules (acSetRescSchemeForRepl invoking msiSetDefaultResc) as:

- "forced" resource assignments are ignored for admin users (rods)
- "preferred" resource assignments are ignored if there is a selection (in either irepl -R or in connection profile).
- when no resource is specified as default and the preferred selection targets the only existing replica, the file would not get replicated at all
- when no resource is specified as default and the preferred selection targets first the target resource and then the REPLISET resource group, the target resource can still be ignored.

Therefore, we have instead modified the replicator.sh script to map files to resources and pass explicit resource selection in {{irepl -R }}.

The current mapping (stored in the cronjob for rods@ngdata.canterbury.ac.nz) is:

>  /BeSTGRID/home/KISS => df.uoo.nesi.org.nz
>  /BeSTGRID/home/EJPGroup => df.bluefern.canterbury.ac.nz
>  /BeSTGRID/home/ARCI-Grid => irods.ceres.auckland.ac.nz

The full invocation is:

>  replicator.sh -v -M /BeSTGRID/home/KISS:df.uoo.nesi.org.nz -M /BeSTGRID/home/EJPGroup:df.bluefern.canterbury.ac.nz -M /BeSTGRID/home/ARCI-Grid:irods.ceres.auckland.ac.nz BeSTGRID-REPLISET /BeSTGRID/home

# Configuring QuickShare

The QuickShare feature allows each DataFabric user to easily share files they own (have uploaded them) by generating a link that can be externally accessed by anyone who has the link (with a unique hash).  The link can be accessed without having a DataFabric/iRODS account - which makes it much easier to share files with either individual collaborators who do not have/want DataFabric accounts - or making a file public.

The QuickShare feature is implemented by a separate servlet running on the same server as Davis.  The servlet is connecting to iRODS separately, under its own account (typically called QuickShare).

To get QuickShare going (in Davis 0.9.3+):

- Create the iRODS `QuickShare` user - as an ordinary `rodsuser` user, picking a random password


>  iadmin mkuser QuickShare rodsuser
>  iadmin moduser QuickShare password QUICKSHARE-PASSWORD
>  iadmin mkuser QuickShare rodsuser
>  iadmin moduser QuickShare password QUICKSHARE-PASSWORD

- Add the following attributes to the Davis configuration (`davis-host.properties`)

``` 

# QuickShare: metadata attribute name
sharing-key=QuickShare

# QuickShare: iRODS account & and server connection details
sharing-user=QuickShare
sharing-password=QUICKSHARE-PASSWORD
sharing-host=irods.institution.ac.nz
sharing-port=1247
sharing-zone=BeSTGRID

# QuickShare - URL prefix for the Davis server
sharing-URL-prefix=https://df.bestgrid.org/quickshare

```

- Patch your iRODS server so that it can can properly expand the userNameClient variable in acAclPolicy rule (used below).  Apply the [aclpolicy_username.patch](http://projects.arcs.org.au/svn/systems/trunk/dataFabricScripts/iRODS/BugFix/patches-2.4/aclpolicy_username.patch) patch to server/api/src/rsGenQuery.c and recompile and restart your iRODS server.

- Add a rule exempting the QuickShare user from the acAclPolicy STRICT policy to bestgrid.irb (replacing the existing acAclPolicy rule)

``` 
acAclPolicy|"$userNameClient" != "QuickShare"|msiAclPolicy(STRICT)|nop
```

- Add a ProxyPass directive for `/quickshare` into `/etc/httpd/conf.d/df.conf`:

``` 
ProxyPass /quickshare ajp://localhost:8009/quickshare flushpackets=on
```

- Restart Davis and reload Apache


>  service davis restart
>  service httpd reload
>  service davis restart
>  service httpd reload

## Restoring a Quickshare link

When a file has been previously shared with Quickshare and then un-shared or deleted, it may be desirable to share it again with the same hash - so that external links pointing to the file still work.

QuickShare itself does not support that, but it can be done on the command line with iCommands (as a user with "own" privileges on the file).  The steps are:

- First, share the file in QuickShare again - that makes the file shared again, even though with a new (diferent) link.
- Start a session with icommands.
- Examine the current file's metadata (that is where QuickShare info is saved):

``` 

imeta ls -ld "filename.mp4"
AVUs defined for dataObj filename.mp4:
attribute: QuickShare
value: https://df.bestgrid.org/quickshare/81995194exxxxce8/filename.mp4

```
- Get the hash code of the original Quickshare link this file was shared under (from existing external links)
- Update the URL (value of the Quickshare metadata attribute), replacing the hash code to the desired one: 

``` 
imeta set -d "filename.mp4" QuickShare "https://df.bestgrid.org/quickshare/9fDESIREDa25a/filename.mp4"
```
- Note that the same change can also be done from the metadata editor built into Davis...

# Disaster Recovery

Recovering from a failure of a storage resource - notes from DS4200 double disk failure at Canterbury.

- Deleting a resource is only permitted when there are no replicas on that resource.
- Delete all replicas from that resource: recursively across /BeSTGRID, remove all replicas from griddata.canterbury.ac.nz, in admin mode, keeping at least 1 replica: 

``` 
itrim -r -M -N 1 -S griddata.canterbury.ac.nz /BeSTGRID/home
```
- If this end up to be too much straining the iCAT, do it user by user:

``` 

iquest "%s" "select USER_NAME where USER_ZONE = 'BeSTGRID'" | sort |
while read DFUSER; do
   echo "Running itrim for $DFUSER" ; 
   itrim -r -M -N 1 -S griddata.canterbury.ac.nz /BeSTGRID/home/$DFUSER 2>> log-autotrim-BeSTGRID-home-$DFUSER.log >&2 ; 
done

```
- * Works even when resource is marked as*down*

- Find files that are still saying on the resource: this may be files that have zero length and therefore did not get replicated:

``` 
iquest "select DATA_NAME where RESC_NAME = 'gridddata.canterbury.ac.nz'"
```
- Or directly from iCAT (`psql ICAT`):

``` 
 select coll_name, data_name, data_path from r_data_main,r_coll_main where r_data_main.coll_id=r_coll_main.coll_id and resc_name = 'griddata.canterbury.ac.nz';
```
- **Manually replicate these files onto another resource (with*irepl** - for zero-length files, works even when the resource is offline) and then trim there replica at the failed resource.

- Finally, delete and create the resource.
	
- Remember to add the new resource into any groups the old one was in.

# Disaster Recovery - changing master server

The master server is currently df-data.uoo.nesi.org.nz.

The server at irods-bestgrid.nesi.org.nz is (as of July 2015) compiled with iCAT support and the server is configured with a PostgreSQL database server.

The iCAT is being backed up twice daily into /data/BeSTGRID/home/rods/backups on irods-bestgrid.nesi.org.nz (NFS mounted from data.bestgrid.org).

Should the current master at df-data.uoo.nesi.org.nz irrecoverably fail, it should be possibly to resume the DataFabric operations by:

- Loading the latest database backup into PostgreSQL on irods-bestgrid.nesi.org.nz (as rods):

``` 

 createdb ICAT
 gzip -d < /data01/df/BeSTGRID/home/rods/backups/icat-backup-...latest.sql.gz | psql ICAT

```

- Changing the iRODS configuration on irods-bestgrid.nesi.org.nz (and all other remaining servers) to make irods-bestgrid.nesi.org.nz the new master:

- Stop irods


>  service irods stop
>  service irods stop

- Change master configuration in $IRODS_HOME/server/config/server.config


>  icatHost irods-dev1.nesi.org.nz
>  icatHost irods-dev1.nesi.org.nz

- And in $IRODS_HOME/server/config/createUser.config


>  M irods-dev1.nesi.org.nz
>  M irods-dev1.nesi.org.nz

- And in $IRODS_HOME/config/irods.config


>  $IRODS_ICAT_HOST = 'irods-dev1.nesi.org.nz';
>  $IRODS_ICAT_HOST = 'irods-dev1.nesi.org.nz';

- IF FORMER MASTER, comment out DATABASE settings in $IRODS_HOME/config/irods.config

- Master as configured in /var/www/html/dfpassword/.htirods/.irods/.irodsEnv

- Master as configured in /var/www/html/dfusers/config.php (used also by dfuseradmin)

- Start iRODS:


>  service irods start
>  service irods start

Note: this does not archive or restore the MySQL database tracking user logins, only the ICAT itself - and may loose up to 12 hours of changes.  But still highly useful in a total disaster scenario....

# Developing iRODS rules

The following links can be useful in developing iRODS rules:

- [Rule Language and Rule Engine description](https://wiki.irods.org/index.php/Changes_and_Improvements_to_the_Rule_Language_and_the_Rule_Engine)
- Description of [types of variables accessible to rules](https://wiki.irods.org/index.php/Attributes) and [data variable mappings](https://wiki.irods.org/index.php/Data_Variable_Mapping)
