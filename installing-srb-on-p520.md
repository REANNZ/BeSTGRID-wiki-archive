# Installing SRB on p520

To achieve good performance for accessing data on the BeSTGRID storage, it is necessary to run a slave SRB server on the IBM p520 system - which has direct access to the BeSTGRID storage via GPFS.  The alternative, accessing the storage via NFS from the master SRB server would be painfully slow and has been strongly discouraged.

This page documents the installation of the SRB slave server on the IBM p520 (hpcgrid1).  As the system runs AIX on Power5+ CPUs, I had to compile SRB from source.  As I was compiling just the minimal version of SRB (no GSI, no Globus, no database connectivity), it was in the end a reasonably straightforward job.

# Compiling SRB

For the compilation, I've had the choice whether to compile with xlC or gcc, and whether to compile in 32-bit or 64-bit mode.

I first tried compiling with xlC in 64-bit mode ... aiming to build a high-performing and robust system.  I succeeded in compiling SRB, and it did run, but it failed to communicate with the (32-bit) master SRB server.  Recompiling with gcc in 32-bit mode resulted in a server that runs well and interoperates correctly with the master server.  I suspect the 64-bit mode was the problem and SRB is not 64-bit safe - but I did not do the additional experiment to figure out whether the problem was with the 64-bit mode or with xlC.  I took the simplifying conclusion that gcc/32 does work and xlC/64 does not...

I wanted to install SRB in `/usr/local/pkg/srb/3.5.0`.  The configure script does not accept `-``prefix`, and I had to use `-enable-installdir` instead.  I've followed the local convention and created the SRB directory with:

>  mkdir -p /usr/local/pkg/srb/3.5.0
>  cd /usr/local/pkg/srb
>  ln -s 3.5.0 version

This allows to refer to the current SRB directory with /usr/local/pkg/srb/version

I did not need to pass configure any other options - no database access (neither data, nor MCAT), no GSI, no Globus.

So, the final sequence of commands to compile SRB was:

``` 

gtar xzf SRB3.5.0.tar.gz
cd SRB3_5_0
CC=gcc CXX=g++ ./configure --enable-installdir=/usr/local/pkg/srb/3.5.0
CC=gcc CXX=g++ gmake CC=gcc CXX=g++
CC=gcc CXX=g++ gmake CC=gcc CXX=g++ install

```

# Configuring SRB

- Configure where to find the MCAT-enabled SRB master server: edit `/usr/local/pkg/srb/3.5.0/data/mcatHost` and change the (non-comment) lines to


>  ngdata.canterbury.ac.nz
>  ENCRYPT1
>  /C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=ngdata.canterbury.ac.nz
>  ngdata.canterbury.ac.nz
>  ENCRYPT1
>  /C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=ngdata.canterbury.ac.nz

- Configure all the names this host may be referred to by: add the following line to `/usr/local/pkg/srb/3.5.0/data/hostConfig`


>  localhost hpcgrid1 hpcgrid1-c hpcgrid1.canterbury.ac.nz
>  localhost hpcgrid1 hpcgrid1-c hpcgrid1.canterbury.ac.nz

- The server needs credentials to authenticate to the master SRB server.  Create `~srb/.srb/.MdasEnv` with the same information as it already exists on the master server:

``` 

mdasCollectionName '/srb.bestgrid.org.nz/home/srbAdmin.srb.bestgrid.org.nz'
mdasCollectionHome '/srb.bestgrid.org.nz/home/srbAdmin.srb.bestgrid.org.nz'
mdasDomainName 'srb.bestgrid.org.nz'
mdasDomainHome 'srb.bestgrid.org.nz'
srbUser 'srbAdmin'
srbHost 'ngdata.canterbury.ac.nz'
#srbPort '5544'
defaultResource 'srb.bestgrid.org.nz'
#AUTH_SCHEME 'PASSWD_AUTH'
#AUTH_SCHEME 'GSI_AUTH'
AUTH_SCHEME 'ENCRYPT1'

```
- Also create `~srb/.srb/.MdasAuth` with the srbAdmin's password.

- Make the whole SRB directory owned by SRB:


>  chown -R srb.srb /usr/local/pkg/srb/3.5.0
>  chown -R srb.srb /usr/local/pkg/srb/3.5.0

- Copy host certificates into SRB certificates and make them owned by SRB (though the certificates won't be used as SRB is built without GSI/Globus).

``` 

cd /etc/grid-security
cp hostcert.pem srbcert.pem
cp hostkey.pem srbkey.pem
chown srb.srb srb{cert,key}.pem

```
- Customize `runsrb`: specify the range for TCP ports to use and the path to the X509 certificates (though the certificates won't be used).


>  commPortNumStart=40000
>  X509_USER_KEY=/etc/grid-security/srbkey.pem
>  X509_USER_CERT=/etc/grid-security/srbcert.pem
>  commPortNumStart=40000
>  X509_USER_KEY=/etc/grid-security/srbkey.pem
>  X509_USER_CERT=/etc/grid-security/srbcert.pem

- Start SRB


>  cd /usr/local/pkg/srb/3.5.0/
>  ./runsrb 
>  cd /usr/local/pkg/srb/3.5.0/
>  ./runsrb 

# Automatic startup

I have crafted an `/etc/rc.d/init.d/srb` script for the p520 (AIX) from the one that came with the SRB Linux distribution.  The major changes were:

- remove support for controlling postgresql
- do not use any RedHat specific functions

Without the RedHat support functions, the magic commands are:

- Start: 

``` 
su - $SRBUSER -c "cd $SRBHOME/bin; ./runsrb"
```
- Stop: 

``` 
su - $SRBUSER -c "cd $SRBHOME/bin; ./killsrb now"
```
- Status: 

``` 
ps -u $SRBUSER | grep -v grep | egrep 'srbMaster|srbServer' || { echo "SRB not running"; exit 1 ; }
```

The control file is installed in `/etc/rc.d/init.d`, with a symbolic link `S95srb` in `rc2.d` (the p520 boots into runlevel 2).

# Failure compiling with xlC in 64-bit mode

As described above, I initially compiled SRB with xlC in 64-bit mode - the command sequence for that was:

>  OBJECT_MODE=64 CC=xlc CXX=xlC ./configure --enable-installdir=/usr/local/pkg/srb/3.5.0
>  OBJECT_MODE=64 CC=xlc CXX=xlC gmake CC=xlc CXX=xlC 
>  OBJECT_MODE=64 CC=xlc CXX=xlC gmake CC=xlc CXX=xlC install

The error message I was getting from client (when trying to store a file on a resource hosted on this server):

>  Sput -S hpcgrid1-datares-test -R 0 /etc/termcap 
>  Unable to create object /srbdev.bestgrid.org.nz/home/srbAdmin.srbdev.bestgrid.org.nz/termcap, status = -1023
>  SVR_TO_SVR_CONNECT_ERROR: Problem with a server connecting to a remote SRB master. The remote SRB master may be down

In the master SRB server log, I could see:

>  connectPort(): Connect to srbServer: hpcgrid1.canterbury.ac.nz:4094 failed, errno=111
>  svrConnectSvr: connectPort error. status =-1023
>  NOTICE:Nov 19 12:34:08: Remote connect to hpcgrid1.canterbury.ac.nz failed: 
>  NOTICE:Nov 19 12:34:08: cannot create ext file /hpc/gridusers/srb/data-test/srbAdmin.srbdev.bestgrid.org.nz/82/57/termcap.728052983.1227051247

And I did not see much useful information in the slave server log: only a mention of a connection attempt:

>  serverLoop: serverLoop: 1 sockets pending
>  serverLoop: connect on 8
>  serverLoop:             handling 8
>  child[295160](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=295160&linkCreation=true&fromPageId=3818228815): execv(/hpc/projects/packages/local.aix/pkg/srb/3.5.0/bin/./srbServer, -d2, -p9, -P10, )
>  Unable to open MAINTENENCE_CONFIG_FILE file ../data/srb.allow
>  initHostWithMCat: host from DATABASE: 
>  initHostWithMCat: host from DATABASE: mda-18.sdsc.edu:NULL:NULL
>  initHostWithMCat: host from DATABASE: gridgwtest.canterbury.ac.nz:NULL.NULL
>  initHostWithMCat: host from DATABASE: hpcgrid1.canterbury.ac.nz:NULL:NULL
>  initHostWithMCat: host from DATABASE: mda-18.sdsc.edu:NULL:NULL
>  initHostWithMCat: host from DATABASE: ghidorah.sdsc.edu:mcat:foo
>  findServerExec: found "/hpc/projects/packages/local.aix/pkg/srb/3.5.0/bin/./srbServer" using argv[0](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=0&linkCreation=true&fromPageId=3818228815)

Watching with wireshark: 

- Master server initiates a connection to port 5544 with message "STARTSRB"
- Slave server replies with port number 4094 (this is suspicious, the port number is always the same (though it does vary in normal SRB operation) and it's outside the range specified by `commPort`.
- Master server initiates a TCP connection to port 4094, which is rejected at the TCP level - no one listening there.

- My explanation: improper 64-bit support, incorrect port number sent to the client.
