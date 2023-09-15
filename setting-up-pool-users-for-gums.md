# Setting up Pool Users for GUMS

# Introduction

The [initial set up of GUMS](setting-up-a-gums-server.md) is not ideal, as all BeSTGRID users end up using the same `grid-bestgrid` account. It is recommended that GUMS is reconfigured to provide pool users, that is a collection of anonymous user accounts that are dynamically mapped to individual Grid users. This will provide some persistence of their user space, and keep the users isolated from each other.

# Prerequisites

An operating GUMS server set up as a BeSTGRID gateway server is set up [according to these instructions](setting-up-a-gums-server.md)

# Setting up the pool accounts

Pool users have to exist on the computation resource that GUMS is authorising, so that the job submission gateway (a.k.a. NG2) can run jobs as those users. 

# Rocks Cluster

For a default Rocks Cluster, these users will have to exist in `/etc/passwd`, and have corresponding entris in `/etc/group`. In the case of the SCENZ-Cluster run by Landcare Research NZ ltd these users are managed using LDAP from the head node of the cluster to the job submission gateway. Though the instructions given below may not work in the general case, they may be adapted for other environments. If you set up your job submission gateway to authenticate users with LDAP and automount their home directory from the head node of the cluster, this will automatically share users and users' home directories with the job submission gateway and across the cluster compute nodes.

## Creating users

Running the following Perl script will create 500 anonyomous pool users. Modify the `$n` variable to change the number of users created.

``` 

#!/usr/bin/perl

# Pool User Generator
# For creating anonymous pool users in /etc/passwd

# Aaron Hicks hicksa@landcareresearch.co.nz
# Landcare Research NZ ltd.
# August 2010

use strict;
use warnings;

print "Pool user generator\n";

my $n = 500; # how many users?
my $homebase = "/export/home/"; # User base in Rocks starts as /export/home
my $userbase = "bestgrid"; #Must not end in a hyphen '-'!


for (my $i;$i <= ($n-1); ++$i)
{

  my $user=$userbase . sprintf("%03d",$i);
  my $home=$homebase.$user;
  print "INFO: Creating $user.\n";
  # system("/usr/sbin/userdel -rf $user\n"); # uncomment this if you need to destroy the user first.
  unless(getpwnam($user)) # test if user exists!
  {
    die "HALT: Unable to create user $user\n" if system("/usr/sbin/adduser $user\n");  # create user with no password
    die "HALT: Unable to create RSA key for $user\n" if system("su $user -c 'ssh-keygen -q -f ~/.ssh/id_rsa -N \"\"'\n"); # generate keys for SSH
    die "HALT: Unable to add ssh key to ~/.ssh/authorized_keys\n" if system("cat $home/.ssh/id_rsa.pub >> $home/.ssh/authorized_keys\n"); # authorise user's SSH key
  }  else 
  {
    print "WARN: Did not create $user, already exists!\n";
  }
  print "INFO: $user created.\n";
}  

```

Then sync the users over the cluster with:

``` 
sudo rocks sync users
```

**NOTE:** This step is critical as it creates the proper mappings of a users home directory, and replicates their RSA keys to the compute nodes.

## Migrating users to LDAP

- Log into the head node of the Rocks Cluster, which should already be configured to [share Rocks users with LDAP](/wiki/spaces/BeSTGRID/pages/3818228593).
- Export user and group data from `etc/passwd` and `/etc/group` respectivly:

``` 

grep bestgrid /etc/passwd > ~/bestgrid.passwd
grep bestgrid /etc/group > ~/bestgrid.group

```
- If the grep search matches any users that have already been added to LDAP, then they will need to be deleted from the list (they should be at the beginning)
- Convert the `/etc/passwd` and `/etc/group` extracts into `ldif`:

``` 

/usr/share/openldap/migration/migrate_passwd.pl bestgrid.passwd > ~/bestgrid.ldif
/usr/share/openldap/migration/migrate_group.pl bestgrid.group >> ~/bestgrid.ldif

```

- Import the `ldif` files into LDAP:

``` 

ldapadd -x -h localhost -D "cn=manager,dc=your,dc=cluster,dc=com" -W -f  ~/bestgrid.ldif

```

- Restart slapd

``` 

sudo /etc/init.d/ldap restart

```

## Deleting LDAP Users

If something goes wrong use this script to create a user list:

``` 

#!/usr/bin/perl

use strict;
use warnings;

my $basename = 'bestgrid';
my $n = 500;

open(my $FILE,'>',"dndelete.txt") or die $!;

for (my $i = 0; $i <= ($n -1); $i++)
{
  print $FILE "uid=$basename".sprintf("%03d",$i).",ou=People,dc=scenzgrid,dc=org\n";
  print $FILE "cn=$basename".sprintf("%03d",$i).",ou=Group,dc=scenzgrid,dc=org\n";
}

close($FILE)

```

Then use the following command to delete all the LDAP users:

``` 

ldapdelete -x -h localhost -D "cn=manager,dc=your,dc=cluster,dc=com" -W -f  dndelete.txt

```

# Configuring GUMS

GUMS and the job submission gateway should now be configured according to this article [here](configuring-a-gums-server-with-pooled-accounts.md).
