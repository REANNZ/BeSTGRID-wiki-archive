# Installing and Evaluating Wikis considered at University of Canterbury___Evaluation summary

This page summarizes the experience learned when [installing the three wikis considered](installing-and-evaluating-wikis-considered-at-university-of-canterbury.md).

The wikis evaluated are:

- Confluence: [http://confluencewiki.canterbury.ac.nz/](http://confluencewiki.canterbury.ac.nz/)
- TWiki: [http://twiki.canterbury.ac.nz/](http://twiki.canterbury.ac.nz/)


>  **xWiki: ****[http://xwiki.canterbury.ac.nz/](http://xwiki.canterbury.ac.nz/)**** (*Warning**: LDAP login not working.)
>  **xWiki: ****[http://xwiki.canterbury.ac.nz/](http://xwiki.canterbury.ac.nz/)**** (*Warning**: LDAP login not working.)

The aspects evaluated are:

- LDAP integration
- Farming
- Customization

# Confluence

Confluence leaves a strong impression that it is a product with a strong commercial backing.

Confluence comes with extension documentation, an easy to follow installation recipe (a quite short one), and a web configuration interface.

And even for trial users, there is a very professionally looking support staff ready to help.

## LDAP

Configuring Confluence to control access via LDAP was quite easy to do.  It did require installation of an additional plugin for dynamic groups, but with this plugin, Confluence provides a broad variety of access control features.  Groups can automatically included users based on their LDAP attributes - either based on the mere presence of an attribute, or based on a specific value in the attribute.  It is easy to create groups like:

- *students*: ucdeptcode has value 'MISC'
- *courseABCD101*: uccourse contains value 'ABCD101'
- groups for each academic or service department (based on their departmental code).

One subtle drawback of LDAP support in Confluence: it requires the attributes `givenName` and `sn` (surname) to construct the display name for a user.  Unfortunately, our LDAP server does not provide this attribute - it only has `cn` (common name) and `sn`.  Without givenName, Confluence was displaying a blank display name for each user.  To work around that, I have configured Confluence to use `cn` in place of givenName.  That makes Confluence work, but it doubles the surname: it greets me as `Vladimir Mencl Mencl`.

I have asked Confluence support staff for help, and I've received back a pointer to documentation on how to change the underlying page templates.  In production use, we should be able to either change the templates and do without a givenName attribute, or we might switch to use the ActiveDirectory server instead of the LDAP server for authorization (... or possibly add the attribute to the LDAP server).

## Farming

Confluence comes with support for [Workspaces](http://www.atlassian.com/software/confluence/features/workspaces.jsp).  Workspaces are separate namespaces for wiki pages, but to users, they appear to sit on the same server, just under a different "directory".

It appears there is no direct support for farming itself in Confluence.  Nonetheless, it would still be possible to run multiple instances of Confluence, each in a separate Tomcat container.  A single Apache server with virtual hosts configured could then route the requests to the appropriate instances.

This solution should be technically possible: Confluence documentation has pages on [Running Confluence behind Apache](http://confluence.atlassian.com/display/DOC/Running+Confluence+behind+Apache) and [Using Apache with virtual hosts and mod_proxy](http://confluence.atlassian.com/display/DOC/Using+Apache+with+virtual+hosts+and+mod_proxy). However, this might be a licensing issue: we might need separate licenses for each confluence instance.

I have asked Confluence support staff about this solution (and what the licensing situation would be), I am still waiting to hear from them back.

## Customization

Quoting the [Confluence FAQ](http://www.atlassian.com/software/confluence/wiki.jsp#customizeConfluence):

Just about everything in Confluence can be customised. Choose what you see by customising the interface (colors, branding, layout, fields, navigation, etc.). Then select who can see it with the administration preferences (privileges, security).

See the relevant [Admin guide sections](http://confluence.atlassian.com/display/DOC/Administrators+Guide#AdministratorsGuide-designandLayout) on configuring layouts and themes.

# xWiki

xWiki also leaves a good impression on how it's documented and packaged for installation.  The installation is very straightforward, just running a single installer jar.

However, xWiki has a serious issue with LDAP integration - it can grant permissions only based on LDAP groups, and with no groups *per se* in the LDAP server, we can't grant our users any permissions - not even to view ordinary wiki pages after they log in.

xWiki is however still available in anonymous mode.  With explicit LDAP groups being introduced into our LDAP server, we might get it going - but for comparison, contrary to Xwiki, Confluence can define groups based on arbitrary LDAP attributes, giving a much greater flexibility in permissions configuration.

## LDAP

xWiki supports use of an LDAP server for authentication.  However, authorization is based on mapping LDAP groups to XWiki groups, which then get permissions assigned.

However, contrary to Confluence, xWiki does not provide any way to define synthetic groups based on LDAP attributes.  With no groups in the LDAP server, it is not possible to assign any privileges to users authenticating via LDAP.  Even though it was possible to log in via LDAP, the user would then not have any privileges, not even those of an anonymous user, and would get a Permission Denied error for an attempt to view any page.

The only way to get around this would be to introduce explicit LDAP groups inside our LDAP server.

## Farming

According to the [xwiki scalability page](http://platform.xwiki.org/xwiki/bin/view/Features/ScalabilityPerformance), XWiki can host [virtual XWiki's](http://platform.xwiki.org/xwiki/bin/view/AdminGuide/Virtualization), which would be exactly what we need for a wiki farm.

## CSS Customization

XWiki should support CSS customization as [Skins](http://platform.xwiki.org/xwiki/bin/view/Features/Skins)

# TWiki

TWiki is implemented as a collection of perl scripts, and the installation somehow looks as that - it's more a do-it-yourself installation.  On the other hand, it's a much more lightweight systems - does not need a Java container, runs only just in Apache, and it in the end may be easier to administer.  Most of the configuration is just in the Apache configuration file.

TWiki is very popular in some communities, and allows quite a lot of logic to be embedded inside the wiki pages - the TWiki project even uses a TWiki wiki page to generate the Apache configuration file for the target environment based on the system's parameters.

## LDAP

Integration with LDAP is quite straightforward and simple.  TWiki itself has no support for LDAP, but can let Apache to do authentication for TWiki.  Thus, configuring LDAP logins is just the matter of configuring Apache configuration against the LDAP server.

Consequently, the only information TWiki receives from the LDAP server is the user's login name (usercode).  No attributes are received from LDAP (not even the full name), and there is no support for groups created based on LDAP attributes.  Although we could setup a single Wiki instance to allow only users with a selected attribute (or value), once we let a user through, TWiki can't make any authorization decisions based on the attributes.

Authorization is done based on TWiki group membership (like in [TWikiAdminGroup](http://twiki.canterbury.ac.nz/twiki/bin/view/Main/TWikiAdminGroup)), and the list of members of a group has to be edited manually.

**Note:** more proper LDAP integration, including support for LDAP groups could be done with the [LdapContrib plugin](http://twiki.org/cgi-bin/view/Plugins/LdapContrib).  With this plugin, TWiki could fetch additional information about a user, and could also make use of the LDAP groups (if they existed in our LDAP server).

## Farming

Given that a lot of TWiki information is stored in plain directories, and that it's Apache driven, the best (and only) way to do farming would be to have a number of virtual servers configured in Apache, and have a separate TWiki directory deployed for each wiki in the farm.  

The performance costs be very small (each TWiki action is anyway done in a separate perl script), storage space would also be moderate (plain TWiki installation takes only about 30 MB), and the administrative costs should be also acceptable (each would be basically maintained separately, but we should keep the configuration in sync).

## Skins and Customization

TWiki does support Skins:

- comes with a number of predefined [Skin packages](http://twiki.org/cgi-bin/view/Plugins/SkinPackage)
- allows to [create](http://twiki.org/cgi-bin/view/TWiki/TWikiSkins) and [customize](http://twiki.org/cgi-bin/view/TWiki.PatternSkinCustomization) skins.

However, installing and customizing skins might need local system access.
