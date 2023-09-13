# List of host certificates

To keep track of the host certificates for all the grid gateways I administer, I have decided to put them together in a single table to see the due dates for renewing the certificates.  This is the list of certificates for Canterbury (with Otago to follow).  I encourage other grid admins within BeSTGRID to create a similar table for their systems.

# Canterbury Grid Gateway: Current certificates

|  Action (+ reason)           |                                                              |              |                                                                           |
| ---------------------------- | ------------------------------------------------------------ | ------------ | ------------------------------------------------------------------------- |
|  gram5p7                     |  Secondary DTN for BlueFern                                  |  2015-10-20  |  Renew - production service (ASGCCA)                                      |
|  viz0                        |  iRODS slave server for BlueFern storage + DTN for BlueFern  |  2016-07-16  |  Renew - production service (ASGCCA)                                      |
|  irods-bestgrid.nesi.org.nz  |  Auckland DataFabric node (iRODS+Davis+Griffin+storage)      |  2016-07-17  |  Renew - production service (NOTE: this is an QuoVadis GRID certificate)  |
|  irods-dev1.nesi.org.nz      |  DataFabric TEST                                             |  2016-07-17  |  Renew - regular test system                                              |
|  df-data.uoo.nesi.org.nz     |  Otago DataFabric node (iRODS+Davis+Griffin+storage)         |  2016-07-17  |  Renew - production service (NOTE: this is an QuoVadis GRID certificate)  |
|  myproxyplus.nesi.org.nz     |  NeSI Globus OAuth server                                    |  2015-10-20  |  Renew - production service                                               |
|  myproxy.nesi.org.nz         |  NeSI MyProxy server                                         |  2016-06-04  |  Renew - production service                                               |
|  transfer.uoa.nesi.org.nz    |  NeSI UoA DTN (GridFTP)                                      |  2016-06-07  |  Renew - production service                                               |

Action items:

>  **Revisit this list by*October 2015** (renew expiring certificates)


# Other NZ grid Gateways

- This lists other sites the maintainer of this page (Vladimir Mencl) looks after.  Administrators of other sites are welcome to either list their sites here (preferred) or create a similar page elsewhere.

|  Action (+ reason)           |                                           |              |                              |
| ---------------------------- | ----------------------------------------- | ------------ | ---------------------------- |
|  ng2.aut.ac.nz               |  AUT NG2 gateway                          |  2011-09-07  |  Decommissioned              |
|  nggums.aut.ac.nz            |  AUT GUMS server                          |  2012-12-13  |  Renew - production service  |
|  nggums.massey.ac.nz         |  Massey GUMS server                       |  2012-01-25  |  Renew - production service  |
|  ng2bestgrid.massey.ac.nz    |  Massey NG2 gateway for BeSTGRID cluster  |  2012-05-09  |  Renew - production service  |
|  nggums.grid.otago.ac.nz     |  Otago GUMS server                        |  2012-05-09  |  Renew - production service  |
|  ng2maggie.grid.otago.ac.nz  |  Otago NG2 gateway for Maggie cluster     |  2012-05-09  |  Renew - production service  |

# BeSTGRID Shibboleth Federation

|  Comment                       |         |                   |              |
| ------------------------------ | ------- | ----------------- | ------------ |
|  idp.lincoln.ac.nz             |  https  |  Equifax          |  2013-05-13  |
|  wayf.bestgrid.org             |  https  |  AusCERT          |  2011-12-04  |
|  idp.bestgrid.org              |  front  |  AusCERT          |  2011-12-04  |
|  idp.bestgrid.org              |  back   |  self-signed      |  2029-12-01  |
|  www.bestgrid.org              |  front  |  AusCERT          |  2011-12-04  |
|  www.bestgrid.org              |  back   |  self-signed      |  2019-11-24  |
|  openidp.test.bestgrid.org     |  front  |  AusCERT          |  2011-12-04  |
|  openidp.test.bestgrid.org     |  back   |  self-signed      |  2029-12-01  |
|  wiki.test.bestgrid.org        |  front  |  AusCERT          |  2011-12-04  |
|  wiki.test.bestgrid.org        |  back   |  self-signed      |  2019-11-23  |
|  wayf.test.bestgrid.org        |  https  |  AusCERT          |  2011-12-04  |
|  gridsphere.test.bestgrid.org  |  front  |  BeSTGRID CA      |  2010-11-21  |
|  gridsphere.test.bestgrid.org  |  back   |  MAMS Level 1 CA  |  2009-12-15  |
|  idp.canterbury.ac.nz          |  front  |  Digicert         |  2012-05-30  |
|  idp20test.canterbury.ac.nz    |  front  |  MAMS Level 1 CA  |  2019-06-02  |
|  wiki.canterbury.ac.nz         |  front  |  Thawte           |  2010-12-18  |
|  wiki.canterbury.ac.nz         |  back   |  self-signed      |  2030-04-06  |
|  wikitest.canterbury.ac.nz     |  front  |  ipsCA            |  2011-05-25  |
|  wikitest.canterbury.ac.nz     |  back   |  self-signed      |  2030-04-06  |

## Decommissioned systems

|  Comment                          |                                                  |                   |                                                                    |                                                                                                  |
| --------------------------------- | ------------------------------------------------ | ----------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
|  idp-test.canterbury.ac.nz        |  front+back                                      |  MAMS Level 1 CA  |  2009-08-21                                                        |                                                                                                  |
|  confluencewiki.canterbury.ac.nz  |  front+back                                      |  MAMS-Level-1     |  2009-11-25                                                        |                                                                                                  |
|  avcc.karen.net.nz                |  front                                           |  ipsCA            |  2010-05-27                                                        |                                                                                                  |
|  avcc.karen.net.nz                |  back                                            |  CAUDIT           |  2010-01-13                                                        |                                                                                                  |
|  hpcgrid1                         |  IBM p520 - GridFTP server for HPC               |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: production service - DataFabric slave + GridFTP for old HPC  |
|  grid                             |  User client tools                               |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: running MDS for NZ - unused now                              |
|  ng2dev                           |  ng2 development                                 |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: Renew (down now)                                             |
|  ng2hpcdev                        |  ng2hpc development                              |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: Renew (unused now)                                           |
|  ng2sge                           |  SGE cluster Ng2 gateway                         |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: Renew - production service                                   |
|  ng2hpc                           |  HPC cluster Ng2 gateway                         |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: Renew - production service (rather unused now)               |
|  ngportal                         |  GridSphere portal                               |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: Renew - production service                                   |
|  ngportaldev                      |  GridSphere development portal                   |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: Renew - may be useful                                        |
|  ng1                              |  Ng1 gateway (GRAM5 experimental) for NGCompute  |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: Renew - regular testing system                               |
|  ng2                              |  Ng2 gateway (GT4) for NGCompute                 |  ASGCCA           |  2014-11-19                                                        |  EOL, decommissioned service.  Was: Renew - production service                                   |
|  gridgwtest                       |  Testing grid sw                                 |  2015-10-20       |  Renew - regular test system                                       |                                                                                                  |
|  irodsdev                         |  Testing grid sw                                 |  2016-02-26       |  Renew - irods-HA dev system (slave, 3.2)                          |                                                                                                  |
|  irodsdev2                        |  Testing grid sw                                 |  2016-02-26       |  Renew - irods-HA dev system (iCAT, 3.3)                           |                                                                                                  |
|  irodsdev3                        |  Testing grid sw                                 |  2016-02-26       |  Renew - irods test system linked with gridgwtest in BeSTGRID-DEV  |                                                                                                  |
|  ngdata                           |  iRODS - BeSTGRID DataFabric df.bestgrid.org     |  2015-10-20       |  Renew                                                             |                                                                                                  |
|  nggums                           |  GUMS authentication server                      |  2015-10-20       |  Renew - production service                                        |                                                                                                  |
|  df.bestgrid.org                  |  AusCERT frontend certificate (ngdata)           |  2017-01-14       |  Renew when needed                                                 |                                                                                                  |
|  ngportal                         |  GoDaddy frontend certificate                    |  2015-12-16       |  Renew when needed                                                 |                                                                                                  |
|  nggums                           |  GoDaddy frontend certificate                    |  2015-12-16       |  Renew when needed                                                 |                                                                                                  |
|  gram5bgp                         |  GRAM5 gateway for BlueGene/P                    |  2015-10-20       |  Renew - production service                                        |                                                                                                  |
|  gram5p7dev                       |  GRAM5 gateway for P7 cluster DEV                |  2015-10-20       |  Renew - regular test system                                       |                                                                                                  |
|  gram5bgpdev                      |  GRAM5 gateway for BlueGene/P DEV                |  2015-10-22       |  Renew - regular test system                                       |                                                                                                  |
|  ng2dev                           |  DTN dev node                                    |  2016-02-26       |  TBD                                                               |                                                                                                  |
|  ng2hpcdev                        |  DTN dev node                                    |  2016-02-26       |  TBD                                                               |                                                                                                  |

- Schedule:
- ***September 2009**: Renew front-end ipsCA certificate for www.bestgrid.org


>  ***Note 3**: Now that idp.bestgrid.org uses an ipsCA front-end certificate on the back-channel - we might remove APACGrid CA from the BeSTGRID Federation metadata.
>  ***Note 3**: Now that idp.bestgrid.org uses an ipsCA front-end certificate on the back-channel - we might remove APACGrid CA from the BeSTGRID Federation metadata.
