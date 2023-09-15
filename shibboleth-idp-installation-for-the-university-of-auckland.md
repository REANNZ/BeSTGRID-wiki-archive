# Shibboleth IdP Installation For The University of Auckland

# Introduction

The article covers all details of the installation of Shibboleth IdP for The University of Auckland (UoA). It also describes the process about how to take part in Australian Access Federation (AAF). 

For general Shibboleth IdP installation, please refer to [general Shibboleth IdP installation](/wiki/spaces/BeSTGRID/pages/3818228900) or [OpenIdP installation](install-open-identity-provider.md)

# Installation Environment

UoA Shibboleth IdP installs on the two servers for load balancing and high availability purposes. These servers are also hosting cosign which also known as UoA Unisign (UoA main authentication mechanism). Redhat Enterprise Linux 4 is installed on both servers and maintaining by ITS ESG team. 

# Prerequisites

The following application softwares are required to be installed prior the Shibboleth IdP installation

- Tomcat 5.5.x
- Apache HTTPD 2.0.x with SSL support (2.2.x and 1.3.x also works, but their configuration will not be describes in here
- mod_jk
- Java 1.5 (1.4+ works, but must be paired with an older Tomcat. 1.6 won't be support).

# mod_jk configuration

- Create a configuration file (e.g. mod_jk.conf) in Apache HTTPD configuration directory (usually at /etc/httpd/conf.d).
- Create a worker properties file (e.g. workers.properties)

- mod_jk.conf

``` 

LoadModule jk_module modules/mod_jk.so
#
# Mod_jk settings
#
JkWorkersFile "conf/workers.properties"
JkLogFile "|/usr/sbin/rotatelogs /var/log/httpd/mod_jk.log.%Y%m%d 86400 720"

JkLogLevel error
JkMount /shibboleth-idp default
JkMount /shibboleth-idp/* default
# End of mod_jk settings

```

- workers.properties

``` 

workers.tomcat_home=/usr/local/tomcat
workers.java_home=/usr/java/latest
ps=/
worker.list=default
worker.default.port=8009
worker.default.host=localhost
worker.default.type=ajp13
worker.default.lbfactor=1

```

# Install Shibboleth IdP

- Download [Shibboleth IdP 1.3.2](http://shibboleth.internet2.edu/downloads/shibboleth-idp-1.3.2.tar.gz) from internet2

- Download [HA-Shib](https://www.middleware.georgetown.edu/confluence/download/attachments/442/hashib-1.0.jar?version=1). HA-Shib is an extension for the Shibboleth 1.3 IdP that allows multiple IdP instances to be clustered together and share in-memory state for handle and artifact mapping.

- Extract Shibboleth IdP into a temporary working directory. We will refer to this directory as shibboleth-1.3.2-install

- Create a directory (hashib) for HA-Shib inside shibboleth-1.3.2-install/custom/

- Extract hashib-1.0.jar

>  **Copy all shibboleth-1.3.2-install/endorsed/**.jar to $TOMCAT_HOME/common/endorsed

 **Run the installation script*shibboleth-1.3.2-install/ant**, and this will take you through a series of question. 

# Configure Shibboleth IdP

**The main configuration of Identity Provider is located in *idp_home**/etc/idp.xml, other important configuration files include attribute source (e.g resolver.ldap.xml), metadata files (e.g. bestgrid-metadata.xml) and attribute release policy files (e.g. arp.site.xml). Please have a look the [General Shibboleth IdP Installation Guide](/wiki/spaces/BeSTGRID/pages/3818228900#Shibboleth-idp-Step_10___Configure_Shibboleth_IdP) for more details. 

- Please have a look the example configuration files below:

*[idp.xml](uoa-idpxml.md)

*[resolver.ldap.xml](uoa-idp-resolverldapxml.md) (NOTE: If you are using secure connection for LDAP, please append the CA into Java cacerts by using keytool)

*[arp.site.xml](/wiki/spaces/BeSTGRID/pages/3818228668)

*[bestgrid-metadata.xml](https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml)

- The configuration for HA-Shib is a little bit different than the general Shibboleth IdP. Please have a look [below](#ShibbolethIdPInstallationForTheUniversityofAuckland-Configure_HA-Shib)

# Configure HA-Shib

- update idp.xml

**Create another *NameMapping** as below. (It may not work with the existing **NameMapping** element).

``` 
<NameMapping xmlns="urn:mace:shibboleth:namemapper:1.0" id="hashib_mapping" format="urn:mace:shibboleth:1.0:nameIdentifier" 
class="edu.georgetown.middleware.shibboleth.idp.ha.nameIdentifier.ReplicatedHandleMapper" /> 
```

**Update name mapping inside *ReplyingParty**

``` 

<RelyingParty name="urn:mace:bestgrid" signingCredential="bestgrid" providerId="urn:mace:bestgrid:idp-test.auckland.ac.nz">
 <!-- <NameID nameMapping="shm"/>  --> 
  <NameID nameMapping="hashib_mapping" /> 
</RelyingParty>

```

**Update *ArtifactMapper** element

``` 

<ArtifactMapper implementation="edu.georgetown.middleware.shibboleth.idp.ha.artifact.ReplicatedArtifactMapper" /> 

```

- update cache-config.xml (usually at /usr/local/shibboleth-idp/etc/hashib)

**Update the *classpath** with the correct jar name

``` 

 <classpath codebase="./lib" archives="JBossCache-1.3.SP3-jboss-cache.jar, JBossCache-1.3.SP3-jgroups.jar"/>

```

- Please have look [https://www.middleware.georgetown.edu/confluence/display/MW/usage](https://www.middleware.georgetown.edu/confluence/display/MW/usage) for full details HA-Shib configuration.

# Configure Apache HTTPD

- Create a configuration file (e.g. shib-idp.conf) in /etc/httpd/conf.d

- An example attached below:

``` 

Listen 8443

<VirtualHost _default_:8443>
    SSLEngine on
    SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP
    SSLVerifyClient optional_no_ca
    SSLVerifyDepth 10
    SSLOptions +StdEnvVars +ExportCertData
    #SSLCertificateFile /etc/httpd/conf/ssl.crt/idp-test.auckland.ac.nz_bestgrid-CA.crt
    SSLCertificateFile /etc/httpd/conf/ssl.crt/idp-test.auckland.ac.nz_AAF-CA.crt
    SSLCertificateKeyFile /etc/httpd/conf/ssl.key/idp-test.auckland.ac.nz.key
    ErrorLog "|/usr/sbin/rotatelogs /var/log/httpd/ssl_error_idp-test_log.%Y%m%d 86400 720"
    TransferLog "|/usr/sbin/rotatelogs /var/log/httpd/ssl_access_idp-test_log.%Y%m%d 86400 720"

</VirtualHost>

Listen 444

<VirtualHost _default_:444>
    ServerName idp-test.auckland.ac.nz:443
    SSLEngine on
    SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP
    SSLVerifyClient optional_no_ca
    SSLVerifyDepth 10
    SSLOptions +StdEnvVars +ExportCertData
    #SSLCertificateFile /etc/httpd/conf/ssl.crt/idp-test.auckland.ac.nz_bestgrid-CA.crt
    SSLCertificateFile /etc/httpd/conf/ssl.crt/idp-test.auckland.ac.nz_AAF-CA.crt
    SSLCertificateKeyFile /etc/httpd/conf/ssl.key/idp-test.auckland.ac.nz.key
    ErrorLog "|/usr/sbin/rotatelogs /var/log/httpd/ssl_error_idp-test2_log.%Y%m%d 86400 720"
    TransferLog "|/usr/sbin/rotatelogs /var/log/httpd/ssl_access_idp-test2_log.%Y%m%d 86400 720"
</VirtualHost>

#
# Setup the UniSign SSO protection of the Shibboleth SSO authentication handler
#
LoadModule cosign_module modules/mod_cosign.so
# UniSign DEV
CosignHostname  webauth-tst-server2.enarc.auckland.ac.nz
CosignPort  6664
CosignRedirect  https://unisign-test.auckland.ac.nz/cosign.cgi
CosignPostErrorRedirect https://unisign-test.auckland.ac.nz/post_error.html
CosignFilterDB  /var/unisign/filter
CosignCrypto    /etc/httpd/conf/ssl.key/server.key /etc/httpd/conf/ssl.crt/server.crt /var/unisign/certs/CA/
CosignService   shibIdPDev
CosignProtected off


<Location /shibboleth-idp/SSO>
        CosignProtected on
</Location>

```

(**NOTE**: In general configuration we should configure Apache to listen port **443** instead of **444**. However since both UoA unisign and IdP are installed in a same server (cerberus1.auckland.ac.nz), it has to do some modifications. In this case, we've to setup a redirection for idp.auckland.ac.nz:443 (or idp-test.auckland.ac.nz for test environment), i.e. all packages that go to idp.auckland.ac.nz:443 will be redirect to cerberus1.auckland.ac.nz:444)

# Configure Tomcat

- Update $TOMCAT_HOME/conf/server.xml as following:
- Turn off Tomcat authentication


![TomcaAuthenticationOff.PNG](./attachments/TomcaAuthenticationOff.PNG)
- Configure port 8009 only to listen the traffic from localhost by adding **address="127.0.0.1"** in port 8009 connector

- Remove port 8080 connector

# Firewall Rules

# How to take part in AAF
