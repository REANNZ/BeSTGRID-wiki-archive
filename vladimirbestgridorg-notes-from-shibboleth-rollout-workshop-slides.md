# Vladimir@bestgrid.org Notes from Shibboleth Rollout workshop slides

I have reading through the [Shibboleth Rollout workshop Day 1 slides](http://federation.org.au/workshop/AAF%20Shibboleth%20Rollout%20Workshop%202008.1.pdf), available at [http://www.federation.org.au/rollout](http://www.federation.org.au/rollout) and the [Operational requirements final draft](http://federation.org.au/requirementsfinaldraft.pdf).

Below is what I found interesting.

# End-user management of release of Personal Information

- Privacy law fulfillment
- Admin manages common policies on attribute-release
- User controls user-specific attribute-release
- Satisfy Kim Cameron’s 1st Laws of Identity: User control and consent

.... hmmm - this is rather in contrast with what I found in the operational requirements

- AAF Req 13: User consent
	
- AAF Shibboleth Federation IdPs must ensure that end-users provide informed consent to the release of their personal information to SPs.

Can we do an automated release ..... (SP-ARP-policy) ?

... not really.  Sect 2.2.1 says personal information (incl. name) should be released after informed consent.  Autograph can be replaced by e.g. paper-based process (esp. for grid services), but there should be informed consent.

# Multiple Trust levels

AAF is the first major federation to provide more than one trust level across the federation

>  – “Floor of Trust”: sufficient for most context with username/password
>  – “Level 3”: higher level of assurance services (e.g. access to grid computing using PKI soft/hard token)

# Operational Requirements

[http://federation.org.au/requirementsfinaldraft.pdf](http://federation.org.au/requirementsfinaldraft.pdf)

3 components:

- Requirements (mandatory)
- Recommendations (encouraged but not required)
- Explanatory comments & advice

- AAF Shibboleth Federation Members must use the EntityID assigned to them by the AAF Shibboleth Federation Operator.
	
- ... no more pick your own in the fed metadata editor?

- Each AAF Shibboleth Federation Member must use their customised Federation Metadata issued to them by the AAF Shibboleth Federation Operator.

- Trusted server certificate - AAF Req02
	
- AAF Shibboleth Federation members must use an AAF approved certificate for secure server-to-server (i.e. back-channel) SAML transactions.

# Commercial SPs

Interesting:

- AAF Req 30: Attribute Request Vetting
	
- Any commercial SP Service Descriptions that request personal information attributes (eg, mail, name, AEPST) will be reviewed against AAF policies on SP use of end-user personal information, and Service Descriptions that do not meet AAF policies will not be provided to IdPs.

# IdP obligations on logging

IdP to maintain authentication and transaction logs

- Allow tracing user-handle to the user (when pseudonymous access was performed)
- When unexpected failure to access service or in case of misuse

# Interesting services provided in the Federation

- Federation White Pages Service
	
- Protected service only available for Federation members
- Is a federation-wide designation of user
- Is based on “People Picker”
- SP can use it to “pick” user for access control

- Federation Entitlement Service (FES)
	
- Manage entitlements at Federation level (e.g. third-party entitlements, SP cluster entitlements)
- Provide multiple approaches to access, different approaches for IdP and SP

- IAMSuite (web-based workspaces for virtual organisations)
	
- (workspace + software for VO management)

# New Federation Manager

Management of SP details

- Including details of Service Offerings and attributes needed for these
- Allows for limiting access of SPs to designated IdPs
- Provision of custom federation metadata
