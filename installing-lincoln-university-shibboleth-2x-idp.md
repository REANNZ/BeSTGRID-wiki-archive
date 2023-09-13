# Installing Lincoln University Shibboleth 2.x IdP

This page documents the installation of Shibboleth 2.x IdP at Lincoln University.  The installation was actually done as a reinstall over a Shibboleth 1.3.x deployment - but this document aims to be styled as if it was done as a fresh install (copying relevant parts of the original 1.3 install documentation).  Thus, this document should be usable to do a complete reinstall of the system if needed.

# Overview

The overall installation plan:

- The install will be done on a CentOS 5.4 (i386) system.
- Shibboleth IdP software (2.1.5) will be installed in /usr/local/shibboleth-idp
- The uApprove user attribute approval tool (version 2.1.5) will be installed on top of Shibboleth IdP
- The Shibboleth IdP and uApprove web applications will run inside Tomcat (tomcat5-5.5.23 bundles with CentOS)
- Tomcat will be using java-1.6.0-openjdk bundles with CentOS

The steps in installing the Shibboleth IdP are:

- Preliminary system configuration (install packages, configure firewall, obtain X509 certificates)
- Install Shibboleth IdP software - as documented at these links:
	
- [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2)
- [https://manager.test.aaf.edu.au/wiki/display/IDP/Installing+the+Shibboleth+IdP](https://manager.test.aaf.edu.au/wiki/display/IDP/Installing+the+Shibboleth+IdP)
- [https://wiki.shibboleth.net/confluence/display/SHIB2/IdPInstall](https://wiki.shibboleth.net/confluence/display/SHIB2/IdPInstall)
- Configure the IdP with LDAP contact information.
- Define all Shibboleth attributes (based on LDAP attributes)
- Configure attribute release / filtering policy.
- Install [uApprove](http://www.switch.ch/aai/support/tools/uApprove.html)

# Preliminaries

## Get front-channel certificate

- Create certificate request


>  openssl req -newkey rsa:2048 -nodes -out `hostname`-http-req.pem -keyout `hostname`-http-key.pem
>  openssl req -newkey rsa:2048 -nodes -out `hostname`-http-req.pem -keyout `hostname`-http-key.pem

- Process the request (done by Royston Boot via RapidSSL)

## System firewall configuration

- Edit `/etc/sysconfig/iptables` and add rules to permit incoming traffic to ports 80, 443, and 8443: add the following just below the rule for port 22:

``` 

-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT

```

- Restart iptables:


>  service iptables restart
>  service iptables restart

## Install certificates

- Install the certificate into `/etc/pki/tls/certs/idp.crt` and the private key into `/etc/pki/tls/private/idp.key`
- Make both files owned by root, with the private key being readable only to owner:


>  rw-rr- 1 root root 1387 Apr 20  2009 /etc/pki/tls/certs/idp.crt
>  rw------ 1 root root 1675 Apr 17  2009 /etc/pki/tls/private/idp.key
>  rw-rr- 1 root root 1387 Apr 20  2009 /etc/pki/tls/certs/idp.crt
>  rw------ 1 root root 1675 Apr 17  2009 /etc/pki/tls/private/idp.key

- Later configure Apache to use these certificates in the virtual host definition.

## Install packages


>  yum install openldap-clients
>  yum install openldap-clients

- For debugging


>  yum install wireshark-gnome
>  yum install wireshark-gnome

- To be able to forward X11 connections via ssh


>  yum install xorg-x11-xauth xorg-x11-fonts-base xorg-x11-fonts-utils xorg-x11-fonts-{75dpi,100dpi,misc,Type1}
>  fc-cache
>  service xfs start
>  yum install xorg-x11-xauth xorg-x11-fonts-base xorg-x11-fonts-utils xorg-x11-fonts-{75dpi,100dpi,misc,Type1}
>  fc-cache
>  service xfs start

- Some useful packages:


>  yum install mc strace
>  yum install mc strace

- Subversion to retrieve source code from svn repositories


>  yum install subversion
>  yum install subversion

- For storing SharedToken and for uApprove information, we will need MySQL


>  yum install mysql mysql-server
>  service mysqld start
>  chkconfig mysqld on
>  yum install mysql mysql-server
>  service mysqld start
>  chkconfig mysqld on

## Configure Time Synchronization

Proper time synchronization is essential for Shibboleth to work correctly.  We configure the IdP to run NTP to continuously synchronize with the two time servers available on campus, `helios` and `selene`.

- Install NTP


>  yum install ntp
>  yum install ntp

- Do a one-off synchronization


>  ntpdate -s helios
>  ntpdate -s helios

- Edit /etc/ntp.conf and:
	
- Comment out local server (`server 127.127.1.0` and `fudge 127.127.1.0`)
- Comment out CentOS servers (all lines starting with `server`)
- Add helios and selene:

``` 

server timeserver1.your.domain.ip.address
server timeserver2.your.domain.ip.address

```
- Make ntpd start on system startup


>  chkconfig ntpd on
>  chkconfig ntpd on

- Start ntpd now


>  service ntpd start
>  service ntpd start

## Configure environment variables

- Create /etc/profile.d/shib.sh with:

``` 

SHIB_HOME=/usr/local/shibboleth-idp/
IDP_HOME=/usr/local/shibboleth-idp/
JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk

export SHIB_HOME IDP_HOME JAVA_HOME

```

- And


>  chmod +x /etc/profile.d/shib.sh
>  chmod +x /etc/profile.d/shib.sh

## Disable network zero-configuration

We don't want to see the `169.254.0.0` address range on `eth0` - so edit /etc/sysconfig/network and add the following line:

``` 
NOZEROCONF=yes
```

## Disable SELinux

The Apache LDAP module does not work with SELinux - SELinux would not allow the module to open outgoing TCP connections.

- Disable SELinux now: 

``` 
echo 0 > /selinux/enforce
```
- And for future restarts:  Edit `/etc/sysconfig/selinux` and change: 

``` 
SELINUX=permissive
```

# IdP installation and basic configuration

These steps are based on the following documentation pages on Shibboleth installation.  You may wish to see them for reference - but the instructions in this section should be sufficient to install the IdP.

- [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2)
- [https://manager.test.aaf.edu.au/wiki/display/IDP/Installing+the+Shibboleth+IdP](https://manager.test.aaf.edu.au/wiki/display/IDP/Installing+the+Shibboleth+IdP)
- [https://wiki.shibboleth.net/confluence/display/SHIB2/IdPInstall](https://wiki.shibboleth.net/confluence/display/SHIB2/IdPInstall)

## Basic Shibboleth IdP Installation

- Download & unpack


>  mkdir /root/inst
>  cd /root/inst
>  wget [http://shibboleth.internet2.edu/downloads/shibboleth/idp/latest/shibboleth-identityprovider-2.1.5-bin.zip](http://shibboleth.internet2.edu/downloads/shibboleth/idp/latest/shibboleth-identityprovider-2.1.5-bin.zip)
>  unzip shibboleth-identityprovider-2.1.5-bin.zip
>  cd shibboleth-identityprovider-2.1.5
>  mkdir /root/inst
>  cd /root/inst
>  wget [http://shibboleth.internet2.edu/downloads/shibboleth/idp/latest/shibboleth-identityprovider-2.1.5-bin.zip](http://shibboleth.internet2.edu/downloads/shibboleth/idp/latest/shibboleth-identityprovider-2.1.5-bin.zip)
>  unzip shibboleth-identityprovider-2.1.5-bin.zip
>  cd shibboleth-identityprovider-2.1.5

- Invoke installer

``` 
sh ./install.sh
```
- When prompted, give the following non-default answers

``` 

Location: non-default /usr/local/shibboleth-idp
FQDN: idp.lincoln.ac.nz
Keystore: changeit

```

- Endorsed XML libs

Remove `/var/lib/tomcat5/common/endorsed/*` ([xml-commons-apis](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=xml-commons-apis&linkCreation=true&fromPageId=3816950998).jar [jaxp_parser_impl](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=jaxp_parser_impl&linkCreation=true&fromPageId=3816950998).jar), symbolic links to `/usr/share/java/` and install all jars from `/root/inst/shibboleth-identityprovider-2.1.2/endorsed/` into `/var/lib/tomcat5/common/endorsed`

## Deploy Shibboleth IdP WAR

Contrary to what the installation instructions say, I have decided to use the standard Tomcat deployment procedure and copy the WAR into the Tomcat webapps directory and let Tomcat explode the WAR.  That gives me the flexibility to drop in new libraries without redeploying the IdP.

- Copy the WAR into Tomcat's webapps directory


>  cp /usr/local/shibboleth-idp/war/idp.war /var/lib/tomcat5/webapps
>  cp /usr/local/shibboleth-idp/war/idp.war /var/lib/tomcat5/webapps

- Start Tomcat - explode the WAR


>  service tomcat5 start
>  service tomcat5 start

## Configure Tomcat

- Connectors: define AJP at 8009 and comment out 8080 in `/etc/tomcat5/server.xml`

- Edit `/etc/tomcat5/tomcat5.conf` and add:


>  JAVA_OPTS="-Xms256m -Xmx768m"
>  JAVA_OPTS="-Xms256m -Xmx768m"

- Restart Tomcat


>  service tomcat5 restart
>  service tomcat5 restart

## Important considerations for connecting to Active Directory

Both Apache and Shibboleth must be configured with access to an LDAP server - Apache to verify username and password, and Shibboleth to retrieve attributes for an already established principal name.

The LDAP server used here is a Windows Active Directory 2008 server.

When doing LDAP searches starting at the root (which is a necessity in this case), the server returns LDAP referrals to other trees in the LDAP forest.  The IdP LDAP resolver must be configured to follow the referrals.  To allow the IdP to follow the referrals, the system must be able to resolve the hostnames for the additional LDAP servers and must be able to connect to these servers (to receive an empty reply there).

Once this is fully configured, a bug in the Apache LDAP module kicks in, breaking Apache LDAP login when referrals *can* be made.

Hence, the necessary configuration is to do Apache LDAP authentication against the AD Global Catalog at port 3268, and only configure the IdP resolver to connect to the actual AD server.

For more information on the background of this issue, see:

- [https://issues.apache.org/bugzilla/show_bug.cgi?id=26538](https://issues.apache.org/bugzilla/show_bug.cgi?id=26538)
- [http://wiki.apache.org/httpd/ModAuthAndActiveDirectory2003](http://wiki.apache.org/httpd/ModAuthAndActiveDirectory2003)

And for Shibboleth IdP configuration with AD, see [https://wiki.shibboleth.net/confluence/display/SHIB2/IdPADConfigIssues](https://wiki.shibboleth.net/confluence/display/SHIB2/IdPADConfigIssues)

The proper approach (used further below) is:

- For Apache, use the URL 

``` 
ldap://acs1.lincoln.ac.nz:3268/dc=lincoln,dc=ac,dc=nz?cn?sub?(objectClass=*)
```
- For Shibboleth LDAP DataConnector, use: 

``` 
ldapURL="ldap://acs1.lincoln.ac.nz" baseDN="dc=lincoln,dc=ac,dc=nz"
```

## Configure Access to LDAP servers

In order for LDAP referrals to work (so that Shibboleth attribute resolver can follow them), we need to configure all of the LDAP servers by adding the following to `/etc/hosts`

``` 

10.x.x.1       acs1.lincoln.ac.nz acs1 DomainDNSZones.lincoln.ac.nz ForestDNSZones.lincoln.ac.nz lincoln.ac.nz
10.x.x.2       acs2.lincoln.ac.nz acs2 DomainDNSZones.lincoln.ac.nz ForestDNSZones.lincoln.ac.nz lincoln.ac.nz

10.x.x.3      DomainDNSZones.lincoln.ac.nz ForestDNSZones.lincoln.ac.nz lincoln.ac.nz
10.x.x.4      DomainDNSZones.lincoln.ac.nz ForestDNSZones.lincoln.ac.nz lincoln.ac.nz

```

## Configure Apache

Configure Apache virtual hosts for ports 443 and 8443.  Follow [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2) for this.

- Create `/etc/httpd/conf.d/ports.conf` with


>  Listen 443
>  Listen 8443
>  Listen 443
>  Listen 8443

- Create `idp.conf` and `idp8443.conf` in `/etc/httpd/conf.d` based on the snippets at [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2/ApacheConf](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2/ApacheConf) with the following modifications
	
- Configure files for hostname idp.lincoln.ac.nz
- In this case (host certificate issued directly by a root CA), remove the SSLCertificateChainFile directive from idp.conf
- Configure LDAP access: change the authentication parameters in the `Location` section to:

``` 

        <Location /idp/Authn/RemoteUser>
            # Lincoln University specific
            SSLRequireSSL
            AuthType Basic
            AuthBasicProvider ldap
            <b>AuthzLDAPAuthoritative OFF
            AuthName "Shibboleth IdP Authentication"
            AuthLDAPBindDN ''LDAP-BIND-DN-HERE''
            AuthLDAPBindPassword ''LDAP-PASSWORD-HERE''
            AuthLDAPURL "ldap://acs1.lincoln.ac.nz:3268/dc=lincoln,dc=ac,dc=nz?cn?sub?(objectClass=*)"</b>
            require valid-user
        </Location>

```

- In `idp8443.conf`, change the path to the certificate and private key files from `/opt/shibboleth-idp/credentials` to `/usr/local/shibboleth-idp/credentials`


**Important Note**: 

- use `ServerName idp.yourdomain:``8443` in `idp8443.conf` - otherwise, Apache uses the certificates selected for virtual host 443 in both virtual hosts.


>  ***Important Note**: Make sure your ssl.conf disables the SSL session cache as instructed above - otherwise, the back-channel communication might unpredictably fail due to a known [OpenSSL bug, error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPTroubleshootingCommonErrors#NativeSPTroubleshootingCommonErrors-error%3A1408F06B%3ASSLroutines%3ASSL3GETRECORD%3Abaddecompression).
>  ***Important Note**: Make sure your ssl.conf disables the SSL session cache as instructed above - otherwise, the back-channel communication might unpredictably fail due to a known [OpenSSL bug, error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPTroubleshootingCommonErrors#NativeSPTroubleshootingCommonErrors-error%3A1408F06B%3ASSLroutines%3ASSL3GETRECORD%3Abaddecompression).

## Backup Shibboleth IdP original configuration

To make it easier to track changes done to the Shibboleth configuration files, create a backup copy of each of the files with the ".dist" suffix:

>  for FILE in /usr/local/shibboleth-idp/conf/{attribute-filter.xml,attribute-resolver.xml,handler.xml,internal.xml,logging.xml,relying-party.xml,service.xml} /usr/local/shibboleth-idp/metadata/idp-metadata.xml ; do cp -i $FILE $FILE.dist ; done

## Configure proper Scope in IdP metadata

- Configure `/usr/local/shibboleth-idp/metadata/idp-metadata.xml` and make sure the Scope is set to `lincoln.ac.nz` - both for `IDPSSODescriptor` and `AttributeAuthorityDescriptor` (two modifications)

``` 

        <Extensions>
            <shibmd:Scope regexp="false">lincoln.ac.nz</shibmd:Scope>
        </Extensions>

```

## Configure Federation Metadata

Configure the IdP to load the Federation Metadata in `/usr/local/shibboleth-idp/conf/relying-party.xml` by adding the following snippets into the `Chaining` `MetadataProvider`.  

``` 

        <!-- AAF Federation metadata -->
        <MetadataProvider id="AAF" xsi:type="FileBackedHTTPMetadataProvider" xmlns="urn:mace:shibboleth:2.0:metadata"
                          metadataURL="http://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml"
                          backingFile="/usr/local/shibboleth-idp/metadata/aaf-metadata.xml">
          <MetadataFilter xsi:type="ChainingFilter" xmlns="urn:mace:shibboleth:2.0:metadata">
            <MetadataFilter xsi:type="SignatureValidation" xmlns="urn:mace:shibboleth:2.0:metadata"
                            trustEngineRef="shibboleth.MetadataTrustEngine"
                            requireSignedMetadata="true" />
          </MetadataFilter>
        </MetadataProvider>

        <!-- BeSTGRID Federation -->
        <!-- temporarily disabled updates
        <MetadataProvider id="BeSTGRID" xsi:type="ResourceBackedMetadataProvider" xmlns="urn:mace:shibboleth:2.0:metadata">
            <MetadataResource xsi:type="resource:FilesystemResource" file="/usr/local/shibboleth-idp/metadata/bestgrid-metadata.xml" />
        </MetadataProvider>
        -->
        <MetadataProvider id="BeSTGRID" xsi:type="FileBackedHTTPMetadataProvider" xmlns="urn:mace:shibboleth:2.0:metadata"
                          metadataURL="https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml"
                          backingFile="/usr/local/shibboleth-idp/metadata/bestgrid-metadata.xml">
        </MetadataProvider>

```

- The AAF metadata should have their signature verified: add the trust engine definition as well (or uncomment and configure it further down in the file):

``` 

    <!-- Trust engine used to evaluate the signature on loaded metadata. -->
    <security:TrustEngine id="shibboleth.MetadataTrustEngine" xsi:type="security:StaticExplicitKeySignature">
        <security:Credential id="AAFCredentials" xsi:type="security:X509Filesystem">
            <security:Certificate>/usr/local/shibboleth-idp/credentials/aaf-metadata-cert.pem</security:Certificate>
        </security:Credential>
    </security:TrustEngine>

```

- This definition is referring to a certificate used to verify the signature - store the certificate in /usr/local/shibboleth-idp/credentials


>  cd /usr/local/shibboleth-idp/credentials
>  wget [https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem](https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem) -O aaf-metadata-cert.pem
>  cd /usr/local/shibboleth-idp/credentials
>  wget [https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem](https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem) -O aaf-metadata-cert.pem

- Note that the relying-party.xml file also refers to:
	
- Our own metadata generated for the IdP in `/usr/local/shibboleth-idp/metadata/idp-metadata.xml`
- Our own credentials stored in `/usr/local/shibboleth-idp/credentials/idp.{crt,key`}
- If using a different entityID than the one assigned by the installer - e.g., an URN-based one - configure the self-metadata in `/usr/local/shibboleth-idp/metadata/idp-metadata.xml` and change the entityID to the custom one

## Prepare for launch

- Change ownership of critical files and directories to Tomcat (give Tomcat permission to read private key, write logs, etc.):


>  cd /usr/local/shibboleth-idp
>  chown -R tomcat:tomcat logs metadata credentials conf
>  cd /usr/local/shibboleth-idp
>  chown -R tomcat:tomcat logs metadata credentials conf

# Attribute configuration

All of attribute configuration is done in `/usr/local/shibboleth-idp/conf/attribute-resolver.xml`.  

Edit the file and implement the following changes:

## Configure resolver access to LDAP

In `/usr/local/shibboleth-idp/conf/attribute-resolver.xml`, uncomment the LDAP `DataConnector` element and configure it with local LDAP connection parameters:

``` 

    <resolver:DataConnector id="myLDAP" xsi:type="LDAPDirectory" xmlns="urn:mace:shibboleth:2.0:resolver:dc"
        ldapURL="<b>ldap://acs1.lincoln.ac.nz</b>" baseDN="<b>dc=lincoln,dc=ac,dc=nz</b>" principal="<b>LDAP-BIND-DN-HERE</b>"
        principalCredential="<b>PASSWORD-HERE</b>">
        <FilterTemplate>
            <![CDATA[
                (cn=$requestContext.principalName)
            ]]>
        </FilterTemplate>
        <b><LDAPProperty name="java.naming.referral" value="follow"/></b>
    </resolver:DataConnector>

```

## Basic attributes

- Define attributes taken straight from LDAP: `mail`, `sn`, and `givenName`: just uncomment the relevant `AttributeDefinition` element for each of these attributes.

- Define attributes based on renaming an attribute from LDAP: uncomment the relevant `AttributeDefinition` element and change the sourceAttributeID XML attribute to the name of the original attribute.
	
- Define `cn` based on `eduDisplayName` (sourceAttributeID="eduDisplayName")
- Define `uid` based on `cn`
- Define `displayName` based on `eduDisplayName`.  As the default `attribute-resolver.xml` configuration does not include the displayName attribute, paste in the following definition:

``` 

    <resolver:AttributeDefinition id="displayName" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="eduDisplayName">
        <resolver:Dependency ref="myLDAP" />
 
        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:dir:attribute-def:displayName" />
        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:2.16.840.1.113730.3.1.241" friendlyName="displayName" />
        <!-- displayName OID courtesy https://manager.aaf.edu.au/rr/list_attributes.php -->
    </resolver:AttributeDefinition>

```

- Define `eduPersonPrincipalName` define based on `cn` with a scope of `"lincoln.ac.nz"`:

``` 
scope="lincoln.ac.nz" sourceAttributeID="cn"
```

## Static attributes

We need to define several attributes that would have a static value for each user.  We do so by first defining a StaticDataConnector (close to where the commented-out example is):

``` 

    <!-- Static Connector -->
    <resolver:DataConnector id="staticAttributes" xsi:type="Static" xmlns="urn:mace:shibboleth:2.0:resolver:dc">
        <Attribute id="o">
            <Value>Lincoln University</Value>
        </Attribute>
        <Attribute id="l">
            <Value>NZ</Value>
        </Attribute>
        <Attribute id="homeOrg">
            <Value>lincoln.ac.nz</Value>
        </Attribute>
        <Attribute id="homeOrgType">
            <Value>urn:mace:terena.org:schac:homeOrganizationType:nz:university</Value>
        </Attribute>
    </resolver:DataConnector>

```

Now define the attributes:

- Define `locality` and `organizationName` by uncommenting their definition and changing the connector dependency from "myLDAP" to "staticAttributes"
	
- Note: to match the name used in the federation, change the SAML1 attribute name for `organizationName` to `"urn:mace:dir:attribute-def:TopLevelOrg"`
- Pasting in the definitions for `homeOrg` and `homeOrgType`, not provided in the default configuration:

``` 

    <resolver:AttributeDefinition id="homeOrg" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="homeOrg">
        <resolver:Dependency ref="staticAttributes" />
 
        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:1.3.6.1.4.1.25178.1.2.9" />
 
        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:1.3.6.1.4.1.25178.1.2.9" friendlyName="homeOrg" />
    </resolver:AttributeDefinition>
 
    <resolver:AttributeDefinition id="homeOrgType" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="homeOrgType">
        <resolver:Dependency ref="staticAttributes" />
 
        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:1.3.6.1.4.1.25178.1.2.10" />
 
        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:1.3.6.1.4.1.25178.1.2.10" friendlyName="homeOrgType" />
    </resolver:AttributeDefinition>

```

## Scripted attributes

The `eduPersonAffiliation` and `eduPersonPrimaryAffiliation` attributes have to be defined using a scriptlet based on other, site specific attributes stored in the LDAP.

- We first define these attributes at the Shibboleth level, importing them from LDAP, using the following definitions.  Note that as these attributes are not expected to be passed in Shibboleth assertions, the definitions don't have any `AttributeEncoder` elements.  Otherwise, we would have to decide on attribute names / OIDs to use in the encoder definitions.

``` 

    <!-- prerequisite to scripted eduPersonAffiliation -->
    <resolver:AttributeDefinition id="luUnderGrad" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="luUnderGrad">
        <resolver:Dependency ref="myLDAP" />
        <!-- no encoder needed -->
    </resolver:AttributeDefinition>
 
    <resolver:AttributeDefinition id="luPostGrad" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="luPostGrad">
        <resolver:Dependency ref="myLDAP" />
        <!-- no encoder needed -->
    </resolver:AttributeDefinition>
 
    <resolver:AttributeDefinition id="luStaff" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="luStaff">
        <resolver:Dependency ref="myLDAP" />
        <!-- no encoder needed -->
    </resolver:AttributeDefinition>
 
    <resolver:AttributeDefinition id="luOutSourcedEmail" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="luOutSourcedEmail">
        <resolver:Dependency ref="myLDAP" />
        <!-- no encoder needed -->
    </resolver:AttributeDefinition>

```

- We follow by defining `eduPersonAffiliation` using an `AttributeDefinition` of type `Script`:

``` 

    <resolver:AttributeDefinition id="eduPersonAffiliation" xsi:type="Script" xmlns="urn:mace:shibboleth:2.0:resolver:ad">
        <resolver:Dependency ref="luUnderGrad" />
        <resolver:Dependency ref="luPostGrad" />
        <resolver:Dependency ref="luStaff" />
        <resolver:Dependency ref="luOutSourcedEmail" />

        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:dir:attribute-def:eduPersonAffiliation" />

        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:1.3.6.1.4.1.5923.1.1.1.1" friendlyName="eduPersonAffiliation" />

        <Script>
        <![CDATA[
                importPackage(Packages.edu.internet2.middleware.shibboleth.common.attribute.provider);
                if (eduPersonAffiliation == null) {
                        eduPersonAffiliation = new BasicAttribute("eduPersonAffiliation");
                }
                isUnderGrad = luUnderGrad != null && luUnderGrad.getValues().size()>0 && luUnderGrad.getValues().get(0).equals("TRUE");
                isPostGrad = luPostGrad != null && luPostGrad.getValues().size()>0 && luPostGrad.getValues().get(0).equals("TRUE");
                isStaff = luStaff != null && luStaff.getValues().size()>0 && luStaff.getValues().get(0).equals("TRUE");
                isOutSourcedEmail = luOutSourcedEmail != null && luOutSourcedEmail.getValues().size()>0 && luOutSourcedEmail.getValues().get(0).equals("TRUE");

                if (isStaff) { eduPersonAffiliation.getValues().add("staff"); };
                if (isPostGrad && !isOutSourcedEmail) { eduPersonAffiliation.getValues().add("staff"); };
                if (isUnderGrad || isPostGrad ) { eduPersonAffiliation.getValues().add("student"); };
                if (isUnderGrad || isPostGrad || isStaff ) { eduPersonAffiliation.getValues().add("member"); };
        ]]>
        </Script>
    </resolver:AttributeDefinition>

```

- And a similar definition for `eduPersonPrimaryAffiliation` (which has to be a single valued attribute, hence the logic in the script is slightly different)

``` 

    <resolver:AttributeDefinition id="eduPersonPrimaryAffiliation" xsi:type="Script" xmlns="urn:mace:shibboleth:2.0:resolver:ad">
        <resolver:Dependency ref="luUnderGrad" />
        <resolver:Dependency ref="luPostGrad" />
        <resolver:Dependency ref="luStaff" />
        <resolver:Dependency ref="luOutSourcedEmail" />

        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:dir:attribute-def:eduPersonPrimaryAffiliation" />

        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:1.3.6.1.4.1.5923.1.1.1.5" friendlyName="eduPersonPrimaryAffiliation" />

        <Script>
        <![CDATA[
                importPackage(Packages.edu.internet2.middleware.shibboleth.common.attribute.provider);
                if (eduPersonPrimaryAffiliation == null) {
                        eduPersonPrimaryAffiliation = new BasicAttribute("eduPersonPrimaryAffiliation");
                }
                isUnderGrad = luUnderGrad != null && luUnderGrad.getValues().size()>0 && luUnderGrad.getValues().get(0).equals("TRUE");
                isPostGrad = luPostGrad != null && luPostGrad.getValues().size()>0 && luPostGrad.getValues().get(0).equals("TRUE");
                isStaff = luStaff != null && luStaff.getValues().size()>0 && luStaff.getValues().get(0).equals("TRUE");
                isOutSourcedEmail = luOutSourcedEmail != null && luOutSourcedEmail.getValues().size()>0 && luOutSourcedEmail.getValues().get(0).equals("TRUE");

                if (isStaff || (isPostGrad && !isOutSourcedEmail)) { eduPersonPrimaryAffiliation.getValues().add("staff"); }
                else if (isUnderGrad || isPostGrad ) { eduPersonPrimaryAffiliation.getValues().add("student"); };
        ]]>
        </Script>
    </resolver:AttributeDefinition>

```

- Finally, we define the `eduPersonScopedAffiliation` attribute by uncommenting the definition and:
	
- setting the correct scope, `scope="lincoln.ac.nz"`
- changing the dependency from LDAP to the previous defined attribute `eduPersonAffiliation`: 

``` 
        <resolver:Dependency ref="eduPersonAffiliation" />
```

## Shared Token

- Follow [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/SharedToken](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/SharedToken)
	
- We will choose to store the SharedToken value in a MySQL database - to keep track of values issued and have a means of inserting a different value if someone asks for portability.

- Download binary from [http://projects.arcs.org.au/svn/systems/tags/idp/arcs-shibext/arcs-shibext-1.5.2/download/arcs-shibext-1.5.2.jar](http://projects.arcs.org.au/svn/systems/tags/idp/arcs-shibext/arcs-shibext-1.5.2/download/arcs-shibext-1.5.2.jar)


>  wget [http://projects.arcs.org.au/svn/systems/tags/idp/arcs-shibext/arcs-shibext-1.5.2/download/arcs-shibext-1.5.2.jar](http://projects.arcs.org.au/svn/systems/tags/idp/arcs-shibext/arcs-shibext-1.5.2/download/arcs-shibext-1.5.2.jar)
>  wget [http://projects.arcs.org.au/svn/systems/tags/idp/arcs-shibext/arcs-shibext-1.5.2/download/arcs-shibext-1.5.2.jar](http://projects.arcs.org.au/svn/systems/tags/idp/arcs-shibext/arcs-shibext-1.5.2/download/arcs-shibext-1.5.2.jar)

- Edit the conf/sharedtoken.properties inside the jar and change the following settings:


>  DEFAULT_IDP_HOME=/usr/local/shibboleth-idp
>  SEARCH_FILTER_SPEC=cn={0}
>  DEFAULT_IDP_HOME=/usr/local/shibboleth-idp
>  SEARCH_FILTER_SPEC=cn={0}

- Copy the JAR into /var/lib/tomcat5/webapps/idp/WEB-INF/lib and /usr/local/shibboleth-idp/lib


>  cp arcs-shibext-*.jar /usr/local/shibboleth-idp/lib
>  cp arcs-shibext-*.jar /var/lib/tomcat5/webapps/idp/WEB-INF/lib
>  cp arcs-shibext-*.jar /usr/local/shibboleth-idp/lib
>  cp arcs-shibext-*.jar /var/lib/tomcat5/webapps/idp/WEB-INF/lib

- Download MySQL JDBC driver from [http://dev.mysql.com/downloads/connector/j/5.0.html](http://dev.mysql.com/downloads/connector/j/5.0.html)
	
- Install the driver (`mysql-connector-java-5.0.8-bin.jar`) into `/var/lib/tomcat5/webapps/idp/WEB-INF/lib` and also into `/usr/local/shibboleth-idp/lib`

- Create a MySQL user: run "mysql" as root and enter the following commands:


>  create user 'idp_admin'@'localhost' identified by 'idp_admin';
>  grant all privileges on **.** to 'idp_admin'@'localhost' with grant option;
>  create user 'idp_admin'@'localhost' identified by 'idp_admin';
>  grant all privileges on **.** to 'idp_admin'@'localhost' with grant option;

- Create a MySQL user: run "mysql" as idp_admin and enter the following commands:


>  mysql -u idp_admin -p
>  mysql -u idp_admin -p

>  CREATE DATABASE idp_db;
>  use idp_db;

>  CREATE TABLE tb_st (
>  uid VARCHAR(100) NOT NULL,
>  sharedToken VARCHAR(50),
>  PRIMARY KEY  (uid)
>  );

- Add schema definition to attribute-resolver.xml: add `urn:mace:arcs.org.au:shibboleth:2.0:resolver:dc classpath:/schema/arcs-shibext-dc.xsd` to the list of schema locations at the top of the file.
- Add connector definition to attribute-resolver.xml (sharedToken) with the following customizations

``` 

    <!-- ==================== auEduPersonSharedToken data connector ================== -->

    <resolver:DataConnector xsi:type="SharedToken" xmlns="urn:mace:arcs.org.au:shibboleth:2.0:resolver:dc"
                        id="sharedToken"
                        idpIdentifier="https://idp.lincoln.ac.nz/idp/shibboleth"
                        sourceAttributeID="cn"
                        storeLdap="false"
                        storeDatabase="true"
                        salt="SALT-GOES-HERE">
        <resolver:Dependency ref="myLDAP" />

        <DatabaseConnection jdbcDriver="com.mysql.jdbc.Driver"
                            jdbcURL="jdbc:mysql://localhost/idp_db"
                            jdbcUserName="username"
                            jdbcPassword="password"
                            primaryKeyName="uid"/>

    </resolver:DataConnector>

```
- Note: on the first install, generate a suitable salt value with: 

``` 
 openssl rand -base64 36 
```
- On subsequent installs, reuse the same value (stored somewhere carefully)
- Note also that the SharedToken value depends on the IdP entityID - which could be picked up from the environment, but is better set in the configuration.

- Add attribute definition to attribute-resolver.xml (auEduPersonSharedToken)

``` 

    <!-- ==================== auEduPersonSharedToken attribute definition ================== -->

    <resolver:AttributeDefinition id="auEduPersonSharedToken" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="auEduPersonSharedToken">

        <resolver:Dependency ref="sharedToken" />

        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:federation.org.au:attribute:auEduPersonSharedToken" />

        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:1.3.6.1.4.1.27856.1.2.5" friendlyName="auEduPersonSharedToken" />
    </resolver:AttributeDefinition>

```

- Release attribute in attribute-filter.xml (auEduPersonSharedToken)
	
- See attribute release later.

## eduPersonTargetedID

Based on [https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPTargetedID](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPTargetedID), define old and new definition of eduPersonTargetedID by:

1. Uncommenting AttributeDefinition id="eduPersonTargetedID.old"
	
- Changing Scope in `eduPersonTargetedID.old` to `scope="lincoln.ac.nz"`
2. Uncommenting AttributeDefinition id="eduPersonTargetedID"
3. Uncommenting DataConnector where id="computedID and changing it in the following ways:
	
- Using just `cn` as the source attribute.
- Using a value of salt generated (only at the first install, to be reused later) with 

``` 
openssl rand -base64 36
```

This is the final configuration of the ComputeID DataConnector (without the proper salt)

``` 

    <resolver:DataConnector xsi:type="ComputedId" xmlns="urn:mace:shibboleth:2.0:resolver:dc"
                            id="computedID"
                            generatedAttributeID="computedID"
                            <b>sourceAttributeID="cn"</b>
                            <b>salt="<em>abcef123YOURVALUE</em>"></b>
        <resolver:Dependency ref="myLDAP" />
    </resolver:DataConnector>

```

# Advanced IdP Configuration

## Enabling automatic reload

To automatically reload a service configuration (such as the attribute-filter.xml file), one has to add two attributes to the service definition: **configurationResourcePollingFrequency** (in milliseconds) and **configurationResourcePollingRetryAttempts**.

The change done to `/usr/local/shibboleth-idp/conf/service.xml` is thus: 

``` 

     <Service id="shibboleth.AttributeResolver"
 +             <b>configurationResourcePollingFrequency="5000" configurationResourcePollingRetryAttempts="10"</b>
              xsi:type="attribute-resolver:ShibbolethAttributeResolver">
         <ConfigurationResource file="/usr/local/shibboleth-idp/conf/attribute-resolver.xml" xsi:type="resource:FilesystemResource" />
     </Service>
      <Service id="shibboleth.AttributeFilterEngine"
 +             <b>configurationResourcePollingFrequency="5000" configurationResourcePollingRetryAttempts="10"</b>
              xsi:type="attribute-afp:ShibbolethAttributeFilteringEngine">
         <ConfigurationResource file="/usr/local/shibboleth-idp/conf/attribute-filter.xml" xsi:type="resource:FilesystemResource" />
     </Service>

```

and

``` 

     <Service id="shibboleth.RelyingPartyConfigurationManager"
 +             <b>configurationResourcePollingFrequency="5000" configurationResourcePollingRetryAttempts="10"</b>
              xsi:type="relyingParty:SAMLMDRelyingPartyConfigurationManager"
              depends-on="shibboleth.SAML1AttributeAuthority shibboleth.SAML2AttributeAuthority">
         <ConfigurationResource file="/usr/local/shibboleth-idp/conf/relying-party.xml" xsi:type="resource:FilesystemResource" />
     </Service>
 
     <Service id="shibboleth.HandlerManager"
 +             <b>configurationResourcePollingFrequency="5000" configurationResourcePollingRetryAttempts="10"</b>
              depends-on="shibboleth.RelyingPartyConfigurationManager"
              xsi:type="profile:IdPProfileHandlerManager">
         <ConfigurationResource file="/usr/local/shibboleth-idp/conf/handler.xml" xsi:type="resource:FilesystemResource" />
     </Service>

```

## Load AAF Atribute Filter

To automatically release attributes to new services registered in the federation, we will define inside the `AttributeFilterEngine` a second `ConfigurationResource`  loading the data from a remote HTTP URL (backed by a local file) (as documented in [Shibboleth documentation on multiple policy group files](https://wiki.shibboleth.net/confluence/display/SHIB2/IdPAddAttributeFilter#IdPAddAttributeFilter-LoadingMultiplePolicyGroupFiles)

In services.xml, modify the AttributeFilterEngine in the following way:

``` 

    <Service id="shibboleth.AttributeFilterEngine"
             <b>configurationResourcePollingFrequency="7200000" configurationResourcePollingRetryAttempts="10"</b>
             xsi:type="attribute-afp:ShibbolethAttributeFilteringEngine">
        <ConfigurationResource file="/usr/local/shibboleth-idp/conf/attribute-filter.xml" xsi:type="resource:FilesystemResource" />
        <b><ConfigurationResource xsi:type="resource:FileBackedHttpResource"
                               url="https://manager.aaf.edu.au/federationregistry/attributefilter/generate/434"
                               file="/usr/local/shibboleth-idp/conf/aaf-attribute-filter.xml" /></b>
    </Service>

```

**Note**:

- Increase polling frequency (2 hours recommended), not to put too much stress on the federation resource manager.
- The attribute names used in the download policy file must match the local attribute names.  To match this, rename the following attributes (the ID in the AttributeDefinition element) in both attribute-resolver.xml (attribute definitions) and in attribute-filter.xml (local attribute filter)

``` 

commonName => cn
email => mail
homeOrg => homeOrganization
homeOrgType => homeOrganizationType
locality => Locality
eduPersonPrincipalName => principalName
organizationName => topLevelOrg

```

# Installing uApprove

The section follows the original uApprove installation manual at [https://www.switch.ch/proxy/aai/downloads/uApprove-2.1.3-manual.html](https://www.switch.ch/proxy/aai/downloads/uApprove-2.1.3-manual.html).

This page documents how I walked through the installation manual and highlights critical points - and where I did things differently.

## Preliminary assumptions

- Shibboleth IdP >= 2.1.3 installed and configured.
	
- Shibboleth home directory is `/usr/local/shibboleth-idp`
- Tomcat webapps directory is `/var/lib/tomcat5/webapps`
- Shibboleth IdP web application is installed (and exploded) in `/var/lib/tomcat5/webapps`
- uApprove configuration files will be installed in `/etc/shibboleth-idp/uApprove`
- uApprove will store the release information in a MySQL database.

## Download & unpack

- Get and unpack uApprove binary distribution


>  mkdir /root/inst
>  cd /root/inst
>  wget [http://www.switch.ch/aai/downloads/uApprove-2.1.3-bin.zip](http://www.switch.ch/aai/downloads/uApprove-2.1.3-bin.zip)
>  unzip uApprove-2.1.3-bin.zip
>  mkdir /root/inst
>  cd /root/inst
>  wget [http://www.switch.ch/aai/downloads/uApprove-2.1.3-bin.zip](http://www.switch.ch/aai/downloads/uApprove-2.1.3-bin.zip)
>  unzip uApprove-2.1.3-bin.zip

- Unpack two zip files inside the unpacked distribution


>  cd uApprove-2.1.3
>  unzip idp-plugin-2.1.3-bin.zip
>  unzip viewer-2.1.3-bin.zip
>  cd uApprove-2.1.3
>  unzip idp-plugin-2.1.3-bin.zip
>  unzip viewer-2.1.3-bin.zip

- Create and populate configuration directory


>  mkdir -p /etc/shibboleth-idp/uApprove
>  cp idp-plugin-2.1.3/conf-template/* /etc/shibboleth-idp/uApprove
>  mkdir -p /etc/shibboleth-idp/uApprove
>  cp idp-plugin-2.1.3/conf-template/* /etc/shibboleth-idp/uApprove

- Install the IdP plugin into the exploded IdP WAR - and also into IdP's lib directory.


>  cp idp-plugin-2.1.3/lib/* /var/lib/tomcat5/webapps/idp/WEB-INF/lib
>  cp idp-plugin-2.1.3/lib/* /usr/local/shibboleth-idp/lib
>  cp idp-plugin-2.1.3/lib/* /var/lib/tomcat5/webapps/idp/WEB-INF/lib
>  cp idp-plugin-2.1.3/lib/* /usr/local/shibboleth-idp/lib


>  cp -r viewer-2.1.3/webapp /var/lib/tomcat5/webapps/uApprove
>  cp -r viewer-2.1.3/webapp /var/lib/tomcat5/webapps/uApprove

## Database

- Install and start MySQL server (if not already installed)


>  yum install mysql mysql-server
>  service mysqld start
>  chkconfig mysqld on
>  yum install mysql mysql-server
>  service mysqld start
>  chkconfig mysqld on

- Set MySQL root password


>  /usr/bin/mysqladmin -u root -h idp.lincoln.ac.nz password secret-password
>  /usr/bin/mysqladmin -u root password secret-password
>  /usr/bin/mysqladmin -u root -h idp.lincoln.ac.nz password secret-password
>  /usr/bin/mysqladmin -u root password secret-password

- Create database, grant permissions to local account `uApprove` and pick a password for the account.
	
- Run `mysql -u root -p`, login with the password set for the MySQL root account, and run the database creation scripts listed in the [uApprove installation manual, database configuration section](https://www.switch.ch/proxy/aai/downloads/uApprove-2.1.3-manual.html#configuration).

- Edit `/etc/shibboleth-idp/uApprove/common.properties`:
	
- uncomment database setup, comment out flatfile setup
- change databaseConfig location to the correct path:

``` 
databaseConfig=/etc/shibboleth-idp/uApprove/database.properties
```
- set the sharedSecret to a random string, at best generated with:

``` 
openssl rand -base64 18
```


## More configuration

- Edit `/etc/shibboleth-idp/uApprove/attribute-list` and add extra local attributes (make sure names match actual definitions in attribute-resolver.xml):

``` 

cn
displayName
eduPersonScopedAffiliation
eduPersonPrimaryAffiliation
eduPersonPrincipalName
auEduPersonSharedToken
Locality
topLevelOrg
homeOrganization
homeOrganizationType

```

- Comment out termsOfUse in `/etc/shibboleth-idp/uApprove/common.properties` - that will switch the TermsOfUseManager off and users will not get asked to agree to (empty) terms of use.

- Set URL to the uApprove web application `/etc/shibboleth-idp/uApprove/idp-plugin.properties`


>  uApproveViewer=[https://idp.lincoln.ac.nz/uApprove/Controller](https://idp.lincoln.ac.nz/uApprove/Controller)
>  uApproveViewer=[https://idp.lincoln.ac.nz/uApprove/Controller](https://idp.lincoln.ac.nz/uApprove/Controller)

- Edit uApprove's web.xml, `/var/lib/tomcat5/webapps/uApprove/WEB-INF/web.xml` and set the path to configuration files:


>         /etc/shibboleth-idp/uApprove/viewer.properties;
>         /etc/shibboleth-idp/uApprove/common.properties;
>         /etc/shibboleth-idp/uApprove/viewer.properties;
>         /etc/shibboleth-idp/uApprove/common.properties;

- Edit `/etc/shibboleth-idp/uApprove/viewer.properies` and:
	
- Configure path to attribute list:

``` 
attributeList=/etc/shibboleth-idp/uApprove/attribute-list
```
- Leave global consent on

``` 
globalConsentPossible=true
```
- Set local to US_en

``` 
useLocale = US_en
```
- Set path to logging config to 

``` 
loggingConfig=/etc/shibboleth-idp/uApprove/logging.xml
```

- In `/etc/shibboleth-idp/uApprove/logging.xml`, configure logging to log into

``` 
/usr/local/shibboleth-idp/logs/uApprove.log
```

- Configure sp-blacklist.  The sp-blacklist (actually rather a whitelist) is a list of Service Provider (their entityIDs) where uApprove should never step in - and should assume user's consent.  This could be used for a local wiki (located within the institution, user information does not cross institutional boundaries) and for the SLCS server - where uApprove would break the flow through the automated tools.

- Configure the blacklist file location in `/etc/shibboleth-idp/uApprove/idp-plugin.properties`:


>  spBlacklist = /etc/shibboleth-idp/uApprove/sp-blacklist
>  spBlacklist = /etc/shibboleth-idp/uApprove/sp-blacklist

- Add the entityIds of the pre-agreed SPs into the list. For now,

``` 

https://slcs1.arcs.org.au/shibboleth

```

- Optional: leaving out configuration of the *Reset-approvals* web application.

## Turn uApprove on

- Edit `/etc/httpd/conf.d/idp.conf` and add an extra ProxyPass directive for the uApprove web application:


>  ProxyPass /uApprove ajp://localhost:8009/uApprove retry=5
>  ProxyPass /uApprove ajp://localhost:8009/uApprove retry=5

- Edit `/var/lib/tomcat5/webapps/idp/WEB-INF/web.xml` and add the filter and mapping for uApprove as documented in the [uApprove installation manual, IdP Plugin Configuration section](https://www.switch.ch/proxy/aai/downloads/uApprove-2.1.3-manual.html#configuration)

``` 

  <filter>
    <filter-name>uApprove IdP plugin</filter-name>
    <filter-class>ch.SWITCH.aai.uApprove.idpplugin.Plugin</filter-class>
    <init-param>
      <param-name>Config</param-name>
      <param-value>
        /etc/shibboleth-idp/uApprove/idp-plugin.properties;
        /etc/shibboleth-idp/uApprove/common.properties;
      </param-value>
    </init-param>
  </filter>

  <filter-mapping>
    <filter-name>uApprove IdP plugin</filter-name>
    <url-pattern>/profile/*</url-pattern>
    <dispatcher>REQUEST</dispatcher>
    <dispatcher>FORWARD</dispatcher>
  </filter-mapping>

```

- Put all changes into effect:


>  service tomcat5 restart
>  service httpd reload
>  service tomcat5 restart
>  service httpd reload

## Local Customization

- Make some clarifications to the text in `/var/lib/tomcat5/webapps/uApprove/WEB-INF/classes/attributes_en.properties`

``` 

--- attributes_en.properties.dist       2009-06-03 12:49:06.000000000 +1200
+++ attributes_en.properties    2009-06-05 11:11:02.000000000 +1200
@@ -5,9 +5,9 @@
 title = <br>
 
-txt_explanation =  This is the Digital ID Card to be sent to '?':
+txt_explanation = To use '?' their system needs to receive some information about you in the form of a Digital ID Card.  You will need to agree to send the following information to access their services.  All this information is needed or service will not be granted.
 
 txt_cross_boxes = <br>
 
-txt_agree_global_arp = Don't show me this page again. I agree that my Digital ID Card (possibly including more data than shown above) will be sent automatically in the future.
+txt_agree_global_arp = Don't show me this page again. I agree that my Digital ID Card (possibly including more data than shown above) will be sent automatically in the future to this site as well as to other services I will access.
 
 

```

- Restart Tomcat again to reload the modified properties file.


>  service tomcat5 restart
>  service tomcat5 restart

# Final touch

- Set permissions right: critical files in the Shibboleth directories need to be owned by tomcat:

``` 

cd /usr/local/shibboleth-idp
chown -R tomcat:tomcat logs metadata credentials conf

```

- Start MySQL, Tomcat, and Apache

``` 

service mysqld start
service tomcat5 start
service httpd restart

```

- Make sure Tomcat, MySQL, and Apache start automatically

``` 

chkconfig httpd on
chkconfig tomcat5 on
chkconfig mysqld on

```

- Make sure Tomcat starts even at level 3


>  chkconfig --level 3 tomcat5 on
>  chkconfig --level 3 tomcat5 on

- Register the IdP in the AAF and BeSTGRID Federation
	
- AAF Federation: Register the IdP in the [AAF Resource Registry](http://www.federation.org.au/)
- BeSTGRID Federation: add the metadata (as published in AAF metadata) manually to `wayf.bestgrid.org:/var/www/html/metadata/bestgrid-metadata.xml`

# Testing

Useful commands for testing attribute query:

- Query LDAP attributes:


>  ldapsearch -LLL -x -h acs1.lincoln.ac.nz -b dc=lincoln,dc=ac,dc=nz -D *LDAP-BIND-DN* -w *LDAP-PASSWORD* cn=*USERCODE*
>  ldapsearch -LLL -x -h acs1.lincoln.ac.nz -b dc=lincoln,dc=ac,dc=nz -D *LDAP-BIND-DN* -w *LDAP-PASSWORD* cn=*USERCODE*

- Test Shibboleth Attribute Resolver:

``` 
/usr/local/shibboleth-idp/bin/aacli.sh --principal bootr2 --configDir /usr/local/shibboleth-idp/conf/ --saml1 --requester https://wiki.canterbury.ac.nz/shibboleth --issuer https://idp.lincoln.ac.nz/idp/shibboleth
```
- ***Note**: the command line resolver is evaluating all attribute-filter `AttributeRequesterInEntityGroup` conditions to false: hence, it will return a blank attribute statement if only relying on the downloaded AAF attribute-filter (where each entry is conditional both on the requester entityID and on a Group condition for the federation.  Create a custom policy in the local `attribute-filter.xml` file to get any results with the command-line resolver.

# Server overview

A quick summary of important features and file locations.

## Software installed and notable features

- Shibboleth IdP 2.1.5
- uApprove 2.1.3
- Tomcat 5.5(.23)
- MySQL 5.0(.77)

- Apache runs in front of Tomcat and handles user authentication
- Shibboleth IdP and uApprove both run inside Tomcat and use MySQL
- Shibboleth uses a self-signed certificate (valid for 20 years) for signing assertions and for Shibboleth back-channel communication.

- SharedToken values are stored in MySQL table idp_db.tb_st
- uApprove approvals are stored in MySQL database uApprove

- IdP is automatically reloading attribute filter policy from AAF RR
- IdP is automatically reloading key configuration files: namely attribute-resolver.xml and attribute-filter.xml

## File locations

Shibboleth IdP is installed in `/usr/local/shibboleth-idp`.  The following directories are notable there:

- configuration is in the `conf` directory
- IdP local metadata and cached federation metadata are in the `metadata` directory
- IdP backchannel certificate and key are in `credentials` directory.
- IdP is logging to `/usr/local/shibboleth-idp/logs/idp-process.log`
- The uApprove web application is logging to `/usr/local/shibboleth-idp/logs/uApprove.log`

- The Shibboleth IdP and uApprove web applications are installed in `/var/lib/tomcat5/webapps`
- The Apache front-channel certificate and private key are in `/etc/pki/tls/certs/idp.crt` and `/etc/pki/tls/private/idp.key`

- MySQL databases are stored in `/var/lib/mysql`

The old Shibboleth 1.3 installation with all relevant files is backed up in `/root/backup/shibboleth-1.3`

All passwords are in `/root/passwords.txt`.

## Maintenance

- Backup the above file locations
- Replace the front-channel certificate before it expires on 19th April 2011.
