# Vladimir's data grid notes

These are miscellaneous notes and links related to the data grid, mostly SRB and the ARCS DataFabric project.

Now refreshed with iRODS notes

# iRODS 

# iRODS clients

- JUX, a file explorer written in java: [https://forge.in2p3.fr/projects/jux](https://forge.in2p3.fr/projects/jux)
- DavFS: RPM package `davfs2`, remember to disable locking:

``` 

# ARCS Specific Options
# ---------------------
use_locks         0
drop_weak_etags   1

```

# Changing iRODS password

Using `ipasswd` does not seem to work, but the following works well (run as rods):

>  iadmin moduser *user.name* password '*new-password*'

- When changing the password for the `rods` user, also change the password in `$IRODS_HOME/config/irods.config` (`IRODS_ADMIN_PASSWORD`) on ALL servers and re-run `irodssetup` (at least on all slave servers)
	
- And also change the password for `rodsBoot`

- Changing database password:
	
- Edit `$IRODS_HOME/config/irods.config` and change `IRODS_DATABASE_PASSWORD` there
- Create a scrambled form of the password:
		
- Edit `$IRODS_HOME/server/config/server.config` and find out what the scramble key is (DBKey)
- Create the scrambled form with:

``` 
iadmin spass new-password scramblekey
```
- Store this as `DBPassword` in server.config
- Change the password in the Postgres database: connect to the database with `psql ICAT rods` and run:

``` 
alter user rods with password 'new-password';
```

# Run As an iRODS user

When connected as `rods`, to do an operation as another user, set `clientUserName` to that user's name. Example:

``` 
clientUserName=mik.black ichmod -r own BCprognosis /BeSTGRID/home/BCprognosis
```

# Using irodsFS/FUSE

According to Gareth Williams:

``` 

First you get to a state where icommands work.
Then icd to the collection you want to mount. 
Then something like
iRODS/clients/fuse/bin/irodsFs /mnt/mountpoint -o max_readahead=0

```

# Installing AWStats on Davis

- [http://wiki.arcs.org.au/bin/view/Main/ChangeNote200907-007](http://wiki.arcs.org.au/bin/view/Main/ChangeNote200907-007)
- [http://wiki.arcs.org.au/bin/view/Main/ChangeNote201006-005](http://wiki.arcs.org.au/bin/view/Main/ChangeNote201006-005)
- [http://wiki.arcs.org.au/bin/view/Main/ChangeNote201005-003](http://wiki.arcs.org.au/bin/view/Main/ChangeNote201005-003)

# Debugging iRODS

Following [https://www.irods.org/index.php/how_to_use_the_debugger_on_the_server-side](https://www.irods.org/index.php/how_to_use_the_debugger_on_the_server-side)

- Uncomment the following line in `server/core/src/rodsAgent.c`:

``` 
?#define SERVER_DEBUG 1
```
- Recompile iRODS:

``` 
?gmake
```

* Create `/tmp/rodsdebug?`

``` 
touch /tmp/rodsdebug
```

Each irodsAgent process will now wait 20 seconds before processing the request:: quickly connect with:

``` 
gdb -p <pid>
```

# SRB 

# Documentation

- SRB main page: [http://www.sdsc.edu/srb/index.php/Main_Page](http://www.sdsc.edu/srb/index.php/Main_Page)
	
- Installation index: [http://www.sdsc.edu/srb/index.php/Installation](http://www.sdsc.edu/srb/index.php/Installation)
- ARCS QuickStart guide: [http://projects.arcs.org.au/trac/systems/wiki/DataServices/SRBQuickStart](http://projects.arcs.org.au/trac/systems/wiki/DataServices/SRBQuickStart)

# SRB commands

## Create a public drop box

- Create the directory `dropbox` which is world read and writable.
- To be issued *"as an srbAdmin user (could be a user with sysadmin attribute)?"*

``` 

 Smkdir -p /<your zone name>/projects/eResearch08/dropbox
 Schmod a public npaci /<your zone name>/projects/eResearch08/dropbox

```

## Zone synchronization

- [Szonesync.pl](http://www.sdsc.edu/srb/index.php/Szonesync.pl)

# SRB metadata structure

I've read through the Smeta man page to see what metadata structure SRB permits.

- Metadata for each object is organized into tables, each identified by a numeric ID (starting with 0).
- Each such table can contain at most 10 strings (labeled as UDSMD0-9) and two integers UDIMD0,1.
- The Smeta command allows to insert values into the tables in an artibrary way (as well as create new tables).
- Hermes is using the first two slots for the key and the value, and creates a new table for each subsequent attribute.
- The Sufmeta command allows to insert tupples or triplets into the first two or three fields in a table - either as "name-value" or "name-value-unit".  Hermes then displays just the first two fields in the table (ignoring the units if specified).

# Minor bits of SRB knowledge

- Scommands keep the current state (SRB cwd) in `~/.srb/.MdasEnv.$$` (where `$$` is the PID of the login shell)

- SRB MCAT backups should be done with the `SRButil.sh` script from [http://projects.arcs.org.au/trac/systems/browser/trunk/dataFabricScripts](http://projects.arcs.org.au/trac/systems/browser/trunk/dataFabricScripts)

- A general rule for project directory ownership:
	
- Pauline Mak:

I just want some clarification on the ownership convention for "projects" folders on the data fabric. Will these only be owned by a single group, and will this be sticky?

- 
- Florian:

That would be the general idea.

- Comments from Florian (on BeSTGRID proposal):
	
- DataServices team is working on (1) allowing login via SRB servers in remote zones and (2) not keeping an account tied with a zone
- multiple domains are useful, e.g. to keep a separate namespace for an institution's users.

- To make permissions inherited even to newly created objects, I must use both Recursive+Sticky (in Hermes)

- An object is made public by granting access to "public@npaci".
	
- Note: even though SRB lists "all users" instead of the group, this does apply also to accounts created after granting the permission.

- My SRB home is at 

``` 
srb://vxm552.srb.dc.apac.edu.au@srb.dc.apac.edu.au/srb.dc.apac.edu.au/home/vxm552.srb.dc.apac.edu.au
```
- SRB project home is at 

``` 
srb://vxm552.srb.dc.apac.edu.au@srb.dc.apac.edu.au/srb.dc.apac.edu.au/projects/ARCSdata
```

- SRB user auto-creation is documented at [http://projects.gridaus.org.au/trac/systems/wiki/DataServices/SRBAutoUserCreation](http://projects.gridaus.org.au/trac/systems/wiki/DataServices/SRBAutoUserCreation)

- Remove trash for a user (`$USER`):


>  clientUserName=$USER clientDomainName=srb.bestgrid.org.nz Srmtrash -U ${USER}@srb.bestgrid.org.nz /srb.bestgrid.org.nz/trash/home/$USER.srb.bestgrid.org.nz
>  clientUserName=$USER clientDomainName=srb.bestgrid.org.nz Srmtrash -U ${USER}@srb.bestgrid.org.nz /srb.bestgrid.org.nz/trash/home/$USER.srb.bestgrid.org.nz

# SRB installation - what is done behind the scenes

## SRB RPM packages scriptlets

>  ***globus-srb-config**: creates `/etc/profile.d/globus.sh` sourcing `/usr/srb/globus/etc/globus-user-env.sh`
>  ***srb-psqlodbc**: some symlinks in `/usr/srb/lib`
>  ***postgresql-server**: create user+group `postgres` (id 26)
>  ***ksh**: add/remove ksh to/from `/etc/shells`
>  ***srb-server**:


**Note:** there's a clash in setting `GLOBUS_LOCATION` by both `vdt_setup.sh` and `globus.sh` in `/etc/profile.d` - alphabetically, VDT takes over

## SRB-install package

The `srb-install` package is a placeholder for the ARCS-specific SRB installation script - the installation and configuration is done from the post-install scriptlet of this otherwise empty package.  The configuration steps done by this script are:

- Creates `/var/lib/srb/.mcat_location` with `/var/lib/srb/mcat` as the data directory.
- Creates `/usr/srb/data/MdasConfig` pointing to local Postgres
- Creates `/var/lib/srb/.odbc.ini` pointing to local Postgres
- Creates new Postgres DB in `/var/lib/srb/mcat`, edits `postgresql.conf` there to listen on port 5432 worldwide
- Starts postgres
- Creates MCAT db
- Injects MCAT schema from /usr/srb/MCAT/data/catalog.install.psg
- ***Problem:** the last line of the dump file: 

``` 
delete from MDAS_AU_USER where user_id = 6;
```
- Fails with: 

``` 
ERROR:  relation "mdas_au_user" does not exist
```
- This is considered as acceptable by the ARCS Data Services team.
- Defines a local domain
- Creates an srbAdmin with the installation default password
- Changes the password of `srb.sdsc` to srbAdmin's password
- Creates a `.MdasEnv` & `.MdasAuth` file for SRB (in /var/lib/srb/.srb)
- Sets the hostname of the MCAT host in `/usr/srb/data/mcatHost`
- ***Problem:** leaves untouched the full DN
	
- Considered OK: GSI authorization is not used for server-to-server communication in our setting.
- Starts SRB
- Defines a local location 

``` 
{/usr/srb/MCAT/bin}/ingestLocation '$SRB_LOCATION' '$HOSTNAME:NULL.NULL' 'level4' $SRB_ADMIN_NAME $SRB_DOMAIN"
```
- Creates a default resource in `/var/lib/srb/Vault` 

``` 
{/usr/srb/MCAT/bin}./ingestResource '$SRB_RESOURCE' 'unix file system' '$SRB_LOCATION' '$SRB_VAULT/?USER.?DOMAIN/?SPLITPATH/?PATH?DATANAME.?RANDOM.?TIMESEC' permanent 0"
```
- Changes zone name (by default to `$HOSTNAME`)
	
- The `SZone -C` command is run twice (?a hack?)
- Sets srbAdmin as the zones admin (also run twice)
- Creates user ticketuser.sdsc (as "public" user)
- Creates user `inca.$HOSTNAME` with GSIAuth as Gerson GTest
- Creates a mapping for `INCA_DN` to `inca@$HOSTNAME` in `/etc/grid-security/grid-mapfile.srb`
- Edits `/usr/bin/ZoneUserSync.py` with 

``` 
administrativeZones = ["gridgwtest.canterbury.ac.nz"]
```

# Glossary

- What is a domain?
	
- A domain is a string used to identify a site or project. Users are uniquely identified by their usernames combined with their domain 'smith@npaci'. SRBadmin has the authority to create domains.
- Zone
	
- In 3.0 we released a Federated MCAT capability, where complete MCAT-enabled SRB systems can be integrated with other SRB federations. Each MCAT member of such a federation is called an SRB Zone.
- Ergo, a Zone is a namespace corresponding to a single metadata catalogue...?
- What is a SRB Vault?
	
- SRB vault is a data repository system that SRB can maintain in any of the storage systems that it can access.
- What is a SRB Space?
	
- SRB space is a union of all SRB Vaults that can be accessed by a system of SRB servers.
- One can visualize SRB space as a logical storage volume that is distributed and heterogeneous.
- What ports does the SRB use? What ports do I need to open in a firewall to run the SRB?
	
- srbMaster listens by default on port 5544
- also, a range of data ports (20000 to 20199 by default, APACGrid uses 40000-40200)

- Location: a hostname in the SRB grid
	
- *A Location is an MCAT item, a token, that describes a computer in the SRB grid.*

## SRB related projects

- Jargon: *A Java client API for the DataGrid* - [http://www.sdsc.edu/srb/index.php/Jargon](http://www.sdsc.edu/srb/index.php/Jargon)
- Scommands - command-line Sinit, Sls, Scd, [http://www.sdsc.edu/srb/index.php/Scommands](http://www.sdsc.edu/srb/index.php/Scommands)
	
- Note: it's OK there's only a download link for [SRB3_4_2client.tar](http://www.sdsc.edu/srb/tarfiles/SRB3_4_2client.tar), the client is said to be the same as in 3.5.0.
- See compilation instructions at [http://projects.arcs.org.au/trac/systems/wiki/DataServices/UbuntuClient](http://projects.arcs.org.au/trac/systems/wiki/DataServices/UbuntuClient)
- inQ: Win32 GUI client
- MySRB: web-based browse+search
- srbBrowser: Java-based GUI (subset of inQ), runs on unix
