# BeSTGRID Shibboleth Project Initial Plan

# Introduction

This is the initial draft working plan for the BeSTGRID Shibboleth project. The main purpose of this working plan is to list all possible tasks with estimated times and possible time frames.

However modifications on this working plan is expected as the project will be carried out through the rest of the year.

# Identity Provider

## [Joining Australian Access Federation](http://support.csi.ac.nz:8080/browse/BG-107)

## [Install Pilot Open Identity Provider (OpenIdP)](http://support.e-learnings.co.nz:8080/browse/BG-81) 

Open Identity Provider is a Shibboleth Identity Provider (IdP) which allows user free to register and uses as an Identity Provider for some Shibbolised services (e.g. BeSTGRID MediaWiki). The following tasks are required during the installation process of OpenIdP:

- Task 1 [OpenIdP Look and feel|http

//support.e-learnings.co.nz:8080/browse/BG-83]
- Description: This is about the collaboration between Eric and Lee-yan (Graphic Designer) to work on the "Look and Feel" task for OpenIdP Registry. Lee-yan should design the layout, CSS files and images for the web page while Eric should migrate the current registry functions into the new design web pages.
- Status: Completed testing stage
- Estimated times: Eric -> 2 weeks; Lee-yan -> 5 weeks
- Suggested URL: [https://openidp.test.bestgrid.org/registry](https://openidp.test.bestgrid.org/registry) for testing and development environment

[https://openidp.bestgrid.org/registry](https://openidp.bestgrid.org/registry) for pilot environment.

- Dependencies: Setup a communication channel between Eric and Lee-yan for the collaboration (e.g. email and JIRA). Documentation is necessary for future development, for example adding a new function or changing the design style.

- Task 2 [Install LDAP server for OpenIdP|http

//support.e-learnings.co.nz:8080/browse/BG-84]
- Description: Install OpenLDAP server to stores the user information (username, password, email, surname, given name and affiliation) for OpenIdP.
- Status: Completed testing stage
- Estimated times: 1 to 2 days
- Dependencies: BeSTGRID Gateway server administration users setup, and management of permissions for various users and users group. It requires documentation on administration of OpenIdP.
- Install Location: BeSTGRID Gateway server

- Task 3 [Transfer existing users information|http

//support.e-learnings.co.nz:8080/browse/BG-87]
- Description:
	
- Transfer existing users information from current BeSTGRID Wiki MySQL database to the new OpenIdP LDAP server.
- Reset user passwords and then notify users to change their default passwords.
- Notify users that old account will no longer be accessible.
- Status: Completed testing stage
- Estimated times: 1 to 2 days
- Dependencies: Completion of Task 2. Setup a management procedure for monitoring, testing and documenting the user information migration process. In addition, it should setup a communication channel to notify users of the change (e.g. email notification).

- Task 4 [Install Identity Provider for OpenIdP|http

//support.e-learnings.co.nz:8080/browse/BG-88]
- Description: Install Identity Provider for OpenIdP
- Status: Completed testing stage
- Estimated times: 1 to 2 days
- Dependencies: Completion of Task 3. Documentation on the installation process for future administration and installation, this includes the attribute release management.
- Install Location: BeSTGRID Gateway server
- Suggested URL: [https://openidp.test.bestgrid.org](https://openidp.test.bestgrid.org) for testing and development environment


>                                          [https://openidp.bestgrid.org](https://openidp.bestgrid.org) for pilot environment.
>                                          [https://openidp.bestgrid.org](https://openidp.bestgrid.org) for pilot environment.

- Suggested providerId: urn:mace:bestgrid:openidp.test.bestgrid.org
- Suggested Attribute Release Policy: Release information of user affiliation and email to all sites, but will only release user surname, given name and email address to the restricted sites.

- Task 5 [Documentation|http

//support.e-learnings.co.nz:8080/browse/BG-89]
- Description: Document above tasks for future references and administration.
- Status: Completed
- Estimated times: 2 days

- Task 6 Document Pilot deployment environments and processes
- Services

WAYF, OpenIDP, WIKI, VRE
- Physical Environment: Location, Redundancy, Configuration, ....

- Task 7 Deploy WAYF to Pilot
- Redundancy / High Availability + Load Balancing
	
- Foundry Switch dependency onto Service

;Task 8 Deploy OpenIDP to Pilot

- Redundancy / High Availability + Load Balancing
	
- Foundry Switch dependency onto Service

;Task 9 Deploy WIKI to Pilot

;Task 10 Deploy VRE (Sakai) to Pilot

- Redundancy / High Availability + Load Balancing
	
- Foundry Switch dependency onto Service
- Database Cluster

;Task 11 Communications Plan

- User account migration
	
- AAF presecribes application user name is eduPersonPrincipalName
- Implications for existing Wiki users is will create a new account, access to old account will be lost
- Need to put in place communications plan to notify of change
- Service Outages
	
- Define service window
- Compose outage notice
- Compile list of people to communicate outage to
- Release outage notice

;Task 12 User Acceptance Testing

- Test end-to-end processes with User Group

## [Install University of Auckland IdP|http

//support.e-learnings.co.nz:8080/browse/BG-90]

- Description: Install production Identity Provider for the University of Auckland. This IdP is considered as a level 1 IdP. In addition, this IdP will be protected by Unisign Single Sign On (SSO) and will release users information from the university production LDAP server.
- Status: Completed
- Estimated times: 1 day
- Suggested URL: [https://idp-test.auckland.ac.nz](https://idp-test.auckland.ac.nz) for pilot environment

[https://idp.auckland.ac.nz](https://idp.auckland.ac.nz) for production environment

- Suggested providerId: urn:mace:bestgrid:idp-test.auckland.ac.nz & urn:mace:bestgrid:idp.auckland.ac.nz
- Suggested Attribute Release Policy: Release information of user affiliation and email to all sites, but will only release user surname, given name and email address to restricted sites.

## [Install University of Canterbury IdP](http://support.csi.ac.nz:8080/browse/BG-91)

Similar to [UoA IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID_Shibboleth_Project_Initial_Plan&linkCreation=true&fromPageId=3818228432)

## [Install Massey University IdP](http://support.csi.ac.nz:8080/browse/BG-92)

Similar to [UoA IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID_Shibboleth_Project_Initial_Plan&linkCreation=true&fromPageId=3818228432)

## Install NIWA IdP

Similar to [UoA IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID_Shibboleth_Project_Initial_Plan&linkCreation=true&fromPageId=3818228432)

# [Install Where Are You From (WAYF)](http://support.e-learnings.co.nz:8080/browse/BG-93)

- Estimated times: 1 to 2 days
- Suggested URL: [https://wayf.test.bestgrid.org](https://wayf.test.bestgrid.org) for testing and development environment
[https://wayf.bestgrid.org](https://wayf.bestgrid.org) for pilot environment.
- Status: Completed testing stage
- Dependencies: Agreement on user interface namings. E.g. Federation: BeSTGRID. Institution: University of Auckland Identity Provider.

# [Service Provider](http://support.e-learnings.co.nz:8080/browse/BG-94)

## [Shibbolizing BeSTGRID MediaWiki](http://support.e-learnings.co.nz:8080/browse/BG-95)

- Target Version
- MediaWiki 1.9.x

; Required Work

- Make user account map to eduPersonPrincipalName
- Backup existing BeSTGRID MediaWiki
- Upgrade existing MediaWiki to latest Mediawiki (1.9.3 at the moment of writing)
- Install OpenIdP (described [above](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID_Shibboleth_Project_Initial_Plan&linkCreation=true&fromPageId=3818228432))
- Install Service Provider

Suggested providerId: urn:mace:bestgrid:mediawiki

- Estimated Time

1 week

- Dependencies
- Administration users setup
- Testing after the shibbolizing process.

- Status

Completed testing stage

## [Shibbolizing BeSTGRID Sakai](http://support.e-learnings.co.nz:8080/browse/BG-96)

- Status: In the progress

; Target Version
- Sakai 2.4

The required works for shibbolizing BeSTGRID Sakai should be carry out in the following orders:

- Task 1 Investigate similar Sakai + Shibboleth integration projects
- Estimated time

2 weeks

- Task 2 Research Sakai
- Investigate Sakai structure
- Reading Sakai development documentations
- Find out how to do CRUD (create, read, update and delete) in Sakai environment
- Research on how to write Java web service for Sakai (if required)
- Estimated time

2 months

- Task 3 Migrate Sakai 2.3 to 2.4
- Estimate time

2 weeks
- Dependencies: Administration users setup, a management procedure of monitoring, testing and documenting the data migration process.

- Task 4 Developing Sakai + Shibboleth plugin
- Estimated time

1 month

- Task 5 FitNesse testing
- Estimated time

2 weeks

- Task 6 Documentation
- Estimated time

1 week

## [Sakai Skin](http://support.e-learnings.co.nz:8080/browse/BG-97)

- Task 1 Research
- Estimated time

1 week

- Task 2 Collaboration between Eric and Lee-yan
- Estimated time

2~3 weeks

# GridSphere R Portal

- Task 1 Research on Gridsphere and SRB connection
- Estimated time

1 week

- Task 2 Implementation
- Estimated time

1 week

# Ongoing support and Maintenance

; Attribute Release Policy maintenance

- How to create, update and delete Attribute Release Policies for various Service Providers
- What user attributes can be released to various Service Providers?

; Meta-data maintenance

- Which institution can join the federation
- How can we add, update and remove an institution from the meta-data
- How can we maintain the consistency between all Service Providers and Identity Providers within a federation
