# Shibboleth Service Provider Setup - RHEL5.3

# Prerequisites

This guide only applies to Red Hat Enterprise Linux Server release 5.3 (Tikanga).

This guide is written by Jun Huh, and the guide begins at a point where the machine already has the following installed:

- Apache 2 with SSL module
- RPM Package Manager
- Drupal 6.13
- Shibboleth 2 SP, without any configuration done

References:

- [Native SP Installation](https://spaces.internet2.edu/display/SHIB2/NativeSPLinuxInstall)
- [Shibboleth Service Provider Setup - RHEL4](shibboleth-service-provider-setup-rhel4.md) for references on firewall configuration and SSL setup on RHEL4.

# Installation of Shibboleth Service Provider 2

- Download the following binary packages:

``` 

curl -O http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/2.2.1/RPMS/i386/RHE/5/log4shib-1.0.3-1.1.i386.rpm \
     -O http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/2.2.1/RPMS/i386/RHE/5/xerces-c-3.0.1-5.1.i386.rpm \
     -O http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/2.2.1/RPMS/i386/RHE/5/xml-security-c-1.5.1-3.2.i386.rpm \
     -O http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/2.2.1/RPMS/i386/RHE/5/xmltooling-1.2.2-1.i386.rpm \
     -O http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/2.2.1/RPMS/i386/RHE/5/opensaml-2.2.1-1.i386.rpm \
     -O http://shibboleth.internet2.edu/downloads/shibboleth/cppsp/2.2.1/RPMS/i386/RHE/5/shibboleth-2.2.1-2.i386.rpm

```

- Install all packages at once:

``` 

rpm -ivh log4shib-1.0.3-1.1.i386.rpm \
    xerces-c-3.0.1-5.1.i386.rpm \
    xml-security-c-1.5.1-3.2.i386.rpm \
    xmltooling-1.2.2-1.i386.rpm \
    opensaml-2.2.1-1.i386.rpm \
    shibboleth-2.2.1-2.i386.rpm

```

# Configurations of Service Provider

## Basic Service Provider Configuration

- Configure the Service Provider by editing the shibboleth2.xml (located at /etc/shibboleth/)

- Download the example [Shibboleth2.xml](shibboleth2xml.md).

## Federation Metadata

### How to add an Identify Provider to a Service Provider

### How to add a Service Provider to an Identify Provider

# Shibboleth Daemon

- Check the Shibboleth configuration with the Shibboleth Daemon

``` 
root# /usr/sbin/shibd -t
```

- start the Shibboleth Daemon

``` 
root# /etc/init.d/shibd start
```

# Appendix

- [Shibboleth2.xml](shibboleth2xml.md)
