# Installing uApprove on a Shibboleth 2.1 IdP at University of Canterbury

This page documents installation of [uApprove](http://www.switch.ch/aai/support/tools/uApprove.html), a tool for users' approval of attribute release, on top of a Shibboleth 2.1 IdP at the University of Canterbury.

Overall, this tool works very well - even though:

- uApprove does not provide all the functionality Autograph had for Shibboleth 1.3, and users can't select attributes to be released - they can only confirm the release of pre-configured attributes to a particular Service Provider, or they can decide not to access the service.
- uApprove 2.1.2 I started with had two serious bugs I had to fix myself (see below for details).  After fixing these bugs, it works all fine.

The installation follows the original uApprove installation manual at [https://www.switch.ch/proxy/aai/downloads/uApprove-2.1.2-manual.html](https://www.switch.ch/proxy/aai/downloads/uApprove-2.1.2-manual.html).

This page documents how I walked through the installation manual and highlights critical points - and where I did things differently.

# Preliminary assumptions

- Shibboleth 2.1 installed and configured.
	
- Shibboleth home directory is `/usr/local/shibboleth-idp`
- Tomcat webapps directory is `/var/lib/tomcat5/webapps`
- Shibboleth IdP web application is installed (and exploded) in `/var/lib/tomcat5/webapps`
- uApprove configuration files will be installed in `/etc/shibboleth-idp2/uApprove`
- uApprove will store the release information in a MySQL database.

# Download & unpack

- Get and unpack uApprove binary distribution


>  mkdir /root/inst
>  cd /root/inst
>  wget [http://www.switch.ch/aai/downloads/uApprove-2.1.2-bin.zip](http://www.switch.ch/aai/downloads/uApprove-2.1.2-bin.zip)
>  unzip uApprove-2.1.2-bin.zip
>  mkdir /root/inst
>  cd /root/inst
>  wget [http://www.switch.ch/aai/downloads/uApprove-2.1.2-bin.zip](http://www.switch.ch/aai/downloads/uApprove-2.1.2-bin.zip)
>  unzip uApprove-2.1.2-bin.zip

- Unpack two zip files inside the unpacked distribution


>  cd uApprove-2.1.2
>  unzip idp-plugin-2.1.2-bin.zip
>  unzip viewer-2.1.2-bin.zip
>  cd uApprove-2.1.2
>  unzip idp-plugin-2.1.2-bin.zip
>  unzip viewer-2.1.2-bin.zip

- Create and populate configuration directory


>  mkdir -p /etc/shibboleth-idp2/uApprove
>  cp idp-plugin-2.1.2/conf-template/* /etc/shibboleth-idp2/uApprove
>  mkdir -p /etc/shibboleth-idp2/uApprove
>  cp idp-plugin-2.1.2/conf-template/* /etc/shibboleth-idp2/uApprove

- Install the IdP plugin into the exploded IdP WAR - and also into IdP's lib directory.


>  cp idp-plugin-2.1.2/lib/* /var/lib/tomcat5/webapps/idp/WEB-INF/lib
>  cp idp-plugin-2.1.2/lib/* /usr/local/shibboleth-idp/lib
>  cp idp-plugin-2.1.2/lib/* /var/lib/tomcat5/webapps/idp/WEB-INF/lib
>  cp idp-plugin-2.1.2/lib/* /usr/local/shibboleth-idp/lib


>  cp -r viewer-2.1.2/webapp /var/lib/tomcat5/webapps/uApprove
>  cp -r viewer-2.1.2/webapp /var/lib/tomcat5/webapps/uApprove

# Database

- Install and start MySQL server


>  yum install mysql mysql-server
>  service mysqld start
>  chkconfig mysqld on
>  yum install mysql mysql-server
>  service mysqld start
>  chkconfig mysqld on

- Set MySQL root password


>  /usr/bin/mysqladmin -u root -h ucidp.canterbury.ac.nz password secret-password
>  /usr/bin/mysqladmin -u root password secret-password
>  /usr/bin/mysqladmin -u root -h ucidp.canterbury.ac.nz password secret-password
>  /usr/bin/mysqladmin -u root password secret-password

- Create database, grant permissions to local account `uApprove` and pick a password for the account.
	
- Run `mysql -u root -p`, login with the password set for the MySQL root account, and run the database creation scripts listed in the [uApprove installation manual, database configuration section](https://www.switch.ch/proxy/aai/downloads/uApprove-2.1.2-manual.html#configuration).

- Edit `/etc/shibboleth-idp2/uApprove/common.properties`:
	
- uncomment database setup, comment out flatfile setup
- change databaseConfig location to the correct path:

``` 
databaseConfig=/etc/shibboleth-idp2/uApprove/database.properties
```
- set the sharedSecret to a random string, at best generated with:

``` 
openssl rand -base64 18
```


# More configuration

- Edit `/etc/shibboleth-idp2/uApprove/attribute-list` and add extra local attributes:

``` 

commonName
displayName
eduPersonScopedAffiliation
eduPersonPrimaryAffiliation
eduPersonPrincipalName
auEduPersonSharedToken
locality
organizationName
ucStudentId
ucCourse
ucDeptCode

```

- Comment out termsOfUse in `/etc/shibboleth-idp2/uApprove/common.properties` - that will switch the TermsOfUseManager off and users will not get asked to agree to (empty) terms of use.

- Set URL to the uApprove web application `/etc/shibboleth-idp2/uApprove/idp-plugin.properties`


>  uApproveViewer=[https://idp.canterbury.ac.nz/uApprove/Controller](https://idp.canterbury.ac.nz/uApprove/Controller)
>  uApproveViewer=[https://idp.canterbury.ac.nz/uApprove/Controller](https://idp.canterbury.ac.nz/uApprove/Controller)

- Edit uApprove's web.xml, `/var/lib/tomcat5/webapps/uApprove/WEB-INF/web.xml` and set the path to configuration files:


>         /etc/shibboleth-idp2/uApprove/viewer.properties;
>         /etc/shibboleth-idp2/uApprove/common.properties;
>         /etc/shibboleth-idp2/uApprove/viewer.properties;
>         /etc/shibboleth-idp2/uApprove/common.properties;

- Edit `/etc/shibboleth-idp2/uApprove/viewer.properies` and:
	
- Configure path to attribute list:

``` 
attributeList=/etc/shibboleth-idp2/uApprove/attribute-list
```
- Leave global consent on

``` 
globalConsentPossible=true
```
- Set local to US_en

``` 
useLocale = US_en
```
- Set path to logging config to 

``` 
loggingConfig=/etc/shibboleth-idp2/uApprove/logging.xml
```

- In `/etc/shibboleth-idp2/uApprove/logging.xml`, configure logging to log into

``` 
/usr/local/shibboleth-idp/logs/uApprove.log
```

- Configure sp-blacklist.  The sp-blacklist (actually rather a whitelist) is a list of Service Provider (their entityIDs) where uApprove should never step in - and should assume user's consent.  I have used this for our local wiki (located within the institution, user information does not cross institutional boundaries) and for the SLCS server - where uApprove would break the flow through the automated tools.

- Configure the blacklist file location in `/etc/shibboleth-idp2/uApprove/idp-plugin.properties`:


>  spBlacklist = /etc/shibboleth-idp2/uApprove/sp-blacklist
>  spBlacklist = /etc/shibboleth-idp2/uApprove/sp-blacklist

- Add the entityIds of the pre-agreed SPs into the list. For now,

``` 

urn:mace:federation.org.au:testfed:wikitest.canterbury.ac.nz
urn:mace:federation.org.au:testfed:wiki.canterbury.ac.nz
https://slcs1.arcs.org.au/shibboleth

```

- Optional: leaving out configuration of the *Reset-approvals* web application.

# Turn uApprove on

- Edit `/etc/httpd/conf.d/idp.conf` and add an extra ProxyPass directive for the uApprove web application:


>  ProxyPass /uApprove ajp://localhost:8009/uApprove retry=5
>  ProxyPass /uApprove ajp://localhost:8009/uApprove retry=5

- Edit `/var/lib/tomcat5/webapps/idp/WEB-INF/web.xml` and add the filter and mapping for uApprove as documented in the [uApprove installation manual, IdP Plugin Configuration section](https://www.switch.ch/proxy/aai/downloads/uApprove-2.1.2-manual.html#configuration)

``` 

  <filter>
    <filter-name>uApprove IdP plugin</filter-name>
    <filter-class>ch.SWITCH.aai.uApprove.idpplugin.Plugin</filter-class>
    <init-param>
      <param-name>Config</param-name>
      <param-value>
        /etc/shibboleth-idp2/uApprove/idp-plugin.properties;
        /etc/shibboleth-idp2/uApprove/common.properties;
      </param-value>
    </init-param>
  </filter>

  <filter-mapping>
    <filter-name>uApprove IdP plugin</filter-name>
    <url-pattern>/profile/*</url-pattern>
    <dispatcher>REQUEST</dispatcher>
    <dispatcher>FORWARD</dispatcher>
  </filter-mapping>

```

- Put all changes into effect:


>  service tomcat5 restart
>  service tomcat5 restart

# Branding and Local Customization

To put a corporate banner at the top of the uApprove page, store the banner in `/var/lib/tomcat5/webapps/uApprove/images` and make the following or similar changes to `/var/lib/tomcat5/webapps/uApprove/header.jsp`

``` 

--- header.jsp.dist     2009-06-03 12:49:06.000000000 +1200
+++ header.jsp  2009-06-04 10:54:36.000000000 +1200
@@ -10,7 +10,11 @@
 
 
 <body class="switchaai">
+<div id="UoCBanner" style="background-color: #c1e9ff;">
+<img src="images/UoC-attributes.jpg" alt="University of Canterbury Attribute Policy Viewer" class="UocLogo" height="120" width="948"> 
+</div>
+<p>
 <div class="box-aai" style="width: 650px;">
-  <img src="images/switch-aai.gif" alt="switch-aai-logo" class="switchaai" height="16" width="139"> 
-  <br>
+<!--
   <span class="switchaai"><a href="http://www.switch.ch/aai/about/" class="switchaai">About AAI</a>&nbsp;:&nbsp;<a href="http://www.switch.ch/aai/faq/" class="switchaai">FAQ</a>&nbsp;:&nbsp;<a href="http://www.switch.ch/aai/help/" class="switchaai">Help</a>&nbsp;:&nbsp;<a href="http://www.switch.ch/aai/privacy/" class="switchaai">Privacy</a></span>
+-->

```

- Make some clarifications to the text in `/var/lib/tomcat5/webapps/uApprove/WEB-INF/classes/attributes_en.properties`

``` 

--- attributes_en.properties.dist       2009-06-03 12:49:06.000000000 +1200
+++ attributes_en.properties    2009-06-05 11:11:02.000000000 +1200
@@ -5,9 +5,9 @@
 title = <br>
 
-txt_explanation =  This is the Digital ID Card to be sent to '?':
+txt_explanation = To use '?' their system needs to receive some information about you in the form of a Digital ID Card.  You will need to agree to send the following infor
mation to access their services.  All this information is needed or service will not be granted.
 
 txt_cross_boxes = <br>
 
-txt_agree_global_arp = Don't show me this page again. I agree that my Digital ID Card (possibly including more data than shown above) will be sent automatically in the fut
ure.
+txt_agree_global_arp = Don't show me this page again. I agree that my Digital ID Card (possibly including more data than shown above) will be sent automatically in the fut
ure to this site as well as to other services I will access.
 
 

```

- Restart Tomcat again to reload the modified properties file.


>  service tomcat5 restart
>  service tomcat5 restart

# Bug fixes

I have found two critical bugs and one cosmetic issues.  See the description below.  Download the patches against the uApprove 2.1.2 source code and the modified Plugin.class and Controller.class from [UApprove-2.1.2-patch.zip](/wiki/download/attachments/3818228675/UApprove-2.1.2-patch.zip?version=1&modificationDate=1539354236000&cacheVersion=1&api=v2).

- Inject updated Plugin.class into


>  /var/lib/tomcat5/webapps/idp/WEB-INF/classes/ch/SWITCH/aai/uApprove/idpplugin
>  /var/lib/tomcat5/webapps/idp/WEB-INF/classes/ch/SWITCH/aai/uApprove/idpplugin

- and Controller.class into


>  /var/lib/tomcat5/webapps/uApprove/WEB-INF/classes/ch/SWITCH/aai/uApprove/viewer
>  /var/lib/tomcat5/webapps/uApprove/WEB-INF/classes/ch/SWITCH/aai/uApprove/viewer

## Problem 1: global consent

uApprove wrongly records global consent for new users when visiting hosts on the sp-blacklist as the first host they ever visit.

When a new user is visiting the IdP for the fist time ever, and is logging in to a host on the sp-blacklist (and thus not intercepted by the uApprove viewer application at all), the uApprove IdP Plugin creates a record the user, and wrongly records as if the user gave the global consent.

In this scenario, users are created by calls to storage.addUserLogInfoData() from Plugin.continue2IdP() - and not from the viewer application.

The call to storage.addUserLogInfoData() in continue2IdP() was passing "yes" as the global consent given parameter - and this is clearly wrong, it should have been "no".

I have fixed that and I am also passing providerId - though that has no effect, the addUserLogInfoData() would accept the providerId only if it also receives the list of attributes released - which is not available inside the continue2IdP() method.  It would be possible to refactor the continue2IdP method to accept the list of attributes - but I have not done that.

This fix is in the attached: Plugin-java-fix-global-consent.diff

## Problem 2: Sticking LoginContext

When a user gets redirected to the uApprove viewer while logging in to SP1, the LoginContext sticks in the current session, and when the user later connects to SP2, the sticking context causes the user to be redirected to SP1.

I have fixed this for myself by ignoring the LoginContext stored in the http session IF there is a query string specified for the request (which is clear to identify a new login to a new SP).

This is fixed in the attached patch: Plugin-java-fix-login-context.diff

## Problem 3: hostname from entityId

This is just a cosmetic issue.  For URN-based entityIDs, Controller.getResourceHost() was not extracting the hostname out of the entityId, but returning it in full.

I have modified the method so that for both 

- `*``[https://sp.example.org/shibboleth*](https://sp.example.org/shibboleth*)`
- and `urn:mace:federation.org:sp.example.org`
- it returns `"sp.example.org"`

This fix is in Controller-java-fix-getResourceHost.diff

# Examples

