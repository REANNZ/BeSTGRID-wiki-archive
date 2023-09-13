# Requesting Host Certificates

This page intends to give an easy - recipe like - introduction for the setup of Grid hosts.

This guide is based on the ARCS instructions, see here: [http://wiki.arcs.org.au/bin/view/Main/HostCertificates](http://wiki.arcs.org.au/bin/view/Main/HostCertificates)

# Basic Certificate Creation 

The process below outlines a basic (or "one off") process for creating a certificate on a designated host.

# Create a Certificate Request

The directory for the Grid host certificates is usually `/etc/grid-security`. In the following we are assuming, that this is also the current working directory for the execution of the given (OpenSSL) commands.

``` 

openssl req -new -nodes -keyout hostkey.pem -out hostcert_request.pem -newkey rsa:2048

```


>  openssl req new -nodes -keyout hostkey.pem -out hostcert_request.pem -newkey rsa:2048 -subj "$( openssl x509 -subject -noout -in /etc/grid-security/hostcert.pem | cut -d ' ' -f 2 )/emailAddress=$( openssl x509 -email -in /etc/grid-security/hostcert.pem -noout )"

Submit the `hostcert_request.pem` to the APAC CA as above. 

An alternative to that is to use the above command to ensure you have the identical CN details but to 

create a renewal request as though you were starting from scratch, as above, another option is to use

the script mentioned below.

Once the certificate has been approved and issued, download it and copy it to `/etc/grid-security/hostcert.pem` with the private key file (`hostkey.pem`) generated with the renewal request. 

Copy the new certificate `hostcert.pem` together with the private key `hostkey.pem` into any location the old certificate was copied - and make sure the permissions and ownership on the other files stay the same.


You may have to restart the services after updating the certificate 

- `globus-ws` on an NG2
- `apache` + `tomcat-55` on a GUMS server.
- `apache` + `irods` + `davis` on a iRODS server

# Retrieving/Installing the Certificate

After the certificate has been processed, you will be sent an eMail (under the above entered requester address). Follow the given link, and download the certificate (in PEM format). Install the certificate as described in the install guide for the setup.

# Advanced Certificate Creation 

Further tips, tricks, etc. to ease the process of certificate management can be found in this section, to aid the maintainer of (multiple) machines.

# Certificate Creation Script

Alternatively you can use the attached [Generate_request.sh](/wiki/download/attachments/3816950550/Generate_request.sh?version=1&modificationDate=1539354174000&cacheVersion=1&api=v2) script to generate request. Edit `EMAIL` and `INSTITUTION` values and run it as

``` 

# ./generate_request.sh hostname
Generating a 2048 bit RSA private key
.......................................+++
...........+++
writing new private key to 'hostname_key.pem'

```

For FQDN `hostname`, request is stored in `hostname_request.pem` and private key in `hostname_key.pem`

# Customising the local OpenSSL to give you sensible defaults

When one comes to request certificates using `OpenSSL` to create the request,

a vanilla install of an `openssl` package will see one prompted, with the

following defaults, to answer these questions:

``` 
Country Name (2 letter code) [GB]:
State or Province Name (full name) [Berkshire]:
Locality Name (eg, city) [Newbury]:
Organization Name (eg, company) [My Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

```

however, when working within BeSTGRID, not only does one not need to provide all

of the information asked for, but the defaults are obviously incorrect, a combination  

that can lead to some confusion.

It is possible to always be prompted as follows

``` 
Country Name (2 letter code) [NZ]:
Organization Name (eg, company) [BeSTGRID]:
Organizational Unit Name (eg, section) [Victoria University of Wellington]:
Common Name (eg, your name or your server's hostname) []:
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:

```

which provides a much more sensible set of defaults whilst removing the

unecessary questions that might cause confusion.

To achieve this, one merely needs to edit the file `/etc/pki/tls/openssl.cnf` (or equivalent for you OS)

The result of patching the file for use at VUW (`RHEL 5.4`, `openssl-0.9.8e-12.el5_4.1`) resulted in this unified diff, which may be informative:

``` 

--- /etc/pki/tls/openssl.cnf.orig    2010-03-03 16:13:13.000000000 +1300
+++ /etc/pki/tls/openssl.cnf    2010-03-03 16:29:15.000000000 +1300
@@ -133,25 +133,25 @@
 
 [ req_distinguished_name ]
 countryName                    = Country Name (2 letter code)
-countryName_default            = GB
+countryName_default            = NZ
 countryName_min                        = 2
 countryName_max                        = 2
 
-stateOrProvinceName            = State or Province Name (full name)
-stateOrProvinceName_default    = Berkshire
+#stateOrProvinceName           = State or Province Name (full name)
+#stateOrProvinceName_default   = Berkshire
 
-localityName                   = Locality Name (eg, city)
-localityName_default           = Newbury
+#localityName                  = Locality Name (eg, city)
+#localityName_default          = Newbury
 
 0.organizationName             = Organization Name (eg, company)
-0.organizationName_default     = My Company Ltd
+0.organizationName_default     = BeSTGRID
 
 # we can do this but it is not needed normally :-)
 #1.organizationName            = Second Organization Name (eg, company)
 #1.organizationName_default    = World Wide Web Pty Ltd
 
 organizationalUnitName         = Organizational Unit Name (eg, section)
-#organizationalUnitName_default        =
+organizationalUnitName_default = Victoria University of Wellington
 
 commonName                     = Common Name (eg, your name or your server\'s hostname)
 commonName_max                 = 64
@@ -166,7 +166,7 @@
 challengePassword_min          = 4
 challengePassword_max          = 20
 
-unstructuredName               = An optional company name
+#unstructuredName              = An optional company name
 
 [ usr_cert ]
 

```

and though obviously that patch is specific to VUW, the principles remain the same.

- modify `countryName_default` to be `NZ`
- comment out `stateOrProvinceName` and its default
- comment out `localityName` and its default
- modify `0.organizationName_default` to be `BeSTGRID`
- uncomment `organizationalUnitName_default` and make it be your institution
- comment out `unstructuredName`

Along similar lines, if all certifcate requests are made using a "catch-all" email

address then an `emailAddress_default` line could be added into the file.

## Using a custom OpenSSL config file alongside the default

There may be reasons why one would wish to leave the default OpenSSL config file

as it is but maintain a customised version for use when generating APAC cert 

requests.

OpenSSL allows one to do this by use of its `-config alternative_file` option.

Instead of patching the default file as suggested above, you would take a copy of the

default and tailor that with any required customisations and then, instead of using 

the default command above, invoke `openssl` as follows

``` 

openssl req -new -nodes -keyout hostkey.pem -out hostcert_request.pem -newkey rsa:2048 -config /path/to/alternative/file

```

so as to be given the defaults and cut down on the data entry.

This would probably be of most benefit should a site admin wish to generate all requests, for

the various grid infrastructure machines that use APAC (or indeed other issuing authority) 

certificates at their site, from the one machine.

That machine would then have, eg

``` 

openssl-ng2.cnf
openssl-nggums.cnf
openssl-ngdata.cnf
openssl-idp.cnf

```

in some location, all preconfigured with the required defaults for each host, allowing for a simple invocation,

against the relevant config file, when the time comes to renew a certifcate.

It is then possible to invoke the request with something as simple as

``` 

# openssl req -new -nodes -out hostcert-idp_req.pem -config /path/to/openssl-idp.cnf
Generating a 2048 bit RSA private key
.........................................................................................+++
.........................+++
writing new private key to 'hostkey-idp.pem'

```

where the name of the key and the RSA bit-size are set within the alternative config file.

## Default permissions on the key file created are 644, not 600

It appears that the default permissions on the key file created are 644 whereas, when you copy it into place

youl'll want them to be 600

It may be useful to create an empty file with the name of the key and set the permissions of it to `600` ahead of 

the request creation. 

The request creation will overwrite the empty file but will maintain the permissions.
