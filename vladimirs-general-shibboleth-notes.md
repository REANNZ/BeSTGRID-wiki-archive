# Vladimir's general Shibboleth notes

This is a place-holder page where I want to keep my notes at least vaguely related to Shibboleth.  I hope this may be useful of others as well.  But it's generally intended as a place for notes I consider useful for myself...

# Signing XML documents

The MAMS testbed federation puts signatures into the federation metadata XML documents.  The signatures, inserted at the beginning of the document, have a digest of the canonic form the the remaining on documents, a signature of the digest, and the certificate for the key used to create the signature.

I was looking at what are the steps to create such signatures.  The Apache XML Security project, [http://xml.apache.org/security/](http://xml.apache.org/security/), provides a Java and C library which allow to handle, and also create signed XML document. (The C library project is at [http://xml.apache.org/security/c/](http://xml.apache.org/security/c/))

I was looking for command-line tools which could be used to sign XML documents in a scripting environment.  The C library (which is compiled as a part of installing the Shibboleth SP) has the `templatesign` tool.  The tool needs a template for the signature to already exist as the first child of the top-level document.  Then, the tool can be simple used as in the following example:

>  ./templatesign --rsakey /etc/certs/mykey.pem "" --x509cert /etc/certs/mycert.pem /tmp/bestgrid-metadata.xml > /tmp/bestgrid-metadata-signed.xml

The template to be included is:

``` 

 <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
   <ds:SignedInfo>
     <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#WithComments"></ds:CanonicalizationMethod>
     <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></ds:SignatureMethod>
     <ds:Reference URI="">
       <ds:Transforms>
         <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform>
         <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#WithComments"></ds:Transform>
       </ds:Transforms>
       <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>
       <ds:DigestValue>  </ds:DigestValue>
     </ds:Reference>
   </ds:SignedInfo>
   <ds:SignatureValue>
 
   </ds:SignatureValue>
 </ds:Signature>

```

## Decrypting encrypted XML documents

De-crypting XML on the command-line:

``` 

yum install xmlsec1.x86_64 xmlsec1-openssl.x86_64
yum install xmlsec1.x86_64 xmlsec1-{gnutls,nss,openssl}.x86_64
mkdir /tmp/xmlsec
cd /tmp/xmlsec
ln -s /usr/lib64/libxmlsec1-nss.so.1 libxmlsec1-nss.so
ln -s /usr/lib64/libxmlsec1-openssl.so.1 libxmlsec1-openssl.so
ln -s /usr/lib64/libxmlsec1-gnutls.so.1 libxmlsec1-gnutls.so
LD_LIBRARY_PATH=/tmp/xmlsec/ xmlsec1 --decrypt --crypto openssl --print-crypto-error-msgs --privkey-pem /etc/shibboleth/sp-key.pem /tmp/assert1.xml 

```

BTW, failed for NSS and gnuTLS:

``` 

LD_LIBRARY_PATH=/tmp/xmlsec/ xmlsec1 --decrypt --crypto nss --print-crypto-error-msgs --privkey-pem /etc/shibboleth/sp-key.pem /tmp/assert1.xml 
func=xmlSecNssAppKeyLoadSECItem:file=app.c:line=420:obj=unknown:subj=xmlSecNssAppKeyLoad:error=17:invalid format:format=2;last nss error=-12285 (0xFFFFD003)
func=xmlSecNssAppKeyLoad:file=app.c:line=299:obj=unknown:subj=xmlSecNssAppKeyLoadSECItem:error=1:xmlsec library function failed: ;last nss error=-12285 (0xFFFFD003)
func=xmlSecAppCryptoSimpleKeysMngrKeyAndCertsLoad:file=crypto.c:line=118:obj=unknown:subj=xmlSecCryptoAppKeyLoad:error=1:xmlsec library function failed:uri=/etc/shibboleth/sp-key.pem;last nss error=-12285 (0xFFFFD003)
Error: failed to load private key from "/etc/shibboleth/sp-key.pem".
Error: keys manager creation failed
Usage: xmlsec <command> [<options>] [<file>]

LD_LIBRARY_PATH=/tmp/xmlsec/ xmlsec1 --decrypt --crypto gnutls --print-crypto-error-msgs --privkey-pem /etc/shibboleth/sp-key.pem /tmp/assert1.xml 
func=xmlSecGnuTLSAppKeyLoad:file=app.c:line=91:obj=unknown:subj=xmlSecGnuTLSAppKeyLoad:error=9:feature is not implemented: 
func=xmlSecAppCryptoSimpleKeysMngrKeyAndCertsLoad:file=crypto.c:line=118:obj=unknown:subj=xmlSecCryptoAppKeyLoad:error=1:xmlsec library function failed:uri=/etc/shibboleth/sp-key.pem
Error: failed to load private key from "/etc/shibboleth/sp-key.pem".
Error: keys manager creation failed

```

## Checking signature on an xml document

When using `xmlsec1` for signature checking, use `--id-attr` option:

>  xmlsec1 --verify --id-attr:ID urn:oasis:names:tc:SAML:2.0:metadata:EntitiesDescriptor --trusted-pem tuakiri-test-metadata-cert.pem tuakiri-test-metadata-signed.xml

# Shibboleth Logo on SP Error Pages

In the default installation of a SP, the error page does not display properly - it links to the Shibboleth stylesheet and logo at an non-existent location, `/shibtarget/logo.jpg` and `/shibtarget/main.css`.

The locations are configured in `shibboleth.xml` - however, in order for them to be accessible, the same names must be aliased to local files in the httpd configuration.

Following the configuration on the BeSTGRID wiki, I will configure both at "/shibboleth-sp" in `shib-sp.conf` on RedHat and `mod_shib.conf` on Debian/Ubuntu.

The following httpd configuration fragment makes the logo and stylesheet accessible.  Note that the path to the resources may vary with the system is - the following works on systems where the Shibboleth SP is installed into `/usr/local/shibboleth-sp`, according to the [MAMS instructions](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallSP).

``` 

<IfModule mod_alias.c>
  <Location /shibboleth-sp>
    Allow from all
  </Location>
  Alias /shibboleth-sp/main.css /usr/local/shibboleth-sp/doc/shibboleth/main.css
  Alias /shibboleth-sp/logo.jpg /usr/local/shibboleth-sp/doc/shibboleth/logo.jpg
</IfModule>

```

Also, `shibboleth.xml` has to be adjusted to use the new locations in error messages (and it also pays off to enter a real email address into the configuration):

``` 

                <Errors session="/usr/local/shibboleth-sp/etc/shibboleth/sessionError.html"
                        metadata="/usr/local/shibboleth-sp/etc/shibboleth/metadataError.html"
                        rm="/usr/local/shibboleth-sp/etc/shibboleth/rmError.html"
                        access="/usr/local/shibboleth-sp/etc/shibboleth/accessError.html"
                        <strong>supportContact="vladimir.mencl@canterbury.ac.nz"</strong>
                        <strong>logoLocation="/shibboleth-sp/logo.jpg"</strong>
                        <strong>styleSheet="/shibboleth-sp/main.css"</strong>/>

```

# Controlling Scope for an IdP

An IdP may be assigning a Scope to some attributes (such as eduPersonPrincipalName or eduPersonAffiliation).  The metadata determines which values an IdP may use for the scope.  The 

``` 
<shib:Scope>
```

 extension gives the permissible value (or optionally a regular expression).  For the AAF federations, the scope is determined from the entityId of the organization - it is exactly the hostname specified as the last part of the entityId (see example below).

For an organization, the hostname of the IdP might take the form `idp.``organization.ac.nz`, while the preferred scope would be just `organization.ac.nz`.   The solution is to register the IdP with an entityId containing just the preferred value of the scope range (and to register the services running on the IdP with its actual hostname).  

For the University of Canterbury, the organization's (and IdP's) entity Id is:

``` 
urn:mace:federation.org.au:testfed:canterbury.ac.nz
```

This results into the 

``` 
<shib:Scope>
```

 extension having the value `canterbury.ac.nz` - while the hostname of the IdP still remains `idp.canterbury.ac.nz`.

# Access control with Shibboleth: requesting a specific attribute

So far, the only form of access control used in the sample Shibboleth settings was requiring that a user authenticates with an IdP in the federation - and this plain membership was sufficient.  It is possible to control access based on the presence of an attribute, or even a specific value of an attribute right at the level of Apache access control with the Shibboleth module.

The very simple form of doing that is:

``` 

     <Location /secure>
        AuthType shibboleth
        ShibRequireSession On
        # require valid-user
        require user ~ ^.+$
     </Location>
<pre>

This specific example asks for the <tt>user</tt> variable to be set to any value - and any Shibboleth attribute can be used with the variable name it is assigned to in the Attribute Acceptance policy (AAP.xml).  For more syntax on using the require directive, see the examples in the [https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPhtaccess|Shibboleth SP htaccess] documentation on specific features implemented for the [http://httpd.apache.org/docs/current/mod/core.html#require Apache require directive].

Users who do not have the attribute (or do not provide it), get the following error message (with the Shibboleth logo):
 <strong>Authorization Failed</strong>
 Based on the information provided to this application about you, you are not authorized to access the resource at "https://idp-test.canterbury.ac.nz/secure/phpinfo.php"
 Please contact the administrator of this service or application if you believe this to be an error.

This form of control however may not be that user friendly - user would have to know to go either use Autograph to allow the release of the attribute, or talk to their IdP administrator to configure the attributes on the IdP.

Also note that this does not work with lazy sessions - in which case one immediately gets the same error message.

Further, note that care must be taken with overlapping <pre><Location>
```

 access control blocks.  These should be listed from the most-generic (`"/"`) to the most specific (as `"/secure"` in the above example).  Otherwise, the more relaxed settings on the generic one would override the more stringent settings on the specific one.

# Enforcing Canonical Hostnames

**Issue**: when a SP is accessed by a URL other than it's cannonical one, the local WAYF redirector (Session Initiator) constructs a URL containing the non-canonical hostname (followed by `/Shibboleth.sso`) - and consequently, IdP produces a Session Creation Failure with the reason: 

>  org.opensaml.SAMLException: Invalid assertion consumer service URL.

- Solution attempt 1: absolute shibboleth.xml handlerURL (does not work).

I thought I could fix it by editing `Sessions` element in shibboleth.xml, and change the attribute handlerURL from relative URL `"/Shibboleth.sso"` to an absolute URL containing the correct hostname.

Surprisingly, doing so results in a 50% failure rate in creating sessions, with the message 

>  Session creation failure at ([https://idp-test.canterbury.ac.nz/Shibboleth.sso/SAML/Artifact](https://idp-test.canterbury.ac.nz/Shibboleth.sso/SAML/Artifact))
>  Session Creation Error

displayed in the HTML response, and SP log saying:

>  2008-02-26 13:52:13 ERROR shibd.Listener [23](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=23&linkCreation=true&fromPageId=3816950783) sessionNew: caught exception while creating session: SOAPHTTPBindingProvider::send() failed while contacting SAML responder: error:1408F06B:SSL routines:SSL3_GET_RECORD:bad decompression

and no useful information in the IdP log.

Even more surprisingly, when I manually edit the URL when at the WAYF server, and switch from Artifact profile to POST profile, I don't get this failure, but I don't get any attributes at all. (In the previous case, if a session is established, I have all attributes there).  Strange: authentication succeeds, but all attributes are rejected - even though in the POST profile, everything is sent in a single signed assertion.

Finally, more surprise, in each case, I'm so far redirected to the registered SP home page, but not to the page where I wanted to go.

I thought about the fact that I'm accessing the SP just by the short name "idp-test" and the server does not search "canterbury.ac.nz"?  It however can resolve "idp-test" locally.

When I access the server by it's canonical name, these oddities do not kick in - so I'd better try redirect the URL already at Apache level.

- Solution attempt 2: Apache redirects based on the Rewrite Engine - as documented in the [Apache URL Rewriting Guide](http://httpd.apache.org/docs/2.2/rewrite/rewrite_guide.html).

Put the following inside 

``` 
<VirtualHost 132.181.4.4:80>
```

:

``` 

RewriteEngine On
RewriteCond %{HTTP_HOST}   !^idp-test\.canterbury\.ac\.nz [NC]
RewriteCond %{HTTP_HOST}   !^$
RewriteRule ^/(.*)         http://idp-test.canterbury.ac.nz/$1 [L,R]

```

This works to redirect http requests to port 80 - how comes it works even for requests which are immediately redirected to the WAYF server (to go to IdP) by the Shibboleth module?  The consumer service URL at the WAYF server already has the canonical hostname.

It however does not work for requests directed to the application-level WAYF redirector:

>  [https://idp-test/Shibboleth.sso/WAYF/level-1.federation.org.au?target=http://idp-test/secure/](https://idp-test/Shibboleth.sso/WAYF/level-1.federation.org.au?target=http://idp-test/secure/)

still asks for `"idp-test/Shibboleth.sso"` - which is still broken.

Surprisingly, expanding the hostname in the target URL parameter to the canonical hostname:

>   [https://idp-test/Shibboleth.sso/WAYF/level-1.federation.org.au?target=http://idp-test.canterbury.ac.nz/secure/](https://idp-test/Shibboleth.sso/WAYF/level-1.federation.org.au?target=http://idp-test.canterbury.ac.nz/secure/)

works and access the consumer service via the canonical hostname.

It appears that we cannot redirect all wrong ways of accessing the SP, but we can redirect all ways of entering the SP to the canonical hostname, and this should assure the Shibboleth login URLs generated when accessing the host this way will always use the canonical hostname.

Let us also add the following to 

``` 
<VirtualHost 132.181.4.4:443>
```

 in `shib-vhosts.conf`:

``` 

RewriteEngine On
RewriteCond %{HTTP_HOST}   !^idp-test\.canterbury\.ac\.nz [NC]
RewriteCond %{HTTP_HOST}   !^$
RewriteRule ^/(.*)         https://idp-test.canterbury.ac.nz/$1 [L,R]

```

For a lazy-session SP, this redirects all entry URLs to the canonical name, and the server will then always construct login URLs via the application-level WAYF redirector with the canonical hostname.

The above solution, together with `UseCanonicalName On`, works also when a Shibboleth-protected URL requiring a session is accessed via an incorrect hostname - the RewriteEngine steps in before the access-control module, and the URL redirected to the WAYF server already uses the canonical hostname of the SP.

# Adding a new attribute

To add a new attribute:

- define it in `/usr/local/shibboleth-idp/etc/resolver.ldap.xml`

``` 

    <SimpleAttributeDefinition id="urn:mace:canterbury.ac.nz:attribute:ucdeptcode" sourceName="ucdeptcode">
        <DataConnectorDependency requires="directory"/>
    </SimpleAttributeDefinition>
* to make it visible in Autograph, add it to <tt>/usr/local/shibboleth-autograph/connectorConfigs/AttributeInfoPointData.xml</tt>
      <Attribute id="urn:mace:canterbury.ac.nz:attribute:ucdeptcode"   type="string">
           <FriendlyName lang="en">UC Dept Code</FriendlyName>
           <Description lang="en">UC department</Description>
      </Attribute>

```

- To allow Autograph to store user-customized values for editable attributes, configure write-access to the LDAP server in `/usr/local/shibboleth-autograph/connectorConfigs/AttributeWriterImplConf.config.xml`

# Adding a static attribute

**Warning: this breaks AutoGraph**.  AutoGraph apparently cannot handle StaticDataConnector attributes.  You need to get an updated `shib-java.jar` from Stuart Allen and install it into `/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib`.

Following [https://wiki.shibboleth.net/confluence/display/SHIB/StaticDataConnector](https://wiki.shibboleth.net/confluence/display/SHIB/StaticDataConnector), add the following into `resolver.ldap.xml`:

``` 

    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:o">
        <DataConnectorDependency requires="staticAttributesConnector"/>
    </SimpleAttributeDefinition>
 
    <SimpleAttributeDefinition id="urn:mace:dir:attribute-def:c">
        <DataConnectorDependency requires="staticAttributesConnector"/>
    </SimpleAttributeDefinition>
 
    <StaticDataConnector id="staticAttributesConnector">
        <Attribute name="o">
            <Value>University of Canterbury</Value>
        </Attribute>
        <Attribute name="c">
            <Value>NZ</Value>
        </Attribute>
    </StaticDataConnector>

```

And the following into `/usr/local/shibboleth-autograph/connectorConfigs/AttributeInfoPointData.xml`:

``` 

                <Attribute id="urn:mace:dir:attribute-def:o"  type="string">
                        <FriendlyName lang="en">organization</FriendlyName>
                        <Description lang="en">no description</Description>
                </Attribute>
                <Attribute id="urn:mace:dir:attribute-def:c"  type="string">
                        <FriendlyName lang="en">country</FriendlyName>
                        <Description lang="en">no description</Description>
                </Attribute>

```

# Adding a Scriptlet Attribute Definition

The [ScriptletAttributeDefinition element](https://wiki.shibboleth.net/confluence/display/SHIB/ScriptletAttributeDefinition) allows to use arbitrary Java code to construct the value of an attribute from other attributes.  This supersedes the problematic Crosswalk IF function, and provides a much more flexible solution.  However, same as for the StaticDataConnector, Autograph cannot handle a ScripletAttributeDefinition straight from the box, and a similar change to `shib-java.jar` may be necessary.

The internet2 page documents pretty clearly what can be used in the scriptlet.  Looking at further documentation, from 

>  edu.internet2.middleware.shibboleth.aa.attrresolv.Dependencies depencencies;

I can get:

``` 

        public Attributes getConnectorResolution(String id);
        public ResolverAttribute getAttributeResolution(String id);

Attributes I'd use will be accessed as edu.internet2.middleware.shibboleth.aa.attrresolv.ResolverAttribute
        public void addValue(Object value);
        public Iterator getValues();

Finally, a small scriptlet using the value of an attribute to compute a new attribute:
        <ScriptletAttributeDefinition id="urn:mace:dir:attribute-def:carLicense">
                <DataConnectorDependency requires="directory"/>
                <AttributeDependency requires="urn:mace:dir:attribute-def:givenName"/>
                <Scriptlet><![CDATA[
                  ResolverAttribute givenNameAttr = dependencies.getAttributeResolution("urn:mace:dir:attribute-def:givenName");
                  String givenNameStr = null;
                  if (givenNameAttr != null) {
                      Iterator i = givenNameAttr.getValues();
                      if (i.hasNext()) { givenNameStr = (String)i.next(); };
                  };
                  if (givenNameStr != null ) {
                    resolverAttribute.addValue("myCar:" + givenNameStr);
                  };
                ]]>
                </Scriptlet>
        </ScriptletAttributeDefinition>

```

# Terminating MediaWiki sessions when a Shibboleth session expires

With the ShibAuthPlugin, and particularly with how it integrates with the MediaWiki AccessControl extension, I've experienced the following issue:

When a Shibboleth sesison timed out, the PHP/MW session still stayed on, and the user would be permitted to access protected pages, even though Shibboleth and the ShibAuthPlugin thought there was no session anymore.  To edit pages, the user would be asked to login again, but the persisting PHP session would let the user through to restricted pages.

It's not really a security hole - it would only let through users who had previously established a valid session - but I still thought it would deserve some attention.

The following modification to ShibAuthPlugin fixes it: create a ShibForceLogout function that foces the PHP MW session to log the user out, when there's no Shibboleth session.  This function then get's called via a hook - and the hook is used only when there's no Shibboleth session.

``` 

--- ShibAuthPlugin.php-orig-2008-10-08  2008-10-08 13:03:00.000000000 +1300
+++ ShibAuthPlugin.php  2008-10-08 12:59:00.000000000 +1300
@@ -278,6 +278,17 @@
 }
 
 /*
+ * Vladimir Mencl 2008-10-08
+ * If there is no Shib Session, force a logout on the MW session
+ */
+function ShibForceLogout(&$user)
+{
+    global $shib_UN;
+    if (($user != null) && ($user->isLoggedIn()) && ($shib_UN == null)) $user->logout();
+    return true;
+}
+
+/*
  * End of AuthPlugin Code, beginning of hook code and auth functions
  */
 function SetupShibAuth()
@@ -304,6 +315,8 @@
         }
         else
        {
+                $wgHooks['AutoAuthenticate'][] = 'ShibForceLogout'; /* Hook for force a logout when there's no Shib session */
+
                 $wgHooks['PersonalUrls'][] = 'SSOLinkAdd';
                 if(isset($_GET['action']))
                 {

```

# SLCS client

Using the SLCS client for the ARCS test SLCS server - [https://slcstest.arcs.org.au/SLCS/login](https://slcstest.arcs.org.au/SLCS/login)

- Some SLCS client libraries are available at [https://projects.arcs.org.au/trac/slcs-client/](https://projects.arcs.org.au/trac/slcs-client/)
- But the real thing is the command-line client at
[https://projects.arcs.org.au/trac/slcs-client/wiki/CommandLineClient](https://projects.arcs.org.au/trac/slcs-client/wiki/CommandLineClient)

Do the steps as recommended:

``` 

 svn co https://projects.arcs.org.au/svn/slcs-client/trunk/org.glite.slcs.ui
 svn co https://projects.arcs.org.au/svn/slcs-client/trunk/org.glite.slcs.common
 cd org.glite.slcs.common
 ant repository
 ant
 cd ..
 cd org.glite.slcs.ui
 ant repository
 ant

```

- And then untar `glite-slcs-ui-1.3.2-jdk1.6.tar.gz` somewhere.
- Edit `etc/glite-slcs-ui/slcs-init.xml` and change the absolute path to `TrustStoreFile` to where the SLCS client is installed.
- Now run


>   ./slcs-init -i canterbury.ac.nz -u vme28
>   ./slcs-init -i canterbury.ac.nz -u vme28

# Minor bits of Shibboleth knowledge

A few questions I've asked Bruc Liong at eResearch2008:

- POST/Artifact profile
	
- => Artifact profile preferred if firewall permits
		
- Switching can be done by setting the `isDefault="true"` attribute in SP's `shibboleth.xml`:

``` 
<md:AssertionConsumerService Location="/SAML/POST" index="2" isDefault="true" Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post"/>
```

- 
- => POST profile should use encryption
		
- I wonder how the client would know SP's pub key and how it would be turned on => documented at [Internet2 Shibboleth space](https://wiki.shibboleth.net/confluence/display/SHIB2/IdPTroubleshootingCommonErrors#IdPTroubleshootingCommonErrors-edu.internet2.middleware.shibboleth.idp.profile.saml2.AbstractSAML2ProfileHandler%3AUnabletoconstructencrypter%2Ccausedby%3Aorg.opensaml.xml.security.SecurityException%3AKeyencryptioncredentialmaynotbenull)
- => POST profile will need to resolve attributes via AA if attributes not pushed (config in idp.xml), see [https://wiki.shibboleth.net/confluence/display/SHIB/AlternateProfiles](https://wiki.shibboleth.net/confluence/display/SHIB/AlternateProfiles)
- Redundancy in IdP:
	
- => yes, there is a solution (via a shared DB of issued tokens)
- => would need tomcat loadbalancer
- => would still have a single point of failure
- Forms vs. https for SSO authn:
	
- => https/apache preferred: simpler to administer, simpler with tools
- => use forms only if pressed by institution for branding

- An IdP can have multiple entityIds, each used for a different set of hosts (e.g., by federation membership).  This is configured by using multiple `RelyingParty` elements in `idp.xml`.  See [https://wiki.shibboleth.net/confluence/display/SHIB/IdPRelyingConfig](https://wiki.shibboleth.net/confluence/display/SHIB/IdPRelyingConfig)

- The format of a SAML Artifact is defined by [SAML](http://www.oasis-open.org/specs/#samlv1.1) [Bindings and Profiles](http://www.oasis-open.org/committees/download.php/3405/oasis-sstc-saml-bindings-1.1.pdf) as Base64 encoding of the following sequence:
	
- TypeCode: 0x0001
- SourceID: 20 byte sequence, SHA1 hash of entityId of the IdP
- AssertionHandle: 20-byte sequence, should be unfeasible to predict

## Forcing Attribute-Push for a single SP

The above can be combined into a RelyingParty configuration setting the forceAttributePush attribute:

## Configuring Admin Contact for Error Messages

When the IdP encounters an error and must display an error message, it would include the email address of the system administrator. This is configured by editing /var/lib/tomcat5/webapps/shibboleth-idp/IdPError.jsp (or ./webApplication/IdPError.jsp in the source tree).

Replace the text root@localhost (and the corresponding link) with the correct address.

## Generating a self-signed certificate

If one needs a Shibboleth 2.0 style self-signed certificate on a Shibboleth 1.3 system (such as to register with resource registry), this is the way to generate it:

- create OpenSSL configuration file `cert.conf` with the following contents (replace idp.example.org with your hostname)

``` 

# OpenSSL configuration file for creating sp-cert.pem
[req]
prompt=no
default_bits=2048
encrypt_key=no
default_md=sha1
distinguished_name=dn
# PrintableStrings only
string_mask=MASK:0002
x509_extensions=ext
[dn]
CN=idp.example.org
[ext]
subjectAltName=DNS:idp.example.org,URI:https://idp.example.org/idp/shibboleth
subjectKeyIdentifier=hash

```
- generate the certificate with


>  openssl req -x509 -newkey rsa:2048 -nodes -out `hostname`-self-cert.pem -keyout `hostname`-self-key.pem -config cert.conf
>  openssl req -x509 -newkey rsa:2048 -nodes -out `hostname`-self-cert.pem -keyout `hostname`-self-key.pem -config cert.conf

## Generating self-signed certs with CA:FALSE

To improve on the above and generate a self-signed certificate that is up to the current best practise (while still being self-signed) as of December 2014 so that it:

- uses SHA-256: add the following to the `openssl req` command line: 

``` 
-sha256
```
- sets `basicConstraints = CA:FALSE`: reuse existing `v3_req` section in default openssl.conf with: 

``` 
-extensions v3_req
```

Alternatively, we could create our own section with further customized extensions with: 

``` 
{ cat /etc/pki/tls/openssl.cnf ; echo '[v3_no_ca]' ; echo 'basicConstraints = CA:false' ; } > /tmp/openssl-v3-no-ca.conf
```

But this one will do to generate the certificate with reusing the existing extensions section: 

``` 
/usr/bin/openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/localhost.key -x509 -days 3650 -set_serial $RANDOM -out /etc/pki/tls/certs/localhost.crt -extensions v3_req -sha256
```

## HTTP Strict Transport Security

HSTS ([HTTP Strict Transport Security](http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) allows to mark a website as requiring secure transport.

- It is activated by adding a "Strict-Transport-Security" header, e.g. with: 

``` 
Header append "Strict-Transport-Security" "max-age=31536000; includeSubDomains"
```
- And can be deactivated for a client if the client sees a header with max-age=0: 

``` 
Strict-Transport-Security: max-age=0; includeSubDomains
```

Important notes:

- An HSTS Host MUST NOT include the STS header field in HTTP responses conveyed over non-secure transport.
- A browser would process the HSTS header only if there are no underlying secure transport errors or warnings - it is ignored on websites with certificate errors.
- Specifically, it is ignored if any of the following is encountered:
	
- Syntax errors in the header itself
- Secure transport errors
- If received over insecure transport
- If received over IP-address URL

Once processed, the HSTS policy

1. Tells the browser to write ALL urls with that hostname from http to https - but only if received correctly, i.e., over secure transport with no errors.
2. Tells the browser NOT to permit click-through when secure transport errors are encountered.  The browser then does not offer the user the option to accept certificate errors at all.

## AAF Pilot Entity Group Names

- "aaf.edu.au" (no URN prefix) for Pilot Test
- "urn:mace:aaf.edu.au:AAFProduction" for Pilot production

## Shibboleth 2.0 policy filter

- Shibboleth 2.0 policy filter `basic:OR` does not work with just one operand.
	
- Either use the same operand twice 🙂, or use the operand at top-level directly - like: 

``` 
<PolicyRequirementRule xsi:type="basic:AttributeRequesterString" value="https://manager.aaf.edu.au/shibboleth" />
```

## IdP and SP metadata URLs

- The IdP metadata can be retrieved from: [https://idp.example.org/idp/profile/Metadata/SAML](https://idp.example.org/idp/profile/Metadata/SAML)
- The SP metadata can be retrieved from: [https://sp.example.org/Shibboleth.sso/Metadata](https://sp.example.org/Shibboleth.sso/Metadata)

## Getting raw assertions

- Add `exportAssertion="true"` into the `Path` element in the `RequestMapper` in `/etc/shibboleth/shibboleth2.xml`
- Alternatively, add the following Apache directive into `/etc/httpd/conf.d/shib.conf`:

``` 
ShibRequestSetting exportAssertion true
```
- Access /secure on the host and dump the Apache environment - e.g., with phpinfo()
- The Apache environemnt now contains entries like:

``` 

Shib-Assertion-01 	http://localhost/Shibboleth.sso/GetAssertion?key=_cbf2e5ecb17c7f1a4a56e7ebb06122ba&ID=_fb3417ef0316a2beb53ccd6c131541ec
Shib-Assertion-Count 	01 

```
- Log into the host and with a locally running browser (links), access the URL - you may have to change http to https.  This will give you the XML raw assertion.

- See [https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPAssertionExport](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPAssertionExport) for more information

## Configuring multiple DS initiators with ShibSP 2.4

Shib SP 2.4 introduces a single **SSO** element that points to ONE DS.

To experiment with different Discovery Services and have explicit session initiator URLs pointing to the different DS instances, add the `SessionInitiator` element (or more of them) into `shibboleth2.xml` **after** the `SSO` and `Logout` elements.

Example:

``` 

            <SSO 
                 discoveryProtocol="SAMLDS" discoveryURL="https://directory.test.tuakiri.ac.nz/ds/DS">
              SAML2 SAML1
            </SSO>
            <!-- taken out: entityID="https://idp.example.org/shibboleth" -->

            <!-- SAML and local-only logout. -->
            <Logout>SAML2 Local</Logout>

            <!-- manually defined additional DS initiators - without isDefault and with custom IDs and Locations -->
            <SessionInitiator type="Chaining" Location="/DS-AAF-TEST" id="DS-AAF-TEST" relayState="cookie">
                <SessionInitiator type="SAML2" acsIndex="1" template="bindingTemplate.html"/>
                <SessionInitiator type="Shib1" acsIndex="5"/>
                <SessionInitiator type="SAMLDS" URL="https://ds.test.aaf.edu.au/discovery/DS"/>
            </SessionInitiator>

            <SessionInitiator type="Chaining" Location="/DS-Tuakiri-TEST" id="DS-Tuakiri-TEST" relayState="cookie">
                <SessionInitiator type="SAML2" acsIndex="1" template="bindingTemplate.html"/>
                <SessionInitiator type="Shib1" acsIndex="5"/>
                <SessionInitiator type="SAMLDS" URL="https://directory.test.tuakiri.ac.nz/ds/DS"/>
            </SessionInitiator>

            <SessionInitiator type="Chaining" Location="/DS-Tuakiri-DEV" id="DS-Tuakiri-DEV" relayState="cookie">
                <SessionInitiator type="SAML2" acsIndex="1" template="bindingTemplate.html"/>
                <SessionInitiator type="Shib1" acsIndex="5"/>
                <SessionInitiator type="SAMLDS" URL="https://directory.test.tuakiri.ac.nz/ds-DEV/DS"/>
            </SessionInitiator>

            <SessionInitiator type="Chaining" Location="/DS-Tuakiri" id="DS-Tuakiri" relayState="cookie">
                <SessionInitiator type="SAML2" acsIndex="1" template="bindingTemplate.html"/>
                <SessionInitiator type="Shib1" acsIndex="5"/>
                <SessionInitiator type="SAMLDS" URL="https://ds.tuakiri.ac.nz/ds/DS"/>
            </SessionInitiator>

```

Then access the URLs via /Shibboleth.sso on the HTTPS port: [https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/DS-Tuakiri-TEST](https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/DS-Tuakiri-TEST)

>  **Important: for these new DS endpoints to work with the Shibboleth project DS implementation, it is necessary to register all of these endpoints into the metadata loaded by the DS - registering multiple***Discovery Response Service** endpoints.  

- Example:

``` 

  <EntityDescriptor entityID="https://gridgwtest.canterbury.ac.nz/shibboleth">
    <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
      <Extensions>
        <dsr:DiscoveryResponse xmlns:dsr="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Binding="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Location="https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/DS-Tuakiri" index="4" isDefault="false"/>
        <dsr:DiscoveryResponse xmlns:dsr="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Binding="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Location="https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/DS-Tuakiri-DEV" index="3" isDefault="false"/>
        <dsr:DiscoveryResponse xmlns:dsr="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Binding="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Location="https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/Login" index="0" isDefault="true"/>
        <dsr:DiscoveryResponse xmlns:dsr="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Binding="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Location="https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/DS-AAF-TEST" index="1" isDefault="false"/>
        <dsr:DiscoveryResponse xmlns:dsr="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Binding="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol" Location="https://gridgwtest.canterbury.ac.nz/Shibboleth.sso/DS-Tuakiri-TEST" index="2" isDefault="false"/>
      </Extensions>

```

## Tweaking the ShibSP SessionInitiator with query parameters

>  **To force login through the default SessionInitiator going directly to an IdP, pass the IdP entityID in the**`entityID`* query parameter:
>  [https://www.etv.org.nz/Shibboleth.sso/DS?entityID=https://idp.canterbury.ac.nz/idp/shibboleth&target=http://www.etv.org.nz/shib/](https://www.etv.org.nz/Shibboleth.sso/DS?entityID=https://idp.canterbury.ac.nz/idp/shibboleth&target=http://www.etv.org.nz/shib/)

 **To use a different DS than the one set in the SessionInitiator configuration, pass the DS URL in the**`discoveryURL`* query parameter:

>  [https://www.etv.org.nz/Shibboleth.sso/DS?discoveryURL=https://directory.tuakiri.ac.nz/ds/DS&target=http://www.etv.org.nz/shib/](https://www.etv.org.nz/Shibboleth.sso/DS?discoveryURL=https://directory.tuakiri.ac.nz/ds/DS&target=http://www.etv.org.nz/shib/)

## Accessing HTTPS URLs from a Shibboleth IdP configuration

When running a Shibboleth IdP on OpenJDK-1.6.0-Java, care must be taken to make sure all HTTPS servers are properly configured.  OpenJDK's SSL implementation is pickier then OpenSSL or Sun Java's SSL and rejects servers that are offering extra certificates in the certificate chain - even if the chain also includes all certificates needed to establish the trust.

## Shib Logout

- SP configuration page: [https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPServiceLogout](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPServiceLogout)
- **Application-level*Notify** [https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPNotify](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPNotify)

- IdP logout - why not implemented [https://wiki.shibboleth.net/confluence/display/SHIB2/SLOIssues](https://wiki.shibboleth.net/confluence/display/SHIB2/SLOIssues)

## Generating a shared token value

Manually:

``` 
openssl rand -base64 20 | tr "/+=" "_\- " 
```

## Re-creating the back-channel certificate on an IdP

- To recreate the back-channel certificate on an IdP without overwriting the configuration files, run: 

``` 
~/inst/shibboleth-identityprovider-2.3.2# ./install.sh renew-cert
```

>  **This invokes an*ant** task that creates idp.crt, idp.key and idp.jks
>  **This invokes an*ant** task that creates idp.crt, idp.key and idp.jks

- It is still necessary to manually replace the certificate in `/opt/shibboleth-idp/metadata/idp-metadata.xml`

## Forcing a SAML2 Artifact profile login

The SP typically defaults to requesting the login via the SAML HTTP-POST profile.  The SAML2 Artifact profile can be selected by passing the ACS index of the endpoint (3 in default configuration) to the session initiator.

- This can be done either as a query string parameter in an explicit SSO request:


>  [https://wiki.test.bestgrid.org/Shibboleth.sso/Login?acsIndex=3&target=http://wiki.test.bestgrid.org/index.php/Main_Page](https://wiki.test.bestgrid.org/Shibboleth.sso/Login?acsIndex=3&target=http://wiki.test.bestgrid.org/index.php/Main_Page)
>  [https://wiki.test.bestgrid.org/Shibboleth.sso/Login?acsIndex=3&target=http://wiki.test.bestgrid.org/index.php/Main_Page](https://wiki.test.bestgrid.org/Shibboleth.sso/Login?acsIndex=3&target=http://wiki.test.bestgrid.org/index.php/Main_Page)

- Or by adding the parameter to the request content setting in Apache configuratino:


>  ShibRequestSetting acsIndex 3
>  ShibRequestSetting acsIndex 3

**NOTE**: On systems running Shibboleth SP 2.4.x and using the default configuration with the `SSO` element, this will not work: due to a know bug ([SSPCPP-439](https://issues.shibboleth.net/jira/browse/SSPCPP-439)), the indexes for the ACS endpoints are not recognized (and are seen as starting from 0 in the internal metadata).  This has been fixed in Shib SP 2.5.0.  Either update to 2.5.0 or use explicit configuration instead of the `SSO` element if needing to have the option to force the attribute profile.

**NOTE**: It may be better to avod forcing the SAML2 Artifact profile ... as many IdPs do not have their 8443 port properly configured / reachable.

**NOTE**: Apparently, cannot be used to force a SAML1 login by choosing acsIndex 5 or 6

## Shibboleth SP 2.5.0

Shibboleth SP 2.5.0 is available as of early August 2012 and is the default versionin the security_shibboleth repo.

Key new features introduced are:

- Apache 2.4 support
- [NativeSPBackDoor](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPBackDoor): allowing applications to mimick a Shibboleth login from local auth data - SAML Artifacts via local filesystem to be generated by an app that does a local login.
- shibd is running as shibd instead of root.
- Fix for [SSPCPP-439](https://issues.shibboleth.net/jira/browse/SSPCPP-439) - see notes in [#Forcing a SAML2 Artifact profile login](#Vladimir&#39;sgeneralShibbolethnotes-ForcingaSAML2Artifactprofilelogin) above.

Release notes links:

- [https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPInterestingFeatures#NativeSPInterestingFeatures-NewinShibboleth25BetaReleased](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPInterestingFeatures#NativeSPInterestingFeatures-NewinShibboleth25BetaReleased)
- [https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPConfigurationChanges#NativeSPConfigurationChanges-Shibboleth250ConfigurationChanges](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPConfigurationChanges#NativeSPConfigurationChanges-Shibboleth250ConfigurationChanges)

Upgrade notes:

- Shib SP 2.5 will be running as shibd, not root.  Care will have to be taken around file ownership/permissions, no longer root.
- Minor changes to Apache shib.conf, attribute-map.xml, shibboleth2.xml
	
- shibboleth2.xml adds new `helpLocation="/about.html"` - this would only be used if an AttributeChecker handler would be used (and would be referenced from the attrChecker.html template.  In such a case, point to an application-specific page explaining the attribute requirements the application has)
- shibboleth logo has disappeared (from the RPM and from Apache aliases in shib.conf) - but if if `logoLocation` also removed from the `Errors` element in `shibboleth2.xml` (not present in the new default config), ShibSP stops using the logo at all in error pages - and there are no broken links.
- the default AttributeExtractor entry (in `shibboleth2.xml`) now adds an `reloadChanges="false"` option - changes this to `reloadChanges="true"`
- Running all fine with 2.4.x config files.

## Upgrading to 2.5.0

- Note: the same procedure applies for upgrades from 2.4.x branch to 2.5.1 (no change in config files between 2.5.0 and 2.5.1)

- Save a copy of your Shib-Apache config file (`/etc/httpd/conf.d/shib.conf`)
- Update shib RPMs: 

``` 
yum --disablerepo="*" --enablerepo=security_shibboleth update
```
- Re-apply changes to the `shib.conf` file

To switch to new shibboleth2.xml file (saved as `shibboleth2.xml.rpmnew`), copy over the following settings:

- Discovery service URL: `discoveryURL="https://directory.tuakiri.ac.nz/ds/DS"`
- EntityID: 

``` 
<ApplicationDefaults entityID="https://sp.example.org/shibboleth"
```
- Metadata URLs
- SSO `ECP="true"` option (if used)
- Set `handlerSSL="true"` (default is now to include the option and say `handlerSSL="false"`)
- In AttributeExtractor, set `reloadChanges="true"`
- Set supportContact to your helpdesk address
- Leave logoLocation unset

## Unsolicited SSO

- SAML1: must pass providerId, shire (ACS URL for either POST or Artifact) and target parameters:
	
- [https://idp.example.org/idp/profile/Shibboleth/SSO?providerId=https://sp.example.org/shibboleth&target=https://sp.example.org/attributes/&shire=https://sp.example.org/Shibboleth.sso/SAML/Artifact](https://idp.example.org/idp/profile/Shibboleth/SSO?providerId=https://sp.example.org/shibboleth&target=https://sp.example.org/attributes/&shire=https://sp.example.org/Shibboleth.sso/SAML/Artifact)
- [https://idp.example.org/idp/profile/Shibboleth/SSO?providerId=https://sp.example.org/shibboleth&target=https://sp.example.org/attributes/&shire=https://sp.example.org/Shibboleth.sso/SAML/POST](https://idp.example.org/idp/profile/Shibboleth/SSO?providerId=https://sp.example.org/shibboleth&target=https://sp.example.org/attributes/&shire=https://sp.example.org/Shibboleth.sso/SAML/POST)
- Tuakiri examples: [Artifact](https://virtualhome.tuakiri.ac.nz/idp/profile/Shibboleth/SSO?providerId=https://virtualhome.tuakiri.ac.nz/shibboleth&target=https://virtualhome.tuakiri.ac.nz/attributes/&shire=https://virtualhome.tuakiri.ac.nz/Shibboleth.sso/SAML/Artifact) [POST](https://virtualhome.tuakiri.ac.nz/idp/profile/Shibboleth/SSO?providerId=https://virtualhome.tuakiri.ac.nz/shibboleth&target=https://virtualhome.tuakiri.ac.nz/attributes/&shire=https://virtualhome.tuakiri.ac.nz/Shibboleth.sso/SAML/POST)

- SAML2: passing providerId is enough: [https://idp.example.org/idp/profile/SAML2/Unsolicited/SSO?providerId=https://sp.example.org/shibboleth](https://idp.example.org/idp/profile/SAML2/Unsolicited/SSO?providerId=https://sp.example.org/shibboleth)
	
- Tuakiri example: [SAML2](https://virtualhome.tuakiri.ac.nz/idp/profile/SAML2/Unsolicited/SSO?providerId=https://virtualhome.tuakiri.ac.nz/shibboleth)
- ***Note**: SAML2 Unsolicited SSO support was added only in Shibboleth IdP 2.3.x.
	
- 
- IdPs running older releases do not support this protocol (proprietary extensions).
- IdPs running with configuration files created by an older installer may need to have this profile added to `handler.xml` and `internal.xml` as per instructions on the link below.

- References: [https://wiki.shibboleth.net/confluence/display/SHIB2/IdPUnsolicitedSSO](https://wiki.shibboleth.net/confluence/display/SHIB2/IdPUnsolicitedSSO)

## IdP Audit Log Structure

I have not been able to find any definition of what goes into `/opt/shibboleth-idp/logs/idp-audit.log` - and neither find the source code for edu.internet2.middleware.shibboleth.common.log.AuditLogEntry.toString() to find the order of the fields.

Here is make take on the structure based on dissecting fields:

``` 

#1 Timestamp    | #2 Binding                                       | #3 Request Id                   | #4 SP entityId                                     | #5 SAML Request binding                             | #6 IdP entityId                                     | #7 SAML Response binding                     | #8 Response Id                  |#9 Principal name| #10 Authentication Method                                       | #10 List of attributes | # 11 User transient Id          | #12 blank |
20140526T203903Z|urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect|_5c81d23d52d20203ca0a5ab4f4e768d6|https://myproxyplusdev.canterbury.ac.nz/shibboleth  |urn:mace:shibboleth:2.0:profiles:saml2:sso           |https://virtualhome.test.tuakiri.ac.nz/idp/shibboleth|urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST|_afa34347c273159521141ce70cd4195f|tuakiritest-mke65|urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport|homeOrganizationType,eduPersonPrincipalName,commonName,eduPersonAffiliation,auEduPersonSharedToken,organizationName,transientId,surname,eduPersonScopedAffiliation,givenName,homeOrganization,eduPersonTargetedID,email,eduPersonAssurance,displayName,_f3f870cc13ea4054f91b1667f1c3d663||
20140528T005808Z|urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect|_00a6f7aa90bcbb171caa3119f8c202d1|https://registry.tamaki.dev.tuakiri.ac.nz/shibboleth|urn:mace:shibboleth:2.0:profiles:saml2:sso           |https://virtualhome.test.tuakiri.ac.nz/idp/shibboleth|urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST|_3d7600dfe8f8f5474f26c76926d8e8e0|tuakiritest-vlad |urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport|commonName,eduPersonAffiliation,auEduPersonSharedToken,transientId,eduPersonTargetedID,email,eduPersonAssurance,|_bddce333206a6e38ea8d5c8bc123c1ac||

```

## Dumping attribute values

To dump the attributes (set up a simple attribute reflector), one can use any of the three with PHP:

- Dump the whole PHP info - this includes the Shibboleth session environment - with:

``` 

<?
phpinfo();
?>

```

- Restrict this to just the Modules info which contains the Shibboleth session with:

``` 

<?
phpinfo(INFO_MODULES);
?>

```

- To dump just the list of attributes and have their values split, use this PHP script:

# Shibbolized systems

Systems that support Shibboleth login - AFAIK

- See the completely list at [https://wiki.shibboleth.net/confluence/display/SHIB2/ShibEnabled](https://wiki.shibboleth.net/confluence/display/SHIB2/ShibEnabled)

So far:

- MediaWiki
- Confluence Wiki
- JIRA
- GridSphere
- Blackboard
- Moodle
- Elsevier ScienceDirect
- Microsoft Dreamspark
- Grid: SLCS server
- Grid: Hermes: Data storage
- Library chat helpdesk
- SubEtha: Mailing lists
- OpenMeeting: video conferencing
