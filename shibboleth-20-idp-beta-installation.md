# Shibboleth 2.0 IdP Beta Installation

# Introduction

This article describes my installation process of Shibboleth 2.0 IdP Beta

# Installation

- Follow the [Shibboleth 2.0 Beta IdP Cook Book](https://spaces.internet2.edu/display/SHIB2/IdPBetaCookbook) in order to complete the  installation and configuration process

# Common Problems

>  **idp-process.log is the main log file for Shib 2.0 Beta IdP  (usually at*shib_install_path**/logs/idp-process.log)

;Incorrect configuration for profile handler path

- log file may presents the following message:

``` 

15:29:25.559 INFO [Shibboleth-Access] 20071203T022925Z|130.216.189.43|kilrogg.auckland.ac.nz:8443
|/profile/saml/SOAP/AttributeQuery|

15:29:25.559 WARN [edu.internet2.middleware.shibboleth.common.profile.ProfileRequestDispatcherServlet] 
No profile handler configured for request at path: /saml/SOAP/AttributeQuery

```
- This is probably a mismatch with the hanlder.xml file and metadata. The default configuration in the trunk is

``` 

    <ProfileHandler xsi:type="SAML1AttributeQuery" 
                    inboundBinding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding"
                    outboundBindingEnumeration="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding">
        <RequestPath>/saml1/SOAP/AttributeQuery</RequestPath>
    </ProfileHandler>

```
**However, the metadata is probably pointing to ****[https://yourhost.org/idpname/saml/SOAP/AttributeQuery](https://yourhost.org/idpname/saml/SOAP/AttributeQuery)**** in *AttributeService** element

;Incorrect configuration for principal connector.

- log file may presents the following message:

``` 

16:40:33.734 INFO [Shibboleth-Access] 
0071203T034033Z|130.216.189.43|kilrogg.auckland.ac.nz:8443|/profile/saml1/SOAP/AttributeQuery| 

16:40:33.749 ERROR [edu.internet2.middleware.shibboleth.idp.profile.saml1.AbstractSAML1ProfileHandler]
Error resolving attributes for SAML request from relying party urn:mace:federation.org.au:bestgrid.org

edu.internet2.middleware.shibboleth.common.attribute.resolver.AttributeResolutionException: No principal connector available to
resolve a subject name with format urn:mace:shibboleth:1.0:nameIdentifier for
relying party urn:mace:federation.org.au:bestgrid.org
        at edu.internet2.middleware.shibboleth.common.attribute.resolver.
provider.ShibbolethAttributeResolver.resolvePrincipalName(ShibbolethAttributeResolver.java:212)
        at edu.internet2.middleware.shibboleth.common.attribute.provider.ShibbolethSAML1AttributeAuthority.
getPrincipal(ShibbolethSAML1AttributeAuthority.java:140)
        at edu.internet2.middleware.shibboleth.idp.profile.saml1.AbstractSAML1ProfileHandler.
resolvePrincipal(AbstractSAML1ProfileHandler.java:564)
        at edu.internet2.middleware.shibboleth.idp.profile.saml1.AttributeQueryProfileHandler.
processRequest(AttributeQueryProfileHandler.java:87)

```
**The value of *NameIDFormat** in metadata should match the nameIDFormat attribute of **PrincipalConnector** element. 

**For example, if the *nameIDFormat** attribute of **PrincipalConnector** element in attribute-resolver.xml contains "urn:oasis:names:tc:SAML:1.0:nameid-format:unspecified", then it should has a corresponding **NameIDFormat** element in metadata with same value "urn:oasis:names:tc:SAML:1.0:nameid-format:unspecified" as well.

- SEVERE

Error listenerStart
- catalina.out log file may presents the following message:

``` 

5/12/2007 10:26:18 org.apache.catalina.startup.HostConfig deployWAR
INFO: Deploying web application archive idp.war
5/12/2007 10:26:24 org.apache.catalina.core.StandardContext start
SEVERE: Error listenerStart
5/12/2007 10:26:24 org.apache.catalina.core.StandardContext start
SEVERE: Context [/idp] startup failed due to previous errors

```
- Plenty of times.  That just means the IdP failed to start.  Check idp-process.log for a good dump of the errors
- At the time of writing, the current configuration defaults in SVN may be the reason to caused this problem. You should use the configuration provided from Shibboleth Internet2 wiki.

NOTE: A test Shibboleth 2.0 IdP beta has installed in server kilrogg.auckland.ac.nz and it has been tested with Shibboleth 1.3 and waiting for Shib 2.0 SP vs Shib 2.0 IdP testing
