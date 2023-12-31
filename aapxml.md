# AAP.xml

``` 

<AttributeAcceptancePolicy xmlns="urn:mace:shibboleth:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="urn:mace:shibboleth:1.0 /usr/share/xml/shibboleth/shibboleth.xsd">

	<!--
	An AAP is a set of AttributeRule elements, each one
	referencing a specific attribute by URI. All attributes that
	should be visible to an application running at the target should
	be listed, or they will be filtered out.
	
	The Header and Alias attributes map an attribute to an HTTP header
	and to an htaccess rule name respectively. Without Header, the attribute
	will only be obtainable from the exported SAML assertion in raw XML.
	
	Scoped attributes can also be filtered on Scope via rules in the
	asserting identity provider's metadata.
	
	Finally, a note on naming. The attributes in this file are mostly drawn from
	the set documented here:
	
	http://middleware.internet2.edu/urn-mace/urn-mace-dir-attribute-def.html
	
	The	actual naming convention most of them follow is NOT to be used for
	any subsequent attributes bound to SAML, and you are NOT free to just
	make up names using it, because the urn:mace:dir namespace tree is
	controlled. For help and advice on defining new attributes, refer to:
	
	https://authdev.it.ohio-state.edu/twiki/bin/view/Shibboleth/AttributeNaming
	-->
	
	<!-- First some useful eduPerson attributes that many sites might use. -->

	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonScopedAffiliation" Scoped="true" CaseSensitive="false" Header="Shib-EP-Affiliation" Alias="affiliation">
		<!-- Filtering rule to limit values to eduPerson-defined enumeration. -->
        <AnySite>
            <Value>MEMBER</Value>
            <Value>FACULTY</Value>
            <Value>STUDENT</Value>
            <Value>STAFF</Value>
            <Value>ALUM</Value>
            <Value>AFFILIATE</Value>
            <Value>EMPLOYEE</Value>
        </AnySite>
        
        <!-- Example of Scope rule to override site metadata. -->
        <SiteRule Name="urn:mace:inqueue:shibdev.edu">
        	<Scope Accept="false">shibdev.edu</Scope>
        	<Scope Type="regexp">^.+\.shibdev\.edu$</Scope>
        </SiteRule>
	</AttributeRule>

	<!--
	This attribute is provided mostly to ease testing because an IdP out of the box only
	sends the unscoped version. It has little use because it lacks the context needed to
	work in a multi-domain scenario and is a subset of the scoped version anyway.
	 -->
	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonAffiliation" CaseSensitive="false" Header="Shib-EP-UnscopedAffiliation" Alias="unscoped-affiliation">
        <AnySite>
            <Value>MEMBER</Value>
            <Value>FACULTY</Value>
            <Value>STUDENT</Value>
            <Value>STAFF</Value>
            <Value>ALUM</Value>
            <Value>AFFILIATE</Value>
            <Value>EMPLOYEE</Value>
        </AnySite>
	</AttributeRule>
	
    <AttributeRule Name="urn:mace:dir:attribute-def:eduPersonPrincipalName" Scoped="true" Header="REMOTE_USER" Alias="user">
		<!-- Basic rule to pass through any value. -->
        <AnySite>
            <Value Type="regexp">^[^@]+$</Value>
        </AnySite>
    </AttributeRule>


	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonEntitlement" Header="Shib-EP-Entitlement" Alias="entitlement">
		<!-- Entitlements tend to be filtered per-site. -->
		
		<!--
		Optional site rule that applies to any site
		<AnySite>
			<Value>urn:mace:example.edu:exampleEntitlement</Value>
		</AnySite>
		-->
		
		<!-- Specific rules for an origin site, these are just development/sample sites. -->
		<SiteRule Name="urn:mace:inqueue:example.edu">
			<Value Type="regexp">^urn:mace:.+$</Value>
		</SiteRule>
		<SiteRule Name="urn:mace:inqueue:shibdev.edu">
			<Value Type="regexp">^urn:mace:.+$</Value>
		</SiteRule>
	</AttributeRule>

	<!-- A persistent id attribute that supports personalized anonymous access. -->
	
	<!-- First, the deprecated version: -->
	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonTargetedID" Scoped="true" Header="Shib-TargetedID" Alias="targeted_id">
        <AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>

	<!-- Second, the new version (note the OID-style name): -->
	<AttributeRule Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10" Header="Shib-TargetedID" Alias="targeted_id">
        <AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<!-- Some more eduPerson attributes, uncomment these to use them... -->
	
	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonNickname">
        <AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>

	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonPrimaryAffiliation" CaseSensitive="false" Header="Shib-EP-PrimaryAffiliation">
        <AnySite>
            <Value>MEMBER</Value>
            <Value>FACULTY</Value>
            <Value>STUDENT</Value>
            <Value>STAFF</Value>
            <Value>ALUM</Value>
            <Value>AFFILIATE</Value>
            <Value>EMPLOYEE</Value>
        </AnySite>
	</AttributeRule>
	
<!--
	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonPrimaryOrgUnitDN" Header="Shib-EP-PrimaryOrgUnitDN">
        <AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonOrgUnitDN" Header="Shib-EP-OrgUnitDN">
        <AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:eduPersonOrgDN" Header="Shib-EP-OrgDN">
        <AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>

	-->


	<!--Examples of common LDAP-based attributes, uncomment to use these... -->
	<!--
	
	<AttributeRule Name="urn:mace:dir:attribute-def:cn" Header="Shib-Person-commonName">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	-->
	
	<AttributeRule Name="urn:mace:dir:attribute-def:sn" Header="Shib-Person-surname"  Alias="surname" CaseSensitive="false">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>


	<AttributeRule Name="urn:mace:dir:attribute-def:mail" Header="Shib-InetOrgPerson-mail"  Alias="email">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	<!--	
	<AttributeRule Name="urn:mace:dir:attribute-def:telephoneNumber" Header="Shib-Person-telephoneNumber">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:title" Header="Shib-OrgPerson-title">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:initials" Header="Shib-InetOrgPerson-initials">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:description" Header="Shib-Person-description">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:carLicense" Header="Shib-InetOrgPerson-carLicense">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:departmentNumber" Header="Shib-InetOrgPerson-deptNum">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:displayName" Header="Shib-InetOrgPerson-displayName">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:employeeNumber" Header="Shib-InetOrgPerson-employeeNum">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:employeeType" Header="Shib-InetOrgPerson-employeeType">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:preferredLanguage" Header="Shib-InetOrgPerson-prefLang">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:manager" Header="Shib-InetOrgPerson-manager">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:roomNumber" Header="Shib-InetOrgPerson-roomNum">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:seeAlso" Header="Shib-OrgPerson-seeAlso">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:facsimileTelephoneNumber" Header="Shib-OrgPerson-fax">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:street" Header="Shib-OrgPerson-street">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:postOfficeBox" Header="Shib-OrgPerson-POBox">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:postalCode" Header="Shib-OrgPerson-postalCode">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:st" Header="Shib-OrgPerson-state">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
-->	
	<AttributeRule Name="urn:mace:dir:attribute-def:givenName" Header="Shib-InetOrgPerson-givenName">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	<!--
	<AttributeRule Name="urn:mace:dir:attribute-def:l" Header="Shib-OrgPerson-locality">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:businessCategory" Header="Shib-InetOrgPerson-businessCat">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:ou" Header="Shib-OrgPerson-orgUnit">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	<AttributeRule Name="urn:mace:dir:attribute-def:physicalDeliveryOfficeName" Header="Shib-OrgPerson-OfficeName">
		<AnySite>
            <AnyValue/>
        </AnySite>
	</AttributeRule>
	
	-->

</AttributeAcceptancePolicy>


```
