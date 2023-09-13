# Migrating Shibboleth 1.3 SP to 2.x in BeSTGRID Federation

These notes document the work I (Vladimir Mencl) have done while migrating the BeSTGRID wiki from MAMS Level 2 into AAF and at the same time upgrading them from Shibboleth 1.3.x to Shibboleth 2.x.

These notes may be useful for similar migration on other hosts - either just for a pure Shibboleth upgrade, or also for the other additional aspects captured here:

- membership in BeSTGRID federation
- configuring the WAYF server
- adjusting MediaWiki to work with Shibboleth 2.x

# WAYF server

First, I have configured the WAYF server to pull in the AAF metadata.

- Note: WAYF server configuration is in: `/usr/local/apache-tomcat-5.5.23/webapps/shibboleth-wayf/WEB-INF/classes/wayfconfig.xml`
- Metadata are downloaded into `/usr/local/shibboleth-wayf/`

## Download AAF metadata

- Get signing certificate

>  cd /usr/local/shibboleth-idp-metadatatool/certs
>  wget [https://manager.aaf.edu.au/metadata/aaf-metadata.jks](https://manager.aaf.edu.au/metadata/aaf-metadata.jks)

- Create `/etc/cron.hourly/idp-aaf-metadata` (based on idp-aafL2-metadata) and change:


>  export METADATA_URL=[http://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml](http://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml)
>  export OUTPUT_FILE=/usr/local/shibboleth-wayf/aaf-metadata.xml
>  export METADATA_URL=[http://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml](http://manager.aaf.edu.au/metadata/metadata.aaf.signed.xml)
>  export OUTPUT_FILE=/usr/local/shibboleth-wayf/aaf-metadata.xml


- Do the same for AAF Test Federation: /etc/cron.hourly/idp-aaf-test-metadata


>  export METADATA_URL=[http://manager.test.aaf.edu.au/metadata/metadata.aaf.signed.xml](http://manager.test.aaf.edu.au/metadata/metadata.aaf.signed.xml)
>  export OUTPUT_FILE=/usr/local/shibboleth-wayf/aaf-test-metadata.xml
>  export METADATA_URL=[http://manager.test.aaf.edu.au/metadata/metadata.aaf.signed.xml](http://manager.test.aaf.edu.au/metadata/metadata.aaf.signed.xml)
>  export OUTPUT_FILE=/usr/local/shibboleth-wayf/aaf-test-metadata.xml

- A bit more difficult getting the keystore for TEST:


>  wget [https://manager.test.aaf.edu.au/metadata/metadata-cert.pem](https://manager.test.aaf.edu.au/metadata/metadata-cert.pem) -O aaf-test-metadata-cert.pem
>  /usr/java/java/bin/keytool -import -alias aaf-test-metadata-cert -file aaf-test-metadata-cert.pem -keystore aaf-test-metadata.jks -storepass aaf-metadata
>  wget [https://manager.test.aaf.edu.au/metadata/metadata-cert.pem](https://manager.test.aaf.edu.au/metadata/metadata-cert.pem) -O aaf-test-metadata-cert.pem
>  /usr/java/java/bin/keytool -import -alias aaf-test-metadata-cert -file aaf-test-metadata-cert.pem -keystore aaf-test-metadata.jks -storepass aaf-metadata

## Configure WAYF server with AAF metadata

Just add additional `MetadataProvider` elements into `wayfconfig.xml` (and restart tomcat): 

``` 
service tomcat restart
```

# Updating Shibboleth

- backup Shibboleth configuration


>  tar czf etc-shibboleth-backup-2009-11-25.tar.gz /etc/shibboleth
>  tar czf etc-shibboleth-backup-2009-11-25.tar.gz /etc/shibboleth

- install Shibboleth 2.3 yum repository:
	
- On CentOS/RHEL 5: 

``` 
wget http://download.opensuse.org/repositories/security://shibboleth/CentOS_5/security:shibboleth.repo -P /etc/yum.repos.d
```
- On CentOS 4: 

``` 
wget http://download.opensuse.org/repositories/security://shibboleth/RHEL_4/security:shibboleth.repo -P /etc/yum.repos.d
```


- move remaining stuff in /etc/shibboleth somewhere safe:

mv /etc/shibboleth /root/etc-shibboleth-1.3

- For subsequent steps (Shibboleth installation), follow [http://www.bestgrid.org/index.php/Installing_a_Shibboleth_2.x_SP](http://www.bestgrid.org/index.php/Installing_a_Shibboleth_2.x_SP)

- Install Shibboleth and dependencies 

``` 
yum install shibboleth
```
- (may need to run it twice, RPM key is imported in the first go, installation succeeds in the second go)


- Download AAF metadata signing cert


>  wget [https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem](https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem) -O /etc/shibboleth/aaf-metadata-cert.pem
>  wget [https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem](https://manager.aaf.edu.au/metadata/aaf-metadata-cert.pem) -O /etc/shibboleth/aaf-metadata-cert.pem

- Edit /etc/shibboleth/shibboleth2.xml
	
- Follow the default instructions on:
		
- replace sp.example.org with local hostname
- add AAF metadata
- Optionally, edit `Errors supportContact`

- Do custom configuration:
	
- use BeSTGRID (test) WAYF server and not DS - to give a choice between the BeSTGRID Federation and AAF
		
- make "WAYF" default
- use URL [https://wayf.bestgrid.org/shibboleth-wayf/WAYF](https://wayf.bestgrid.org/shibboleth-wayf/WAYF)
- use Location="/WAYF/wayf.bestgrid.org" (default WAYF would live at "/Shibboleth.sso/WAYF" but MW Shib plugin can't be configured for that)

- Manually edit `attribute-map.xml` and uncomment givenName,sn,cn,displayName,mail, primary-affiliation (eppn + unscoped-affiliation are uncommented) + their OID equivalents

# Configure BeSTGRID test metadata in shibboleth.xml

- This can be in the end done quite simply by pulling the metadata over https:

``` 

            <MetadataProvider type="XML" uri="https://wayf.test.bestgrid.org/metadata/bestgrid-test-metadata.xml" backingFilePath="bestgrid-test-metadata.xml" validate="true" />

```

- Note that shibd (curl) does not check the certificate and this works even for pulling the metadata from a host with a self-signed certificate (wayf.test.bestgrid.org)

Alternative approaches:

- Loading a local file as a URI ([file:///](file:///)) does not work (ERROR "Error writing body" in shibd.log)
- Loading a local file as a PATH works.  With validation enabled, Shibd even detects errors and will keep original version if current file is broken.
	
- But, this would still break if shibd is restarted.

# Register new entityID in Bestgrid (test) federation

- copy entityDescriptor block over from AAF metadata
- remove existing descriptor - both with urn entityID and second set of URLs from BeSTGRID (test) IdP

# Making MediaWiki work again

## Enable global lazy sessions

Edit `/etc/httpd/conf.d/shib.conf`

``` 

<Location />
  AuthType shibboleth
  ShibRequireSession off
  require shibboleth
</Location>

```

## Customize MW to fit into new environment

- Edit LocalSettings.php and modify all $_SERVER references to use new variable names.
- use displayName instead of givenName + sn
