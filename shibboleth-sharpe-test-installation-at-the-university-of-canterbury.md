# Shibboleth ShARPE Test Installation at the University of Canterbury

ShARPE is installed on top of the [identity provider test installation](shibboleth-idp-test-installation-at-the-university-of-canterbury.md).

It is installed according to the [MAMS ShARPE install instructions](http://www.federation.org.au/twiki/bin/view/Federation/ShARPEInstall).

# Compile and Install

Backup `/usr/local/shibboleth-idp` as `/usr/local/shibboleth-idp-backup-2007-05-25`

Following the guide:

>  **changing **`javac`** source code level from 1.4 to 1.5 in **`/root/work/shibboleth-1.3.2-install/build.xml`** and **`/root/work/shibboleth-1.3.2-install/custom/extension-build.xml`** (backing up these files as **`"``-backup-2007-05-25"`).


- Add the following JkMounts to `/etc/httpd/conf.d/proxy_ajp.conf`

``` 

ProxyPass /ShARPE ajp://localhost:8009/ShARPE
ProxyPass /Autograph ajp://localhost:8009/Autograph
ProxyPass /SPDescription ajp://localhost:8009/SPDescription

```

- Protect ShARPE: in `/etc/httpd/conf.d/shib-vhosts.conf`, copy 

``` 
<Location /shibboleth-idp/SSO>
```

 to protect also `/ShARPE` and `/Autograph`
	
- Alternatively, this could be done also for other vhosts ... or the location could be mounted only for :443 virtual hosts
- Edit `/usr/local/shibboleth-idp/etc/idp.xml` and replace the `ReleasePolicyEngine` with the ShARPE-specific one.

- ShARPE, Autograph and SPDescription should now be available at
	
- [https://idp-test.canterbury.ac.nz/ShARPE](https://idp-test.canterbury.ac.nz/ShARPE)
- [https://idp-test.canterbury.ac.nz/Autograph](https://idp-test.canterbury.ac.nz/Autograph)
- [https://idp-test.canterbury.ac.nz/SPDescription](https://idp-test.canterbury.ac.nz/SPDescription)

# Installing Autograph

Autograph still needs a few additional steps, described in the MAMS page on [installing Autograph](http://www.federation.org.au/twiki/bin/view/Federation/AutographInstallation).

- Modified `Autograph.war` to fix the typo in legal agreement message each user would get on their first visit.  The mis-spelled message might make some users doubt whether this is a legitimate service:

``` 
Do you agree that your Identity Provider releaeases personal attributes to Service Providers in the Federation?
```

.  The modification was easy to do, it was enough to edit the textual file `view/legalAgreement.inc.jsp` inside `Autograph.war`.
- Deployed `Autograph.war` into `/var/lib/tomcat5/webapps`
- I'm not sure how to change the value of the AUTOGRAPH_HOME property when the property is defined in a file in the Autograph homeDir
- I did not have to change any value in `IAMConfiguration.xml` - everything has matched my (default) environment.
- The default attribute list in `AttributeInfoPointData.xml` looks OK, no change done.


>  ***Important**: when setting up Autograph with the redirection switch, it is important to also edit `/usr/local/shibboleth-idp/etc/idp.xml` and change the SSO Protocol Handler registration from `/SSO` to `/IdP`.  Change according to the following patch:

``` 

--- idp.xml.orig      2007-09-25 16:35:04.000000000 +1200
+++ idp.xml     2007-09-28 16:32:29.000000000 +1200
@@ -101,3 +101,3 @@
        <ProtocolHandler implementation="edu.internet2.middleware.shibboleth.idp.provider.ShibbolethV1SSOHandler">
-               <Location>https?://[^:/]+(:(443|80))?/shibboleth-idp/SSO</Location> <!-- regex works when using default protocol ports -->
+               <Location>https?://[^:/]+(:(443|80))?/shibboleth-idp/IdP</Location> <!-- regex works when using default protocol ports -->
        </ProtocolHandler>

```

# Installing eduPersonTargetedID

Following [http://www.federation.org.au/twiki/bin/view/Federation/ShARPEEPTID](http://www.federation.org.au/twiki/bin/view/Federation/ShARPEEPTID) ...

- Skip ARP editing - will be done with ShARPe.
- Define the attribute in resolver-ldap.xml



- I had to solve the problem with crosswalk configuration file not being found (and other problems, see below)
- To make EPTID available in Autograph, I've added the following to `/var/lib/tomcat5/webapps/Autograph/WEB-INF/homeDir/connectorConfigs/AttributeInfoPointData.xml` (now located in `/var/lib/autographHomeDir/connectorConfigs/AttributeInfoPointData.xml`)


>       eduPersonTargetedID
>       no description
>       eduPersonTargetedID
>       no description

- I have also relocated autograph home directory into a different directory (`/var/lib/autographHomeDir/`), see below.

## Problem: locating crosswalk configuration properties

After defining an attribute using crosswalk (such as EPTID), the Attribute Resolver system would crash each time this attribute was about to be retrieved, with the message

>  java.io.IOException: Fail to get requested file:/conf/crosswalkconfig.properties

This was because the file `/conf/crosswalkconfig.properties` was not available via a file-based URL.  This problem happens both with the IdP and Autograph web applications, and with the resolvertest command-line application.  The exact causes and remedies are slightly different for each of these.

The configuration file is loaded via the `ShibResource.getFile()` method, and this method tries to get the resource via a classloader.  If the file is found by a classloader, but inside a jar file, at a later time, conversion of an URI to a File fails (the URL has the form `jar:file:/home/mencl/wrk/java/testuri/mams-core-crosswalk.jar\!/conf/crosswalkconfig.properties`), with the message 

>  IllegalArgumentException: URI is not hierarchical

Thus, the crosswalk engine can only initialize if the file `/conf/crosswalkconfig.properties` is found in the classpath, and the first hit found is in a *file* URL.

My solution was to create `/var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/classes/conf/crosswalkconfig.properties` by expanding the env variables in `/var/lib/tomcat5/webapps/shibboleth-idp/ShARPE/WEB-INF/classes/conf/crosswalkconfig.properties` - the expand content of the file is:

``` 

CrosswalkListFile=/usr/local/shibboleth-idp/etc/mams-core-crosswalk/crosswalk.properties
CrosswalkPath=/usr/local/shibboleth-idp/etc/mams-core-crosswalk/mapper/
#CrosswalkListFile=$IDP_HOME$/etc/$EXTENSION_NAME$/crosswalk.properties
#CrosswalkPath=$IDP_HOME$/etc/$EXTENSION_NAME$/mapper/

```

To have Crosswalk functioning in all the web applications installed (shibboleth-idp, ShARPE, Autograph), I have copied this file into all the following locaitons:

- `/var/lib/tomcat5/webapps/Autograph/WEB-INF/classes/conf/crosswalkconfig.properties`
- `/var/lib/tomcat5/webapps/ShARPE/WEB-INF/classes/conf/crosswalkconfig.properties`
- `/var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/classes/conf/crosswalkconfig.properties`

For the command-line application resolvertest, an additional step was needed:

- the shell-script executable `$SHIB_HOME/bin/resolvertest` had to be modified to prepend (instead of appending) the custom-specified CLASSPATH additions:

``` 

--- /usr/local/shibboleth-idp/bin/resolvertest  2005-10-12 08:16:17.000000000 +1300
+++ /root/bin/resolvertest-appendcp     2007-10-29 15:42:00.000000000 +1300
@@ -45,7 +45,7 @@
       if [ -z "$SHIB_UTIL_CLASSPATH" ] ; then
         SHIB_UTIL_CLASSPATH=$i
       else
-        SHIB_UTIL_CLASSPATH="$i":$SHIB_UTIL_CLASSPATH
+        SHIB_UTIL_CLASSPATH=$SHIB_UTIL_CLASSPATH:"$i"
       fi
     fi
 done

```
- the script has to be invoked with an additional CLASSPATH entry pointing to the deployed (exploded) Shibboleth IdP:

``` 

  IDP_HOME=$SHIB_HOME CLASSPATH=/var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/classes/ \
  /root/bin/resolvertest-appendcp --idpXml=file://$SHIB_HOME/etc/idp.xml --user=staff --requester=urn:mace:federation.org.au:testfed:level-1:sp-dspace1.mams.org.au

```

## Problem: Autograph Exception: NoClassDefFoundError: org/apache/commons/codec/binary/Base64

After Autograph succeeded to initialize the Crosswalk Engine, it still could not calculate the EPTID attribute - it could not create the base64 representation of the hash value.  The respective classes used by ShARPE/Crosswalk were not bundled in the `Autograph.war` web application.

I was getting the following error in `catalina.out`:

>  java.lang.NoClassDefFoundError: org/apache/commons/codec/binary/Base64
>         at
>  au.edu.mq.melcoe.mams.sharpe.core.crosswalk.HashCrosswalkFunction$SHA1HashFunction.hash(HashCrosswalkFunction.java:227)

I had to copy /var/lib/tomcat5/webapps/ShARPE/WEB-INF/lib/commons-codec-1.3.jar into /var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/commons-codec-1.3.jar

## Problem: Service Provider not accepting eduPersonTargetedID

The default AAP.xml installed with Shibboleth Service Provider (`/usr/local/shibboleth-sp/etc/shibboleth/AAP.xml`) was listing `eduPersonTargetedID` as scoped (`Scoped="true"`), and the SP was then rejecting the (unscoped) value of the attribute.

I had to modify the `AAP.xml` file, removing the `Scoped="true"` snippet in the eduPersonTargetedID attribute definition.  Thus, the definition should be:

``` 

 <AttributeRule Name="urn:mace:dir:attribute-def:eduPersonTargetedID" Header="Shib-TargetedID" Alias="targeted_id">

```

# Relocating Autograph homeDir

The Autograph homeDir (where user preferences and ID cards are stored) would be removed each time Autograph (or ShARPE) is redeployed.  (This includes running ant in ShARPE source directory).  Therefore, I have configured Autograph to use a homeDir outside of its webapps sub-directory.

The following steps had to be done:

- move `/var/lib/tomcat5/webapps/Autograph/WEB-INF/homeDir` to `/var/lib/autographHomeDir`
- edit `/var/lib/tomcat5/webapps/Autograph/WEB-INF/web.xml` and change the context parameter `IAMConfigurationFileLocation` to `../../../autographHomeDir/IAMConfiguration.xml` (unfortunately, an absolute path does not work, as the value is always interpreted as relative interpreted w.r.t. to the web application's root directory.
- edit `/var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/web.xml` and change the `userProfileStorePath` context paramater to point to the new `userProfiles` directory - `/var/lib/autographHomeDir/userProfiles`

Note:  [MAMS' sample web.xml file](http://www.federation.org.au/IAMSuiteResources/Autograph/Shibboleth_Autograph_IdP_web.xml) uses /usr/local/shibboleth-autograph/userProfiles, I should have relocated the Autograph homedir to that location (and I'll do that next time, when setting up the real Universtiy of Canterbury IdP)

# Experimenting with file-connector

ShARPE comes with a file connector, able to obtain additional attributes for a user from files (with a variety of row-filtering and column-splitting options).  Sample configuration and a brief documentation are available in `/usr/local/shibboleth-idp/etc/mams-core-fileconnector/resolver.fileconnector.xml`

I have successfully merged additional attributes (eduPersonEntitlement) specified in a file with the collection of attributes obtained from an LDAP directory.  I only had to insert additional entries into `resolver.ldap.xml`, defining a new file-based connector and defining an attribute based on this connector:

(Note that I have commented out the original definition of the eduPersonEntitlement attribute, referring to the LDAP directory.)

To test this setting, I created a sample attribute file `/usr/local/shibboleth-attributes/entitlements/staff.dat` listing one entitlement value per line.  Each value listed there was passed as a value in the SAML attribute statement.
