# LDAP-based GUMS mapping to individual accounts

An alternative to [Pool Accounts](/wiki/spaces/BeSTGRID/pages/3818228667) and [Shibboleth Auth  Tool](/wiki/spaces/BeSTGRID/pages/3818228565) to map users to individual accounts on grid gateways.  

# Comparison with Pool Accounts

Advantages of this  approach:

- easier to map certificates to individual cluster accounts
	
- Shibboleth Auth Tool can be used for the same  purpose but it requires extra steps from the user
- resulting LDAP database can be used for other purposes such as:
	
- provisioning accounts on gateway(s) and other resources
- potentially for mapping data fabric users. At the moment IRODS does not support LDAP.
- as accounts are created on demand there is no problem with their depletion
- easier to associate user with account

Disadvantages:

- account creation is not under administrative control
	
- provided script does not create accounts but generates ldif which could be emailed to administrator instead of adding it to the database straight away. But this approach requires more manual work.
- accounts created even for inactive users
	
- on the other hand, "generate grid mapfile" GUMS function can be used as often as needed for testing.

# Prerequisites

- ldap server with read and write access
- valid host certificate to connect to VOMS server
- VOMS Admin library  [http://code.arcs.org.au/gitorious/voms-admin](http://code.arcs.org.au/gitorious/voms-admin)
	
- on CentOS 5 in can be installed from the following rpm [http://vhpc-bestgrid.auckland.ac.nz/repo/noarch/voms-admin-1.0-1.noarch.rpm](http://vhpc-bestgrid.auckland.ac.nz/repo/noarch/voms-admin-1.0-1.noarch.rpm)
- optional: access to shared token database

# GUMS Configuration

create new mapper of type ldap:

``` 

Name: ldapMapper
Description: maps certificate DN to user account in ldap
Type: ldap
JNDI LDAP URL:ldap://cluster.your.domain/dc=cluster,dc=your,dc=domain
LDAP Certificate DN Field: description
LDAP Account UID Field: uid

```

and associate any user group with it. Resulting mapping can be added to any host. 

# Populating LDAP Database

The are many ways to achieve this, our approach is based on VOMS information to generate individual account  "firstname.secondname" from certificate CN using python script [https://subversion.ceres.auckland.ac.nz/BeSTGRID/importUsersFromVOMS.py](https://subversion.ceres.auckland.ac.nz/BeSTGRID/importUsersFromVOMS.py)

Sometimes resulting username will not be unique in which case the script appends uid 

and can be run as

``` 

python /usr/share/scripts/importUsersFromVOMS.py /etc/voms_accounts.ini /ARCS/BeSTGIRD

```

to generate ldif of new users. The configuration file, /etc/voms_accounts.ini, contains connection details to various systems and should only be readable by root. Example: 

``` 

[LDAP]
ldap_uri = ldap://localhost:389
base_dn = ....
user_base = ou=People,...
bind_dn = ....
ldap_password = ****

[VOMS]
root_vo = /ARCS
host = vomrs.arcs.org.au
port = 8443
certificate = /etc/grid-security/hostcert.pem
key = /etc/grid-security/hostkey.pem

[User]
loginShell  = /bin/bash
home = /home
group=6000


```

# Account Creation

Strictly speaking, there is no requirement to use LDAP for accounts on the cluster as we can generate passwd entries from resulting ldif.  

On Rocks clusters with LDAP authentication (have a look at [Sharing Rocks users with LDAP](/wiki/spaces/BeSTGRID/pages/3818228593)) the following shell script can be installed as cron job to create accounts  :

``` 

#!/bin/bash

NEW_USERS_FILE=/tmp/users${RANDOM}
VO=/ARCS/BeSTGRID
BINDDN="cn=manager,dc=er171,dc=ceres,dc=auckland,dc=ac,dc=nz" 
CONFIG=/etc/voms_accounts.ini
SCRIPT=/usr/share/scripts/importUsersFromVOMS.py

PASSWORD=$(cat $CONFIG|grep ldap_password|awk -F= '{print $2}')


python $SCRIPT $CONFIG $VO > $NEW_USERS_FILE
ldapadd -c -x -h localhost -w $PASSWORD   -D $BINDDN -f $NEW_USERS_FILE

for i in $(cat $NEW_USERS_FILE|grep "Adding new user"|awk '{print $5}')
do
  echo "n"|su $i -c  'ssh-keygen -q -f ~/.ssh/id_rsa -N ""'
  su $i -c  'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
done

rm $NEW_USERS_FILE

rocks sync users


```

# Mapping Shared Token to Shibboleth Username

For SLCS users from your institution it is possible to map them to their shibboleth username if shared token is persisted in the database, and this database is available for read access. The script needs to be provided with database details via config file:

``` 

[MySQL]
user = cluster
host = shared-token.db.host
db = idp_db
password = *****

```

Note that there is no reliable way to associate old style APAC identity with SLCS, so users logging in under non-SLCS certificate will be mapped under different account. 

# Testing

"generate grid mapfile" function on GUMS server can be used to verify mappings. Any change to the database will be seen by GUMS immediately as it queries ldap for every mapping.
