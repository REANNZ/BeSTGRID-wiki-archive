# Installing Shibboleth 2.1 IdP at University of Canterbury

This page documents the installation of the Shibboleth 2.1 IdP at the University of Canterbury.  The installation is based on documentation from several sources:

- [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2)
- [https://manager.test.aaf.edu.au/wiki/display/IDP/Installing+the+Shibboleth+IdP](https://manager.test.aaf.edu.au/wiki/display/IDP/Installing+the+Shibboleth+IdP)
- [https://spaces.internet2.edu/display/SHIB2/IdPInstall](https://spaces.internet2.edu/display/SHIB2/IdPInstall)

The installation was done as a minimal install to get Shibboleth going - and worked well and is now being used in production.

The installation was followed by [installing uApprove](/wiki/spaces/BeSTGRID/pages/3816950723).

# Preliminary considerations

- Which version: Shibboleth 2.1 (latest)
- Which entityId format to use: for now, let us stick with URN-based, otherwise, the MAMS Federation Manager would set my Scope to the hostname.

# Basic Install

Install a basic CentOS 5.3 system.

## Firewall

- Edit /etc/sysconfig/iptables and add rules to permit incoming traffic to ports 80, 443, and 8443: add the following just below the rule for port 22:


>  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
>  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
>  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
>  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
>  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
>  -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT

- And activate the configuration:


>  service iptables restart
>  service iptables restart

## Disable network zero-configuration

- Edit `/etc/sysconfig/network` and add 

``` 
NOZEROCONF=yes
```

## Disable SELinux

Other services running on this host (SpendVision SSO) do not work with SELinux.

- Disable SELinux now: 

``` 
echo 0 > /selinux/enforce
```
- And for future restarts:  Edit `/etc/sysconfig/selinux` and change: 

``` 
SELINUX=permissive
```

## Packages

- Packages we need to get the system going and for management and likely debugging.


>  yum install httpd mod_ssl tomcat5 openldap-clients wireshark-gnome mc strace subversion
>  yum install httpd mod_ssl tomcat5 openldap-clients wireshark-gnome mc strace subversion

## Configure Java

OpenJDK got installed as a package when installing Tomcat.  Create `/etc/profile.d/java.sh` with

>  JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk
>  export JAVA_HOME

# Shibboleth IdP

Follow:

- [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2)
- [https://manager.test.aaf.edu.au/wiki/display/IDP/Installing+the+Shibboleth+IdP](https://manager.test.aaf.edu.au/wiki/display/IDP/Installing+the+Shibboleth+IdP)
- [https://spaces.internet2.edu/display/SHIB2/IdPInstall](https://spaces.internet2.edu/display/SHIB2/IdPInstall)

## Basic Shibboleth IdP Installation

- Download & unpack


>  mkdir /root/inst
>  cd /root/inst
>  wget [http://shibboleth.internet2.edu/downloads/shibboleth/idp/latest/shibboleth-identityprovider-2.1.2-bin.tar.gz](http://shibboleth.internet2.edu/downloads/shibboleth/idp/latest/shibboleth-identityprovider-2.1.2-bin.tar.gz)
>  tar xvzf shibboleth-identityprovider-2.1.2-bin.tar.gz
>  mkdir /root/inst
>  cd /root/inst
>  wget [http://shibboleth.internet2.edu/downloads/shibboleth/idp/latest/shibboleth-identityprovider-2.1.2-bin.tar.gz](http://shibboleth.internet2.edu/downloads/shibboleth/idp/latest/shibboleth-identityprovider-2.1.2-bin.tar.gz)
>  tar xvzf shibboleth-identityprovider-2.1.2-bin.tar.gz

- Invoke installer

``` 
sh ./install.sh
```
- When prompted, give the following non-default answers

``` 

Location: non-default /usr/local/shibboleth-idp
FQDN: idp.canterbury.ac.nz
Keystore: changeit

```

- Endorsed XML libs

Remove `/var/lib/tomcat5/common/endorsed/*` ([xml-commons-apis](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=xml-commons-apis&linkCreation=true&fromPageId=3816950954).jar [jaxp_parser_impl](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=jaxp_parser_impl&linkCreation=true&fromPageId=3816950954).jar), symbolic links to `/usr/share/java/` and install all jars from `/root/inst/shibboleth-identityprovider-2.1.2/endorsed/` into `/var/lib/tomcat5/common/endorsed`

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

## Configure Apache

Configure Apache virtual hosts for ports 443 and 8443.  Follow [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2) for this.

- Create `/etc/httpd/conf.d/ports.conf` with


>  Listen 443
>  Listen 8443
>  Listen 443
>  Listen 8443

- Download `ssl.conf`, `idp.conf` and `idp8443.conf` from [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2)


>  for I in ssl.conf idp.conf idp8443.conf ; do wget "http://projects.arcs.org.au/trac/systems/attachment/wiki/HowTo/PilotAAF/InstallIdPShib2/${I}?format=raw" -O $I ; done
>  for I in ssl.conf idp.conf idp8443.conf ; do wget "http://projects.arcs.org.au/trac/systems/attachment/wiki/HowTo/PilotAAF/InstallIdPShib2/${I}?format=raw" -O $I ; done

- Configure files for hostname idp.canterbury.ac.nz

>  ***Important Note**: use `ServerName idp.yourdomain:``8443` in `idp8443.conf` - otherwise, Apache uses the certificates selected for virtual host 443 in both virtual hosts.

 ***Important Note**: Do NOT use the self-signed certificate generated by Shibboleth on the port 8443 virtual host - use the ipsCA front-end certificate itself.  The MAMS Federation Manager does not properly advertise the self-signed certificates and publishes it only for the IdPSSO definition - but not for the AttributeAuthority definition.  Using the self-signed certificate on the 8443 back-channel port would cause all attribute queries to fail.

>  ***Important Note**: If not using the custom ssl.conf as documented above, make sure your ssl.conf disables the SSL session cache - otherwise, the back-channel communication might unpredictably fail due to a known [OpenSSL bug, error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression](https://spaces.internet2.edu/display/SHIB2/NativeSPTroubleshootingCommonErrors#NativeSPTroubleshootingCommonErrors-error%3A1408F06B%3ASSLroutines%3ASSL3GETRECORD%3Abaddecompression).
>  SSLSessionCache         none

## Configure Shibboleth IdP

Configure the IdP in the `/usr/local/shibboleth-idp/conf/relying-party.xml`.  Use the file available at as an attachment at [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2) as an example - but do not just use it.  It has to be tailor-made specifically for your IdP, and the one generated by the Shibboleth IdP installer would be best starting point.  Proceed with the following modifications.

- Change `providerId` for *Anonymous* and *Default* Relying party
	
- In MAMS federation, use the URN-based format - like `urn:mace:federation.org.au:testfed:canterbury.ac.nz`

>  **Configure **`/usr/local/shibboleth-idp/metadata/idp-metadata.xml`** and make sure the**`Scope`* is set to correctly - such as to `canterbury.ac.nz`

- Load metadata for BeSTGRID and MAMS Level 1 and Level 2 federations and back them in `/usr/local/shibboleth-idp/metadata`:

``` 

        <!-- MAMS Level 2 metadata -->
        <MetadataProvider id="MAMS-L2" xsi:type="FileBackedHTTPMetadataProvider" xmlns="urn:mace:shibboleth:2.0:metadata"
                          metadataURL="https://www.federation.org.au/level-2/level-2-metadata.xml"
                          backingFile="/usr/local/shibboleth-idp/metadata/mams-level-2-metadata.xml">
          <MetadataFilter xsi:type="ChainingFilter" xmlns="urn:mace:shibboleth:2.0:metadata">
            <MetadataFilter xsi:type="SignatureValidation" xmlns="urn:mace:shibboleth:2.0:metadata"
                            trustEngineRef="shibboleth.MetadataTrustEngine"
                            requireSignedMetadata="true" />
          </MetadataFilter>
        </MetadataProvider>

        <!-- BeSTGRID Federation -->
        <MetadataProvider id="BeSTGRID" xsi:type="FileBackedHTTPMetadataProvider" xmlns="urn:mace:shibboleth:2.0:metadata"
                          metadataURL="https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml"
                          backingFile="/usr/local/shibboleth-idp/metadata/bestgrid-metadata.xml">
        </MetadataProvider>

        <!-- MAMS Level 1 metadata -->
        <MetadataProvider id="MAMS-L1" xsi:type="FileBackedHTTPMetadataProvider" xmlns="urn:mace:shibboleth:2.0:metadata"
                          metadataURL="https://www.federation.org.au/level-1/level-1-metadata.xml"
                          backingFile="/usr/local/shibboleth-idp/metadata/mams-level-1-metadata.xml">
          <MetadataFilter xsi:type="ChainingFilter" xmlns="urn:mace:shibboleth:2.0:metadata">
            <MetadataFilter xsi:type="SignatureValidation" xmlns="urn:mace:shibboleth:2.0:metadata"
                            trustEngineRef="shibboleth.MetadataTrustEngine"
                            requireSignedMetadata="true" />
          </MetadataFilter>
        </MetadataProvider>

```

- The MAMS metadata are verified with a trust engine: add the trust engine definition as well (or uncomment and configure it further down in the file):

``` 

    <!-- Trust engine used to evaluate the signature on loaded metadata. -->
    <security:TrustEngine id="shibboleth.MetadataTrustEngine" xsi:type="security:StaticExplicitKeySignature">
        <security:Credential id="MyFederation1Credentials" xsi:type="security:X509Filesystem">
            <security:Certificate>/usr/local/shibboleth-idp/credentials/www.federation.org.au.pem</security:Certificate>
        </security:Credential>
    </security:TrustEngine>

```

- This definition is referring to a certificate used to verify the signature - store the certificate in /usr/local/shibboleth-idp/credentials


>  cd /usr/local/shibboleth-idp/credentials
>  wget [http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/www.federation.org.au.pem](http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/www.federation.org.au.pem)
>  cd /usr/local/shibboleth-idp/credentials
>  wget [http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/www.federation.org.au.pem](http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/www.federation.org.au.pem)

- Note that the relying-party.xml file also refers to:
	
- Our own metadata generated for the IdP in `/usr/local/shibboleth-idp/metadata/idp-metadata.xml`
- Our own credentials stored in `/usr/local/shibboleth-idp/credentials/idp.{crt,key`}

- If using a different entityID than the one assigned by the installer - e.g., an URN-based one - configure the self-metadata in `/usr/local/shibboleth-idp/metadata/idp-metadata.xml` and change the entityID to the custom one

## Change Federation Registration

If upgrading from Shibboleth 1.3, change the federation metadata to point to new URLs where Shibboleth 2.x advertises the SAML1 profile:

- [https://idp.canterbury.ac.nz/idp/profile/Shibboleth/SSO](https://idp.canterbury.ac.nz/idp/profile/Shibboleth/SSO)
- [https://idp.canterbury.ac.nz:8443/idp/profile/SAML1/SOAP/AttributeQuery](https://idp.canterbury.ac.nz:8443/idp/profile/SAML1/SOAP/AttributeQuery)
- [https://idp.canterbury.ac.nz:8443/idp/profile/SAML1/SOAP/ArtifactResolution](https://idp.canterbury.ac.nz:8443/idp/profile/SAML1/SOAP/ArtifactResolution)

## Configure attribute resolver

Configure `/usr/local/shibboleth-idp/conf/attribute-resolver.xml`

- Uncomment and configure LDAP data connector
- Pull in basic LDAP attributes

## Prepare for launch

- Change ownership of critical files and directories to Tomcat (give Tomcat permission to read private key, write logs, etc.):


>  cd /usr/local/shibboleth-idp
>  chown -R tomcat:tomcat logs metadata credentials conf
>  cd /usr/local/shibboleth-idp
>  chown -R tomcat:tomcat logs metadata credentials conf

# Configuring Additional attributes

All attributes are defined in the resolver configuration file `/usr/local/shibboleth-idp/conf/attribute-resolver.xml`.

## Static attributes

- Define `organizationName` and `locality` ("o" and "l" attributes) via the staticAttributes connector.

- Uncomment and configure the staticAttributes connector

``` 

    <!-- Static Connector -->
    <resolver:DataConnector id="staticAttributes" xsi:type="Static" xmlns="urn:mace:shibboleth:2.0:resolver:dc">
        <Attribute id="o">
            <Value>University of Canterbury</Value>
        </Attribute>
        <Attribute id="l">
            <Value>NZ</Value>
        </Attribute>
    </resolver:DataConnector>

```

- Define the `organizationName` and `locality` using this connector:

``` 

    <!-- static attributes -->

    <resolver:AttributeDefinition id="locality" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="l">
        <resolver:Dependency ref="staticAttributes" />

        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:dir:attribute-def:l" />

        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:2.5.4.7" friendlyName="l" />
    </resolver:AttributeDefinition>

    <resolver:AttributeDefinition id="organizationName" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="o">
        <resolver:Dependency ref="staticAttributes" />

        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:dir:attribute-def:o" />

        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:2.5.4.10" friendlyName="o" />
    </resolver:AttributeDefinition>

```

## Shared Token

- Follow [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/SharedToken](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/SharedToken)


- Copy the JAR into /var/lib/tomcat5/webapps/idp/WEB-INF/lib and /usr/local/shibboleth-idp/lib
- Add schema definition to attribute-resolver.xml: add `urn:mace:arcs.org.au:shibboleth:2.0:resolver:dc classpath:/schema/arcs-shibext-dc.xsd` to the list of schema locations at the top of the file.
- Add connector definition to attribute-resolver.xml (sharedToken)

``` 

    <!-- ==================== auEduPersonSharedToken data connector ================== -->

    <resolver:DataConnector xsi:type="SharedToken" xmlns="urn:mace:arcs.org.au:shibboleth:2.0:resolver:dc"
                        id="sharedToken"
                        idpIdentifier="urn:mace:federation.org.au:testfed:canterbury.ac.nz"
                        sourceAttributeID="uid,mail"
                        salt="ThisIsRandomText">
        <resolver:Dependency ref="myLDAP" />
    </resolver:DataConnector>

```
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
- As needed, configure the attribute definition: do not store the value in LDAP and use only uid as the seed:

``` 

                        sourceAttributeID="uid"
                        storeLdap="false"

```
- Generate a suitable salt value with:


>  openssl rand -base64 36 
>  openssl rand -base64 36 

- Release attribute in attribute-filter.xml (auEduPersonSharedToken)
	
- See attribute release later.

**Important note**: this implementation won't accept a seed value smaller than 16 bytes (and perhaps uses a different method of calculating the sharedToken value), so it can't generate the same values as the Shib 1.3 implementation - especially if Shib 1.3 was using a salt value smaller then 16 bytes.

Note also that the SharedToken value depends on the IdP entityID - which could be picked up from the environment, but is better set in the configuration.

- To store the generated sharedToken value in a local MySQL: database
	
- Make sure you have IMAST implementation at least 1.5.0 (1.5.2 at the time of writing)
- Follow the instructions at [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/SharedToken#DatabaseSupport](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/SharedToken#DatabaseSupport)

- If not installed with uApprove yet, download the MySQL JDBC driver from [http://dev.mysql.com/downloads/connector/j/5.0.html](http://dev.mysql.com/downloads/connector/j/5.0.html)
	
- Install the driver (`mysql-connector-java-5.0.8-bin.jar`) into `/var/lib/tomcat5/webapps/idp/WEB-INF/lib` and also into `/usr/local/shibboleth-idp/lib`

- Create the database user and the database with the following MySQL commands:


>  CREATE DATABASE idp_db;
>  use idp_db;
>  CREATE DATABASE idp_db;
>  use idp_db;

>  CREATE TABLE tb_st (
>  uid VARCHAR(100) NOT NULL,
>  sharedToken VARCHAR(50),
>  PRIMARY KEY  (uid)
>  );

>  create user 'idp_admin'@'localhost' identified by 'idp_admin';
>  grant all privileges on **.** to 'idp_admin'@'localhost' with grant option;

- Configure a database connector as a sub-element of the SharedToken connector definition (past the `myLDAP` Dependency)


- Turn the Database support on by setting `storeDatabase` to `true` in the SharedToken connector definition:


>                          storeDatabase="true"
>                          storeDatabase="true"

## eduPersonAffiliation

The eduPerson affiliation attributes need to be defined with a script.  Shibboleth 2.x has moved from Java Bean-shell to ECMA script (JavaScript).  The usage is documented with convenient examples at [https://spaces.internet2.edu/display/SHIB2/ResolverScriptAttributeDefinition](https://spaces.internet2.edu/display/SHIB2/ResolverScriptAttributeDefinition)

In defining the attribute, we first:

- Expose the `ucdeptcode`, `uccourse`, and `ucstudentid` attributes from LDAP into Shibboleth (we need them available via Shibboleth anyway).

``` 

    <resolver:AttributeDefinition id="ucDeptCode" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="ucdeptcode">
        <resolver:Dependency ref="myLDAP" />

        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:canterbury.ac.nz:attribute:ucdeptcode" />
        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:canterbury.ac.nz:attribute:ucdeptcode" friendlyName="ucdeptcode" />
    </resolver:AttributeDefinition>

    <resolver:AttributeDefinition id="ucCourse" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="uccourse">
        <resolver:Dependency ref="myLDAP" />

        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:canterbury.ac.nz:attribute:uccourse" />
        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:canterbury.ac.nz:attribute:uccourse" friendlyName="uccourse" />
    </resolver:AttributeDefinition>

    <resolver:AttributeDefinition id="ucStudentId" xsi:type="Simple" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        sourceAttributeID="ucstudentid">
        <resolver:Dependency ref="myLDAP" />

        <resolver:AttributeEncoder xsi:type="SAML1String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:canterbury.ac.nz:attribute:ucstudentid" />
        <resolver:AttributeEncoder xsi:type="SAML2String" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:canterbury.ac.nz:attribute:ucstudentid" friendlyName="ucstudentid" />
    </resolver:AttributeDefinition>

```

- Now, define the eduPersonAffiliation attribute as a script depending on the `ucDeptcode` and `ucStudentId` attributes (we can use ucDeptCode and ucStudentId as variables inside the script):

``` 

    <resolver:AttributeDefinition id="eduPersonAffiliation" xsi:type="Script" xmlns="urn:mace:shibboleth:2.0:resolver:ad">
        <resolver:Dependency ref="ucDeptCode" />
        <resolver:Dependency ref="ucStudentId" />

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
                hasStudentId = false;
                if ( ucStudentId != null && ucStudentId.getValues().size()>0){
                    hasStudentId = true;
                }

                if ( ucDeptCode != null && ucDeptCode.getValues().size()>0){
                        value = ucDeptCode.getValues().get(0);
                        student = false;
                        staff = false;
                        affiliate = false;
                        alum = false;

                        if (value == "MISC") {
                           student = true;
                        } else {
                          if (value == "EXTI" || value == "EXTL") {
                              if (hasStudentId) {
                                  alum = true;
                              } else {
                                  affiliate = true;
                              };
                          } else {
                              staff = true;
                          }
                        }
      
                        if (student) { eduPersonAffiliation.getValues().add("student"); }
                        if (staff) { eduPersonAffiliation.getValues().add("staff"); }
                        if (alum) { eduPersonAffiliation.getValues().add("alum"); }
                        if (affiliate) { eduPersonAffiliation.getValues().add("affiliate"); }

                        // Staff and students are also members
                        if (staff || student){
                                eduPersonAffiliation.getValues().add("member");
                        }
                }
        ]]>
        </Script>
    </resolver:AttributeDefinition>

```

- Now defined the scoped affiliation based on this - see it depends on the previous attribute definition, not the LDAP connector

``` 

    <resolver:AttributeDefinition id="eduPersonScopedAffiliation" xsi:type="Scoped" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        scope="idp20test.canterbury.ac.nz" sourceAttributeID="eduPersonAffiliation">
        <resolver:Dependency ref="eduPersonAffiliation" />

        <resolver:AttributeEncoder xsi:type="SAML1ScopedString" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:dir:attribute-def:eduPersonScopedAffiliation" />

        <resolver:AttributeEncoder xsi:type="SAML2ScopedString" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:oid:1.3.6.1.4.1.5923.1.1.1.9" friendlyName="eduPersonScopedAffiliation" />
    </resolver:AttributeDefinition>

```

- And the primary affiliation as a variation of the script, producing just a single value:

``` 

    <resolver:AttributeDefinition id="eduPersonPrimaryAffiliation" xsi:type="Script" xmlns="urn:mace:shibboleth:2.0:resolver:ad">
        <resolver:Dependency ref="ucDeptCode" />
        <resolver:Dependency ref="ucStudentId" />

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
                hasStudentId = false;
                if ( ucStudentId != null && ucStudentId.getValues().size()>0){
                    hasStudentId = true;
                }

                if ( ucDeptCode != null && ucDeptCode.getValues().size()>0){
                        value = ucDeptCode.getValues().get(0);
                        student = false;
                        staff = false;
                        affiliate = false;
                        alum = false;

                        if (value == "MISC") {
                           student = true;
                        } else {
                          if (value == "EXTI" || value == "EXTL") {
                              if (hasStudentId) {
                                  alum = true;
                              } else {
                                  affiliate = true;
                              };
                          } else {
                              staff = true;
                          }
                        }

                        if (staff){
                                eduPersonPrimaryAffiliation.getValues().add("staff");
                        } else if (student){
                                eduPersonPrimaryAffiliation.getValues().add("student");
                        } else if (alum){
                                eduPersonPrimaryAffiliation.getValues().add("alum");
                        } else if (affiliate){
                                eduPersonPrimaryAffiliation.getValues().add("affiliate");
                        }
                }
                
        ]]>
        </Script>
    </resolver:AttributeDefinition>

```

## eduPersonTargetedID

After reading [https://spaces.internet2.edu/display/SHIB2/NativeSPTargetedID](https://spaces.internet2.edu/display/SHIB2/NativeSPTargetedID), I have uncommented the old and new definition of eduPersonTargetedID:

``` 

    <resolver:AttributeDefinition id="eduPersonTargetedID.old" xsi:type="Scoped" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        scope="example.org" sourceAttributeID="computedID">
        <resolver:Dependency ref="computedID" />

        <resolver:AttributeEncoder xsi:type="SAML1ScopedString" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
            name="urn:mace:dir:attribute-def:eduPersonTargetedID" />
    </resolver:AttributeDefinition>

    <resolver:AttributeDefinition id="eduPersonTargetedID" xsi:type="SAML2NameID" xmlns="urn:mace:shibboleth:2.0:resolver:ad"
        nameIdFormat="urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
        sourceAttributeID="computedID">
        <resolver:Dependency ref="computedID" />

        <resolver:AttributeEncoder xsi:type="SAML1XMLObject" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
                name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10" />

        <resolver:AttributeEncoder xsi:type="SAML2XMLObject" xmlns="urn:mace:shibboleth:2.0:attribute:encoder"
                name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10" friendlyName="eduPersonTargetedID" />
    </resolver:AttributeDefinition>

```

And also uncommented and configured the `computedID` connector definition:

``` 

    <resolver:DataConnector xsi:type="ComputedId" xmlns="urn:mace:shibboleth:2.0:resolver:dc"
                            id="computedID"
                            generatedAttributeID="computedID"
                            <b>sourceAttributeID="uid"</b>
                            <b>salt="<em>abcef123YOURVALUE</em>"></b>
        <resolver:Dependency ref="myLDAP" />
    </resolver:DataConnector>

```

- Using just `uid` as the source attribute.
- Using a value of salt generated with 

``` 
openssl rand -base64 36
```

# Attribute Release Policy configuration

- Attribute release is configured in `/usr/local/shibboleth-idp/conf/attribute-filter.xml`
- The file can contain multiple policies.
- Each policy can apply to a number of hosts or hostgroups (federations) - linked with the `basic:OR` policy.
- Attributes are refered to by the "friendly" ID they get assigned in `attribute-resolver.xml`.

- I have configured the following policy that releases the basic information to all hosts in the federation:

``` 

    <AttributeFilterPolicy id="federationPolicy" >
        <PolicyRequirementRule xsi:type="basic:OR">
            <basic:Rule xsi:type="saml:AttributeRequesterInEntityGroup" groupID="urn:mace:federation.org.au:testfed:level-1" />
            <basic:Rule xsi:type="saml:AttributeRequesterInEntityGroup" groupID="urn:mace:federation.org.au:testfed:level-2" />
            <basic:Rule xsi:type="saml:AttributeRequesterInEntityGroup" groupID="urn:mace:bestgrid.org" />
        </PolicyRequirementRule>

        <AttributeRule attributeID="displayName">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="commonName">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="surname">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="givenName">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="email">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="eduPersonPrincipalName">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="eduPersonScopedAffiliation">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="eduPersonAffiliation">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="eduPersonPrimaryAffiliation">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>

    </AttributeFilterPolicy>

```

- And then created more refined policies for hosts that need additional attributes.

- ARCS hosts requiring auSharedToken, locality, organizationName:

``` 

    <AttributeFilterPolicy id="slcsARCSPolicy" >
        <PolicyRequirementRule xsi:type="basic:OR">
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="https://slcs1.arcs.org.au/shibboleth" />
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="https://nagios.arcs.org.au/shibboleth" />
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="https://services.arcs.org.au/shibboleth" />
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="urn:mace:federation.org.au:testfed:test.arcs.org.au" />
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="https://slcstest.arcs.org.au/shibboleth" />
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="https://plonedev.arcs.org.au/shibboleth" />
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="https://ng2dev.canterbury.ac.nz/shibboleth" />
        </PolicyRequirementRule>

        <AttributeRule attributeID="commonName">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="email">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="locality">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="organizationName">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="auEduPersonSharedToken">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
    </AttributeFilterPolicy>

```

- Local wiki systems require also the local UoC-specific attributes:

``` 

    <AttributeFilterPolicy id="wikiLocalPolicy" >
        <PolicyRequirementRule xsi:type="basic:OR">
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="urn:mace:federation.org.au:testfed:wiki.canterbury.ac.nz" />
            <basic:Rule xsi:type="basic:AttributeRequesterString" value="urn:mace:federation.org.au:testfed:wikitest.canterbury.ac.nz" />
        </PolicyRequirementRule>
        <AttributeRule attributeID="ucDeptCode">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="ucCourse">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
    </AttributeFilterPolicy>

```

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

# Testing and tuning

- Test attribute release with:


>  ./aacli.sh --principal vme28 --configDir /usr/local/shibboleth-idp/conf/
>  ./aacli.sh --principal vme28 --configDir /usr/local/shibboleth-idp/conf/

- or for saml1 syntax:


>  ./aacli.sh --principal vme28 --configDir /usr/local/shibboleth-idp/conf/ --saml1
>  ./aacli.sh --principal vme28 --configDir /usr/local/shibboleth-idp/conf/ --saml1



# Final pre-production check-list

- Make sure Apache and Tomcat always start

>  chkconfig httpd on
>  chkconfig tomcat5 on

- Check that filter policy is not too permissive
- Make sure critical files (credentials, metadata and log directories) are owned by the `tomcat` user.
- Change registration URLs in all federations.
- Change registration URLs explicitly configured at selected SPs (Confluence wiki test+production, E-Cast)
- Until these changes propagate, use `ProxyPass` to pass the old shib13 URLs to Shib21

- Proceed with [installing uApprove](/wiki/spaces/BeSTGRID/pages/3816950723)

# Registering the IdP in the AAF Pilot Resource Registry

The AAF Pilot Resource Registry (RR) is using Shibboleth to login ... and to register your IdP, there's also a bootstrap form.

What you need to know in advance:

- Your Shihboleth SSO and AA URLs.
- Your entityID (or pick your own)
- Your self-signed certificate (is using one)
- Your security domain name.

Fill in these into the [bootstrap form](https://manager.test.aaf.edu.au/rr/bootstrap_homeorg.php) and configure the IdP in the following way:

## Pull in AAF metadata

- Download the signing certificate and store it as `/usr/local/shibboleth-idp/credentials/aaf-metadata-cert.pem`


>  cd /usr/local/shibboleth-idp/credentials/
>  wget [https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem](https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem) -O aaf-metadata-cert.pem
>  cd /usr/local/shibboleth-idp/credentials/
>  wget [https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem](https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem) -O aaf-metadata-cert.pem

- Configure the default trust engine with multiple Credentials, each with single Certificate:

``` 

     <!-- Trust engine used to evaluate the signature on loaded metadata. -->
     <security:TrustEngine id="shibboleth.MetadataTrustEngine" xsi:type="security:StaticExplicitKeySignature">
         <security:Credential id="MyFederation1Credentials-MAMS" xsi:type="security:X509Filesystem">
             <security:Certificate>/usr/local/shibboleth-idp/credentials/www.federation.org.au.pem</security:Certificate>
         </security:Credential>
         <security:Credential id="MyFederation1Credentials-AAF" xsi:type="security:X509Filesystem">
             <security:Certificate>/usr/local/shibboleth-idp/credentials/aaf-metadata-cert.pem</security:Certificate>
         </security:Credential>
     </security:TrustEngine>

```

- Fetch the AAF metadata with signature checking:

``` 

        <!-- AAF Pilot Federation metadata -->
        <MetadataProvider id="AAF-Pilot" xsi:type="FileBackedHTTPMetadataProvider" xmlns="urn:mace:shibboleth:2.0:metadata"
                          metadataURL="http://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml"
                          backingFile="/usr/local/shibboleth-idp/metadata/aaf-pilot-metadata.xml">
          <MetadataFilter xsi:type="ChainingFilter" xmlns="urn:mace:shibboleth:2.0:metadata">
            <MetadataFilter xsi:type="SignatureValidation" xmlns="urn:mace:shibboleth:2.0:metadata"
                            trustEngineRef="shibboleth.MetadataTrustEngine"
                            requireSignedMetadata="true" />
          </MetadataFilter>
        </MetadataProvider>

```

## Configure a Relying party

If using a different entityID in the AAF Pilot federation than what's the default entityID for this provider, configure a specific RelyingParty element for the AAF.

Copy the `DefaultRelyingParty` element and store it as `RelyingParty`, with the two additional attributes: **id** (the name of the AAF federation group) and **provider** - your entityID within this federation.

``` 

    <RelyingParty <b>id="urn:mace:aaf.edu.au:AAFProduction" provider="https://idp.canterbury.ac.nz/idp/shibboleth"</b>
                         defaultSigningCredentialRef="IdPCredential">
    ....
    </RelyingParty>

```

## Define home organization attributes

Define two new static attributes needed by the Resource Registry: homeOrg ("canterbury.ac.nz") and homeOrgType ("urn:mace:terena.org:schac:homeOrganizationType:nz:university").

- The following goes into the `staticAttributes` connector:

``` 

        <Attribute id="homeOrg">
            <Value>canterbury.ac.nz</Value>
        </Attribute>
        <Attribute id="homeOrgType">
            <Value>urn:mace:terena.org:schac:homeOrganizationType:nz:university</Value>
        </Attribute>

```
- And this defines the actual attributes:

``` 

    <!-- two static attributes needed for the resource registry -->

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

## Configure Attribute Release

Release the new attributes and eduPersonTargetedID to the whole federation:

``` 

    <!-- release homeOrg and homeOrgType within the AAF -->
    <AttributeFilterPolicy id="AAFhomeOrgPolicy" >
        <PolicyRequirementRule xsi:type="saml:AttributeRequesterInEntityGroup" groupID="urn:mace:aaf.edu.au:AAFProduction" />
 
        <AttributeRule attributeID="homeOrg">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="homeOrgType">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
        <AttributeRule attributeID="eduPersonTargetedID">
            <PermitValueRule xsi:type="basic:ANY" />
        </AttributeRule>
    </AttributeFilterPolicy>

```

and add the group also to the default policy releasing other attributes (givenName, surname, email address, affiliation):

``` 

    <AttributeFilterPolicy id="federationPolicy" >
        <PolicyRequirementRule xsi:type="basic:OR">
            <basic:Rule xsi:type="saml:AttributeRequesterInEntityGroup" groupID="urn:mace:federation.org.au:testfed:level-1" />
            <basic:Rule xsi:type="saml:AttributeRequesterInEntityGroup" groupID="urn:mace:federation.org.au:testfed:level-2" />
            <basic:Rule xsi:type="saml:AttributeRequesterInEntityGroup" groupID="urn:mace:bestgrid.org" />
            <b><basic:Rule xsi:type="saml:AttributeRequesterInEntityGroup" groupID="urn:mace:aaf.edu.au:AAFProduction" /></b>
        </PolicyRequirementRule>
        ....
    </AttributeFilterPolicy>

```

Finally, restart tomcat

>  service tomcat5 restart
