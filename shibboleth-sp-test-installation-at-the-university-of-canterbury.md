# Shibboleth SP Test Installation at the University of Canterbury

This page documents a test installation of a Shibboleth Service Provider (SP at the University of Canterbury.

This installation follows the MAMS recommendations for [manually installing a SP](http://www.federation.org.au/twiki/bin/view/Federation/ManualInstallSP), and the documentation below only describes what had been done 'differently' from the MAMS recommendations.

# Prerequisites

- We have a CentOS 5 system (equivalent to RHEL5)
- The default GCC installed is 4.1.1.  We *do* need a 3.x version (my experience from the AAF workshop), so 

``` 
yum install compat-gcc-34 compat-gcc-34-c++
```
- We now have `gcc34` and `g++34`
- Let's use these for compiling the SP: 

``` 
export CC=gcc34 CXX=g++34
```
- Let's also install C++ for the standard GCC installed (in case we need it...):

``` 
yum install gcc-c++
```
- We need apache development libraries: 

``` 
yum install httpd-devel
```
- We need CURL development libraries: 

``` 
yum install curl-devel
```

## Compiler selection justification

At the MAMS AAF workshop, Bruc Liong has strongly recommended to use a 3.x GCC C++ compiler.  He was referring to a number of bugs in the 4.1 GCC C++ compiler.  Due to these bugs, it is not possible to compile the set of libraries needed for Shibboleth SP with G++ 4.1.

When I tried bootstrapping the Shibboleth SP library chain with G++ 4.1, I could compile `log4cpp` and `Xerces`, but I got a compile error for `xml-security`: 

``` 

make[1]: Entering directory `/root/work/shib-gcc4/xml-security-c-1.2.1/src/canon'
g++  -O2 -DNDEBUG -Wall -fPIC -DLINUX -c -I/root/work/shib-gcc4/xerces-c-src_2_6_1/src -I../../include -o ../../lib/obj/XSECC14n20010315.o XSECC14n20010315.cpp
/root/work/shib-gcc4/xerces-c-src_2_6_1/src/xercesc/framework/XMLBuffer.hpp:257: warning: 'class xercesc_2_6::XMLBufferFullHandler' has virtual functions but non-virtual destructor
../../include/xsec/canon/XSECC14n20010315.hpp:127: error: extra qualification 'XSECC14n20010315::' on member 'init'
make[1]: *** [../../lib/obj/XSECC14n20010315.o] Error 1
make[1]: Leaving directory `/root/work/shib-gcc4/xml-security-c-1.2.1/src/canon'make: *** [compile] Error 2

```

When I compile the tool chain with `gcc34` and `g+``34`, `xml-security` compiles fine and I get up to compiling Shibboleth.  There I trigger another problem: Apache was compiled with gcc 4.1, and when `apxs` reports compile flags to use for compiling Apache modules, it includes flags that were introduced in gcc 4.x.  It is not possible to use gcc 4.1 to compile the module - a compile error is reported, either due to a similar bug in g+ 4.1, or due to an incompatibility between g++ 3.4 and 4.1.  In the end, the only way forward is to compile also the Apache module with gcc 3.4, and to remove the compile options not understood by gcc 3.4 (detailed in the following section).  This way, the whole compile task completes.

# Build and Install

- Create the target directory


>  mkdir /usr/local/shibboleth-sp/
>  export SHIB_SP_HOME=/usr/local/shibboleth-sp
>  mkdir /usr/local/shibboleth-sp/
>  export SHIB_SP_HOME=/usr/local/shibboleth-sp

- Add the SHIB_SP_HOME environment variable to `/etc/profile.d/shib.sh`.
- Download all source .tar.gz files to `/root/work`
- Follow the instructions for Building and Compiling
	
- Log4cpp: no changes
- Xerces: the `runConfigure` line has explicit references to `gcc` and `g+`.  Change these to `gcc34` and `g+34`:

``` 
./runConfigure -p linux -c gcc34 -x g++34 -r pthread -P $SHIB_SP_HOME
```
- xml-security: no changes
- opensaml: no changes
- Shibboleth SP: MAMS has already `shibboleth-sp-1.3f.tar.gz` available, but the ManualInstallSP wiki page still links to `shibboleth-sp-1.3e.tar.gz`. Use the 1.3f version.
		
- CentOS 5 comes with Apache 2.2 (package `httpd-2.2.3`), and the development configuration file name is `/usr/sbin/apxs`.  Change the module version and the apxs path in the `configure` step: 

``` 
./configure --prefix=$SHIB_SP_HOME --with-log4cpp=$SHIB_SP_HOME --enable-apache-22 --with-apxs22=/usr/sbin/apxs --disable-mysql
```
- Problem: `apxs -q CFLAGS` says to use flag `-fstack-protector`, not understood by gcc34
- Problem even worse: I cannot compile Shibboleth with g++ (4.1), has to be compiled with the same one as opensaml et al.
- Hack: remove {{-fstack-protector --param=ssp-buffer-size=4 -mtune=generic }}
- Surprise surprise: when compiling version 1.3f, the problem does not kick in.  Actually, it may be that the Apache module would use g++ for parts where needed, but could not find it - and it compiles well because I already have it now...?  Anyway, compiled.

# Configuring

- Installing on the same host as IdP
	
- Certificate already exists
- Time synchronization already configured (note that `ntpd` however sometimes unexpectedly dies)
- Note that the federation metadata must be fresh in *both* IdP and SP directories.
- The `/etc/init.d/shibboleth` script must have an extra line with a `chkconfig` directive, and the file must be quite adjusted to the RedHat environment from Debian (such as to use `daemon` instead of `start-stop-daemon`.
	
- Download the startup script from here:
		
- [RHEL-init-d-shibboleth.txt](attachments/RHEL-init-d-shibboleth.txt) (download)
- !RHEL-init-d-shibboleth.txt!
 (file information)
- Enable automatic startup with 

``` 
chkconfig --add shibboleth
```
- Start the service now with 

``` 
service shibboleth start
```

- I have created a single Apache configuration file for both loading the shibboleth module and for configuring the module, `/etc/httpd/conf.d/shib-sp.conf`
- It was not necessary to set the LD_LIBRARY_PATH module to load the Shibboleth module - so I have skipped the following recommendation (which should have gone to `/etc/apache2/envvars`).  If needed, the following can be added to `/etc/sysconfig/httpd`


>    SHIB_HOME=/usr/local/shibboleth-sp
>    LD_LIBRARY_PATH=${SHIB_HOME}/libexec:${SHIB_HOME}/lib
>    export LD_LIBRARY_PATH
>    SHIB_HOME=/usr/local/shibboleth-sp
>    LD_LIBRARY_PATH=${SHIB_HOME}/libexec:${SHIB_HOME}/lib
>    export LD_LIBRARY_PATH

# Metadata updates

The SP needs to periodically download metadata - and after each download, check that the XML document contains a correct signature from the `www.federation.org.au`.  As described at the [MAMS metadata update guide](http://www.federation.org.au/twiki/bin/view/Federation/UpdateMetadata), Shibboleth SP comes with a tool to do that (`siterefresh`) and MAMS provides the certificate used to sign the metadata.  We thus only get the certificate:

>  wget [http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/www.federation.org.au.pem](http://www.federation.org.au/twiki/pub/Federation/UpdateMetadata/www.federation.org.au.pem) -P /etc/certs

And create a cron job that would update the metadata periodically - `/etc/cron.hourly/idp-metadata`

``` 

#!/bin/bash

# get SHIB_HOME and SHIB_SP_HOME
. /etc/profile.d/shib.sh

export METADATA_URL=http://www.federation.org.au/level-1/level-1-metadata.xml
export SP_HOME=${SHIB_SP_HOME}
export OUTPUT_FILE=${SP_HOME}/etc/shibboleth/level-1-metadata.xml
## export SP_HOME=/usr/local/shibboleth-sp
## export OUTPUT_FILE=/usr/local/shibboleth-sp/etc/shibboleth/level-1-metadata.xml

$SP_HOME/sbin/siterefresh --url $METADATA_URL --cert /etc/certs/www.federation.org.au.pem --out $OUTPUT_FILE

```

Note that the `siterefresh` tool does not support the https protocol, so unlike for the [IdP](/wiki/spaces/BeSTGRID/pages/3818228985#ShibbolethIdPTestInstallationattheUniversityofCanterbury-Metadataupdates), we have to get the metadata via plain http (reasonably safe if we verify the signature afterwards - up to DOS intended network outage).

# Running and Testing

After protecting 

``` 
<Location /secure>
```

 with Shibboleth and restarting Apache, [https://idp-test.canterbury.ac.nz/secure/](https://idp-test.canterbury.ac.nz/secure/) is protected with Shibboleth and requires a login in the level-1 federation.... which is not so hard to get 🙂

In `shib-vhosts.conf`, the 443 virtual host section now also says:

``` 

     <Location /secure>
        AuthType shibboleth
        ShibRequireSession On
        require valid-user
     </Location>

```

I am further proceeding with [Shibbolizing an application](http://www.federation.org.au/twiki/bin/view/Federation/ShibbolizeApplication).  I have added Shibboleth protection also for 

``` 
<Location /jsp-examples>
```

, and I have JkMounted `/jsp-examples`.  In `proxy_ajp.conf`, add

>   ProxyPass /jsp-examples ajp://localhost:8009/jsp-examples

I have installed the [demo.jsp](http://www.federation.org.au/twiki/pub/Federation/ShibbolizeApplication/demo.jsp.txt) page and modified it as instructed on the [workshop page](http://www.federation.org.au/twiki/bin/view/Federation/Workshop_ShibbolizeApplication) (reset attribute values to `null` if their value is an empty String).
