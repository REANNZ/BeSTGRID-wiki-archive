# Installing Blender on CentOS 5 x86 64

Installing Blender on CentOS 5 has been much simpler then on [CentOS 4](/wiki/spaces/BeSTGRID/pages/3816950657) - all of the dependencies are available as RPMs, in either CentOS core distribution or in EPEL.

This page is specifically about installing Blender on CentOS 5 x86_64 - but the same would apply to CentOS 5 i386 (minus the changes related to the lib64 directory name).

**Note**: The original description - to build Blender from source and link against CentOS 5 + EPEL packages - did not work.  Blender kept randomly segfaulting.

Instead:


>  export PYTHONHOME=/opt/shared/python/2.5.4-x86_64
>  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PYTHONHOME/lib
>  export PYTHONHOME=/opt/shared/python/2.5.4-x86_64
>  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PYTHONHOME/lib

# Prerequisites

- Enable EPEL

``` 
rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm
```
- Install dependencies

``` 
yum install yasm cmake SDL-devel OpenEXR-devel libtiff-devel python-devel openal openal-devel freetype-devel libjpeg-devel libpng-devel giflib-devel libXmu-devel libXi-devel
```

# Download source

Download blender-2.49a.tar.gz from [http://download.blender.org/source/](http://download.blender.org/source/) and extract it into a temporary directory.

# Modify makefiles

- Edit `source/Makefile` to use /lib64/libname.so instead of /lib/libname.a for libjpeg.a, libopenal.a and libfreetype.a

``` 

106c106
< COMLIB += $(NAN_JPEG)/lib/libjpeg.a
---
> COMLIB += $(NAN_JPEG)/lib64/libjpeg.so
204c204
<             COMLIB += $(NAN_FREETYPE)/lib/libfreetype.a
---
>             COMLIB += $(NAN_FREETYPE)/lib64/libfreetype.so
365c365
<         NAN_SND_LIBS += $(NAN_OPENAL)/lib/libopenal.a
---
>         NAN_SND_LIBS += $(NAN_OPENAL)/lib64/libopenal.so

```

- Make a similar change to the definition of NAN_OPENEXR_LIBS, NAN_PYTHON_LIB, and NAN_FFMPEGLIBS in `source/nan_definitions.mk`

``` 

359c359
<     export NAN_PYTHON_LIB ?= $(NAN_PYTHON)/lib/python$(NAN_PYTHON_VERSION)/config/libpython$(NAN_PYTHON_VERSION).a
---
>     export NAN_PYTHON_LIB ?= $(NAN_PYTHON)/lib64/python$(NAN_PYTHON_VERSION)/config/libpython$(NAN_PYTHON_VERSION).a
377c377
<     export NAN_FFMPEGLIBS ?= -L$(NAN_FFMPEG)/lib -lavformat -lavcodec -lavutil -lswscale -lavdevice -ldts -lz
---
>     export NAN_FFMPEGLIBS ?= -L$(NAN_FFMPEG)/lib64 -lavformat -lavcodec -lavutil -lswscale -lavdevice -ldts -lz
384c384
<       export NAN_OPENEXR_LIBS ?= $(addprefix ${NAN_OPENEXR}/lib/lib,$(addsuffix .a,$(shell pkg-config --libs-only-l OpenEXR | sed -s "s/-l//g" )))
---
>       export NAN_OPENEXR_LIBS ?= $(addprefix ${NAN_OPENEXR}/lib64/lib,$(addsuffix .so,$(shell pkg-config --libs-only-l OpenEXR | sed -s "s/-l//g" )))

```

# Compile

- Override the Python version in the environment and run make:


>  NAN_PYTHON_VERSION=2.4 make
>  NAN_PYTHON_VERSION=2.4 make

# Install

> - Just copy the `obj/*/bin/blender` executable into the desired target location:
>  cp obj/*/bin/blender /opt/shared/blender/2.49a/bin/blender
