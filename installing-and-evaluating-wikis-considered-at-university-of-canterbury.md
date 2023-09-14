# Installing and Evaluating Wikis considered at University of Canterbury

Install and evaluate: 

- TWiki
- xWiki
- Confluence

Evaluate:

- farming
- ldap integration
- CSS customization

... a selection of criteria from [http://librarywiki.canterbury.ac.nz/Wiki_Working_Group/Wiki_Working_Group_Report](http://librarywiki.canterbury.ac.nz/Wiki_Working_Group/Wiki_Working_Group_Report)

# TWiki

- Homepage: [http://twiki.org/](http://twiki.org/)
- Download: [http://twiki.org/cgi-bin/view/Codev/DownloadTWiki](http://twiki.org/cgi-bin/view/Codev/DownloadTWiki) (download release 4.2.1 zip, OS-specific installers available for older releases)
- Install instructions: [http://twiki.org/cgi-bin/view/TWiki04x02/TWikiInstallationGuide](http://twiki.org/cgi-bin/view/TWiki04x02/TWikiInstallationGuide)

## Installation notes

- Install Apache and PHP (needed for some configuration directives)


>  yum install httpd php
>  chkconfig httpd on
>  service httpd start
>  yum install httpd php
>  chkconfig httpd on
>  service httpd start

- Create `/usr/local/TWiki-4.2.1`, untar `TWiki-4.2.1.tgz` there, make it owned by the Apache user.


>  mkdir /usr/local/TWiki-4.2.1
>  cd /usr/local/TWiki-4.2.1
>  tar xzf /root/inst/TWiki-4.2.1.tgz -p
>  chown -R apache:apache .
>  mkdir /usr/local/TWiki-4.2.1
>  cd /usr/local/TWiki-4.2.1
>  tar xzf /root/inst/TWiki-4.2.1.tgz -p
>  chown -R apache:apache .



>  service httpd restart
>  service httpd restart

- Open TWiki web configuration interface: [http://twiki.canterbury.ac.nz/twiki/bin/configure](http://twiki.canterbury.ac.nz/twiki/bin/configure)

>  ***Note**: Had to disable access control to configure for the first run of configure.  The ErrorPage can depends on the LocalSite.cfg file created by configure - enable access control to configure only after the first run.

- Inside configure:
	
- General settings: Confirm hostname and paths.
- Set standard wiki password as configure password.
- Login Manager: Switch to Apache logins (will be used for LDAP).
- Uncheck `EnableNewUserRegistration` - we only want LDAP users
- Change `DisplayTimeValues` from `gmtime` to `servertime`
- Give my email address as WebMaster
- SMTP MAILHOST: smtphost.canterbury.ac.nz
- Restrict PATH to `/bin:/usr/bin`

## Post-install

- Disable running any server-side code (PHP, perl) in the /twiki/pub directory.
	
- Apparently done by the settings in the Directory element for the pub directory: turns PHP engine off, and switches file-type for most executables to text/plain.

- Establish automatic redirect to `/twiki/bin/view`: create `/etc/httpd/conf.d/rootredir.conf` with 

``` 
RedirectMatch ^/+$ /twiki/bin/view
```

- To improve performance, it might be worthwhile installing `mod_perl` and configuring TWiki to use it by creating a `/usr/local/TWiki-4.2.1/tools/mod_perl_startup.pl` script, as documented at the [ApacheConfigGenerator](http://twiki.org/cgi-bin/view/TWiki/ApacheConfigGenerator) page.

## LDAP

- Edit the [TWikiAdminGroup](http://twiki.canterbury.ac.nz/twiki/bin/view/Main/TWikiAdminGroup) page and make an LDAP usercode an administrator before switching to LDAP.

- Uncomment:

``` 

 <FilesMatch "(attach|edit|manage|rename|save|upload|mail|logon|rest|.*auth).*">
        require valid-user
 </FilesMatch>

```

- Comment out: `AuthUserFile`
- Enter LDAP configuration:


>         AuthName 'Enter your WikiName: (First name and last name, no space, no dots, capitalized, e.g. JohnSmith). Cancel to register if you do not have one.'
>         AuthType Basic
>         AuthBasicProvider ldap
>         AuthzLDAPAuthoritative OFF
>         AuthLDAPBindDN cn=reader,dc=canterbury,dc=ac,dc=nz
>         AuthLDAPBindPassword "PASSWORD"
>         AuthLDAPURL "ldap://ldap.canterbury.ac.nz:389/ou=useraccounts,dc=canterbury,dc=ac,dc=nz?uid?sub?(objectClass=*)"
>         AuthName 'Enter your WikiName: (First name and last name, no space, no dots, capitalized, e.g. JohnSmith). Cancel to register if you do not have one.'
>         AuthType Basic
>         AuthBasicProvider ldap
>         AuthzLDAPAuthoritative OFF
>         AuthLDAPBindDN cn=reader,dc=canterbury,dc=ac,dc=nz
>         AuthLDAPBindPassword "PASSWORD"
>         AuthLDAPURL "ldap://ldap.canterbury.ac.nz:389/ou=useraccounts,dc=canterbury,dc=ac,dc=nz?uid?sub?(objectClass=*)"

- Works all fine now

- Note: more proper LDAP integration, including support for LDAP groups could be done with the [LdapContrib plugin](http://twiki.org/cgi-bin/view/Plugins/LdapContrib).

## Skins and Customization

TWiki does support Skins:

- comes with a number of predefined [Skin packages](http://twiki.org/cgi-bin/view/Plugins/SkinPackage)
- allows to [create](http://twiki.org/cgi-bin/view/TWiki/TWikiSkins) and [customize](http://twiki.org/cgi-bin/view/TWiki.PatternSkinCustomization) skins.

However, installing and customizing skins might need local system access.

## Farming

Given that a lot of TWiki information is stored in plain directories, and that it's apache driven, the best (and only) way to do farming would be to have a number of virtual servers configured in Apache, and have a separate TWiki directory deployed for each wiki in the farm.  

The performance costs would not be really high (each TWiki action is anyway done in a separate perl script), storage space would also be moderate (plain TWiki installation takes only about 30 MB), and the administrative costs should be also acceptable (each would be basically maintained separately, but we should keep the configuration in sync).

# xWiki

- Homepage: [http://www.xwiki.org/xwiki/bin/view/Main/WebHome](http://www.xwiki.org/xwiki/bin/view/Main/WebHome)
- Download: [http://www.xwiki.org/xwiki/bin/view/Main/Download](http://www.xwiki.org/xwiki/bin/view/Main/Download) (generic installer r1.5)
- Install instructions [http://platform.xwiki.org/xwiki/bin/view/AdminGuide/Installation#HInstallingtheStandalonedistribution](http://platform.xwiki.org/xwiki/bin/view/AdminGuide/Installation#HInstallingtheStandalonedistribution)

## Installation


- Install XWiki

``` 
java -jar xwiki-enterprise-installer-generic-1.5.jar
```
- Installation path: `/usr/local/XWiki`

- Start and stop with:


>  /usr/local/XWiki/start_xwiki.sh
>  /usr/local/XWiki/stop_xwiki.sh
>  /usr/local/XWiki/start_xwiki.sh
>  /usr/local/XWiki/stop_xwiki.sh

## Post-configuration

>  **Change Admin password from Admin/admin to Admin/*same as confluence**


## LDAP

- Follow [http://platform.xwiki.org/xwiki/bin/view/AdminGuide/Authentication](http://platform.xwiki.org/xwiki/bin/view/AdminGuide/Authentication)
- Edit `/usr/local/XWiki/webapps/xwiki/WEB-INF/xwiki.cfg`

``` 

xwiki.authentication.ldap=1
xwiki.authentication.ldap.server=ldap.canterbury.ac.nz
xwiki.authentication.ldap.bind_DN=uid={0},ou=useraccounts,dc=canterbury,dc=ac,dc=nz
xwiki.authentication.ldap.base_DN=ou=useraccounts,dc=canterbury,dc=ac,dc=nz
xwiki.authentication.ldap.fields_mapping=last_name=sn,fullname=cn,email=mail,ldap_dn=dn
# omitted first_name=givenName

xwiki.authentication.ldap.UID_attr=uid

# leaving: xwiki.authentication.ldap.trylocal=1

```


- Hmm, changed UID_attr to UID - users will be called by their UIDs (maybe leave CNs)


- Let's instead try to connect to the LDAP server as the reader account, and validate user passwords externally:


>  xwiki.authentication.ldap.bind_DN=cn=reader,dc=canterbury,dc=ac,dc=nz
>  xwiki.authentication.ldap.bind_pass=PASSWORD
>  xwiki.authentication.ldap.validate_password=1
>  xwiki.authentication.ldap.password_field=userPassword
>  xwiki.authentication.ldap.bind_DN=cn=reader,dc=canterbury,dc=ac,dc=nz
>  xwiki.authentication.ldap.bind_pass=PASSWORD
>  xwiki.authentication.ldap.validate_password=1
>  xwiki.authentication.ldap.password_field=userPassword

Nope, this won't work: XWiki is asking the LDAP to do a "Compare" operation where it sends the password in cleartext - this clearly doesn't work.

But at least, when XWiki can bind to the LDAP, but does not find an admin account, I can log in as Admin again.

Last resort: let's try this with Active Directory:

>  xwiki.authentication.ldap.server=cantwd3.canterbury.ac.nz
>  xwiki.authentication.ldap.bind_DN=cn=ldap,cn=users,dc=canterbury,dc=ac,dc=nz
>  xwiki.authentication.ldap.bind_pass=OTHERPASSWORD
>  xwiki.authentication.ldap.base_DN=dc=canterbury,dc=ac,dc=nz
>  xwiki.authentication.ldap.UID_attr=cn

Hmmm, it looks like I can't get LDAP authentication working with XWiki:

- with authentication done via LDAP Bind with user's name, I cannot login as an Admin (Bind fails, then all fails)
	
- I can login as a user - but then I have no permissions.  I could only get permissions by mapping an LDAP group to a XWiki group, but I'm not a member of any LDAP group - so I cannot get any XWiki permissions.
- when authenticating via a generic account (reader/ldaplookup)
	
- admin login succeeds, because LDAP bind succeeds and LDAP reports "no such user" and LDAPImpl tries a local account
- user logins fail, because XWiki LDAPImpl tries to do an LDAP_compare on the userPassword field
		
- ActiveDirectory has no userPassword field
- ldap.canterbury stores Base64 of crypt(userpassword)
- other wikis use a second bind with user's credentials

Conclusion: with the support available in XWiki (permissions can only be granted to LDAP groups) and our LDAP configuration (no groups), I cannot get Xwiki to work with 

LDAP.

## Farming

According to the [xwiki scalability page](http://platform.xwiki.org/xwiki/bin/view/Features/ScalabilityPerformance), XWiki can host [virtual XWiki's](http://platform.xwiki.org/xwiki/bin/view/AdminGuide/Virtualization), which would be exactly what we need for a wiki farm.

## CSS Customization

XWiki should support CSS customization as [Skins](http://platform.xwiki.org/xwiki/bin/view/Features/Skins)

# Confluence

- Homepage: [http://www.atlassian.com/software/confluence/](http://www.atlassian.com/software/confluence/)
- Download: [http://www.atlassian.com/software/confluence/ConfluenceDownloadCenter.jspa](http://www.atlassian.com/software/confluence/ConfluenceDownloadCenter.jspa) (Linux r2.9)
- Install instructions: [http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide](http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide)
	
- Or better, [http://confluence.atlassian.com/display/DOC/Installing+Confluence+Standalone+on+Unix+or+Linux](http://confluence.atlassian.com/display/DOC/Installing+Confluence+Standalone+on+Unix+or+Linux)
- System requirements: [http://confluence.atlassian.com/display/DOC/System+Requirements](http://confluence.atlassian.com/display/DOC/System+Requirements)
- Documentation: [http://confluence.atlassian.com/display/DOC/Confluence+Documentation+Home](http://confluence.atlassian.com/display/DOC/Confluence+Documentation+Home)

## Installing Confluence

Install notes:

- Can be installed inside an application server container
- Even in standalone mode, for production use, database should be switched from HSQLDB to MySQL/Oracle/...

- Need a license key first.  Request at [http://confluence.atlassian.com/display/DOC/Get+A+Confluence+Licence](http://confluence.atlassian.com/display/DOC/Get+A+Confluence+Licence)
	
- Cannot be obtained first - can be obtained only with a ServerID available after installation.
- Install Java.


>  sh jdk-6u7-linux-i586-rpm.bin
>  sh jdk-6u7-linux-i586-rpm.bin

- Set Sun Java as default Java
	
- Follow [instructions for setting default java](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Shibboleth_IdP_Installation_at_the_University_of_Canterbury&linkCreation=true&fromPageId=3818228420)

``` 

export JAVA_HOME=/usr/java/latest
alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 16007      \
  --slave /usr/bin/rmiregistry rmiregistry $JAVA_HOME/bin/rmiregistry    \
  --slave /usr/share/man/man1/java.1 java.1 $JAVA_HOME/man/man1/java.1   \
  --slave /usr/share/man/man1/rmiregistry.1 rmiregistry.1 $JAVA_HOME/man/man1/rmiregistry.1  \
  --slave /usr/lib/jvm/jre jre $JAVA_HOME/jre                            \
  --slave /usr/lib/jvm-exports/jre jre_exports $JAVA_HOME/jre/lib        \
  --slave /usr/bin/keytool keytool $JAVA_HOME/bin/keytool                \
  --slave /usr/bin/rmic rmic $JAVA_HOME/bin/rmic                         \
  --slave /usr/bin/javah javah $JAVA_HOME/bin/javah                      \
  --slave /usr/bin/javadoc javadoc $JAVA_HOME/bin/javadoc                \
  --slave /usr/bin/javac javac $JAVA_HOME/bin/javac                      \
  --slave /usr/bin/jarsigner jarsigner $JAVA_HOME/bin/jarsigner          \
  --slave /usr/bin/jar jar $JAVA_HOME/bin/jar                            \
  --slave /usr/lib/jvm/java java_sdk $JAVA_HOME                          \
  --slave /usr/lib/jvm-exports/java java_sdk_exports $JAVA_HOME/lib

```

- Configure JAVA_HOME environment variable: create executable `/etc/profile.d/java.sh` with


>  JAVA_HOME=/usr/java/latest
>  export JAVA_HOME
>  JAVA_HOME=/usr/java/latest
>  export JAVA_HOME

- Install required graphics libraries:


>  yum install libXp libXp-devel
>  yum install libXp libXp-devel

- Untar Confluence: installation directory is `/usr/local/confluence-2.9-std`


>  cd /usr/local/
>  tar xzf ~/inst/confluence-2.9-std.tar.gz 
>  cd /usr/local/
>  tar xzf ~/inst/confluence-2.9-std.tar.gz 


- Leaving confluence to run at port 8080

- For now, not selecting an external database.

- Start confluence


>  /usr/local/confluence-2.9-std/bin/startup.sh
>  /usr/local/confluence-2.9-std/bin/startup.sh

- Confluence is now available at


>  [http://confluencewiki.canterbury.ac.nz:8080/](http://confluencewiki.canterbury.ac.nz:8080/)
>  [http://confluencewiki.canterbury.ac.nz:8080/](http://confluencewiki.canterbury.ac.nz:8080/)

- Now we have a ServerID: get the license key from http://www.atlassian.com/software/confluence/GenerateConfluenceEvaluationLicenseSID\!default.jspa
- Copy the license key into our confluence instance and choose Standard Install (Custom Install would be for an external database,...)

## Post configuration

- See the Administration Guide: [http://confluence.atlassian.com/display/DOC/Administrators+Guide](http://confluence.atlassian.com/display/DOC/Administrators+Guide)
- Admin console should have an Mail Configuration page to configure an outgoing SMTP server.
- Enable LDAP
- Sections on Customization

TODO:

- Set JAVA_HOME system-wide
- Start Confluence automatically (startup.sh and shutdown.sh need JAVA_HOME)

Install Apache at port 80 and configure automatic redirects to port 8080:

>  yum install httpd
>  chkconfig httpd on
>  service httpd start

- Establish automatic redirect to `/twiki/bin/view`: create `/etc/httpd/conf.d/rootredir.conf` with 

``` 
RedirectMatch ^/+$ http://confluencewiki.canterbury.ac.nz:8080/
```

## LDAP integration

- Documented at: [http://confluence.atlassian.com/display/DOC/Add+LDAP+Integration](http://confluence.atlassian.com/display/DOC/Add+LDAP+Integration)


>  **Important note:*do not** turn on *External user management* - that is for users managed by JIRA, not for LDAP.
>  **Important note:*do not** turn on *External user management* - that is for users managed by JIRA, not for LDAP.

Documentation says *"Your LDAP or Active Directory server must support static groups."*

- We don't have that, but we should still be able to use LDAP without group support...
- Hmmm, doc says that permissions (even to access confluence) would be granted to LDAP groups ... which we don't have.
	
- But there is a [LDAP Dynamic Groups Plugin](http://confluence.atlassian.com/display/CONFEXT/LDAP+Dynamic+Groups+Plugin) that could save us...

- We might also try linking against Active Directory: we have groups there!

Troubleshooting links:

- [http://confluence.atlassian.com/display/DOC/Troubleshooting+LDAP+User+Management](http://confluence.atlassian.com/display/DOC/Troubleshooting+LDAP+User+Management)
- [http://confluence.atlassian.com/pages/viewpage.action?pageId=176721](http://confluence.atlassian.com/pages/viewpage.action?pageId=176721)

Let's roll: edit `/usr/local/confluence-2.9-std/confluence/WEB-INF/classes/atlassian-user.xml` and modify:

``` 

                        <host>ldap.canterbury.ac.nz</host>
                        <securityPrincipal>cn=reader,dc=canterbury,dc=ac,dc=nz</securityPrincipal>
                        <securityCredential>password</securityCredential>
                        <baseContext>ou=useraccounts,dc=canterbury,dc=ac,dc=nz</baseContext>
                        <baseUserNamespace>ou=useraccounts,dc=canterbury,dc=ac,dc=nz</baseUserNamespace>
                        <baseGroupNamespace>ou=groups,dc=canterbury,dc=ac,dc=nz</baseGroupNamespace>
                        <usernameAttribute>uid</usernameAttribute>
                        <userSearchFilter>(objectClass=person)</userSearchFilter>
                        # not changing group search parameters

```

- Restart Confluence


>  /usr/local/confluence-2.9-std/bin/shutdown.sh
>  /usr/local/confluence-2.9-std/bin/startup.sh
>  /usr/local/confluence-2.9-std/bin/shutdown.sh
>  /usr/local/confluence-2.9-std/bin/startup.sh

- Works enough to log in, but the user does not have even read permissions - likely will need the Dynamic Groups plugin

- LDAP test reports errors if groupsearch is pointed to an nonexistent context - let it search `ou=groups,dc=canterbury,dc=ac,dc=nz`
- Our LDAP does have a single group `rdpusers` in `ou=groups,dc=canterbury,dc=ac,dc=nz`

We now need the [LDAP Dynamic Groups Plugin](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=LDAP%20Dynamic%20Groups%20Plugin&linkCreation=true&fromPageId=3818228420)

- See an [Overview of Mapped Groups](http://confluence.atlassian.com/display/CONFEXT/Overview+of+Mapped+Groups) and a [Group Mappings Example](http://confluence.atlassian.com/display/CONFEXT/Group+Mappings+Example)

Installing the plugin:

- Shutdown confluence


>  /usr/local/confluence-2.9-std/bin/shutdown.sh 
>  /usr/local/confluence-2.9-std/bin/shutdown.sh 

- Download [LDGP 2.1.1 JAR](http://svn.atlassian.com/svn/public/contrib/confluence/ldap-dynamic-groups/trunk/target/ldap-dynamic-groups-2.1.1.jar)
- Copy the jar into CONFLUENCE_INSTALL_DIR/confluence/WEB-INF/lib


>  rw-rw-r- 1 root root 25567 Aug 11 10:06 /usr/local/confluence-2.9-std/confluence/WEB-INF/lib/ldap-dynamic-groups-2.1.1.jar
>  rw-rw-r- 1 root root 25567 Aug 11 10:06 /usr/local/confluence-2.9-std/confluence/WEB-INF/lib/ldap-dynamic-groups-2.1.1.jar

- Create CONFLUENCE_HOME/ldap-group-mapping


>  mkdir /usr/local/confluence-data/ldap-group-mapping
>  mkdir /usr/local/confluence-data/ldap-group-mapping

- Put [ldap-mappings.properties](http://svn.atlassian.com/svn/public/contrib/confluence/ldap-dynamic-groups/trunk/properties/ldap-group-mapping/ldap-mappings.properties) into the directory - and edit as necessary:

``` 

# mappings:
#   all logged-in users are confluence-users
#   all students are in group students
#   me and Robin are in icts-ats
dynamic-groups.mapping= uid, confluence-users; \ 
                        ucdeptcode:MISC, students; \
                        ucdeptcode:ITAT, icts-ats;

```
- Restart confluence


>  /usr/local/confluence-2.9-std/bin/startup.sh 
>  /usr/local/confluence-2.9-std/bin/startup.sh 

- Manually create the groups configured before users start logging in!

- Problem: Confluence has been displaying a blank full name for LDAP users.  This was because the `givenName` attribute did not exist in our LDAP server.  As a temporary hack, I have configured Confluence to use CN instead.

``` 

                        <firstnameAttribute>cn</firstnameAttribute>
                        <!-- <firstnameAttribute>givenname</firstnameAttribute> -->
                        <surnameAttribute>sn</surnameAttribute>

```
- Now, user names do display - even though they now take the form

``` 
Vladimir Mencl Mencl
```
- This could be solved by switching over to the ActiveDirectory LDAP server - or we can just live with that.

## Farming

- Confluence supports multiple [Workspaces](http://www.atlassian.com/software/confluence/features/workspaces.jsp) for different projects - which would sit on the same site.
- It appears there is no direct support for farming in confluence.
- But it should at least be doable by having multiple Tomcat containers linked from a single Apache server with virtual hosts.
	
- This should be technically possible: Confluence documentation has pages on [Running Confluence behind Apache](http://confluence.atlassian.com/display/DOC/Running+Confluence+behind+Apache) and [Using Apache with virtual hosts and mod_proxy](http://confluence.atlassian.com/display/DOC/Using+Apache+with+virtual+hosts+and+mod_proxy).
- However, this might be a licensing issue: we might need separate licenses for each confluence instance.

BTW, I've found an interesting [summary](http://wiki.case.edu/Wiki_farm_proposal) of another project evaluating multiple wiki systems for the purpose of establishing a wiki farm.  And another one [comparing Confluence and Mediawiki](http://www.bobsgear.com/display/bobsgear/Confluence+vs.+Mediawiki).

## Customizing Confluence

[http://www.atlassian.com/software/confluence/wiki.jsp#customizeConfluence](http://www.atlassian.com/software/confluence/wiki.jsp#customizeConfluence)

Just about everything in Confluence can be customised. Choose what you see by customising the interface (colors, branding, layout, fields, navigation, etc.). Then select who can see it with the administration preferences (privileges, security).

See the relevant [Admin guide sections](http://confluence.atlassian.com/display/DOC/Administrators+Guide#AdministratorsGuide-designandLayout) on configuring layouts and themes.
