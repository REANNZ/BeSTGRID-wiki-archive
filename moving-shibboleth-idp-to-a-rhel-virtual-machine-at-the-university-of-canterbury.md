# Moving Shibboleth IdP to a RHEL virtual machine at the University of Canterbury

This page documents how the University of Canterbury Shibboleth IdP was moved from a CentOS based system (a blade) to a new RHEL based system (a VMware virtual machine).  The process involved reinstalling the IdP from scratch - reusing configuration files from the IdP.  This page documents what were all the necessary steps on the new IdP - including all configuration done there.

# Preliminary installation steps

- Get a RHN account (Bill Rea) and register with


>  rhn-register
>  rhn-register

- Update the system


>  yum update
>  yum update

- Install necessary packages (utilities, and what would be needed to compile & install Shibboleth-SP)


>  yum install ntp mc openldap-servers openldap-clients gcc gcc-c++ compat-gcc-34 compat-gcc-34-c++ curl-devel httpd-devel httpd
>  yum install kernel-devel tomcat5
>  yum install ntp mc openldap-servers openldap-clients gcc gcc-c++ compat-gcc-34 compat-gcc-34-c++ curl-devel httpd-devel httpd
>  yum install kernel-devel tomcat5



# Archiving old configuration

- Archive everything relevant on the old IdP with tar and copy the tarball (`idp-move.tar`) to the new IdP:


>  /etc/httpd/conf.d
>  /etc/certs
>  /etc/cron.hourly
>  /usr/local/shibboleth-* # autograph, idp, idp-backup
>  /var/lib/tomcat5/common/endorsed
>  /var/lib/tomcat5/webapps
>  /root # bin,cert,inst,work
>  /etc/profile.d # java.sh, shib.sh
>  /etc/httpd/conf.d
>  /etc/certs
>  /etc/cron.hourly
>  /usr/local/shibboleth-* # autograph, idp, idp-backup
>  /var/lib/tomcat5/common/endorsed
>  /var/lib/tomcat5/webapps
>  /root # bin,cert,inst,work
>  /etc/profile.d # java.sh, shib.sh

 tar cf idp-move.tar /etc/httpd/conf.d/ /etc/certs/ /etc/cron.hourly/ /usr/local/shibboleth-* /var/lib/tomcat5/common/endorsed* /var/lib/tomcat5/webapps/ /root/{bin,cert,inst,work} /etc/profile.d/

- Hmmm... better recompile Shibboleth, idp had just version 1.3.2, we should use 1.3.3 available now.

# Network address considerations

- For testing, use already the target hostname `idp.canterbury.ac.nz` - and add that to /etc/hosts

``` 
132.181.39.162 idp.canterbury.ac.nz
```
- But keep DHCP registration as "ucidp": `/etc/sysconfig/network-scripts/ifcfg-eth0` contains

``` 
DHCP_HOSTNAME=ucidp
```

# Shibboleth 1.3.3 installation

- Start installing Shibboleth 1.3.3 following [MAMS recipe](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallIdP) - and reuse existing stuff where applicable. Install new Autograph.

- Create environment file: `/etc/profile.d/shib.sh`:


>  export SHIB_HOME=/usr/local/shibboleth-idp
>  export SHIB_SP_HOME=/usr/local/shibboleth-sp
>  export SHIB_HOME=/usr/local/shibboleth-idp
>  export SHIB_SP_HOME=/usr/local/shibboleth-sp

- Create environment file: `/etc/profile.d/java.sh`:


>  export JAVA_HOME=/usr/java/latest
>  export JAVA_HOME=/usr/java/latest

- Update tomcat endorsed jars: `resolver.jar xalan.jar xercesImpl.jar xml-apis.jar`
	
- remove [jaxp_parser_impl](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=jaxp_parser_impl&linkCreation=true&fromPageId=3816950544)`.jar` and [xml-commons-apis](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=xml-commons-apis&linkCreation=true&fromPageId=3816950544)`.jar` (symlinks to /usr/share/java)
- copy shibboleth-1.3.3/endorsed into /var/lib/tomcat5/common/endorsed

- Install Shibboleht-idp: run


>    cd ~/work/shibboleth-1.3.3-install
>    ./ant
>    => all defaults, enter /var/lib/tomcat5 as Tomcat directory.
>    cd ~/work/shibboleth-1.3.3-install
>    ./ant
>    => all defaults, enter /var/lib/tomcat5 as Tomcat directory.

- Stop here and start installing ShARPE, following [MAMS ShARPE recipe](http://www.federation.org.au/twiki/bin/view/Federation/ShARPEInstall)

# Installing ShARPE

- Modify Shib-Idp `build.xml` and `custom/extensions-build.xml` javac language version from 1.4 to 1.5
- Invoke Ant - following the discussion at my ShARPE install page, the magic command is:


>  cd ~/work/ShARPE/
>  /root/work/apache-ant-1.7.1/bin/ant --noconfig -Dshib.src=/root/work/shibboleth-1.3.3-install
>  cd ~/work/ShARPE/
>  /root/work/apache-ant-1.7.1/bin/ant --noconfig -Dshib.src=/root/work/shibboleth-1.3.3-install

- Answer "y" to Attribute Mapping (and I believe it's ignored)
- Again enter `/var/lib/tomcat5` as Tomcat home directory.

# Back to IdP installation

- Now back to IdP installation: certificates: Copy `/etc/certs` from old IdP:
	
- aa-{cert,key}.pem - backend certificate
- host-{cert,key}.pem - front-end certificate
- **CA/** - certification authorities
	
- metadata - certificiates for metadata verification

- Enable SSL in Apache
	
- Install Apache SSL module

``` 
yum install mod_ssl
```
- Copy `/etc/httpd/conf.d/ssl.conf` over from old IdP.
- Listens at port 8443, leaves ssl engine initialization up to VirtualHosts

- Enable SSL virtual hosts
	
- Copy /etc/httpd/conf.d/shib-vhosts.conf over from old IdP
- Change IP address in VirtualHost definition from 132.181.2.17 (idp) to 132.181.39.42 (ucidp)

>  **Connect Apache to Tomcat AJP connector for /shibboleth-idp/**

- 
- Using the [ModProxy MAMS recipe](http://www.federation.org.au/twiki/bin/view/Federation/ModProxy)
- Passing also ShARPE URLs
- Add the following to /etc/httpd/conf.d/proxy_ajp.conf

``` 

ProxyRequests Off
<Proxy *>
  Order deny,allow
  Allow from all
</Proxy>
ProxyPass /shibboleth-idp ajp://localhost:8009/shibboleth-idp
ProxyPass /jsp-examples ajp://localhost:8009/jsp-examples
ProxyPass /ShARPE ajp://localhost:8009/ShARPE
ProxyPass /Autograph ajp://localhost:8009/Autograph
ProxyPass /SPDescription ajp://localhost:8009/SPDescription

```

- Check Tomcat AJP configuration in `/etc/tomcat5/server.xml` - add the `authentication="false"` parameters to the 8009 Connector definition

``` 

 <Connector port="8009" 
  <b>request.tomcatAuthentication="false" tomcatAuthentication="false"</b>
  enableLookups="false" redirectPort="8443" protocol="AJP/1.3" />

```

# Metadata updates

- Setup metadata updates: copy the update scripts from the old IdP into /etc/cron.hourly - `idp-metadata` and `idp-bestgrid-metadata`

# Configuring the IdP

- Configure idp.xml: copy /usr/local/shibboleth-idp/etc/idp.xml over from old IdP
- Base idp.xml has not changed in shibboleth-1.3.3
- The idp.xml file copied over includes:
	
- idp hostname/entityId
- ShARPE ARP engine
- certificate locations
- metadata locations for Level2 and BeSTGRID

- No additional changes should be needed for ShARPE:
	
- idp.xml already uses the MAMSFileSystemArpRepository for ReleasePolicyEngine
- proxy_ajp.conf already maps ShARPE, SPDescription, and Autograph

- Configure LDAP resolver: copy /usr/local/shibboleth-idp/etc/resolver.ldap over from old IdP

- Configure ARP: copy over the "blank" /usr/local/shibboleth-idp/etc/arps/arp.site.xml from old IdP

- Install Autograph - upload new Autograph.war into /var/lib/tomcat/webapps and let Tomcat explode it

- Change ownership of IdP files:


>  chown -R tomcat:tomcat /usr/local/shibboleth-idp/ 
>  chown -R tomcat:tomcat /usr/local/shibboleth-idp/ 

- Start Tomcat, let it explode WARs


>  service tomcat5 start
>  service tomcat5 start

- Edit /etc/sysconfig/iptables and enable incoming ports 80,443,8443


>  service iptables reload
>  service iptables reload

- Make Apache and Tomcat automatically start


>  chkconfig httpd on
>  chkconfig tomcat5 on
>  chkconfig httpd on
>  chkconfig tomcat5 on

# Minor Configuration bits

## Configuring Admin Contact for Error Messages

When the IdP encounters an error and must display an error message, it would include the email address of the system administrator. This is configured by editing `/var/lib/tomcat5/webapps/shibboleth-idp/IdPError.jsp` (or `./webApplication/IdPError.jsp` in the source tree).

Replace the text root@localhost (and the corresponding link) with the correct address (Vladimir Mencl's).

# Installing Autograph

- Configure new Autograph


>  service tomcat5 stop
>  service tomcat5 stop

- No need to remove old `autograph-redirection-switch.jar` - it was never installed.
- Install new Autograph-SSO.jar into /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/lib (and make it owned by tomcat)
- Copy /var/lib/tomcat5/webapps/ShARPE/WEB-INF/lib/commons-codec-1.3.jar into /var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/commons-codec-1.3.jar to make the SHA Crosswalk function work
- Copy conf/crosswalkconfig.properties into /var/lib/tomcat5/webapps/Autograph/WEB-INF/classes to make crosswalk work.
- Would have to change ProtocolHandler in idp.xml from /SSO to /IdP - but that has been copied over with idp.xml

- For Autograph configuration, plan:
	
- Autograph homedir in /usr/local/shibboleth-autograph
- user profiles in /usr/local/shibboleth-autograph/userProfiles
- SPDs in /usr/local/shibboleth-autograph/SPDs

- Configure Autograph home:
	
- Move /var/lib/tomcat5/webapps/Autograph/WEB-INF/homeDir as /usr/local/shibboleth-autograph
- Edit /var/lib/tomcat5/webapps/Autograph/WEB-INF/web.xml
		
- Set AutographHome to /usr/local/shibboleth-autograph/
- Try DisplayAgreement = once (appears to work on idp-test)
- Set BlockOnNoService = false

- Copy over SPDs from old IdP (avcc.karen, dreamspark) into /usr/local/shibboleth-autograph/SPDs
- Leaving IAMConfiguration.xml and AttributeInfoPointData.xml intact (EPTID is already defined in the stock one)

- Copy over user profiles from old IdP into /usr/local/shibboleth-autograph/userProfiles

- Copy over user arps from old IdP into /usr/local/shibboleth-idp/etc/arps

- Include Autograph in SSO profile: edit webapps/shibboleth-idp/WEB-INF/web.xml
	
- context-param userProfileStorePath = /usr/local/shibboleth-autograph/userProfiles
- servlet AutographRedirectionSwitch
- servlet-mapping AutographRedirectionSwitch to /SSO
- Remap IdP servlet from /SSO to /IdP


## Configuring Autograph admin login


# Issues to look at

- EPTID maybe broken - looks like it's the same for all SPs


>  HashFunction hashing: vladimir.mencl@canterbury.ac.nzaRequesterCanterbury ID seednull = 0BzDqgp9J1sDXvXuxzFh9vmAZSw                                                         
>  HashFunction hashing: vladimir.mencl@canterbury.ac.nzaRequesterCanterbury ID seednull = 0BzDqgp9J1sDXvXuxzFh9vmAZSw                                                         

- ??? REQUEST_O_R ???? or will it just work when it's actually sent to a SP?
- OK: Works OK when passed to an SP in an assertion - but displays an incorrect value inside SP

- ResolverTest
	
- Copy over `/root/bin/resolvertest-appendcp` from old IdP.  Use with

``` 

# assume SHIB_HOME=/usr/local/shibboleth-idp
export IDP_HOME=$SHIB_HOME
export CLASSPATH=/var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/classes/
 
resolvertest-appendcp --idpXml=file://$SHIB_HOME/etc/idp.xml --user=vme28 --requester=urn:mace:federation.org.au:testfed:avcc.karen.net.nz --responder urn:mace:federation.org.au:testfed:canterbury.ac.nz

```

## Decompression Error

Sometimes, the SP SSL client fails with 

``` 
error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression
```

This issue is already known in the [Shibboleth Community](https://spaces.internet2.edu/display/SHIB2/NativeSPTroubleshootingCommonErrors#NativeSPTroubleshootingCommonErrors-error%3A1408F06B%3ASSLroutines%3ASSL3GETRECORD%3Abaddecompression) and [elsewhere](https://bugs.launchpad.net/ubuntu/+source/stunnel4/+bug/247343).

This is an OpenSSL bug, and a supposed remedy is to disable session caching.

While the Shibboleth project page has a fix to be implemented in the SP, it's only available in Shibboleth2.  For Shibboleth 1.3.x, the only way is to disable session caching in Apache: add the following to `/etc/httpd/conf.d/ssl.conf`:

>  SSLSessionCache         none

# Configuring additional attributes

## Country and Organization

- Country and Organization are already (statically) defined in Resolver.ldap.xml, but Country's not yet in Autograph: add the following to `AttributeInfoPointData.xml`

``` 

                <Attribute id="urn:mace:dir:attribute-def:c"  type="string">
                        <FriendlyName lang="en">country</FriendlyName>
                        <Description lang="en">no description</Description>
                </Attribute>

```

## Affiliation

- Affiliation
	
- Need to update Crosswalk IF function with the update I got from Hung in order for old crosswalk to work for students.
- Let's now try a proper Scriptlet for all the features I needed
- YES it works - the following scriptlet definition:

``` 

    <ScriptletAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonAffiliation">
        <AttributeDependency requires="urn:mace:canterbury:attribute:ucdeptcode"/>
        <AttributeDependency requires="urn:mace:canterbury:attribute:ucstudentid"/>
        <Scriptlet><![CDATA[
                 ResolverAttribute deptCodeAttr = dependencies.getAttributeResolution("urn:mace:canterbury:attribute:ucdeptcode");
                 ResolverAttribute studentIdAttr = dependencies.getAttributeResolution("urn:mace:canterbury:attribute:ucstudentid");
                 String deptCodeStr = null;
                 String studentIdStr = null;

                 if (deptCodeAttr != null) {
                     Iterator i = deptCodeAttr.getValues();
                     if (i.hasNext()) { deptCodeStr = (String)i.next(); };
                 };
                 if (studentIdAttr != null) {
                     Iterator i = studentIdAttr.getValues();
                     if (i.hasNext()) { studentIdStr = (String)i.next(); };
                 };

                 if (deptCodeStr == "MISC" ) {
                   resolverAttribute.addValue("student");
                   resolverAttribute.addValue("member");
                 } else 
                 if ( (deptCodeStr=="EXTI") || (deptCodeStr=="EXTL")) {
                     if (studentIdStr != null) {
                       resolverAttribute.addValue("alum");
                     } else {
                       resolverAttribute.addValue("affiliate");
                     };
                 } else
                 if ( deptCodeStr=="STAF") {
                     resolverAttribute.addValue("affiliate");
                 } else if ( deptCodeStr != null ) {
                    /* we have a non-null deptcode that is not any of the
                     * special ones, therefore the user is a regular staff
                     * member */
                     resolverAttribute.addValue("staff");
                     resolverAttribute.addValue("member");
                 };
               ]]></Scriptlet>
    </ScriptletAttributeDefinition>

```

Notes:

- I'm adding also a member attribute value for Staff & Students (ie, not alum/affiliate)
- I'm switching eduPersonScopedAffiliation to use smartScope="canterbury.ac.nz"

``` 

    <SimpleAttributeDefinition
        id="urn:mace:dir:attribute-def:eduPersonScopedAffiliation" smartScope="canterbury.ac.nz">
        <AttributeDependency requires="urn:mace:dir:attribute-def:eduPersonAffiliation"/>
    </SimpleAttributeDefinition>

```
- Add the same logic (without "member" and without scope) for primaryAffiliation

``` 

    <ScriptletAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonPrimaryAffiliation">
        <AttributeDependency requires="urn:mace:canterbury:attribute:ucdeptcode"/>
        <AttributeDependency requires="urn:mace:canterbury:attribute:ucstudentid"/>
        <Scriptlet><![CDATA[
                 ResolverAttribute deptCodeAttr = dependencies.getAttributeResolution("urn:mace:canterbury:attribute:ucdeptcode");
                 ResolverAttribute studentIdAttr = dependencies.getAttributeResolution("urn:mace:canterbury:attribute:ucstudentid");
                 String deptCodeStr = null;
                 String studentIdStr = null;

                 if (deptCodeAttr != null) {
                     Iterator i = deptCodeAttr.getValues();
                     if (i.hasNext()) { deptCodeStr = (String)i.next(); };
                 };
                 if (studentIdAttr != null) {
                     Iterator i = studentIdAttr.getValues();
                     if (i.hasNext()) { studentIdStr = (String)i.next(); };
                 };

                 if (deptCodeStr == "MISC" ) {
                   resolverAttribute.addValue("student");
                 } else 
                 if ( (deptCodeStr=="EXTI") || (deptCodeStr=="EXTL")) {
                     if (studentIdStr != null) {
                       resolverAttribute.addValue("alum");
                     } else {
                       resolverAttribute.addValue("affiliate");
                     };
                 } else
                 if ( deptCodeStr=="STAF") {
                     resolverAttribute.addValue("affiliate");
                 } else if ( deptCodeStr != null ) {
                    /* we have a non-null deptcode that is not any of the
                     * special ones, therefore the user is a regular staff
                     * member */
                     resolverAttribute.addValue("staff");
                 };
               ]]></Scriptlet>
    </ScriptletAttributeDefinition>

```

## Shared Token FAST: OBSOLETE

- Installing FAST
- Following [ARCS IdP documentation](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallIdP/IdP-Installation-CentOS5) and README inside [FAST-idp.zip](http://www.mams.org.au/downloads/FAST-idp.zip)
- Download FAST-idp


>  wget [http://www.mams.org.au/downloads/FAST-idp.zip](http://www.mams.org.au/downloads/FAST-idp.zip)
>  wget [http://www.mams.org.au/downloads/FAST-idp.zip](http://www.mams.org.au/downloads/FAST-idp.zip)

- Copy all jars into /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/lib/
	
- Note: commons-codec-1.3.jar already exists
- A few other jars exist in different versions:
- commons-logging-1.03.jar (old) vs. commons-logging-1.1.jar (new)
- xmlsec-20050514.jar (old) vs. xmlsec-1.3.0.jar (new)
- Keeping so far both.
- Add the attribute definition to `resolver.ldap.xml`
	
- If no attribute dependency is provided, FAST will use just IdP and user identification - but that is perfectly sufficient.


## SharedToken: IMAST

- Based on the recommendation from ARCS, I have decided to switch from FAST to IMAST:
	
- Avoiding a single point of failure (and possible future bottleneck).
- Avoiding the need to rely on the SharedToken service (which has dropped the database a few times in the past, triggering a change of the SharedToken value for all users)
- IMAST will better fit IdMS processes in the future.

I was following the [ARCS IMAST installation guidelines](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallIdP/IdP-Installation-CentOS5/IMAST-Installation):

- Get IMAST source code


>  svn co [https://projects.arcs.org.au/svn/systems/trunk/idp/imast](https://projects.arcs.org.au/svn/systems/trunk/idp/imast)
>  svn co [https://projects.arcs.org.au/svn/systems/trunk/idp/imast](https://projects.arcs.org.au/svn/systems/trunk/idp/imast)

- Fix a bug: the code was ignoring the IDP_IDENTIFIER setting (and as Autograph does not provide a `responder` value, the attribute would not resolve in Autograph)

``` 

Index: SharedTokenAttrDef.java
===================================================================
--- SharedTokenAttrDef.java	(revision 795)
+++ SharedTokenAttrDef.java	(working copy)
@@ -75,7 +75,7 @@
 
 				String userIdentifier = this.getPrivateUniqueID(attributes,
 						imastProperties);
-				String idpIdentifier = responder;
+				String idpIdentifier = imastProperties.getProperty("IDP_IDENTIFIER", responder);
 				String privateSeed = imastProperties
 						.getProperty("PRIVATE_SEED");
 

```

- Edit the configuration file (`conf/imast.properties`)

``` 

USER_IDENTIFIER=uid
#  uid is non-reassignable, so we can rely just on that
#  mail might change (in change of name), so let's not use it
IDP_IDENTIFIER=idp.canterbury.ac.nz
# entityId may change AAF moves to production - let's use just the hostname
PRIVATE_SEED=private_seed
WORK_MODE=PNP
# we so far don't store the value in LDAP

```

- Build IMAST


>  ant
>  ant

- Install arcs-imast-0.3.0.jar into `WEB-INF/lib` for `shibboleth-idp`, `Autograph`, and `ShARPE`

- Remove all files installed by FAST (see above)

- Add the attribute definition into `resolver.ldap.xml` (and remove the old FAST definition if still present)

``` 

    <CustomAttributeDefinition id="urn:mace:federation.org.au:attribute:auEduPersonSharedToken"
                               class="au.org.arcs.imast.SharedTokenAttrDef">
            <DataConnectorDependency requires="directory"/>
    </CustomAttributeDefinition>

```
- Define the attribute also for Autograph if not defined yet - add the following to `/usr/local/shibboleth-autograph/connectorConfigs/AttributeInfoPointData.xml`

``` 

                <Attribute id="urn:mace:federation.org.au:attribute:auEduPersonSharedToken"  type="string">
                        <FriendlyName lang="en">shared token</FriendlyName>
                        <Description lang="en">no description</Description>
                </Attribute>

```

- Restart IdP & Autograph


>  service tomcat5 restart
>  service tomcat5 restart

## UC specific attributes

Defining `ucdeptcode`, `ucstudentid`, and `uccourse` and making them available via Autograph:

`resolver.ldap.xml`

``` 

    <SimpleAttributeDefinition
        id="urn:mace:canterbury.ac.nz:attribute:ucdeptcode" sourceName="ucdeptcode">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition
        id="urn:mace:canterbury.ac.nz:attribute:ucstudentid" sourceName="ucstudentid">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition
        id="urn:mace:canterbury.ac.nz:attribute:uccourse" sourceName="uccourse">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>

```

`AttributeInfoPointData.xml`:

``` 

                <Attribute id="urn:mace:canterbury.ac.nz:attribute:ucdeptcode"  type="string">
                        <FriendlyName lang="en">UC Department code</FriendlyName>
                        <Description lang="en">no description</Description>
                </Attribute>

                <Attribute id="urn:mace:canterbury.ac.nz:attribute:uccourse"  type="string">
                        <FriendlyName lang="en">UC Course code</FriendlyName>
                        <Description lang="en">no description</Description>
                </Attribute>

                <Attribute id="urn:mace:canterbury.ac.nz:attribute:ucstudentid"  type="string">
                        <FriendlyName lang="en">UC Student ID</FriendlyName>
                        <Description lang="en">no description</Description>
                </Attribute>

```

# Configuring the IdP for SLCS service

## Configuring additional hosts

Because slcstest.arcs.org.au is only registered at Level 1, I had to manually add a mini-federation with the SLCS-test SP metadata:

- Add additional hosts into the federation (slcstest.arcs.org.au, registered only at Level 1)
- Create extra-metadata.xml - take level-1-metadata.xml and keep only
- **Testbed Federation Level 1 CA's*ds:KeyInfo**
	
- ``` 
<EntityDescriptor entityID="urn:mace:federation.org.au:testfed:vpac.org:slcstest.arcs.org.au">
```
- Change OrganizationDisplayName from "VPAC" to "VPAC SLCS server" to distinguish it in Autograph from other VPAC's entries.
- Include the file in idp.xml:


## Configure a direct SSO URL

Because the new version Autograph redirection servlet always redirects /Autograph/ConfigurationDecision and automated tools may not be able to handle the sequence of redirects, it may be necessary to point them to `/shibboleth-idp/IdP` (instead of `/shibboleth-idp/SSO`) - which goes straight to the IdP SSO login,  bypassing Autograph-related redirects.

The following configuration bits would define a new URL `/shibboleth-idp/SSODirect`, which would be functional equivalent to `/shibboleth-idp/IdP`.

**Do not** define the new SSODirect URL and instead just use `/shibboleth-idp/IdP`.

- Add a new ProtocolHandler for `/shibboleth-idp/SSODirect` in `idp.xml`:

``` 

     <ProtocolHandler implementation="edu.internet2.middleware.shibboleth.idp.provider.ShibbolethV1SSOHandler">
             <Location>https?://[^:/]+(:(443|80))?/shibboleth-idp/SSODirect</Location>
     </ProtocolHandler>

```
- And define a servlet mapping for the IdP servlet under this new URL in `/var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/web.xml`:

``` 

    <servlet-mapping>
        <servlet-name>IdP</servlet-name>
        <url-pattern>/SSODirect</url-pattern>
    </servlet-mapping>

```
- And protect this URL in  `/etc/httpd/conf.d/shib-vhosts.conf`

``` 

    <Location /shibboleth-idp/SSODirect>

```

- Finally, configure the SLCS client to use this new URL:
	
- edit `etc/glite-slcs-ui/slcs-metadata.aaf.xml` and change the SSO URL to `/shibboleth-idp/SSODirect` (twice).

- As said above, point the client just to `/shibboleth-idp/IdP`.

## Testing the SLCS service

- Access the service via [https://slcstest.arcs.org.au/SLCS/login](https://slcstest.arcs.org.au/SLCS/login)
- If the service is still in Level 1 federation and your IdP is in Level 2, go to the [Level 2 WAYF URL](https://level-2.federation.org.au/level-2-wayf/WAYF?shire=https%3A%2F%2Fslcstest.arcs.org.au%2FShibboleth.sso%2FSAML%2FArtifact&target=cookie&providerId=urn%3Amace%3Afederation.org.au%3Atestfed%3Avpac.org%3Aslcstest.arcs.org.au)

- To test the certificate, fetch the CA cert attached to [http://projects.arcs.org.au/trac/slcs-client/](http://projects.arcs.org.au/trac/slcs-client/)

- On my gateways:
	
- upload the CA certificate to ng2hpcdev and nggums
- On NGGUMS, configure Apache to send an empty list of CA names, so that the browser lets user pick from all certificates.

``` 

# VLADIMIR: We need Apache not to send any CA names at all - sending all of the
# trusted CAs would trigger a bug and Apache would lock up.  And sending only
# some of them would prevent users with certificates from other CAs from using
# their certificates - their browser would not offer that certificate.
# The safest thing to do is thus to send an empty list of CA names.
# And the only way to do that is to use the SSLCADNRequestPath directive
# pointing to an empty directory.  
# It is safe to assume /opt/vdt/apache/conf won't contain any certificates...
SSLCADNRequestPath /opt/vdt/apache/conf

```
- Alternatively, I could list the likely-to-be-used CAs in the `SSLCADNRequestFile` directive: create `/opt/vdt/apache/conf/extra/ssl-dn-list.pem` containing APACGrid + ARCS SLCS CA certificates.
- Upload the CA certificate also to gridgwtest - so that client globusrun-ws trusts the user cert when connecting to Globus services.

## Problems with the old IdP

- The SLCS server was failing with the old IdP with the following message - after successfully going through one Artifact resolution query.


>  2008-09-12 14:45:19 ERROR SAML.SAMLSOAPHTTPBinding [511](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=511&linkCreation=true&fromPageId=3816950544) sessionNew: failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression
>  2008-09-12 14:45:19 ERROR shibd.Listener [511](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=511&linkCreation=true&fromPageId=3816950544) sessionNew: caught exception while creating session: SOAPHTTPBindingProvider::send() failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression
>  2008-09-12 14:45:19 ERROR SAML.SAMLSOAPHTTPBinding [511](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=511&linkCreation=true&fromPageId=3816950544) sessionNew: failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression
>  2008-09-12 14:45:19 ERROR shibd.Listener [511](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=511&linkCreation=true&fromPageId=3816950544) sessionNew: caught exception while creating session: SOAPHTTPBindingProvider::send() failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression

- Wireshark shows the message to be "SSLv3 Alert: Decompression failure"
- This is documented as a known problem with decompression at [http://www.davidpashley.com/blog/debian/libssl-bad-decompression](http://www.davidpashley.com/blog/debian/libssl-bad-decompression)
- However, updating openssl to openssl-0.9.8b-8.3.el5_0.2 did not help.
- However, this works with the new IdP (RHEL based, openssl-0.9.8b-10.el5)

# Notes on testing

- I was getting no attributes at a remote SP: that is because the SP issues a query to the IdP's AA service, and it was ending on the wrong IdP.

- I had then still my query failing: that was because I used the IdP AA certificates for the test SP: that does not work, the AA certificates are marked as Server Only.
	
- Using the generic commercial front-end certificate for the test SP worked though...

- BeSTGRID federation metadata contained AVCC twice (for uc-avcc) and that confuses Autograph quite a lot.... two entries under the same name, each configures a different ARP - and another name configures of of these two ARPs.
	
- Fixed: old entry removed.

- Signing policy "once"  works, and redirection to Autograph works too

## Issues to report

Autograph:

- adminLogin does not work.
- SPDs are being ignored?
- Autograph uses cookie based state control

# Long-term TODO

- look at [TomcatAuthentication](http://www.federation.org.au/twiki/bin/viewauth/Federation/ProtectIdPTomcatAuthentication)

# Preparing switchover


