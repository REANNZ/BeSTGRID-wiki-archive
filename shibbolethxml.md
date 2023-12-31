# Shibboleth.xml

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
		
		<!--
		<Extensions>
			<Library path="/usr/libexec/shib-mysql-ccache.so" fatal="false"/>
		</Extensions>
		-->
    
		<!-- Only one listener can be defined. -->
		   <UnixListener address="/var/run/shib-shar.sock"/>
		
		<!-- <TCPListener address="127.0.0.1" port="12345" acl="127.0.0.1"/> -->
		
		<!--
		See Wiki for details:
			cacheTimeout - how long before expired sessions are purged from the cache
			AATimeout - how long to wait for an AA to respond
			AAConnectTimeout - how long to wait while connecting to an AA
			defaultLifetime - if attributes come back without guidance, how long should they last?
			strictValidity - if we have expired attrs, and can't get new ones, keep using them?
			propagateErrors - suppress errors while getting attrs or let user see them?
			retryInterval - if propagateErrors is false and query fails, how long to wait before trying again
		Only one session cache can be defined.
		-->
		<MemorySessionCache cleanupInterval="300" cacheTimeout="3600" AATimeout="30" AAConnectTimeout="15"
			defaultLifetime="1800" retryInterval="300" strictValidity="false" propagateErrors="false"/>
		<!--
		<MySQLSessionCache cleanupInterval="300" cacheTimeout="3600" AATimeout="30" AAConnectTimeout="15"
			defaultLifetime="1800" retryInterval="300" strictValidity="false" propagateErrors="false"
			mysqlTimeout="14400" storeAttributes="false">
			<Argument>&#x2D;&#x2D;language=/usr/share/english</Argument>
			<Argument>&#x2D;&#x2D;datadir=/usr/data</Argument>
		</MySQLSessionCache>
		-->
        
		<!-- Default replay cache is in-memory. -->
		<!--
		<MySQLReplayCache>
			<Argument>&#x2D;&#x2D;language=/usr/share/english</Argument>
			<Argument>&#x2D;&#x2D;datadir=/usr/data</Argument>
		</MySQLReplayCache>
		-->
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
				<Host name="scooby.enarc.auckland.ac.nz" redirectToSSL="443">
					<Path name="wiki" authType="shibboleth" requireSession="false"/>
				</Host>
				
				<!-- Example shows the vhost "sp-admin.example.org" assigned to a separate <Application> -->
				<!--
				<Host name="sp-admin.example.org" applicationId="admin" redirectToSSL="443">
					<Path name="secure" authType="shibboleth" requireSession="true"/>
				</Host>
				-->
			</RequestMap>
		</RequestMapProvider>
		
		<Implementation>
			<ISAPI normalizeRequest="true">
				<!--
				Maps IIS Instance ID values to the host scheme/name/port/sslport. The name is
				required so that the proper <Host> in the request map above is found without
				having to cover every possible DNS/IP combination the user might enter.
				The port and scheme can	usually be omitted, so the HTTP request's port and
				scheme will be used.
				
				<Alias> elements can specify alternate permissible client-specified server names.
				If a client request uses such a name, normalized redirects will use it, but the
				request map processing is still based on the default name attribute for the
				site. This reduces duplicate data entry in the request map for every legal
				hostname a site might permit. In the example below, only sp.example.org needs a
				<Host> element in the map, but spalias.example.org could be used by a client
				and those requests will map to sp.example.org for configuration settings.
				-->
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
	<Applications id="default" providerId="urn:mace:UoAFederation:sp.scooby.enarc.auckland.ac.nz"
		homeURL="https://sp.example.org/index.html"
		xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion"
		xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">

		<!--
		Controls session lifetimes, address checks, cookie handling, and the protocol handlers.
		You MUST supply an effectively unique handlerURL value for each of your applications.
		The value can be a relative path, a URL with no hostname (https:///path) or a full URL.
		The system can compute a relative value based on the virtual host. Using handlerSSL="true"
		will force the protocol to be https. You should also add a cookieProps setting of "; path=/; secure"
		in that case. Note that while we default checkAddress to "false", this has a negative
		impact on the security of the SP. Certain attacks are a bit easier with this
		disabled. The consistentAddress property is even more critical, and should rarely be
		disabled. It will only trip if a client uses a different source address at the SP
		after the cookie is issued. Allowing that means many scripting attacks against
		applications can result in theft and impersonation using the Shibboleth session.
		-->
		<Sessions lifetime="7200" timeout="3600" checkAddress="false" consistentAddress="true"
			handlerURL="/Shibboleth.sso" handlerSSL="false" idpHistory="true" idpHistoryDays="7">
			
			<!--
			SessionInitiators handle session requests and relay them to a WAYF or directly
			to an IdP, if possible. Automatic session setup will use the default or first
			element (or requireSessionWith can specify a specific id to use). Lazy sessions
			can be started with any initiator by redirecting to it. The only Binding supported
			is the "urn:mace:shibboleth:sp:1.3:SessionInit" lazy session profile using query
			string parameters:
		         *  target      the resource to direct back to later (or homeURL will be used)
		         *  acsIndex    optional index of an ACS to use on the way back in
		         *  providerId  optional direct invocation of a specific IdP
			-->
			
			<!-- This default example directs users to a specific IdP's SSO service. -->
			<SessionInitiator  id="UoATestFedDirect" Location="/WAYF/idp.auckland.ac.nz"
				Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
				wayfURL="https://idp.auckland.ac.nz/shibboleth-idp/SSO"
				wayfBinding="urn:mace:shibboleth:1.0:profiles:AuthnRequest"/>
			<SessionInitiator isDefault="true" id="UoATestFedWayf" Location="/WAYF/testfed.auckland.ac.nz"
				Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
				wayfURL="https://testfed.auckland.ac.nz/shibboleth-wayf/WAYF"
				wayfBinding="urn:mace:shibboleth:1.0:profiles:AuthnRequest"/>
			
				
			<!-- This example directs users to a specific federation's WAYF service. -->
			<!--<SessionInitiator id="IQ" Location="/WAYF/InQueue"
				Binding="urn:mace:shibboleth:sp:1.3:SessionInit"
				wayfURL="https://wayf.internet2.edu/InQueue/WAYF"
				wayfBinding="urn:mace:shibboleth:1.0:profiles:AuthnRequest"/>-->
			
			<!--
			md:AssertionConsumerService elements replace the old shireURL function with an
			explicit handler for particular profiles, such as SAML 1.1 POST or Artifact.
			The isDefault and index attributes are used when sessions are initiated
			to determine how to tell the IdP where and how to return the response.
			-->
			<md:AssertionConsumerService Location="/SAML/POST" isDefault="true" index="1"
				Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post"/>
			<md:AssertionConsumerService Location="/SAML/Artifact" index="2"
				Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01"/>
			
			<!--
			md:SingleLogoutService elements are mostly a placeholder for 2.0, but a simple
			cookie-clearing option with a ResponseLocation or a return URL parameter is
			supported via the "urn:mace:shibboleth:sp:1.3:Logout" Binding value.
			-->
			<md:SingleLogoutService Location="/Logout" Binding="urn:mace:shibboleth:sp:1.3:Logout"/>

		</Sessions>

		<!--
		You should customize these pages! You can add attributes with values that can be plugged
		into your templates. You can remove the access attribute to cause the module to return a
		standard 403 Forbidden error code if authorization fails, and then customize that condition
		using your web server.
		-->
		<Errors session="/etc/shibboleth/sessionError.html"
			metadata="/etc/shibboleth/metadataError.html"
			rm="/etc/shibboleth/rmError.html"
			access="/etc/shibboleth/accessError.html"
			ssl="/etc/shibboleth/sslError.html"
			supportContact="e.jiang@auckland.ac.nz"
			logoLocation="/shibboleth-sp/logo.jpg"
			styleSheet="/shibboleth-sp/main.css"/>

		<!-- Indicates what credentials to use when communicating -->
		<CredentialUse TLS="urn:mace:UoATestFed" Signing="urn:mace:UoATestFed">
			<!-- RelyingParty elements can customize credentials for specific IdPs/sets. -->
			<!--<RelyingParty Name="urn:mace:inqueue" TLS="inqueuecreds" Signing="inqueuecreds"/>-->
			<RelyingParty Name="urn:mace:UoAFederation" TLS="UoATestFedCreds" Signing="UoATestFedCreds"/>
		</CredentialUse>
			
		<!-- Use designators to request specific attributes or none to ask for all -->
		<!--
		<saml:AttributeDesignator AttributeName="urn:mace:dir:attribute-def:eduPersonScopedAffiliation"
			AttributeNamespace="urn:mace:shibboleth:1.0:attributeNamespace:uri"/>
		-->

		<!-- AAP can be inline or in a separate file -->
		<AAPProvider type="edu.internet2.middleware.shibboleth.aap.provider.XMLAAP" uri="/etc/shibboleth/AAP.xml"/>
		
		<!-- Operational config consists of metadata and trust providers. Can be external or inline. -->

		<!-- Dummy metadata for private testing, delete for production deployments. -->
		<!--<MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
			uri="/etc/shibboleth/example-metadata.xml"/>-->

		<!-- InQueue pilot federation, delete for production deployments. -->
		<!--<MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
			uri="/etc/shibboleth/IQ-metadata.xml"/>-->
		
		<MetadataProvider type="edu.internet2.middleware.shibboleth.metadata.provider.XMLMetadata"
			uri="/etc/shibboleth/UoATestFed-metadata.xml"/>
		
		<!-- The standard trust provider supports SAMLv2 metadata with path validation extensions. -->
		<TrustProvider type="edu.internet2.middleware.shibboleth.common.provider.ShibbolethTrust"/>
					
		<!--
		Zero or more SAML Audience condition matches (mainly for Shib 1.1 compatibility).
		If you get "policy mismatch errors, you probably need to supply metadata about
		your SP to the IdP if it's running 1.2. Adding an element here is only a partial fix.
		-->
		<!--<saml:Audience>urn:mace:inqueue</saml:Audience>-->
		<saml:Audience>urn:mace:UoATestFed</saml:Audience>
		
		<!--
		You can customize behavior of specific applications here. The default elements inside the
		outer <Applications> element generally have to be overridden in an all or nothing fashion.
		That is, if you supply a <Sessions> or <Errors> override, you MUST include all attributes
		you want to apply, as they will not be inherited. Similarly, if you specify an element such as
		<MetadataProvider>, it is not additive with the defaults, but replaces them.
		
		Note that each application must have a handlerURL that maps uniquely to it and no other
		application in the <RequestMap>. Otherwise no sessions will reach the application.
		If each application lives on its own vhost, then a single handler at "/Shibboleth.sso"
		is sufficient, since the hostname will distinguish the application.
		
		The example below shows a special application that requires use of SSL when establishing
		sessions, restricts the session cookie to SSL, and inherits most other behavior except that
		it requests only EPPN from the IdP instead of asking for all attributes. Note that it will
		inherit all of the handler endpoints defined for the default application.
		-->
		<!-- 
		<Application id="admin">
			<Sessions lifetime="7200" timeout="3600" checkAddress="true" consistentAddress="true"
				handlerURL="/Shibboleth.sso" handlerSSL="true" cookieProps="; path=/; secure"/>
			<saml:AttributeDesignator AttributeName="urn:mace:dir:attribute-def:eduPersonPrincipalName"
				AttributeNamespace="urn:mace:shibboleth:1.0:attributeNamespace:uri"/>
		</Application>
		-->

	</Applications>
	
	<!-- Define all the private keys and certificates here that you reference from <CredentialUse>. -->
	<CredentialsProvider type="edu.internet2.middleware.shibboleth.common.Credentials">
		<Credentials xmlns="urn:mace:shibboleth:credentials:1.0">
			<!--<FileResolver Id="defcreds">
				<Key>
					<Path>/etc/shibboleth/sp-example.key</Path>
				</Key>
				<Certificate>
					<Path>/etc/shibboleth/sp-example.crt</Path>
				</Certificate>
			</FileResolver>-->
			
			<!--
			Mostly you can define a single keypair above, but you can define and name a second
			keypair to be used only in specific cases and then specify when to use it inside a
			<CredentialUse> element.
			-->
			<!--<FileResolver Id="inqueuecreds">
				<Key>
					<Path>/etc/shibboleth/inqueue.key</Path>
				</Key>
				<Certificate>
					<Path>/etc/shibboleth/inqueue.crt</Path>
				</Certificate>
			</FileResolver>-->

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

	<!-- Specialized attribute handling for cases with complex syntax. -->
	<AttributeFactory AttributeName="urn:oid:1.3.6.1.4.1.5923.1.1.1.10"
		type="edu.internet2.middleware.shibboleth.common.provider.TargetedIDFactory"/>

</SPConfig>

```
