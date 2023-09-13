# Setup PRIMA on IBM p520

As a part of deploying the GUMS server, the GridFTP server running on the p520 had to switch from using a `grid-mapfile` to using PRIMA for authorization callouts to the GUMS server.  While a Globus has binaries available for AIX on Power5+, PRIMA has not, and I had to compile PRIMA from source code.  It has been a very painful process.  Below please find the essence of my findings, which should hopefully be sufficient to successfully compile PRIMA on a similar system.  For more information, please contact [me](https://reannz.atlassian.net/wiki/404?key%3Dbestgrid.org%3Bsearch%3Fq%3DUser__Vladimir) by email and I may send you the complete notes.

# General notes

The PRIMA authorization module for Globus is the last piece in a stack of a number of packages - some written in C, most in C++.  The packages are:

- curl
- log4cpp
- xerces-c
- xml-security-c
- opensaml
- prima-saml-support
- prima-soap-support
- prima-logger
- prima-clients
- prima-autz-module

The Globus GridFTP server and libraries are compiled as 64-bit binaries with `xlc`, globus flavor `vendorcc64`.  As our installation of GCC on AIX cannot produce 64-bit binaries anyway, we have to compile with with xlc, in 64-bit mode.

Additional important considerations are:

- When linking a C program which uses C++ libraries I have to use the C++ compiler xlC.  Otherwise, with just "xlc", in the resulting code, all method calls from one C++ library to another fail with "Illegal instruction" - the methods are called at a nil address.
- To use dynamic casts in C++, I have to compile all units with `-qrtti`.  Otherwise, the `dynamic_cast` operator always fails - and the compiler emits only a mere warning: 

``` 
"prima_saml_support.cpp", line 334.17: 1540-2411 (W) A dynamic cast is present, but the correct RTTI option is not specified.
```
- These two lessons learnt are documented also on the [UCSC wiki PRIMA page](http://cantmc.canterbury.ac.nz/UCSCadm/AppsPRIMA).
- It may be necessary to compile the code as Position Independent Code (PIC) - at least I did so when PRIMA was crashing (due to the problems above) and I was trying to figure out why.  To compile PIC code with xlc, use the `-qpic` option.
- Globus is linked against it's own version of OpenSSL (specific to its own flavor, `vendorcc64`).  I have compiled PRIMA against the system-wide OpenSSL, installed in `/opt/freeware`.  When the PRIMA module ins loaded into the Globus GridFTP server, two versions of OpenSSL are present in one address space - but that does not seem to pose a problem.  Luckily...

# Getting PRIMA

The starting point for getting PRIMA is [http://computing.fnal.gov/docs/products/voprivilege/prima/nmi_build.html](http://computing.fnal.gov/docs/products/voprivilege/prima/nmi_build.html)

PRIMA comes in two flavors - NMI and OSG.  In the end, I found it easier and more suitable to get working NMI PRIMA, so I installed that one, and that's what the instructions focus on.  The OSG build looks like not so actively maintained.  However, it would probably compile as well - and if I had known all that I know when I tried compiling it, I would likely have succeeded as well.  But the p520 has NMI PRIMA installed.

To fetch NMI PRIMA:

1. First fetch the build script - by following the the link to the [FNAL CVS](http://cdcvs0.fnal.gov/cgi-bin/public-cvs/cvsweb-public.cgi/privilege/prima/build/nmi_build/prepare_nmi.sh), and clicking Download for the most recent revision.
2. Make sure your machine is allowed to open outgoing connections to an CVS server (use Internet Enabler on UoC campus).
3. Edit `prepare_nmi.sh`, comment out the line `rm -fr "$outdir/cvs_nmi"` (cleanup at the end of the file)
4. Set PATH so thet GNU tar is first:

``` 
PATH=/usr/local/bin:$PATH
```
5. Run `prepare_nmi.sh`:

``` 
sh prepare_nmi.sh -e vladimir.mencl@canterbury.ac.nz
```
6. This creates `prima_nmi.tar`.  Untar this file, untar archives inside (`*.tar.gz`)

# Preparing the build

PRIMA comes with a build script, `fnal-build.sh`.  The script would untar all the packages, and for each of them, run configure, make, make install, with the customized settings the authors considered appropriate.  The script would likely successfully compile all packages on a Linux x86 system, but would stop at each failure, and would have to be restarted from the beginning (rebuilding all packages).  The script can be also called to compile just one package with the `-p` parameter - but that would again restart the build process for the package, starting from `configure`.

I recommend using the script to get as far as possible on the first try, and than proceeding by hand, manually invoking the commands the script would call.

Before starting the script, I made the following changes:

- Change the following configuration variables:


>  export INSTALLDIR="/usr/local/pkg/globus/4.0.6/prima"
>  export OPENSSL_DIR="/opt/freeware"
>  export GLOBUS_LOCATION=/usr/local/pkg/globus/version
>  export GPT_LOCATION=/usr/local/pkg/globus/version
>  export PRIMA_GCC_VERSION=vendorcc64
>  export INSTALLDIR="/usr/local/pkg/globus/4.0.6/prima"
>  export OPENSSL_DIR="/opt/freeware"
>  export GLOBUS_LOCATION=/usr/local/pkg/globus/version
>  export GPT_LOCATION=/usr/local/pkg/globus/version
>  export PRIMA_GCC_VERSION=vendorcc64

- Comment out the following variables (all their occurrences):


>  ##export GCC_DIR=/usr
>  ##export  CC=$GCC_DIR/bin/gcc
>  ##export CXX=$GCC_DIR/bin/g++
>  ##export GCC_DIR=/usr
>  ##export  CC=$GCC_DIR/bin/gcc
>  ##export CXX=$GCC_DIR/bin/g++

- Use `gmake` instead of `make` for making and installing the packages
- Changed all references to the `gcc64dbg` flavor (that was more in the OSG build).
- Comment out patching of Makefiles
- Add `-I$OPENSSL_DIR/include` to `CPPFLAGS` for opensaml.
- Pass `-c $CC -x $CXX` instead of hard-coded `gcc` and `g++` to configure for xerces-c.
- Change the variable passed to configure for log4cpp to `CXXFLAGS=\"-qthreaded\""`
- Patch configure for log4cpp not to use a macro definition that would conflict with a later definition of the macro:

``` 
sed -e 's/^#define HAVE_STDINT_H$/&1 1/'
```
- Note that AIX `sed` does not have in-place editing...

# Setting the build environment

To compile thread safe code, in 64-bit mode, with the right compilers, and with the right directories passed, I set the following environment variables - which hopefully can be kept throughout the build process:

>  export CC=xlc_r CXX=xlC_r OBJECT_MODE=64
>  export OPENSSL_DIR="/opt/freeware"
>  export OPENSSL=/opt/freeware
>  export CPPFLAGS="-I$OPENSSL_DIR/include"
>  export LDFLAGS="-L$OPENSSL_DIR/lib -lssl -lcrypto"
>  export INSTALLDIR=/usr/local/pkg/globus/4.0.6/prima
>  export OPENSAML_LOCATION=$INSTALLDIR
>  export PRIMA_LOCATION=$INSTALLDIR
>  export XERCESCROOT=$INSTALLDIR 

# Compiling curl

The only critical issue is setting the openssl configuration right.  With the above environment configuration, the only steps to compile curl should be:

>  cd ./curl-7.11.1
>  ./configure --prefix=$INSTALLDIR --without-ca-bundle --enable-static=no --with-ssl=$OPENSSL_DIR
>  gmake
>  gmake install

# Compiling log4cpp

Getting a bit tougher: two things to change with respect to the original build:

- The parameter to xlC to generate thread-safe code is `-qthreaded`, not `-pthread`.
- Configure must use consistent definitions of `HAVE_STDINT_H`, define it as `1`, not just an empty (true) definition.

``` 
sed -e 's/^#define HAVE_STDINT_H$/&1 1/' configure > configure.fixed
```

>  ./configure --prefix=$INSTALLDIR --with-pthreads=yes --enable-static=no --enable-doxygen=no CXXFLAGS=\"-qthreaded\"
>  gmake
>  gmake install

# Compiling xerces-c

For compiling xerces, set 

``` 
export XERCESCROOT=/hpc/home/vme28/grid/prima/nmi/nmi/nmi-prima/xerces-c-src_2_6_0
```

>  cd ./xerces-c-src_2_6_0/src/xersesc
>  ./runConfigure -p linux -c $CC -x $CXX -r pthread -b 64 -P $INSTALLDIR
>  gmake
>  gmake install

If you get a build error reporting that library `xlopt` was not found, add `-L /usr/vac/lib` to `obj/Makefile`

# Compiling xml-security-c

Getting even tougher:

Problem #1: configure script reports AIX as unsupported platform

Solution: manually edit "configure" and define AIX platform. Copy the section with linux definition, and:

- change .so to .a
- remove -DLINUX from all variables
- clean up PLATFORM OPTIONS
- change PIC to "-qpic"

``` 

*-*-aix*)       platform=AIX 
      shlibsuffix=.a
      lib_name="lib${PACKAGE_TARNAME}.a.${package_lib_version}"
      lib_major_name="lib${PACKAGE_TARNAME}.a.${package_lib_major}"
      lib_short_name="lib${PACKAGE_TARNAME}.a"
      #if test "x${CXX}" = "xg++"; then
      if test "x${ac_cv_cxx_compiler_gnu}" = "xyes"; then
              PLATFORM_OPTIONS="-Wall"
              PIC="-fPIC"
      else
              # Not sure if these will work - only tested with g++
              PIC="-qpic"
              PLATFORM_OPTIONS=""
      fi
      # Should use -D_REENTRANT - but not yet OK
      PLATFORM_OPTIONS="${PLATFORM_OPTIONS} ${PIC}"
      CC1="${CXX} ${CXXFLAGS} ${PLATFORM_OPTIONS}"
      CC4="${CC} ${CXXFLAGS} ${PLATFORM_OPTIONS}"
      MAKE_SHARED="${CXX} ${CXXFLAGS} -o \$(LIBNAME) -qmkshrobj ${PIC}"
      LINK="${CXX} ${CXXFLAGS} ${PIC}"
      LINK_COMMAND_1="(cd \$(LIB_DIR) ; rm -f \$(LIBMAJORNAME) ; \$(LN_S) \$(LIBNAME) \$(LIBMAJORNAME))"
      LINK_COMMAND_2="(cd \$(LIB_DIR) ; rm -f \$(LIBSHORTNAME) ; \$(LN_S) \$(LIBNAME) \$(LIBSHORTNAME))"
      INSTALL_COMMAND_1="\$(INSTALL) \${THISLIB} \${libdir}"
      INSTALL_COMMAND_2="\$(RM) \${libdir}/\${LIBMAJORNAME} && \$(LN_S) \${LIBNAME} \${libdir}/\${LIBMAJORNAME}"
      INSTALL_COMMAND_3="\$(RM) \${libdir}/\${LIBSHORTNAME} && \$(LN_S) \${LIBNAME} \${libdir}/\${LIBSHORTNAME}"
  ;;

```

Problem #2: the package comes with `install-sh` that can only install one file at a time, but is called from Makefiles to install multiple files at a time.  When not solved, only a fraction of header files are installed.

Solution: extend `install-sh` to handle multiple files.

``` 

--- install-sh-orig     2003-02-02 23:48:17.000000000 +1300
+++ install-sh  2008-03-27 15:42:56.000000000 +1300
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # install - install a program, script, or datafile
 # This comes from X11R5 (mit/util/scripts/install.sh).
@@ -54,6 +54,25 @@
 dst=""
 dir_arg=""
 
+# VM: extending this script to handle multiple source arguments.
+# I'm using bash arrays for that.
+# src_cnt holds the number of sources found, and src_name will
+# hold the source names (passed as multiple arguments)
+
+# When the first argument is found, it would be assumed to be a source
+# Each time a new argument is found, it would first be first assumed to be
+# the destination, but if a subsequent argument is found, the previous 
+# destination would be re-considered to be a source and the new argument
+# would become the new destination.
+# The current argument parsing code is flawed and broken, as it does
+# not consume the argument to the -d parameter when the parameter is
+# found, but -d is merely recorded in a boolean flag and it is assumed
+# that the last argument would remain as destination.
+# Luckily, this script uses (in xml-security-c) a -d only to create a
+# single directory - I don't have to do any special handling for dir_arg.
+
+src_cnt=0
+
 while [ x"$1" != x ]; do
     case $1 in
        -c) instcmd="$cpprog"
@@ -94,9 +113,16 @@
        *)  if [ x"$src" = x ]
            then
                src=$1
+                src_cnt=1
+                src_names[0]=$1
            else
                # this colon is to work around a 386BSD /bin/sh bug
                :
+                if [ -n "$dst" ]
+                then
+                  src_names[$src_cnt]=$dst
+                  src_cnt=`expr $src_cnt + 1`
+                fi
                dst=$1
            fi
            shift
@@ -104,6 +130,16 @@
     esac
 done
 
+src_idx=0
+dst_orig=$dst
+# have to save dst - it gets base filename appended in each iteration
+while [ $src_idx -lt $src_cnt ] ; do
+  src=${src_names[$src_idx]}
+  src_idx=`expr $src_idx + 1`
+  dst=$dst_orig
+  ### DEBUG: echo "Installing: $src to $dst"
+
+
 if [ x"$src" = x ]
 then
        echo "install:  no input file specified"
@@ -245,7 +281,9 @@
        $doit $rmcmd -f $dstdir/$dstfile &&
        $doit $mvcmd $dsttmp $dstdir/$dstfile 
 
-fi &&
+fi || exit $?
+#&&
 
+done
 
 exit 0

```

Problem #3: xtest/xtest.cpp fails to compile: not found class XSECCryptoKeyHMAC

Solution: add extra include

``` 
#include <xsec/enc/XSECCryptoKeyHMAC.hpp>
```

Problem #4: tools/checksig/checksig.cpp won't compile, needs `-DHAVE_OPENSSL -I/opt/freeware/include`

>  cd ./xml-security-c-1.1.0.1/src
>  ./configure --prefix=$INSTALLDIR --without-xalan
>  gmake
>  gmake install

# Compiling opensaml

Gets again tougher.  

Problem: Some versions of opensaml (OSG and opensaml-1.0) report a syntax error in saml.h

Solution: Edit `saml.h`, move the definition of class QName a bit up, before it's first use.

Problem: All versions of opensaml trigger the following compiler error in `SAMLPOSTProfile.cpp` in version 8.0.0.0 of XLC, and it is necessary to upgrade (version 8.0.0.18 is fine):

``` 
xlC_r: 1501-230 Internal compiler error; please contact your Service Representative
```

Solution: Upgrade XLC (VAC backend) to at least 8.0.0.18

Problem: `gmake install` fails: nested makefiles call "mkinstalldirs" from top-level opensaml dir (even though top-level Makefile calls install-sh)

Solution: create opensaml/mkinstalldirs invoking just `mkdir -p "$@"`

Problem: gmake re-runs configure (as a dependency to `Makefile` by calling `./config.status --recheck`) and configure fails with message: `"no suitable ld found in PATH"`

Solution: pass `CONFIG_STATUS_DEPENDENCIES=""` to all gmake invocations.

Problem: libsaml.a would be created just as an archive of static (not shared) object files.

Solution: edit `libtool` and override the variable as follows.  Sorry, I could not get the compile dependencies in the *old-style* command, so linker options for saml are hard-coded in this libtool line:

``` 

old_archive_cmds="\$CXX -qmkshrobj -o \$output_objdir/\$libname.so\$major \$oldobjs \$old_deplibs \$linker_flags \$compiler_flags -lxerces-c -lxml-security-c -llog4cpp -lcurl -lssl -lcrypto -L/opt/freeware/lib -L/usr/local/pkg/globus/version/prima/lib ~\$AR -crlo \$objdir/\$libname\$release.a \$objdir/\$libname.so\$major"

```

>  cd ./opensaml
>  ./configure --prefix=$INSTALLDIR --with-curl=$INSTALLDIR --with-log4cpp=$INSTALLDIR --with-xerces=$XERCESCROOT --with-xmlsec=$INSTALLDIR --with-openssl=$OPENSSL_DIR -C
>  gmake CONFIG_STATUS_DEPENDENCIES=""
>  gmake install CONFIG_STATUS_DEPENDENCIES=""

# Compile prima-logger

Edit Makefile.in: remove GCC-specific options `-Wp,-MD` (2x)

>  ./configure --prefix=$INSTALLDIR
>  gmake
>  gmake install

# Compile prima-saml-support

Edit Makefile.in: remove GCC-specific options `-Wp,-MD` (4x)

>  export OPENSAML_LOCATION=$INSTALLDIR
>  ./configure --prefix=$INSTALLDIR
>  gmake
>  gmake install

Note: may need editing Makefile.in to add `-lxerces-c -lxml-security-c -llog4cpp -lcurl`

# Compiling prima-soap-support

Problem: the package does not include a Makefile.in and would need more of the GNU autoconf/automake tools installed: the command-line to configure the package would be as follows (and fails with warnings (LIBTOOL support missing) and does not generate Makefile.in):

>  aclocal && autoconf -i && automake -a && ./configure --prefix=$INSTALLDIR"

The package prima-saml-support has a very similar Makefile.am - let's handycraft Makefile.in for prima-soap-support from the one shipped with prima-saml-support, by adjusting it to the following differences:

- libraries: libprima_saml_support.la=>libprima_soap_support.la
- SOURCES: var_name, prima_soap_client.c soapC.c soapClient.c stdsoap2.c
- NO LDFLAGS
- headers: prima_soap_client.h
- includes:  -I$(PRIMA_LOCATION)/include -DWITH_OPENSSL
- libprima_soap_support_la_OBJECTS = prima_soap_client.lo soapC.lo soapClient.lo stdsoap2.lo
- change LIBTOOL to ./libtool
- Touch the following files to make the build system happy:


>  touch configure.in
>  touch Makefile.in
>  touch Makefile
>  touch configure.in
>  touch Makefile.in
>  touch Makefile

- Remove Makefile from all-am:
- get libtool from prima-saml-support
- get mkinstalldirs from osg-opensaml (or just use `mkdir -p "$@"`)

Fingers crossed, run

>  export PRIMA_LOCATION=$INSTALLDIR
>  ./configure --prefix=$INSTALLDIR"
>  gmake
>  gmake install

If the build fails when it would link the libraries (worked for me on first build but failed when I started over), well, sorry, I just created the libraries manually with:

>  xlC_r -qmkshrobj -o libprima_soap_support.so.0 prima_soap_client.o  soapC.o soapClient.o stdsoap2.o -lssl -lcrypto -L/opt/freeware/lib -lprima_logger -L/usr/local/pkg/globus/version/prima/lib/
>  ar -rv libprima_soap_support.a libprima_soap_support.so.0 

And continued with

>  gmake install

# Compile prima-clients

Edit Makefile to link with the C++ compiler (and pass all needed libraries):

>  **$(CXX)** -g -o $@ $^ -L$(PRIMA_LOCATION)/lib -lprima_soap_support -lprima_saml_support **-lsaml -lxerces-c -lxml-security-c -llog4cpp -lcurl -lprima_logger**

 gmake

>  gmake install

Test gums_map_args with:

>  /usr/local/pkg/globus/version/prima/bin/gums_map_args /usr/local/pkg/globus/version/prima/etc/opensaml/ /etc/grid-security/certificates/ '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=hpcgrid1.canterbury.ac.nz' /etc/grid-security/hostcert.pem /etc/grid-security/hostkey.pem [https://nggums.canterbury.ac.nz:8443/gums/services/GUMSAuthorizationServicePort](https://nggums.canterbury.ac.nz:8443/gums/services/GUMSAuthorizationServicePort) "/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl"

Or, for easier readability:

>  /usr/local/pkg/globus/version/prima/bin/gums_map_args                                 \
>      /usr/local/pkg/globus/version/prima/etc/opensaml/                                 \
>      /etc/grid-security/certificates/                                                  \
>      '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=hpcgrid1.canterbury.ac.nz'       \
>      /etc/grid-security/hostcert.pem /etc/grid-security/hostkey.pem                    \
>      [https://nggums.canterbury.ac.nz:8443/gums/services/GUMSAuthorizationServicePort](https://nggums.canterbury.ac.nz:8443/gums/services/GUMSAuthorizationServicePort)   \
>      "/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl"

# Compile prima-autz-module

Problem: Globus headers (`include/vendorcc64/globus_config.h`) turn on large file support (64-bit offsets), but system headers included before the support is turned on would introduce conflicting definitions, and the compile would fail with:

>  "/usr/include/unistd.h", line 171.17: 1506-343 (S) Redeclaration of lseek64 differs from previous declaration on line 169 of "/usr/include/unistd.h".
>  "/usr/include/unistd.h", line 171.17: 1506-050 (I) Return type "long long" in redeclaration is not compatible with the previous return type "long".
>  "/usr/include/unistd.h", line 171.17: 1506-377 (I) The type "long long" of parameter 2 differs from the previous type "long".

Solution: Turn large file support for the whole module:

>  export CFLAGS="-g -qpic -qrtti -D_LARGE_FILES -D_LARGE_FILE_API"
>  export CXXFLAGS="$CFLAGS"

 ./configure --prefix=$INSTALLDIR --with-flavor=vendorcc64

>  gmake
>  gmake install

# Configuring and activating PRIMA

This is the last and easiest bit - keep fingers crossed PRIMA will link fine.

- Configure Globus to use the PRIMA module for authorization: create `/etc/grid-security/gsi-authz.conf` with content based on the following sample (with proper path to the PRIMA library substituted): 

``` 
globus_mapping /usr/local/pkg/globus/version/prima/lib/libprima_authz_module_vendorcc64 globus_gridmap_callout
```
- Configure the PRIMA authorization module: create `/etc/grid-security/prima-authz.conf` based on what PRIMA installs on Linux x86 VDT machines, changing the configuration as needed - this is the configuration file that works for me, stripped of all comments:

``` 

imsContact https://nggums.canterbury.ac.nz:8443/gums/services/GUMSAuthorizationServicePort
issuerCertDir  /etc/grid-security/vomsdir
verifyAC false
serviceCert /etc/grid-security/hostcert.pem
serviceKey  /etc/grid-security/hostkey.pem
caCertDir   /etc/grid-security/certificates
logLevel    info
samlSchemaDir /usr/local/pkg/globus/version/prima/etc/opensaml

```

Fingers crossed, give it a try - after 5 days of trying, worked for me after finding all the compilation tricks and getting the PRIMA module right.

**Important**: to make sure the PRIMA library correctly locates all it's dependencies ... and does not accidentally pick a different version of the same library that may be installed into `/usr/lib`, add the following to `$GLOBUS_LOCATION/custom/run-gridftp-server.sh`.

``` 

# to make sure the PRIMA library correctly locates all it's dependency
export LIBPATH=$GLOBUS_LOCATION/prima/lib:$LIBPATH
export LD_LIBRARY_PATH=$GLOBUS_LOCATION/prima/lib:$LD_LIBRARY_PATH

```
