# ShARPE Exploration

# Introduction

This article describes my (Eric) exploration on ShARPE (Shibboleth Attribute Release Policy Editor). 

The following paragraphs are directly quoted from ShARPE website:

"ShARPE is developed as part of the collaboration between MAMS and Shibboleth. ShARPE's aim is to manage the creation and maintenance of user's attributes as defined by Attribute Release Policy (ARP) mechanism of Shibboleth.

In particular, ShARPE allows admins and users to easily manage their release attribute policy in a way that conforms to their privacy and satisfaction of users in gaining the services that they want (on service provider end) To do the crosswalk between different directory schemas mappings have to be defined. This can be achieved using the Crosswalker."

# Official Online Documentation

- [What is ShARPE?](http://www.federation.org.au/twiki/bin/view/Federation/ShARPE)
- [ShARPE Installation Guide](http://www.federation.org.au/twiki/bin/view/Federation/ShARPEInstall)
- [ShARPE Quick Start Guide](http://www.federation.org.au/twiki/bin/view/Federation/WebSharpeView)
- [ShARPE Uninstall Guide](http://www.federation.org.au/twiki/bin/view/Federation/UninstallShARPE)

# Common Errors

ShARPE and Tomcat log files are useful during the debugging process. They stores in $CATALINA_HOME/logs/.

## HTTP Status 404

This error usually caused by unsuccessful ShARPE initialization if you have configured mod_jk to mount /ShARPE correctly. Therefore it is necessary to investigate Tomcat's log file (catalina.out).

- MAMSFileSystemArpRepository is not used
- According to [ShARPE Install Guide|http

//www.federation.org.au/twiki/bin/view/Federation/ShARPEInstall], it is necessary to use MAMSFileSystemArpRepository instead of Shibboleth original FileSystemArpRepository in idp.xml.

- Fail to get requested file

$IDP_HOME$/etc/$EXTENSION_NAME$/crosswalk.properties
- This is a bug in 0.7.3 build.xml file. It doesn't replace the variables $IDP_HOME$ and $EXTENSION_NAME$ with real value in crosswork.properties configuration. Therefore please apply a [ShARPE crosswork configuration patch](/wiki/spaces/BeSTGRID/pages/3818228523) to it as following:

``` 
[shib@kilrogg ShARPE]$patch -p0 < ShARPE_0.7.3_patch.txt 
```

## Failed to instantiate an AttributeResolverGroupLookup

If you followed the online [ShARPE Installation Guide](http://www.federation.org.au/twiki/bin/view/Federation/ShARPEInstall), you may found this error in sharpe.log file, because it can't find the resolver file. Therefore you can change the resolver configuration from

``` 

<ResolverConfig implementation="edu.internet2.middleware.shibboleth.aa.attrresolv.MAMSAttributeResolver">
               /usr/local/shibboleth-idp/etc/resolver.ldap.xml
</ResolverConfig>

```

to

``` 

<ResolverConfig implementation="edu.internet2.middleware.shibboleth.aa.attrresolv.MAMSAttributeResolver">
               file:/usr/local/shibboleth-idp/etc/resolver.ldap.xml
</ResolverConfig>

```
