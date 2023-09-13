# BeSTGRID Shibboleth Authentication for GridSphere Work Plan

# Introduction

This is a working plan for install Shibboleth authentication supported GridSphere

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

;Required work analysis

- Upgrade Path for GridSphere 3.0.5
	
- Contact Vladimir for BioPortal component details from the GridPorlet packages
		
- Install the job submission portlet into GridSphere 3.0.5.  See if it works, adjust the code if needed.
- Contact GridSphere mailing list to find out the possible complexities of GridPorlet upgrade

- Upgrade Path for Shibbolized GridSphere 2.1.1 to 2.2.7
	
- Investigate the user login structure for GridSphere 2.2.7
- Investigate the possible complexities for migrate Shibbolized GridSphere 2.1.1 patches to GridSphere 2.2.7

- Setup a virtual machine (VM) for shibbolized GridSphere test installation. bg51.bestgrid.org has been setup for this purpose
- Install Shibboleth Service Provider.
- Install Shibbolized GridSphere (ShibGS)
- Review the installation process with [Vladimir Mencl](https://reannz.atlassian.net/wiki/404?key%3Dbestgrid.org%3Bsearch%3Fq%3DUser__Vladimir) and [Nick Jones](https://reannz.atlassian.net/wiki/404?key%3Dbestgrid.org%3Bsearch%3Fq%3DUser__Nickdjones)

;Estimated Time

- Unknown
