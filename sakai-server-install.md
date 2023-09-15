# Sakai Server Install

To The Gateway Server Configuration

- BeSTGRID Sakai VRE - Production/Pilot deployment details
[http://jira.sakaiproject.org/jira/browse/PROD-118](http://jira.sakaiproject.org/jira/browse/PROD-118)

# Setting up the Sakai VRE Virtual Machine

To create a virtual machine for the Sakai server a procedure from section "Creation of Other Domains" described in [APACGrid twiki page](http://www.vpac.org/twiki/bin/view/APACgrid/XenInstall) has been used.

There were some changes which we've implemented in this sequence:

## Disc space for VM:

- Two logical volumes in VolumeGroup00 were created:
	
- SakaiR with 8G size for root partition of VM
- SakaiS with 512M for swap partition

## Sakai VM configuration:

- Directory for Sakai VM file system is */srv/sakai*
- Config file is */etc/xen/Sakai*
- Changes in config file:
	
- ramdisk="/boot/initrd.img-2.6.16.33-xen
- name="Sakai"
- memory=1024
- cpus="0"       //using cpus="" makes an perl error
- disk=['phy:VolumeGroup00/SakaiR,sda1,w','phy:VolumeGroup00/SakaiS,sda2,w'
- vif=[16:3E:01:01:01, bridge=xenbr0']
- added lines:
		
- netmask="255.255.255.0"
- gateway="130.216.189.254"
- hostname="sakai.bestgrid.org"

# Additional software packages:

- Several software packages have been installed to provide full functionality of the server
- **System packages: ******yum install openssh-server logwatch sendmail nano mc***
	
- Application packages:
		
- [J2SE(TM) Development Kit 5.0 Update 11](http://java.sun.com/javase/downloads/index_jdk5.jsp), Linux RPM in self-extracting file;
- Apache Tomcat 5.5.20 in [Core](http://www.pangex.com/pub/apache/tomcat/tomcat-5/v5.5.20/bin/apache-tomcat-5.5.20.tar.gz), [Administration](http://www.pangex.com/pub/apache/tomcat/tomcat-5/v5.5.20/bin/apache-tomcat-5.5.20-admin.tar.gz) and [JDK 1.4 Compatibility](http://www.pangex.com/pub/apache/tomcat/tomcat-5/v5.5.20/bin/apache-tomcat-5.5.20-compat.tar.gz) binary distributions;
- MySQL 4.1 in RHEL4 RPMs (x86): [Server](http://dev.mysql.com/get/Downloads/MySQL-4.1/MySQL-server-standard-4.1.22-0.rhel4.i386.rpm/from/pick), [Client](http://dev.mysql.com/get/Downloads/MySQL-4.1/MySQL-client-standard-4.1.22-0.rhel4.i386.rpm/from/pick), [Shared Libraries](http://dev.mysql.com/get/Downloads/MySQL-4.1/MySQL-shared-standard-4.1.22-0.rhel4.i386.rpm/from/pick);
- [MySQL Connector/J 5.0.4](http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.0.4.tar.gz/from/pick) - the official JDBC driver for MySQL;
- [Sakai 2.3.0](http://source.sakaiproject.org/release/2.3.0/sakai_2-3-0/sakai-bin_2-3-0.tar.gz) - direct download link.

# Compulsory requirements:

- Sakai 2.3.0 requires Tomcat JDK 1.4 Compatibility Package;
- Sakai doesn't work with JDK 6;

# Software Installation

## Make JDK 5 binary file executable and run it

>  chmod 755 jdk-1_5_0_11-linux-i586-rpm.bin
>  ./jdk-1_5_0_11-linux-i586-rpm.bin

## Install and Configure MySQL

- Install MySQL RPMs


>  rpm -iv MySQL-server-standard-4.1.22-0.rhel4.i386.rpm
>  rpm -iv MySQL-client-standard-4.1.22-0.rhel4.i386.rpm
>  rpm -iv MySQL-shared-standard-4.1.22-0.rhel4.i386.rpm
>  rpm -iv MySQL-server-standard-4.1.22-0.rhel4.i386.rpm
>  rpm -iv MySQL-client-standard-4.1.22-0.rhel4.i386.rpm
>  rpm -iv MySQL-shared-standard-4.1.22-0.rhel4.i386.rpm

- Change password for root user


>  mysqladmin -u root password PASSWORD
>  mysqladmin -u root password PASSWORD

- Configure Tomcat's mysql user and authority database


>  mysql> GRANT ALL PRIVILEGES ON **.** TO TOMCATUSERNAME@localhost 
>     ->   IDENTIFIED BY 'TOMCATPASSWORD' WITH GRANT OPTION;
>  mysql> create database authority;
>  mysql> use authority;
>  mysql> create table users (
>     ->   id int not null auto_increment primary key,
>     ->   user_name varchar(20), 
>     ->   user_pass varchar(20));
>  mysql> create table user_roles (
>     ->   id int not null auto_increment primary key,
>     ->   user_name varchar(20), 
>     ->   role_name varchar(20));
>  mysql> insert into users (user_name, user_pass) values ('admin', 'adminpw');
>  mysql> insert into users (user_name, user_pass) values ('manager', 'managerpw');
>  mysql> insert into user_roles (user_name, user_pass) values ('admin', 'admin');
>  mysql> insert into user_roles (role_name, user_pass) values ('manager', 'manager');
>  mysql> GRANT ALL PRIVILEGES ON **.** TO TOMCATUSERNAME@localhost 
>     ->   IDENTIFIED BY 'TOMCATPASSWORD' WITH GRANT OPTION;
>  mysql> create database authority;
>  mysql> use authority;
>  mysql> create table users (
>     ->   id int not null auto_increment primary key,
>     ->   user_name varchar(20), 
>     ->   user_pass varchar(20));
>  mysql> create table user_roles (
>     ->   id int not null auto_increment primary key,
>     ->   user_name varchar(20), 
>     ->   role_name varchar(20));
>  mysql> insert into users (user_name, user_pass) values ('admin', 'adminpw');
>  mysql> insert into users (user_name, user_pass) values ('manager', 'managerpw');
>  mysql> insert into user_roles (user_name, user_pass) values ('admin', 'admin');
>  mysql> insert into user_roles (role_name, user_pass) values ('manager', 'manager');

## Install Apache Tomcat 5.5.20

>  tar -xzfv apache-tomcat-5.5.20.tar.gz -C /opt
>  tar -xzfv apache-tomcat-5.5.20-admin.tar.gz -C /opt
>  tar -xzfv apache-tomcat-5.5.20-compat.tar.gz -C /opt
>  mv /opt/apache-tomcat-5.5.20 /opt/tomcat

## Configure Tomcat

- Untar and move MySQL Connector/J (JDBC driver) into /opt/tomcat/common/lib


>  tar -xzvf mysql-connector-java-5.0.4.tar.gz mysql-connector-java-5.0.4/mysql-connector-java-5.0.4-bin.jar
>  mv mysql-connector-java-5.0.4/mysql-connector-java-5.0.4-bin.jar /opt/tomcat/common/lib 
>  tar -xzvf mysql-connector-java-5.0.4.tar.gz mysql-connector-java-5.0.4/mysql-connector-java-5.0.4-bin.jar
>  mv mysql-connector-java-5.0.4/mysql-connector-java-5.0.4-bin.jar /opt/tomcat/common/lib 

- Add the attribute URIEncoding="UTF-8" to the connector element
- Change port to 80 in the connector:

``` 

    <Connector
        enableLookups="false"
        acceptCount="100"
        debug="0"
        disableUploadTimeout="true"
        URIEncoding="UTF-8"
        port="80"
        redirectPort="8443"
        minSpareThreads="25"
        connectionTimeout="20000"
        maxSpareThreads="75"
        maxThreads="150">
    </Connector>

```
- Realm

``` 

    <Realm className="org.apache.catalina.realm.JDBCRealm"
        connectionName="tomcat"
        connectionPassword="Tomcat#1"
        connectionURL="jdbc:mysql://localhost/authority"
        driverName="org.gjt.mm.mysql.Driver"
        roleNameCol="role_name"
        userCredCol="user_pass"
        userNameCol="user_name"
        userRoleTable="user_roles"
        userTable="users"/>

```
