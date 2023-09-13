# Auckland GUMS Server

Server is used for centralized user management on grid gateways and gridftp servers. There are two ways it can be used:

1. generate grid-mapfile and put it on hosts
2. have gateway host contact it directly via [PRIMA](http://computing.fnal.gov/docs/products/voprivilege/prima/prima.html) callout

We use the second approach because it allows the user to map to different accounts based on his virtual organization. The grid-mapfile can have only single mapping. On the other hand PRIMA may be difficult to install on non-standard systems (see [compiling](http://www.bestgrid.org/index.php/Setup_PRIMA_on_IBM_p520) PRIMA for AIX for example).

Host: [https://gums.ceres.auckland.ac.nz:8443/gums/](https://gums.ceres.auckland.ac.nz:8443/gums/)

Requires grid certificate in the browser to log in. Easy way to convert grid-certificate into browser-consumable form:

> 1. usercert.pem and userkey.pem are globus certificate and key. cert.p12 - file name for certificate in pkcs12 format that can be imported in
> 2. the browser.
>  openssl pkcs12 -export -in usercert.pem -inkey userkey.pem -out cert.p12

Only nggums admins can change user policies. To add user DN to administrator list execute the following command on nggums host as root:

>  /opt/vdt/tomcat/v55/webapps/gums/WEB-INF/scripts/gums-add-mysql-admin "/C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Yuriy Halytskyy"

it may not work, given our database modifications, so it is better to add admin directly via SQL query:

>  INSERT INTO USER VALUES (NULL,'admins','/C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Andrey Kharuk',NULL,'a.kharuk@auckland.ac.nz');
>  INSERT INTO USER VALUES (NULL,'admins','/C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Yuriy Halytskyy',NULL,'a.kharuk@auckland.ac.nz');

To verify user mapping under particular virtual organization run the following on NG2 machine:

>  /opt/vdt/prima/bin/gums_map_args /opt/vdt/prima/etc/opensaml/ \
>  /etc/grid-security/certificates/ '/C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=ng2hpc.ceres.auckland.ac.nz' \
>  /etc/grid-security/hostcert.pem /etc/grid-security/hostkey.pem \
>  [https://gums.ceres.auckland.ac.nz:8443/gums/services/GUMSAuthorizationServicePort](https://gums.ceres.auckland.ac.nz:8443/gums/services/GUMSAuthorizationServicePort) \
>  "/C=NZ/O=BeSTGRID/OU=The University of Auckland/CN=Yuriy Halytskyy" "/C=AU/O=APACGrid/OU=ARCS/CN=vomrs.arcs.org.au" "/ARCS/BeSTGRID"

Where the last 3 arguments are:

1. User CN
2. VOMRS server DN
	
1. /C=AU/O=APACGrid/OU=ARCS/CN=vomrs.arcs.org.au for new ARCS server
3. User VO

For resilience it is important to store configuration in the database. Go to "Persistense Factories" and tick "store configuration" flag. 

# Usage Scenarios

## Account Per User

Useful for users with strict security requirements. It does not make any sense to create a virtual organization for single user, but we can map an account using gums manual groups.

Example for /CN=Random User/ and grid-random account

1. create **grid-random** account on the cluster and ng2. Connect its home directory via nfs.
2. create **Account Mapper** for account **grid-random**
3. create new **User Group** for /CN=Random User/
	
1. type = manual
2. name = **someUserGroupName**
4. create new **Group To Account Mapper** to associate **someUserGroupName** with **grid-random** account mapper
5. add /CN=Random User/ **Manual User Group Members**.
6. edit **Host To Group Mappings** to include our group to account mapper.
	
1. make sure this mapper goes in front of all more generic mappers.

Much easier way to achieve this:

1. add **Manual Account Mappings** and map directly
2. edit **Host To Group Mappings** to include our group to account mapper.

I discovered this method later so we don't use it yet...

GUMS 1.1 manual user groups are only mapped to standard non-VOMS related proxy.

As of GUMS 1.3 it is possible for manual user group to accept VOMS proxy, when properly configured (.* for FQAN attribute). This is important because new Grix does not let users create standard proxies, so single account scenario can only be accomplished with GUMS 1.3

## Account Per VO

For generic BeSTGRID users (mapped to grid-bestgrid), ARCS administrators (members of /ARCS/NGadmin group) and supported projects.

Example for /ARCS/BeSTGRID VO and grid-bestgrid account

1. create **Account Mapper** for account **grid-bestgrid** unless it exists
2. add new **User Group** for /ARCS/BeSTGRID VO
	
1. type = voms
2. VOMS  Server = ... (select appropriate. We use ARCS for all right now).
3. Remainer URL = ... ( for ARCS it is /ARCS/services/VOMSAdmin
4. VO/Group = /ARCS/BeSTGRID
3. create new **Group To Account Mapper** to associate our new user group with  account mapper
4. Edit **Host to Group** Mappings to add group to account mapper to the host
	
1. make sure it goes after all individual mappings
5. go to **Update VO Members** and click on update
6. verify with **Generate Grid-Mapfile**

# Extra documentation

[NGGums Canterury Setup](http://www.bestgrid.org/index.php/Setup_NGGums_at_University_of_Canterbury)
