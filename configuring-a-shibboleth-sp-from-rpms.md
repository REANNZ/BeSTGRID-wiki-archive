# Configuring a Shibboleth SP from RPMs

This page documents installing a Shibboleth SP from RPMS, instead of compiling from source code.  This is a much easier and faster way.

**This update is OUTDATED. Please see ****[Installing a Shibboleth 2.x SP](/wiki/spaces/BeSTGRID/pages/3818228742)** |

This page documents just the Shibboleth SP software installation - which is only one part of deploying a SP.  Please see the [MAMS SP installation guide](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallSP) for the remaining steps, including [registering your host in the federation](http://www.federation.org.au/FedManager/jsp/index.jsp).

# Basic Installation

Download RHEL 5 RPMS from [http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/1.3.1/RPMS/i386/RHE/5/](http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/1.3.1/RPMS/i386/RHE/5/)

- log4shib, opensaml, shibboleth-1.3.1,  xerces-c, xml-security-c

- Install all of them (for the sake of simplicity, including debuginfo, doc and devel sub-packages)


>  wget -r -np [http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/1.3.1/RPMS/i386/RHE/5/](http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/1.3.1/RPMS/i386/RHE/5/)
>  rpm -Uvh *.rpm
>  wget -r -np [http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/1.3.1/RPMS/i386/RHE/5/](http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/1.3.1/RPMS/i386/RHE/5/)
>  rpm -Uvh *.rpm

- This automatically installs the Shibboleth Apache (2.2) module, an Apache configuration file to load the module and configure Shibboleth, and protects "/secure" with shib-session required.

# Configure shibboleth

The following has to be changed in `/etc/shibboleth/shibboleth.xml`

- Entity Id
- Host Certificates
- Metadata
- WAYF

## Comparing RPM distribution shibboleth.xml vs. MAMS

- Library paths - use dist
- Host name = "sp.example.org" vs. MY_DNS - be careful about that


>  ***Path** ... MAMS has exportAssertion="true", use that.
>  ***Sessions** ... dist has consistentAddress="true" - let's keep it
>  ***SessionInitiator** dist has isDefault="true",
>  **Keep logoLocation and StyleSheet as /shibboleth-sp/** (dist)
>  ***Path** ... MAMS has exportAssertion="true", use that.
>  ***Sessions** ... dist has consistentAddress="true" - let's keep it
>  ***SessionInitiator** dist has isDefault="true",
>  **Keep logoLocation and StyleSheet as /shibboleth-sp/** (dist)

 **MAMS has MY_DNS as:*Host name**, **Site id**, **Applications providerId** **Applications homeURL**

## Changes Done in dist shibboleth.xml

- change hostname from sp.example.org to idp.canterbury.ac.nz (Host,Site,Applications)
- set ProviderId in Applications
- set path to credentials
- set certs to /etc/certs/aa-{key,cert}.pem and append CAPath elements for CAUDIT/AusCERT pilot hierarchy.
- NOTE: This does not work for installing a SP on an IdP: The IdP's AA certificates are Web Server only and won't work on a SP.  Either get a proper SP back-channel certificate, or use the general-purpose front-channel certificate.
- Thus, set certs to /etc/certs/host-{key,cert}.pem and append a CAPath element for ThawtePremiumServerCA.pem
- Pull in AAF L2 metadata: change MetadataProvider:uri to: 

``` 
uri="/etc/shibboleth/level-2-metadata.xml"
```
- add `exportAssertion="true"` to RequestMap->Host->Path
- set wayfURL="https://www.federation.org.au/level-2-wayf/WAYF"
- use https for receiving assertions: in the `Sessions` element, set: 

``` 
handlerSSL="true"
```
- set local initiator Location="/WAYF/level-2.federation.org.au"
- in the `Errors` element, set the `supportContact` element to your email address
- optionally, switch from POST to Artifact profile:

``` 

-                       <md:AssertionConsumerService Location="/SAML/POST" isDefault="true" index="1"
+                       <md:AssertionConsumerService Location="/SAML/POST" index="2"
                                Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post"/>
-                       <md:AssertionConsumerService Location="/SAML/Artifact" index="2"
+                       <md:AssertionConsumerService Location="/SAML/Artifact" isDefault="true" index="1"
                                Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01"/>

```

## Additional configuration

- Download Level-2 metadata

``` 
wget http://www.federation.org.au/level-2/level-2-metadata.xml -O /etc/shibboleth/level-2-metadata.xml
```
- Setup [metadata updates](/wiki/spaces/BeSTGRID/pages/3818228810#UpdatingFederationMetadata-UpdatingmetadataonaSP)

## Configure AAP

- Fetch [MAMS AAP.xml](http://www.federation.org.au/twiki/pub/Federation/ManualInstallSP/AAP.xml) and use it instead of dist AAP.xml
	
- Edit AAP.xml and remove `Scoped="true"` from eduPersonTargetedID definition - in order to make EPTID work.

# Start the Shibboleth Service

- Start and enable shibd service, and restart Apache


>  chkconfig shibd on
>  service shibd start
>  service httpd restart
>  chkconfig shibd on
>  service shibd start
>  service httpd restart

# Notes

- Note: Shibboleth SP will likely not work with SELinux.  See [https://wiki.shibboleth.net/confluence/display/SHIB/Security+Enhanced+Linux](https://wiki.shibboleth.net/confluence/display/SHIB/Security+Enhanced+Linux)
