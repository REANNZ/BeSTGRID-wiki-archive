# Deploying SRB for BeSTGRID

The [Storage Resource Broker (SRB)](http://www.sdsc.edu/srb/index.php/Main_Page), can provide access to the BeSTGRID storage resources, allowing the users to tag their data with metadata.

This page analyzes the several ways SRB can be deployed within BeSTGRID.

The key question in the SRB deployment is deciding how many SRB zones we will have in New Zealand - whether just a single BeSTGRID zone, or multiple zones, one per institution.

# What is a zone

In SRB, a *zone* is an administrative domain.  All user accounts are created within a zone, all permissions are granted within a zone - but also work across zones, for users accessing data in remote zones.  An administrator account has administrative privileges over the whole zone.

It is possible to *federate* among zones, and users can access data (and possibly resources) in other zones.

There can be multiple SRB servers within a zone.

Each such server is an entry point for the users to access all resources within the zone (and can also act as a gateway for accessing other zones in the federation).

One of the servers would be also maintaining the *metadata catalogue* (MCAT) - and by virtue of that would be the master server - other servers could still run a slave MCAT to have fast access to the metadata as well.

Note that on the technical side, there can be also data-only servers, providing access to the storage resources to the *"main"* SRB servers (we would like be running one on the IBM p520 running AIX/p520, while the main SRB server would run on a Linux/x86 system).

# What is a domain

Domain is the namespace for user accounts: like vme28@srb.canterbury.ac.nz.  There could be multiple domains in a zone, and a domain could be used across multiple zone.

Currently, ARCS Data Fabric uses a convention to use a single domain solely within a single zone, and these have the same name - the DNS name of the main SRB server.

# Controlling access to resources

Access to resources can be granted to a individual users or a group of users known in the SRB zone.  The users may be coming from a remote zone.

# Considering a single BeSTGRID zone

Pros:

- simpler administration: a single administrative domain
- simpler layout for the users: just one global directory tree.
- simpler access: users can use any SRB server in the zone as the entry point into the SRB zone.

Cons: 

- a single administrative domain: some institutions might not be comfortable with other site's administrators having control over their resources

# Considering per-institution zones

Pros:

- tighter control: institutions are fully in control of their resources

Cons:

- complex directory view for the users: one subtree with home directories and project directories for each institution.
- complex identity: user account would be tied with their home zone (though recognized in federated zones)
- constrained access: users have to use their institution's SRB server to access SRB resources.

# Situation in ARCS Data Fabric

The restrictive factor in ARCS Data Fabric was that institutions were not willing to give up the control over their storage resources.

Consequently, each institution established their own SRB zone.  The zones have been federated together, as each zone has links to other zones at the same location, they provide a single virtual federated data storage service to the user community, laid out as:

``` 

\
 +- srb.dc.apac.edu.au -+- home
 |                      +- projects
 +- srb.tpac.org.au +----- home
 |                  +----- projects
 +- srb.vpac.org ....
 +.....

```

I was getting a strong recommendation from the ARCS Data Services team to have just a single zone if at all possible.  According to their advice, it leaves more flexibility open in configuring the SRB systems, makes it simpler for users to navigate through, makes it easier to administer.

# Considerations for BeSTGRID

Within BeSTGRID, we have the right situation for establishing a single BeSTGRID wide SRB zone, encompassing the resources that were purchased within the original BeSTGRID process.

We might create a single zone called **srb.bestgrid.org.nz**, with entry points being initially srb.canterbury.ac.nz and srb.auckland.nz.  (We may as well create srb.bestgrid.org.nz as an alias to srb.canterbury.ac.nz).

Within the zone, we might create a single logical storage resource **bestgrid**, consisting of physical storage resources both at Canterbury and in Auckland.  This resource would be available to all BeSTGRID members.

Each institution might as well create their own institutional resources, available just to their institutional members.  There might be an SRB group for each institution, and user accounts might get automatically added to the respective group based on the Organization field in their certificate.  Also, we might use separate domains for each institution to clearly distinguish their user accounts.

Individual research groups might use SRB to access their own dedicated storage, and the project leader would be manually assigning privileges to access the resource.

The **srb.bestgrid.org.nz** zone would federate with the other zones in the ARCS Data Fabric.  This would allow easy access between the zones, for BeSTGRID users to access data in the ARCS Data Fabric, and ARCS users to access data in the BeSTGRID SRB zone.

Both ARCS and BeSTGRID users would see the same directory structure.  All BeSTGRID contents would be under /srb.bestgrid.org.nz, and other directories for other SRB zones would point to their respective directory structure.

# Deployment plan

>  **Deploy an SRB server at Canterbury, with server-name*srb.cantebury.ac.nz**, and zone and domain name **srb.bestgrid.org.nz**.


# References

- SRB documentation main page: [http://www.sdsc.edu/srb/index.php/Main_Page](http://www.sdsc.edu/srb/index.php/Main_Page)
- SRB documentation on Zones: [http://www.sdsc.edu/srb/index.php/Zones](http://www.sdsc.edu/srb/index.php/Zones)
- SRB documentation on Federated Metadata catalogue (Fed MCAT): [http://www.sdsc.edu/srb/index.php/Fed_MCAT](http://www.sdsc.edu/srb/index.php/Fed_MCAT)
- ARCS DataServices SRB Installation guide: [http://projects.arcs.org.au/trac/systems/wiki/DataServices/SRBQuickStart](http://projects.arcs.org.au/trac/systems/wiki/DataServices/SRBQuickStart)
