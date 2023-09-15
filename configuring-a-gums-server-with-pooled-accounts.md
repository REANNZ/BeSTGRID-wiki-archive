# Configuring a GUMS server with pooled accounts

Initially, the grid gateways were configured to map all users in the same VO Group to the same local system account.  While this works well for a small project, it shouldn't be used at large scale projects where the users don't closely collaborate / don't know each other.

A much more preferred way is to map each user to an individual account.  This might be the user's already existing account on the system (if they link the local identity with their grid identity either via the Auth Tool or the [Shib Auth Tool](deploying-shibbolized-authtool-on-a-gums-server.md)), or it could be an account from a large account pool pre-created on the system.  

This page documents how to configure a [GUMS server](setting-up-a-gums-server.md) to perform both kinds of mappings, individual account mappings and pooled account mappings.

# Prerequisites

A GUMS server already installed and configured with the following configuration entries:

- A VOMRS server (this would be the ARCS VOMRS server for BeSTGRID, vomrs.arcs.org.au)
- A UserGroup for each group on the VOMRS server to be mapped.

If users are to be mapped to their personal accounts, the Auth Tool and Shib Auth Tool should be already installed and the GUMS server should have the `manualUsers` user group and the `manualGroup` account mapper.

# Pre-creating accounts

The GUMS server will be allocating accounts from a pool - and the accounts must be pre-created beforehand, and must be named following a suitable naming convention.

Also, the pool must be suitably sized.  At the time of writing (August 2010), there are 170 users in the BeSTGRID group.  To sufficiently plan for the future, I recommend creating 500 accounts in the pool.

The recommended naming scheme would be naming the accounts `grid001` - `grid500`.  All of the accounts in the pool must have the same base name, followed by a zero-prefixed number padded to the width of the maximum value.  The base name **must not** contain any hyphens.

To illustrate this, a very simple approach to creating the accounts would be:

>  ACCT=1 ; while [Configuring a GUMS server with pooled accounts](configuring-a-gums-server-with-pooled-accounts.md) ; do ACCT_NAME=$( printf 'grid%03d' $A ) ; adduser $ACCT_NAME ; ACCT=$(( $ACCT + 1 )) ; done

A a more detailed description how this would be done [on a Rocks cluster](/wiki/spaces/BeSTGRID/pages/3818228667)

# Configuring GUMS

In the GUMS web configuration interface, go to Account Mappers and *add* a new pooled account mapper:

>  Name: BeSTGRIDPoolAccountMapper
>  Description: BeSTGRID Pool AccountMapper
>  Type: pool
>  Pool Name/Groups: BeSTGRID
>  Persistence factory: mysql (only choice)

Next, load the pre-created accounts into the pool.  Go to "Manage Pool Accounts", fill in the following:

>  Account Pool Mapper: BeSTGRIDPoolAccountMapper
>  Account Pool: BeSTGRID
>  Range: grid001-500 (enter the first account name, followed by a hyphen, followed by the index **number** of the last account in the range)

and choose **Add**

Next, define a Group to Account Mapping.  This will be slightly different from how this has been done for shared account mappers.  Firstly, the Account Mapper used will be the above defined BeSTGRIDPoolAccountMapper.  Second, if the system is also configured with the Auth Tool, the manualGroup account mapper should be used as well, **preceding** the pool account mapper.

So, if configuring with the Auth Tool, the Group to Account Mapping should be configured like this:

>  Name: BeSTGRID to pooled accounts
>  Desc: BeSTGRID to pooled accounts
>  User Group(s): ARCSBeSTGRIDUserGroup
>  Account Mapper: manualGroup, BeSTGRIDPoolAccountMapper
>  Accounting VO Subgroup:              (leave blank)
>  Accounting VO:                       (leave blank)

Without the Auth Tool, the Group to Account Mapping would be just:

>  Name: BeSTGRID to pooled accounts
>  Desc: BeSTGRID to pooled accounts
>  User Group(s): ARCSBeSTGRIDUserGroup
>  Account Mapper: BeSTGRIDPoolAccountMapper
>  Accounting VO Subgroup:              (leave blank)
>  Accounting VO:                       (leave blank)

Now proceed as usual with configuring a Host To Group mapping, including this Group to Account Mapping for your NG2.

# MDS changes

Because each of the accounts has a different home directory, MDS can now longer advertise the full path to the home directory of the VO account.  To work around this, Grisu supports expanding `${GLOBUS_USER_HOME`} into the home directory of the account. Modify your `/usr/local/mip/config/apac_config.py` accordingly - the VOView and StorageArea definitions for VOs using pooled accounts should now look like the following:

``` 

# VOVIEW
voview = computeElement.views['ng2.canterbury.ac.nz-bestgrid'] = VOView()
#voview.RealUser = 'grid001-500'
voview.DefaultSE = 'ng2.canterbury.ac.nz'
voview.DataDir = '${GLOBUS_USER_HOME}'
voview.ACL = [ '/ARCS/BeSTGRID' ]
# /VOVIEW

```

and

``` 

area = storageElement.areas['area-ng2.canterbury.ac.nz-bestgrid'] = StorageArea()
area.Path = '/home'
area.VirtualPath = '${GLOBUS_USER_HOME}'
area.Type = 'volatile'
area.ACL = [ '/ARCS/BeSTGRID' ]

```

# Testing

In the GUMS server web interface, go to Map Grid Identity to Account and fill in the form like this:

>  DN (service): /CN=ng2.your.site.domain
>  DN (user): your own DN (also shown at the bottom of the page)
>  VOMS FQAN for user: /ARCS/BeSTGRID (or other VO configured for pooled accounts)

Hit the "map user" button.  You should get an account assigned from the pool.

Important note: after configuring pooled accounts, **do not** run the Generate Mapfile command on your GUMS server unless you really have to.  Doing so would make every user in the VO (including inactive ones) get an account mapped from the pool.

To be sure submit a simple generic 'whoami' job to your cluster:

``` 

globusrun-ws -submit -s -S -F ng2.your.site.domain -Ft PBS -c whoami

```

The response should be one of the pool user accounts.
