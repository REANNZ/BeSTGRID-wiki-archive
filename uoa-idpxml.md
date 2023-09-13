# Uoa idp.xml

``` 

<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- Shibboleth Identity Provider configuration -->

	<IdPConfig 
	xmlns="urn:mace:shibboleth:idp:config:1.0" 
	xmlns:cred="urn:mace:shibboleth:credentials:1.0" 
	xmlns:name="urn:mace:shibboleth:namemapper:1.0" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:schemaLocation="urn:mace:shibboleth:idp:config:1.0 ../schemas/shibboleth-idpconfig-1.0.xsd" 
	AAUrl="https://idp-test.auckland.ac.nz:8443/shibboleth-idp/AA" 
	resolverConfig="file:/usr/local/shibboleth-idp/etc/resolver.ldap.xml"
	defaultRelyingParty="urn:mace:bestgrid" 
	providerId="urn:mace:bestgrid:idp-test.auckland.ac.nz">


	<!-- This section contains configuration options that apply only to a site or group of sites
		This would normally be adjusted when a new federation or bilateral trust relationship is established -->
	<RelyingParty name="urn:mace:bestgrid" signingCredential="bestgrid" providerId="urn:mace:bestgrid:idp-test.auckland.ac.nz">
                <NameID nameMapping="shm"/> <!-- (nameMapping) must correspond to a <NameMapping/> element below -->
		<!-- <NameID nameMapping="hashib_mapping"/>-->
        </RelyingParty>

	<RelyingParty name="urn:mace:federation.org.au:testfed:level-1" signingCredential="aaf" providerId="urn:mace:federation.org.au:level-1:auckland.ac.nz">
              <NameID nameMapping="shm"/> 
		<!-- <NameID nameMapping="hashib_mapping"/>-->
        </RelyingParty>

	<!-- Configuration for the attribute release policy engine
		For most configurations this won't need adjustment -->
	 <ReleasePolicyEngine>
                <ArpRepository implementation="edu.internet2.middleware.shibboleth.aa.arp.provider.FileSystemArpRepository">
                        <Path>file:/usr/local/shibboleth-idp/etc/arps/</Path>
                </ArpRepository>
        </ReleasePolicyEngine>

	
    <!-- Logging Configuration
		The defaults work fine in this section, but it is sometimes helpful to use "DEBUG" as the level for 
		the <ErrorLog/> when trying to diagnose problems -->
	<Logging>
		<ErrorLog level="DEBUG" location="file:/usr/local/shibboleth-idp/logs/shib-error.log" />
		<TransactionLog level="DEBUG" location="file:/usr/local/shibboleth-idp/logs/shib-access.log" />
	</Logging>
	<!-- Uncomment the configuration section below and comment out the one above if you would like to manually configure log4j -->
    <!--
	<Logging>
		<Log4JConfig location="file:///tmp/log4j.properties" />
	</Logging> -->


	<!-- This configuration section determines how Shibboleth maps between SAML Subjects and local principals.
		The default mapping uses shibboleth handles, but other formats can be added.
		The mappings listed here are only active when they are referenced within a <RelyingParty/> element above -->
	<NameMapping 
		xmlns="urn:mace:shibboleth:namemapper:1.0" 
		id="shm" 
		format="urn:mace:shibboleth:1.0:nameIdentifier" 
		type="SharedMemoryShibHandle" 
		handleTTL="28800"/>

	 <!-- This configuration is for HAShib -->
       <!-- <NameMapping xmlns="urn:mace:shibboleth:namemapper:1.0"
             id="hashib_mapping"
             format="urn:mace:shibboleth:1.0:nameIdentifier"
             class="edu.georgetown.middleware.shibboleth.idp.ha.nameIdentifier.ReplicatedHandleMapper"/>
	-->

	<!-- Determines how SAML artifacts are stored and retrieved
		The (sourceLocation) attribute must be specified when using type 2 artifacts -->
	<ArtifactMapper implementation="edu.internet2.middleware.shibboleth.artifact.provider.MemoryArtifactMapper" />
	 <!-- HA Shib Artifact Mapper -->
        <!--<ArtifactMapper implementation="edu.georgetown.middleware.shibboleth.idp.ha.artifact.ReplicatedArtifactMapper" />-->



	<!-- This configuration section determines the keys/certs to be used when signing SAML assertions -->
	<!-- The credentials listed here are used when referenced within <RelyingParty/> elements above -->
	<Credentials xmlns="urn:mace:shibboleth:credentials:1.0">
		<FileResolver Id="aaf">
			<Key format="PEM">
				<Path>file:/usr/local/shibboleth-idp/etc/certs/server.key</Path>
			</Key>
			<Certificate format="PEM">
				<Path>file:/usr/local/shibboleth-idp/etc/certs/idp-test.auckland.ac.nz_AAF-CA.crt</Path>
			</Certificate>
		</FileResolver>
              <FileResolver Id="bestgrid">
                        <Key format="PEM">
                                <Path>file:/usr/local/shibboleth-idp/etc/certs/server.key</Path>
                        </Key>
                        <Certificate format="PEM">
                                <Path>file:/usr/local/shibboleth-idp/etc/certs/idp-test.auckland.ac.nz_BeSTGRID-CA.crt</Path>
                        </Certificate>
                </FileResolver>

	</Credentials>


	<!-- Protocol handlers specify what type of requests the IdP can respond to.  The default set listed here should work 
		for most configurations.  Modifications to this section may require modifications to the deployment descriptor -->
	<ProtocolHandler implementation="edu.internet2.middleware.shibboleth.idp.provider.ShibbolethV1SSOHandler">
		<Location>https?://[^:/]+(:(443|80))?/shibboleth-idp/SSO</Location> <!-- regex works when using default protocol ports -->
	</ProtocolHandler>
	<ProtocolHandler implementation="edu.internet2.middleware.shibboleth.idp.provider.SAMLv1_AttributeQueryHandler">
		<Location>.+:8443/shibboleth-idp/AA</Location>
	</ProtocolHandler>
	<ProtocolHandler implementation="edu.internet2.middleware.shibboleth.idp.provider.SAMLv1_1ArtifactQueryHandler">
		<Location>.+:8443/shibboleth-idp/Artifact</Location>
	</ProtocolHandler>
	<ProtocolHandler implementation="edu.internet2.middleware.shibboleth.idp.provider.Shibboleth_StatusHandler">
		<Location>https://[^:/]+(:443)?/shibboleth-idp/Status</Location>
	</ProtocolHandler>
	 <ProtocolHandler implementation="nz.ac.auckland.middleware.shibboleth.idp.provider.WebLogicShibbolethV1SSOHandler">
     		<Location>https?://[^:/]+(:(443|80))?/shibboleth-idp/WebLogicSSO</Location> <!-- regex works when using default protocol ports -->
  	</ProtocolHandler>
	
	<!-- This section configures the loading of SAML2 metadata, which contains information about system entities and 
		how to authenticate them.  The metadatatool utility can be used to keep federation metadata files in synch.
		Metadata can also be placed directly within this these elements. -->
	<MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
               uri="file:/usr/local/shibboleth-idp/etc/bestgrid-test-metadata.xml"/>
        <MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
                uri="file:/usr/local/shibboleth-idp/etc/level-1-metadata.xml"/>

</IdPConfig>



```
