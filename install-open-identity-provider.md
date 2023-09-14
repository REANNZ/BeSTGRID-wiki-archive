# Install Open Identity Provider

# Introduction

The Open IdP is a Shibboleth Identity provider with a web interface which would allow users to register their details (without any verification).

This allows them to use Shibboleth without the burden of installing an IdP at their site.

It might also be a good mechanism for the slow and controlled adoption of Shibboleth in an institution which might have a small audience.

# Limitations of an OpenIdP

An Open IdP *could* be used in a legally sound federation, but it would be envisaged that some mechanism would be needed to identify the lack of validation and assurance one has regarding the information and attributes issued by the IdP

# Strengths of an OpenIdP

The concept of an Open IdP has the following strengths 

- Low cost of Shibboleth Piloting
- Most Shibboleth installations will be Service Providers, and not IdPs, this would give a good vehicle for development and testing
- There is no requirement for a institutional ldap or the complex process of adding people to the institutional identity management system

# Components

The components needed to accomplish this are

- WebServer and web application providing an interface allowing users the following functionality:
	
- Self-registation for at the following attributes:
		
- Common Name (login name etc)
- First Name(s)
- Last Name
- Email address
- Self-service password changes
- Free LDAP server (e.g. OpenLDAP) for the storage of personal data
	
- eduPerson schema loaded
- Shibboleth IdP configured to both authenticate and consume identity from this LDAP

# Install OpenIdP Registry

## Install Berkeley DB

- Download [Oracle Berkeley DB](http://www.oracle.com/technology/software/products/berkeley-db/index.html) tar ball.
- Unpack the tar ball, cd to the build_unix directory, and type *../dist/configure/*, followed by *make* and *make install* as root. This will create a directory called /usr/local/BerkeleyDB.4x, which contains all necessary libraries and binaries we need for the OpenLDAP Server installation.

## Install OpenLDAP Server

- Download and extract [OpenLDAP](http://www.openldap.org/software/download/) tar ball.
- Before install OpenLDAP server, set the environment variables as follows:

``` 

$ export CPPFLAGS="-I/usr/local/BerkeleyDB.4.x/include"
$ export LDFLAGS="-L/usr/local/BerkeleyDB.4.x/lib"
$ export LD_LIBRARY_PATH=/usr/local/BerkeleyDB.4.x/lib

```
- Follow the steps below to install OpenLDAP server

``` 

$ cd ~yjia032/openidpInstallation/openldap-2.3.32 (my installation directory)
$ ./configure --prefix=/usr/local/openldap (the path where OpenLDAP Server going to be installed)
$ make depend
$ make
$ make test
$ sudo su (change to root user)
# make install

```

## Configure OpenLDAP Server

- Edit /usr/local/openldap/etc/openldap/sldap.conf
- An example configuration file is located at [sldap.conf here](/wiki/spaces/BeSTGRID/pages/3818228519).
- Create a shielded password for the root DN.



- The *SLAPPW* variable contains the shielded string that is needed for the slapd.conf file. Insert the value of this variable into the slapd.conf file as following



- Change the permissions of /usr/local/openldap/ to user ldap

## Starting OpenLDAP Server

- Starting the slapd daemon as: #/usr/local/openldap/libexec/slapd -u ldap -h ldap://openidp.test.bestgrid.org/
- Check if slapd daemon is running

``` 
# ps -ef | grep slapd
ldap     22409     1  0 13:28 ?        00:00:00 /usr/local/openldap/libexec/slapd -u ldap -h ldap://openidp.test.bestgrid.org/
ldap     22410 22409  0 13:28 ?        00:00:00 /usr/local/openldap/libexec/slapd -u ldap -h ldap://openidp.test.bestgrid.org/
ldap     22411 22410  0 13:28 ?        00:00:00 /usr/local/openldap/libexec/slapd -u ldap -h ldap://openidp.test.bestgrid.org/
ldap     22412 22410  0 13:28 ?        00:00:00 /usr/local/openldap/libexec/slapd -u ldap -h ldap://openidp.test.bestgrid.org/
ldap     22413 22410  0 13:28 ?        00:00:00 /usr/local/openldap/libexec/slapd -u ldap -h ldap://openidp.test.bestgrid.org/
root     22540 22368  0 14:27 pts/1    00:00:00 grep slapd

```
- Add an organisation called *people* into LDAP database by importing a LDIF file as below:

``` 

dn: dc=openidp,dc=test,dc=bestgrid,dc=org
dc: openidp
description: BeSTGRID OpenIDP LDAP DB
objectClass: dcObject
objectClass: organization
o: BeSTGRID Open Identity Provider.

dn: ou=people,dc=openidp,dc=test,dc=bestgrid,dc=org
ou: people
description: All user in BeSTGRID OpenIdP
objectclass: organizationalunit

```
- Load the LDIF file into database

``` 
ldapadd -x -D "cn=Manager,dc=openidp,dc=test,dc=bestgrid,dc=org" -f createPeople.ldif -W
```

# Email Setup

- Add "Smart" replay host into /etc/mail/sendmail.cf

e.g. DSmailhost.auckland.ac.nz
- Restart sendmail

/etc/init.d/sendmail restart

# References

[eduPerson Schema](/wiki/spaces/BeSTGRID/pages/3818228510)

# Maintenance

If slapd fails to start after a system crash (`service slap start` says "starting slapd" but doesn't really start anything), and if `/usr/sbin/slapd -d 1 -u ldap -h ldap:///` reports:

``` 

slapd startup: initiated.
bdb_db_open: dbenv_open(/var/lib/ldap/idp)
=> bdb_last_id: get failed: Cannot allocate memory (12)
bdb_db_open: last_id(/var/lib/ldap/idp) failed: Cannot allocate memory (12)
backend_startup: bi_db_open(0) failed! (12)

```

The following command can fix the database:

``` 
/usr/sbin/slapd_db_recover -h /var/lib/ldap/idp
```
