# Install GridSphere Portal Framework

# Introduction

This article represents a simple instructions for installing the GridSphere Portal Framework. 

# Prerequisites

- Java JDK 1.5 (Make sure the environment variable JAVA_HOME is defined)
- [Jakarta Tomcat](http://tomcat.apache.org/download-55.cgi) (Make sure the environment variable CATALINA_HOME is defined)
- [Apache ANT](http://ant.apache.org/bindownload.cgi) (Make sure the environment variable ANT_HOME is defined, and ANT_HOME/bin is in the PATH environment variable)
- [Subversion client](http://subversion.tigris.org/)
- MySQL (Optional)

# GridSphere Source

>  **Check out GirdSphere source from subversion repository*http**://svn.gridsphere.org/gridsphere/trunk. 

Note: According to the [Getting Started Guide](http://docs.gridsphere.org/display/gs30/Getting+Started+Guide) from [GridSphere Wiki](http://docs.gridsphere.org/dashboard.action), the subversion repository is **https**://svn.gridsphere.org/gridsphere/trunk, but the certificate of SSL is expired at the time of writing, However http is working. i.e. svn co [https://svn.gridsphere.org/gridsphere/trunk](https://svn.gridsphere.org/gridsphere/trunk) gridsphere

# Pre-install Database Configuration (Optional)

If you don not like to replace default database HSQL with MySQL, you could skip this part

>  **Edit*gridsphere_source_directory**/webapps/gridsphere/WEB-INF/CustomPortal/database/hibernate.properties, remove the configuration for HSQL and uncomment the configuration for MySQL as following. Make sure the correct value of mysql url, username and password.

``` 

## MySQL

hibernate.dialect org.hibernate.dialect.MySQLDialect
hibernate.connection.driver_class org.gjt.mm.mysql.Driver
hibernate.connection.driver_class com.mysql.jdbc.Driver
hibernate.connection.url jdbc:mysql://localhost/gridsphere
hibernate.connection.username root
hibernate.connection.password


```

- Download MySQL and Java jdbc driver from [http://www.mysql.com/downloads/api-jdbc.html](http://www.mysql.com/downloads/api-jdbc.html)


>  **Copy the driver mysql-connector-java-5.0.6-bin.jar to*gridsphere_source_directory**/lib
>  **Copy the driver mysql-connector-java-5.0.6-bin.jar to*gridsphere_source_directory**/lib

# GridSphere Logging

You can edit **Gridsphere_install_path**/webapps/gridsphere/WEB-INF/classes/log4j.properties to setup your preferred GridSphere logging settings before deployment.

# Install the Portal

>  **cd to*gridsphere_source_directory**, and then type:

``` 

ant install

```

- start up the tomcat

``` 

$ cd $CATALINA_HOME/bin
$ ./startup.sh

```

# Setting up the portal


