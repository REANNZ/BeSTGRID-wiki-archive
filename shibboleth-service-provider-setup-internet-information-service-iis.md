# Shibboleth Service Provider Setup - Internet Information Service (IIS)

# Introduction

This guide describes how to install a Shibboleth Service Provider 1.3 on a Windows XP machine with IIS 5.x. The configuration in Microsoft Windows platform is similar to [Linux platform](/wiki/spaces/BeSTGRID/pages/3816950611#ShibbolethServiceProviderSetup-RHEL4-ConfigurationsofServiceProvider)

This guide can also be applied to other MS Windows OSs with IIS installed (e.g. Windows 2003 server). But they have not been test yet.

# Prerequisites

- Microsoft Windows XP Professional
- Service Pack (recommended to have an up-to-date service-pack)
- Internet Information Service (IIS) (It only been tested with IIS 5.x, not quite sure about other version)
- OpenSSL (It is optional if you have a SSL Certificate and a SSL private key already)

# SSL

## Create SSL certificates and private keys

- NOTE: yifan-jiang.enarc.auckland.ac.nz is my host name

- Greate a private key and a certificate request by OpenSSL

``` 
root# openssl req -new -newkey rsa:1024 -sha1 -keyout yifan-jiang.enarc.auckland.ac.nz.key -nodes 
-out yifan-jiang.enarc.auckland.ac.nz.csr
```
- Send the certificate request (yifan-jiang.enarc.auckland.ac.nz.csr) to be signed by a trusted external Certification Authority (CA). e.g. [VeriSign](http://www.verisign.com/) or [Thawte](http://www.thawte.com/).
- You can self-sign the certificate in a prototype environment.
- Create a CA certificate and a CA key

``` 
openssl req -x509 -new -newkey rsa:1024 -keyout myCA.key -nodes -out myCA.crt -days 3650
```
- Self-sign your own certificate

``` 
openssl x509 -req -in yifan-jiang.enarc.auckland.ac.nz.csr -CA myCA.crt -CAkey myCA.key -CAcreateserial 
-out yifan-jiang.enarc.auckland.ac.nz.crt -days 1095
```
- Create PKCS12 file for use in IIS

``` 
openssl pkcs12 -export -in yifan-jiang.enarc.auckland.ac.nz.crt 
-inkey yifan-jiang.enarc.auckland.ac.nz.key -out yifan-jiang.enarc.auckland.ac.nz.p12
```

## Configure SSL for IIS

### Store the certificate for IIS

- Open Microsoft Management Console (MMC). By click "Start" > "Run" > typle "MMC" > click "OK".
- In the "MMC", Select "Console Root" > click "File" > "Add/Remove Snap-in".
- In the "Add/Remove Snap-in dialog box, click "Add"
- In the "Add Standalone Snap-in" dialog box, select "Certificates" > click "Add".
- Select "Computer account" > "Next" > "Local computer" > "Finish"
- In the "Add Standalone Snap-in" box, click Close.
- In the "Add/Remove Snap-in" box, click OK.
- In the "Console Root Window", expand "Certificates (Local Computer)" > expand "Personal" > select "Certificates"
- Right click the "Certificates" sub-folder > "Add Task" > "Import ..."


>  **At the "Certificate Import Wizard", "Next" > "Browse" > select your**.p12 file (e.g. yifan-jiang.enarc.auckland.ac.nz.p12) 
>  **"Next" > Type the password that you entered when you was generating the**.p12 file. > "Next"
>  **At the "Certificate Import Wizard", "Next" > "Browse" > select your**.p12 file (e.g. yifan-jiang.enarc.auckland.ac.nz.p12) 
>  **"Next" > Type the password that you entered when you was generating the**.p12 file. > "Next"

- " Select "Place all certificates in the following store" > Select "Personal" > "Next" > "Finish"
- Save and exit MMC

### Deploy the certificate for IIS

- Open "Computer Management" (CM). By right click "My Computer" > click "Manage"
- In the "CM", select and expand "Services and Applications" > expand "Internet Information Services"
- Expand "Web sites" > "Default Web Site" > Right click and select "Properties"
- In the "Default Web Site Properties", select "Directory Security" tab > select "Server Certificate..."
- In the "Web Server Certificate Wizard", "Next" > select "Assign an existing certificate" > "Next"
- Select the certificate you just saved > "Next" > "Next" > "Finish"
- In the "Default Web Site Properties", select "Edit" in the "Secure communications" panel.
- In the "Secure Communication" dialog box, click "Require secure channel (SSL)" > "OK"
- In the "Default Web Site Properties", click "Apply" > "OK"
- You are done!!!!
- Test it by enter the "https://" + your host name at the URL address bar of web browser. (e.g. [https://yifan-jiang.enarc.auckland.ac.nz](https://yifan-jiang.enarc.auckland.ac.nz))

# Install Shibboleth Service Provider 1.3

- Download the Windows Installer of latest Shibboleth Service Provider 1.3 from [Internet2](http://shibboleth.internet2.edu/latest.html)
- Double click the Windows Installer you just downloaded, keep everything as default.
- Restart your computer

# IIS configuration for Shibboleth SP

- "Start" > "Control Panel" > "Administrative Tools" > "Internet Information Services"
- Right click "Web Sites" and select "Properties"
- Click the "ISAPI Filters" tab, make sure Shibboleth is in the filter list and it should show up with a green arrow.


>  **If Shibboleth is not in the filter list, click "Add" > "Browse" > select*Shibboleth SP installed path**\libexec\isapi_shib.dll" > click "OK"
>  **If Shibboleth is not in the filter list, click "Add" > "Browse" > select*Shibboleth SP installed path**\libexec\isapi_shib.dll" > click "OK"

- If Shibboleth is "Not load" (i.e. a red arrow), restart the system. (check the Windows event log and/or the Shibboleth logs if it still fails to load)
- In the "Web Sites Properties" dialog, select "Home Directory" tab > click "Configuration"
- In the "Application Configuration" dialog, make sure ".sso" extension is on the "Application Mappings" list.

# Configure Shibboleth Service Provider

The configuration of SP in Windows is similar to [Linux](/wiki/spaces/BeSTGRID/pages/3816950611#ShibbolethServiceProviderSetup-RHEL4-ConfigurationsofServiceProvider) except the path name. e.g.

- In Linux: /etc/shibboleth/....
- In Windows: C:/opt/shibboleth-sp/...

# Protecting a web directory

Protecting a web directory in IIS is different from Apache, it depends on the [XML Access Control Policies](/wiki/spaces/BeSTGRID/pages/3816950611#ShibbolethServiceProviderSetup-RHEL4-XML_Access_Control) that defined in the configuration file.

# Common Problems

I only listed the problems that I found during my installation of SP in MS Windows. Please find other common problems in [here](/wiki/spaces/BeSTGRID/pages/3816950611#ShibbolethServiceProviderSetup-RHEL4-CommonProblems).

## Session creation failure - (is not encoded in Based64)

- The log file (c:/opt/shibboleth-sp/var/log/shibboleth/shibd.log) listed something similar to below:

``` 

2007-02-05 17:21:25 ERROR SAML.XML.ParserPool [12] sessionNew handleError: error on line 18, column 21, message: Datatype error: 
Type:InvalidDatatypeValueException, Message:Value '
...'
' is not encoded in Base64 .

2007-02-05 17:21:25 ERROR shibd.Listener [12] sessionNew: caught exception while creating session: XML::Parser detected an error
during parsing: Datatype error: Type:InvalidDatatypeValueException, Message:Value '
...
' is not encoded in Base64 .

```

- It may be caused by a Xerces library conflict since you may have a copy of Xerces library in system32 that is overriding the copy in Shibboleth library.

>  **Solution: Replace the xerces-c_**.dll in systme32 (usually c:\WINDOWS\system32) by the Xerces library from Shibboleth(usually at c:/opt/shibboleth-sp/lib).
