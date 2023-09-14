# Shibboleth Service Provider Setup - RHEL4

# Prerequisites

This guide only applies to RedHat Advanced Server 4.

- Apache 2 with SSL module
- An Identity Provider (IdP) for testing purpose
- RPM Package Manager
- All of the command lines at the command terminal are of the form:

``` 
root# rpm .....
```

# Firewall Configuration

- Port 443 and 80 are used by any browser-user
- Open the fire-wall configuration file. i.e.

``` 
root# vi /etc/sysconfig/iptables 
```
- Add the following lines before the word - COMMIT

``` 
	-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 80 -s 130.216.4.0/255.255.254.0 -j ACCEPT 
	-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 443 -s 130.216.4.0/255.255.254.0 -j ACCEPT 
```
- Restart the fire-wall for these changes to take effect

``` 
 root# /etc/init.d/iptables restart 
```

# SSL Certificate

- Generate a private key and a certificate request by [OpenSSL](http://www.openssl.org)

``` 
 root# openssl req -new -newkey rsa:1024 -sha1 -keyout server.key -nodes -out server.csr 
```

- Send the certificate request (server.csr) to be signed by a trusted external Certification Authority (CA). e.g. [VeriSign](http://www.verisign.com/) or [Thawte](http://www.thawte.com/).

- You can generate a self-signed certificate while waiting for the certificate to be 'signed' by a CA or only using it in a prototype environment.

- Before self-sign a certificate, you need to generate a CA certificate.

``` 
openssl req -x509 -new -newkey rsa:1024 -keyout myCA.key -nodes -out myCA.crt -days 3650
```

- Self sign a certificate.

openssl x509 -req -in server.csr -CA myCA.crt -CAkey myCA.key -CAcreateserial -out server.crt -days 1095

- Save the private key (server.key) and the signed certificate (server.crt) in a safe place, and then delete the certificate request (server.csr) for the security concern.

# Installation Shibboleth Service Provider 1.3

- Download the following binary packages from [http://shibboleth.internet2.edu/downloads/RPMS/i386/RHE/4.3/](http://shibboleth.internet2.edu/downloads/RPMS/i386/RHE/4.3/)


>   log4cpp-0.3.5rc1-1.i386.rpm 
>   opensaml-1.1-6.i386.rpm 
>   shibboleth-1.3-11.i386.rpm 
>   xerces-c-2.6.1-2.i386.rpm 
>   xml-security-c-1.2.0-2.i386.rpm
>   log4cpp-0.3.5rc1-1.i386.rpm 
>   opensaml-1.1-6.i386.rpm 
>   shibboleth-1.3-11.i386.rpm 
>   xerces-c-2.6.1-2.i386.rpm 
>   xml-security-c-1.2.0-2.i386.rpm

- Install all packages at once

``` 
root# rpm -ivh log4cpp-0.3.5rc1-1.i386.rpm opensaml-1.1-6.i386.rpm shibboleth-1.3-11.i386.rpm
xerces-c-2.6.1-2.i386.rpm xml-security-c-1.2.0-2.i386.rpm 
```

# Configurations of Service Provider

## Basic Service Provider Configuration

- Configure the Service Provider by edit the shibboleth.xml (usually at /etc/shibboleth/)

- Download the example [Shibboleth.xml](/wiki/spaces/BeSTGRID/pages/3818228679).

- urn:mace namespace is a Uniform Resource Name namespace for [MACE](http://middleware.internet2.edu/MACE/) working groups. The namespace is intended to be delegated to different working groups or organizations that registered with MACE. For example, the URN namespace of the University of Auckland (UoA) in MACE is 'urn:mace:UoAFederation'.

- providerId: This is the unique identifier of the resource within the federation network. Its value should be 'stable'. For the default application it should be the full URL. E.g. the providerId of Service Provider Scooby inside UoA federation network is urn:mace:UoAFederation:sp.scooby.enarc.auckland.ac.nz.

- The request handling of the Shibboleth Service Provider accommodates a wide range of deployment scenarios. Each request begins with the evaluation of the requested URL and terminates with a web service. The received attributes are matched to a shibboleth protected resource with an access control mechanism. In Shibboleth, the request handling function is configured by the RequestMapProvider and RequestMap elements along with one or more  Host and Path elements which matched to host names and paths of the protected resources. An example to configure a protected directory called 'wiki' at 'scooby.enarc.auckland.ac.nz' host is shown below:

``` 

<RequestMapProvider type="edu.internet2.middleware.shibboleth.sp.provider.NativeRequestMapProvider">
 <RequestMap applicationId="default">
  <Host name="scooby.enarc.auckland.ac.nz" redirectToSSL="443">
   <Path name="wiki" authType="shibboleth" requireSession="true"/> 
  </Host>
 </RequestMap>
</RequestMapProvider>

```

- "Applications" is the configuration element that affects the shibboleth behaviour at the application layer, and also controls the mapping of this layer onto the providerId layer above it. This element must appear once and must contain at least one each of the Sessions and Errors elements. It may also contain CredentialUse, saml:AttributeDesignator, saml:Audience for backward compatibility, AAPProvider , TrustProvider, MetadataProvider , and Application elements. An example is shown below:

``` 

	<Applications id="default" providerId="urn:mace:UoAFederation:sp.scooby.enarc.auckland.ac.nz"
		homeURL="https://sp.example.org/index.html"
		xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion"
		xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">

		<Sessions lifetime="7200" timeout="3600" checkAddress="false" consistentAddress="true"
			handlerURL="/Shibboleth.sso" handlerSSL="false" idpHistory="true" idpHistoryDays="7">
			
			<SessionInitiator  id="UoATestFedDirect" Location="/WAYF/idp.auckland.ac.nz"
				Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
				wayfURL="https://idp.auckland.ac.nz/shibboleth-idp/SSO"
				wayfBinding="urn:mace:shibboleth:1.0:profiles:AuthnRequest"/>
			<SessionInitiator isDefault="true" id="UoATestFedWayf" Location="/WAYF/testfed.auckland.ac.nz"
				Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
				wayfURL="https://testfed.auckland.ac.nz/shibboleth-wayf/WAYF"
				wayfBinding="urn:mace:shibboleth:1.0:profiles:AuthnRequest"/>
			
			<md:AssertionConsumerService Location="/SAML/POST" isDefault="true" index="1"
				Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post"/>
			<md:AssertionConsumerService Location="/SAML/Artifact" index="2"
				Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01"/>
			<md:SingleLogoutService Location="/Logout" Binding="urn:mace:shibboleth:sp:1.3:Logout"/>
		</Sessions>

		<Errors session="/etc/shibboleth/sessionError.html"
			metadata="/etc/shibboleth/metadataError.html"
			rm="/etc/shibboleth/rmError.html"
			access="/etc/shibboleth/accessError.html"
			ssl="/etc/shibboleth/sslError.html"
			supportContact="e.jiang@auckland.ac.nz"
			logoLocation="/shibboleth-sp/logo.jpg"
			styleSheet="/shibboleth-sp/main.css"/>

		<CredentialUse TLS="urn:mace:UoATestFed" Signing="urn:mace:UoATestFed">
			<!-- RelyingParty elements can customize credentials for specific IdPs/sets. -->
			<!--<RelyingParty Name="urn:mace:inqueue" TLS="inqueuecreds" Signing="inqueuecreds"/>-->
			<RelyingParty Name="urn:mace:UoAFederation" TLS="UoATestFedCreds" Signing="UoATestFedCreds"/>
		</CredentialUse>
			

		<AAPProvider type="edu.internet2.middleware.shibboleth.aap.provider.XMLAAP" uri="/etc/shibboleth/AAP.xml"/>
		
		<MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
			uri="/etc/shibboleth/UoATestFed-metadata.xml"/>
		
		<TrustProvider type="edu.internet2.middleware.shibboleth.common.provider.ShibbolethTrust"/>
					
		<saml:Audience>urn:mace:UoATestFed</saml:Audience>
		 
		<Application id="admin">
			<Sessions lifetime="7200" timeout="3600" checkAddress="true" consistentAddress="true"
				handlerURL="/Shibboleth.sso" handlerSSL="true" cookieProps="; path=/; secure"/>
			<saml:AttributeDesignator AttributeName="urn:mace:dir:attribute-def:eduPersonPrincipalName"
				AttributeNamespace="urn:mace:shibboleth:1.0:attributeNamespace:uri"/>
		</Application>
	</Applications>

```

- Sessions may contain one or more SessionInitiator. Please look at [Shibbolize MediaWiki](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Shibbolize_MediaWiki&linkCreation=true&fromPageId=3818228563) for more details.

- CredentialsProvider is the configuration that describes the details of the CredentialUse element. It defines the paths of private keys and certificates. An example is shown below:

``` 

	<CredentialsProvider type="edu.internet2.middleware.shibboleth.common.Credentials">
		<Credentials xmlns="urn:mace:shibboleth:credentials:1.0">
			<FileResolver Id="UoATestFedCreds">
				<Key>
					<Path>/etc/shibboleth/certs/scooby.enarc.auckland.ac.nz.key</Path>
				</Key>
				<Certificate>
					<Path>/etc/shibboleth/certs/scooby.enarc.auckland.ac.nz_UoAPilotFederationCA.crt</Path>
				</Certificate>
			</FileResolver>
		</Credentials>
	</CredentialsProvider>

```

## Federation Metadata

### How to add an Identify Provider to a Service Provider

The metadata on a Service Provider describes all Identify Providers that can be used to access its resource. It contains all IdP entity descriptions and their public keys. The path of the metadata is defined by the MetadataProvider element.

An example of how to add an Identity Provider with a providerId - "urn:mace:UoAFederation:idp.auckland.ac.nz" to a Service Provider is shown below:

``` 

   <EntityDescriptor entityID="urn:mace:UoAFederation:idp.auckland.ac.nz">
      <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol urn:mace:shibboleth:1.0">
         <Extensions>
            <shib:Scope xmlns:shib="urn:mace:shibboleth:metadata:1.0" regexp="false">auckland.ac.nz</shib:Scope>
         </Extensions>

         <KeyDescriptor use="signing">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
               <ds:X509Data>
                 <ds:X509Certificate>
     MIIDKjCCApOgAwIBAgIBADANBgkqhkiG9w0BAQUFADByMR0wGwYDVQQDExRVb0FQ 
     aWxvdEZlZGVyYXRpb25DQTELMAkGA1UEBhMCTloxETAPBgNVBAcTCEF1Y2tsYW5k 
     MQwwCgYDVQQLEwNJVFMxIzAhBgNVBAoTGlRoZSBVbml2ZXJzaXR5IG9mIEF1Y2ts 
     YW5kMB4XDTA3MDIxMjAxNDQwM1oXDTE3MDIwOTAxNDQwM1owcjEdMBsGA1UEAxMU 
     ......
     VGhlIFVuaXZlcnNpdHkgb2YgQXVja2xhbmSCAQAwDAYDVR0TBAUwAwEB/zANBgkq 
     hkiG9w0BAQUFAAOBgQARPr257BM8XaOw9q9fWv4Nw2/acSgfmuqqsB+T6V1ConP6 
     qbLx27tktn11PvsPqGKF2XTIlKvhak/SC40RG67u7STP7LZHR10Yq4xQIupWkpa6 
     fy1r/PjYoSphS7mpRZevYZwo7qi97A78PFLfDU+40xf6AyLsWi7oZYoGbU0J8A==
               </ds:X509Certificate>
            </ds:X509Data>
            </ds:KeyInfo>
         </KeyDescriptor>

         <ArtifactResolutionService Binding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding"
                 Location="https://idp.auckland.ac.nz/shibboleth-idp/Artifact" index="1">
         </ArtifactResolutionService>

         <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>

         <SingleSignOnService Binding="urn:mace:shibboleth:1.0:profiles:AuthnRequest" 
                 Location="https://idp.auckland.ac.nz/shibboleth-idp/SSO">
         </SingleSignOnService>
      </IDPSSODescriptor>

      <AttributeAuthorityDescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol">
         <Extensions>
            <shib:Scope xmlns:shib="urn:mace:shibboleth:metadata:1.0" regexp="false">auckland.ac.nz</shib:Scope>
         </Extensions>

         <KeyDescriptor use="signing">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
               <ds:KeyName>idp.auckland.ac.nz</ds:KeyName>
            </ds:KeyInfo>
         </KeyDescriptor>

         <AttributeService Binding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding" 
                    Location="https://idp.auckland.ac.nz:8443/shibboleth-idp/AA">
         </AttributeService>

         <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>
      </AttributeAuthorityDescriptor>

      <Organization>
         <OrganizationName xml:lang="en">The University of Auckland</OrganizationName>

         <OrganizationDisplayName xml:lang="en">The University of Auckland</OrganizationDisplayName>

         <OrganizationURL xml:lang="en">http://www.auckland.ac.nz/</OrganizationURL>
      </Organization>

      <ContactPerson contactType="technical">
         <SurName>Brett Lomas</SurName>

         <EmailAddress>b.lomas@auckland.ac.nz</EmailAddress>
      </ContactPerson>

      <ContactPerson contactType="administrative">
         <SurName>Brett Lomas</SurName>

         <EmailAddress>b.lomas@auckland.ac.nz</EmailAddress>
      </ContactPerson>
   </EntityDescriptor>

```

### How to add a Service Provider to an Identify Provider

Similar to above, you need to add the details of your Service Provider to the metadata of you Identity Provider. 

An example of adding a SP with a providerId - "urn:mace:UoAFederation:sp.scooby.enarc.auckland.ac.nz" to a IdP is shown below:

``` 

   <EntityDescriptor entityID="urn:mace:UoAFederation:sp.scooby.enarc.auckland.ac.nz">
      <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol">
         <KeyDescriptor>
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
                           <ds:X509Data>
                              <ds:X509Certificate>
                                  HTAbBgNVBAMTFFVvQVBpbG90RmVkZXJhdGlvbkNBMQswCQYDVQQG
                                      ...............
                                  qbLx27tktn11PvsPqGKF2XTIlKvhak/SC40RG67u7STP7LZHR10Y  
                              </ds:X509Certificate>
                            </ds:X509Data>
            </ds:KeyInfo>
         </KeyDescriptor>
         <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>
         <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post" 
               Location="https://scooby.enarc.auckland.ac.nz/Shibboleth.sso/SAML/POST" index="0">
         </AssertionConsumerService>
         <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01" 
               Location="https://scooby.enarc.auckland.ac.nz/Shibboleth.sso/SAML/Artifact" index="1">
         </AssertionConsumerService>
      </SPSSODescriptor>
      <Organization>
         <OrganizationName xml:lang="en">The University of Auckland SP Testing</OrganizationName>
         <OrganizationDisplayName xml:lang="en">The University of Auckland - Scooby Testing</OrganizationDisplayName>
         <OrganizationURL xml:lang="en">http://scooby.enarc.auckland.ac.nz/</OrganizationURL>
      </Organization>
      <ContactPerson contactType="technical">
         <SurName>Eric Jiang</SurName>
         <EmailAddress>e.jiang@auckland.ac.nz</EmailAddress>
      </ContactPerson>
      <ContactPerson contactType="administrative">
         <SurName>Eric Jiang</SurName>
         <EmailAddress>e.jiang@auckland.ac.nz</EmailAddress>
      </ContactPerson>
   </EntityDescriptor>

```

## Attribute Acceptance Policy

The following explanation of Attribute Acceptance Policy (AAP) is directly quoted from [Internet2->Shibboleth->Attribute Acceptance Policy](https://spaces.internet2.edu/display/SHIB/AttributeAcceptancePolicy)

*An Attribute Acceptance Policy (AAP) is a policy defining rules for the processing of SAML attributes by a Service Provider. These rules include:*

- *Whether to "accept" the attribute's values. Unaccepted values are filtered out before information is extracted for use by applications. The raw, unfiltered assertions can still be accessed when required.*

- *The HTTP request headers in which to place attribute values. Multiple attributes can be mapped to a single header. Multiple values are collectively combined into a single header with semicolons separating the values.*

- *Aliases by which attributes can be referenced in access control policy rules, such as Apache require commands. SAML attributes tend to have machine-friendly names, so aliases allow more admin-friendly names to be used instead.*

- Download the example [AAP.xml](/wiki/spaces/BeSTGRID/pages/3818228812) and save it to the URI that defined by the AAPProvider element. (usually at /etc/shibboleth/)

- An example of [how to obtain attributes from an Identity Provider](#ShibbolethServiceProviderSetup-RHEL4-HowtoobtainattributesfromanIdentityProvider) is shown below .

# Shibboleth Daemon

- Check the Shibboleth configuration with the Shibboleth Daemon

``` 
root# /usr/sbin/shibd -t
```

- start the Shibboleth Daemon

``` 
root# /etc/init.d/shibd start
```

# Protecting a web directory with Shibboleth

## Apache

- Make sure the Apache 2 will load and configure the Shibboleth module mod_shib.so.

- Create a directory called /secure under the root directory. i.e./var/www/html/secure

(Assume the web root directory is /var/www/html)

- Edit the configure file (usually at /etc/httpd/conf.d/shib.conf)

``` 
<Location /secure>
  AuthType shibboleth
  ShibRequireSession On
  require valid-user
</Location>
```

- Restart Apache for the changes to take effect.

``` 
root# /etc/init.d/httpd restart
```

- An example is shown [below](#ShibbolethServiceProviderSetup-RHEL4-AccessControlintegrationwithLDAP)

## XML Access Control

- If you want to defer all decisions to the RequestMap, you can do the following way

- Edit the configure file (usually at /etc/httpd/conf.d/shib.conf)

``` 

<Location />
	 AuthType shibboleth
	 Require shibboleth
</Location>

```

- Edit the Shibboleth.xml by insert an AccessControl element into a Host or Path element in the RequestMap

``` 

<Host name="scooby.enarc.auckland.ac.nz">
	<Path name="secure" authType="shibboleth" requireSession="true">
		<AccessControl>
			<AND>
				<OR>
					<Rule require="affiliation">member@auckland.ac.nz</Rule>
					<Rule require="affiliation">member@ec.auckland.ac.nz</Rule>
				</OR>
				<Rule require="entitlement">urn:mace:example.edu:exampleEntitlement</Rule>
			</AND>
		</AccessControl>
	</Path>
       <Path name="student" authType="shibboleth" requireSession="true">
               <AccessControl>
                          <Rule require="affiliation">member@auckland.ac.nz</Rule>
               </AccessControl>
       </Path>
</Host>

```

- Restart Apache for the changes to take effect.

# Common Problems

The path of the default IdP log file is

/usr/local/shibboleth-idp/logs/shib-error.**date**.log

e.g. /usr/local/shibboleth-idp/logs/shib-error.20xx-xx-xx.log

The path of the default SP log file is

/var/log/shibboleth/shibd.log

## Clock Skew

SP log file will generate a similar message as below if there is a Clock Skew error.

``` 

2007-xx-xx 10:19:33 ERROR shibd.Listener [1] sessionNew: 
caught exception while creating session: unable to accept assertion because of clock skew

```

It is caused by the different clock settings between IdP and SP,. and their differences exceeds the default configuration setting of SP.

(i.e. at /etc/shibboleth/shibboleth.xml   ...clockSkew="180")

Solution: Reset the system time setting

``` 
root# date 073123161998
```

Synchronize the hardware clock setting with the system time

``` 
root# /sbin/hwclock --systohc
```

## Detected expired POST profile response

SP log file generates a similar message as below:

``` 

ERROR shibd.Listener [3] sessionNew: caught exception while creating session: detected expired POST profile response

```

It is a similar problem as [Clock Skew](#ShibbolethServiceProviderSetup-RHEL4-ClockSkew) which indicates the different clock setting between machines.

## How to obtain attributes from an Identity Provider

- Aim: obtain the email address of a user from a debugging prospective.

- Write a php script to display the returned attributes. The php script should located inside a shibboleth protected folder called "secure". (usually /var/www/html/secure/)

``` 

<?php
foreach ($_SERVER as $attribute => $value) {
        if ( ereg('^HTTP_SHIB_', $attribute) ) {
        // values are sent UTF8, must decode to ISO
             $value= utf8_decode( $value );
             echo "$attribute = $value<br>";
        }
}
?>

```

- First of all, enter the URL of the php script (e.g. [https://scooby.enarc.auckland.ac.nz/secure/displayAttributes.php](https://scooby.enarc.auckland.ac.nz/secure/displayAttributes.php))

- Authenticate as a registered user e.g. yjia032

- If there is no attribute found for this user, the IdP log file should contained somethings similar to below:

``` 
 
2007-02-13 11:15:02,746 DEBUG [IdP] -1892060997      - Dumping ARP:
...
2007-02-13 11:15:02,747 DEBUG [IdP] -1892060997      - Computed possible attribute release set.
2007-02-13 11:15:02,747 DEBUG [IdP] -1892060997      - ARP Engine was asked to apply filter to empty attribute set.
2007-02-13 11:15:02,748 INFO  [IdP] -1892060997      - Found 0 attribute(s) for yjia032
...

```

- Review the Attribute Release Policy (ARP) of the Identity Provider

(usually at /usr/local/shibboleth-idp/etc/arps/arp.site.xml). If there is no Attribute Release Rules found for this Service Provider, then add a set of Attribute Release Rules for it. An example is shown below:

``` 

    <Rule>
        <Description>Scooby SP</Description>
        <Target>
            <Requester>urn:mace:UoAFederation:sp.scooby.enarc.auckland.ac.nz</Requester>
            <AnyResource/>
        </Target>
        <Attribute name="urn:mace:dir:attribute-def:mail">
            <AnyValue release="permit"/>
        </Attribute>
    </Rule>

```

- Make sure the Attribute Name is specified in the Attribute Acceptance Policy of Service Provider(usually at /etc/shibboleth/AAP.xml)

It should contain somethings similar to below:

``` 

        <AttributeRule Name="urn:mace:dir:attribute-def:mail" Header="Shib-InetOrgPerson-mail"  Alias="email">
                <AnySite>
                     <AnyValue/>
               </AnySite>
        </AttributeRule>

```

- The resolver of Identity Provider (usually /usr/local/shibboleth-idp/etc/resolver.xml) should contain the description of this attribute. An example is shown below:

``` 

    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:mail">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>

```

- The php script should displayed something similar to below:

``` 
HTTP_SHIB_INETORGPERSON_MAIL = yjia032@ec.auckland.ac.nz
```

## Access Control integration with LDAP

This is mainly targeted at the restriction of access to a resource to a specific set of users. i.e. the SP is configured to restrict the accesses to a secure directory by a specified group of users, e.g. university staffs only.

The example below describes how to set up a directory that restricted to university staffs and another directory that restricted to university students. It assumed the students and staffs can be distinguished by their email address. (e.g. student email: yjia032@ec.auckland.ac.nz, staff email: e.jiang@auckland.ac.nz)

Include the following configurations inside the Apache configuration file (/etc/httpd/conf.d/shib.conf).

Staff only

``` 
<Location /staff>
  AuthType shibboleth
  ShibRequireSession On
  ShibRedirectToSSL 443
  require email ~ ^[a-z]+\.+[a-z].+@auckland+\.ac+\.nz$
</Location>
```

Student only:

``` 

<Location /student>
  AuthType shibboleth
  ShibRequireSession On
  ShibRedirectToSSL 443
  require email ~ ^[a-z].+\d.+@ec+\.auckland+\.ac+\.nz$
</Location>

```

## No Credentials attached

This error occurs when the log of IdP shows:

``` 

..... INFO  [IdP] -1540475702 - Request contained no credentials, treating as an unauthenticated service provider
..... INFO  [IdP] -1540475702 - Unable to locate metadata about provider, treating as an unauthenticated service
provider.

```

or the log of SP shows:

``` 

..... ERROR shibtarget.ShibHTTPHook [1] sessionGet: unable to attach credentials to request using (urn:mace:bestgrid), leaving anonymous

```

There are several mistakes in the configuration file shibboleth.xml that may caused this problem:

- Permission error.
	
- Shibboleth daemon shibd doesn't have permission to read the credential certificate and key.
- Incorrect file path or file doesn't not exist
- **The*FileResolver** (Under **CredentialsProvider** **Credentials**)defines the path of the credential certificate and the credential key. The path maybe misspell by mistake
- Id mismatch
- **The Id of*FileResolver** MUST be matched the name of **CredentialUse**

## How to enable HTTP front end communication while maintaining attribute assertion on HTTPS

Configure handlerSSL="true" in Shibboleth SP configuration (usually at /etc/shibboleth/shibboleth.xml). Please look at [here](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Shibbolize_MediaWiki&linkCreation=true&fromPageId=3818228563) for a Mediawiki example.

## SSL3_READ_BYTES:sslv3 alert unsupported certificate

This is a "catch-all" type error message which can be caused by variety of reasons which involved invalid SSL certificate. It usually caused by IdP rejects the certificate when SP trying to make a SAML SOAP Binding to IdP port 8443 for attribute assertion. Please check the following configuration are set correctly:

- SSLCACertificateFile is pointing to correct CA bundle
- Alternatively you could use "SSLVerifyClient optional_no_ca" to ignore the CAs
- SSLVerifyDepth must be configured to appropriate value.

**In IdP, you need to make sure it is for *TLS Web Server Authentitication** and you can verify the certificate by 

``` 

openssl verify -purpose sslserver  -CAfile ca-bundle.pem mycert.pem

```

**In SP, you need to make sure it is for *TLS Web Client Authentication** and you can verify the certificate by

``` 

openssl verify -purpose sslclient  -CAfile ca-bundle.pem mycert.pem

```

**OR, you can try to make an SSL connection using the SP cert and key and expected a successful *SSL handshake**

``` 

openssl s_client -connect idp.example.com:8443 -showcerts -cert SP.crt -key SP.key

```

## Your IP address (...) does not match the address recorded at the time the session was established

This error occurred when SP determined an inconsistent status from a comparison of two distinct sets of client addresses. 

One of the addresses is the address that the client placed into the initial SAML assertion created by the IdP and the address of the client that delivers the SAML assertion to the SP to create a session

Another address is the address that the client making a resource request and the address of the client that was given the session cookie that corresponds to the current request

The error might be caused by the client access the internet via a proxy server.

A possible solution for this error is to disable both "checkAddress" and "consistentAddress" configurations by setting them to "false". These two configurations are located in the SP configuration file shibboleth.xml.

# Appendix

- [Shibboleth.xml](/wiki/spaces/BeSTGRID/pages/3818228679)
- [AAP.xml](/wiki/spaces/BeSTGRID/pages/3818228812)
