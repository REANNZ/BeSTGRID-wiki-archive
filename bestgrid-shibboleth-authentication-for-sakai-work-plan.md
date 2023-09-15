# BeSTGRID Shibboleth Authentication for Sakai Work Plan

# Introduction

This is a working plan for install Shibboleth authentication supported Sakai for BeSTGRID

# [Install Shibbolized Sakai](http://support.csi.ac.nz:8080/browse/BG-96)

## Related Project

Stockholm University (Sweden) has released a set of patches for Shibboleth Authentication for Sakai version 2.3 and version 2.4.

- Useful links

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
