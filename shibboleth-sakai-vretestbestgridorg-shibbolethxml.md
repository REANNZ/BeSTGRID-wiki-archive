# Shibboleth Sakai vre.test.bestgrid.org shibboleth.xml

``` 


<SPConfig xmlns="urn:mace:shibboleth:target:config:1.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="urn:mace:shibboleth:target:config:1.0 /usr/share/xml/shibboleth/shibboleth-targetconfig-1.0.xsd"
	logger="/etc/shibboleth/shibboleth.logger" clockSkew="180">

	<!-- These extensions are "universal", loaded by all Shibboleth-aware processes. -->
	<Extensions>
		<Library path="/usr/libexec/xmlproviders.so" fatal="true"/>
	</Extensions>

	<!-- The Global section pertains to shared Shibboleth processes like the shibd daemon. -->
	<Global logger="/etc/shibboleth/shibd.logger">
		
	   
		<!-- Only one listener can be defined. -->
		   <UnixListener address="/var/run/shib-shar.sock"/>
		
		<MemorySessionCache cleanupInterval="300" cacheTimeout="3600" AATimeout="30" AAConnectTimeout="15"
			defaultLifetime="1800" retryInterval="300" strictValidity="false" propagateErrors="false"/>

	</Global>
    
	<!-- The Local section pertains to resource-serving processes (often process pools) like web servers. -->
	<Local logger="/etc/shibboleth/native.logger" localRelayState="true">
		<!--
		To customize behavior, map hostnames and path components to applicationId and other settings.
		See: https://authdev.it.ohio-state.edu/twiki/bin/view/Shibboleth/RequestMap
		-->
		<RequestMapProvider type="edu.internet2.middleware.shibboleth.sp.provider.NativeRequestMapProvider">
			<RequestMap applicationId="default">
				<!--
				This requires a session for documents in /secure on the containing host with http and
				https on the default ports. Note that the name and port in the <Host> elements MUST match
				Apache's ServerName and Port directives or the IIS Site name in the <ISAPI> element
				below. You should also be sure that Apache's UseCanonicalName setting is On
				-->
				<Host name="vre.test.bestgrid.org">
					<Path name="secure" authType="shibboleth" requireSession="true"/>
				</Host>
				
			</RequestMap>
		</RequestMapProvider>
		
		<Implementation>
			<ISAPI normalizeRequest="true">
				<Site id="1" name="sp.example.org">
					<Alias>spalias.example.org</Alias>
				</Site>
			</ISAPI>
		</Implementation>
	</Local>

	<!--
	The Applications section is where most of Shibboleth's SAML bits are defined.
	Resource requests are mapped in the Local section into an applicationId that
	points into to this section.
	-->
	<Applications id="default" providerId="urn:mace:federation.org.au:bestgrid.org:vre.test.bestgrid.org"
		homeURL="https://vre.test.bestgrid.org"
		xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion"
		xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">


		<Sessions lifetime="86400" timeout="86400" checkAddress="false" consistentAddress="true"
			handlerURL="/Shibboleth.sso" handlerSSL="false" idpHistory="true" idpHistoryDays="7">
			

	               <SessionInitiator isDefault="true" id="BestGRIDwayf" Location="/WAYF/wayf.test.bestgrid.org"
                               Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
                              wayfURL="https://wayf.test.bestgrid.org/shibboleth-wayf/WAYF"
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
			supportContact="root@localhost"
			logoLocation="/shibboleth-sp/logo.jpg"
			styleSheet="/shibboleth-sp/main.css"/>

		<!-- Indicates what credentials to use when communicating -->
		<CredentialUse TLS="AAFCredLevel1" Signing="AAFCredLevel1">
			<!-- RelyingParty elements can customize credentials for specific IdPs/sets. -->
			<!--
			<RelyingParty Name="urn:mace:inqueue" TLS="inqueuecreds" Signing="inqueuecreds"/>
			-->
		</CredentialUse>
			

		<!-- AAP can be inline or in a separate file -->
		<AAPProvider type="edu.internet2.middleware.shibboleth.aap.provider.XMLAAP" uri="/etc/shibboleth/AAP.xml"/>
		
		<!-- Operational config consists of metadata and trust providers. Can be external or inline. -->

        <MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
                        uri="/etc/shibboleth/bestgrid-test-metadata.xml"/>
                        
        <MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
                        uri="/etc/shibboleth/level-1-metadata.xml"/>

		
		<!-- The standard trust provider supports SAMLv2 metadata with path validation extensions. -->
		<TrustProvider type="edu.internet2.middleware.shibboleth.common.provider.ShibbolethTrust"/>
					
		<!--
		Zero or more SAML Audience condition matches (mainly for Shib 1.1 compatibility).
		If you get "policy mismatch errors, you probably need to supply metadata about
		your SP to the IdP if it's running 1.2. Adding an element here is only a partial fix.
		-->
		<saml:Audience>urn:mace:inqueue</saml:Audience>
		

	</Applications>
	
	<!-- Define all the private keys and certificates here that you reference from <CredentialUse>. -->
	<CredentialsProvider type="edu.internet2.middleware.shibboleth.common.Credentials">
		<Credentials xmlns="urn:mace:shibboleth:credentials:1.0">
               <FileResolver Id="AAFCredLevel1">
                            <Key>
                                    <Path>/etc/shibboleth/certs/vre.test.bestgrid.org.key</Path>
                            </Key>
                            <Certificate>
                                    <Path>/etc/shibboleth/certs/vre.test.bestgrid.org_AAF-CA.crt</Path>
                            </Certificate>
                </FileResolver>

		</Credentials>
	</CredentialsProvider>

	<!-- Specialized attribute handling for cases with complex syntax. -->
	<AttributeFactory AttributeName="urn:oid:1.3.6.1.4.1.5923.1.1.1.10"
		type="edu.internet2.middleware.shibboleth.common.provider.TargetedIDFactory"/>

</SPConfig>




```
