# Setup AuthTool for HPC at University of Canterbury

The AuthTool is a small program that allows users to link their grid identity (the Distinguished Name, DN) to their local account on a cluster.  

The ARCS website provides an overall description of [how AuthTool works](http://wiki.arcs.org.au/bin/view/Main/AuthTool) and [list of deployed AuthTool instances](http://www.arcs.org.au/GridAuthtool).

AuthTool is a PHP script, typically reachable under the /auth path on the GUMS server. The AuthTool requires two lays of authentication: the users must authenticate with their certificate (loaded into their browser), and must also authenticate with the username and password for logging to their cluster (the login details are verified by an external authentication tool). If the PHP script receives both the user's Distinguished Name (DN) and the cluster login name, it offers the user to request a local mapping, and if the user requests so, the PHP adds the user's mapping to a local mapfile.

This page documents how I installed AuthTool for user with the [University of Canterbury HPC facility](http://www.ucsc.canterbury.ac.nz/).  I was drawing on the guide for [installing AuthTool](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool) in the ARCS documentation, but I had to do a few things differently.  The main reason is that the HPC accounts do not exist on the NgGums machine, I had to use a different external authentication tool (verifying the username and password by attempting an SSH login).

Also, at the GUMS server will serve multiple cluster with distinct user bases, I had to plan the deployment locations to avoid name clashes.  Thus, the HPC AuthTool is not directly under `/auth`, but under `/hpc/auth`, and also the GUMS groups for use with this AuthTool instance are suffixed with HPC, leaving space to install AuthTool for the SGE (Oldesparky) cluster in the future.

## Installing AuthTool

Following [http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool)

### Step 1: Install AuthTool

- Get AuthTool from wget [http://www.vpac.org/~sam/authtool.tar.gz](http://www.vpac.org/~sam/authtool.tar.gz)
- extract authtool into `/opt/vdt/apache/htdocs` as `hpc/auth`, `hpc/mapfile`
- just change ownership to `daemon.daemon`, permissions are otherwise right.

### Step 2: compile apache authnz_external module

- Get the module from [http://www.unixpapa.com/software/mod_authnz_external-3.1.0.tar.gz](http://www.unixpapa.com/software/mod_authnz_external-3.1.0.tar.gz)
- compiles and installs with /opt/vdt/apache/bin/apxs


>  cd mod_authnz_external-3.1.0
>  apxs -c mod_authnz_external.c
>  apxs -i -a mod_authnz_external.la
>  cd mod_authnz_external-3.1.0
>  apxs -c mod_authnz_external.c
>  apxs -i -a mod_authnz_external.la

- VDT 1.8.1 comes with apache 2.2.4, that's fine.
- apxs automatically makes the module loaded from `/opt/vdt/apache/conf/httpd.conf`

### Step 3: external authorization tool

Here comes the hard part: we cannot use pwauth, it can only authenticate via local accounts (PAM), but we need a tool that would do external authentication by attempting an SSH connection.  And, SSH won't accept a user's password on the standard input (to avoid security risks by being called from a script), and would only read the password from a terminal.  This sounds like a problem ... and the solution is to write an [expect](http://expect.nist.gov/) script that wraps around ssh.

The options I considered were:

1. Use package `expect` to feed the password to ssh
2. ssh via an automated login to an account on HPC and run the `pwauth` program there.  Possible, but looks even more complicated (and dependent on the remote configuration)
3. move authtool to the HPC - even more complicated, and would need to copy the `mapfile` back to the gums server.

Choosing 1:

>  yum install expect

Save the following expect script as `/opt/vdt/apache/bin/sshauth-hpc`:

``` 

#!/usr/bin/expect -f

expect_user -re {^([^\n]*)\n} {
   set username $expect_out(1,string)
}
expect_user -re {^([^\n]*)\n} {
   set password $expect_out(1,string)
}
if {[regexp {^[A-Za-z]?[-_A-Za-z0-9]*$} $username]} {
  # username OK
} else {
  # Invalid username
  exit 51;
}
spawn ssh -o HostbasedAuthentication=no -o PasswordAuthentication=yes -o PubkeyAuthentication=no -o RhostsRSAAuthentication=no -o RSAAuthentication=no $username@bgl.canterbury.ac.nz echo Authenticated
expect -re "assword:" { send "$password\r" }
expect -brace { "Authenticated\r" {
        #send_user "Authentication successful\n"
        #close
        exit 0
    }
    "assword:" {
        #send_user "Authentication failed\n"
        close
        exit 2
    }
}
#send_user "Authentication failed\n"
#close
exit 52

```

Notes: 

- SSH is invoked with parameters to disable all other authentication mechanism and permit only password authentication.
- When SSH prompts for the password again, it means authentication failed and we close the connection and report failure.
- The script should return the following values (drawing on `pwauth.h`):
	
- "1" is the most proper one for ssh logins with a repeated `Password:` prompt, but I'll instead return "2" to differentiate from a generic expect error code - it's still very appropriate.
- Return 51 for invalid username
- Return 52 when I don't get an ssh password prompt
- pwauth.h defines these code as follows:

``` 

#define STATUS_UNKNOWN    1   /* Login doesn't exist or password incorrect */
#define STATUS_INVALID    2   /* Password was incorrect */
#define STATUS_INT_ARGS  51   /* login/password not passed in correctly */
#define STATUS_INT_ERR   52   /* Miscellaneous internal errors */

```

Now, activate this script as the authentication mechanism protecting `/hpc/auth/`:

- Load the module and define the script as external authentication method sshauth-hpc in  `/opt/vdt/apache/conf/httpd.conf`:

``` 

LoadModule authnz_external_module modules/mod_authnz_external.so
AddExternalAuth sshauth-hpc /opt/vdt/apache/bin/sshauth-hpc
SetExternalAuthMethod sshauth-hpc pipe
<Directory "/opt/vdt/apache/htdocs/hpc/auth">
        AllowOverride AuthConfig
</Directory>

```

- Customize `/opt/vdt/apache/htdocs/hpc/auth/.htaccess`
	
- Change `AuthName` to `"Grid Authorization Tool - University of Canterbury HPC"`
- Change `AuthExternal` to use `sshauth-hpc`

- Customize index.php, change "vpac" to "University of Canterbury HPC"

Additional configuration: put the ssh key for `hpcgrid1`, `hpclogin1`, `bgl` and `oldesparky` into `/etc/ssh/ssh_known_hosts`:

- otherwise, SSH won't be able to connect automatically when run under the daemon account.
- use full domain names (or the names that would be specified on the ssh command line).

### Step 4: mapfile-GUMS synchronization

The final step is to configure synchronization between the mapfile managed by the AuthTool and the GUMS server *local mapping* and *local group* databases.  This is done by the python script [gumsmanualmap.py](http://projects.arcs.org.au/trac/systems/attachment/wiki/HowTo/InstallAuthTool/gumsmanualmap.py.txt).  This script has to be periodically run (every 8 mins on Canterbury GUMS server).

The script uses the Python MySQL library so first install this library:

>  yum install MySQL-python

- Download [gumsmanualmap.py](http://projects.arcs.org.au/trac/systems/attachment/wiki/HowTo/InstallAuthTool/gumsmanualmap.py.txt?format=raw)
- Customize the script to local environment:
	
- *Different database name* (GUMS version specific, `GUMS_1_3` as of GUMS 1.3.17
- Different path to the mapfile (HPC specific)
- Different names of the GUMS groups (HPC specific)
- Change `DBHOST` to the hosts FQDN (the VDT-created MySQL account for GUMS only allows connections coming from the host's FQDN, not from localhost).
- Define a new variable `DBPORT=49151` - VDT-installed MySQL does not run at port 3306 but at the VDT-selected port 49151.  Use this variable in `dbConnect()`.
- ***Note**: As of VDT 2.0.0, the port number can actually be 49152 in a default install.
- The script would check if the account being mapped to exists locally - but, as NgGums is not a part of the HPC cluster, this would never hold.  Comment out this check.
- As of VDT 2.0.0, the database schema has changed (USERS table now has an EMAIL column) and the script has to be changed to handle that.
- With all these customization, the script differs in the following:

``` 

--- gumsmanualmap.py.txt	2008-02-22 15:42:58.000000000 +1300
+++ gumsmanualmap-hpc.py	2009-12-08 16:46:20.000000000 +1300
@@ -50,15 +50,17 @@
     sys.stderr.write('MySQLdb module is not installed or is misconfigured.\n')
     sys.exit(1)
 
-MAPFILE = "/opt/vdt/apache/htdocs/mapfile/mapfile"
+MAPFILE = "/opt/vdt/apache/htdocs/hpc/mapfile/mapfile"
 GUMS_CONFIG = "/opt/vdt/vdt-app-data/gums/config/gums.config"
 
-DBHOST = "localhost"
-DBNAME = "GUMS_1_1"
+DBHOST = "nggums.canterbury.ac.nz"
+DBPORT = 49152
+### ORIG: DBPORT = 3306
+DBNAME = "GUMS_1_3"
 DBUSER = "gums"
 
-MAPPEDUSERS = 'mappedUsers'
-MANUALGROUP = 'manualGroup'
+MAPPEDUSERS = 'mappedUsersHPC'
+MANUALGROUP = 'manualGroupHPC'
 
 
 
@@ -128,13 +130,14 @@
                 continue
             if debug > 2:
                 log.info('-- File [%s] [%s]' % (userDN, localAccount))
-            # Check that local account name exists
+            # HPC: DISABLE: VM 2008-04-03 Check that local account name exists
             invalidAccount = 0
-            status, output = commands.getstatusoutput("getent passwd %s" % localAccount)
-            if status != 0:
-                log.warning('-- %3d:Local account for %s does not exist' \
-                             % (lineno, mapEntry))
-                invalidAccount = 1
+            #status, output = commands.getstatusoutput("getent passwd %s" % localAccount)
+            #if status != 0:
+            #    log.warning('-- %3d:Local account for %s does not exist' \
+            #                 % (lineno, mapEntry))
+            #    invalidAccount = 1
+
             # Check for duplicate entry in mapfile
             if mapfile.has_key(userDN):
                 log.warning('-- %3d:Duplicate mapfile entry for \"%s\"' % (lineno, userDN))
@@ -176,7 +179,7 @@
 def dbConnect():
 
     try:
-        db = MySQLdb.Connect(host=DBHOST, port=3306, user=DBUSER, passwd=getGumsConfigPasswd(), db=DBNAME)
+        db = MySQLdb.Connect(host=DBHOST, port=DBPORT, user=DBUSER, passwd=getGumsConfigPasswd(), db=DBNAME)
         return db
 
     except:
@@ -327,7 +330,7 @@
         matchcursor = c.cursor()
         deletecursor = c.cursor()
         for row in selectcursor.fetchall():
-            id, group_name, dn, fqan = row
+            id, group_name, dn, fqan, email = row
             matchSQL = """SELECT * FROM MAPPING WHERE MAP = "%s" AND \
                      DN = "%s";""" % (MANUALGROUP, dn)
             matchcursor.execute(matchSQL)
@@ -441,7 +444,7 @@
                 log.info('%s' % (selectSQL))
             if selectcursor.rowcount == 0:
                 insertcursor = conn.cursor()
-                insertSQL = """INSERT INTO USER VALUES (0, "%s", "%s", NULL);""" \
+                insertSQL = """INSERT INTO USER VALUES (0, "%s", "%s", NULL, NULL);""" \
                                % (MAPPEDUSERS, dn)
                 insertcursor.execute(insertSQL)
                 insertcursor.close()

```

- Finally, install this script as `/opt/vdt/apache/bin/gumsmanualmap-hpc.py`.
- Make this called every 8 minutes: create `/etc/cron.d/gumsmanualmap-hpc.cron` with:

``` 
*/8 * * * * daemon /opt/vdt/apache/bin/gumsmanualmap-hpc.py >> /opt/vdt/apache/logs/gumsmanualmap-hpc.log 2>&1
```
- Restart cron to pick the new .cron file: 

``` 
service crond restart
```
- And also make sure the log file exists and is writable by daemon:


>  touch /opt/vdt/apache/logs/gumsmanualmap-hpc.log
>  chown daemon.daemon /opt/vdt/apache/logs/gumsmanualmap-hpc.log
>  touch /opt/vdt/apache/logs/gumsmanualmap-hpc.log
>  chown daemon.daemon /opt/vdt/apache/logs/gumsmanualmap-hpc.log

### Step 5: Friendly Auth Tool

Configure a friendly https front interface to the Auth Tool as documented in [Step 5: Friendly Auth Tool](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallAuthTool#Step5:FriendlyAuthToolpage) page in the ARCS AuthTool installation documentation.
