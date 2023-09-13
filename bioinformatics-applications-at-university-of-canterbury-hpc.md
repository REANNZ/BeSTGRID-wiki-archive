# Bioinformatics applications at University of Canterbury HPC

A number of Bioinformatics applications have been already installed on the University of Canterbury HPC (p575).  This page lists the tricks that very necessary to compile the applications.

Note: this page has been replicated from the [UCSC Admin wiki](http://cantmc.canterbury.ac.nz/UCSCadm/), where it has its master copy as [AppsBioinformatics](http://cantmc.canterbury.ac.nz/UCSCadm/AppsBioinformatics). Please contact the author (Vladimir Mencl) before modifying this page. 

# List of Bioinformatics applications

Unless noted otherwise, the packages are installed on both AIX and Linux.  They are installed in `/usr/local/pkg/``appname``/``version` and binaries are symlinked to `/usr/local/bin`.

- BayesPhylogenies 1.0
- BEAST 1.4.4
- LAMARC 2.1 (Linux only)
- MrBayes 3.1.2 (with local modifications)
- ClustalW 1.83
- ClustalW-MPI 0.13
- ModelTest 3.7
- PAUP 4.0beta
- Structure 2.2.2

# Installing BayesPhylogenies

Download link: [http://www.evolution.rdg.ac.uk/BayesPhy.html](http://www.evolution.rdg.ac.uk/BayesPhy.html) Note that source code is not publicly available, the page contains only precompiled binaries - including support for Linux x86.  If you need the source code, contact either Vladimir Mencl, or the authors directly.

- AIX: fix source code 🙂
	
- in pmatrix.c, comment out

``` 
      extern int isnan (double);
```
- in BayesPhylogenies.c, line 589

``` 
      fix C++ style comment (//) to /* */
```
- (reported only by mpcc)
- AIX UP compile:


>   xlc  -o BayesPhylogenies -lm -w -O3 **.c ./MathLib/**.c
>   xlc  -o BayesPhylogenies -lm -w -O3 **.c ./MathLib/**.c

- AIX MPI compile:


>   mpcc -o BayesPhylogenies -lm -w -O3 -DMPI_ENABLED **.c ./MathLib/**.c
>   mpcc -o BayesPhylogenies -lm -w -O3 -DMPI_ENABLED **.c ./MathLib/**.c


>      mpcc -compiler xlc -o BayesPhylogenies-xlc -lm -w -O3 -DMPI_ENABLED **.c ./MathLib/**.c
>      mpcc -compiler xlc -o BayesPhylogenies-xlc -lm -w -O3 -DMPI_ENABLED **.c ./MathLib/**.c

# Installing ClustalW

Download link: [ftp://ftp.ebi.ac.uk/pub/software/unix/clustalw/](ftp://ftp.ebi.ac.uk/pub/software/unix/clustalw/)

- optionally edit makefile and set `CC=xlc`
- linux and AIX: `make`

# Installing ClustalW-MPI

Download link: [http://packages.debian.org/unstable/source/clustalw-mpi](http://packages.debian.org/unstable/source/clustalw-mpi)


# Installing ModelTest

Download link: [http://darwin.uvigo.es/software/modeltest.html](http://darwin.uvigo.es/software/modeltest.html)

Linux and AIX: edit `Makefile`

1. set CMP and LD to `xlc`
2. remove `"-fast"` from LD options

# Installing PAUP

Download: this is commercial software and you need to purchase a license. See [http://paup.csit.fsu.edu/](http://paup.csit.fsu.edu/) for more information.

Nothing to do: already binary

# Installing Structure

Downloads link: [http://pritch.bsd.uchicago.edu/software/](http://pritch.bsd.uchicago.edu/software/)  Only binaries available at the site - email authors for source code.

Structure: no changes, "`make`"

Compiled with gcc.  Could compile with `xlc` (edit Makefile, remove "-shared" option), but xlc gives warnings about -O3 optimization - so rather stay with author's decision on how to optimize.

# Installing LAMARC

Download link: [http://evolution.genetics.washington.edu/lamarc/lamarc.html](http://evolution.genetics.washington.edu/lamarc/lamarc.html)

- AIX: not supported OS
- Linux: depends on wxWidgets (at least 2.8.3).
	
- install gtk2-devel from RPM (thanks Colin!)
- compile and install wxWidgets

``` 

  cd wxWidgets-2.8.4/
  ./configure --prefix=/usr/local/pkg/wxWidgets/2.8.4/
  make
  make install

```
- compile and install LAMARC

``` 

  cd ../lamarc
  ./configure --prefix=/usr/local/pkg/lamarc/2.1 --with-wx-config=/usr/local/pkg/wxWidgets/2.8.4/bin/wx-config

```

# Installing BEAST

Download link: [http://beast.bio.ed.ac.uk/Main_Page](http://beast.bio.ed.ac.uk/Main_Page)

BEAST comes as a precompiled Java package, but uses a native library for optimized computation.  If the library is not available, BEAST uses an alternative non-optimized Java implementation - so we want the library to be available.  The source code of the library is in the `native` directory, and the compiled library should replace the precompiled `Linux x86` file in the `lib` directory.


>  TreeLikelihood using **native** nucleotide likelihood core
>  TreeLikelihood using **native** nucleotide likelihood core

In BEAST-1/native:

- AIX:

``` 

 cd BEAST.v1.4.4/native
 JAVA_HOME=/usr/java14 gmake -f Makefile.linux

```
- New try (64-bit):


>  OBJECT_MODE=64 JAVA_HOME=/usr/local/pkg/java/version/sdk gmake -f Makefile.linux 
>  OBJECT_MODE=64 JAVA_HOME=/usr/local/pkg/java/version/sdk gmake -f Makefile.linux 


> - Linux:

``` 

 cd BEAST.v1.4.4/native
 JAVA_HOME=/opt/IBMJava2-ppc-142 make -f Makefile.linux

```

- Linux: fix java startup/PATH - edit `bin/beast`

``` 

JAVA_HOME=/opt/IBMJava2-ppc-142
JRE_HOME=$JAVA_HOME/jre
PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
export JAVA_HOME
export PATH

```

And in both cases, copy `./native/libNucleotideLikelihoodCore.so` into `./lib/libNucleotideLikelihoodCore.so`

- Linux on x86 (CentOS)
	
- no changes necessary, runs straight out of the box.

# Installing MrBayes

Download link: [http://mrbayes.csit.fsu.edu/download.php](http://mrbayes.csit.fsu.edu/download.php)

Installing MrBayes is theoretically just the matter of typing `make` - but there is a number of tweaks involved, so here they are documented:

- On AIX, you have to use `gmake` instead of `make`
- Tweaking the `Makefile`
	
- to compile an MPI version, set `MPI=yes`
- On AIX, set `USEREADLINE=no` (`readline-devel` is not available on AIX)
- Patch the source code (with 

``` 
patch -p 1 < filename.patch
```

):
	
1. Fix problem with SumP hanging in MPI on error: [mrbayes-3.1.2-fix-sump-mpi.diff](/wiki/download/attachments/3816950536/Mrbayes-3.1.2-fix-sump-mpi.diff.txt?version=1&modificationDate=1539354275000&cacheVersion=1&api=v2) (
!Mrbayes-3.1.2-fix-sump-mpi.diff.txt!
)
2. Fix minor issue in mcmcdiagn param print: [mrbayes-3.1.2-fix-mcmcdiagnparamprint.diff](/wiki/download/attachments/3816950536/Mrbayes-3.1.2-fix-mcmcdiagnparamprint.diff.txt?version=1&modificationDate=1539354275000&cacheVersion=1&api=v2) (
!Mrbayes-3.1.2-fix-mcmcdiagnparamprint.diff.txt!
)
3. If compiling for 64-bit architecture, apply [mb_64bit_safe.patch](/wiki/download/attachments/3816950536/Mb_64bit-safe.patch.txt?version=1&modificationDate=1539354275000&cacheVersion=1&api=v2) (
!Mb_64bit-safe.patch.txt!
) and compile with parameter `_64BIT=yes`.

Without the patch ***and*** the compile flagf, 64-bit MrBayes crashes (core dump) in sump.  When applying the patch, use -R (the patch is in reverse format).  Still, I recommend to avoid the 64-bit version - MrBayes is installed here as a 32-bit application.

To compile the 64-bit version, type:

``` 

    patch -R -p 1 < ~/mrbayes-patches/downloaded/mb_64bit-safe.patch
    OBJECT_MODE=64 make _64BIT=yes

```

- Note, an easier way then editing Makefile with all options is passing them as Make variables:
	
- Likely to work an a GNU/Linux system: 

``` 
make _64BIT=yes MPI=yes USEREADLINE=no"
```
- With IBM Visual Age compilers: 

``` 
OBJECT_MODE=64 make _64BIT=yes MPI=yes USEREADLINE=no CC=mpcc OPTFLAGS="-q64 -qarch=pwr7 -qtune=pwr7 -O2"
```
- **Note: this needs still editing the Makefile to make the assignments to CC conditional (**`?=`*) - and also commenting out `"-Wall"` from CFLAGS

# Infernal

[Infernal](http://infernal.janelia.org/) *"is for searching DNA sequence databases for RNA structure and sequence similarities."*.

I have installed Infernal just on the Linux part of the IBM p575.

I have tried installing it on AIX:

>  wget [ftp://selab.janelia.org/pub/software/infernal/infernal.tar.gz](ftp://selab.janelia.org/pub/software/infernal/infernal.tar.gz)
>  gtar xzf infernal.tar.gz
>  cd infernal-1.0
>  CC=xlc MPICC=mpcc ./configure --enable-mpi

But it failed with:

>  mpcc -g  -DHAVE_CONFIG_H  -L.. -o esl-afetch esl-afetch.o  -leasel   -lm
>  ld: 0711-317 ERROR: Undefined symbol: .va_copy
>  ld: 0711-345 Use the -bloadmap or -bnoquiet option to obtain more information.

It looks like `va_copy` is not supported by the XLC runtime libraries, not evne on Linux.

I have however succeeded compiling it with gcc on Linux, as a 64-bit parallel + serial application.

- Parallel version:


>  export OBJECT_MODE=64 MP_COMPILER=gcc CC="gcc -m64" MPICC=mpcc
>  ./configure --enable-mpi
>  gmake
>  export OBJECT_MODE=64 MP_COMPILER=gcc CC="gcc -m64" MPICC=mpcc
>  ./configure --enable-mpi
>  gmake

- Serial version:


>  export OBJECT_MODE=64 MP_COMPILER=gcc CC="gcc -m64" MPICC=mpcc
>  ./configure
>  gmake
>  export OBJECT_MODE=64 MP_COMPILER=gcc CC="gcc -m64" MPICC=mpcc
>  ./configure
>  gmake

Works all fine.

# MsBayes

Install MsBayes from [http://msbayes.sourceforge.net/](http://msbayes.sourceforge.net/)

- So far installed on ngcompute.canterbury.ac.nz
- Download tarball, extract
- Edit Makefile and change PREFIX=/opt/shared/msbayes/20081106
- Install dependency libraries:

``` 
yum install gsl gsl-devel
```
- Compile:

``` 
gmake
```

- To run AcceptRej, one also needs R, available in the EPEL repository


>  rpm -Uvh [http://download.fedora.redhat.com/pub/epel/4/i386/epel-release-4-9.noarch.rpm](http://download.fedora.redhat.com/pub/epel/4/i386/epel-release-4-9.noarch.rpm)
>  yum install R
>  rpm -Uvh [http://download.fedora.redhat.com/pub/epel/4/i386/epel-release-4-9.noarch.rpm](http://download.fedora.redhat.com/pub/epel/4/i386/epel-release-4-9.noarch.rpm)
>  yum install R
