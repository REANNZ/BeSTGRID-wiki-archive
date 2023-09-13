# Install Where Are You From

# Introduction

This article describes how to install and configure Where Are You From (WAYF) on a CentOS 4.5 Linux (Identitical to RedHat Enterprise Linux) server. WAYF sometimes also is referred to as Identity Provider Discovery Service.

WAYF has to present the user a list of Identity Providers when an AuthRequest message provided from a Service Provider (SP) and return a redirect to the selected Identity Provider with the original GET arguments. 

# Prerequisites

The version of softwares use in this installation are listed inside the bracket.

- Apache Httpd Server with SSL module (Httpd 2.0.59)
- Apache Httpd devel (2.0.59)
- Java SDK (1.5.0_11)
- Apache Tomcat (5.5.23)

# Install Apache Tomcat Connector

- Download latest Tomcat Connector (mod_jk) source from [http://tomcat.apache.org/download-connectors.cgi](http://tomcat.apache.org/download-connectors.cgi). The latest version of mod_jk at the time of writing is 1.2.23
- Extract the downloaded tar file

``` 
tar xvfz tomcat-connectors-1.2.23-src.tar.gz
```
- Make and install tomcat-connector

``` 
cd tomcat-connectors-1.2.23-src/native
./configure --with-apxs=/usr/sbin/apxs (where your Httpd-devel installed)
make
cp ./apache-2.0/mod_jk.so /etc/httpd/modules
make clean
```

# Configure tomcat-connector

- Create a configure file called mod_jk.conf in /etc/httpd/conf.d/

``` 

LoadModule jk_module modules/mod_jk.so
#
# Mod_jk settings
#
JkWorkersFile "conf.d/workers.properties"
JkLogFile "logs/mod_jk.log"
JkLogLevel error
#Mount the necessary tomcat directory
#Remove /jsp-exampels in the production environment
#It is only for testing purpose
JkMount /jsp-examples default
JkMount /jsp-examples/* default
JkMount /shibboleth-wayf default
JkMount /shibboleth-wayf/* default
# End of mod_jk settings

```

- Create a worker file called workers.properties in /etc/httpd/conf.d/

``` 

workers.tomcat_home=/usr/local/tomcat
workers.java_home=/usr/java/java
ps=/
worker.list=default
worker.default.port=8009
worker.default.host=localhost
worker.default.type=ajp13
worker.default.lbfactor=1

```

- Restart Apache

``` 

/etc/init.d/httpd restart

```
- Test your installation by go to, if you can see the default tomcat JSP examples page, congratulation!!!!

``` 

http://<your host url>/jsp-examples/

```

# WAYF Configuration and Installation

- You need to configure the Discovery Service before installation

- Extract the binary to a temporary install directory by enter the following command:

``` 
 tar xvfz DiscoveryService-2.0-TP1.tgz 
```

- Edit /webpages/wayf.jsp for changing look and feel

- Edit /src/config/wayfconfig.xml and change the line *uri="file:///usr/local/sites.xml* for changing the location for the metadata

- Eidt build.xml, change

``` 
<property name="dist.name" value="DiscoveryService-${version}" /> to <property name="dist.name" value="shibboleth-wayf" />
```

- Once configuration is complete, go to the top level of the temporary install directory and type 'ant'. This will build the war file  suitable for deploying into your container.

- Copy your war file into tomcat webapps directory.

# CentOS 4.5 RPM Repositories

- [http://mirror.centos.org/centos/4.5/os/i386/CentOS/RPMS/](http://mirror.centos.org/centos/4.5/os/i386/CentOS/RPMS/)

- RPM Most updated repository [http://mirror.centos.org/centos/4.5/centosplus/i386/RPMS/](http://mirror.centos.org/centos/4.5/centosplus/i386/RPMS/)
