# Experimenting with grid gateway enhancements at University of Canterbury

This page documents a few (successful) experiments with grid gateway configuration.  The notes have been written up for other to be able to reproduce this experiment - and if possible, for the community to embrace them as standard practice.

# Marker VOs

*Marker VO* is a technique that allows to submit jobs that are considered to be VO-based jobs by Globus (are submitted with a VOMS certificate), but run under the local personal account of a user.  While it's been possible to run jobs under the local account with a plain (non-VOMS) proxy certificate, the ability to run such jobs with a VOMS proxy would greatly simplify how Grisu handles such jobs (instead of requiring special treatment, they would just become ordinary VO-based jobs).  

Note that the term marker VO refers also to the VO group used to realize this technique itself.  The term comes from the fact that membership in this VO does not grant any privileges, the membership only serves as a marker that the user has a local account - and an individually established mapping to that account.  The marker VO indicates that the user has access to a local account on this system.  The use of this VO then triggers the mapping to the local account - but only if such a local account mapping exists.

To get Marker VOs working at a site (and allow Grisu to submit jobs via that marker VO), the following steps have to be done:

1. Create the Marker VO itself - e.g., `/ARCS/LocalAccounts/CanterburyHPC`
2. Configure the GUMS server to map the marker VO to local accounts.
3. In the Site's MDS registration, create a VO view advertising ComputeElement as accessible to this VO.
4. Create a directory accessible by this VO via GridFTP (and bound with the ComputeElement) and advertise it in MDS as such.

In addition, each user with a local account at the site has to:

1. Obtain a local mapping at the site - via the site's Auth Tool.
2. Obtain membership in the marker VO.
3. Get a symbolic link named after the user's DN and pointing to the user's home directory created in the local accounts directory.

## Creating the Marker VO

The Marker VO should be created under `/ARCS/LocalAccounts` and be named after the site (or a specific cluster at the site if the site has several cluster with distinct user codes as is the case of Canterbury).

The site's grid administrator (or a local RAO) should be the owner of the VO.  There's no risk involved - just the membership itself does not grant any privileges.

## Configuring GUMS server to marker VO

- We assume the GUMS server is already configured with local mappings created with the Auth Tool.

- Define a User Group on the GUMS server including everyone in the site's marker VO.  Example: ARCSLocalAccountsCanterburyHPC group including all users in `/ARCS/LocalAccounts/CanterburyHPC`

``` 

VOMS User Group:  ARCSLocalAccountsCanterburyHPC
Description: ARCS LocalAccounts Canterbury HPC marker VO
VOMS Server: ARCS
URL: {base url}/ARCS/services/VOMSAdmin
Accept non-VOMS certificates: true
VOMS certificate's FQAN is matched as: vogroup
VO/Group: /ARCS/LocalAccounts/CanterburyHPC
GUMS Access: read self

```

>  **Create a**'Group To Account Mapping*' linking the Marker VO with the `manualGroup` *Account Mapper*

``` 

Name:  HPCLocalAccountsViaVO
Description: Mapping to HPC local accounts via a VO
User Group: ARCSLocalAccountsCanterburyHPC
Account Mapper: manualGroupHPC

```

- Add this *Group To Account Mapping* into the site's (or clusters) HostToGroup mapping (right after the ManualMapper).

## Registering the Marker VO in MDS

Add the following snippet into `/usr/local/mip/config/apac_config.py` to advertise a new VO view on the ComputeElement:

>       voview = computeElement.views\['viewHPCLocal'\] = VOView()
>       #voview.RealUser = 'grid-xxx'
>       voview.DefaultSE = 'ng2hpc.canterbury.ac.nz'
>       #voview.DataDir = '/hpc/home/grid-xxx'
>       voview.ACL = \['/ARCS/LocalAccounts/CanterburyHPC'\]

Note that we are not specifying a RealUser, neither a DataDir.

## Create a base directory for the Marker VO

To submit a job to a Site, Grisu needs to see the permissions right for both (a) the ComputeElement (just done) and (b) a data directory used for staging.  Because we cannot advertise a separate directory for each of the users, we need to create a single directory used by all local users.

In this case, create `/hpc/gridusers/localaccounts` - and make it writable only to root.  Users will not be storing any files on this directory, they will be only traversing into their home directory via a symbolic link.

We advertise the directory as accessible to all members of the marker VO by adding the following snippet into `/usr/local/mip/config/apac_config.py`:

>   area = storageElement.areas\['area3'\] = StorageArea()
>   area.Path = '/hpc/gridusers/localaccounts'
>   area.Type = 'volatile'
>   area.ACL = \['/ARCS/LocalAccounts/CanterburyHPC'\]

## Creating the symbolic links

Grisu will be considering the marker VO directory advertised in MDS as the VO home directory, and will be using a subdirectory named after the user's DN to separate each user's jobs.  We need a symbolic link named after the DN of each user to point to user's actual home directory.

The symbolic links should look like: 

``` 

vme28@l3n02-c:/hpc/gridusers/localaccounts$ls -l
total 64
lrwxrwxrwx  1 root root  15 2009-03-04 10:26 C_AU_O_APACGrid_O_BeSTGRID_OU_University_of_Canterbury_CN_Tony_Dale -> /hpc/home/ajd41
lrwxrwxrwx  1 root root  15 2009-03-04 10:26 C_AU_O_APACGrid_OU_Monash_University_CN_Graham_Jenkins -> /hpc/home/gkj16
lrwxrwxrwx  1 root root  15 2009-03-04 10:26 C_AU_O_APACGrid_OU_VPAC_CN_Graham_Jenkins -> /hpc/home/gkj16
lrwxrwxrwx  1 root root  15 2009-03-04 10:26 C_NZ_O_BeSTGRID_OU_University_of_Canterbury_CN_Peyman_Zawar-Reza -> /hpc/home/pre24
lrwxrwxrwx  1 root root  15 2009-03-04 10:26 C_NZ_O_BeSTGRID_OU_University_of_Canterbury_CN_Vladimir_Mencl -> /hpc/home/vme28
lrwxrwxrwx  1 root root  15 2009-03-04 10:26 DC_nz_DC_org_DC_bestgrid_DC_slcs_O_University_of_Canterbury_CN_Vladimir_Mencl_L_bXc3nKeqCteJms2xJjA8O4L2Q -> /hpc/home/vme28

```

The links can be created based on the information in the local mappings grid-map file - and could be created automatically by the Auth Tool each time a local mapping is created.

This process has not been automated yet: so far, the links at Canterbury were created manually with a simple perl script ran manually on the local mappings grid-map file.

This is the perl script:

``` 

#!/usr/bin/perl

open(MAPFILE,"<mapfile") or die("cannot open mapfile");

while (<MAPFILE>) {
  chomp;
  if ( /"([^"]*)"\s+(\S+)/ ) {
     #print "DN=$1, account=$2\n";
     #
     # shell script grisufying done in 
     # brecca.vpac.monash.edu.au:/etc/bashrc.local

     # Extract and Grisufy the subject: C_AU_O_APACGrid_OU_VPAC_CN_Andy_Botting
     # SUBJECT=`openssl x509 -noout -in $X509_USER_PROXY -subject | 
     # sed 's/subject= //g' | sed 's/\/CN=proxy//g' | 
     # tr -s '/?:@=& ' '_' | sed 's/^_//g'`
     $dn = $1;
     $account = $2;
     $dn =~ s/[\/?:@=& ]/_/g;
     $dn =~ s/^_+//;
     print "ln -s /hpc/home/$account $dn\n";
     system("ln -s /hpc/home/$account $dn");
  } else {
     print "Cannot parse $_\n";
  };
}
close(MAPFILE);

```

# Cloud VO: Pooled accounts

Trying out if pooled accounts would work with GUMS to support the Cloud VO (which would separate users for privacy and fair-share schedulers) - and it works as a sharm:

- Add AccountMapper:

``` 

Name: NZ-Cloud-pool-mapper
Description: dtto
Type: pool
Pool Name: blank
Persistence Factory: mysql

```

- Manage pool accounts: Add "gridnzcloud001-100" for this mapper

- Define a user group (based on a VOMS group): /ARCS/BeSTGRID/Demo-VO, ARCSDemoVOUserGroup

- Add GroupToAccountMapper:

``` 

Name: Demo-VO-to-pool-account
Desc: dtto
User Group: ARCSDemoVOUserGroup
AccountMapper: NZ-Cloud-pool-mapper

```

- Add this to host to group account mapping.

- Testing this: Map Grid Identity:

``` 

Service DN: /CN=ng2.canterbury.ac.nz
User DN: (me)
VOMS FAQ: /ARCS/BeSTGRID/Demo-VO

```
- Result: gridnzcloud001

Note that the mappings are assigned permanently, stored in the `MAPPINGS` MySQL database.  They would never expire - though they can be manually removed (via User Management -> Manual Account Mappings) when a user is no longer using the mapped pool account.
