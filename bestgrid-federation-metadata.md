# BeSTGRID Federation Metadata

# Introduction

This page contains the SSO Descriptors of some of the BeSTGRID Federation entities.  The primary source of the federation metadata is at the WAYF server at [https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml](https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml)  Use the data on this page for demonstration purposes only, and refer to the URL above for authoritative source.  The WAYF server has a certificate issued by the APACGrid CA ([download root certificate](https://ca.apac.edu.au/cgi-bin/pub/pki?cmd=getStaticPage;name=download_cacert)).

For information on how to update the metadata, please see the page [Updating Federation Metadata](/wiki/spaces/BeSTGRID/pages/3818228810).

When editing the metadata, please keep in mind the following:

- For an IdP, the value of the `KeyName` element in `KeyDescriptors` MUST match the hostname of the IdP.
- For an IdP, the value of `shib:Scope` gives the permitted value of Scope - and MUST be the same for both occurrences in the IDP definition.
- For an IdP, the Artifact resolution services is only accessible via port 8443 - the URL listed for `ArtifactResolutionService` MUST include the port, 8443.

# The University of Auckland

## Identity Provider

## Production Identity Provider

This is UoA production IdP which requires UoA cosign authentication and will look up the user data in production LDAP. The SSL certificate has been signed by Thawte Premium Server CA.

Please find its SSO descriptor below:

``` 


  <EntityDescriptor entityID="urn:mace:bestgrid:idp.auckland.ac.nz">
      <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol urn:mace:shibboleth:1.0">
         <Extensions>
            <shib:Scope xmlns:shib="urn:mace:shibboleth:metadata:1.0" regexp="false">auckland.ac.nz</shib:Scope>
         </Extensions>

         <KeyDescriptor use="signing">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
               <ds:KeyName>idp.auckland.ac.nz</ds:KeyName>
            </ds:KeyInfo>
         </KeyDescriptor>

         <ArtifactResolutionService Binding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding" Location="https://idp.auckland.ac.nz:8443/shibboleth-idp/Artifact" index="1">
         </ArtifactResolutionService>

         <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>

         <SingleSignOnService Binding="urn:mace:shibboleth:1.0:profiles:AuthnRequest" Location="https://idp.auckland.ac.nz/shibboleth-idp/SSO">
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

         <AttributeService Binding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding" Location="https://idp.auckland.ac.nz:8443/shibboleth-idp/AA">
         </AttributeService>

         <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>
      </AttributeAuthorityDescriptor>

      <Organization>
         <OrganizationName xml:lang="en">The University of Auckland Identity Provider</OrganizationName>

         <OrganizationDisplayName xml:lang="en">The University of Auckland Identity Provider</OrganizationDisplayName>

         <OrganizationURL xml:lang="en">http://www.auckland.ac.nz/</OrganizationURL>
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

## Testing Identity Provider

As the name suggested this IdP is used for testing purpose and only return the user details from testing UoA LDAP. In addition, its certificate was signed by a self-generated [BeSTGRID CA](#BeSTGRIDFederationMetadata-BeSTGRIDCA). 

``` 


   <EntityDescriptor entityID="urn:mace:bestgrid:idp-test.auckland.ac.nz">
      <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol urn:mace:shibboleth:1.0">
         <Extensions>
            <shib:Scope xmlns:shib="urn:mace:shibboleth:metadata:1.0" regexp="false">auckland.ac.nz</shib:Scope>
         </Extensions>

         <KeyDescriptor use="signing">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
               <ds:KeyName>idp-test.auckland.ac.nz</ds:KeyName>
            </ds:KeyInfo>
         </KeyDescriptor>

         <ArtifactResolutionService Binding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding" Location="https://idp-test.auckland.ac.nz:8443/shibboleth-idp/Artifact" index="1">
         </ArtifactResolutionService>

         <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>

         <SingleSignOnService Binding="urn:mace:shibboleth:1.0:profiles:AuthnRequest" Location="https://idp-test.auckland.ac.nz/shibboleth-idp/SSO">
         </SingleSignOnService>
      </IDPSSODescriptor>

      <AttributeAuthorityDescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol">
         <Extensions>
            <shib:Scope xmlns:shib="urn:mace:shibboleth:metadata:1.0" regexp="false">auckland.ac.nz</shib:Scope>
         </Extensions>

         <KeyDescriptor use="signing">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
               <ds:KeyName>idp-test.auckland.ac.nz</ds:KeyName>
            </ds:KeyInfo>
         </KeyDescriptor>

         <AttributeService Binding="urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding" Location="https://idp-test.auckland.ac.nz:8443/shibboleth-idp/AA">
         </AttributeService>

         <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>
      </AttributeAuthorityDescriptor>

      <Organization>
         <OrganizationName xml:lang="en">The University of Auckland Identity Provider Test</OrganizationName>

         <OrganizationDisplayName xml:lang="en">The University of Auckland Identity Provider Test</OrganizationDisplayName>

         <OrganizationURL xml:lang="en">http://www.auckland.ac.nz/</OrganizationURL>
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

# BeSTGRID

At the time of writing, all BeSTGRID Shibboleth entities are in testing stage.

## Open Identity Provider

The Open IdP is a Shibboleth Identity provider with a web interface which would allow users to register their details (without any verification). This allows them to use Shibboleth without the burden of installing an IdP at their site. It might also be a good mechanism for the slow and controlled adoption of Shibboleth in an institution which might have a small audience.

``` 


  <EntityDescriptor entityID="urn:mace:bestgrid:wiki.test.bestgrid.org">
      <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol">
         <KeyDescriptor>
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
               <ds:KeyName>wiki.test.bestgrid.org</ds:KeyName>
            </ds:KeyInfo>
         </KeyDescriptor>

         <NameIDFormat>urn:mace:shibboleth:1.0:nameIdentifier</NameIDFormat>

         <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post" Location="https://wiki.test.bestgrid.org/Shibboleth.sso/SAML/POST" index="0">
         </AssertionConsumerService>

         <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01" Location="https://wiki.test.bestgrid.org/Shibboleth.sso/SAML/Artifact" index="1">
         </AssertionConsumerService>
      </SPSSODescriptor>

      <Organization>
         <OrganizationName xml:lang="en">BeSTGRID WIKI Test</OrganizationName>

         <OrganizationDisplayName xml:lang="en">BeSTGRID WIKI Test</OrganizationDisplayName>

         <OrganizationURL xml:lang="en">http://www.bestgrid.org/</OrganizationURL>
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

# BeSTGRID CA

``` 


<!-- BeSTGRID CA -->
         <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
            <ds:X509Data>
               <ds:X509Certificate>MIIDXDCCAsWgAwIBAgIBADANBgkqhkiG9w0BAQUFADCBgTEUMBIGA1UEAxMLYmVz
dGdyaWQtQ0ExCzAJBgNVBAYTAk5aMREwDwYDVQQHEwhBdWNrbGFuZDERMA8GA1UE
CxMIQmVTVEdSSUQxNjA0BgNVBAoTLUJyb2FkYmFuZCBlbmFibGVkIFNjaWVuY2Ug
YW5kIFRlY2hub2xvZ3kgR1JJRDAeFw0wNzA1MjQwMzI3MDVaFw0xNzA1MjEwMzI3
MDVaMIGBMRQwEgYDVQQDEwtiZXN0Z3JpZC1DQTELMAkGA1UEBhMCTloxETAPBgNV
BAcTCEF1Y2tsYW5kMREwDwYDVQQLEwhCZVNUR1JJRDE2MDQGA1UEChMtQnJvYWRi
YW5kIGVuYWJsZWQgU2NpZW5jZSBhbmQgVGVjaG5vbG9neSBHUklEMIGfMA0GCSqG
SIb3DQEBAQUAA4GNADCBiQKBgQCzaWPv4iN2UvAwllyBdZ3Of+0GvxPubwpAgLs6
rYNYRTQpa28BOyPsKOH6zIu25Nvv2kYw3ZAtqTreRCy8Kb+hAtDNjtJRBvyGD3uj
sogV1CXZGjXhzzcPkLBRkjpfTnGparLh1tqtkWPXiWu3JmMuCZt70YvQlJX+TK0p
5q0kywIDAQABo4HhMIHeMB0GA1UdDgQWBBTJaWDM6hxoNXz3Tr67tArck/PZDTCB
rgYDVR0jBIGmMIGjgBTJaWDM6hxoNXz3Tr67tArck/PZDaGBh6SBhDCBgTEUMBIG
A1UEAxMLYmVzdGdyaWQtQ0ExCzAJBgNVBAYTAk5aMREwDwYDVQQHEwhBdWNrbGFu
ZDERMA8GA1UECxMIQmVTVEdSSUQxNjA0BgNVBAoTLUJyb2FkYmFuZCBlbmFibGVk
IFNjaWVuY2UgYW5kIFRlY2hub2xvZ3kgR1JJRIIBADAMBgNVHRMEBTADAQH/MA0G
CSqGSIb3DQEBBQUAA4GBAHxbmAO03zsBkV9Rzg1DTKSd7sVOBh8BPDbhYDhHZFF0
695emFV48chUFzK7clurefYABp9b7wXnVCFqv3HF3fvaUEa+EOMZVVom3l/zXp7m
GvQLqh2JDUY6xs010vqeKaB3gJee9HoSVzhFnjzqYhtki6G2sQZu8SW9f/FH/9eh</ds:X509Certificate>
            </ds:X509Data>
         </ds:KeyInfo>


```
