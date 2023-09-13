# Configuring a Shibboleth 2.0 IdP with a login screen

The default installation of a Shibboleth 2.0 IdP comes with authentication handled by Apache at the http(s) level, with Tomcat and Shibboleth IdP only receiving the remote user information from Apache.  The user sees a generic browser prompt asking for the username and password.

It may be desirable to have a site-branded login screen - this would make it easier for users to recognize the proper login screen - and may be necessary for deploying site-wide login and password-handling policies.

Deploy a login screen for a Shibboleth 2.0 IdP is not at all difficult.  

- The primary documentation is at [https://wiki.shibboleth.net/confluence/display/SHIB2/IdPAuthUserPass](https://wiki.shibboleth.net/confluence/display/SHIB2/IdPAuthUserPass)
- Additional documentation is at [http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2](http://projects.arcs.org.au/trac/systems/wiki/HowTo/PilotAAF/InstallIdPShib2)

This page lists the essential information in configuring the login handler to use an LDAP server - and it's only a few easy steps.

# Configuring a Shibboleth 2.0 IdP with a login screen

- Edit `$IDP_HOME/handler.xml` and
	
- Uncomment `UsernamePassword` LoginHandler
- Comment out `RemoteUser` LoginHandler
- Optionally: customize session duration (default 30 minutes): add the following attribute (with the duration in minutes) to the UsernamePassword login handler:

``` 
authenticationDuration="60"
```

- Edit $IDP_HOME/conf/login.config and provide details for the LDAP server (uncomment and configure LdapLoginModule section).  You may have to provide more attributes then what's in the default commented-out section: namely `subtreeSearch="true"` and `serviceUser` and `serviceCredential` with login details for a privileged account (to look up users).  The following section has worked at Canterbury:

``` 

   edu.vt.middleware.ldap.jaas.LdapLoginModule required
      host="ldap.canterbury.ac.nz"
      base="ou=useraccounts,dc=canterbury,dc=ac,dc=nz"
      serviceUser="<ldap user DN here>"
      serviceCredential="<ldap password here>"
      subtreeSearch="true"
      ssl="false"
      userField="uid";

```

- Customize login screen with site branding:
	
- Either edit `/var/lib/tomcat5/webapps/idp/login.jsp` (if you are running the IdP with the WAR extracted in `/var/lib/tomcat5/webapps/idp`)
- Or edit `src/main/webapp/login.jsp` in your Shibboleth IdP source distribution (and rebuild the WAR file afterwards)

- Restart Tomcat


>  service tomcat5 restart
>  service tomcat5 restart
