# Installing and Configuring May 2009 version of Autograph and ShARPE

This page contains installation notes on the recent version (April/May 2009) of Autograph and ShARPE.  The notes are more just a personal archive - but other are welcome to make use of them.

# Autograph

## Installing Autograph

Following [MAMS AutographInstall page](http://www.federation.org.au/twiki/bin/view/Federation/AutographInstall) and installing [Autograph-1.0-Beta-2](http://www.mams.org.au/downloads/Autograph-1.0-Beta-2.tgz).

The notes are fairly detailed and not much extra effort was needed - except for the following:

- In Step 2: (copying jars into shibboleth-idp/WEB-INF/lib), it's not clear where to get the jars from.The correct answer is that mams-idp-ext.jar is in $TOMCAT_HOME/webapps/Autograph/WEB-INF/lib - while Autograph.sso is in the downloaded tarball.
- Step 5: configuring Autograph/WEB-INF/web.xml: Wiki formatting has discarded the tags that should be removed from TOMCAT_HOME/webapps/Autograph/WEB-INF/web.xml, the text is rendered just as `"This file also contains the tags and , required..."`.

The tags to be removed are `security-contraint` as discussed in step 1.

- Step 6: customizing AutographConfiguration.properties.  The default AutographConfiguration.properties says:

``` 
attributeInfoPointDataFile = WEB-INF/homeDir/connectorConfigs/AttributeInfoPointData.xml
```

But there's no AttributeInfoPointData.xml file included in the whole

Autograph web application.

Correct answer: this file is no longer used and should not be specified in the configuration file.  The equivalent information is now stored in `/usr/local/shibboleth-idp/etc/mams-sharpe/attribute_info.xml`

## Reported bugs

- When testing the user experience with Autograph, I found:

The text "More information about this service is available from the Service Provider." links to the Artifact consumer service URL - in this

particular case, [https://confluencewiki.canterbury.ac.nz/Shibboleth.sso/SAML/Artifact](https://confluencewiki.canterbury.ac.nz/Shibboleth.sso/SAML/Artifact)

This particular SP has a proper Service URL registered in the metadata, [http://confluencewiki.canterbury.ac.nz/](http://confluencewiki.canterbury.ac.nz/) - but Autograph is linking to the Artifact consumer service....

- Performance issue: while the performance has greatly improved for normal operation (when Autograph intrecepts a shibboleth login), when I go to the management interface (/Autograph/Login_AAF), there is a very noticeable delay (>5s) on each page load between loading the list of SPs and loading the detailed view.  The delay repeats on every user action .... looks painfully slow.  (Testing on the level-1 federation metadata, which is quite bloated .... but it still should not be a scaling issue)

- When I include multiple metadata files in my idp.xml (like for the level-1 and level-2) federation, Autograph picks up only the last one, and for

hosts defined in other metadata files displays:

``` 

Autograph Error Page

Autograph has encountered an error !!

Error Message : Unable to find service provider for urn:mace:federation.org.au:testfed:www.e-cast.co.nz

Resolution : Contact your Identity Provider system administrator - possible Autograph configuration problems

```

- When connecting to a SP with no service offerings: In the Detailed View, I correctly get the message:

``` 

"This Service Provider has no advertised Service Offerings."

```

while in the Simple View, I get the message:

``` 

"This Service Provider has no enabled Service Offerings."

```

Which is technically also true - but I think the message displayed should be the same as the one displayed in the Detailed View.

## New features requested

- Would it be possible to configure invididual hosts where Autograph should not ask any user for attribute release?  I.e., for a given SP, behave as if displayAutographSSO was set to "never"

- By default, Autograph starts in the simple view mode - and does not list the service offerings, even when none is enabled and the Go to SP button is disabled. That's something that may get users confused .... and it would be simpler to use if in that case, Autograph started in the detailed view.

## Customizing Autograph

- Logo in retrieved from [https://idp-test.canterbury.ac.nz/Autograph/aut-view/images/bars.gif](https://idp-test.canterbury.ac.nz/Autograph/aut-view/images/bars.gif) and is stored in `/var/lib/tomcat5/webapps/Autograph/aut-view/images`

- Logo can be customized/replaced in `/var/lib/tomcat5/webapps/Autograph/aut-view/includes/CorpHeader.jsp`
	
- When adding UoC logo there, also change `styles/corporateHeaderColors.css` to height of 170px

- Doing this for real:
	
- upload the following files into `/var/lib/tomcat5/webapps/Autograph/aut-view/images`: `autograph_banner.jpg autograph_hd.gif titlebar_bg.gif`

``` 

<div class="banner">
        <div style="background-color: #c1e9ff;">
                <img src="/Autograph/aut-view/images/autograph_banner.jpg" 
                     alt="University of Canterbury" />
        </div>
        <div style="background-image: url('/Autograph/aut-view/images/titlebar_bg.gif'); background-repeat: repeat-x;">
                <img src="/Autograph/aut-view/images/autograph_hd.gif" 
                     alt="Autograph" />
        </div>
</div>

```

>  **Plans to change the text **`"Personal details released:"`** to **`"Details released to:*SP``"`

- 
- URL `/Autograph/ConfigureCardAction_SSO` is handled by servlet `au.edu.mq.melcoe.mams.autograph.web.ConfigureCardAction_SSO`
- Edit `CardConfig_CardDetails.jsp` and `CardDisplay_CardDetails.jsp`

## Customizing an older version of Autograph

- Customizing the older version of Autograph installed on idp.canterbury.ac.nz (tarball name autograph-orig-beta-05.tgz, dated Aug 19, 2008)
- Logo in stored in `/var/lib/tomcat5/webapps/Autograph/view/images/mq.gif` and is included from `/var/lib/tomcat5/webapps/Autograph/view/header.inc.jsp`

- Doing this for real:
- upload the following files into `/var/lib/tomcat5/webapps/Autograph/view/images`: `autograph_banner.jpg autograph_hd.gif titlebar_bg.gif`

- Change header.inc.jsp: use the following html snippet:

``` 

<div id="Header">
        <div style="background-color: #c1e9ff;">
                <img src="/Autograph/view/images/autograph_banner.jpg" 
                     alt="University of Canterbury" 
                     style = "margin: 0px;" />
        </div>
        <div style="background-image: url('/Autograph/view/images/titlebar_bg.gif'); background-repeat: repeat-x;">
                <img src="/Autograph/view/images/autograph_hd.gif" 
                     alt="Autograph" 
                     style = "margin: 0px;" />
        </div>
</div>

```

- change styles.css:
	
- change absolute position of #Navbar (the blue bar) to 174px
- cosmetics: comment out `padding: .5em;"` from `#main:`
- fix a few syntax errors.

### New feature: block on no SO

Minor modification to the JSPs to implement a feature that block the Go to Service Provider button when ℹ at least one Service Offering is defined and (ii) none of them is enabled - not enough attributes released.

- `WEB-INF/web.xml`: new context parameter:

``` 

    <context-param>
        <param-name>BlockOnSOsDefinedNoneEnabled</param-name>
        <param-value>true</param-value>
    </context-param>

```

idCard.inc.jsp: define:

``` 

      boolean BlockOnSOsDefinedNoneEnabled  = Boolean.parseBoolean(servletContext.getInitParameter("BlockOnSOsDefinedNoneEnabled"));
      boolean SOsDefined = selectedServiceProvider.getServiceLevels().size() != 0;

```

and make use of them (twice):

``` 

-                       if (!Access && BlockOnNoService) {
-                               out.println("<input disabled=\"true\" type=\"submit\" value=\"Go to this Service Provider\"/></p>");
+                       if (!Access && SOsDefined && BlockOnSOsDefinedNoneEnabled) {
+                               out.println("<input disabled=\"true\" type=\"submit\" value=\"Go to " + selectedServiceProvider.getServiceProviderName() + "\"/></p>");
                        } else {
-                               out.println("<input type=\"submit\" value=\"Go to this Service Provider\"/></p>");
+                               out.println("<input type=\"submit\" value=\"Go to " + selectedServiceProvider.getServiceProviderName() + "\"/></p>");
                        }

```

Note: this last bit also changes the text on the `Go to SP` button to include the name of the service provider.

# ShARPE

## Installing ShARPE

Following [ShARPE](https://www.mams.org.au/confluence/display/SHA/ShARPE) [Installation guide](https://www.mams.org.au/confluence/display/SHA/Installation)

Fixes to the procedure:

- change build.xml to pull in catalina-ant.jar from /var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar

``` 

#diff build.xml.dist build.xml 
30,37c30,37
< 	<taskdef name="deploy" classname="org.apache.catalina.ant.DeployTask" />
< 	<taskdef name="list" classname="org.apache.catalina.ant.ListTask" />
< 	<taskdef name="reload" classname="org.apache.catalina.ant.ReloadTask" />
< 	<taskdef name="resources" classname="org.apache.catalina.ant.ResourcesTask" />
< 	<taskdef name="roles" classname="org.apache.catalina.ant.RolesTask" />
< 	<taskdef name="start" classname="org.apache.catalina.ant.StartTask" />
< 	<taskdef name="stop" classname="org.apache.catalina.ant.StopTask" />
< 	<taskdef name="undeploy" classname="org.apache.catalina.ant.UndeployTask" />
---
> 	<taskdef name="deploy" classname="org.apache.catalina.ant.DeployTask" classpath="/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar" />
> 	<taskdef name="list" classname="org.apache.catalina.ant.ListTask" classpath="/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar" />
> 	<taskdef name="reload" classname="org.apache.catalina.ant.ReloadTask" classpath="/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar" />
> 	<taskdef name="resources" classname="org.apache.catalina.ant.ResourcesTask" classpath="/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar" />
> 	<taskdef name="roles" classname="org.apache.catalina.ant.RolesTask" classpath="/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar" />
> 	<taskdef name="start" classname="org.apache.catalina.ant.StartTask" classpath="/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar" />
> 	<taskdef name="stop" classname="org.apache.catalina.ant.StopTask" classpath="/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar" />
> 	<taskdef name="undeploy" classname="org.apache.catalina.ant.UndeployTask" classpath="/var/lib/tomcat5/webapps/Autograph/WEB-INF/lib/catalina-ant.jar" />

```

- jar clash resolution: use ShARPE jars to override IdP's ones + mams-idp-ext.jar installed with Autograph

- changing IdPResponder class name: packagename stays the same, so we are changing from edu.internet2.middleware.shibboleth.idp.IdPResponder to edu.internet2.middleware.shibboleth.idp.MAMSIdPResponder

- Step 4: does not say where to get sample.grouplookup.properties (it's in conf/)

- in mams-sharpe-folder: use attribute_info.xml from Autograph, not ShARPE (ShARPE has typos like "bysinessCategory"

- copying bsh-2.0b4.jar from /var/lib/tomcat5/webapps/shibboleth-idp/WEB-INF/lib/bsh-2.0b4.jar into /var/lib/tomcat5/webapps/ShARPE/WEB-INF/lib

- increasing the memory settings for tomcat in `/etc/sysconfig/tomcat5`:

``` 
JAVA_OPTS="-Xms256m -Xmx768m"
```

## Post-install configuration

- Settings: Mail Settings:
	
- SMTP Server: smtphost.canterbury.ac.nz
- Sender: no-reply@bitbucket.canterbury.ac.nz
- Recipient: vladimir.mencl@canterbury.ac.nz

- Change password: edit ShARPE's web.xml and enter what you get with:

``` 
ant generate-admin-password
```
