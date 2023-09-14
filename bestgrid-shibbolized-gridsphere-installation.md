# BeSTGRID Shibbolized GridSphere Installation

# Introduction

This article describes my (Eric's) steps to install Shibboleth Authentication supported GridSphere.

Work Plan: [BeSTGRID Shibboleth Authentication for GridSphere Work Plan](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID_Shibboleth_Authentication_for_GridSphere_Work_Plan&linkCreation=true&fromPageId=3818228632)

Please look at [BeSTGRID Shibbolized Sakai Installation](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID_Shibbolized_Sakai_Installation&linkCreation=true&fromPageId=3818228632) and [Shibboleth Service Provider Installation on RHEL4](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Shibboleth_Service_Provider_Setup_-_RHEL4&linkCreation=true&fromPageId=3818228632) for Shibboleth 1.3 SP installation and it will also guide you how to become AAF Level 1 member.

# Prerequisites

- Shibboleth SP installed.
- JAVA installed.
- Tomcat installed.
- MySQL installed. (or other SQL database)

(Please look at [BeSTGRID Shibbolized Sakai Installation](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID_Shibbolized_Sakai_Installation&linkCreation=true&fromPageId=3818228632) for an example setup)

# Installation

- Download MySQL - Java jdbc driver from [http://www.mysql.com/downloads/api-jdbc.html](http://www.mysql.com/downloads/api-jdbc.html) (We are using mysql-connector-java-5.0.5-bin.jar in this example)

- Copy mysql-connector-java-5.0.5-bin.jar to $CATALINA_HOME/common/lib

- Download Shibbolized GridSphere 3.0.5 from MAMS

``` 

$wget http://www.federation.org.au/software/shibbolized-gridsphere-3.0.5.zip

```

- Extract the new downloaded Shibbolized GridSphere

``` 

unzip shibbolized-gridsphere-3.0.5.zip

```

**Edit webapps/gridsphere/Shibboleth.properties and update *host.dns** with correct value. e.g. host.dns=gridsphere.test.bestgrid.org

- Customize webapps/gridsphere/WEB-INF/classes/log4j.properties.

For example:

``` 

#log4j.debug=TRUE

# Set root category priority to ERROR and its only appender to A1.
log4j.rootCategory=ERROR, A1, LOGFILE

# A1 is set to be a ConsoleAppender.
log4j.appender.A1=org.apache.log4j.ConsoleAppender
# A1 uses PatternLayout.
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=%r:%p:(%F:%M:%L)%n< %m >%n%n

log4j.appender.LOGFILE=org.apache.log4j.RollingFileAppender
log4j.appender.LOGFILE.layout=org.apache.log4j.PatternLayout
log4j.appender.LOGFILE.File=/usr/local/tomcat/logs/gridsphere_log.txt
log4j.appender.LOGFILE.MaxFileSize=1024KB
log4j.appender.LOGFILE.MaxBackupIndex=3
log4j.appender.LOGFILE.layout.ConversionPattern=%r:%p:(%F:%M:%L)%n< %m >%n%n

# Log all of GS
log4j.logger.org.gridsphere=DEBUG

```

- Copy common-logging.jar and log4j.jar from gridsphere-3.0.5/lib to $CATALINA_HOME/commons/lib

>  **Comment the*create-database** antcall

- Copy gridsphere-context.xml to $CATALINA_HOME/conf/Catalina/localhost

- Insert the following text into your port 443 Apache configuration

``` 

<Location /gridsphere/gridsphere/login/shib_login>
                AuthType shibboleth
                ShibRequireSession On
                require valid-user
</Location>

```

- Restart Tomcat and Apache HTTPD

**ACKNOWLEDGMENT**

The Shibbolized GridSphere work was original developed by Dr Aizhong (Alan) Lin from MAMS project, Australia. Thanks so much for their excellent work!!!
