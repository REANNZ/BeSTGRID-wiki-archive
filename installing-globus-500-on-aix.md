# Installing Globus 5.0.0 on AIX

Globus 5.0.0 came out only as a source code release.  I have tried compiling Globus 5.0.0 on AIX - and succeeded.  There were only a few gotchas, this page documents them.  Otherwise, the compile was suprisingly straightforward.

I was building a 64-bit version - 32-bit could be built as well.

# Prerequisites

- Globus will be compiled with the IBM Visual Age C compiler (xlc) - so you definitely need this one installed.
- Globus relies on some GNU tools, available from the [AIX Toolbox download page](http://www-03.ibm.com/systems/power/software/aix/linux/toolbox/alpha.html).  Install at least:
	
- `make`, `tar`
- Globus also needs openssl (also available from the AIX Toolbox: `openssl`, `openssl-devel`) and needs to be told where to find OpenSSL.  See the instructions at [http://dev.globus.org/wiki/C_Security:_Vendor_OpenSSL#Known_Issues_and_Workarounds](http://dev.globus.org/wiki/C_Security:_Vendor_OpenSSL#Known_Issues_and_Workarounds) and set the following environment variables:

``` 

OPENSSL_INCLUDES=-I/opt/freeware/include
OPENSSL_LDFLAGS=-L/opt/freeware/64/lib
OPENSSL_LIBS="-lssl -lcrypto"
export OPENSSL_INCLUDES OPENSSL_LDFLAGS OPENSSL_LIBS

```

# Modifying source code

The compilation was first failing for me because two C source files are using the symbolic names AF_LOCAL and PF_LOCAL, which are OK on Linux as aliases to AF_UNIX / PF_UNIX, but AIX only defines AF_UNIX / PF_UNIX.

Apply the following two patches before proceeding further:

``` 


--- source-trees/xio/drivers/popen/source/globus_xio_popen_driver.c.orig	2010-01-07 12:46:52.000000000 +1300
+++ source-trees/xio/drivers/popen/source/globus_xio_popen_driver.c	2010-03-18 16:18:42.888951980 +1300
@@ -557,5 +557,5 @@
 #   if defined(USE_SOCKET_PAIR)
     {
-        rc = socketpair(AF_LOCAL, SOCK_STREAM, 0, s_fds);
+        rc = socketpair(AF_UNIX, SOCK_STREAM, 0, s_fds);
         if(rc != 0)
         {

```

``` 

--- source-trees/gram/jobmanager/source/startup_socket.c.orig	2009-12-17 12:25:48.000000000 +1300
+++ source-trees/gram/jobmanager/source/startup_socket.c	2010-03-18 22:13:17.305365695 +1300
@@ -311,8 +311,8 @@
             manager->socket_path);
     memset(&addr, 0, sizeof(struct sockaddr_un));
-    addr.sun_family = PF_LOCAL;
+    addr.sun_family = PF_UNIX;
     strncpy(addr.sun_path, manager->socket_path, sizeof(addr.sun_path)-1);
 
-    sock = socket(PF_LOCAL, SOCK_DGRAM, 0);
+    sock = socket(PF_UNIX, SOCK_DGRAM, 0);
     if (sock < 0)
     {
@@ -668,7 +668,7 @@
     /* create socket */
     memset(&addr, 0, sizeof(struct sockaddr_un));
-    addr.sun_family = PF_LOCAL;
+    addr.sun_family = PF_UNIX;
     strncpy(addr.sun_path, sockpath, sizeof(addr.sun_path)-1);
-    sock = socket(PF_LOCAL, SOCK_DGRAM, 0);
+    sock = socket(PF_UNIX, SOCK_DGRAM, 0);
     if (sock < 0)
     {
@@ -753,5 +753,5 @@
     }
     /* create acksocks */
-    rc = socketpair(PF_LOCAL, SOCK_STREAM, 0, acksock);
+    rc = socketpair(PF_UNIX, SOCK_STREAM, 0, acksock);
     if (rc < 0)
     {

```

# Configure, compile, install

- Make sure the above OPENSSL environment variable settings are in place.
- Make sure the GNU tar and make and in path first:

``` 
PATH=/opt/freeware/bin:$PATH
```

- Create the installation directory (`/usr/local/pkg/globus/5.0.0` in this case):

``` 
mkdir -p /usr/local/pkg/globus/5.0.0
```

- Configure, compile & install globus (compile takes several hours)


>  ./configure --prefix=/usr/local/pkg/globus/5.0.0 --with-flavor=vendorcc64dbg
>  make
>  make install
>  ./configure --prefix=/usr/local/pkg/globus/5.0.0 --with-flavor=vendorcc64dbg
>  make
>  make install

- Optional: also build [UDT support for GridFTP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setup_GRAM5_on_CentOS_5&linkCreation=true&fromPageId=3816950721): 

``` 
make udt
```
- ooops: doesn't work:

``` 

 cd . && /bin/sh /hpc/home/vme28/grid/globus/gt5.0.0-all-source-installer/source-trees-thr/xio/external_libs/udt/udt4/missing --run automake-1.10 --gnu 
src/Makefile.am:1: Libtool library used but `LIBTOOL' is undefined
src/Makefile.am:1:   The usual way to define `LIBTOOL' is to add `AC_PROG_LIBTOOL'
src/Makefile.am:1:   to `configure.ac' and run `aclocal' and `autoconf' again.
src/Makefile.am:1:   If `AC_PROG_LIBTOOL' is in `configure.ac', make sure
src/Makefile.am:1:   its definition is in aclocal's search path.
make[1]: *** [Makefile.in] Error 1
make[1]: Leaving directory `/hpc/home/vme28/grid/globus/gt5.0.0-all-source-installer/source-trees-thr/xio/external_libs/udt/udt4'

ERROR: Build has failed
make: *** [udt-thr-compile] Error 2

```

# Set the environment

- To use globus, one has to set `GLOBUS_LOCATION` and load `$GLOBUS_LOCATION/etc/globus-user-env.sh`
- Due to some GT 5.0.0 build issues, one must also include /opt/freeware/lib in LIBPATH to let binaries like myproxy-logon find openssl libraries.

- My script to intialize Globus environment is thus:

``` 

GLOBUS_LOCATION=/usr/local/pkg/globus/5.0.0/
export GLOBUS_LOCATION
. $GLOBUS_LOCATION/etc/globus-user-env.sh
LIBPATH=$LIBPATH:/opt/freeware/lib

```

and site-specific:

``` 

export GLOBUS_TCP_PORT_RANGE=40000,41000
export GLOBUS_HOSTNAME=hpcgrid1.canterbury.ac.nz
export MYPROXY_SERVER=myproxy.arcs.org.au

```
