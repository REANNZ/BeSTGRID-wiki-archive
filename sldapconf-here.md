# Sldap.conf here

``` 

include         /usr/local/openldap/etc/openldap/schema/core.schema
include         /usr/local/openldap/etc/openldap/schema/cosine.schema
include         /usr/local/openldap/etc/openldap/schema/inetorgperson.schema
include         /usr/local/openldap/etc/openldap/schema/nis.schema
include         /usr/local/openldap/etc/openldap/schema/eduPerson.schema

#Allow binding version 2 which used by php-ldap module
allow bind_v2

pidfile         /usr/local/openldap/var/run/slapd.pid
argsfile        /usr/local/openldap/var/run/slapd.args

database        bdb
suffix          "dc=openidp,dc=test,dc=bestgrid,dc=org"

#Access Control Rules:
access to *
       by self       write
       by anonymous  auth
       by *          none

rootdn         "cn=Manager,dc=openidp,dc=test,dc=bestgrid,dc=org"
directory       /usr/local/openldap/var/openldap-data

# Indices to maintain
index objectClass                       eq,pres
index ou,cn,mail,surname,givenname      eq,pres,sub
index uidNumber,gidNumber,loginShell    eq,pres
index uid,memberUid                     eq,pres,sub
index nisMapName,nisMapEntry            eq,pres,sub

rootpw {SSHA}ZfSU6CiWcVWx4R99ReR1khQ6sS4jTD3z

```
