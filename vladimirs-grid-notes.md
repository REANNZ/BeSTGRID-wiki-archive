# Vladimir's grid notes

**Various notes I'm taking while working on setting up the Grid Node**

# Grid Setup TODO (both local config and gateway node)

## create local gridmap configuration

- list local users in `/opt/vdt/edg/etc/grid-mapfile-local`

- list VOMSes in `/opt/vdt/edg/etc/edg-mkgridmap.conf`

Works for me:

>   group vomss://vdtcentos.bestgrid:8443/voms/BeSTGRID?/BeSTGRID/Universities/Canterbury ucgriduser
>   group vomss://vdtcentos.bestgrid:8443/voms/BeSTGRID?/BeSTGRID griduser
>   group vomss://vdtcentos.bestgrid:8443/voms/BeSTGRID?/BeSTGRID/Role=GridUser griduser

Beware: no trailing slashes and no `Group=` in vomss URL!

Otherwise, vomss *silently fails* (output in `/opt/vdt/edg/log/edg-mkgridmap.log`), reporting VOMS Internal Server Error.

- re-create: run `edg-mkgridmap`

Note: All output (including `edg-mkgridmap -help`) goes to `/opt/vdt/edg/log/edg-mkgridmap.log`.

Doc: [http://vdt.cs.wisc.edu/extras/edg-mkgridmap.html](http://vdt.cs.wisc.edu/extras/edg-mkgridmap.html)

man edg-mkgridmap.conf (7)

## setup services to be started automatically

Usage from mailing list:

>   vdt-register-service --name sshd -type init --init-script /opt/vdt/globus/sbin/SXXsshd --enable

Log entry from installing voms - service is installed as disabled

>   /opt/vdt/vdt/sbin/vdt-register-service --name voms --type init --disable --init-script /opt/vdt/post-install/voms

Worked for me:

>   /opt/vdt/vdt/sbin/vdt-register-service -name voms --enable
>   /opt/vdt/vdt/sbin/vdt-register-service -name vomrs --enable --type init --init-script /opt/vdt/vomrs-1.3/etc/init.d/vomrs-wrap-all
>   vdt-control --on voms 
>   vdt-control --on vomrs 

Contents of hand-crafted `/opt/vdt/vomrs-1.3/etc/init.d/vomrs-wrap-all`

>   #!/bin/sh
>   #
> 1. Header written by hand by Vladimir
> 2. VDT_LOCATION = /opt/vdt
>   #
> 3. chkconfig: 345 99 99
> 4. description: Virtual organization membership registration server
> 	
> 1. 
> 1. BEGIN INIT INFO
> 5. Provides: voms
> 6. Required-Start: $network $mysql $voms $tomcat-5
> 7. Required-Stop:
> 8. Default-Start: 3 4 5
> 9. Default-Stop: 1 2 6
> 10. Description: Virtual organization membership registration server
> 	
> 1. 
> 1. END INIT INFO
>   if [-e /opt/vdt/setup.sh](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=-e%20%2Fopt%2Fvdt%2Fsetup.sh&linkCreation=true&fromPageId=3816950583); then source /opt/vdt/setup.sh; fi
>   VOMRS_NAMES="BeSTGRID"
> 1. 
> 1. 
> 1. could be automatically obtained from directory listings
>   VOMRS_LOCATION=/opt/vdt/vomrs-1.3/
>   export VOMRS_LOCATION
>   for VO_NAME in $VOMRS_NAMES ; do
>     /opt/vdt/vomrs-1.3/etc/init.d/vomrs "$@" "$VO_NAME"
>   done

## set up certificate request data

>   $VDT_LOCATION/vdt/setup/setup-cert-request 

## Apache / Tomcat 5 configuration

- Source: [http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsVomrs#Step_Four_Configuring_the_VOMS_V](http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsVomrs#Step_Four_Configuring_the_VOMS_V)
- Do not run apache linked with tomcat (JkMount), instead configure TOMCAT for an extra HTTPS connector
- Backup the current tomcat-5 /opt/vdt/tomcat/v5/conf/server.xml and create a new one

``` 

  <?xml version='1.0' encoding='UTF-8'?>
  <!DOCTYPE Server>
  <Server port='8005' shutdown='SHUTDOWN'>
    <Service name='Catalina'>
      <Connector sslProtocol='TLS' maxThreads='150' maxSpareThreads='75' secure='true' enableLookups='false' sslKey='/etc/grid-security/http/httpkey.pem' sslCAFiles='/etc/grid-security/certificates/*.0' crlFiles='/etc/grid-security/certificates/*.r0' minSpareThreads='25' disableUploadTimeout='true' sSLImplementation='org.glite.security.trustmanager.tomcat.TMSSLImplementation' acceptCount='100' clientAuth='true' debug='0' sslCertFile='/etc/grid-security/http/httpcert.pem' scheme='https' port='8443' log4jConfFile='/opt/vdt/tomcat/v5/conf/log4j-trustmanager.properties'/>
      <Engine name='Catalina' defaultHost='localhost'>
       <Logger className="org.apache.catalina.logger.FileLogger" prefix="catalina_log." suffix=".txt" timestamp="true"/>
        <Logger className="org.apache.catalina.logger.FileLogger" directory="logs"  prefix="localhost_log." suffix=".txt" timestamp="true"/>
        <Host name='localhost' appBase='webapps'/>
      </Engine>
    </Service>
  </Server>

```

Copy some .jar files to the right place

> 1. cd /opt/vomrs-1.3/server/lib && cp glite-security-trustmanager.jar glite-security-util-java.jar puretls.jar log4j-1.2.8.jar /opt/vdt/tomcat/v5/server/lib/
> 2. cd /opt/vdt/tomcat/v5/server/lib/ && chown daemon:daemon glite-security-trustmanager.jar glite-security-util-java.jar puretls.jar log4j-1.2.8.jar

Note: dissecting default (VDT) Tomcat server.xml: almost same content as asked for by APAC (except for Apache connector instead of SSL).

>   Server contains
>     Service name=Catalina contains
>       x Conecctor
>       1x Engine (special case of a Container)
>           contains:
>             Logger
>             Realm (?some kind of data storage - linked to mem/fs/database)
>             (virtual) Host appBase="webapps"
>                   maycontain Cluster, Valve(s),
>                   contains Logger

# Crypto

## OpenSSL useful commands

To test server or client with openssl

>  openssl s_client -host vdtcentos.bestgrid -port 8443 -cert ~/.globus/usercert.pem -key ~/.globus/userkey.pem -verify 0 -CApath /etc/grid-security/certificates/
>  openssl s_server -accept 18443 -key /etc/grid-security/hostkey.pem -cert /etc/grid-security/hostcert.pem -verify 0 -CApath /etc/grid-security/certificates/

To export a PEM certificate into PKCS12:

>  openssl pkcs12 -export -chain -inkey ~/.globus/userkey.pem -in ~/.globus/usercert.pem -out ~/.globus/usercert.p12 -CAfile ~/.globus/certificates/1e12d831.0 -name MyCertificateName

To convert a PKCS12 certificate into PEM (note that the last command is needed to use the correct private key encoding that Grix/Grisu/jGlobus need)

>  openssl pkcs12 -in usercert.p12  -out usercert.pem -nokeys -clcerts
>  openssl pkcs12 -in usercert.p12  -out userkey.pem -nocerts -des3
>  openssl rsa -in userkey.pem -out userkey.pem -des3

To import a PKCS12 certificate into PEM format:

>  openssl pkcs12 -in ~/.globus/usercert.p12 -out ~/.globus/usercert+key.pem

To request a certificate (for the grid):

>  openssl req -new -nodes -keyout hostkey.pem -out hostcert_request.pem -newkey rsa:2048

To request a certificate (for a web host):

>  openssl req -new -nodes -keyout `hostname`-key.pem -out `hostname`-csr.pem -newkey rsa:2048

To remove passphrase from an RSA key:

>  umask 077
>  openssl rsa -in ~/.globus/userkey.pem -out ~/.globus/userkey.pem

To set a passphrase for an RSA key (encrypting with Triple DES):

>  umask 077
>  openssl rsa -in ~/.globus/userkey.pem -3des -out ~/.globus/userkey.pem

To generate a self-signed certificate for Apache (overwrite the one generated by mod_ssl post-install scriptlet):

>  /usr/bin/openssl req -newkey rsa:2048 -new -nodes -keyout /etc/pki/tls/private/localhost.key -x509 -days 3650 -set_serial $RANDOM -out /etc/pki/tls/certs/localhost.crt


---

To view certificate, certificate request, private key:

>  openssl x509 -text -in ~/.globus/usercert.pem
>  openssl req -text -in ~/.globus/usercert_request.pem
>  openssl rsa -text -in ~/.globus/userkey.pem

## Rehash CA certificates directory

``` 

# for CA in *.pem ; do ln -s $CA $( openssl x509 -hash -noout -in $CA ).0 ; done

for CA in *.pem ; do
  CA_BASE=$( basename $CA .pem )
  HASH=$( openssl x509 -hash -noout -in $CA )
  ln -s $CA $HASH.0
  for CA_FILE in ${CA_BASE}.* ; do
    ln -s $CA_FILE ${CA_FILE/#$CA_BASE/$HASH}
  done
done

```

## Grid Crypto commands

### New user creation (with dummy CA)

As user:

>   grid-cert-request -dir ~/.globus-other/ -nopw -verbose -cn "John Q Public" -int ### -int recommended

As root on machine with CA key:

>   grid-ca-sign -in ~mencl/.globus-other/usercert_request.pem -out ~mencl/.globus-other/usercert.pem

If `grid-ca-sign` refuses to sign:

>   openssl x509 -req -in ~mencl/.globus-testnamespace/usercert_request.pem -out ~mencl/.globus-testnamespace/usercert.pem -days 365 -set_serial 293 -CA /root/.globus/simpleCA/cacert.pem -CAkey /root/.globus/simpleCA/private/cakey.pem -extfile /root/.globus/simpleCA/grid-ca-ssl.conf -extensions x509v3_extensions

### Host and Service certificate request

Host certificate:

>   $VDT_LOCATION/globus/bin/grid-cert-request -service http -host vdtcentos.bestgrid
>     /C=NZ/O=BeSTGRID/OU=Advanced Technologies Group/CN=http/vdtcentos.bestgrid
>   The private key is stored in /etc/grid-security/http/httpkey.pem
>   The request is stored in /etc/grid-security/http/httpcert_request.pem

Renewing a host certificate with the same Subject Name:

>  openssl req new -nodes -keyout hostkey.pem -out hostcert_request.pem -newkey rsa:2048 -subj "$( openssl x509 -subject -noout -in /etc/grid-security/hostcert.pem | cut -d ' ' -f 2 )"

### Issues with requesting certificates

- `$VDT_LOCATION/vdt/setup/setup-cert-request` reports a `sed` error and leaves the grid-security.conf.1e12d831 file empty.
	
- OK, it's fine to select the CA with `-ca <ca-hash>` when calling `grid-cert-request`
- non-intertactive `grid-cert-request` fails with openssl error - EOF received when email address expected.
	
- works in interactive mode (`-int`)
- BeSTGRID UoC Test CA:
	
1. does not ask for email address (and hence works fine with non-interactive `grid-cert-request`)
2. asks for a second-level OU (and insists on putting it into DN, default 2nd OU=bestgrid)

Command lines that work:


## Java Crypto Commands

- Add the APACGrid root certificate to the Java system keystore


>  keytool -import -noprompt -alias apacgridca -keystore /usr/java/latest/jre/lib/security/cacerts -file ~mencl/.globus/certificates/1e12d831.0 -storepass "changeit"
>  keytool -import -noprompt -alias apacgridca -keystore /usr/java/latest/jre/lib/security/cacerts -file ~mencl/.globus/certificates/1e12d831.0 -storepass "changeit"

# Miscellaneous

## Start services currently needed

>   . /opt/vdt/setup.sh
>   /opt/vdt/post-install/voms start
>   VOMRS_LOCATION=/opt/vdt/vomrs-1.3/ /opt/vdt/vomrs-1.3/etc/init.d/vomrs start BeSTGRID
>   /opt/vdt/post-install/apache start 

## edg-mkgridmap problem

Problem:

>   edg-mkgridmap
>   /opt/vdt/edg/sbin/edg-mkgridmap: line 100: [missing `](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=missing%20%60&linkCreation=true&fromPageId=3816950583)'

Fix:

>  — edg-mkgridmap.orig-vdt      2006-12-18 13:07:39.000000000 +1300
>  +++ edg-mkgridmap       2007-03-05 16:50:39.000000000 +1300
>  @@ -97,7 +97,7 @@
> 1. overwrite the grid-mapfile unless it's changed. (See below)
> 2. We also make sure that ${GRIDMAP}.new is empty if we don't have
> 3. an existing grid-mapfile.
> - if [-e $\{GRIDMAP\}.new](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=-e%20%24%5C%7BGRIDMAP%5C%7D.new&linkCreation=true&fromPageId=3816950583); then
>  +  if [-e $\{GRIDMAP\}.new](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=-e%20%24%5C%7BGRIDMAP%5C%7D.new&linkCreation=true&fromPageId=3816950583); then
>       rm ${GRIDMAP}.new
>     fi
>     if [-e $\{GRIDMAP\}](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=-e%20%24%5C%7BGRIDMAP%5C%7D&linkCreation=true&fromPageId=3816950583); then

Doc:
[http://vdt.cs.wisc.edu/extras/edg-mkgridmap.html](http://vdt.cs.wisc.edu/extras/edg-mkgridmap.html)

## GRIS

From VPAC wiki: GRIS is old and fairly useless. We're using MonALISA for

grid info at the moment.

## User management issues

- [http://www.vpac.org/twiki/bin/view/APACgrid/PlanGridStaging](http://www.vpac.org/twiki/bin/view/APACgrid/PlanGridStaging)
- if a user already has a local account, use it, otherwise use the approprate 'generic user' for the project.
- (eg) "access to Abaqus is only available via the grid when run as existing logon accounts".
- ensure that grid usage mapped to a logon user is not counted twice by local sites.
- ...=> Virtual Account

## Understanding Job Ids

A job may have two externally visible IDs - which both have a similar form as a long string of hexadecimal digits, but be different for a single job.

One of these is called the *Idempotence ID*, is generated by the client, and is used to uniquely identify the client's attempt to submit the job - that is, have a way to find out whether a particular job submission attempt succeeded or not, to avoid double submission if job submission is interrupted and the client thinks it needs to resubmit the task.  Example: `c61344ae-e344-11dc-ac0e-00163e84b599`.

The other is the job *ResourceID*, is generated by the server, is used as a part of the job's *end-point reference* (EPR), and is used throughout the Globus server to identify the job.  Example: `c698b490-e344-11dc-8ba9-ffac443c90f7`.

**Idempotence ID** is used in the following:

- When submitting a job with `globusrun-ws -submit`, the ID printed on standard output of `globusrun-ws` is the idempotence ID.
- When submitting a job with `globusrun-ws` with streaming (-s), the standard output and error files in the grid user's home directory are named after the idempotence ID (`~/${IDEMPOTENCE_ID}.{stdout,stderr`}).  This happens because the job description is created by the globusrun-ws client.

**ResourceID** is used in the following:

- The directory created for the PBS submit scripts in `~/.globus` is named after the ResourceID.
- If a job delegated proxy is stored in `~/.globus/gram_job_proxy_some_hex_id`, the file is named based on the ResourceID.

Furthermore, there is also a Local ID, which in the case of the Fork scheduler takes similar hexadecimal form, but is again based on a number different from both ResourceID and Idempotence ID, and has the PID of the processed appended.  Example: `1cba76d2-e346-11dc-9053-00163e8b5002:28685`.

(with ResourceID being 1c4a9ce0-e346-11dc-8ba9-ffac443c90f7 and Idempotence ID being 1bc60ee4-e346-11dc-a13b-00163e84b599.  For other local schedulers, the local job ID  is generated by the scheduler, and typically includes the hostname of the cluster's headnode and a sequence number.

## Debugging pbs.pm

Andrew Sharpe sent me a number of tips on how to debug what's happening in PBS.pm.  The crucial part is this patch to several scripts around pbs.pm: [http://www.hpc.jcu.edu.au/projects/apac/svn/gateway/globus/globus_perl.patch](http://www.hpc.jcu.edu.au/projects/apac/svn/gateway/globus/globus_perl.patch)

The patch adds the missing pieces to allow the JobManager framework log to a file.

Additional logging code may go directly to `pbs.pm`:

- this bit goes near the top


>    if(defined($self->{logdir})) {
>        $description->save($self->{logdir} . "/description.pl");
>    }
>    if(defined($self->{logdir})) {
>        $description->save($self->{logdir} . "/description.pl");
>    }

- this bit goes just before submission


>    if(defined($self->{logdir})) {
>        system("cp $pbs_job_script_name $self->{logdir}/pbs.sh");
>    }
>    if(defined($self->{logdir})) {
>        system("cp $pbs_job_script_name $self->{logdir}/pbs.sh");
>    }

- then all you have to do to enable the extras is uncomment the following line in $GLOBUS_LOCATION/lib/perl/Globus/GRAM/JobManager.pm (about line 90)


>    $self->{logdir} = "/tmp/" . $ENV{'USER'} . "/" . $id;
>    $self->{logdir} = "/tmp/" . $ENV{'USER'} . "/" . $id;

## Get gridftplist working

The `gridftplist` command is a part of the SRM-V1-Client VDT package.  When invoked, it complains about `SRM_PATH` not set.  It also needs to add the Apache logging API to the class path.  Thus, the patch to get the command working is:

``` 

--- /opt/vdt/srm-v1-client/bin/gridftplist.orig      2006-11-22 11:53:19.000000000 +1300
+++ /opt/vdt/srm-v1-client/bin/gridftplist 2008-03-04 11:32:56.000000000 +1300
@@ -1,5 +1,9 @@
 #! /bin/sh
 
+### VM ###
+if [ -z "$SRM_PATH" ] ; then
+  SRM_PATH=/opt/vdt/srm-v1-client
+fi
 #DEBUG=true
 #SECURITY_DEBUG=true 
 #DEBUG=false
@@ -19,6 +23,9 @@
 SRM_CP=$SRM_PATH/lib/srm_client.jar
 SRM_CP=$SRM_CP:$SRM_PATH/lib/srm.jar
 
+### VM ###
+SRM_CP=$SRM_CP:$SRM_PATH/lib/axis/commons-logging-1.0.4.jar
+
 # globus cog
 SRM_CP=$SRM_CP:$SRM_PATH/lib/globus/cryptix.jar
 SRM_CP=$SRM_CP:$SRM_PATH/lib/globus/ce-jdk13-120.jar

```

However, I rather recommend installing UberFTP, which provides a nice text-mode shell in the style of the traditional unix FTP client.

## Enabling logging on a GridFTP server

Edit `/opt/vdt/vdt/services/vdt-run-gsiftp.sh` and change the server startup to the following:

``` 

. /opt/vdt/setup.sh
GRIDFTP_LOGFILE=/opt/vdt/globus/var/log/gridftp-debug.log.$$
exec /opt/vdt/globus/sbin/globus-gridftp-server -logfile $GRIDFTP_LOGFILE -log-level ALL -debug
# exec /opt/vdt/globus/sbin/globus-gridftp-server

```

## Debugging a Globus 5.2 GridFTP server

Add this to either `/etc/gridftp.conf` or a new file in `/etc/gridftp.d/`: 

``` 

log_level ALL
log_module stdio:buffer=0
log_single /var/log/globus-gridftp-server.log

```

## Increasing the validity limit for VOMS Attribute Certificates

- The option is rather counter-intuitively named:

``` 

-timeout      The maximum length of validity of the ACs that
              VOMS will grant. (in seconds) The default value
              is 24 hours

```
- Source: [http://glite.web.cern.ch/glite/documentation/](http://glite.web.cern.ch/glite/documentation/) => VOMS Core User and Reference Guide

- Edit `/opt/vdt/glite/etc/voms/VO-NAME/voms.conf` and add the --timeout option with the new limit (in seconds):

``` 
--timeout=259200
```
- (3 days in seconds)

## Listing users in a VO group

[https://vomrs.arcs.org.au:8443/voms/ARCS/services/VOMSCompatibility?method=getGridmapUsers&container=/ARCS/BeSTGRID](https://vomrs.arcs.org.au:8443/voms/ARCS/services/VOMSCompatibility?method=getGridmapUsers&container=/ARCS/BeSTGRID)

## Signing JNLP files

[Java6 release notes on JNLP](http://www.oracle.com/technetwork/java/javase/jnlp-136707.html) talk about JNLP signing and refer to section 5.4.1 of the [JNLP specification](http://www.oracle.com/technetwork/java/javase/tech/index-jsp-136112.html) - which can be downloaded from [http://www.oracle.com/technetwork/java/javase/download-spec-142476.html](http://www.oracle.com/technetwork/java/javase/download-spec-142476.html)

And after getting all there, section 5.4.1 reads:

**5.4.1 Signing of JNLP Files**

- A JNLP file can optionally be signed. A JNLP Client must check if a signed version of the JNLP file exists, and if so, verify that it matches the JNLP file that is used to launch the application. If it does not match, then the launch must be aborted. If no signed JNLP file exists, then the JNLP file is not signed, and no check needs to be performed.

- A JNLP file is signed by including a copy of it in the signed main JAR file. The copy must match the JNLP file used to launch the application. The signed copy must be named: JNLP-INF/APPLICATION.JNLP. The APPLICATION.JNLP filename should be generated in upper case, but should be recognized in any case.

- The signed JNLP file must be compared byte-wise against the JNLP file used to launch the application. If the two byte streams are identical, then the verification succeeds, otherwise it fails.

- As described above, a JNLP file is not required to be signed in order for an application to be signed. This is similar to the behavior of Applets, where the Applet tags in the HTML pages are not signed, even when granting unrestricted access to the Applet.

So, copy the JNLP file as `JNLP-INF/APPLICATION.JNLP` into the jar before packing up and singing the jar - and that is it.

## JavaWebStart and OpenJDK

Grix was failing with *weird errors* (`NullPointerException` in `net.sourceforge.jnlp.runtime.JNLPClassLoader.getPermissions`) with OpenJDK/IceadTea JavaWebStart.

Turns out it was all caused by OpenJDK/IceadTea interpretting the main jar's `MANIFEST.MF` literally and loading bcprov.jar from the same codebase (web URL).

The very simple solution is to move the jar to a different directory then where bcprov.jar is (and adjust the JNLP file accordingly).

At ngportal.canterbury.ac.nz, grix jar is now in `/grid/grix/grix-jdk5-bestgrid.jar`, while bcprov.jar is still in `/grid/bcprov-jdk15-140.jar`

## Building Grix

- Get Grix from [https://github.com/makkus/Grix:](https://github.com/makkus/Grix:)

``` 
git clone https://github.com/makkus/Grix
```
- Get jGlobus modified for BeSTGRID from [https://github.com/makkus/jglobus-nz:](https://github.com/makkus/jglobus-nz:)

``` 
git clone https://github.com/makkus/jglobus-nz
```
- You can build jglobus using ant
		
- `ant # => jglobus-nz/build/cog-jglobus-1.8.0.jar`

- To build grix, all you need to do is:

``` 
mvn clean install
```
- binaries should be in grix_impl/target (... but are in `# h1. > ~/.m2/repository/au/org/arcs/grix/grix_impl/1.3.5-SNAPSHOT`)
- In order to switch in your jglobus, we probably have to be bit a bit tricky... easiest way is replace existing `~/.m2/repository/external/jglobus/cog-jglobus/1.8.2-nesi/cog-jglobus-1.8.2-nesi.jar` with your binary before you do mvn clean install

## Running and developing with OpenMPI on RHEL6

- Install openmpi (and compilers if not installed yet):

``` 
yum install openmpi gcc gcc-c++
```


## XDMCP login

To configure a CentOS5 system to accept an XDMCP login:

- Install gdm (xdm replacement) with (xterm needed too, see below):

``` 
yum install gdm xterm
```
- Enable xdmcp in gdm configuration: edit `/etc/gdm/custom.conf` and add `Enable=true` into the [xdmcp](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=xdmcp&linkCreation=true&fromPageId=3816950583) section:

``` 

[xdmcp]
Enable=true

```
- Start GDM (without starting a local X server):

``` 
gdm --no-console
```

Credits (for xdmcp enable option): [http://www.yolinux.com/TUTORIALS/GDM_XDMCP.html](http://www.yolinux.com/TUTORIALS/GDM_XDMCP.html)

## Submitting LoadLeveler GPU jobs

As per Gene's email 2012-01-30

``` 

#@ class = gpu
#@ group = nesi_test
#@ account_no = /nz/nesi
#@ node_resources = ConsumableMemory(4096mb) ConsumableVirtualMemory(4096mb) GPUDev(2)

GPUDev can be up to 8.

```

## Using VOMS Admin on the command line

Using VOMS Admin on the command line ... to work around bugs in the Web GUI.

- Install voms-admin-client from the OSG repo: 

``` 
yum install voms-admin-client
```
- Install MyProxy client (from either OSG or Globus): 

``` 
yum install myproxy
```

- Get a user certificate for a VO-Admin user:

``` 
MYPROXY_SERVER=myproxy.nesi.org.nz  myproxy-logon -l mencl-shib-99999 -t 168
```

- Get help and a list of VOMS-Admin commands ... and a list of users to test it works


>  voms-admin --help
>  voms-admin --help-commands
>  voms-admin --host voms.bestgrid.org --vo nz list-users
>  voms-admin --help
>  voms-admin --help-commands
>  voms-admin --host voms.bestgrid.org --vo nz list-users

 **Use the add-member command:*add-member GROUPNAME USER** (user should be DN-CA couple  when the --nousercert option is set)

>  voms-admin --host voms.bestgrid.org --vo nz --nousercert add-member /nz/nesi/projects/uoc '/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl' '/C=AU/O=APACGrid/OU=CA/CN=APACGrid/Email=camanager@vpac.org'
>  voms-admin --host voms.bestgrid.org --vo nz --nousercert add-member /nz/nesi/projects/test99999 '/DC=nz/DC=org/DC=bestgrid/DC=slcs/O=University of Canterbury/CN=Vladimir Mencl -2vdKb_4CoiSg1P_uGfB9YTRJLo' '/DC=au/DC=org/DC=arcs/CN=ARCS SLCS CA 1'
>  voms-admin --host voms.bestgrid.org --vo nz --nousercert add-member /nz/bestgrid '/C=TW/O=AP/OU=GRID/CN=Michael Keller 187411' '/C=TW/O=AS/CN=Academia Sinica Grid Computing Certification Authority Mercury'

## Getting the list of VOMS users

Access: 

>  [https://voms.bestgrid.org:8443/voms/nz/services/VOMSCompatibility?method=getGridmapUsers](https://voms.bestgrid.org:8443/voms/nz/services/VOMSCompatibility?method=getGridmapUsers)

or

>  [https://voms.bestgrid.org:8443/voms/nz/services/VOMSCompatibility?method=getGridmapUsers&container=/nz](https://voms.bestgrid.org:8443/voms/nz/services/VOMSCompatibility?method=getGridmapUsers&container=/nz)

## Extending wall clock limit for a job on SGE

Can be done as a normal user (owning the job) with:

>  qalter -l h_rt=480:0:00 31844

## Upgrading from GT5 to GT6 and OSG 3.1 to OSG 3.2

Upgrading an (RHEL or CentOS 6) Linux system from GT5 + OSG 3.1 to GT6 + OSG 3.2 

- Switch the RPM repo packages:


>  yum remove osg-release Globus-repo-config.centos
>  yum localinstall [http://repo.grid.iu.edu/osg/3.2/osg-3.2-el6-release-latest.rpm](http://repo.grid.iu.edu/osg/3.2/osg-3.2-el6-release-latest.rpm)
>  yum localinstall [http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo-latest.noarch.rpm](http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo-latest.noarch.rpm)
>  yum remove osg-release Globus-repo-config.centos
>  yum localinstall [http://repo.grid.iu.edu/osg/3.2/osg-3.2-el6-release-latest.rpm](http://repo.grid.iu.edu/osg/3.2/osg-3.2-el6-release-latest.rpm)
>  yum localinstall [http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo-latest.noarch.rpm](http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo-latest.noarch.rpm)

- Remove any modified repo config files left behind


>  rm /etc/yum.repos.d/Globus-repo-config.centos.repo.rpmsave
>  rm /etc/yum.repos.d/Globus-repo-config.centos.repo.rpmsave

- Remove packages dropped form globus


>  yum remove grid-packaging-tools
>  yum remove grid-packaging-tools

 **Fix repository priorities:*Yikes**: Both osg and Globus repo now have a priority of 98 (CLASH), with the default (for e.g. EPEL) being 99.

- 
- Note that as EPEL now also has lcmaps and voms, OSG must come before EPEL.
- So edit priority of GT60 from 98 (equal to osg) to 90 (before OSG and EPEL): edit `/etc/yum.repos.d/globus-toolkit-6-stable-el6.repo` and set: 

``` 
priority=90
```

- Update to new packages: 

``` 
yum update
```
- And sort out any issues (new files left as .rpmnew / old files as .rpmsave) Recommended reading h1. # [Globus Toolkit](http://www.globus.org/toolkit/docs/4.0/) Primer [PDF](http://www.globus.org/toolkit/docs/4.0/key/GT4_Primer_0.6.pdf)

1. [VOMRS](http://www.uscms.org/SoftwareComputing/Grid/VO/) User Guide [PDF](http://www.uscms.org/SoftwareComputing/Grid/VO/vox.pdf) - VOMRS Glossary Grid related problems I've been strugling with h1. ... and hopefully solved.

## RFT staging fails

I occasionally saw that a gateway was rejected all job staging, including the implicit cleanup stage which occurs even for jobs submitted with `globusrun-ws -s -s submit ... -c command`.  The errror message was:

>     globusrun-ws: Job failed: Staging error for RSL element fileCleanUp.

After examining `container-real.log`, I saw that RFT's start method was failing with a NullPointer exception.  Further reading revealed that the RFT failed to create a MySQL connection at the time it was started - as also shown by the following excerpt from the Globus-WS container startup captured in `container-real.log`:

``` 

 2008-01-15 17:38:04,733 WARN  service.ReliableFileTransferHome [main,initialize:97] \
    All RFT requests will fail and all GRAM jobs that require file staging will      \
    fail.com.mysql.jdbc.CommunicationsException: Communications link failure due to underlying exception:
 
 ** BEGIN NESTED EXCEPTION **
 
 java.net.ConnectException
 MESSAGE: Connection refused
 
 STACKTRACE:
 
 java.net.ConnectException: Connection refused
         at java.net.PlainSocketImpl.socketConnect(Native Method)
         at java.net.PlainSocketImpl.doConnect(PlainSocketImpl.java:333)
         at java.net.PlainSocketImpl.connectToAddress(PlainSocketImpl.java:195)
         at java.net.PlainSocketImpl.connect(PlainSocketImpl.java:182)
         at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:366)
         at java.net.Socket.connect(Socket.java:520)
         at java.net.Socket.connect(Socket.java:470)
         at java.net.Socket.<init>(Socket.java:367)
         at java.net.Socket.<init>(Socket.java:209)
         at com.mysql.jdbc.StandardSocketFactory.connect(StandardSocketFactory.java:173)
         at com.mysql.jdbc.MysqlIO.<init>(MysqlIO.java:268)
         at com.mysql.jdbc.Connection.createNewIO(Connection.java:2745)

```

It is crystal clear - MySQL wasn't running when RFT was starting, RFT initialization failed, and all job staging indeed fails.  The problem can be solved by restarting the Globus-WS container.  I have however also looked at why it actually can happen.

``` 

# ls -1 /etc/rc.d/rc3.d/S99*
/etc/rc.d/rc3.d/S99globus-ws
/etc/rc.d/rc3.d/S99local
/etc/rc.d/rc3.d/S99mysql

```

Yes, that explains it: globus-ws is started before mysql, and it boils down to a race condition whether mysql succeeds to start before the globus-ws container gets in its background initialization to the point where it starts up RFT....

Well, I did not decide on the startup order, vdt-control did.... I have reported this to vdt-discuss and I'll see whether a fix emerges.  Otherwise, a manual edit of the symlinks in rc.d would do...

## Fixing startup order

To fix the startup order to avoid the above problem, run the following commands:

``` 

sed '/^# chkconfig:/c # chkconfig: 345 97 09' --in-place=.ORI /etc/rc.d/init.d/mysql 
sed '/^# chkconfig:/c # chkconfig: 345 98 04' --in-place=.ORI /etc/rc.d/init.d/globus-ws 
chkconfig mysql reset
chkconfig globus-ws reset

```


## Fixing shutdown

In CentOS 4.6 (can't tell for past releases), `/etc/rc.d/rc` won't run the shutdown sequence for services which did not put a stamp in /var/lock/subsys with heir name.  On Ng2 gateways, that particularly applies to mysql and globus-ws.  The VDT-created control scripts do not do that, and consequently, globus-ws and mysql won't shutdown cleanly when the gateway is shutdown.  Below are patches which add proper interaction with the CentOS subsystem management to the VDT-created scripts.

Note that even after applying these patches, to have the services stopped correctly the next time the virtual machine shuts down, you have to manually create the subsystem stamps:

>  touch /var/lock/subsys/{globus-ws,mysql}

Apply this patch to `/etc/rc.d/init.d/globus-ws`:

``` 

--- globus-ws-fixed-start-seq   2008-02-05 16:29:47.000000000 +1300
+++ globus-ws   2008-02-12 16:00:18.000000000 +1300
@@ -37,6 +37,7 @@
     fi

     container_exit=$?
+    if [ $container_exit -eq 0 ] ; then touch /var/lock/subsys/globus-ws ; fi

     if [ $container_exit -eq 3 ]; then
         # Error 3 means that it is already running. We don't consider that to be an error
@@ -47,6 +48,7 @@

 elif [ "$1" = "stop" ] ; then
     $VDT_LOCATION/globus/sbin/globus-stop-container-detached
+    rm -f /var/lock/subsys/globus-ws
 else

   echo "Usage: [start | stop]"

```

And this one to `/etc/rc.d/init.d/mysql`:

``` 

--- mysql-fixed-start-order     2008-02-05 16:29:43.000000000 +1300
+++ mysql       2008-02-12 15:50:45.000000000 +1300
@@ -219,6 +219,7 @@
       then
         touch /opt/vdt/mysql/var/mysql
       fi
+      touch /var/lock/subsys/mysql
     else
       log_failure_msg "Can't execute $bindir/mysqld_safe"
     fi
@@ -240,6 +241,7 @@
       then
         rm -f /opt/vdt/mysql/var/mysql
       fi
+      rm -f /var/lock/subsys/mysql
     else
       log_failure_msg "MySQL PID file could not be found!"
     fi

```

## /C=NZ/O=BeSTGRID certificates not being recognized

That happened when I had old `/.globus/certificates`<sub> CA bundle that did have the old signing_policy for APACGrid CA - and this bundle took priority over </sub>`/etc/grid-security/certificates`<sub>.  The old bundle was until recently still distributed with Grix - but Markus has fixed the Grix distribution recently, and also included a provision to replace the old bundle with a new one in user's </sub>`/.globus/certificates` directory.

## GPIcalc job not running for a user

If the compile job of gpicalc fails with a GridFTP error, check that the user's credentials are accepted at ng2.vpac.org (where the source code for gpicalc is transfered from).  That basically means that only members of NGAdmin can run the gpicalc test job.

## GPIcalc compile job failing on HPC

The GPIcalc compile job may fail in the CleanUp state: this is because the job assumes a `.o` file would be created as an intermediate product by the Fortran compiler, and the compile job comes with two CleanUp directives: remove the source code (`.f`) and the `.o` file, and leave only the executable.  The issue can be easily fixed by removing the directive for the `.o` file from the job description.

## GridFTP firewall issues

Failing `globus-url-copy` in MLSD command ... because of firewall issues.

In this case, globus-url-copy was using passive mode, opening connections to ports where the server was listening.  In this case, it failed, because even though the server was correctly configured to use ports in a range (`GLOBUS_TCP_PORT_RANGE=40000,41000`), the client machine did not have this range fully open on the firewall.

I have also considered whether `GLOBUS_TCP_SOURCE_RANGE` might provide solution: no, it only affects what TCP source port will be used when opening a connection - not really used by firewalls these days.

## Fetch-CRL failing on ng2.massey.ac.nz

When `fetch-crl` fails to download URLs from a cron job (but downloads them from an interactive session), it may be because the `http_proxy` environment variable must be set for the fetch-crl cron job (but it may be set in the environment for an interactive session, as it was done in `/etc/profile.d/proxy.sh` at `ng2.massey.ac.nz`.

To set the environment variable for the cronjob, create an executable file `/etc/sysconfig/fetch-crl` with the content:

>  export http_proxy="http://www-cache3.massey.ac.nz"

## Globus creating references with IP address instead of hostname

The ARCS Build scripts take care of that.  Re-apply the change if it had been lost: in `/opt/vdt/globus/etc/globus_wsrf_core/server-config.wsdd`, add 

## MDS broken

Symptoms: MDS dnoes not run mpi-exec, does not contribute content to the central index, and every 5 minutes prints:

``` 

2009-02-24 10:49:59,918 WARN  transforms.GLUESchedulerElementTransform [Timer-5,transformElement:377] Unhandled exception during GLUE ComputeElement transformation
java.lang.Exception: Batch provider generated no useful information.
        at org.globus.mds.usefulrp.rpprovider.transforms.GLUESchedulerElementTransform.transformElement(GLUESchedulerElementTransform.java:121)
        at org.globus.mds.usefulrp.rpprovider.TransformElementListener.executionPerformed(TransformElementListener.java:81)
        at org.globus.mds.usefulrp.rpprovider.ResourcePropertyProviderTask.timerExpired(ResourcePropertyProviderTask.java:155)
        at org.globus.wsrf.impl.timer.TimerListenerWrapper.executeTask(TimerListenerWrapper.java:65)
        at org.globus.wsrf.impl.timer.TimerListenerWrapper.run(TimerListenerWrapper.java:82)
        at java.util.TimerThread.mainLoop(Timer.java:512)
        at java.util.TimerThread.run(Timer.java:462)

```

This likely happens when the system is configured to use a local job scheduler which is not reachable.

When `globus/libexec/globus-scheduler-provider-pbs` returns an error (prints to stderr), MDS does invoke mip-exec and does not process upstream registration.  Fix your local scheduler (... or hack the script not to return an error state)

Note that when the scheduler-provider script returns no ***Queue*** element, but at least does not print an error, MDS will still print the above exception, but will proceed to invoke MIP.  Just make sure your script does not print to stderr.

## Java PKI operations failing with SecurityException: JCE cannot authenticate the provider BC

Starting with Java 6u16, Grix & Grisu have started having a problem: any attempt to use the Bouncy Castle JCE provider (thus any attempts to use X509 certificates in PEM format) have been failing with:

>  SecurityException: JCE cannot authenticate the provider BC 

Based on the [posts by Jodeleit at Sun forums](http://forums.sun.com/thread.jspa?threadID=5389796&start=15), I've been able to narrow it down a bit further - to a quite usable workaround (which still has to be done by each user and I would not dare to ask unskilled users to follow).

With some testing, I could confirm the SecurityException: JCE cannot authenticate the provider BC starts kicking in on the next run after a user permanently accepts the Bouncy Castle code-signing certificate.

And the way to remedy that is to

1. Delete the Bouncy Castle certificate from the list of trusted certificates and
2. Delete bcprov.jar from the list of cached resources.

Both can be done from the Java Control Panel (or by running javaws -viewer).

This looks to me like a bug in how the JavaWS engine handles trust - if the BCPROV JCE can be verified with a user-trusted certificate, it's somehow labeled with that (as the source of trust) and is not accepted as a JCE provider anymore.

I hope Sun will fix this sometime soon.

## How do I browse an old revision of a subversion repository through the web view?

- Append something like this to your repository URL: 

``` 
!svn/bc/<revision_number>/
```
- E.g. 

``` 
http://www.example.com/svnrepository/!svn/bc/3/
```

Thanks to: [http://stackoverflow.com/questions/651305/how-do-i-browse-an-old-revision-of-a-subversion-repository-through-the-web-view](http://stackoverflow.com/questions/651305/how-do-i-browse-an-old-revision-of-a-subversion-repository-through-the-web-view) PBS specific stuff h1. h2. Configuring PBS to use CP instead of SCP

In your pbs_mom.conf (likely, `/var/spool/torque/mom_priv/config`) put:

>  $usecp *:/home /home Cluster specific knowledge ==

## AUT Nautilus

- Compile MPI code with LAM


>  PATH=$PATH:/opt/lam-7.0.6/bin
>  mpicc ...
>  PATH=$PATH:/opt/lam-7.0.6/bin
>  mpicc ...


- Run application with:

``` 

 PATH=/opt/lam-7.0.6/bin:$PATH
 lamboot -H
 mpiexec <program> <arguments>
 lamclean
 lamhalt -H

```
