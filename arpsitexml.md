# Arp.site.xml

``` 

<?xml version="1.0" encoding="UTF-8"?>
<AttributeReleasePolicy xmlns="urn:mace:shibboleth:arp:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:mace:shibboleth:arp:1.0 shibboleth-arp-1.0.xsd">
    <Description>noDescription</Description>
  <Rule>
	<Description/>
        <Target>
           <AnyTarget/>
        </Target>
         <Attribute name="urn:mace:dir:attribute-def:eduPersonPrincipalName">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:mace:dir:attribute-def:eduPersonAffiliation">
            <AnyValue release="permit"/>
        </Attribute>
	 <Attribute name="urn:mace:dir:attribute-def:mail">
            <AnyValue release="permit"/>
        </Attribute>
<Attribute name="urn:mace:dir:attribute-def:eduPersonTargetedID">
         <AnyValue release="permit"/>
     </Attribute>
  </Rule>

  <Rule>
        <Description>BeSTGRID WIKI Test</Description>
        <Target>
            <Requester>urn:mace:bestgrid:wiki.test.bestgrid.org</Requester>
            <AnyResource/>
        </Target>
        <Attribute name="urn:mace:dir:attribute-def:sn">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:mace:dir:attribute-def:mail">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:mace:dir:attribute-def:givenName">
            <AnyValue release="permit"/>
        </Attribute>
         <Attribute name="urn:mace:dir:attribute-def:eduPersonPrincipalName">
            <AnyValue release="permit"/>
        </Attribute>
         <Attribute name="urn:mace:dir:attribute-def:cn">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:mace:dir:attribute-def:eduPersonAffiliation">
            <AnyValue release="permit"/>
        </Attribute>
        <!--<Attribute name="urn:mace:dir:attribute-def:memberOf">
            <AnyValue release="permit"/>
        </Attribute>-->

    </Rule>
  <Rule>
        <Description>Confluence Wiki</Description>
        <Target>
            <Requester>urn:mace:bestgrid:wiki-dev.auckland.ac.nz</Requester>
            <AnyResource/>
        </Target>
        <Attribute name="urn:mace:dir:attribute-def:sn">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:mace:dir:attribute-def:mail">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:mace:dir:attribute-def:givenName">
            <AnyValue release="permit"/>
        </Attribute>
         <Attribute name="urn:mace:dir:attribute-def:eduPersonPrincipalName">
            <AnyValue release="permit"/>
        </Attribute>
         <Attribute name="urn:mace:dir:attribute-def:cn">
            <AnyValue release="permit"/>
        </Attribute>
        <Attribute name="urn:mace:dir:attribute-def:displayName">
            <AnyValue release="permit"/>
        </Attribute>

    </Rule>

</AttributeReleasePolicy>


```
