# Shibboleth2.xml

``` 

<SPConfig xmlns="urn:mace:shibboleth:2.0:native:sp:config"
    xmlns:conf="urn:mace:shibboleth:2.0:native:sp:config"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"    
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    logger="syslog.logger" clockSkew="180">

    <!-- The OutOfProcess section contains properties affecting the shibd daemon. -->
    <OutOfProcess logger="shibd.logger">
        <!--
        <Extensions>
            <Library path="odbc-store.so" fatal="true"/>
        </Extensions>
        -->
    </OutOfProcess>
    
    <!-- The InProcess section conrains settings affecting web server modules/filters. -->
    <InProcess logger="native.logger">
        <ISAPI normalizeRequest="true" safeHeaderNames="true">
            <!--
            Maps IIS Instance ID values to the host scheme/name/port. The name is
            required so that the proper <Host> in the request map above is found without
            having to cover every possible DNS/IP combination the user might enter.
            -->
            <Site id="1" name="nzfed.auckland.ac.nz" scheme="https" port="443"/>
            <!--
            When the port and scheme are omitted, the HTTP request's port and scheme are used.
            If these are wrong because of virtualization, they can be explicitly set here to
            ensure proper redirect generation.
            -->
            <!--
            <Site id="42" name="virtual.example.org" scheme="https" port="443"/>
            -->
        </ISAPI>
    </InProcess>

    <!-- Only one listener can be defined, to connect in-process modules to shibd. -->
    <UnixListener address="shibd.sock"/>
    <!-- <TCPListener address="127.0.0.1" port="12345" acl="127.0.0.1"/> -->
    
    <!-- This set of components stores sessions and other persistent data in daemon memory. -->
    <StorageService type="Memory" id="mem" cleanupInterval="900"/>
    <SessionCache type="StorageService" StorageService="mem" cacheTimeout="3600" inprocTimeout="900" cleanupInterval="900"/>
    <ReplayCache StorageService="mem"/>
    <ArtifactMap artifactTTL="180"/>

    <!-- This set of components stores sessions and other persistent data in an ODBC database. -->
    <!--
    <StorageService type="ODBC" id="db" cleanupInterval="900">
        <ConnectionString>
        DRIVER=drivername;SERVER=dbserver;UID=shibboleth;PWD=password;DATABASE=shibboleth;APP=Shibboleth
        </ConnectionString>
    </StorageService>
    <SessionCache type="StorageService" StorageService="db" cacheTimeout="3600" inprocTimeout="900" cleanupInterval="900"/>
    <ReplayCache StorageService="db"/>
    <ArtifactMap StorageService="db" artifactTTL="180"/>
    -->

    <!-- To customize behavior, map hostnames and path components to applicationId and other settings. -->
    <RequestMapper type="Native">
        <RequestMap applicationId="default">
            <!--
            The example requires a session for documents in /secure on the containing host with http and
            https on the default ports. Note that the name and port in the <Host> elements MUST match
            Apache's ServerName and Port directives or the IIS Site name in the <ISAPI> element
            below.
            -->
            <Host name="nzfed.auckland.ac.nz">
                <Path name="secure" authType="shibboleth" requireSession="true"/>
            </Host>
            <!-- Example of a second vhost mapped to a different applicationId. -->
            <!-- Host name="nzfed.auckland.ac.nz" applicationId="admin" authType="shibboleth" requireSession="false"/ -->
        </RequestMap>
    </RequestMapper>

    <!--
    The ApplicationDefaults element is where most of Shibboleth's SAML bits are defined.
    Resource requests are mapped by the RequestMapper to an applicationId that
    points into to this section.
    -->
    <ApplicationDefaults id="default" policyId="default"
        entityID="https://nzfed.auckland.ac.nz/shibboleth"
        REMOTE_USER="eppn persistent-id targeted-id"
        signing="false" encryption="false">

        <!--
        Controls session lifetimes, address checks, cookie handling, and the protocol handlers.
        You MUST supply an effectively unique handlerURL value for each of your applications.
        The value can be a relative path, a URL with no hostname (https:///path) or a full URL.
        The system can compute a relative value based on the virtual host. Using handlerSSL="true"
        will force the protocol to be https. You should also add a cookieProps setting of "; path=/; secure"
        in that case. Note that while we default checkAddress to "false", this has a negative
        impact on the security of the SP. Stealing cookies/sessions is much easier with this disabled.
        -->
        <Sessions lifetime="28800" timeout="3600" checkAddress="false"
            handlerURL="/Shibboleth.sso" handlerSSL="true"
            exportLocation="http://localhost/Shibboleth.sso/GetAssertion" exportACL="127.0.0.1"
            idpHistory="false" idpHistoryDays="7">
            
            <!--
            SessionInitiators handle session requests and relay them to a Discovery page,
            or to an IdP if possible. Automatic session setup will use the default or first
            element (or requireSessionWith can specify a specific id to use).
            -->

            <!-- Default example directs to a specific IdP's SSO service (favoring SAML 2 over Shib 1). -->
            <!-- SessionInitiator type="Chaining" Location="/Login" isDefault="true" id="Intranet"
                    relayState="cookie" entityID="urn:mace:bestgrid.org:auckland.ac.nz">
                <SessionInitiator type="SAML2" defaultACSIndex="1" template="bindingTemplate.html"/>
                <SessionInitiator type="Shib1" defaultACSIndex="5"/>
            </SessionInitiator -->
            
            <!-- An example using an old-style WAYF, which means Shib 1 only unless an entityID is provided. -->
            <SessionInitiator type="Chaining" Location="/WAYF" id="WAYF" relayState="cookie">
                <SessionInitiator type="SAML2" defaultACSIndex="1" template="bindingTemplate.html"/>
                <SessionInitiator type="Shib1" defaultACSIndex="5"/>
                <SessionInitiator type="WAYF" defaultACSIndex="5" URL="https://wayf.bestgrid.org/shibboleth-wayf/WAYF"/>
            </SessionInitiator>

            <!-- An example supporting the new-style of discovery service. -->
            <!-- SessionInitiator type="Chaining" Location="/DS" id="DS" relayState="cookie">
                <SessionInitiator type="SAML2" defaultACSIndex="1" template="bindingTemplate.html"/>
                <SessionInitiator type="Shib1" defaultACSIndex="5"/>
                <SessionInitiator type="SAMLDS" URL="https://ds.example.org/DS/WAYF"/>
            </SessionInitiator -->
            
            <!--
            md:AssertionConsumerService locations handle specific SSO protocol bindings,
            such as SAML 2.0 POST or SAML 1.1 Artifact. The isDefault and index attributes
            are used when sessions are initiated to determine how to tell the IdP where and
            how to return the response.
            -->
            <md:AssertionConsumerService Location="/SAML2/POST" index="1"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
            <md:AssertionConsumerService Location="/SAML2/POST-SimpleSign" index="2"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign"/>
            <md:AssertionConsumerService Location="/SAML2/Artifact" index="3"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>
            <md:AssertionConsumerService Location="/SAML2/ECP" index="4"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:PAOS"/>
            <md:AssertionConsumerService Location="/SAML/POST" index="5"
                Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post"/>
            <md:AssertionConsumerService Location="/SAML/Artifact" index="6"
                Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01"/>

            <!-- LogoutInitiators enable SP-initiated local or global/single logout of sessions. -->
            <LogoutInitiator type="Chaining" Location="/Logout" relayState="cookie">
                <LogoutInitiator type="SAML2" template="bindingTemplate.html"/>
                <LogoutInitiator type="Local"/>
            </LogoutInitiator>

            <!-- md:SingleLogoutService locations handle single logout (SLO) protocol messages. -->
            <md:SingleLogoutService Location="/SLO/SOAP"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>
            <md:SingleLogoutService Location="/SLO/Redirect" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"/>
            <md:SingleLogoutService Location="/SLO/POST" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
            <md:SingleLogoutService Location="/SLO/Artifact" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>

            <!-- md:ManageNameIDService locations handle NameID management (NIM) protocol messages. -->
            <md:ManageNameIDService Location="/NIM/SOAP"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>
            <md:ManageNameIDService Location="/NIM/Redirect" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"/>
            <md:ManageNameIDService Location="/NIM/POST" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
            <md:ManageNameIDService Location="/NIM/Artifact" conf:template="bindingTemplate.html"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>

            <!--
            md:ArtifactResolutionService locations resolve artifacts issued when using the
            SAML 2.0 HTTP-Artifact binding on outgoing messages, generally uses SOAP.
            -->
            <md:ArtifactResolutionService Location="/Artifact/SOAP" index="1"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>

            <!-- Extension service that generates "approximate" metadata based on SP configuration. -->
            <Handler type="MetadataGenerator" Location="/Metadata" signing="false"/>

            <!-- Status reporting service. -->
            <Handler type="Status" Location="/Status" acl="127.0.0.1"/>

            <!-- Session diagnostic service. -->
            <Handler type="Session" Location="/Session" showAttributeValues="false"/>

        </Sessions>

        <!--
        You should customize these pages! You can add attributes with values that can be plugged
        into your templates. You can remove the access attribute to cause the module to return a
        standard 403 Forbidden error code if authorization fails, and then customize that condition
        using your web server.
        -->
        <Errors session="sessionError.html"
            metadata="metadataError.html"
            access="accessError.html"
            ssl="sslError.html"
            localLogout="localLogout.html"
            globalLogout="globalLogout.html"
            supportContact="root@localhost"
            logoLocation="/shibboleth-sp/logo.jpg"
            styleSheet="/shibboleth-sp/main.css"/>
        
        <!-- Uncomment and modify to tweak settings for specific IdPs or groups. -->
        <!-- <RelyingParty Name="SpecialFederation" keyName="SpecialKey"/> -->

        <!-- Chains together all your metadata sources. -->
        <MetadataProvider type="Chaining">
            <!-- Example of remotely supplied batch of signed metadata. -->
            <MetadataProvider type="XML" uri="https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml"
                 backingFilePath="bestgrid-metadata.xml" reloadInterval="7200">
               <!-- MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/ -->
               <!-- MetadataFilter type="Signature" certificate="fedsigner.pem"/ -->
            </MetadataProvider>

            <!-- Example of locally maintained metadata. -->
            <!--
            <MetadataProvider type="XML" file="partner-metadata.xml"/>
            -->
        </MetadataProvider>

        <!-- Chain the two built-in trust engines together. -->
        <TrustEngine type="Chaining">
            <TrustEngine type="ExplicitKey"/>
            <TrustEngine type="PKIX"/>
        </TrustEngine>

        <!-- Map to extract attributes from SAML assertions. -->
        <AttributeExtractor type="XML" path="attribute-map.xml"/>
        
        <!-- Use a SAML query if no attributes are supplied during SSO. -->
        <AttributeResolver type="Query"/>

        <!-- Default filtering policy for recognized attributes, lets other data pass. -->
        <AttributeFilter type="XML" path="attribute-policy.xml"/>

        <!-- Simple file-based resolver for using a single keypair. -->
        <CredentialResolver type="File" key="sp-key.pem" certificate="sp-cert.pem"/>

        <!-- Example of a second application (using a second vhost) that has a different entityID. -->
        <!-- <ApplicationOverride id="admin" entityID="https://admin.example.org/shibboleth"/> -->

    </ApplicationDefaults>
    
    <!-- Each policy defines a set of rules to use to secure messages. -->
    <SecurityPolicies>
        <!--
        The predefined policy enforces replay/freshness, standard
        condition processing, and permits signing and client TLS.
        -->
        <Policy id="default" validate="false">
            <PolicyRule type="MessageFlow" checkReplay="true" expires="60"/>
            <PolicyRule type="Conditions">
                <PolicyRule type="Audience"/>
                <!-- Enable Delegation rule to permit delegated access. -->
                <!-- <PolicyRule type="Delegation"/> -->
            </PolicyRule>
            <PolicyRule type="ClientCertAuth" errorFatal="true"/>
            <PolicyRule type="XMLSigning" errorFatal="true"/>
            <PolicyRule type="SimpleSigning" errorFatal="true"/>
        </Policy>
    </SecurityPolicies>

</SPConfig>

```
