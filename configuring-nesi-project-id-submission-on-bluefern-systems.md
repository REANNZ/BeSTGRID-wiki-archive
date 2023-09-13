# Configuring NeSI project ID submission on BlueFern systems

The method for passing NeSI project ID in jobs submitted via the grid aims to:

- Place minimum overhead on users - simply choose the project from the projects the user is on.
- Place minimum overhead on administrators - as little per-project administration as possible.

The design is:

- In GOLD, users are assigned to projects - and each project is assigned to sites.
- There is a VO group for each project and users on the project are assigned to the group (so far manually but can be automatically pulled from GOLD)
- The VO group is advertised in the infosystem as supported by each of the sites on the project (again, so far manually but could be automatically pulled from GOLD)
- Each GUMS server is only configured to support a single "hidden" VO - there is one per site, users whose project gets assigned to a site get assigned to this group (again, can be pulled from GOLD)

When submitting the job, users choose their project by selecting their project VO group (only sites supporting their projects are listed as submission options).

LoadLeveler.pm then translates the last component of the selected VO group (GRISU_FQAN job environment variable) into the LoadLeveler ll_account keyword value.

# GUMS configuration

To implement the above design:

- Define a GUMS User Group: NeSI-projects-hidden-site-group: (the VO group name is site specific - "uoc" here)


>   Name: NeSI-projects-group
>   Description: NeSI hidden-site-group to control who has access to the site (anyone in this group)
>   Type: VOMS
>   VOMS Server: BeSTGRID-nz
>   Remainder URL:  /nz/services/VOMSAdmin 
>   Accept non-VOMS: true
>   Match VOMS as: *ignore* (this is crucial!)
>   VO group: /nz/nesi/projects/uoc
>   Role: (blank)
>   GUMS access: read-self
>   Name: NeSI-projects-group
>   Description: NeSI hidden-site-group to control who has access to the site (anyone in this group)
>   Type: VOMS
>   VOMS Server: BeSTGRID-nz
>   Remainder URL:  /nz/services/VOMSAdmin 
>   Accept non-VOMS: true
>   Match VOMS as: *ignore* (this is crucial!)
>   VO group: /nz/nesi/projects/uoc
>   Role: (blank)
>   GUMS access: read-self

- Define a Group-To-Account-Mapping with this group and the site's account mappers.  For BlueFern:


>   Name: NeSI-projects-to-LocalAccountNeSIPool
>   Description: NeSI-projects to LocalAccount or NeSIPool
>   User Group: NESI-projects-group
>   Account Mapper: manualGroupNESI, NeSIPoolAccountMapper
>   Name: NeSI-projects-to-LocalAccountNeSIPool
>   Description: NeSI-projects to LocalAccount or NeSIPool
>   User Group: NESI-projects-group
>   Account Mapper: manualGroupNESI, NeSIPoolAccountMapper

- Use this Group-To-Account-Mapping with a Host-To-Group mapping: for BlueFern, with the gram5p7 and gram5bgp mappings.

# Loadleveler.pm changes

- Extract the group name from the GRISU_FQAN job environment variable.
- Store the group name in the `$ll_account_no` variable to be passed as `# @ account_no` to LoadLeveler

- Insert this code right after the line defining `$ll_account_no` (and initializing it from the RSL project value): `my $ll_account_no = $description->project();`

``` 

# NeSI-specific:
   my $account_prefix = "/nz/nesi/projects/";
   my $account_var_name = "GRISU_FQAN";
   if (!not_null($ll_account_no) && not_null($job_environment{$account_var_name})
      && $job_environment{$account_var_name} =~ /^$account_prefix(.*)/  && not_null($1) ) {
           $ll_account_no = $1;
   };

```
