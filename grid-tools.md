# Grid Tools

The following Grid tools might be particularly useful to grid users. Most of these tools need [Java](http://www.java.com/) installed to run.

# Certificate Management

## Grix

- [Grix](http://ngportal.canterbury.ac.nz/grid/grix-jdk5-bestgrid.jnlp) is the ultimate all-in-one easy to use tool for:
	
- Requesting, retrieving and managing a certificate.
- Managing the VO memberships.
- Creating a local and remote proxy for a certificate.

- Start the BeSTGRID Grix by clicking the [Grix Java Web-Start link](http://ngportal.canterbury.ac.nz/grid/grix-jdk5-bestgrid.jnlp).
	
- In case of problems with Java Web-Start, download the two jars ([grix-jdk5-bestgrid.jar](http://ngportal.canterbury.ac.nz/grid/grix-jdk5-bestgrid.jar) and [bcprov.jar](http://ngportal.canterbury.ac.nz/grid/bcprov.jar)) and run them with:

``` 
java -jar grix-jdk5-bestgrid.jar
```
- Read more about Grix (developed by [at the [http://grix.arcs.org.au/ Grix project page](http://www.vpac.org))].

On some shared computers, user doesn't have the permissions to write into the home folder. To force Grix to use user-writable location, such as a flash drive, user should download [grix jar](http://ngportal.canterbury.ac.nz/grid/grix-jdk5-bestgrid.jar) and [bcprov.jar](http://ngportal.canterbury.ac.nz/grid/bcprov.jar) and store both files in a folder on the flash drive, i.e., "**E:\grix**". 

Then open the command line: Start->Run... and enter a command of the form:

>  java -Duser.home=E:\grix -jar E:\grix\grix-jdk5-bestgrid.jar

Grix will create (or use) **E:\grix\.globus** as a folder for a certificate.

**Note:** Grix will require the full-strength encryption pack to export the certificate for a browser (PKCS-12 format): see [http://www.arcs.org.au/plone/support/how-to/grix/grix-unlimited-strength-patch](http://www.arcs.org.au/plone/support/how-to/grix/grix-unlimited-strength-patch) for instructions.

**Note:** Grix will require you http proxy settings to be set up for Java in the Windows Control Panel applet, but this does not work for all Grix functions. Grix will not be able to do Shibboleth authentication from behind a HTTP proxy.

Grix requires the outgoing TCP  ports http(80), https(443), 8443, 7512, and 15001 to be open.

### Grix server and ports

This is the complete list of servers and ports required for Grix to operate:

``` 

code.arcs.org.au 202.158.218.169 [http, https]
myproxy.arcs.org.au 202.158.218.205 [https]
vomrs.arcs.org.au 202.158.218.236 [https, 8443, 15001]
voms.arcs.org.au 202.158.218.165 [https, 8443, 15001]
slcs1.arcs.org.au. 202.158.218.211 [https]
ds.aaf.edu.au 202.158.212.130 [https]

grisu-vpac.arcs.org.au 202.158.218.149 [https]
grisu.vpac.org 202.158.218.232 [https]
grisu.ceres.auckland.ac.nz 130.216.189.207 [https]

ngportal.canterbury.ac.nz 132.181.39.15 [http,https]

www.bouncycastle.org 203.32.61.81 [http]
downloads.bouncycastle.org 210.15.218.194 [http]

ca.apac.edu.au. 202.158.218.200 [http]
crl.comodoca.com 149.5.128.174 [http]
crl.comodoca.com 91.199.212.174 [http]
crl.comodoca.com 91.209.196.174 [http]
crl.geotrust.com canonical name = geotrust-crl-ilg.verisign.net.geotrust-crl-ilg.verisign.net 69.58.183.143 [http]
crl.verisign.net 199.7.52.190 [http]
crl.startssl.com 70.167.227.245 [http]

```

## ProxyLight

- [ProxyLight](http://hudson.vpac.org/proxyLight/downloads/webstart/proxyLight.jnlp) is a lightweight travel-with-you replacement for grix, capable of retrieving a proxy from a myproxy server.
- Start proxyLight via [proxyLight JavaWebstart link](http://hudson.vpac.org/proxyLight/downloads/webstart/proxyLight.jnlp)
- or download [proxyLight.zip](http://hudson.vpac.org/proxyLight/downloads/current-snapshot/proxyLight.zip) and carry it on your USB memory stick.
- Read more about proxyLight on the [ProxyLight project page](http://projects.arcs.org.au/trac/common-grid-libs/wiki/ProxyLight).

# Job Submission

## Grisu

- Grisu Template Client is a tool for submitting and monitoring jobs on the grid - but it also can manage your files.
- The easiest way to install Grisu is to use the NeSI Tools installer that installs Grisu (as well as other related NeSI tools)
- Download the version best suited for your platform:
	
- For Windows: use [nesi-tools.msi](http://code.ceres.auckland.ac.nz/downloads/nesi/nesi-tools.msi)
- For Mac OS X: use [nesi-tools.pkg](http://code.ceres.auckland.ac.nz/downloads/nesi/nesi-tools.pkg)
- For Linux and other platforms: use generic Java version: [nesi-tools.jar](http://code.ceres.auckland.ac.nz/downloads/nesi/nesi-tools.jar) (Java required)

**NOTE:** For users behind a HTTP proxy, you may need to check *Advanced connection properties* and enter your proxy's address and port number and restart Grisu to get the list of Identity Providers (IDp) to populate correctly.

## BeSTGRID portal

- [BeSTGRID GridSphere portal](https://ngportal.canterbury.ac.nz/gridsphere/gridsphere) allows a user to submit a job from anywhere, just by using a web browser and uploading the files they would like to process on the grid.
	
- The portal so far supports several bioinformatics applications, but please ask us if you would like to see your favorite application there.
- See the brief guide on [Getting started with the portal](/wiki/spaces/BeSTGRID/pages/3816950786).
- Open the portal at [https://ngportal.canterbury.ac.nz/gridsphere/gridsphere](https://ngportal.canterbury.ac.nz/gridsphere/gridsphere)

# File Management

## Hermes

- [Hermes](http://ngportal.canterbury.ac.nz/grid/hermes/hermes.jnlp) is a tool for remote file management, supporting the SRB, GridFTP, and also SFTP and FTP protocols.
	
- Simply click the [Hermes JavaWebStart link](http://ngportal.canterbury.ac.nz/grid/hermes/hermes.jnlp), or downloaded Hermes from [http://sourceforge.net/projects/commonsvfsgrid](http://sourceforge.net/projects/commonsvfsgrid).
- For more information on using Hermes to access the Data Grid, please see the documentation on [Using the Data Grid](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Using%20the%20Data%20Grid&linkCreation=true&fromPageId=3816950787)
- For more information on Hermes and videos showing Hermes in action, please see the [ARCS wiki page on Hermes](http://wiki.arcs.org.au/bin/viewfile/Main/HermesARCS) (the videos are linked at the bottom of the page).  To get a quick taste, have a look at [Dragging and dropping a file from the desktop to a remote site with Hermes](http://wiki.arcs.org.au/bin/viewfile/Main/HermesARCS?filename=2008-11-11_1605.swf).

## SGGC

- [SGGC](http://wiki.arcs.org.au/bin/view/Main/FileTransferSGGCUsageGuide) is another java-based client capable of accessing GridFTP storage systems.
	
- Read more about SGGC and download SGGC from the [SGGC page on ARCS wiki](http://wiki.arcs.org.au/bin/view/Main/FileTransferSGGCUsageGuide).
