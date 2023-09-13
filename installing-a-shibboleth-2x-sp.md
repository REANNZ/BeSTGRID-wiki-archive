# Installing a Shibboleth 2.x SP

There's already plenty of documentation on how to install a Shibboleth SP, covering also Shibboleth 2.x - notably:

- [https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLinuxInstall](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLinuxInstall)
- [https://wiki.shibboleth.net/confluence//display/SHIB2/NativeSPConfigurationElements](https://wiki.shibboleth.net/confluence//display/SHIB2/NativeSPConfigurationElements)

This page documents a simple sequence of steps to get a Shibboleth SP working in the Australian + NZ AAF/ARCS/BeSTGRID environment.

This documentation covers Shibboleth SP 2.2.1.  It is tested on CentOS 5.  It should work as well on CentOS/RHEL 4.

# Download and installation

- Install prerequisites (Apache with mod_ssl)


>  yum install httpd mod_ssl
>  yum install httpd mod_ssl

- Install latest version via YUM


>  wget [http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo](http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo) -P /etc/yum.repos.d
>  yum install shibboleth
>  wget [http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo](http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo) -P /etc/yum.repos.d
>  yum install shibboleth

# Federation membership

- Register the host in the federation.
	
- For AAF, go to [https://manager.aaf.edu.au/rr/](https://manager.aaf.edu.au/rr/)
- Preferrably, use an entityID based on the host name - such as [https://sp.example.org/shibboleth](https://sp.example.org/shibboleth)
- Manually add a SAML1 Browser POST, with a URL like [https://sp.example.org/Shibboleth.sso/SAML/POST](https://sp.example.org/Shibboleth.sso/SAML/POST)

>  **Note: the AAF RR requires that your self-signed certificate*includes** the entityID as subject altName URI.  When installing the Shibboleth RPM, the certificate got generated without the entityID.  You have to re-generate the self-signed certificate with
>  cd /etc/shibboleth
>  ./keygen.sh -f -e https://*_sp.example.org_*/shibboleth

- Instead of replacing sp.example.org with your hostname, you may also run:


>  ./keygen.sh -f -e https://`hostname`/shibboleth
>  ./keygen.sh -f -e https://`hostname`/shibboleth

# Configuration

- Download AAF metadata signing certificate 

``` 
wget https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem -O /etc/shibboleth/aaf-metadata-cert.pem
```
- Note: download the file from [https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem](https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem), not [https://manager.aaf.edu.au/metadata/metadata-cert.pem](https://manager.aaf.edu.au/metadata/metadata-cert.pem)

- Edit `/etc/shibboleth/shibboleth2.xml`
	
- Replace all instances of `sp.example.org` with your hostname.
- Add the following or relevant section into `/etc/shibboleth/shibboleth2.xml` under 

``` 
<MetadataProvider type="Chaining">
```
``` 

             <MetadataProvider type="XML" uri="https://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml"
                  backingFilePath="metadata.aaf.xml" reloadInterval="7200">
                <MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>
                <MetadataFilter type="Signature" certificate="aaf-metadata-cert.pem"/>
             </MetadataProvider>

```

>  **Make session handler use SSL: in*Sessions** element, set `handlerSSL="true"`

- Configure Session Initiator
	
- Configure the URL for the SAMLDS initiator to [https://ds.aaf.edu.au/discovery/DS](https://ds.aaf.edu.au/discovery/DS)
- Move the `isDefault="true"` from the `Intranet` session initiator to the `DS` session Initiator

- Change attribute map.  Instead of editing attribute-map.xml manually to accept attributes, configure Shibboleth to pull a pre-configured one from the ARCS website (courtesy Sam Morrison).  Edit `/etc/shibboleth/shibboleth2.xml` and change the {{}} definition to:

``` 

         <AttributeExtractor type="XML" uri="http://static.arcs.org.au/sp/attribute-map.xml"
                             backingFilePath="attribute-map.xml" reloadInterval="7200"
                             validate="false"/>

```

- Optionally, change the `SupportContact` attribute in the `Errors` element to something more meaningful then `root@localhost`

# 64-bit platforms

On x86_64, edit /etc/httpd/conf.d/shib.conf and change the path to the Shibboleth Apache module to 64-bit version:

>  LoadModule mod_shib /usr/**lib64**/shibboleth/mod_shib_22.so

# Finishing up

This should get you going.

- Start up Apache and shibd:


>  service httpd start
>  service shibd start
>  chkconfig httpd on
>  chkconfig shibd on
>  service httpd start
>  service shibd start
>  chkconfig httpd on
>  chkconfig shibd on

- And try accessing [http://your.server/secure](http://your.server/secure)
