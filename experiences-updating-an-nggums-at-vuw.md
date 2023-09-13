# Experiences updating an NGGUMS at VUW

# Summary

These notes detail my experiences in updating a VDT installtion of an

NGGUMS using the VDT updater.

They are less a set of instructions to follow, more of a *get you thinking*

walk (don't run) through, highlighting the gaps in my knowledge at the

time I carried this process out.

I have however tried to removed VUW-local paths in favour of a

more generic `/path/to/some/directory/` representation.

# Introduction

The NGGUMS in question was part of a number of technology preview grid

infrastructure gateway deployments that had been set up so that VUW's

central IT facilitator could see what was required to run such a

gateway as a production service.

The various components of the grid gateway pilots had been deployed

around June 2010 following the general guidelines for such an installation,

including the `Auth Tool` extension, found here:

>   [ Setting up a GUMS server|http://technical.bestgrid.org/index.php/Setting_up_a_GUMS_server]

although some VUW-local customisations, mostly arising from issues

that the standard installation procedure brought to light, can be 

seen here:

>   [ IoSCC: Setting up an NGGUMS|http://technical.bestgrid.org/index.php/IoSCC_Setting_up_an_NGGUMS]

Those two documents thus provide the background to the content within

this one.

In March 2011, VUW's central IT facilitator had been performing some

scanning of public-facing machines and found that the NGGUMS, in

what still remained a pilot deployment, was running an older version

of PHP than that which their vulnerability scanner considered up to

date.

The consensus within the NZ Grid comunity then seemed to be that a

complete re-installation would be the required course of action,

because updating using pacman, which underlies the VDT, would ignore

any local customisations that had been done, whilst over in Australia,

the view was that it should be possible to just use VDT's own updater

to bring the local installation up to date.

The answer I found seemed to lie somwhwere between those two approaches, 

although it turned out that "up to date", as far as VDT was concerned,

was not up to date enough for the vulnerability scanner - oh well.

As there did not seem to be any current BeSTGRID doucmentation

detailing the ongoing maintenance of a VDT installation, I posted my

exeriences here in case they might provide some useful pointers for

folk looking to ensure their VDT installations, though not just

`NGGUMS`, are kept up to date.

My experience also suggests that the original NGGUMS installation might

be done in a slightly different way that would then allow for a easier

update path. 

Having said that, if the choice taken for an "update" at your site is

always going to be a complete re-installation against the original

guidelines, then I guess it's of little consquence how one installs VDT.

Finally, the results of this update are currently running and seem to

be working. If it turns out later that something was missed then this

doucment might change to reflect that.

# Determining what VDT version you have

I was initially pointed to the following VDT document

>  [http://vdt.cs.wisc.edu/releases/2.0.0/vdt-updater-instructions.html](http://vdt.cs.wisc.edu/releases/2.0.0/vdt-updater-instructions.html)

however, that suggested that I run the command `vdt-version` and sure 

enough I was running an old enough version to need to follow this:

>  [http://vdt.cs.wisc.edu/releases/2.0.0/vdt-updater-instructions-pre21.html](http://vdt.cs.wisc.edu/releases/2.0.0/vdt-updater-instructions-pre21.html)

but here's what I had installed in June 2010.

``` 

# vdt-version

You have installed a subset of VDT version 2.0.0p17:

Software                                                 Status
--------                                                 ------
Apache HTTPD 2.2.15                                      UPDATE AVAILABLE [2.2.16]
vdt-ca-manage 1.2                                        UPDATE AVAILABLE [1.3]
vdt-update-certs 2.5                                     UPDATE AVAILABLE [2.6]
CA Certificates v58 (includes IGTF 1.38 CAs)             -
Fetch CRL 2.6.6                                          UPDATE AVAILABLE [2.8.5]
GPT 3.2-4.0.8p1                                          OK
Grid User Management System (GUMS) Client 1.3.17         OK
Grid User Management System (GUMS) Service 1.3.17        OK
Java 5 SDK 1.5.0_22                                      -
Logrotate 3.7                                            OK
MyProxy Client 5.1                                       UPDATE AVAILABLE [5.3]
MySQL 5.0.88                                             UPDATE AVAILABLE [5.0.91]
PHP 5.2.9                                                UPDATE AVAILABLE [5.2.14]
Apache Tomcat 5.5.28                                     OK
VOMS Client 1.8.8-2p1                                    OK
Wget 1.12                                                OK


Status legend:
OK: Software is up to date with the latest release in VDT version 2.0.0
- : Not enough information to determine if updates are available.
Type 'man vdt-version' for more information.

```

Having followed the VDT instructions for backing up my current

installation `2.0.0p17` and obtaining the updater itself, I was

a little surprised to find it telling me that I was some 8 revisions

behind the VDT installation I would have got had I done an new install

``` 

STEP 1 OF 6: INITIALIZATION

Updating '/opt/vdt' to VDT 2.0.0p25 (script revision 0).

```

# Backing up the current VDT installation

The VDT instructions to backup the current installation not 

only highlighted the fact that I hadn't really been concerned

with the size of the installtion when doing the initial set up

but also suggested that a couple of backups at various stages

in the installation process would have made the identification

of altered items within it easier.

Having turned off the VDT and ascertained the size of the 

current installation

``` 

vdt-control --off
cd $VDT_LOCATION 
du -sh .
752M    .

```

I was then able to identify an area which I could use to backup the

current installation, choosing a directory name representing then my

current revision:

``` 

export VDT_BACKUP_LOCATION=/path/to/backup/vdt-location-200p17
mkdir -p $VDT_BACKUP_LOCATION
rsync -a $VDT_LOCATION/ $VDT_BACKUP_LOCATION/

```

I had reason to run a sanity check of the above sync some time into

the process as a whole and found that whilst I had turned off the

VDT controlled processes, some files within the `$VDT_LOCATION`

were still being modified by some `cron` tasks.

Leaving these running seems harmless though some folk may wish to

turn those off as well when doing the update.

1. The `gridpulse` task in the root crontab
2. The hourly `gumsmanualmap-vdt20.py` invocation

# Identifying the local customisations

Having been told that an update would remove all the local customisations,

I thus tried to identify them.

As well as looking within the `$VDT_LOCATION`, on the

assumption that the VDT would be pretty much self-contained,

system-level cron scripts excepted, I did run a check to see if

anything was linking back into the VDT, using a `find` with a

`-lname` clause, in case something was removed.

The only thing I found was the link created during the install

>  `/etc/profile.d/vdt.sh  -> /opt/vdt/setup.sh`

and with the target being created by the `pacman` install, it 

seemed likely that it would be preserved across an update.

In looking for customisations within the `$VDT_LOCATION` I tried

comaparing file times to the top-level file `vdt-install.log` but found 

that I had added some extra parts of the GUMS instatllation after 

customising the base. It thus took an inspection of the install guide,

as well as looking for `.orig` files to highlight where changes

had been made.

The files that seem to have changed were (all name relatives to

`$VDT_LOCATION`)

``` 

apache/conf/httpd.conf
apache/conf/extra/httpd-ssl.conf
vdt-app-data/apache/vdt-webapps.conf 
tomcat/v55/webapps/gums/WEB-INF/web.xml
post-install/apache
post-install/mysql5
post-install/tomcat

```

The last three in that list contain patches for issues that BeSTGRID's

Vladimir Mencl, identified at the time the original installtion

guidelines were written.

Those patches, albeit in a modified form, now appear to be contained

within the files distributed in the VDT, so following the

installation guidelines when doing a complete re-install, may well

see a duplication of effort.

## Customisation of  `apache/conf/extra/httpd-ssl.conf`

The majority of the alterations to my

`apache/conf/extra/httpd-ssl.conf` seemed to arise from the addition

of a `VirtualHost` stanza for `Port 443`, as part of

the `Auth Tool` extension, something outside of the VDT

installation itself.

Noting that `apache/conf/extra/httpd-ssl.conf` is an include into the

main `Apache` config file, 

``` 

Include conf/extra/httpd-ssl.conf

```

I decided to try adding the `Auth Tool` modifications as a seperate file, and including that in the main config file, thus:

``` 

Include conf/extra/httpd-ssl.conf
Include conf/extra/httpd-ssl-443.conf

```

Note that this differs from the `Auth Tool` documentation,

however, with VDT knowing nothing about the new file, that file will

remain in place across updates and so there'd merely be one extra

change to the main config file required so as to maintain the 

functionality it added.

## Local data within the VDT

I was obviously concerned that updating the VDT might see any data

that had been added to the `MySQL` databases, that lie behind

the `GUMS`, lost but with the following document at the VDT

website 

>  [http://vdt.cs.wisc.edu/releases/2.0.0/installation_advanced.html#preserve_config](http://vdt.cs.wisc.edu/releases/2.0.0/installation_advanced.html#preserve_config)

detailing what data gets maintained across an installation into a

different `VDT_LOCATION`, summised that an in-situ update of

the `MySQL` component might well do the same and, happily, this

turns out to be the case.

# Running the VDT updater

Having now identified the files that had been modified from a "vanilla"

installtion of the VDT, the updater can be run.

I chose to explcitly set the `VDTMIRROR` as for the original 

install though this may be available to the update from the existing

installation.

``` 

export VDTMIRROR=http://vdt.cs.wisc.edu/vdt_200_cache
cd $VDT_LOCATION
vdt/update/vdt-updater

```

I saw the following output from the installer

``` 

-------------------------------------------------------------------------------
STEP 1 OF 6: INITIALIZATION

Updating '/opt/vdt' to VDT 2.0.0p25 (script revision 0).
Initialization complete.

-------------------------------------------------------------------------------
STEP 2 OF 6: CHECK BACKUP

It is very important to have a good backup of your VDT installation before
running updates, because failures during the update process can result in a VDT
that cannot be used or fixed easily.  To have the vdt-updater script check your
backup now, provide the absolute path to your backup directory below.  If you
are certain that you have a good backup, you can skip the check by leaving the
path blank, but we do not recommend doing so.

Absolute path to backup: /path/to/backup/vdt-location-200p17 Checking backup (may take a minute)...
Backup is good.

-------------------------------------------------------------------------------
STEP 3 OF 6: FETCHING LATEST VERSION OF vdt-updater

Checking vdt-updater version (may take a minute)...
The vdt-updater script is up-to-date.

-------------------------------------------------------------------------------
STEP 4 OF 6: PREPARE UPDATES

Checking installed packages (may take a minute)...

The following packages are installed and have been updated one or more times
since VDT 2.0.0 was released.  Therefore, this update may affect any or all of
these packages:  Apache, BC-Provider, CA-Certificates-Manager,
CA-Certificates-Updater, Configure-Apache, Configure-Fetch-CRL, Configure-GUMS,
Configure-MySQL, Configure-Tomcat, Configure-VDT-Logrotate, Fetch-CRL,
GUMS-Client, GUMS-Service, JDK-1.5, Licenses, Licenses, MyProxy-Client,
MyProxy-Essentials, MySQL-5, PHP, Tomcat-5.5, VDT-Common, VDT-Configure-Base,
VDT-Core, VDT-Core-Bin, VDT-Service-Management, VDT-System-Profiler,
VDT-Version, VDT-Version-Info, Wget

Type 'yes' to approve all updates: yes
All updates are approved.

-------------------------------------------------------------------------------
STEP 5 OF 6: PERFORM UPDATES

To update your VDT installation, this script will run 'pacman -update' on 7
packages.  Other packages listed above in Step 3 will be updated as needed
because they are dependencies.  Each 'pacman -update' command may take a few
minutes.

Updating 7 packages:
  * Apache
  * JDK-1.5
  * Tomcat-5.5
  * PHP
  * MyProxy-Client
  * GUMS-Service
  * GUMS-Client
The pacman updates are complete.

-------------------------------------------------------------------------------
STEP 6 OF 6: FINISHING THE UPDATE


Post-update steps complete.

Run vdt-post-install to complete configuration

--------------------------------------------------------------------------------
NEW VDT PACKAGES

Below is the list of packages that are new to the VDT since the original 2.0.0
release and that are not installed.  If you are interested in installing one or
more of them, or if you simply want more information about them, check the VDT
release documentation.

 * Pigeon-Tools (released in VDT 2.0.0p24)
 * gLite-FTS-Client (released in VDT 2.0.0p16)
 * Publish-SE-Info (released in VDT 2.0.0p19)
 * Bestman2 (released in VDT 2.0.0p20)
 * EDG-GridFTP-Client (released in VDT 2.0.0p16)

```

Despite my hopes having been raised by the

``` 

Type 'yes' to approve all updates:

```

prompt, answering "no" did not allow for a selection of a subset of 

packages, though as we see, only a subset do get updated.

# Post update inspection

Running a `vdt-version` then shows 

``` 

You have installed a subset of VDT version 2.0.0p25:

Software                                                 Status
--------                                                 ------
Apache HTTPD 2.2.16                                      OK
vdt-ca-manage 1.3                                        OK
vdt-update-certs 2.6                                     OK
CA Certificates v58 (includes IGTF 1.38 CAs)             -
Fetch CRL 2.8.5                                          OK
GPT 3.2-4.0.8p1                                          OK
Grid User Management System (GUMS) Client 1.3.17         OK
Grid User Management System (GUMS) Service 1.3.17        OK
Java 6 SDK 1.6.0_20                                      OK
Logrotate 3.7                                            OK
MyProxy Client 5.3                                       OK
MySQL 5.0.91                                             OK
PHP 5.2.14                                               OK
Apache Tomcat 5.5.28                                     OK
VOMS Client 1.8.8-2p1                                    OK
Wget 1.12                                                OK


Status legend:
OK: Software is up to date with the latest release in VDT version 2.0.0
- : Not enough information to determine if updates are available.
Type 'man vdt-version' for more information.

```

whilst a size comparison of the new and backed-up directories

suggests some space has been saved/recliamed

``` 

du -sm $VDT_LOCATION/ /path/to/backup/vdt-location-200p17
648     /opt/vdt/
753     /path/to/backup/vdt-location-200p17

```

though it is worth noting that the "update" `JDK 5` has 

actually moved to a `JDK 6`.

At this point I did an rsync of the updated installation, so as to 

have something to return to, choosing a directory name representing 

now current revision:

``` 

export $VDT_BACKUP_LOCATION=/path/to/backup/vdt-location-200p25
mkdir -p $VDT_BACKUP_LOCATION
rsync -a $VDT_LOCATION/ $VDT_BACKUP_LOCATION/

```

## Running `vdt-post-install`

The VDT instructions suggest running  `vdt-post-install` however

in the BeSTGRID installation guidelines, that was not mentioned.

Running it and comparing the VDT installation against the rsync'd copy

just made, shows that it merely creates one directory and adds a couple of

convenience links, suggesting there's little harm in running it.

``` 

# vdt-post-install
Starting...
Done.
Making log symlinks in /opt/vdt/logs
#
# rsync -avin $VDT_LOCATION/ /path/to/backup/vdt-location-200p25/
building file list ... done
>f.st.... vdt-install.log
.d..t.... logs/
cL+++++++ logs/apache -> /opt/vdt/apache/logs
cL+++++++ logs/globus -> /opt/vdt/globus/var
cL+++++++ logs/gums -> /opt/vdt/gums/log
cL+++++++ logs/tomcat -> /opt/vdt/tomcat/v55/logs
.d..t.... vdt/
cd+++++++ vdt/config/

```

I then rsync'd again to get a "base" 2.0.0p25 copy.

# Customising the new installation

Because the VDT updater has ignored any files it does not know about,

there will still be backup copies of files which were made for the

original installation.

I found these, (all name relatives to `$VDT_LOCATION`)

``` 

apache/conf/httpd.conf.orig
apache/conf/httpd.conf.bak
apache/conf/extra/httpd-ssl.conf.orig

```

suggesting I had not been as careful to create backups as I might have

been when editing files in the original install.

It seemed a good idea to remove these files ahead of carrying out any

customisation to files that the update had effectively removed, which would

see the `.orig` files created once again.

# Restarting and testing the updated NGGUMS

Having made the few changes that the update had seen lost, I then

restarted the VDT services and was pleasantly surprised to see 

things reappear:

``` 

# vdt-control --on
enabling cron service vdt-rotate-logs... ok
enabling cron service fetch-crl... ok
enabling cron service vdt-update-certs... ok
enabling init service apache... ok
enabling init service tomcat-55... ok
enabling init service mysql5... ok
enabling cron service gums-host-cron... ok
#

```

Navigating to the GUMS at [https://nggums.your.site:8443/gums](https://nggums.your.site:8443/gums) allowed 

me to verify that the mappings I had created were still visible.

Finally, a quick job submission via a command line from a grid-enabled

machine:

``` 

globusrun-ws -passive -submit -s -S -F ng2.your.site -Ft Fork -c /usr/bin/id
Delegating user credentials...Done.
Submitting job...Done.
Job ID: uuid:0b37e59c-4b81-11e0-8794-00163e142244
Termination time: 03/12/2011 01:44 GMT
Current job state: CleanUp-Hold
uid=123(arcsvo01) gid=123(arcsvo01) groups=456(arcsvo01),20004
Current job state: Done
Destroying job...Done.
Cleaning up any delegated credentials...Done.

```

provided verifcation that the original mappings were still also

available, via `GUMS`, to the job submission gateway.
