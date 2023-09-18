# Installing Lincoln University IdP

This page documents the installation of the Shibboleth Identity Provider (IdP) for the Lincoln University.  The installation has been done based on existing documentation (mostly provided by the [MAMS project](http://www.mams.org.au/)).  This documentation is created to pull all of this information together - and document how this particular system has been setup, to allow for reinstallation if necessary.

**OBSOLETE**: The Lincoln IdP has been upgraded to Shibboleth 2.x.  This page is now obsolete, see the [Installing Lincoln University Shibboleth 2.x IdP](installing-lincoln-university-shibboleth-2x-idp.md) page instead.

# Overview

The IdP installation consists of the following parts:

- Basic CentOS 5.3 installation on a VMware VM (not covered here)
- Preliminary system configuration (install packages, configure firewall, obtain X509 certificates)
- Install Shibboleth IdP software - as documented at [http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallIdP](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallIdP)
- Configure the IdP for use in the Level 2 federation - as documented at [http://www.federation.org.au/twiki/bin/view/Federation/HowToJoinLevel2](http://www.federation.org.au/twiki/bin/view/Federation/HowToJoinLevel2)
- Install [ShARPE](https://www.mams.org.au/confluence/display/SHA/ShARPE) - as documented at [https://www.mams.org.au/confluence/display/SHA/Installation](https://www.mams.org.au/confluence/display/SHA/Installation)

# Preliminaries

## Get front-channel certificate

- Create certificate request


>  openssl req -newkey rsa:2048 -nodes -out `hostname`-http-req.pem -keyout `hostname`-http-key.pem
>  openssl req -newkey rsa:2048 -nodes -out `hostname`-http-req.pem -keyout `hostname`-http-key.pem

- Process the request (done by Royston Boot via RapidSSL)

## Get AusCERT back-channel certificate

- Follow [http://www.federation.org.au/twiki/bin/view/Federation/HowToJoinLevel2](http://www.federation.org.au/twiki/bin/view/Federation/HowToJoinLevel2) and [http://esecurity.edu.au/how-to-obtain-a-certificate-under-the-aaf](http://esecurity.edu.au/how-to-obtain-a-certificate-under-the-aaf)


>  wget [http://esecurity.edu.au/docs/openssl_shiblvl3ca_certs.cnf](http://esecurity.edu.au/docs/openssl_shiblvl3ca_certs.cnf)
>  vi openssl_shiblvl3ca_certs.cnf # customize for Lincoln user
>  openssl req -new -config openssl_shiblvl3ca_certs.cnf -out `hostname`_esecurity.csr -keyout `hostname`_key.pem
>  wget [http://esecurity.edu.au/docs/openssl_shiblvl3ca_certs.cnf](http://esecurity.edu.au/docs/openssl_shiblvl3ca_certs.cnf)
>  vi openssl_shiblvl3ca_certs.cnf # customize for Lincoln user
>  openssl req -new -config openssl_shiblvl3ca_certs.cnf -out `hostname`_esecurity.csr -keyout `hostname`_key.pem

- Send request to pilot-level3-shibca@auscert.org.au

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

## Configure certificate symbolic links


- Later configure Apache to use these certificates in the virtual host definition.


- Install AusCERT CA bundle as /etc/certs/CA/caudit-ca-bundle.pem

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

# Installing Shibboleth IdP

## Configure SSL

- Save original Apache SSL configuration file:


>  cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig
>  cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig

- Make the following modifications to `/etc/httpd/conf.d/ssl.conf`:
	
- Listen on port 8443
- Disable SSL session cache (the cache is known to cause problems with Shibboleth)
- Use built-in SSLRandomSeed instead of /dev/urandom
- Do not start the SSL engine globally (leave it to individual virtual hosts)

``` 

diff /etc/httpd/conf.d/ssl.conf.orig /etc/httpd/conf.d/ssl.conf
18a19
> Listen 8443
43c44,45
< SSLSessionCache         shmcb:/var/cache/mod_ssl/scache(512000)
---
> ###SSLSessionCache         shmcb:/var/cache/mod_ssl/scache(512000)
> SSLSessionCache         none
61c63,64
< SSLRandomSeed startup file:/dev/urandom  256
---
> ###SSLRandomSeed startup file:/dev/urandom  256
> SSLRandomSeed startup builtin
95c98
< SSLEngine on
---
> ###SSLEngine on
112c115
< SSLCertificateFile /etc/pki/tls/certs/localhost.crt
---
> ###SSLCertificateFile /etc/pki/tls/certs/localhost.crt
119c122
< SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
---
> ###SSLCertificateKeyFile /etc/pki/tls/private/localhost.key

```

## Configure Apache virtual hosts

Create `/etc/httpd/conf.d/shib-vhosts.conf` based on the template in the [MAMS IdP Install guide](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallIdP) - and customize with:

- Local LDAP settings
- IP address
- Hostname
- Path to certificates

## Install Shibboleth IdP software

- Download Shibboleth IdP 1.3.3 tarball: [shibboleth-idp-1.3.3.tar.gz](http://www.federation.org.au/software/shibboleth-idp-1.3.3.tar.gz)


>  mkdir /root/inst
>  cd /root/inst
>  wget [http://www.federation.org.au/software/shibboleth-idp-1.3.3.tar.gz](http://www.federation.org.au/software/shibboleth-idp-1.3.3.tar.gz)
>  tar xzf shibboleth-idp-1.3.3.tar.gz
>  cd shibboleth-1.3.3-install/
>  export SHIB_INSTALL=`/bin/pwd`
>  mkdir /root/inst
>  cd /root/inst
>  wget [http://www.federation.org.au/software/shibboleth-idp-1.3.3.tar.gz](http://www.federation.org.au/software/shibboleth-idp-1.3.3.tar.gz)
>  tar xzf shibboleth-idp-1.3.3.tar.gz
>  cd shibboleth-1.3.3-install/
>  export SHIB_INSTALL=`/bin/pwd`

- Replace xerces and xalan in Tomcat lib directory with versions shipped with Shibboleth IdP:


>  rm /var/lib/tomcat5/common/endorsed/*
>  cp $SHIB_INSTALL/endorsed/*.jar /var/lib/tomcat5/common/endorsed/
>  rm /var/lib/tomcat5/common/endorsed/*
>  cp $SHIB_INSTALL/endorsed/*.jar /var/lib/tomcat5/common/endorsed/


- This has now installed Shibboleth-IdP in `/usr/local/shibboleth-idp` and the corresponding web application in `/var/lib/tomcat5/webapps/shibboleth-idp.war`.

## Connect Apache to Tomcat AJP connector

- Using the [ModProxy MAMS recipe](http://www.federation.org.au/twiki/bin/view/Federation/ModProxy)


>  **Passing **`/shibboleth-idp/`  and also Autograph and ShARPE URLs
>  **Passing **`/shibboleth-idp/`  and also Autograph and ShARPE URLs

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

- Configure Tomcat to listen on port ajp://localhost:8009 and disable the default 8080 http connector.
	
- Backup `/etc/tomcat5/server.xml`

``` 
cp /etc/tomcat5/server.xml /etc/tomcat5/server.xml.dist
```
- Edit /etc/tomcat5/server.xml and:
		
- Comment out the port 8080 http connector
- Add the `request.tomcatAuthentication="false" authentication="false"` parameters to the 8009 Connector definition

``` 

    <Connector port="8009" 
               <b>request.tomcatAuthentication="false" authentication="false"</b>
               enableLookups="false" redirectPort="8443" protocol="AJP/1.3" />

```

## Configure the Shibboleth IdP main configuration file

Main IdP configuration is in `/usr/local/shibboleth-idp/etc/idp.xml`

- Make a backup copy:


>  cd $SHIB_HOME/etc
>  cp idp.xml idp.xml.dist
>  cd $SHIB_HOME/etc
>  cp idp.xml idp.xml.dist

- Edit `/usr/local/shibboleth-idp/etc/idp.xml` and change the following:
- Change `IdPConfig.AAurl` to `"https://idp.lincoln.ac.nz:8443/shibboleth-idp/AA"`
- Change `IdPConfig.providerId` to `"urn:mace:federation.org.au:testfed:lincoln.ac.nz"`
- Change `IdpConfig.defaultRelyingParty` to `"urn:mace:federation.org.au:testfed"`
- Change `IdpConfig.resolverConfig` to `"file:/usr/local/shibboleth-idp/etc/resolver.ldap.xml"`
- Change `RelyingParty.name` to `"urn:mace:federation.org.au:testfed"`
- Change `RelyingParty.signingCredential` to `"def_cred"`
- Comment out existing `Credentials` block and put in this new one (pointing to the right certificate, key and CA certificate chain):


>                                 file:/etc/certs/idp.lincoln.ac.nz-shib-key.pem
>                                 file:/etc/certs/idp.lincoln.ac.nz-shib-cert.pem
>                                 file:/etc/certs/CA/pilot-level-3.pem
>                                 file:/etc/certs/CA/pilot-auscert-level3.pem
>                                 file:/etc/certs/CA/pilot-auscert-root.pem
>                                 file:/etc/certs/idp.lincoln.ac.nz-shib-key.pem
>                                 file:/etc/certs/idp.lincoln.ac.nz-shib-cert.pem
>                                 file:/etc/certs/CA/pilot-level-3.pem
>                                 file:/etc/certs/CA/pilot-auscert-level3.pem
>                                 file:/etc/certs/CA/pilot-auscert-root.pem


## Downloading metadata

- Download a one-off snapshot of the Level 1 and Level 2 federation metadata


>  wget [https://www.federation.org.au/level-1/level-1-metadata.xml](https://www.federation.org.au/level-1/level-1-metadata.xml) -O /usr/local/shibboleth-idp/etc/level-1-metadata.xml
>  wget [https://www.federation.org.au/level-2/level-2-metadata.xml](https://www.federation.org.au/level-2/level-2-metadata.xml) -O /usr/local/shibboleth-idp/etc/level-2-metadata.xml
>  wget [https://www.federation.org.au/level-1/level-1-metadata.xml](https://www.federation.org.au/level-1/level-1-metadata.xml) -O /usr/local/shibboleth-idp/etc/level-1-metadata.xml
>  wget [https://www.federation.org.au/level-2/level-2-metadata.xml](https://www.federation.org.au/level-2/level-2-metadata.xml) -O /usr/local/shibboleth-idp/etc/level-2-metadata.xml

## Configure Period Metadata Updates

Follow BeSTGRID documentation on [Updating Federation Metadata](updating-federation-metadata.md) and the original MAMS documentation for [Updating metadata](http://www.federation.org.au/twiki/bin/view/Federation/UpdateMetadata)

Install the following three scripts (based on these two pages) into `/etc/cron.hourly`: `idp-aafL1-metadata idp-aafL2-metadata idp-bestgrid-metadata`

The scripts download metadata from 

- [https://www.federation.org.au/level-1/level-1-metadata.xml](https://www.federation.org.au/level-1/level-1-metadata.xml)
- [https://www.federation.org.au/level-2/level-2-metadata.xml](https://www.federation.org.au/level-2/level-2-metadata.xml)
- [https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml](https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml)

For verification of the first two, the scripts use the certificate stored in the Java key store `/etc/certs/metadata/testfed-keystore.jks` (which is available as an attachment at the MAMS Updating page.

>  mkdir /etc/certs/metadata
>  wget [http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/testfed-keystore.jks](http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/testfed-keystore.jks) -O /etc/certs/metadata/testfed-keystore.jks

The BeSTGRID metadata is verified only by downloading from an https URL (and making sure the downloaded file is not corrupt, i.e., is a well-formed XML document).  The CA certificate might be stored in `/etc/certs/metadata/IPS-IPSCABUNDLE.crt` - which is however not necessary on this system, as the bundle OpenSSL comes with  already includes ipsCA.

## Configure attribute resolver

- Backup distribution configuration file:


>  mv resolver.ldap.xml resolver.ldap.xml.dist
>  mv resolver.ldap.xml resolver.ldap.xml.dist

- Download MAMS default version and make a backup


>  wget [http://www.federation.org.au/twiki/pub/Federation/ManualInstallIdP/resolver.ldap.xmlcp](http://www.federation.org.au/twiki/pub/Federation/ManualInstallIdP/resolver.ldap.xmlcp) resolver.ldap.xml resolver.ldap.xml.mams.dist
>  cp resolver.ldap.xml resolver.ldap.xml.mams.dist
>  wget [http://www.federation.org.au/twiki/pub/Federation/ManualInstallIdP/resolver.ldap.xmlcp](http://www.federation.org.au/twiki/pub/Federation/ManualInstallIdP/resolver.ldap.xmlcp) resolver.ldap.xml resolver.ldap.xml.mams.dist
>  cp resolver.ldap.xml resolver.ldap.xml.mams.dist

- Configure JNDIDirectoryDataConnector with access to LDAP server: edit `/usr/local/shibboleth-idp/etc/resolver.ldap.xml` (see below in next section)

- Configure correct IP addresses for the main LDAP server and other trees in the forest the LDAP server might sent referrals to: add the following to `/etc/hosts`

``` 

10.2.8.21       acs1.lincoln.ac.nz acs1 DomainDNSZones.lincoln.ac.nz ForestDNSZones.lincoln.ac.nz lincoln.ac.nz
10.2.16.21      acs2.lincoln.ac.nz acs2 DomainDNSZones.lincoln.ac.nz ForestDNSZones.lincoln.ac.nz lincoln.ac.nz

10.2.24.64      DomainDNSZones.lincoln.ac.nz ForestDNSZones.lincoln.ac.nz lincoln.ac.nz
10.2.24.65      DomainDNSZones.lincoln.ac.nz ForestDNSZones.lincoln.ac.nz lincoln.ac.nz

```

## Important considerations for connecting to Active Directory

The LDAP server used here is a Windows Active Directory 2008 server.

When doing LDAP searches starting at the root (which is a necessity in this case), the server returns LDAP referrals to other trees in the LDAP forest.  The IdP LDAP resolver must be configured to follow the referrals.  To allow the IdP to follow the referrals, the system must be able to resolve the hostnames for the additional LDAP servers and must be able to connect to these servers (to receive an empty reply there).

Once this is fully configured, a bug in the Apache LDAP module kicks in, breaking Apache LDAP login when referrals *can* be made.

Hence, the necessary configuration is to do Apache LDAP authentication against the AD Global Catalog at port 3268, and only configure the IdP resolver to connect to the actual AD server.

For more information on the background of this issue, see:

- [https://issues.apache.org/bugzilla/show_bug.cgi?id=26538](https://issues.apache.org/bugzilla/show_bug.cgi?id=26538)
- [http://wiki.apache.org/httpd/ModAuthAndActiveDirectory2003](http://wiki.apache.org/httpd/ModAuthAndActiveDirectory2003)

And for Shibboleth IdP configuration with AD, see [https://spaces.internet2.edu/display/SHIB2/IdPADConfigIssues](https://spaces.internet2.edu/display/SHIB2/IdPADConfigIssues)

The proper configuration is:

- LDAP authentication in `/etc/httpd/conf.d/shib_vhosts.conf`:

``` 

     <Location /shibboleth-idp/SSO>
        SSLRequireSSL
        AuthType Basic
        AuthBasicProvider ldap
        AuthzLDAPAuthoritative OFF
        AuthName "Shibboleth IdP Authentication"
        AuthLDAPBindDN cn=ldapweb,cn=users,dc=lincoln,dc=ac,dc=nz
        AuthLDAPBindPassword <b>PASSWORD</b>
        AuthLDAPURL "ldap://acs1.lincoln.ac.nz:3268/dc=lincoln,dc=ac,dc=nz?cn?sub?(objectClass=*)"
        require valid-user
     </Location>

```

(and the same for Locations /shibboleth-idp/IdP and /Autograph

- And the IdP resolver configuration:

``` 

        <JNDIDirectoryDataConnector id="directory">
                <Search filter="cn=%PRINCIPAL%">
                        <Controls searchScope="SUBTREE_SCOPE" returningObjects="false" />
                </Search>
                <Property name="java.naming.factory.initial" value="com.sun.jndi.ldap.LdapCtxFactory" />
                <Property name="java.naming.provider.url" value="ldap://acs1.lincoln.ac.nz:389/dc=lincoln,dc=ac,dc=nz" />
                <Property name="java.naming.security.principal" value="cn=ldapweb,cn=users,dc=lincoln,dc=ac,dc=nz" />
                <Property name="java.naming.security.credentials" value="<b>PASSWORD</b>" />
                <b><Property name="java.naming.referral" value="follow"/></b>
        </JNDIDirectoryDataConnector>

```

## Resolve basic attributes

Edit `/usr/local/shibboleth-idp/etc/resolver.ldap.xml` and define the following attributes:

- mail,sn,givenName: leave intact, defined as their counterpart in AD
- displayName,cn: define as eduDisplayName (`sourceName="eduDisplayName"`)
- eduPersonPrincipalName: define as "cn" with a smartScope of "lincoln.ac.nz" (`smartScope="lincoln.ac.nz" sourceName="cn"`)
- uid: define as "cn"

## Configure Attribute Release Policy

- Backup distribution original policy


>  cd /usr/local/shibboleth-idp/etc/arps/
>  cp arp.site.xml arp.site.xml.dist
>  cd /usr/local/shibboleth-idp/etc/arps/
>  cp arp.site.xml arp.site.xml.dist

- Temporarily (until ShARPE and Autograph are deployed), release all attributes to all sites: edit `/usr/local/shibboleth-idp/etc/arps/arp.site.xml` and list all attributes defined in the resolver configuration like follows:

``` 

        <Rule>
                <Target>
                        <AnyTarget/>
                </Target>
 <b>               <Attribute name="urn:mace:dir:attribute-def:eduPersonAffiliation">
                        <AnyValue release="permit"/>
                </Attribute>
 </b>               <Attribute name="urn:mace:dir:attribute-def:eduPersonPrimaryAffiliation">
                        <AnyValue release="permit"/>
                </Attribute>
                ....

```

## Configure Time Synchronization

Proper time synchronization is essential for Shibboleth to work correctly.  We configure the IdP to run NTP to continuously synchronize with the two time servers available on campus, `helios` (138.75.240.60) and `selene` (138.75.240.70).

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

server 138.75.240.60
server 138.75.240.70

```
- Make ntpd start on system startup


>  chkconfig ntpd on
>  chkconfig ntpd on

- Start ntpd now


>  service ntpd start
>  service ntpd start

## Configure Administrator Contact Details

When the IdP encounters an error and must display an error message, it would include the email address of the system administrator.  This is configured by editing `/var/lib/tomcat5/webapps/shibboleth-idp/IdPError.jsp` (or ./webApplication/IdPError.jsp in the source tree).

Replace the text `root@localhost` (and the corresponding link) with the correct address - in this case, Royston Boot's address.

# Configure additional attributes

- organisation (`"o"`) and locality (`"l"`) attributes: define a static data connector and pull the attributes from this connector:

``` 

        <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:o">
                <DataConnectorDependency requires="staticAttributesConnector"/>
        </SimpleAttributeDefinition>

        <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:l">
                <DataConnectorDependency requires="staticAttributesConnector"/>
        </SimpleAttributeDefinition>

        <StaticDataConnector id="staticAttributesConnector">
            <Attribute name="o">
                <Value>Lincoln University</Value>
            </Attribute>
            <Attribute name="l">
                <Value>NZ</Value>
            </Attribute>
        </StaticDataConnector>

```

- eduPersonAffiliation: use the following Scriptlet definition:

``` 

    <ScriptletAttributeDefinition
        id="urn:mace:dir:attribute-def:eduPersonAffiliation" >
        <DataConnectorDependency requires="directory"/>
        <Scriptlet><![CDATA[
                 Attributes attributes = dependencies.getConnectorResolution("directory");

                 Attribute luUnderGrad = attributes.get("luUnderGrad");
                 Attribute luPostGrad = attributes.get("luPostGrad");
                 Attribute luStaff = attributes.get("luStaff");
                 Attribute luOutSourcedEmail = attributes.get("luOutSourcedEmail");

                 boolean isUnderGrad = (luUnderGrad != null) && (luUnderGrad.size()>0) && luUnderGrad.get(0).equals("TRUE");
                 boolean isPostGrad = (luPostGrad != null) && (luPostGrad.size()>0) && luPostGrad.get(0).equals("TRUE");
                 boolean isStaff = (luStaff != null) && (luStaff.size()>0) && luStaff.get(0).equals("TRUE");
                 boolean isOutSourcedEmail = (luOutSourcedEmail != null) && (luOutSourcedEmail.size()>0) && luOutSourcedEmail.get(0).equals("TRUE");

                 if (isStaff) { resolverAttribute.addValue("staff"); };
                 if (isPostGrad && isOutSourcedEmail) { resolverAttribute.addValue("staff"); };
                 if (isUnderGrad || isPostGrad ) { resolverAttribute.addValue("student"); };
                 if (isUnderGrad || isPostGrad || isStaff ) { resolverAttribute.addValue("member"); };
               ]]></Scriptlet>
    </ScriptletAttributeDefinition>

```
- eduPersonPrimaryAffiliation: do a minor variation:

``` 

    <ScriptletAttributeDefinition
        id="urn:mace:dir:attribute-def:eduPersonPrimaryAffiliation" >
        <DataConnectorDependency requires="directory"/>
        <Scriptlet><![CDATA[
                 Attributes attributes = dependencies.getConnectorResolution("directory");

                 Attribute luUnderGrad = attributes.get("luUnderGrad");
                 Attribute luPostGrad = attributes.get("luPostGrad");
                 Attribute luStaff = attributes.get("luStaff");
                 Attribute luOutSourcedEmail = attributes.get("luOutSourcedEmail");

                 boolean isUnderGrad = (luUnderGrad != null) && (luUnderGrad.size()>0) && luUnderGrad.get(0).equals("TRUE");
                 boolean isPostGrad = (luPostGrad != null) && (luPostGrad.size()>0) && luPostGrad.get(0).equals("TRUE");
                 boolean isStaff = (luStaff != null) && (luStaff.size()>0) && luStaff.get(0).equals("TRUE");
                 boolean isOutSourcedEmail = (luOutSourcedEmail != null) && (luOutSourcedEmail.size()>0) && luOutSourcedEmail.get(0).equals("TRUE");

                 if (isStaff || (isPostGrad && isOutSourcedEmail)) { resolverAttribute.addValue("staff"); }
                 else if (isUnderGrad || isPostGrad ) { resolverAttribute.addValue("student"); };
               ]]></Scriptlet>
    </ScriptletAttributeDefinition>

```

- eduPersonScopedAffiliation: add `smartScope="lincoln.ac.nz"` into the attribute definition.
- eduPersonTargetedID: add the following definition:

``` 

    <ScriptletAttributeDefinition
        id="urn:mace:dir:attribute-def:eduPersonTargetedID" >
        <DataConnectorDependency requires="directory"/>
        <Scriptlet><![CDATA[
                 Attributes attributes = dependencies.getConnectorResolution("directory");

                 Attribute cnAttr = attributes.get("cn");

                 String cn = (cnAttr != null) && (cnAttr.size()>0) && (cnAttr.get(0) instanceof String) ? cnAttr.get(0) : null;
                 if (cn != null ) {
                    String eptID = responder + '!' + requester + '!' + cn + "!secretSEED";
                    resolverAttribute.registerValueHandler( new edu.internet2.middleware.shibboleth.aa.attrresolv.provider.ScopedStringValueHandler("lincoln.ac.nz"));
                    resolverAttribute.addValue(new String(org.apache.commons.codec.binary.Base64.encodeBase64(org.apache.commons.codec.digest.DigestUtils.sha(eptID)),0,27));
                 };
               ]]></Scriptlet>
    </ScriptletAttributeDefinition>

```

## Configuring auEduPersonSharedToken

The sharedToken attribute is constructed by a simple module that gets installed as a jar file into the Shibboleth IdP web application.  It is constructed as a hash of the IdP identifier, a user identifier and a secret seed.  We are using the username (stored as `cn`) - which is unique, non-reassigned and persistent.

- Following [ARCS IMAST guide](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallIdP/IdP-Installation-CentOS5/IMAST-Installation) and deploying in PNP (Partial-or-No-Provisioning) mode.

- Fetch the source code :


>  cd /root/inst
>  svn co [https://projects.arcs.org.au/svn/systems/tags/idp/imast/arcs-imast-1.1.0/](https://projects.arcs.org.au/svn/systems/tags/idp/imast/arcs-imast-1.1.0/)
>  cd arcs-imast-1.1.0
>  cd /root/inst
>  svn co [https://projects.arcs.org.au/svn/systems/tags/idp/imast/arcs-imast-1.1.0/](https://projects.arcs.org.au/svn/systems/tags/idp/imast/arcs-imast-1.1.0/)
>  cd arcs-imast-1.1.0

- Edit `conf/imast.properties` and add the following configuration (replace privateSEED with the actual seed value):

``` 

USER_IDENTIFIER=cn
IDP_IDENTIFIER=idp.lincoln.ac.nz
PRIVATE_SEED=privateSEED
IDP_CONFIG_FILE=file:/usr/local/shibboleth-idp/etc/idp.xml
WORK_MODE=PNP

```
- Compile and build the IMAST module


>  ant
>  cp dist/arcs-imast-1.0.0.jar /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/lib
>  ant
>  cp dist/arcs-imast-1.0.0.jar /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/lib

- Install the jar also into /usr/local/shibboleth-idp/lib/ so that it's available to the `resolvertest` utility:


>  cp dist/arcs-imast-1.0.0.jar /usr/local/shibboleth-idp/lib/
>  cp dist/arcs-imast-1.0.0.jar /usr/local/shibboleth-idp/lib/

**Note:** when installing Autograph or ShaRPE, install the jar also into their WEB-INF/lib directories.

- Define the attribute in `resolver.ldap.xml`


# Join the AAF Pilot Federation

In preparation for move from MAMS Level 2 to AAF, this IdP has been registered in the AAF Pilot Federation.  For that, the IdP had to provide two additional attributes: *home organization* and *home organization type*, and has to pull in the federation metadata.

## Configuring home organization attributes

The homeOrg and homeOrgType are static attributes.

- We define the attibute values in the existing `staticAttributesConnector` *StaticDataConnector*:

``` 

            <Attribute name="homeOrg">
                <Value>lincoln.ac.nz</Value>
            </Attribute>
            <Attribute name="homeOrgType">
                <Value>urn:mace:terena.org:schac:homeOrganizationType:int:university</Value>
            </Attribute>

```

- Define the attributes themselves (based on the Migration document):

``` 

        <SimpleAttributeDefinition id="urn:oid:1.3.6.1.4.1.25178.1.2.9" sourceName="homeOrg">
                <DataConnectorDependency requires="staticAttributesConnector"/>
        </SimpleAttributeDefinition>

        <SimpleAttributeDefinition id="urn:oid:1.3.6.1.4.1.25178.1.2.10" sourceName="homeOrgType">
                <DataConnectorDependency requires="staticAttributesConnector"/>
        </SimpleAttributeDefinition>

```

- Release the attributes (and eduPersonTargetedID) to the Resource Registry Manager in `/usr/local/shibboleth-idp/etc/arps/arp.site.xml`

``` 

        <!-- release homeOrg and homeOrgType to AAF RR manager -->
        <Rule>
                <Description>noDescription</Description>
                <Target>
                    <Requester>https://manager.aaf.edu.au/shibboleth</Requester>
                    <AnyResource/>
                </Target>

                <!-- AAF Pilot: homeOrg and homeOrgType -->
                <Attribute name="urn:oid:1.3.6.1.4.1.25178.1.2.9">
                        <AnyValue release="permit"/>
                </Attribute>
                <Attribute name="urn:oid:1.3.6.1.4.1.25178.1.2.10">
                        <AnyValue release="permit"/>
                </Attribute>
                <Attribute name="urn:mace:dir:attribute-def:eduPersonTargetedID">
                        <AnyValue release="permit"/>
                </Attribute>
        </Rule>

```

## Import AAF federation metadata

- Download metadata signing certificate into `/etc/certs/metadata`


>  cd /etc/certs/metadata
>  wget [https://manager.aaf.edu.au/metadata/metadata-cert.pem](https://manager.aaf.edu.au/metadata/metadata-cert.pem) -O aaf-metadata-cert.pem
>  cd /etc/certs/metadata
>  wget [https://manager.aaf.edu.au/metadata/metadata-cert.pem](https://manager.aaf.edu.au/metadata/metadata-cert.pem) -O aaf-metadata-cert.pem

- Import the certificate into a Java keystore


>  keytool -import -alias aaf-metadata-cert -file aaf-metadata-cert.pem -keystore aaf-metadata.jks -storepass aaf-metadata
>  keytool -import -alias aaf-metadata-cert -file aaf-metadata-cert.pem -keystore aaf-metadata.jks -storepass aaf-metadata

- Download the metadata with an (executable) cron job `/etc/cron.hourly/idp-aafPilot-metadata`

``` 

#!/bin/bash

[ -x /etc/profile.d/java.sh ] && . /etc/profile.d/java.sh
[ -x /etc/profile.d/shib.sh ] && . /etc/profile.d/shib.sh

if [ -z "$SHIB_HOME" ] ; then
  export SHIB_HOME="/usr/local/shibboleth-idp"
fi

if [ -z "$JAVA_HOME" ] ; then
  export JAVA_HOME=/usr/java/java
  PATH=$PATH:$JAVA_HOME/bin
fi

export METADATA_URL=https://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml
export IDP_HOME=${SHIB_HOME}
export OUTPUT_FILE=${IDP_HOME}/etc/aaf-pilot-metadata.xml

$IDP_HOME/bin/metadatatool -i $METADATA_URL \
    -k /etc/certs/metadata/aaf-metadata.jks -a aaf-metadata-cert -p aaf-metadata \
    -o $OUTPUT_FILE

```

- Import the metadata into `/usr/local/shibboleth-idp/etc/idp.xml`

``` 

        <MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
                uri="file:/usr/local/shibboleth-idp/etc/aaf-pilot-metadata.xml"/>

```

## Configure a self-signed certificate

- Create OpenSSL configuration file `cert.conf` in /etc/certs/self-signed with the following contents (replace idp.example.org with your hostname, idp.lincoln.ac.nz)

``` 

# OpenSSL configuration file for creating sp-cert.pem
[req]
prompt=no
default_bits=2048
encrypt_key=no
default_md=sha1
distinguished_name=dn
# PrintableStrings only
string_mask=MASK:0002
x509_extensions=ext
[dn]
CN=idp.example.org
[ext]
subjectAltName=DNS:idp.example.org,URI:https://idp.example.org/idp/shibboleth
subjectKeyIdentifier=hash

```

- Generate the certificate with


>  openssl req -x509 -newkey rsa:2048 -nodes -out `hostname`-self-cert.pem -keyout `hostname`-self-key.pem -config cert.conf
>  openssl req -x509 -newkey rsa:2048 -nodes -out `hostname`-self-cert.pem -keyout `hostname`-self-key.pem -config cert.conf

- Configure a second `FileResolver` in `idp.xml` with this certificate:

``` 

                <FileResolver Id="aaf_cred">
                        <Key>
                                <Path>file:/etc/certs/self-signed/idp.lincoln.ac.nz-self-key.pem</Path>
                        </Key>
                        <Certificate>
                                <Path>file:/etc/certs/self-signed/idp.lincoln.ac.nz-self-cert.pem</Path>
                        </Certificate>
                </FileResolver>

```

- Create a `RelyingParty` configuration in `idp.xml` that would use this credentials for signing assertions to the AAF Pilot federation entityGroup:

``` 

        <RelyingParty name="urn:mace:aaf.edu.au:AAFProduction" providerId="https://idp.lincoln.ac.nz/idp/shibboleth" signingCredential="aaf_cred">
                <NameID nameMapping="shm"/>
        </RelyingParty>

```

## Register to the federation

- Fill in the bootstrap form at [https://manager.aaf.edu.au/rr/](https://manager.aaf.edu.au/rr/)

- Login to the Resource Registry Manager at the same URL

# Install Autograph

Autograph is the tool for users to decide on attribute release.  Autograph was installed following the installation guidelines at [http://www.federation.org.au/twiki/bin/view/Federation/AutographInstall](http://www.federation.org.au/twiki/bin/view/Federation/AutographInstall), www.mams.org.au/downloads/Autograph-1.0-Beta-2.5.tgz Autograph version 2.5 and an additional replace for mams-idp-ext.jar (to be officially released soon).

Autograph is storing it's configuration and the user profile data in `/usr/local/shibboleth-autograph`.

## Basic Autograph installation

Follow the steps at the [AutographInstall page](http://www.federation.org.au/twiki/bin/view/Federation/AutographInstall).

Specific details of this installation are:

- In `/var/lib/tomcat5/webapps/Autograph/WEB-INF/web.xml`, set `AutographConfigurationFileLocation` to `/usr/local/shibboleth-autograph/AutographConfiguration.properties`

``` 

    <context-param>
        <param-name>AutographConfigurationFileLocation</param-name>
        <param-value>/usr/local/shibboleth-autograph/AutographConfiguration.properties</param-value>
    </context-param>

```

- Create `/usr/local/shibboleth-autograph`

``` 
mkdir /usr/local/shibboleth-autograph
```
- From `/var/lib/tomcat5/webapps/Autograph/WEB-INF`, copy `AutographConfiguration.properties` and `homeDir` to `/usr/local/shibboleth-autograph/`


>  cp -r -p /var/lib/tomcat5/webapps/Autograph/WEB-INF/{AutographConfiguration.properties,homeDir} /usr/local/shibboleth-autograph
>  cp -r -p /var/lib/tomcat5/webapps/Autograph/WEB-INF/{AutographConfiguration.properties,homeDir} /usr/local/shibboleth-autograph

- In /usr/local/shibboleth-autograph/AutographConfiguration.properties, change:


>  userProfileDir = /usr/local/shibboleth-autograph/homeDir/userProfiles
>  displayAgreement = never
>  userProfileDir = /usr/local/shibboleth-autograph/homeDir/userProfiles
>  displayAgreement = never

- Comment out `securitycontraints` section from `/var/lib/tomcat5/webapps/Autograph/WEB-INF/web.xml`
- Expand mams-sharpe.tgz into SHIB_IDP_HOME/etc


>  cd /usr/local/shibboleth/etc
>  tar xzf /root/inst//Autograph-2.5/mams-sharpe.tgz
>  cd /usr/local/shibboleth/etc
>  tar xzf /root/inst//Autograph-2.5/mams-sharpe.tgz

- Make sure `/etc/httpd/conf.d/proxy_ajp.conf` maps `/Autograph` to Tomcat:


>  ProxyPass /Autograph ajp://localhost:8009/Autograph
>  ProxyPass /Autograph ajp://localhost:8009/Autograph

## Additional configuration

- Copy the sharedToken implementation into `/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib`


>   cp /root/inst/arcs-imast-1.1.0/dist/arcs-imast-1.0.0.jar /var/lib/tomcat5/webapps/Autograph/WEB-INF/lib
>   cp /root/inst/arcs-imast-1.1.0/dist/arcs-imast-1.0.0.jar /var/lib/tomcat5/webapps/Autograph/WEB-INF/lib

- Teach Autograph about additional attributes in /usr/local/shibboleth-idp/etc/mams-sharpe/attribute_info.xml

``` 

                <!-- AAF specific -->
                <Attribute personal="false" id="urn:oid:1.3.6.1.4.1.25178.1.2.9"  type="string">
                        <FriendlyName lang="en">home organization</FriendlyName>
                        <Description lang="en">home organization domain name</Description>
                </Attribute>
                <Attribute personal="false" id="urn:oid:1.3.6.1.4.1.25178.1.2.10"  type="string">
                        <FriendlyName lang="en">home organization type</FriendlyName>
                        <Description lang="en">no description</Description>
                </Attribute>

```

- Make sure all Autograph files are owned by tomcat


>  chown R tomcat.tomcat /usr/local/shibboleth{idp,autograph}
>  chown R tomcat.tomcat /usr/local/shibboleth{idp,autograph}

## Switching Autograph on and off

- Switch Autograph on with


>  cd /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF
>  cp web.xml-with-autograph web.xml
>  service tomcat5 restart
>  cd /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF
>  cp web.xml-with-autograph web.xml
>  service tomcat5 restart

- If desired, switch Autograph off with


>  cd /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF
>  cp web.xml-no-autograph web.xml
>  service tomcat5 restart
>  cd /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF
>  cp web.xml-no-autograph web.xml
>  service tomcat5 restart

## Enable Autograph interface

To allow users to pre-configure access to other services in a single visit, create `/etc/httpd/conf.d/rootredir.conf` with

>  RedirectMatch ^/+$ [https://idp.lincoln.ac.nz/Autograph/Login_AAF](https://idp.lincoln.ac.nz/Autograph/Login_AAF)

That redirects users from [https://idp.lincoln.ac.nz](https://idp.lincoln.ac.nz) to the entry point into Autograph, [https://idp.lincoln.ac.nz/Autograph/Login_AAF](https://idp.lincoln.ac.nz/Autograph/Login_AAF)

# Final touch

- Set permissions right: all files in the Shibboleth directories need to be owned by tomcat:

``` 

chown -R tomcat.tomcat /usr/local/shibboleth-idp /var/lib/tomcat5/webapps
chown tomcat.tomcat /etc/certs/idp.lincoln.ac.nz-shib-{cert,key}.pem

```

- Start the IdP

``` 

service tomcat5 start
service httpd restart

```

- Make sure Tomcat and Apache start automatically

``` 

chkconfig httpd on
chkconfig tomcat5 on

```

- Register the IdP in MAMS Level 2 federation and BeSTGRID Federation
	
- MAMS Level 2 Federation: Register the IdP in the [Federation Manager](http://www.federation.org.au/)
- BeSTGRID Federation: add the metadata (as published in MAMS metadata) manually to `wayf.bestgrid.org:/var/www/html/metadata/bestgrid-metadata.xml`

# Testing

Useful commands for testing attribute query:

- Query LDAP attributes:


>  ldapsearch -LLL -x -h acs1.lincoln.ac.nz -b dc=lincoln,dc=ac,dc=nz -D cn=ldapweb,cn=users,dc=lincoln,dc=ac,dc=nz -w PASSWORD cn=USERCODE
>  ldapsearch -LLL -x -h acs1.lincoln.ac.nz -b dc=lincoln,dc=ac,dc=nz -D cn=ldapweb,cn=users,dc=lincoln,dc=ac,dc=nz -w PASSWORD cn=USERCODE

- Test Shibboleth Attribute Resolver:

``` 

$SHIB_HOME/bin/resolvertest
--resolverxml=file://$SHIB_HOME/etc/resolver.ldap.xml --responderurn:mace:federation.org.au:testfed:lincoln.ac.nz --user=bootr2 2>&1 | less

```

# Maintenance notes

- Remember to renew certificates
	
- Front-end certificate expires 2011-04-19
- Back-channel certificate expires 2010-04-17

- After any changes to idp.xml or resolver.ldap.xml, it is necessary to restart the IdP with

``` 
service tomcat5 restart
```

# Optional tasks for the future

- ShARPE installation
- Store the auEduPersonSharedToken attribute inside LDAP (to be populated on demand by the IdP - would need write access to this attribute)

# Critical configuration files

The following files should be thoroughly backed up - and cannot be posted here, as they contain password / other sensitive information (private seed used for EPTID and auEPST)

- /usr/local/shibboleth-idp/etc/idp.xml
- /usr/local/shibboleth-idp/etc/resolver.ldap.xml
- /etc/httpd/conf.d/shib-vhosts.conf
- /etc/httpd/conf.d/proxy_ajp.conf
- /root/inst/arcs-imast-1.1.0/conf/imast.properties
- /etc/certs directory where all certificates are stored
- /var/lib/tomcat5/webapps (backup the whole directory with customized installation of Autograph and the Shibboleth IdP web application)
- /usr/local/shibboleth-idp (the full IdP installation tree)
- /usr/local/shibboleth-autograph (user profiles)
- /root/inst (installation files)
