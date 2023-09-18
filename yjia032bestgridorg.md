# Yjia032@bestgrid.org

# Work Plan

- Auckland Work Programme
[http://www.bestgrid.org/index.php/Auckland_Work_Programme](http://www.bestgrid.org/index.php/Auckland_Work_Programme)
- GridSphere work Plan
[http://www.bestgrid.org/index.php/GridSphere_R_Portal_Initial_Work_Plan](http://www.bestgrid.org/index.php/GridSphere_R_Portal_Initial_Work_Plan)
- Shibboleth Work Plan
[http://www.bestgrid.org/index.php/BeSTGRID_Shibboleth_Project_Initial_Plan](http://www.bestgrid.org/index.php/BeSTGRID_Shibboleth_Project_Initial_Plan)
- BeSTGRID Productionization Plan
[http://www.bestgrid.org/index.php/BeSTGRID_Shibboleth_services_productionization_plan](http://www.bestgrid.org/index.php/BeSTGRID_Shibboleth_services_productionization_plan)
- Shibbolized GridSphere Work Plan
[http://www.bestgrid.org/index.php/BeSTGRID_Shibboleth_Authentication_for_GridSphere_Work_Plan](http://www.bestgrid.org/index.php/BeSTGRID_Shibboleth_Authentication_for_GridSphere_Work_Plan)
- Shibbolized Sakai Work Plan
[http://www.bestgrid.org/index.php/BeSTGRID_Shibboleth_Authentication_for_Sakai_Work_Plan](http://www.bestgrid.org/index.php/BeSTGRID_Shibboleth_Authentication_for_Sakai_Work_Plan)

# Shibboleth 1.3 IdP

- All Shibboleth IdP configuration files are stored in /usr/local/shibboleth-idp/

**Please run Tomcat as user *shib**

## The University of Auckland Shibboleth IdP

- Test UoA IdP
- Location

osiris1.auckland.ac.nz and osiris2.auckland.ac.nz
- HAShib installed
- Retrieving user information from test EC LDAP
- Member of BeSTGRID test federation

- Production UoA IdP
- Location

cerberus1.auckland.ac.nz and cerberus2.auckland.ac.nz 
- HAShib installed
- Retrieving user information from test EC LDAP
- Member of BeSTGRID production federation
- Member of AAF Level 2 federation

## BeSTGRID Shibboleth Open IdP

- OpenIdP registry is a PHP web application, and its source codes are stored in

``` 
https://svn.csi.ac.nz/svn/bestgrid/themes/collab grid/BeSTGRID/openidp/trunk/registry
```

- BeSTGRID Test Open IdP
- Location

openidp.test.bestgrid.org
- Shib 1.3 IdP installed
- User information are stored in a local LDAP directory
- Root password could be review in Shib configuration resolver.ldap.xml
- Member of AAF Level 1 federation
- User can register in [https://openidp.test.bestgrid.org/registry/register.php](https://openidp.test.bestgrid.org/registry/register.php)

- BeSTGRID Production Open IdP
- Location

idp.bestgrid.org
- Shib 1.3 IdP installed
- User information are stored in a local LDAP directory
- User information will be export into a LDIF format file and then backup into data.bestgrid.org:/data/grid/backup/idp/LDIF
- Member of BeSTGRID Production federation
- User can register in [https://idp.bestgrid.org/registry/register.php](https://idp.bestgrid.org/registry/register.php)
- Please contact Andrey Kharuk for SSL certificate password

# Shibbolized BeSTGRID Wiki

BeSTGRID Customized wiki skin, Shibboleth plugin and modified **accesscontrol** plugin are stored in 

``` 

https://svn.csi.ac.nz/svn/bestgrid/themes/collab grid/BeSTGRID/mediawiki/trunk/wiki

```

- BeSTGRID Test BeSTGRID Wiki
- Location

wiki.test.bestgrid.org
- Shib 1.3 SP installed
- Any modification on this wiki content will be erased due to a nightly PRODUCTION->TEST data synchronization
- Member of BeSTGRID Test federation
- Member of AAF Level 1 member
- Implemented Shibboleth plugin

**Implemented *accesscontrol** plugin, this plugin has been modified to do Shibboleth role/group auto upgrade. Please have a look  [BeSTGRID Shibbolized Wiki Group Control](bestgrid-shibbolized-wiki-group-control.md) guide for more details

**Implemented *Google Calendar** extension. Please have a look [Google Calendar Extension](google-calendar-extension.md) for more details

- BeSTGRID Production BeSTGRID Wiki
- Location

www.bestgrid.org
- Shib 1.3 SP installed
- Member of BeSTGRID Federation
- Member of AAF Level 2 member
- Implemented Shibboleth plugin

**Implemented original *accesscontrol** plugin. NOTE: The Shibboleth group control supported accesscontrol plugin are only implemented in BeSTGRID test machine.

**Implemented *Google Calendar** extension. 
- A nightly MySQL dump will be export to data.bestgrid.org for backup
- A nightly Image archive will be export to data.bestgrid.org for backup

# Shibbolized BeSTGRID GridSphere

A detailed document has been written at [BeSTGRID Shibbolized GridSphere Installation](bestgrid-shibbolized-gridsphere-installation.md). 

- BeSTGRID Test Shibbolized GridSphere
- Location

gridsphere.test.bestgrid.org
- Shib 1.3 SP installed
- Member of BeSTGRID Test federation
- Member of AAF Level 1 member

# Shibbolized BeSTGRID Sakai

A detailed document has been written at [BeSTGRID Shibbolized Sakai Installation](bestgrid-shibbolized-sakai-installation.md).

- BeSTGRID Test Shibbolized Sakai
- Location

vre.test.bestgrid.org
- Shib 1.3 SP installed
- Sakai 2.4 installed
- The test Sakai data was retrieved from production Sakai sakai.bestgrid.org
- Member of BeSTGRID Test federation
- Member of AAF Level 1 member

[BeSTGRID Shibbolized Sakai Migration](bestgrid-shibbolized-sakai-migration.md)

# Shibboleth WAYF

- BeSTGRID Test WAYF
- Metadata
[http://wayf.test.bestgrid.org/metadata/bestgrid-test-metadata.xml](http://wayf.test.bestgrid.org/metadata/bestgrid-test-metadata.xml)
- Location: wayf.test.bestgrid.org:/var/www/html/
- The metadata will be export to data.bestgrid.org on a nightly base.

- BeSTGRID Production WAYF
- Metadata
[http://wayf.bestgrid.org/metadata/bestgrid-metadata.xml](http://wayf.bestgrid.org/metadata/bestgrid-metadata.xml)
- Location: wayf.bestgrid.org:/var/www/html/
- The metadata will be export to data.bestgrid.org on a nightly base.

# Shibboleth 2.0 IdP Beta

At the time of writing, Internet 2 group only released a beta version for testing and debugging purpose. 

A Shibboleth 2.0 Beta IdP has been installed in kilrogg.auckland.ac.nz for development and testing purpose.

[Shibboleth 2.0 IdP Beta Installation](shibboleth-20-idp-beta-installation.md) will document my installation process.

# Documentation

- Most Shibboleth related articles has been written at [http://www.bestgrid.org/index.php/Category:Shibboleth](http://www.bestgrid.org/index.php/Category:Shibboleth)
