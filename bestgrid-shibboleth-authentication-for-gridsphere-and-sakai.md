# BeSTGRID Shibboleth Authentication for GridSphere and Sakai

# Introduction

This is a working plan for install Shibboleth authentication supported GridSphere and Sakai for BeSTGRID

# [Install Shibbolized GridSphere](http://support.csi.ac.nz:8080/browse/BG-136)

## Related Project

MAMS (Australia) has released a set of patches for Shibboleth authentication for GridSphere version 2.1.1 and version 3.0.5.

- Useful links
- [Shibbolized GridSphere installation guide|http

//mams.melcoe.mq.edu.au/wiki/display/MAMS/Virtual+Organization?showComments=false]
- [shibbolized-gridsphere-3.0.5 download link](http://www.federation.org.au/software/shibbolized-gridsphere-3.0.5.zip)

## Our Plan

- Goal

Install one or more Shibbolized GridSphere portlet containers for BioPortal Portlet and NDSG R Portlet.

;Background

In MAMS's work, the patches are developed for GridSphere version 2.1.1 and version 3.0.5. However, BioPortal Portlet and NDSG R Portlet are running on GridSphere 2.2.x. Therefore there are possible two options available for this problem

migrate BioPortal Portlet and NDSG R Portlet from GridSphere 2.2.x to 3.0.x or develop a shibbolized GridSphere patch for version 2.2.x.

- Required work analysis
- Upgrade Path for GridSphere 3.0.5
	
- Contact Vladimir for BioPortal component details from the GridPorlet packages
- Contact GridSphere mailing list to find out the possible complexities of GridPorlet upgrade

- Upgrade Path for Shibbolized GridSphere 2.1.1 to 2.2.7
	
- Investigate the user login structure for GridSphere 2.2.7
- Investigate the possible complexities for migrate Shibbolized GridSphere 2.1.1 patches to GridSphere 2.2.7

- Setup a virtual machine (VM) for shibbolized GridSphere test installation. bg51.bestgrid.org has been setup for this purpose
- Install Shibboleth Service Provider.
- Install Shibbolized GridSphere (ShibGS)
- Review the installation process with [Vladimir Mencl](vladimirbestgridorg.md) and [Nick Jones](nickdjonesbestgridorg.md)

;Estimated Time

- 3 to 4 days

# Install Shibbolized Sakai

## Related Project

Stockholm University (Sweden) has released a set of patches for Shibboleth Authentication for Sakai version 2.3 and version 2.4.

;Useful links

[Stockholm University Sakai Shibboleth Patch|http

//devel.it.su.se/pub/jsp/polopoly.jsp?d=2376&a=21472]

## Our Plan

- Goal

Migrate current [BeSTGRID Sakai|http

//sakai.bestgrid.org/portal] to a Shibbolized Sakai.

- Background

The current version of BeSTGRID production Sakai is 2.3. We have to upgrade it from 2.3 to 2.4

;Required work

- Setup a VM for the testing installation. vre.test.bestgrid.org has been setup for this purpose.
- Install Sakai 2.4 at http

//vre.test.bestgrid.org/portal/
- Import data from production site to the test site
- Upgrade the data from 2.3 to 2.4
- Create a script to perform the migration process
- Install JForum for Sakai 2.4
- Provided BeSTGRID customized Sakai skin to the new installed Sakai
- Install Shibboleth Service Provider
- Provided the Shibboleth authentication patch to the new installed Sakai
- Review the installation process with [Nick Jones](nickdjonesbestgridorg.md)
- Review the new functionalities with current BeSTGRID Sakai user and test it.

;Estimated Time

- Unknown
