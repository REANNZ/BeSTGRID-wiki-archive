# Setting up a GUMS server on Ubuntu

This guide is tightly meshed with the [Setting up a GUMS server](/wiki/spaces/BeSTGRID/pages/3816950966) guide. It tries to avoid redundancies and refers back frequently to its parent.

At time of writing the descriptions are based on the (64 bit) server release of Ubuntu 10.04 LTS (Long Term Support, code name "Lucid Lynx"). It is likely to work equally well with slightly older or newer releases, 32 bit releases and with (some minor) modifications with current Debian releases as well.

Note: Some of these notes may not be 100% in proper chronological order. The order has been retained from the original install notes to keep them in sync. But it should be quite obvious that certain configuration can only be integrated into VDT once VDT has been installed. Please, keep this in mind when using this guide. 

# Preliminaries

See also [Setting up a GUMS server#Preliminaries](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-Preliminaries).

## OS requirements

See also [Setting up a GUMS server#OS requirements](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-OSrequirements).


# GUMS install

## Clean the System

See also [Setting up a GUMS server#Clean CentOS Install](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-CleanCentOSInstall).

We're not running CentOS, but it may still make sense to check the system for a clean install. Make sure there is no Apache web server (package `apache2`) or MySQL server (package `mysql-server`) installed. Remove or purge these package first to insure a working setup.

## Check Firewall

See also [Setting up a GUMS server#Check Firewall](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-CheckFirewall).

## Prerequisite Packages

See also [Setting up a GUMS server#Prerequisite Packages](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-PrerequisitePackages).

No repositories need to be added/edited.

Get and install the APAC GridPulse system monitor:

- Get the RPM from the ARCS RPM repository, in this case here: [http://projects.arcs.org.au/dist/production/5/x86_64/noarch/APAC-gateway-gridpulse-0.3-4.noarch.rpm](http://projects.arcs.org.au/dist/production/5/x86_64/noarch/APAC-gateway-gridpulse-0.3-4.noarch.rpm)
- Convert it with the `alien` tool to a Debian package (do not use the `--scripts` option), copy the Debian package to the host and install it.


>  ***Hack the script **`/usr/local/bin/gridpulse`** to fit Ubuntu!**  This one should work for a start: [gridpulse](/wiki/download/attachments/3816950479/Gridpulse.sh?version=1&modificationDate=1539354115000&cacheVersion=1&api=v2) (Note: renamed for upload on the wiki.)
>  ***Hack the script **`/usr/local/bin/gridpulse`** to fit Ubuntu!**  This one should work for a start: [gridpulse](/wiki/download/attachments/3816950479/Gridpulse.sh?version=1&modificationDate=1539354115000&cacheVersion=1&api=v2) (Note: renamed for upload on the wiki.)

- Create a file `/usr/local/lib/gridpulse/system_packages.pulse` and add the following line to it:


>  apac-gateway-gridpulse
>  apac-gateway-gridpulse

- Add a `crontab` entry for executing the script every 20 minutes:


>  3,23,43 * * * * /usr/local/bin/gridpulse grid_pulse@lists.arcs.org.au >/dev/null 2>&1
>  3,23,43 * * * * /usr/local/bin/gridpulse grid_pulse@lists.arcs.org.au >/dev/null 2>&1

## Pacman and VDT

See also [Setting up a GUMS server#Pacman and VDT](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-PacmanandVDT).

Most of these steps are *much* more easily performed with a root shell. To obtain one use the following:

>  $ sudo su -

Following steps using a root shell use a preceding shell prompt "`#`".


> 1. mkdir -p /opt/vdt
> 1. mkdir -p /opt/vdt

- Download and setup `pacman` (the packager used)


> 1. cd /opt/vdt
> 2. wget [http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz](http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz)
> 3. tar xfz pacman-latest.tar.gz
> 4. cd pacman-3.29 && source setup.sh && cd ..
>  **Install Grid tools from VDT (*Note:** It is *very* important to use the `-pretend-platform` switch at the first usage of `pacman`. For Ubuntu Karmic (9.10) and Lucid (10.04) "Debian-5" worked well.)
> 5. cd /opt/vdt
> 6. export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
> 7. pacman -pretend-platform Debian-5 -get $VDTMIRROR:GUMS
> 1. cd /opt/vdt
> 2. wget [http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz](http://physics.bu.edu/pacman/sample_cache/tarballs/pacman-latest.tar.gz)
> 3. tar xfz pacman-latest.tar.gz
> 4. cd pacman-3.29 && source setup.sh && cd ..
>  **Install Grid tools from VDT (*Note:** It is *very* important to use the `-pretend-platform` switch at the first usage of `pacman`. For Ubuntu Karmic (9.10) and Lucid (10.04) "Debian-5" worked well.)
> 5. cd /opt/vdt
> 6. export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
> 7. pacman -pretend-platform Debian-5 -get $VDTMIRROR:GUMS

- Make the environment variable setup script created by VDT load in the default profile


> 1. ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
> 2. . /etc/profile
> 1. ln -s /opt/vdt/setup.sh /etc/profile.d/vdt.sh
> 2. . /etc/profile

## Configure VDT certificate distribution

Proceed as described in [Setting up a GUMS server#Configure VDT certificate distribution](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-ConfigureVDTcertificatedistribution).

## Set ServerName in Apache

Proceed as described in [Setting up a GUMS server#Set ServerName in Apache](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-SetServerNameinApache).

## MOD_SSL Bug

Proceed as described in [Setting up a GUMS server#MOD_SSL Bug](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-MOD_SSLBug).

## Turn VDT services on

Proceed as described in [Setting up a GUMS server#Turn VDT services on](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-TurnVDTserviceson).

# Post-install configuration

Proceed as described in [Setting up a GUMS server#Post-install configuration](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-Post-installconfiguration).

# Populate GUMS configuration

Proceed as described in [Setting up a GUMS server#Populate GUMS configuration](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-PopulateGUMSconfiguration).

# Polishing Globus

See also [Setting up a GUMS server#Polishing Globus](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-PolishingGlobus).

Do not edit the starting scripts for fixing the starting order. Do proceed in this following way, however to fix the problem with the starting order of MySQL, Tomcat and Apache:

- Enable the linking of the script into the init process using `update-rc.d` (the fields "90", "95" and "99" are important for indicating the starting order of the services). Stop the services, remove their starting order links, re-insert the links, and finally start them again.


>  $ # Stop services
>  $ sudo service apache stop
>  $ sudo service tomcat-55 stop
>  $ sudo service mysql5 stop
>  $ # Remove service links
>  $ sudo update-rc.d -f mysql5 remove
>  $ sudo update-rc.d -f tomcat-55 remove
>  $ sudo update-rc.d -f apache remove
>  $ # Insert service links
>  $ sudo update-rc.d mysql5 defaults 90
>  $ sudo update-rc.d tomcat-55 defaults 95
>  $ sudo update-rc.d apache defaults 99
>  $ # Start services
>  $ sudo service mysql5 start
>  $ sudo service tomcat-55 start
>  $ sudo service apache start
>  $ # Stop services
>  $ sudo service apache stop
>  $ sudo service tomcat-55 stop
>  $ sudo service mysql5 stop
>  $ # Remove service links
>  $ sudo update-rc.d -f mysql5 remove
>  $ sudo update-rc.d -f tomcat-55 remove
>  $ sudo update-rc.d -f apache remove
>  $ # Insert service links
>  $ sudo update-rc.d mysql5 defaults 90
>  $ sudo update-rc.d tomcat-55 defaults 95
>  $ sudo update-rc.d apache defaults 99
>  $ # Start services
>  $ sudo service mysql5 start
>  $ sudo service tomcat-55 start
>  $ sudo service apache start

# Next: Install Auth Tool

See also [Setting up a GUMS server#Next___Install Auth Tool](/wiki/spaces/BeSTGRID/pages/3816950966#SettingupaGUMSserver-Next___InstallAuthTool).

Setup content of this section has not been tested for Ubuntu.
