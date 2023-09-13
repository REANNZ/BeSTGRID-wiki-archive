# Installing Blender on CentOS 4

This page documents the installation of Blender, "the free open source 3D content creation suite" on a CentOS 4 based system from the source code.  Because of library dependencies, the precompiled binary packages won't run on CentOS 4 and we have to compile from source.  On CentOS 4, this has involved some modification to the build scripts - the detailed documentation follows.

# Download source

Note that as of 2009-08-27, the URL at [http://www.blender.org/download/source-code/](http://www.blender.org/download/source-code/) was wrongly pointing to the version 2.49 - and not 2.49a.

Go directly to [http://download.blender.org/source/](http://download.blender.org/source/) and download [blender-2.49a.tar.gz](http://download.blender.org/source/blender-2.49a.tar.gz) from there.

# Install pre-requisites

## Packages

Blender depends on a number of packages - but luckily, most of them are available in CentOS 4 (and EPEL for CentOS 4).  

- First enable the EPEL repository:


>  rpm -Uvh [http://download.fedora.redhat.com/pub/epel/4/i386/epel-release-4-9.noarch.rpm](http://download.fedora.redhat.com/pub/epel/4/i386/epel-release-4-9.noarch.rpm)
>  rpm -Uvh [http://download.fedora.redhat.com/pub/epel/4/i386/epel-release-4-9.noarch.rpm](http://download.fedora.redhat.com/pub/epel/4/i386/epel-release-4-9.noarch.rpm)

- And now install the required packages:


>  yum install yasm cmake SDL-devel OpenEXR-devel libtiff-devel python-devel
>  yum install yasm cmake SDL-devel OpenEXR-devel libtiff-devel python-devel

I was doing the install on a rather basic CentOS-4 setup (with gcc installed).  I hope this installs everything needed.

## OpenAL

The only package Blender build depends on not available in CentOS+EPEL is openal.

I am installing OpenAL from source into /opt/shared/openal/1.8.466 (with a version independent symlink /opt/shared/openal/version).

- Download openal from [http://kcat.strangesoft.net/openal.html#download](http://kcat.strangesoft.net/openal.html#download) (redirected from [http://www.openal.org](http://www.openal.org))


>  wget [http://kcat.strangesoft.net/openal-releases/openal-soft-1.8.466.tar.bz2](http://kcat.strangesoft.net/openal-releases/openal-soft-1.8.466.tar.bz2)
>  tar xjf openal-soft-1.8.466.tar.bz2
>  cd openal-soft-1.8.466
>  cmake -D CMAKE_INSTALL_PREFIX=/opt/shared/openal/1.8.466 .
>  make
> 1. as root
>  mkdir -p /opt/shared/openal/1.8.466
>  make install
>  cd /opt/shared/openal
>  ln -s 1.8.466 version
>  wget [http://kcat.strangesoft.net/openal-releases/openal-soft-1.8.466.tar.bz2](http://kcat.strangesoft.net/openal-releases/openal-soft-1.8.466.tar.bz2)
>  tar xjf openal-soft-1.8.466.tar.bz2
>  cd openal-soft-1.8.466
>  cmake -D CMAKE_INSTALL_PREFIX=/opt/shared/openal/1.8.466 .
>  make
> 1. as root
>  mkdir -p /opt/shared/openal/1.8.466
>  make install
>  cd /opt/shared/openal
>  ln -s 1.8.466 version

# Extract and pre-patch Blender

- Extract the binary


>  tar xzf blender-2.49a.tar.gz
>  cd tar xzf blender-2.49a
>  tar xzf blender-2.49a.tar.gz
>  cd tar xzf blender-2.49a

- And modify the source code in the following way - either run `patch -p 1` and feed it the text below, or edit the source files manually:

``` 

diff -u -r blender-2.49.orig/extern/ffmpeg/libavdevice/v4l.c blender-2.49/extern/ffmpeg/libavdevice/v4l.c
--- blender-2.49.orig/extern/ffmpeg/libavdevice/v4l.c   2009-03-24 04:16:31.000000000 +1300
+++ blender-2.49/extern/ffmpeg/libavdevice/v4l.c        2009-08-21 11:37:35.000000000 +1200
@@ -30,6 +30,7 @@
 #include <sys/mman.h>
 #include <sys/time.h>
 #define _LINUX_TIME_H 1
+typedef unsigned long           ulong;
 #include <linux/videodev.h>
 #include <time.h>
 #include <strings.h>
diff -u -r blender-2.49.orig/source/Makefile blender-2.49/source/Makefile
--- blender-2.49.orig/source/Makefile   2009-05-19 07:13:48.000000000 +1200
+++ blender-2.49/source/Makefile        2009-08-27 15:26:05.000000000 +1200
@@ -362,7 +362,7 @@
         NAN_SND_LIBS += $(DUMMYSOUND)
         NAN_SND_LIBS += $(OPENALSOUND)
         NAN_SND_LIBS += $(SDLSOUND)
-        NAN_SND_LIBS += $(NAN_OPENAL)/lib/libopenal.a
+        NAN_SND_LIBS += $(NAN_OPENAL)/lib/libopenal.so
         NAN_SND_LIBS += $(SOUNDSYSTEM)
     else
       ifeq ($(OS),windows)
diff -u -r blender-2.49.orig/source/nan_definitions.mk blender-2.49/source/nan_definitions.mk
--- blender-2.49.orig/source/nan_definitions.mk 2009-05-27 06:29:02.000000000 +1200
+++ blender-2.49/source/nan_definitions.mk      2009-08-27 15:26:12.000000000 +1200
@@ -381,7 +381,7 @@
     ifeq ($(WITH_OPENEXR), true)
       export NAN_OPENEXR ?= $(shell pkg-config --variable=prefix OpenEXR )
       export NAN_OPENEXR_INC ?= $(shell pkg-config --cflags OpenEXR )
-      export NAN_OPENEXR_LIBS ?= $(addprefix ${NAN_OPENEXR}/lib/lib,$(addsuffix .a,$(shell pkg-config --libs-only-l OpenEXR | sed -s "s/-l//g" )))
+      export NAN_OPENEXR_LIBS ?= $(addprefix ${NAN_OPENEXR}/lib/lib,$(addsuffix .so,$(shell pkg-config --libs-only-l OpenEXR | sed -s "s/-l//g" )))
     endif
 
     # Uncomment the following line to use Mozilla inplace of netscape

```

- The makefile changes tell Blender to link against .so (instead of .a) variants of the openal and OpenEXR (libIlmImf) libraries.
- The v4l.c source code was necessary to make it compile - somehow, the definition of ulong in linux/types.h was ignored.

# Build Blender

Set a few variables telling Blender to link against Python 2.3 (the default on CentOS 4) and tell it where to find 

>  NAN_PYTHON_VERSION=2.3 NAN_OPENAL=/opt/shared/openal/1.8.466 make

- Keep your fingers crossed and go get yourself a cut of tea.

# Install the binary

The actual directory hierarchy depends on your system - but this is the essence.

>  mkdir -p /opt/shared/blender/2.49a/bin
>  cp obj/*/bin/blender /opt/shared/blender/2.49a/bin/blender.real

- Create executable `/opt/shared/blender/2.49a/bin/.wrapper` with the following content (a wrapper to set LD_LIBRARY_PATH to the openal libs):

``` 

#!/bin/bash

EXEC_BASE=`basename $0`
if [ "$DIRNAME" == "" -o "$DIRNAME" == "/usr/local/bin" ] ; then
  DIRNAME=/opt/shared/blender/2.49a/bin
fi
EXECUTABLE=$DIRNAME/${EXEC_BASE}.real


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/shared/openal/version/lib

exec "$EXECUTABLE" "$@"

```
- Now make the wrapper run blender:


>  cd /opt/shared/blender/2.49a/bin
>  chmod +x .wrapper
>  ln -s .wrapper blender
>  cd /opt/shared/blender/2.49a/bin
>  chmod +x .wrapper
>  ln -s .wrapper blender

- And make this the default blender version:


>  cd /opt/shared/blender
>  ln -sfn 2.49a version
>  cd /opt/shared/blender
>  ln -sfn 2.49a version

Now advertise /opt/shared/blender/version/bin/blender as your executable ... or symlink it from somewhere else.  And register Blender in your MDS.

# Other attempts

## Blender Binary Distribution on Linux CentOS 4 / x86

When I attempted to run the pre-built linux32-python25 binary, I first got stuck: it needs python25, but CentOS 4 comes only with Python 2.3

- Download Python-2.5.4.tar.bz2, untar and compile with Shared library support (so that we actually get the library blender is linked against).


>  ./configure --prefix=/opt/shared/python/2.5.4 --enable-shared
>  gmake
>  gmake install
>  ./configure --prefix=/opt/shared/python/2.5.4 --enable-shared
>  gmake
>  gmake install

- Yuck ... blender won't run because it's linked against mesa-libGLU, not available for CentOS 4.

## Installing Blender on AIX

I've been (briefly) trying to compile Blender on AIX (ppc64), but this would be a long path to get all the dependencies installed right.

Just following the advise:

- *If you want to be able to run in 'make' in any subdirectory, you also need to set 2 environment variables:*
	
- NANBLENDERHOME : should point to the bf-blender directory
- MAKEFLAGS: "-w -I$NANBLENDERHOME/source"

I've set:

>  export NANBLENDERHOME=/hpc/home/vme28/wrksw/blender/blender-2.49-AIX-ppc64
>  export MAKEFLAGS="-w -I$NANBLENDERHOME/source"

And I've tried compiling with (to meet language level requirements in qhull.h:

>  gmake CC=xlc_r CFLAGS=-qlanglvl=extc99

But this would be a very long path...
