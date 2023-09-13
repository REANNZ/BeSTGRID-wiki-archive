# Waikato GUMS server setup

# Overview

As recommended in the deployment guidelines for ARCS and BeSTGRID, this GUMS server is being deployed.

This host is a Virtual Machine, using the x86_64 64 bit system architecture.  The Distribution is Debian Lenny (5.0), amd64.  The system image is based on a `debootstrap` generated system image, rather than an install from an ISO.  This meant that various debconf settings were not done on installation.  See [Debian Tips](/wiki/spaces/BeSTGRID/pages/3816950813)

It was installed following these documents:

- [http://technical.bestgrid.org/index.php/Setting_up_a_GUMS_server](http://technical.bestgrid.org/index.php/Setting_up_a_GUMS_server)
- [http://technical.bestgrid.org/index.php/Setting_up_a_GUMS_server_on_Ubuntu](http://technical.bestgrid.org/index.php/Setting_up_a_GUMS_server_on_Ubuntu)

# Apt sources.list

``` 

deb http://ftp.monash.edu.au/pub/linux/debian/ lenny main
deb http://security.debian.org/ lenny/updates main

```

# X509 ARCS Host Certificate Details

``` 

Subject/DN: "C=NZ/O=BeSTGRID/OU=The University of Waikato/CN=ng2.symphony.waikato.ac.nz"
Valid from: Aug 16 01:17:43 2010 GMT
Valid until: Aug 16 01:17:43 2011 GMT
Issued by: C=AU, O=APACGrid, OU=CA, CN=APACGrid/emailAddress=camanager@vpac.org
Contact email: symphony_admins@wand.net.nz

```

Emails with regard to renewal will come to the above address.  The certificate, its signing request, and the key can all be found in `/etc/grid-security` on the machine.  The key file is unencrypted. This certificate request and key are read-only for the root user.

The steps in [Debian Tips](/wiki/spaces/BeSTGRID/pages/3816950813) were carried out to make the machine more administrator friendly, with an emphasis on remote access.

# SMTP Mail Server Details

Post fix was installed with `apt-get install postfix`.  It is configured as a `Satelite system`, with mail smart host set to `mail.wand.net.nz`.  The system mail name is set to `nggums.symphony.waikato.ac.nz`.

# Grid pulse setup

The instructions up at [Setting_up_a_GUMS_server_on_Ubuntu#Prerequisite_Packages Prerequisite Packages](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setting_up_a_GUMS_server_on_Ubuntu&linkCreation=true&fromPageId=3816950733) were followed.

Here's a tip for Debian Lenny, or Debian 5. I installed `fakeroot` and `alien`, and did the following in my home directory:

``` 

$ wget http://projects.arcs.org.au/dist/production/5/x86_64/noarch/APAC-gateway-gridpulse-0.3-4.noarch.rpm
$ apt-get install fakeroot alien
$ fakeroot alien APAC-gateway-gridpulse-0.3-4.noarch.rpm

```

# VDT Pacman set up

As per [Pacman and VDT](http://technical.bestgrid.org/index.php/Setting_up_a_GUMS_server_on_Ubuntu#Pacman_and_VDT). Since we are on Debian 5, no major problems here.

The package `insserv` needs to be installed for the VDT init scripts to be set up by `chkconfig`.

``` 

# apt-get install insserv

```

To load VDT shell environment on login to server the following has to be added to `/etc/profile`

``` 

# Add this to deal with VDT environment setup
# Debian Squeeze has /etc/profile.d directory
# Matthew Grant <grntma@physics.otago.ac.nz> Mon, 06 Sep 2010 12:53:35 +1200
if [ -d /etc/profile.d ]; then
        for i in /etc/profile.d/*.sh; do
                if [ -r $i ]; then
                        . $i
                fi
        done
        unset i
fi

```

and the `/etc/profile.d` directory created.

``` 

# mkdir /etc/profile.d

```

Then the setup as per [Pacman and VDT](http://technical.bestgrid.org/index.php/Setting_up_a_GUMS_server_on_Ubuntu#Pacman_and_VDT) works.

# Rest of the Setup

Follow the rest of [Setting up a Gums Server on Ubuntu](http://technical.bestgrid.org/index.php/Setting_up_a_GUMS_server_on_Ubuntu#Configure_VDT_certificate_distribution), using the alternative way of patching up the start up order of apache, tomcat, and mysql.
