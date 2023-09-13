# Shibboleth Prototyping

# Good Resources

- Shibboleth Website [http://shibboleth.internet2.edu/](http://shibboleth.internet2.edu/)
- Official Shibboleth Wiki [https://authdev.it.ohio-state.edu/twiki/bin/view/Shibboleth/WebHome](https://authdev.it.ohio-state.edu/twiki/bin/view/Shibboleth/WebHome)

# How does Shibboleth Work

Shibboleth is an implementation of the OASIS SAML[specification.

# Federations

Federations are essentially the governence structures above a group of IdPs who have aggreed to a set of policies determining the following:

- Reasons for the federation
- Entry requirements
- Rules and requirement for continued membership

At the technical level we have agreed

- Schema (for attribute sharing etc)
- Certificate CA's

## Questions

- How do we technically set up a federation
	
- Is it based on the CA who signed the certs for the assertions?
- Can an IdP be a party in more than one federation?

# The IdP

If you want to install as part of the *demo* InQueue federation, then this will guide you well[https://authdev.it.ohio-state.edu/twiki/bin/view/Shibboleth/InQueueIdPInstall](http://www.oasis-open.org/committees/tc_home.php?wg_abbrev=security)]

## Attributes and their Resolution

### Attributes

Attributes are included in attribute assertions. Some examples of attributes might be

- cn
- dn
- eduPersonEntitlement
- etc

Attribute and Authentication assertions are used by SP to allow access to local resources. It is important to note that as such, a federation **must** aggree on an ontology, that is attributes, and what they mean in a concrete fashion.

For example, consider you are a member of the group UniStaff@auckland.ac.nz. What does this mean an SP who is not in the UoA, can they assume it mean you are employed by the University of Auckland in some way? *But* does it mean you are part of a faculty or that you are *not* a student? It is thses types of questions a federation ontology/schema is meant to make clear to all members of the federation. Upon this strong grounding, clear and predicable access control decisions can be made

eduPerson/eduOrg[is an initiative by Internet2/eduCause for a schema relating to teriary academic institutions. It is upon this that any federation (at least within a tertiary institution) should base it's ontology/schema

#### Opaque ID for session support

Given the design principles around SAML and Shibboleth for anonymity, it is important to give an SP a way of storing state about a visitor but without knowning a unique identifier for that person in their home organisation (which would be a breach of the Privacy Act). SAML has a mechanism around this; a persistent ID. Shibboleth implements this as a pseudonymous hashing of the principal name, requester and a fixed secret salt. In Shibboleth, the persistent id is called a targeted-id.

This has a number of benefits:

1. The persistent id is valid only for a principal and requester pair.
2. Only the IdP knows the real unique identifier of the user

Of note is that the eduPersonTargetedID appears to have been superseeded by the SAML2 PersistentID.

Resources on this are:

1. A wiki on targeted-id and shib IdP 1.3 and it's implementation[http://staff.washington.edu/fox/notes/tgtid.shtml](http://www.educause.edu/eduperson/)]
2. Discussion on the shibboleth-dev mailing list as to the implementation of a targeted-id[https://mail.internet2.edu/wws/arc/shibboleth-dev/2005-01/msg00078.html](https://mail.internet2.edu/wws/arc/shibboleth-dev/2005-01/msg00078.html)

### Resolution

Attributes about a person/entity are obtained via attribute resolution. LDAP is the best place for this.

In the idp.xml, the resolverConfig is the place to specify the reolver configuration.

The resolver configuration details to the IdP how it is to get attributes about a person.

## Attribute Release Policies (ARP)

Attribute release policies allow an IdP site to specify what attributes about it's principles are released SP and they are contained in {shidIdp}/etc/arps

There are two types of ARP

- Site Wide arp (arp.site.xml)
- User specific ARP (arp.{user}.xml)

### Questions

- Given arps are meant to be for users to maintain their own privicy, how do users know the entityid or site to hide details from specific sites?
	
- It could be taken from the federation metadata - but there is not any user-understandable information in there!
- The MAMS ShARPE and Autograph are designed for this.
- How do the site and user specific arps work together?

# SP

If you want to install as part of the *demo* InQueue federation, then this will guide you well[https://authdev.it.ohio-state.edu/twiki/bin/view/Shibboleth/InQueueSPInstall](https://authdev.it.ohio-state.edu/twiki/bin/view/Shibboleth/InQueueSPInstall)

# General FAQ

1. How is n-tier authentication handled, e.g. Webmail and IMAP?
