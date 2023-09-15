# Shibboleth IdP Installation at the University of Canterbury

This page documents installing the Shibboleth Identity Provider (IdP) at the University of Canterbury.  The installation primarily follows the [MAMS IdP installation instructions](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallIdP), and builds on the experience from [installing the Test IdP](/wiki/spaces/BeSTGRID/pages/3818228985).  Thus, this page is rather brief, and documents mainly what was done differently, and focuses on details of the key commands and configuration entries used.

# Installation Prerequisites

- Setup JDK 1.5.0_12 as the default java (replacing gcj)

``` 

JAVA_HOME=/usr/java/jdk1.5.0_12
alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 15004      \
  --slave /usr/bin/rmiregistry rmiregistry $JAVA_HOME/bin/rmiregistry    \
  --slave /usr/share/man/man1/java.1 java.1 $JAVA_HOME/man/man1/java.1   \
  --slave /usr/share/man/man1/rmiregistry.1 rmiregistry.1 $JAVA_HOME/man/man1/rmiregistry.1  \
  --slave /usr/lib/jvm/jre jre $JAVA_HOME/jre                            \
  --slave /usr/lib/jvm-exports/jre jre_exports $JAVA_HOME/jre/lib        \
  --slave /usr/bin/keytool keytool $JAVA_HOME/bin/keytool                \
  --slave /usr/bin/rmic rmic $JAVA_HOME/bin/rmic                         \
  --slave /usr/bin/javah javah $JAVA_HOME/bin/javah                      \
  --slave /usr/bin/javadoc javadoc $JAVA_HOME/bin/javadoc                \
  --slave /usr/bin/javac javac $JAVA_HOME/bin/javac                      \
  --slave /usr/bin/jarsigner jarsigner $JAVA_HOME/bin/jarsigner          \
  --slave /usr/bin/jar jar $JAVA_HOME/bin/jar                            \
  --slave /usr/lib/jvm/java java_sdk $JAVA_HOME                          \
  --slave /usr/lib/jvm-exports/java java_sdk_exports $JAVA_HOME/lib

```

Note: tomcat by default uses as JAVA_HOME /usr/lib/jvm/java - which is a symlink to /etc/alternatives/java_sdk

Make sure you either edit /ets/sysconfig/tomcat5 or change this symlink with /etc/alternatives.  When tomcat5 is running under GJC, the IdP appears to run fine, however, it is not able to verify PKI credentials of Service Providers requesting attributes; in the end, any authentication request fails with [Session Creation Error](http://www.federation.org.au/twiki/bin/view/Federation/SessionCreationError), and `/usr/local/shibboleth-idp/logs/shib-error.log` reports

``` 

2007-10-03 15:44:13,670 ERROR [IdP] -2107690520                         - Encountered an error during validation: java.security.NoSuchAlgorithmException: PKIX
2007-10-03 15:44:13,670 ERROR [IdP] -2107690520                         - Supplied TLS credential (C=NZ,O=University of Canterbury,OU=ICT Services,CN=idp-test.canterbury.ac.nz) is NOT valid for provider (urn:mace:federation.org.au:testfed:idp-test.canterbury.ac.nz), to whom this artifact was issued.
2007-10-03 15:44:13,671 ERROR [IdP] -2107690520                         - Error while processing request: org.opensaml.SAMLException: Invalid credential.

```

Install packages needed (or useful):

>  yum install ntp mc 

Install OpenLDAP (at the very least client tools are needed)

>  yum install openldap-servers openldap-clients

C++ compiler

>  yum install gcc-c++

C++ 3.4 (to compile Shibboleth SP)

>  yum install compat-gcc-34 compat-gcc-34-c++ 

Libraries to compile apache modules

>  yum install  curl-devel httpd-devel

TODO: setup ntpd

`/etc/ntp.conf`

>  server clock1.canterbury.ac.nz

 chkconfig  ntpd on

>  service ntpd start

# Installation

./ant

>  => /var/lib/tomcat5

## Apache Configuration

ssl.conf changes:

>  Listen 8443
>  SSLRandomSeed startup builtin
>  SSLMutex file:/var/run/apache_ssl_mutex

leaving: 

>    SSLSessionCache         shmcb:/var/cache/mod_ssl/scache(512000)

instead of 

>    SSLSessionCache         dbm:/var/run/apache2/ssl_scache

vhost configuration

- use AA certificate (issued by CAUDIT) for host
- use  (till we get a host certificate)
- disable RedirectMatch for / (handled by welcome.conf in Redhat distributions)

enable ports 80,443,8080,8443 on local firewall

if copying shib-vhosts.conf from another host, change IP address in VirtualHost directives to 132.181.2.17

Create /etc/certs/caudit-ca-bundle.pem by

>  cat pilot-level-3.pem pilot-auscert-level3.pem pilot-auscert-root.pem > caudit-ca-bundle.pem

in shib-vhosts.conf, Virtualhost: 8843 :

>     SSLCertificateChainFile /etc/certs/caudit-ca-bundle.pem

- not needed for :443 - Thawte certificate is issued directly by the root CA (no intermediate CA), thus, as a client trusting us will have the root CA, it will always be possible to build the complete chain and we don't have to provide a bundle

## Tomcat Configuration

`/etc/tomcat5/server.xml`: add `request.tomcatAuthentication="false" tomcatAuthentication="false"` to port 8009 AJP Connector definition:

``` 

    <Connector port="8009"                
+               request.tomcatAuthentication="false"
+               tomcatAuthentication="false"
               enableLookups="false" redirectPort="8443" protocol="AJP/1.3" />

```

## IdP configuration

idp.xml

- `IdpConfig` element:


>         AAUrl="https://idp.canterbury.ac.nz:8443/shibboleth-idp/AA"
>         resolverConfig="file:/usr/local/shibboleth-idp/etc/resolver.ldap.xml"
>         defaultRelyingParty="urn:mace:federation.org.au:testfed"
>         providerId="urn:mace:federation.org.au:testfed:idp.canterbury.ac.nz">
>         AAUrl="https://idp.canterbury.ac.nz:8443/shibboleth-idp/AA"
>         resolverConfig="file:/usr/local/shibboleth-idp/etc/resolver.ldap.xml"
>         defaultRelyingParty="urn:mace:federation.org.au:testfed"
>         providerId="urn:mace:federation.org.au:testfed:idp.canterbury.ac.nz">

- `SigningCredential`
- Note: with AA credential signed by a subordinate CA (CAUDIT), it is necessary to build up the chain of CA credentials in the signing credential configuration:

``` 

<Credentials xmlns="urn:mace:shibboleth:credentials:1.0">
    <FileResolver Id="idp_canterbury_ac_nz_cred">
        <Key>
            <Path>file:/etc/certs/aa-key.pem</Path>
        </Key>
        <Certificate>
            <Path>file:/etc/certs/aa-cert.pem</Path>
            <CAPath>file:/etc/certs/CA/pilot-level-3.pem</CAPath>
            <CAPath>file:/etc/certs/CA/pilot-auscert-level3.pem</CAPath>
            <CAPath>file:/etc/certs/CA/pilot-auscert-root.pem</CAPath>
        </Certificate>
    </FileResolver>
</Credentials>

```
- Metadata provider

``` 

  <MetadataProvider ...
          uri="file:/usr/local/shibboleth-idp/etc/level-1-metadata.xml"/>
         <! -- will be level-2 once we get approved -->

```

replaced `$SHIB_HOME/etc/resolver.ldap.xml` with [http://www.federation.org.au/twiki/pub/Federation/ManualInstallIdP/resolver.ldap.xml](http://www.federation.org.au/twiki/pub/Federation/ManualInstallIdP/resolver.ldap.xml)

replaced `$SHIB_HOME/etc/arps/arp.site.xml` with [http://www.federation.org.au/twiki/pub/Federation/ManualInstallIdP/arp.site.xml](http://www.federation.org.au/twiki/pub/Federation/ManualInstallIdP/arp.site.xml)

TODO: LDAP Directory connector in resolver.ldap.xml and in Apache LDAP auth

``` 

     <Location /shibboleth-idp/SSO>
        AuthType Basic
        AuthBasicProvider ldap
        AuthzLDAPAuthoritative OFF
        AuthName "Shibboleth IdP Authentication"
        AuthLDAPBindDN cn=reader,dc=canterbury,dc=ac,dc=nz
        AuthLDAPBindPassword "password"
        AuthLDAPURL "ldap://ldap.canterbury.ac.nz:389/ou=useraccounts,dc=canterbury,dc=ac,dc=nz?uid?sub?(objectClass=*)"
        require valid-user
     </Location>

```

JNDI connector in resolver.ldap.xml

``` 

                <Property name="java.naming.provider.url" value="ldap://ldap.canterbury.ac.nz:389/ou=useraccounts,dc=canterbury,dc=ac,dc=nz" />
                <Property name="java.naming.security.principal" value="cn=reader,dc=canterbury,dc=ac,dc=nz" />
                <Property name="java.naming.security.credentials" value="password" />

```

TODO(APACHE): setup cert bundle for AA cert

Get metadata for the first time (now for level-1)

>  wget [https://www.federation.org.au/level-1/level-1-metadata.xml](https://www.federation.org.au/level-1/level-1-metadata.xml) -O /usr/local/shibboleth-idp/etc/level-1-metadata.xml

Problem: HTTP Status 404 - Servlet IdP is not available

>  chown -R tomcat:tomcat /usr/local/shibboleth-idp/ 
>  chown tomcat:tomcat /etc/certs/aa-{cert,key}.pem

# Problems Encountered

## Apache mixing up certificates

In our configuration, Apache is supposed to use a "commercial" certificate (issued by Thawte) on port 443, but a "federation" certificate (issued by CAUDIT) on port 8443.  Apache virtual host configuration file lists a `SSLCertificateFile` and a `SSLCertificateKeyFile` for each of the virtual hosts, and a `SSLCertificateChainFile` only for the CAUDIT certificate - the Thawte certificate is issued directly by the root CA, so it does not need a chain file.

Unfortunately, in this configuration Apache ignores the SSL configuration directives in the second virtual host, and uses the Thawte certificate for both virtual hosts.

However, when the Thawte SSL configuration also gets a `SSLCertificateChainFile` directive (with the Thawte Root CA, as an empty file is not permitted), Apache  suddenly works correctly and uses the SSL certificates for the virtual hosts as expected.

The final SSL configuration including the workaround is as follows:

``` 

 <VirtualHost 132.181.2.17:443>
   ...
   SSLCertificateFile /etc/certs/host-cert.pem
   SSLCertificateKeyFile /etc/certs/host-key.pem
   <b>SSLCertificateChainFile /etc/certs/ThawtePremiumServerCA.pem</b>
   ...
 </VirtualHost>
 
 <VirtualHost 132.181.2.17:8443>
   ...
   SSLCertificateFile /etc/certs/aa-cert.pem
   SSLCertificateKeyFile /etc/certs/aa-key.pem
   SSLCertificateChainFile /etc/certs/caudit-ca-bundle.pem
   ...
 </VirtualHost>

```

# Federation Membership & Metadata updates

The IdP has a dual membership in the AAF Level-2 federation and in the [BeSTGRID Federation Metadata](bestgrid-federation-metadata.md).

## BeSTGRID Federation

This was easy to configure - the only necessary steps, after entering the IdP in both federations' metadata, is to create a second 

``` 
<MetadataProvider>
```

 element in `idp.xml`:

``` 

        <MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
                uri="file:/usr/local/shibboleth-idp/etc/level-2-metadata.xml"/>
        
        <strong><MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
                uri="file:/usr/local/shibboleth-idp/etc/bestgrid-metadata.xml"/></strong>

```

## Metadata updates

A somehow tricky task was to setup automatic metadata updates for the BeSTGRID Federation.  For the AAF Level 2 federation, updating was done in the same way as for the [Test IdP](http://www.bestgrid.org/index.php/Shibboleth_IdP_Test_Installation_at_the_University_of_Canterbury#Metadata_updates) according to the [MAMS metadata update guide](http://www.federation.org.au/twiki/bin/view/Federation/UpdateMetadata).  The `metadataupdate` tool checks the signature on the XML document, preventing both willful tampering and corruption of the metadata during the download (e.g., due to incomplete transfer).

However, for the BeSTGRID federations, several factors step in: 

- the metadata is not signed
- the metadata is hosted on the WAYF server, which uses a SSL certificate issued by the APACGrid CA.  Even after adding the APACGrid CA root certificate to the java `cacerts` keystore, metadatatool is not able to download metadata from an HTTPS location on this server, as certificate path validation throws an exception 

``` 
CA key usage check failed: keyCertSign bit is not set
```

.

Therefore, an alternative solution must be used to assure that:

1. The metadata is retrieved in a secure manner to avoid willful tampering, and
2. The metadata would be checked for consistency at least by an XML parser to detect errors introduced e.g. by an incomplete transfer.

This is achieved by first retrieving the metadata with `wget` from an HTTPS URL, checking the certificate authenticity with APACGrid CA used as a trusted root, and then installing the metadata with `metadatatool`, which checks the metadata with an XML parser.

The following commands should be placed in an executable script in `/etc/cron.hourly/idp-bestgrid-metadata`:

``` 

#!/bin/bash

wget --quiet --ca-certificate=/etc/certs/apacgrid.pem https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml -O /usr/local/shibboleth-idp/etc/bestgrid-metadata-download.xml
IDP_HOME=$SHIB_HOME $SHIB_HOME/bin/metadatatool -i file:////usr/local/shibboleth-idp/etc/bestgrid-metadata-download.xml -N -o /usr/local/shibboleth-idp/etc/bestgrid-metadata.xml

```

**Note** that this command needs the **APACGrid CA root certificate** in `/etc/certs/apacgrid.pem`.

Download the update script from here:

- [idp-bestgrid-metadata](/wiki/download/attachments/3818228463/Idp-bestgrid-metadata.txt?version=1&modificationDate=1539354143000&cacheVersion=1&api=v2) (download)
- !Idp-bestgrid-metadata.txt!
 (file information)

Edit the script to customize file locations (in particular, set the path to the CA certificate for your web server in HTTPS_CERT_CA)

You may install the script with:

``` 

 wget -O /etc/cron.hourly/idp-bestgrid-metadata <copy the download link>
 chmod +x /etc/cron.hourly/idp-bestgrid-metadata

```

## AAF scope

The namespace assigned to Scoped attribute values is stored in the `shib:Scope` extension in the metadata, and is directly derived from the entity Id.  Hence, to issue attributes with scope `canterbury.ac.nz` (and not `idp.canterbury.ac.nz`), the entityId in the Organization registered in the federation must end with `:canterbury.ac.nz` - i.e., `urn:mace:federation.org.au:testfed:canterbury.ac.nz`.

This can be changed later without intervention from the AAF - just edit an already approved host.
