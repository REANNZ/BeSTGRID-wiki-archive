# Shibboleth login to E-Cast for K-12 sector IdPs

The K-12 sector is using IdPs based on simpleSAMLphp.  E-Cast is using Shibboleth SP 2.2.x and is linked into the Australian Access Federation (AAF).

This page documents the configuration steps necessary at both ends of this setup to enable Shibboleth login from the K-12 IdPs to E-Cast.

# Configuration at E-Cast server

The E-Cast server must be configured to:

- Load the metadata of the K-12 IdPs
- Accept additional attributes from the MLEP schema
- Accept eduPersonPrincipalName without a Scope filter
- Define a session initiator pointing to a WAYF/DS server loading the K-12 metadata

## Load the K-12 metadata

The (yet to be confirmed) metadata distribution point is [https://directory.tuakiri.ac.nz/metadata/nzcsed-metadata.xml](https://directory.tuakiri.ac.nz/metadata/nzcsed-metadata.xml)

- Edit  (`/opt/local/etc/shibboleth/`)`shibboleth2.xml` and add a MetadataProvider element loading the metadata from this URL:


## Accepting additional attributes from MLEP schema

Add the following mappings to (`/opt/local/etc/shibboleth/`)`attribute-map.xml`

``` 

    <!-- HighEd attributes -->
    <Attribute name="urn:oid:1.3.6.1.4.1.36350.1.1.1.1" id="mlepUsername"/>
    <Attribute name="urn:oid:1.3.6.1.4.1.36350.1.1.1.3" id="mlepFirstName"/>
    <Attribute name="urn:oid:1.3.6.1.4.1.36350.1.1.1.4" id="mlepLastName"/>
    <Attribute name="urn:oid:1.3.6.1.4.1.36350.1.1.1.5" id="mlepEmail"/>
    <Attribute name="urn:oid:1.3.6.1.4.1.36350.1.1.1.6" id="mlepOrganisation"/>
    <Attribute name="urn:oid:1.3.6.1.4.1.36350.1.1.1.7" id="mlepRole"/>

    <Attribute name="urn:oid:1.3.6.1.4.1.36350.1.1.1.12" id="mlepGlobalUserId"/>

```

## Accept eduPersonPrincipalName without a Scope filter

Comment out the "eppn" rule in (`/opt/local/etc/shibboleth/`)`attribute-policy.xml`

``` 

 <!--
         <afp:AttributeRule attributeID="eppn">
             <afp:PermitValueRuleReference ref="ScopingRules"/>
         </afp:AttributeRule>
 -->

```

## Define a session initiator pointing to a WAYF/DS server loading the K-12 metadata

The (yet to be confirmed) Tuakiri WAYF server serving also for the K-12 federation URL is [https://directory.tuakiri.ac.nz/ds/DS](https://directory.tuakiri.ac.nz/ds/DS)

>  **Edit  (**`/opt/local/etc/shibboleth/`**)**`shibboleth2.xml`** and*modify** the DS SessionInitiator to use this URL

``` 

             <SessionInitiator type="Chaining" Location="/DS" isDefault="true" id="DS" relayState="cookie">
                 <SessionInitiator type="SAML2" acsIndex="1" template="bindingTemplate.html"/>
                 <SessionInitiator type="Shib1" acsIndex="5"/>
                 <SessionInitiator type="SAMLDS" URL="<b><nowiki>https://directory.tuakiri.ac.nz/ds/DS</nowiki></b>"/>
             </SessionInitiator>

```

>  **Optionally,*add** also an additional SessionInitiator for the Catalyst test IdP (and optionally also for other IdPs):

``` 

             <SessionInitiator type="Chaining" Location="<b>/Login/idp.catalyst.net.nz</b>" id="<b>SSO-Catalyst</b>"
                     relayState="cookie" entityID="<b>idp.catalyst.net.nz</b>">
                 <SessionInitiator type="SAML2" acsIndex="1" template="bindingTemplate.html"/>
                 <SessionInitiator type="Shib1" acsIndex="5"/>
             </SessionInitiator>

```

- Or alternatively, instead of creating the session initiator, just provide the entityID in the query argument to the default SessionInitiator:
- **Note: the argument must be the*entityID** of the IdP - which may or may not be the hostname (it could be e.g. [https://idp.example.org/idp/shibboleth](https://idp.example.org/idp/shibboleth))


# Configuration at each K-12 IdP

Each K-12 IdP must be configured to: 

- Load the metadata of the E-Cast server
- Use OID-based attribute names for all attributes
- Providing eduPersonPrincipalName

These changes have to be implemented for each of the K-12 IdPs:

- [https://idp.catalyst.net.nz/simplesaml/saml2/idp/metadata.php?output=xml](https://idp.catalyst.net.nz/simplesaml/saml2/idp/metadata.php?output=xml) (test service)
- [https://idp.theloop.school.nz/simplesaml/saml2/idp/metadata.php?output=xml](https://idp.theloop.school.nz/simplesaml/saml2/idp/metadata.php?output=xml) - Nelson Loop
- [https://login.gcsn.school.nz/simplesaml/saml2/idp/metadata.php?output=xml](https://login.gcsn.school.nz/simplesaml/saml2/idp/metadata.php?output=xml) - Greater Christchurch School Network
- [https://ares.wellingtonloop.net.nz/simplesaml/saml2/idp/metadata.php?output=xml](https://ares.wellingtonloop.net.nz/simplesaml/saml2/idp/metadata.php?output=xml) - Wellington Loop
- [https://idp.rorohiko.school.nz/simplesaml/saml2/idp/metadata.php?output=xml](https://idp.rorohiko.school.nz/simplesaml/saml2/idp/metadata.php?output=xml) - Rorohiko School (EdTech)
- [https://sso.ashs.school.nz/simplesaml/saml2/idp/metadata.php?output=xml](https://sso.ashs.school.nz/simplesaml/saml2/idp/metadata.php?output=xml) - Albany senior High School

## Load the metadata of the E-Cast server

- The Metadata distribution point is: [https://www.etv.org.nz/Shibboleth.sso/Metadata](https://www.etv.org.nz/Shibboleth.sso/Metadata)
- The PHP code to configure this metadata into SimpleSAMLphp is (also attached as [saml20-sp-remote.php](/wiki/download/attachments/3818228482/Saml20-sp-remote.txt?version=1&modificationDate=1539354136000&cacheVersion=1&api=v2))

``` 

// E-Cast test service
$metadata['https://www.etv.org.nz/shibboleth'] = array (
  'AttributeNameFormat' => 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri',
  'authproc' => array(
                      99 => array('class' => 'core:AttributeMap', 'mlepname2oid'),
                     ),
  'entityid' => 'https://www.etv.org.nz/shibboleth',
  'metadata-set' => 'saml20-sp-remote',
  'AssertionConsumerService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SAML2/POST',
      'index' => 1,
    ),
    1 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SAML2/POST-SimpleSign',
      'index' => 2,
    ),
    2 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SAML2/Artifact',
      'index' => 3,
    ),
    3 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:PAOS',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SAML2/ECP',
      'index' => 4,
    ),
    4 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:1.0:profiles:browser-post',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SAML/POST',
      'index' => 5,
    ),
    5 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:1.0:profiles:artifact-01',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SAML/Artifact',
      'index' => 6,
    ),
  ),
  'SingleLogoutService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SLO/SOAP',
    ),
    1 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SLO/Redirect',
    ),
    2 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SLO/POST',
    ),
    3 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact',
      'Location' => 'https://www.etv.org.nz/Shibboleth.sso/SLO/Artifact',
    ),
  ),
  'certData' => 'MIIDFDCCAfygAwIBAgIJAM76dpbNwg9FMA0GCSqGSIb3DQEBBQUAMBkxFzAVBgNVBAMTDnd3dy5ldHYub3JnLm56MB4XDTEwMDgxMTAyMTEwOFoXDTIwMDgwODAyMTEwOFowGTEXMBUGA1UEAxMOd3d3LmV0di5vcmcubnowggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDQ8u/qk5gZ6HNjsA5DxLDAxHS6zdP+oJSI5xnhFKvysjEOSOtWGpnoHHWTap4raAPq7vs9UEuwe0BDCAsrKMmAFfGZTRHQ1pb16l1xzp4K10WdFivCBNCrZ9kffeGTFZDTbBxs5xyaZimyHtXLJ1YmEy/wVF6emlzg+XZ1Q/+BUb1V2G16Zb7nDOaoqVzzlR5EOWtH4WCi7SPnGJJ231vRlXkgkdEqkjlag5SLipbpJsJHXcpRyTFnOjnl1AFJPaLZok24++sxBgu8XVoojjmQVkcDS85GuCdjONMUI4g9pBHTSFpgvjQUadbcT6vY1e1IwlVg7Z79DEMciRVGczJrAgMBAAGjXzBdMDwGA1UdEQQ1MDOCDnd3dy5ldHYub3JnLm56hiFodHRwczovL3d3dy5ldHYub3JnLm56L3NoaWJib2xldGgwHQYDVR0OBBYEFBgN8V4PEiBy3aoQMjKLPgXCzn0eMA0GCSqGSIb3DQEBBQUAA4IBAQBt8spyzxcNHrFakRn+KSopIeQaX04e36NjfLSySngpKGSbxvu5t/ntNE/NcO4dAsfDrR2CVNaJqH9HaH5kLML1qHeAS4SsVSzLRhYBQWl3x8Twq9As5LFbYAd0XSSKLT8DK71VKycD2254D85JMBKGYFIAQeIn9Whb/Mq5n2FHbkVh3u1bFlHBnY6IvA7iBu/2CCHR6h6fF1NMWtkvhYAVXU9yPsSeQ5ZDeLt51Nl5f+cDm97uRfaVbeBXHzmLW9ZTgJ+jXY3EY02dmfS9CvOX0KXo1Wex2Wgk1lsC+rzRaydUGFoq28od7dyDm5xSrL1j4H6qIxxnSQgf/SYzNr1I',
);

```

## Use OID-based attribute names for all attributes

The following instructions apply for configuring a [//www.simplesamlphp.org](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=SimpleSAMLphp http&title=%2F%2Fwww.simplesamlphp.org) IdP service to support an E-Cast Shibboleth SP end-point.

- The following PHP code is an attribute map that adds the Ministry of Education MLEP extensions to the standard set of the OID attribute names:

``` 

// pull in the standard definitions
require_once('name2oid.php');

// now add the MLEP specific values
$attributemap = array_merge($attributemap, array(
    'mlepUsername' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.1',
    'mlepSmsPersonId' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.2',
    'mlepFirstName' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.3',
    'mlepLastName' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.4',
    'mlepEmail' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.5',
    'mlepOrganisation' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.6',
    'mlepRole' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.7',
    'mlepStudentNSN' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.8',
    'mlepAssociatedNSN' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.9',
    'mlepFirstAttending' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.10',
    'mlepLastAttendance' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.11',
    'mlepGlobalUserId' => 'urn:oid:1.3.6.1.4.1.36350.1.1.1.12',
    )
);

```

Place this is a file mlepname2oid.php in the ./attributemap/ directory of SimpleSAMLphp.

To activate this attribute mapping for a given SP, edit the appropriate SP metadata in the metadata/saml20-sp-rempote.php file, adding an autproc rule like this:

``` 

  ...
  'authproc' => array(
                      99 => array('class' => 'core:AttributeMap', 'mlepname2oid'),
                     ),
  ...

```

- Note: the value for mlepGlobalUserId is identical to eduPersonPrincipalName.  This can be mapped using the following metadata/saml20-sp-remote.php file authproc rule :

``` 

  ...
  'authproc' => array(
    50 => array(
      'class' => 'core:AttributeMap',
      'mlepGlobalUserId' => 'eduPersonPrincipalName'),
  ),
  ...

```

Note that if this is combined with the OID mapping rule, then it must have a lower rule number (eg: 50) to ensure that it is processed first.

- In addition to that, also make sure the encoding of the attributes is "urn:oasis:names:tc:SAML:2.0:attrname-format:uri".  The configuration for this is also in the metadata/saml20-sp-remote.php file.  Add the following to the E-Cast SP config:

``` 

  'AttributeNameFormat' => 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri',

```

## Logout settings

To make the SAML2 Logout work (betweeen SimpleSAMLphp running at the IdP and Shibboleth 2.x SP running at ETV), it is necessary to set an option to enable signing of Logout responses:

- Add the following in the metadata for the IdP (in the saml20-idp-hosted.php metadata file): 

``` 
'request.signing' => TRUE,
```

See the [original discussion](http://groups.google.com/group/simplesamlphp/browse_thread/thread/700e8e89fa02ecd0?pli=1) for more information.

Example:

``` 

// E-Cast test service
$metadata['https://www.etv.org.nz/shibboleth'] = array (
  'redirect.sign' => TRUE,
  'AttributeNameFormat' =>
'urn:oasis:names:tc:SAML:2.0:attrname-format:uri',
  'authproc' => array(
                      99 => array('class' => 'core:AttributeMap',
'mlepname2oid'),
                     ),
  'entityid' => 'https://www.etv.org.nz/shibboleth',
  'metadata-set' => 'saml20-sp-remote',
...


```

# Handling K-12 Login and Attributes at E-Cast

(Copied from email sent to E-Cast on October 13th, 2010)

- The E-Cast Shibboleth SP (at www.etv.org.nz) is now configured to test the Shibboleth login
	
- You can test this by going to: [https://www.etv.org.nz/Shibboleth.sso/Login/idp.catalyst.net.nz?target=http://www.etv.org.nz/shib/](https://www.etv.org.nz/Shibboleth.sso/Login/idp.catalyst.net.nz?target=http://www.etv.org.nz/shib/)
- This requires admin login to get to the test IdP at all, and then log in by selecting E-Cast and logging in as either testteacher or teststudent.

- After logging in, your Shibboleth session should have all the attributes received from the Catalyst test IdP.  They would be available as Apache Environment variables in $_SERVER, same as for "normal" Shibboleth login.

The key attributes relevant for E-Cast are:

(1) $_SERVER["Shib-Identity-Provider"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22Shib-Identity-Provider%22&linkCreation=true&fromPageId=3818228482) = "idp.catalyst.net.nz"

- this is the identification of the IdP (but not the institution).  Use for access control.  This attribute uses a different syntax from the university IdPs (where it's "https://idp.canterbury.ac.nz/shibboleth") - but passes the same information - which IdP the user came from.

(2) $_SERVER["mlepOrganisation"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22mlepOrganisation%22&linkCreation=true&fromPageId=3818228482) = "e-cast.co.nz"

- this will be the organization name (actual School) to help you decide whether they do or don't have access to E-Cast.

(3) $_SERVER["mlepRole"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22mlepRole%22&linkCreation=true&fromPageId=3818228482) = "TeachingStaff"

- this tells you who's staff and who's students.  The values are: "Student", "TeachingStaff", "NonTeachingStaff", "ParentCaregiver", "Alumni".
	
- You would probably want to see either any of the "TeachingStaff" / "NonTeachingStaff" values or "Student" here to give the user access.

(4) $_SERVER["eppn"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22eppn%22&linkCreation=true&fromPageId=3818228482) = "testteacher@e-cast.co.nz"

- global user name, same as for university IdPs.

(5) $_SERVER["mail"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22mail%22&linkCreation=true&fromPageId=3818228482) = "testteacher@e-cast.co.nz"

- Email address, same as for university IdPs

(6) $_SERVER["mlepFirstName"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22mlepFirstName%22&linkCreation=true&fromPageId=3818228482) = "Test"; $_SERVER["mlepLastName"](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=%22mlepLastName%22&linkCreation=true&fromPageId=3818228482) = "Teacher"

- the user's first and last name.  As other IdPs may not be reliably providing neither displayName, nor, cn, the only way to get their full name may be:

``` 
$_SERVER["mlepFirstName"] . " " . $_SERVER["mlepLastName"]
```

After logging in, you can access the detailed attributes at 

- [http://www.etv.org.nz/shib/phpinfo.php](http://www.etv.org.nz/shib/phpinfo.php) (scroll down to Apache Environment)
- or at [https://www.etv.org.nz/Shibboleth.sso/Session](https://www.etv.org.nz/Shibboleth.sso/Session)

# K-12 Federation Metadata

The K-12 Metadata has been manually collected from the metadata distribution points at each IdP and SP (with the use of a script).  As the metadata has been manually augmented with institution's names, the metadata will not be automatically updated via the use of the script - any changes (to URLs, certificates, adding new IdP) will have to be done manually, until a federation manager is in place.

The metadata primary copy is located on **directory.tuakiri.ac.nz** in the `/opt/shibboleth-ds/metadata/nzcsed-metadata.xml` file.

The metadata distribution URL is [https://directory.tuakiri.ac.nz/metadata/nzcsed-metadata.xml](https://directory.tuakiri.ac.nz/metadata/nzcsed-metadata.xml)

The IdPs and SPs include in the metadata are:

|  Full name  |                                                                                                           |                                                                                                                             |                                            |
| ----------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
|  IdP        |  idp.theloop.school.nz                                                                                    |  Nelson Loop                                                                                                                |                                            |
|  IdP        |  login.gcsn.school.nz                                                                                     |  Greater Christchurch Schools Network                                                                                       |                                            |
|  IdP        |  ares.wellingtonloop.net.nz                                                                               |  Wellington Loop                                                                                                            |                                            |
|  SP         | [https://www.etv.org.nz/shibboleth](https://www.etv.org.nz/shibboleth)                                    | [https://www.etv.org.nz/Shibboleth.sso/Metadata](https://www.etv.org.nz/Shibboleth.sso/Metadata)                            |  E-Cast ETV Service                        |
|  SP         | [https://gridgwtest.canterbury.ac.nz/shibboleth](https://gridgwtest.canterbury.ac.nz/shibboleth)          | [https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/Metadata](https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/Metadata)  |  Test Service at University of Canterbury  |
|  IdP        |  idp.catalyst.net.nz                                                                                      |  Test IdP - Catalyst SSO Login Service                                                                                      |                                            |
|  IdP        | [https://idp.watchdog.net.nz/saml2/idp/metadata.php](https://idp.watchdog.net.nz/saml2/idp/metadata.php)  | [https://idp.watchdog.net.nz/saml2/idp/metadata.php](https://idp.watchdog.net.nz/saml2/idp/metadata.php)                    |  Watchdog Identity Service                 |
|  IdP        | [https://auth.edtech.net.nz](https://auth.edtech.net.nz)                                                  |  EdTech SSO service                                                                                                         |                                            |
|  IdP        |  login.school.nz                                                                                          |  Wellington Regional Single Signon                                                                                          |                                            |
