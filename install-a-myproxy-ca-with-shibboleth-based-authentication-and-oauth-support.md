# Install a MyProxy CA, with Shibboleth Based Authentication and OAuth Support

These instructions detail how to set up a system that can be used to issue short lived grid certificates based on a users shibboleth login. The original purpose of these certificates is to enable authentication with Globus, and subsequent access to the DataFabric endpoints inside Globus. In addition to this, such a server can be used to enable access to any other grid resource based on a shibboleth login.

The glue used to bind the different components of this server together is provided by the [OAuth for MyProxy Server](http://grid.ncsa.illinois.edu/myproxy/oauth/server/index.xhtml). A custom extension for this has been developed and published as [oa4mp-shibboleth](https://github.com/nesi/oa4mp-shibboleth).

The installation uses 2 servers, they will be referred to as follows in the instructions:

- Server `myproxyplusca` runs myproxy in CA mode
- Server `myproxyplus` runs OAuth protected by shibboleth to allow other web services to retrieve certificates.

Typically, `myproxyplusca` will be running in an elevated security zone, i.e. without direct connection to the internet, and only be reachable from `myproxyplus`. As a consequence of this, periodical jobs that require an internet connection (operating system updates, fetch-crl...) will not work.

# Preliminary steps


- On `myproxyplusca`:


>   yum install myproxy myproxy-server myproxy-admin myproxy-doc globus-simple-ca perl-Text-CSV perl-Email-Valid
>   yum install myproxy myproxy-server myproxy-admin myproxy-doc globus-simple-ca perl-Text-CSV perl-Email-Valid

- On `myproxyplus`:


>   yum install httpd httpd-tools mod_ssl java-1.6.0-sun-compat tomcat6 httpd-devel libtool gcc-c++ jglobus
>   yum install httpd httpd-tools mod_ssl java-1.6.0-sun-compat tomcat6 httpd-devel libtool gcc-c++ jglobus


# Install Certificates

- On all servers:


>   yum install igtf-ca-certs
>   yum install igtf-ca-certs


# Configure MyProxy to act as a CA


- On `myproxyplus`:
	
- Install `myproxyplus`' CA cert into `/etc/grid-security/certificates`
- **Create symlink **`*certificate_hash``.0` to CA cert, hash can be calculated by

``` 

  openssl x509 -in <ca certificate> -noout -hash

```

# Install Shibboleth


# Configure tomcat


# Install oa4mp-shibboleth

## Build .war file

This should be done on any workstation with a functioning installation of git and maven. Due to maven downloading a large number of components during the build, doing this on a production host requires a firewall configuration that allows all outgoing connections on ports 80, 443.

- Get source:


>   git clone [https://github.com/nesi/oa4mp-shibboleth](https://github.com/nesi/oa4mp-shibboleth) oa4mp-shibboleth
>   git clone [https://github.com/nesi/oa4mp-shibboleth](https://github.com/nesi/oa4mp-shibboleth) oa4mp-shibboleth

- Build


>   mvn clean install
>   mvn clean install

The resulting `oauth-shibboleth-``version``.war` file can be found in the `target` directory.

## Install on server


- On `myproxyplusca`:
	
- Create directory `/opt/myproxy-ca`
- Create file `/opt/myproxy-ca/myproxy-mapapp.pl` (this file can pretty much be copied from `doc/myproxy-mapapp.pl` from oa4mp-shibboleth, except for the my `$namespace = "/DC=nz/DC=ac/DC=canterbury/DC=myproxyplusdev";` line:

``` 

#!/usr/bin/perl -T -w -I /opt/myproxy-ca

=head1 myproxy-mapapp.pl

mapapp / extapp script for myproxy to build DN / certificate extensions from 
attributes passed by myproxy-oauth as username.
myproxy-oauth allows request attributes to be submitted as username in CSV format.
For example, these attributes could come from an authentication
that the user performed with shibboleth.

This script can be invoked with two different names:

myproxy-mapapp.pl: print DN for certificate
myproxy-extapp.pl: print extensions for certificate

MyProxy and this script handle only OpenSSL-formated DNs - e.g.:
/C=OS/O=Organization/CN=My Common Name

=head2 Usage

myproxy-mapapp.pl [<username>]
myproxy-extapp.pl [<username>]

=head2 Return Value

Zero on success, printing DN / certificate extensions to STDOUT; one on error.

=head2 Version

version 1.0.0

=cut

######################################################################
#
# My DN namespace prefix

my $namespace = "/DC=nz/DC=ac/DC=canterbury/DC=myproxyplusdev";


######################################################################
#
# 

use Sys::Syslog;
use File::Basename;
use Text::CSV;
use Switch;
use Email::Valid;

######################################################################
#
# Set up logging

my $runas = basename($0);
openlog($runas, "pid", "auth");

######################################################################
#
# Get requested DN and validate

my $input = $ARGV[0];

syslog("info", "input: \"%s\", running as \"%s\"", $input, $runas);

if (!defined($input) || ($input eq ""))
{
    syslog("err", "Missing argument");
    exit(1);
}

if ($input =~ m/^\/(.*)$/) {
  $input = $1
} else {
    syslog("err", "Invalid argument format: \"%s\"", $input);
    exit(1);
}

my $csv = Text::CSV->new();
if (!$csv->parse($input))
{
    syslog("err", "Error (%s) parsing input CSV: \"%s\"", "" . $csv->error_diag(), $input);
    exit(1);
}

######################################################################
#
# Extract attributes

my %fields = $csv->fields();
my $attribute;
my $value;
while (($attribute, $value) = each(%fields)) {
  syslog("info", "Attribute: \"%s\", value \"%s\"", $attribute, $value);
}

######################################################################
#
# Generate output

my $result;
switch ($runas) {
  case "myproxy-mapapp.pl" {
    if (!defined($fields{"organisation"})
      || !defined($fields{"commonName"})
      || !defined($fields{"sharedToken"})) {
      syslog("err", "Error: Required field for DN missing: \"%s\"", $input);
      exit(1);
    }

    $result = $namespace . "/O=" . $fields{"organisation"} . "/CN=" . $fields{"commonName"} . " " . $fields{"sharedToken"} . "\n";

    syslog("info", "DN: \"%s\"", $result);
  }
  case "myproxy-extapp.pl" {
    if (defined($fields{"mail"})) {
        $result = $result . "subjectAltName=email:" . $fields{"mail"} . "\n";
    }
    if (defined($fields{"assurance"})) { # assertion level
        $result = $result . "1.3.6.1.4.1.5923.1.1.1.11=ASN1:UTF8String:" . $fields{"assurance"} . "\n";
    }
    if (defined($fields{"affiliation"})) { # unscoped affiliation
        $result = $result . "1.3.6.1.4.1.5923.1.1.1.1=ASN1:UTF8String:" . $fields{"affiliation"} . "\n";
    }
    if (defined($fields{"sharedToken"})) {
        $result = $result . "1.3.6.1.4.1.27856.1.2.5=ASN1:UTF8String:" . $fields{"sharedToken"} . "\n";
    }
    if (defined($fields{"principalName"})) { # eppn
        $result = $result . "1.3.6.1.4.1.5923.1.1.1.6=ASN1:UTF8String:" . $fields{"principalName"} . "\n";
    }

    syslog("info", "extensions: \"%s\"", $result);
  }
}

# All seems well, print out result so MyProxy will pick it up and return
# success.

print $result;
exit(0);

### Local Variables: ***
### mode:perl ***
### End: ***
######################################################################

```
- Create symlink `/opt/myproxy-ca/myproxy-extapp.pl` pointing to `/opt/myproxy-ca/myproxy-mapapp.pl`
- Edit `/etc/myproxy-server.config`, add:

``` 

certificate_mapapp /opt/myproxy-ca/myproxy-mapapp.pl
certificate_extapp /opt/myproxy-ca/myproxy-extapp.pl

```

## Workaround SSL configuration issues

To work around [a bug in oa4mp](https://github.com/nesi/oa4mp-shibboleth/issues/1) (using legacy "SSL" protocol to connect to MyProxy server), re-enable SSLv3 in Java configuration (disabled in OpenJDK 1.7.0.79): edit jre/lib/security/java.security and comment out the line that says: 

``` 
jdk.tls.disabledAlgorithms=SSLv3
```

# Configure apache


# Register and Approve a client

This has to be done for every service that should be allowed to redirect users to the oa4mp server for authentication / certificate retrieval.

- Point a web browser to [https://myproxyplus/oauth/register](https://myproxyplus/oauth/register) and follow instructions
- In `/opt/oa4mp`, on `myproxyplus` do


>   wget [http://svn.code.sf.net/p/cilogon/code/tags/latest/server/oa4mp-approver.jar](http://svn.code.sf.net/p/cilogon/code/tags/latest/server/oa4mp-approver.jar)
>   java -jar oa4mp-approver.jar -cfg server-cfg.xml
>   wget [http://svn.code.sf.net/p/cilogon/code/tags/latest/server/oa4mp-approver.jar](http://svn.code.sf.net/p/cilogon/code/tags/latest/server/oa4mp-approver.jar)
>   java -jar oa4mp-approver.jar -cfg server-cfg.xml

- Follow instructions

- If the client to be added is Globus (formerly Globus Online), the oa4mp server will also have to be registered as a myproxy-oauth server with Globus. Please contact Globus support to receive instructions on how to do this.
