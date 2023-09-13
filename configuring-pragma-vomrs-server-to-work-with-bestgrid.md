# Configuring PRAGMA VOMRS server to work with BeSTGRID

# Fixing permissions after DN change

Due to switching to the new PRAGMA CA, the DN of the VOMRS server had changed.  Consequently, the VOMS/VOMRS synchronization broke, because the VOMRS server, presenting the host certificate with the new DN, was no longer trusted.  The following steps made the new host certificate DN a trusted DN in the VOMS database.

``` 

# mysql
>  use voms_PRAGMA;
>  insert into admins values (7, '/DC=NET/DC=PRAGMA-GRID/OU=SDSC/CN=vomrs-pragma.sdsc.edu', NULL, 154); 
>  insert into acl2_permissions values (1,4095,7); 
>  insert into acl2_permissions values (2,4095,7);

```

Also, to let the page [https://vomrs-pragma.sdsc.edu:8443/voms/PRAGMA/Configuration.do](https://vomrs-pragma.sdsc.edu:8443/voms/PRAGMA/Configuration.do) present the correct configuration information, I have also changed two files in `/opt/vdt/vdt-app-data/voms/voms-admin/PRAGMA` which contained the old DN:

- `vomses`, had the wrong subject DN and now contains: 

``` 
"PRAGMA" "vomrs-pragma.sdsc.edu" "15001" "/DC=NET/DC=PRAGMA-GRID/OU=SDSC/CN=vomrs-pragma.sdsc.edu" "PRAGMA"
```
- `voms.service.properties`, which had old incorrect entries `voms.trusted.admin.subject` and `voms.trusted.admin.ca`: fixed to contain:

``` 

voms.trusted.admin.subject =  /DC=NET/DC=PRAGMA-GRID/OU=SDSC/CN=vomrs-pragma.sdsc.edu
voms.trusted.admin.ca = /DC=NET/DC=PRAGMA-GRID/CN=PRAGMA-UCSD CA

```

# Granting permission to list members

The right command to allow any authenticated host (grid gateway or gums server) to retrieve the list of members is:

>  voms-admin --vo PRAGMA add-ACL-entry /PRAGMA ANYONE VOMS_CA CONTAINER_READ,MEMBERSHIP_READ true 

# Accessing VOMS from GUMS and edg-mkgridmap

VOMSAdmin 2.0 package, installed on the PRAGMA VOMRS server, returns the data in a slightly different format:

``` 

 <soapenv:Envelope>
     <soapenv:Body>
     <getGridmapUsersResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
     <getGridmapUsersReturn soapenc:arrayType="soapenc:string[11]" xsi:type="soapenc:Array">
       <getGridmapUsersReturn xsi:type="soapenc:string">/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl</getGridmapUsersReturn>

```

instead of

``` 

 <soapenv:Envelope>
     <soapenv:Body>
     <getGridmapUsersResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
     <getGridmapUsersReturn xsi:type="soapenc:Array" soapenc:arrayType="xsd:string[53]">
       <item>/C=AU/O=APACGrid/O=BeSTGRID/OU=University of Canterbury/CN=Colin John McMurtrie</item>

```

Old edg-mkgridmap (2.8.0) does not understand the server response, but a new one, 3.0.0, available from [http://eticssoft.web.cern.ch/eticssoft/repository/org.glite/edg-mkgridmap/](http://eticssoft.web.cern.ch/eticssoft/repository/org.glite/edg-mkgridmap/) works with that all fine. 

# Pending Issues

- VOMS/VOMRS Synchronization fails

- Grix access to PRAGMA VOMRS fails: Grix thinks I'm not a member.

`//opt/vdt/tomcat/v55/logs/vomrs_pragma.log` says:

``` 

07/16/08 18:15:02,789 :INFO :TP-Processor1:fnal.vox.vomrs.error.VOMRSException.<init>: Member not found - DN(/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl/CN=proxy) ca(/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl)

```

Looks like we are missing support for proxies in Apache/Tomcat - should we be running Tomcat directly?

# Configuring Tomcat proxy-certificate aware connector

In the default installation, Tomcat won't recognize proxy certificates.  In such a configuration, Grisu is not able to inquire about group membership nor request VOMS proxies.  Also, this may be linked to some problems I had with creating voms proxies with `voms-proxy-init`

I have thus followed Sam Morrison's recommendation documented in his [VOMRS installation notes](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallVomrs).

The steps to make Tomcat recognize proxy certificates are:

- Copy jar files implementing the proxy-certificate aware connector from the VOMRS server lib directory to the Tomcat lib directory:


>  cd /opt/vdt/vomrs/server/lib
>  cp glite-security-trustmanager.jar glite-security-util-java.jar puretls.jar log4j-1.2.8.jar /opt/vdt/tomcat/v55/server/lib/ 
>  cd /opt/vdt/tomcat/v55/server/lib/ 
>  chown daemon:daemon glite-security-trustmanager.jar glite-security-util-java.jar puretls.jar log4j-1.2.8.jar 
>  cd /opt/vdt/vomrs/server/lib
>  cp glite-security-trustmanager.jar glite-security-util-java.jar puretls.jar log4j-1.2.8.jar /opt/vdt/tomcat/v55/server/lib/ 
>  cd /opt/vdt/tomcat/v55/server/lib/ 
>  chown daemon:daemon glite-security-trustmanager.jar glite-security-util-java.jar puretls.jar log4j-1.2.8.jar 

- Make sure the host certificate exists as `/etc/grid-security/http/http{cert,key}.pem` and is readable by Tomcat (on VDT systems, both Apache and Tomcat run as daemon):


>  chown daemon:daemon /etc/grid-security/http/http{cert,key}.pem
>  chown daemon:daemon /etc/grid-security/http/http{cert,key}.pem


# Plan

- install PRAGMA-CA on GUMS,all mkgridmap servers
- install pragma bundle on all servers accepting users and/or talking to PRAGMA servers (ng2hpc, ngportal)
	
- hmmm.... the GUMS server might use a separate certificates directory for PRAGMA non-IGTF certs .... but I think we'll have to merge with IGTF anyway - will be simpler then making sure each app knows where else to look for root certs

- talk with Cindy about project groups, asking leaders to submit Project requests.
