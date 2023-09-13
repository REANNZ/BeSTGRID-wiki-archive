# Uoa idp resolver.ldap.xml

``` 


<?xml version="1.0" encoding="UTF-8"?>
<AttributeResolver xmlns="urn:mace:shibboleth:resolver:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:mace:shibboleth:resolver:1.0 shibboleth-resolver-1.0.xsd">
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonEntitlement">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition
        id="urn:mace:dir:attribute-def:eduPersonAffiliation" sourceName="eduPersonAffiliation">
        <DataConnectorDependency requires="directory"/>
        <!-- We dont have eduPersonAffilication attribute yet, so we are going to use static value -->
        <DataConnectorDependency requires="static"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonNickname">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonPrimaryAffiliation">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonPrimaryOrgUnitDN">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonOrgUnitDN">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonOrgDN">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <!-- To use these attributes, you should change the smartScope value to match your site's domain name. -->
    <SimpleAttributeDefinition
        id="urn:mace:dir:attribute-def:eduPersonScopedAffiliation" smartScope="auckland.ac.nz">
        <AttributeDependency requires="urn:mace:dir:attribute-def:eduPersonAffiliation"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition
        id="urn:mace:dir:attribute-def:eduPersonPrincipalName"
        smartScope="auckland.ac.nz" sourceName="cn">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <!-- Example persistent id attribute.  Since this configuration is permanent, some thought is required before 
		deploying in  production. -->
    <SAML2PersistentID id="urn:oid:1.3.6.1.4.1.5923.1.1.1.10" sourceName="eduPersonPrincipalName">
        <DataConnectorDependency requires="echo"/>
        <Salt keyStoreKeyAlias="handleKey" keyStoreKeyPassword="shibhs"
            keyStorePassword="shibhs" keyStorePath="file:///usr/local/shibboleth-idp/etc/persistent.jks"/>
    </SAML2PersistentID>
    <!--Examples of common ldap-based attributes -->
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:cn">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:sn">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <!--<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:groupMembership">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:member">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>-->
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:dn">
        <DataConnectorDependency requires="directory1"/>
    </SimpleAttributeDefinition>
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:memberOf">
        <DataConnectorDependency requires="directory1"/>
    </SimpleAttributeDefinition>

    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:mail">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:displayName">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:personalTitle">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:givenName">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
   <PersistentIDAttributeDefinition id="urn:mace:dir:attribute-def:eduPersonTargetedID" scope="auckland.ac.nz" sourceName="cn"> 
    <DataConnectorDependency requires="directory"/>
    <Salt keyStorePath="file:///usr/local/shibboleth-idp/etc/persistent.jks"
          keyStoreKeyAlias="handleKey"
          keyStorePassword="shibhs"
          keyStoreKeyPassword="shibhs"/>
    </PersistentIDAttributeDefinition>
    <!--
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:telephoneNumber">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:initials">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:description">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:carLicense">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:departmentNumber">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:employeeNumber">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:employeeType">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:preferredLanguage">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:manager">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:roomNumber">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:seeAlso">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:facsimileTelephoneNumber">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:street">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:postOfficeBox">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:postalCode">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:st">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:l">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:businessCategory">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:ou">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
	
	<SimpleAttributeDefinition id="urn:mace:dir:attribute-def:physicalDeliveryOfficeName">
		<DataConnectorDependency requires="directory"/>
	</SimpleAttributeDefinition>
-->
    <!--<JNDIDirectoryDataConnector id="directory">
		<Search filter="cn=%PRINCIPAL%">
			<Controls searchScope="SUBTREE_SCOPE" returningObjects="false" />
		</Search>
		<Property name="java.naming.factory.initial" value="com.sun.jndi.ldap.LdapCtxFactory" />
		<Property name="java.naming.provider.url" value="ldap://ldap.example.edu/dc=example,dc=edu" />
		<Property name="java.naming.security.principal" value="cn=admin,dc=example,dc=edu" />
		<Property name="java.naming.security.credentials" value="examplepw" />
	</JNDIDirectoryDataConnector>-->
    <!-- An example of how to do a simple ldap bind over SSL -->
    <JNDIDirectoryDataConnector id="directory">
        <Search filter="cn=%PRINCIPAL%">
            <Controls returningObjects="false" searchScope="SUBTREE_SCOPE"/>
        </Search>
        <Property name="java.naming.factory.initial" value="com.sun.jndi.ldap.LdapCtxFactory"/>
        <Property name="java.naming.provider.url" value="ldap://ldap-vip.test.ec.auckland.ac.nz:636/ou=ec_users,dc=ec,dc=auckland,dc=ac,dc=nz"/>
	<Property name="java.naming.security.protocol" value="ssl" />
        <Property name="java.naming.security.principal" value="cn=shibboleth,ou=webapps,ou=ec,o=uoa"/>
        <Property name="java.naming.security.credentials" value="password"/>
    </JNDIDirectoryDataConnector>
    <JNDIDirectoryDataConnector id="directory1" mergeMultipleResults="true">
        <Search filter="objectclass=groupofNames member=cn=%PRINCIPAL%,ou=ec_users,dc=ec,dc=auckland,dc=ac,dc=nz">
            <Controls returningObjects="false" searchScope="SUBTREE_SCOPE"/>
        </Search>
        <Property name="java.naming.factory.initial" value="com.sun.jndi.ldap.LdapCtxFactory"/>
        <Property name="java.naming.provider.url" value="ldap://ldap-vip.test.ec.auckland.ac.nz:636/ou=ec_group,dc=ec,dc=auckland,dc=ac,dc=nz"/>
        <Property name="java.naming.security.protocol" value="ssl" />
        <Property name="java.naming.security.principal" value="cn=shibboleth,ou=webapps,ou=ec,o=uoa"/>
        <Property name="java.naming.security.credentials" value="password"/>
    </JNDIDirectoryDataConnector>

    <!-- Static value for testing purpose only!!!! -->
    <StaticDataConnector id="static">
        <Attribute name="eduPersonAffiliation">
                <Value>staff</Value>
        </Attribute>
    </StaticDataConnector>

    <!-- An example of how to setup ldap with connection pooling -->
    <!-- 
	<JNDIDirectoryDataConnector id="directoryPooled">
		<Search filter="cn=%PRINCIPAL%">
			<Controls searchScope="SUBTREE_SCOPE" returningObjects="false" />
		</Search>
		<Property name="java.naming.factory.initial" value="com.sun.jndi.ldap.LdapCtxFactory" />
		<Property name="java.naming.provider.url" value="ldap://ldap.example.edu/dc=example,dc=edu" />
		<Property name="com.sun.jndi.ldap.connect.pool" value="true" />
		<Property name="com.sun.jndi.ldap.connect.pool.initsize" value="5" />
		<Property name="com.sun.jndi.ldap.connect.pool.prefsize" value="5" />
		<Property name="com.sun.jndi.ldap.connect.pool.authentication" value="none simple DIGEST-MD5" />
		<Property name="com.sun.jndi.ldap.connect.pool.protocol" value="plain ssl" />
	</JNDIDirectoryDataConnector>
	-->
    <!--<StaticDataConnector id="staticLibraryEPE">
                <Attribute name="urn:mace:dir:attribute-def:eduPersonEntitlement">
                <Value>urn:mace:dir:entitlement:common-lib-terms</Value>
                <Value>urn:mace:incommon:entitlement:common:1</Value>
                </Attribute>
        </StaticDataConnector>-->
    <CustomDataConnector
        class="edu.internet2.middleware.shibboleth.aa.attrresolv.provider.SampleConnector" id="echo"/>
    <!--<CustomAttributeDefinition
        class="au.edu.mq.melcoe.mams.sharpe.shib.aa.attrresolv.provider.CrosswalkAttributeDefinition"
        haltOnFirstFound="false" id="urn:mace:dir:attribute-def:eduPersonAffiliation">
        <AttributeDependency requires="idp:urn:mace:dir:attribute-def:eduPersonAffiliation"/>
    </CustomAttributeDefinition>-->
    <!--<CustomAttributeDefinition
        class="au.edu.mq.melcoe.mams.sharpe.shib.aa.attrresolv.provider.CrosswalkAttributeDefinition"
        haltOnFirstFound="false" id="urn:mace:dir:attribute-def:eduPersonPrincipalName">
        <AttributeDependency requires="idp:urn:mace:dir:attribute-def:eduPersonPrincipalName"/>
    </CustomAttributeDefinition>-->
</AttributeResolver>




```
