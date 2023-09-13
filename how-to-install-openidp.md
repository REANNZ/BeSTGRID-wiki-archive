# How to Install OpenIdP

- Create SSL certificate request for idp.bestgrid.org and submit to CA by Grix
- Setup a new VM with CentOS 4.4 installed
- Submit request to ITS to register DNS name idp.bestgrid.org for the new setup VM.
- Install PHP
- Install Java 1.5
- Install Apache Tomcat 5.5
- Install OpenLDAP
- Install OpenIdP registry.
- Obtain latest existing user information from old production BeSTGRID WIKI.
- Generate LDIF file to fill up the new installed OpenLDAP directory
- Create random password for each existing user in LDAP.
- Download BeSTGRID Shibboleth metadata from metadata repository
- Install Shibboleth IdP
