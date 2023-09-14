# Configuring IdP for SLCS certificates

This page lists the configuration steps that must be done to let an already configured IdP join the ARCS SLCS operation and let the users start using SLCS certificates.

The steps are:

- Configure the SharedToken and Organization attributes
	
- The other required attributes needed are Common Name and Email address - these are likely to be already configured.
- Include the SLCS server metadata on the IdP.
- Ask the SLCS server administrator (Sam Morrison) to trust your IdP on the SLCS server.
	
- Give him also the statically configured Organization attribute and ask him to configure this Organization for the New Zealand DN namespace.
- Download the SLCS client application.
	
- If your IdP has Autograph installed, configure the application to use the `/shibboleth/IdP` SSO URL instead of `/shibboleth/SSO`
- Install the SLCS CA root certificate on your grid gateway (including the GUMS server).

# Shared Token attribute

There are two approaches to providing the SharedToken attribute - either Federation Managed (FAST) or Institution Managed (IMAST).  Both are documented at [http://www.aaf.edu.au/documentation](http://www.aaf.edu.au/documentation).  

The advantages of FAST are:

- Reliable central storage.
- Easier transfer of SharedToken among institutions (when a researcher moves to a different site).
- A central mechanism for avoiding hash collisions (keep tokens unique).

The advantages of IMAST would be:

- Not dependent on a single point of failure.

***IMPORTANT***: do not install FAST, install IMAST instead - follow the [ARCS IMAST instructions](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallIdP/IdP-Installation-CentOS5/IMAST-Installation)

This page documents how to configure the SharedToken attributes based on the FAST approach - but IMAST would work the same well (if the new encoding avoiding problematic characters is implemented).

- Follow the [ARCS IdP documentation](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallIdP/IdP-Installation-CentOS5) and README inside [FAST-idp.zip](http://www.mams.org.au/downloads/FAST-idp.zip)
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
	
- If no 

``` 
<AttributeDependency>
```

 is provided, FAST will use just the IdP and user identification - but that is perfectly sufficient.


# Organization attribute

To use the SLCS service, it is necessary to configure the Organization attribute to be defined for each user with a static value (like `"University of Canterbury"`).  It might also be desirable to configure the Country attribute with the value of "NZ".  Following the [StaticDataConnector documentation](https://spaces.internet2.edu/display/SHIB/StaticDataConnector), add the following into `resolver.ldap.xml`:

>             University of Canterbury
>             NZ

If you are using Autograph, add the following into `/usr/local/shibboleth-autograph/connectorConfigs/AttributeInfoPointData.xml`:

>                         organization
>                         no description
>                         location (country)
>                         no description

Please note that earlier versions of Autograph could not handle a StaticDataConnector.  You may need an updated `shib-java.jar`, or better a newer version of Autograph.  You may get these either from Stuart Allen (MELCOE), or from the author of this documentation (Vladimir Mencl).

If you are not using Autograph, configure the release of these attributes for the target SP in the site's Attribute Release Policies (ARPs).

# SLCS server metadata

Because `slcs1.arcs.org.au` is only registered at Level 1, I had to manually add a mini-federation with the SLCS SP metadata:

- Create `extra-metadata.xml` - take level-1-metadata.xml and keep only
	
- Testbed Federation Level 1 CA's 

``` 
<ds:KeyInfo>
```
- ``` 
<EntityDescriptor entityID="urn:mace:federation.org.au:testfed:slcs1.arcs.org.au">
```
- Change OrganizationDisplayName from "VPAC" to "ARCS SLCS server" to distinguish it in Autograph from other VPAC's entries.
- Include the file in idp.xml:


- For new version Autograph, also embed the Service Provider Description (SPD) inside the metadata

You may download the attached file [extra-metadata.xml](/wiki/download/attachments/3818228428/Extra-metadata.xml.txt?version=1&modificationDate=1539354128000&cacheVersion=1&api=v2).

# Registration with SLCS server administrator

- Ask Sam Morrison to allow your IdP to access the SLCS server.
- Give him the value configured for the Organization static attribute and ask him to configure that for the NZ BeSTGRID namespace.

# Testing the SLCS service

- Access the service via [https://slcs1.arcs.org.au/SLCS/login](https://slcs1.arcs.org.au/SLCS/login)
- If the service is still in Level 1 federation and your IdP is in Level 2, go to the [Level 2 WAYF URL](https://level-2.federation.org.au/level-2-wayf/WAYF?shire=https%3A%2F%2Fslcs1.arcs.org.au%2FShibboleth.sso%2FSAML%2FArtifact&target=cookie&providerId=urn%3Amace%3Afederation.org.au%3Atestfed%3Aslcs1.arcs.org.au)

# SLCS client application

- Follow the [ARCS instructions for installing the SLCS command-line client](http://projects.arcs.org.au/trac/slcs-client/wiki/CommandLineClient).
- After the build, untar the file `glite-slcs-ui-1.3.2-jdk1.6.tar.gz` somewhere.
- Within the extracted directory, edit the metadata in `etc/glite-slcs-ui/slcs-metadata.aaf.xml`
	
- Enter [https://slcs1.arcs.org.au/SLCS/login](https://slcs1.arcs.org.au/SLCS/login) as the Service Provider.
- Create a configuration entry for your IdP
		
- If you have Autograph installed, configure your IdP with the location `/shibboleth-idp/IdP` instead of `/shibboleth-idp/SSO`
			
- Because the new version Autograph redirection servlet always redirects /Autograph/ConfigurationDecision and automated tools may not be able to handle the sequence of redirects, it is necessary to point them to `/shibboleth-idp/IdP` (instead of `/shibboleth-idp/SSO`) - which goes straight to the IdP SSO login,  bypassing Autograph-related redirects.
- Edit `etc/glite-slcs-ui/slcs-init.xml` and change the path to `etc/glite-slcs-ui/truststore.aaf.jks` - by default, it assumes you untarred the distribution in `/opt/glite`

Finally, in the bin directory, run

>  ./slcs-init -i canterbury.ac.nz -u YOUR-USER-ID -p YOUR-SHIB-PASSWORD -k PASSPHRASE

- replace the `-i` parameter with your IdP id as defined in the metadata.

# SLCS-enabled Grix and Grisu

- The Shibboleth-enabled version of Grix is available at [http://grix.arcs.org.au/downloads/webstart/grix.jnlp](http://grix.arcs.org.au/downloads/webstart/grix.jnlp)

- The Shibboleth-enabled version of Grisu is available as the current snapshot at [http://grisu.arcs.org.au/downloads/beta/webstart/grisu-snapshot.jnlp](http://grisu.arcs.org.au/downloads/beta/webstart/grisu-snapshot.jnlp)

- These are both preliminary versions under development - use with care.  As of now, they only list Level 1 IdPs - stay tuned for updates.

# SLCS CA root certificate

- Follow the [ARCS SLCS instructions](http://wiki.arcs.org.au/bin/view/Main/SLCS) and download the CA tarball from [http://www.arcs.org.au/slcs/arcs-slcs-ca.tar.gz](http://www.arcs.org.au/slcs/arcs-slcs-ca.tar.gz)
- Install the CA bundle on:
- **Your job submission gateways (ng2**)
	
- Your GUMS server (nggums) - if applicable.

# Pending issues

- The SLCS server occasionally fails and the SLCS client tool prints


>  Shibboleth Authentication Failed.
>  Shibboleth Authentication Failed.

- The shibd logs on the SLCS server contain the following message (after successfully going through one Artifact resolution query):


>  2008-09-12 14:45:19 ERROR SAML.SAMLSOAPHTTPBinding [511](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=511&linkCreation=true&fromPageId=3818228428) sessionNew: failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression
>  2008-09-12 14:45:19 ERROR shibd.Listener [511](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=511&linkCreation=true&fromPageId=3818228428) sessionNew: caught exception while creating session: SOAPHTTPBindingProvider::send() failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression
>  2008-09-12 14:45:19 ERROR SAML.SAMLSOAPHTTPBinding [511](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=511&linkCreation=true&fromPageId=3818228428) sessionNew: failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression
>  2008-09-12 14:45:19 ERROR shibd.Listener [511](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=511&linkCreation=true&fromPageId=3818228428) sessionNew: caught exception while creating session: SOAPHTTPBindingProvider::send() failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression

- Wireshark shows the message to be "SSLv3 Alert: Decompression failure"
- This is documented as a known problem with decompression at [http://www.davidpashley.com/blog/debian/libssl-bad-decompression](http://www.davidpashley.com/blog/debian/libssl-bad-decompression)
- However, updating openssl to openssl-0.9.8b-8.3.el5_0.2 did not help.

- This problem occurred so far twice:
	
- Once it went away after moving the IdP to a new system (RHEL based, with openssl-0.9.8b-10.el5, just slightly newer then the old CentOS-based IdP)
- It reoccurred once, and was solved by restarting shibd on the SLCS server.
- The problem is likely to occur again: however, no permanent solution has been found yet.  It might help to configure Apache on the IdP to only accept SSLv2 ciphers, where no compression is available.
