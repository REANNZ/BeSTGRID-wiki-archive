# Setting up a Data Transfer Node

## Table of Contents 
 - [Overall Architecture and Planning](#overall-architecture-and-planning)
-- [DTN Overview](#dtn-overview)
-- [DTN Authentication Options](#dtn-authentication-options)
-- [DTN Authentication Scenarios](#dtn-authentication-scenarios)
-- [DTN Planning Decisions](#dtn-planning-decisions)
- [Preliminaries](#preliminaries)
-- [OS requirements](#os-requirements)
-- [User Account and Storage System Integration](#user-account-and-storage-system-integration)
-- [Network requirements](#network-requirements)
-- [Certificates](#certificates)
--- [Grid certificate](#grid-certificate)
--- [Browser-facing host certificate](#browser-facing-host-certificate)
- [Installation](#installation)
-- [Globus Connect Server](#globus-connect-server)
-- [Installing Globus GridFTP server from package repositories](#installing-globus-gridftp-server-from-package-repositories)
-- [Installing Globus GridFTP server from source](#installing-globus-gridftp-server-from-source)
- [Additional configuration](#additional-configuration)
-- [Installing MyProxyPlus certificates](#installing-myproxyplus-certificates)
-- [Add IGTF certificates](#add-igtf-certificates)
-- [Enable Globus.org Sharing](#enable-globus.org-sharing)
-- [Enable logging](#enable-logging)
- [Account mapping - AuthTool](#account-mapping---authtool)
-- [Installing AuthTool](#installing-authtool)
-- [AuthTool Installation - Preliminaries](#authtool-installation---preliminaries)
-- [AuthTool Installation - SELinux considerations](#authtool-installation---selinux-considerations)
-- [Install pwauth - local authentication tool](#install-pwauth---local-authentication-tool)
-- [Installing AuthTool itself](#installing-authtool-itself)
A [Data Transfer Node](http://fasterdata.es.net/science-dmz/DTN) (DTN) is a purpose built system, connected to a data storage system and allowing to transfer data in and out of the storage system with state of the art throughput and performance.

In this context, we plan for the DTN to use GridFTP as the transfer protocol - and have the transfers managed by [Globus.org](https://www.globus.org/).

We also assume the data storage is attached to an HPC system, but this does not necessarily have to be the case.

When transferring data, the users authenticate to the GridFTP server with X509 credentials, but access data on the storage system with the privileges associated with their personal accounts. This means a DTN needs to be quite tightly integrated with the storage system: to understand the same user accounts as exist on the data storage system - or at least the accounts of the users who would be using the DTN. (This guide provides one suitable implementation of a self service tool for establishing mappings between the users' X509-based identities and their local accounts).

Overall, a DTN needs:

- a fast connection to the data storage - in case of cluster filesystems like GPFS or lustre, "be part of the cluster" (and as per above, also connecting to user accounts).
- a fast connection to the outside network (at least 1Gbps, ideally 10Gbps, and either bypassing the firewall or being behind a well-performing firewall).

This guide documents the setup of a DTN for use with [NeSI](http://www.nesi.org.nz/) HPC systems, but can be used outside of this context as well.

# Overall Architecture and Planning

## DTN Overview

The very high level view of the DTN is that:

- The DTN runs a Globus GridFTP server
- Users authenticate to the GridFTP server with X509 certificates and get mapped to a local account
- Users submit transfer requests at Globus.org
- and this services authenticates on behalf of the users
- and transfers files to / from the DTN

However, this high-level overview leaves several questions open:

- (1) What type of X509 certificates users use and where they get them from
- (2) How the GridFTP server maps X509 certificates to local accounts.
- (3) How Globus.org gets these certificates to act on behalf of the users
- (4) And ... what server certificate is the GridFTP server using and how do users / Globus.org establish trust with the certificate.

## DTN Authentication Options

There are several options for the above questions - some of them can be combined, some cannot.

- Users can use use the following types of certificates:
- (1a) Certificates issued by a local MyProxy CA running directly on the DTN.
- (1b) Certificates issued by a MyproxyOAuth server (registered with Globus.org)
- (1c) Long-lived X509 certificates issued by an IGTF accredited CA

- The GridFTP server can map these certificates:
- (2a) In case of certificates issued by a local MyProxy CA (1a), decode the local username stored in the certificate and map to the account of that name.
- (2b) Use a local grid map file - administered by the local system administrator.
- (2c) Use a local grid map file - with users self-administering their mapping with the Auth Tool.

- Globus.org can use these mechanisms for users to authenticate
- (3a) Users authenticate through Globus.org website and Globus.org website retrieves the X509 certificate directly by talking to the MyProxy CA on the DTN (1a) directly. Note: this has the downside that he password for the user's DTN account is sent through Globus.org.
- (3b) Users authenticate through Globus.org website and Globus.org website retrieves the X509 certificate by talking to a centralized MyProxy server (typically long-lived X509 certificate (1c) that the user has stored in the centralized MyProxy server). Note: this still has the downside that a password is sent through Globus.org, but this time, it is only the password for the copy of the X509 credential in the centralized MyProxy server.
- (3c) Users authenticate to Globus.org with a MyProxyOAuth server - and possibly use federated single sign on to authenticate to the MyProxyOAuth server. In this case, no password is sent to Globus.org (and neither to the MyProxyOAuth server, only to the user's home IdP).

## DTN Authentication Scenarios

(SC1) The simplest case is configuring the DTN as a pure Globus Connect Server, running a local MyProxy CA.

- Mapping done based on name in the certificate (2a)
- Users only use local MyProxy CA certificates (1a)
- Globus.org gets credentials only via the local MyProxyCA (3a)
- PROS: This makes the setup very easy
- All of the configuration is done by the Globus Connect Server setup scripts
- No external certificates to be obtained neither on the server nor the user side
- Mapping is done based on the username stored in the certificate - (1a)
- CONS: But the drawbacks are:
- The DTN can only be accessed with the local MyProxy CA certificate (and no other certificates)
- The GridFTP server certificate and the user certificates would only be trusted by Globus.org
- Users can only access the server with X509 certificates issued by the local MyProxy CA
- The GridFTP server would really be only usable from Globus.org
- User credentials (username+password) for the storage system are sent through Globus.org
- No single sign on at Globus.org - the user would have to explicitly activate the DTN endpoint each time the credentials cached by Globus.org expire.

(SC2) Configuring the DTN as a Globus Connect Server, but use an external MyProxyOAuth server.

- Mapping now to be explicitly configured (2b) or (2c).
- Users can use either MyProxyOAuth (1b) or long-lived X509 certificates (1c)
- Globus.org can get certificates with either MyProxyOAuth (3c) or external centralized MyProxyServer (3b)
- PROS:
- This improves on the previous scenario in that user credentials no longer pass through Globus.org
- It is possible to configure mapping also for other X509 certificates (like long-lived IGTF CA certificates)
- Globus.org provides single sign on: login once with the MyProxyOAuth server to activate all endpoints using the same MyProxyOAuth server.
- CONS:
- However, it is now necessary to also configure account mapping - either self-service or administered by a sysadmin.
- Other CONs from (SC1) still persist: the server certificate would only be trusted by Globus.org, and using from outside Globus.org would thus be still quite limited.

(SC1-2) A combination of SC1 and SC2, where the DTN is a pure Globus Connect Server, running a local MyProxy CA, but also accepts an external MyProxyOAuth server.

- Mapping done based on name in the certificate (2a), but can also be explicitly configured (2b) or (2c).
- This relies on a special feature of the globus-gridmap-verify-myproxy callout function, which, after attempting to decode the certificate as a local myproxy certificate also consults a local grid-mapfile.
- Users only use either local MyProxy CA certificates (1a), or MyProxyOAuth (1b) or long-lived X509 certificates (1c)
- Globus.org gets credentials either via the local MyProxyCA (3a), or MyProxyOAuth (3c) or external centralized MyProxyServer (3b)
- PROS:
- Users can still use the MyProxy CA, where they do not need to establish explicit mapping.
- Users can also use other certificates (myproxyplus, long-lived IGTF)
- No external certificates to be obtained neither on the server nor the user side
- CONS: But the drawbacks are:
- This setup gets rather complicated: while the core install is simple as for SC1, the administrator needs to also configure account mapping.
- The DTN needs to have multiple registration entries in Globus.org (manually create additional endpoint registrations).
- The GridFTP server certificate and the user certificates would only be trusted by Globus.org
- The GridFTP server would really be only usable from Globus.org (unless also configured with a proper host certificate)
- For users using the local MyProxy CA, user credentials (username+password) for the storage system are sent through Globus.org
- No single sign on at Globus.org - the user would have to explicitly activate the DTN endpoint each time the credentials cached by Globus.org expire (except for the MyProxyPlus version of the endpoint).

(SC3) Configure the server as standalone GridFTP server, registered into Globus.org.

- Mapping now to be explicitly configured (2b) or (2c).
- Users can use either MyProxyOAuth (1b) or long-lived X509 certificates (1c)
- Globus.org can get certificates with either MyProxyOAuth (3c) or external centralized MyProxyServer (3b)
- PROS:
- Fully flexible configuration, users can use MyProxyOAuth or long-lived x509 certificates
- Server certificate trusted outside Globus.org (through IGTF)
- GridFTP server ready to use outside Globus.org
- For MyProxyOAuth login, Globus.org provides single sign on: login once with the MyProxyOAuth server to activate all endpoints using the same MyProxyOAuth server.
- CONS:
- Somewhat more involved deployment (including the need to obtain an X509 server certificate)
- Same as in (SC2), it is now necessary to also configure account mapping - either self-service or administered by a sysadmin.

## DTN Planning Decisions

There are several decisions to be made when planning a DTN deployment as discussed above.

Pick one of the scenarios detailed above.

Depending on the requirements:

- Should users be able to use this server outside Globus.org?
- Should users be able to use other X509 credentials (like long-lived IGTF-accredited X509 certificates)
- Would it be a concern (e.g., with the local storage system password management policy) that the credentials travel through Globus.org?

Pick:

- SC1 if you want a simple installation and users would be using the DTN solely via Globus.org, would not be using any other X509 certificates, and passing the local storage systems credentials through Globus.org is not seen as an issue.
- SC2 if you want some flexibility in configuring access to the DTN from outside Globus.org, but Globus.org would still be the main mode of use.
- SC3 if you want the DTN to be flexibly used with other GridFTP clients as well, but want support for Globus.org integration.

And, for SC2 and SC3, decide on whether to install the self-administration account mapping tool (AuthTool), or whether to rely on a local systems administrator to configure the mappings for all users.

# Preliminaries

## OS requirements

This guide assumes the system where DTN will be installed has already been configured.

The following is recommended:

**NOTE**: For performance reasons, we recommend using a physical system and not a virtual machine if at all possible.


The system will need access to the local ITS infrastructure; specifically, it will need:

- DNS
- NTP (and be configured with time synchronization)
- SMTP outgoing server (TBD whether this is a real requirement)

## User Account and Storage System Integration

- The OS must configured to recognize accounts used on the storage system (at least for the users who would be accessing the DTN). Ideally, this would be done via the appropriate PAM module, but the accounts may be created in parallel (but, if password authentication is used on the system, the DTN must be integrated with the authentication management system used - such as Kerberos).
- If password authentication is not used (neither running a local MyProxy server, nor using the self-service account mapping tool), it is not required to have password-based login configured for the user accounts (Globus will only be acting on behalf of the accounts after successful X509 authentication).

- The system have direct (and well performing) access to the directories on the storage system the users would be accessing (like project directories of the users' home directories).

## Network requirements

- The server needs a public (and static) IP address.
- The hostname must resolve to this IP address and the IP address must resolve back to the system's hostname.
- The server may also have a CNAME point to it, but the internal hostname would be the one used in the grid certificate discussed below
- The server needs to be able to open INcoming and OUTgoing TCP connections to ports 2811, 7512(if using local MyProxy), and 50000-51000 (a range of 1001 ports).
- In addition to that, is requires INcoming + OUTgoing UDP to ports 50000-51000 (again a range of 1001 ports).
- In addition to that, OUTgoing TCP connection to ports 80 and 443.
- In addition to that, INcoming TCP connection to ports 80 and 443 if running the self-service user mapping tool locally.
- Note: The outgoing TCP traffic to ports 80 and 443 MAY go through a proxy (if the `http_proxy environment` variable is properly set), but all other traffic must be a direct connection.
- In addition, OUTgoing UDP to port 4810 (Globus usage statistics packets)
- (see [http://www.globus.org/toolkit/docs/5.0/5.0.0/Usage_Stats.html](http://www.globus.org/toolkit/docs/5.0/5.0.0/Usage_Stats.html))
- In addition to that, IF using SC#1 or SC#2 (running `globus-connect-server-setup`), outgoing TCP to port 2223 (outgoing SSH to Globus.org CLI at alternative port number for registering the endpoint).

**Note:** Remember to check the firewall settings on the server itself, as the default install of CentOS may restrict the use of these ports.

**Note**: The above focuses on a DTN open to the whole Internet. If you want a DTN open to a selection of partner sites AND Globus.org, this is the list of fine-grained firewall rules that Globus.org says you'd need (as of June 2015):

``` 

Port 2811 inbound from 184.73.189.163 and 174.129.226.69
-This is for GridFTP control channel traffic
Ports 50000—51000 inbound and outbound to/from Any
-This is for GridFTP data channel traffic
-Data channel traffic is sent directly between endpoints, and is not proxied/intermediated by Globus servers
-We strongly recommend the use of the default range
Port 2223 outbound to 184.73.255.160
-This is to pull cert info from our backend
Port 443 outbound to nexus.api.globusonline.org and 174.129.226.69
-nexus.api.globusonline.org is a CNAME for an Amazon ELB, IP addresses in the ELB are subject to change
-This is to communicate with our REST API
Port 80 outbound to 192.5.186.47
-This is to pull packages from our repo
Port 7512 inbound from 174.129.226.69
-This is for MyProxy traffic
-Needed if server will run MyProxy service
Port 443 inbound from Any
-This is for OAuth traffic
-Needed if server will run OAuth service
-OAuth traffic will come directly from clients using your OAuth service, and will not be proxied/intermediated by Globus servers

```


## Certificates

### Grid certificate

If installing a standalone GridFTP server, you will need to obtain a grid host certificate from an IGTF accredited CA.

For NeSI deployments, we recommend you get the certificate either from [Quo Vadis](https://tl.quovadisglobal.com/) (if your institution is subscribing to AusCERT Certificate Services), or from [Academia Sinica (ASGCCA)](http://ca.grid.sinica.edu.tw/) otherwise.

- To request an ASGCCA host certificate, please follow the [ASGCCA host certificate instructions](http://ca.grid.sinica.edu.tw/certificate/apply_host_cert/apply_host_cert.html).
- For Quo Vadis, generate a CSR manually and submit it at [https://tl.quovadisglobal.com/subscriber](https://tl.quovadisglobal.com/subscriber) as a Grid Certificate request (you will need an SSL Subscriber account for accessing this site)

- If no other software has created the directory `/etc/grid-security` then it needs to be created
``` 

mkdir -p /etc/grid-security
chown -R root:root /etc/grid-security
chmod 755 /etc/grid-security

```


- Install the certificate and private key as `/etc/grid-security/hostcert.pem` and `/etc/grid-security/hostkey.pem` respectively
- The files should be owned by root
- The private key should be readable only to root

### Browser-facing host certificate

If also deploying the Auth Tool, you will also need a browser facing host certificate.

If your grid certificate is issued by QuoVadis, you can also reuse this certificate as a browser facing certificate - it is trusted by browsers too.

Otherwise, please request a standard certificate from your usual (commercial) certificates provider. The name in the certificate should be the hostname users would use to access the Auth Tool on the DTN.

# Installation

## Globus Connect Server

Install Globus Connect Server - do this part if deploying scenarios SC1 or SC2.

Follow instructions at [https://support.globus.org/entries/23857088-Installing-Globus-Connect-Server](https://support.globus.org/entries/23857088-Installing-Globus-Connect-Server) - i.e.:



Note: if necessary, the script can be re-run multiple times and always attempts to configure all the bits necessary. However, the script does not deconfigure anything - so for example, if the script is once run with [MyProxy](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=MyProxy&linkCreation=true&fromPageId=3816948880)` Server` set to localhost and configures a local myproxy server, subsequent runs with this entry commented out would not remove the myproxy server setup and the server needs to be removed manually.

## Installing Globus GridFTP server from package repositories

Do this if installing a standalone GridFTP server (SC3)

The Globus project provides repositories with binaries for a number of common Linux distributions, see the list at [http://toolkit.globus.org/toolkit/downloads/latest-stable/](http://toolkit.globus.org/toolkit/downloads/latest-stable/)
If your OS is listed there, we recommend following this process. For other operating systems, the fall back method is installing from source, documented in the next section.


- Check that the grid host certificate obtained earlier for the server is properly installed in `/etc/grid-security/hostcert.pem` (and private key in `/etc/grid-security/hostkey.pem`)

- Adjust the server configuration by creating `/etc/gridftp.d/local.config` (create the directory if does not exist yet) with:
- A line to set the port range for data connections to the agreed value (also used by Globus.org) of 50000-51000:
``` 
port_range 50000,51000
```


- If desired, a line to set the path restrictions to prevent the users from trawling the whole filesystem. E.g., to allow users to access only their home directory and /projects, use:
``` 
restrict_paths = RW~,RW/projects
```




- Register the endpoint in Globus.org: login to [Globus.org](https://www.globus.org/) with the account the endpoint should be visible under and create a new endpoint with the following parameters:
- Endpoint name: choose a suitable endpoint name
- Visible to: choose Public unless this is a test deployment
- Identity Providers: select "MyProxy OAuth" and enter `myproxyplus.nesi.org.nz` into the URL field.
- Servers: enter your server hostname - and leave the Subject DN blank to let Globus.org derive the expected DN from the hostname.

- If your server is restricted in making arbitrary outgoing TCP connections, tell Globus.org to only ask the server to connect to ports in the 50000-51000 range:
- Log into the Globus Command Line (CLI) interface with:
``` 
ssh <globus-username>@cli.globusonline.org
```


- Modify the endpoint with:
``` 
endpoint-modify --port-range=50000,51000 <endpoint#name>
```



## Installing Globus GridFTP server from source

If your OS distribution is not listed at [http://toolkit.globus.org/toolkit/downloads/latest-stable/](http://toolkit.globus.org/toolkit/downloads/latest-stable/), install from source.

In the ideal situation, it would be the case of


For platform specific details of resolving build issues, please document them here - and possibly refer to the notes on installing [Installing Globus 5.0.0 on AIX](/wiki/spaces/BeSTGRID/pages/3816950721)

# Additional configuration

Most of these tasks are needed only for advanced topics.

## Installing MyProxyPlus certificates

Do this for any of the advanced scenarios (SC2 or SC3) - if this server is to trust


## Add IGTF certificates

Do this if this server is to accept connections for any of the advanced scenarios (SC2 or SC3) - if this server is to trust IGTF user certificates

Install IGTF CA certificates from [OSG repo](https://twiki.opensciencegrid.org/bin/view/Documentation/Release3/YumRepositories#Install_OSG_Repositories)



Now, if this server was installed as a Globus Connect Server, it would have received the initial set of trusted certificates (primarily for Globus.org) in `/var/lib/globus-connect-server/grid-security/certificates`

We now need to merge these two directories:


## Enable Globus.org Sharing

Globus.org provides an additional feature called sharing - which allows a user to select a directory on the DTN they want to share, select who to share with (other users / groups / everyone / future users to receive invitation email), and those users then access the endpoint on behalf of the sharing user.

On the server side, the connections come from Globus.org with a special sharing credential (X509 certificate), and the GridFTP server has to be configured to let this credential access any user account as per configured shares.

On an installation mananged by Globus-Connect-Server, this gets all automatically configured when running `globus-connect-server-setup`.

On a manually installed GridFTP server (SC3) do these steps (as per [http://toolkit.globus.org/toolkit/docs/latest-stable/gridftp/admin/#idp7087088](http://toolkit.globus.org/toolkit/docs/latest-stable/gridftp/admin/#idp7087088))


Note that sharing also needs to be enabled in the Globus.org registration: the endpoint must be registered as managed endpoint (and this is only available to accounts on a [provider plan](https://www.globus.org/provider-plan-configuration)).

To mark an endpoint as managed:

- Log into the Globus Command Line (CLI) interface with:
``` 
ssh <globus-username>@cli.globusonline.org
```


- Modify the endpoint with:
``` 
endpoint-modify --managed-endpoint <endpoint#name>
```



## Enable logging

With the default settings, logging would be turned off.

Configure basic logging by creating `/etc/gridftp.d/logging` with:

> log_module stdio
> log_level info,warn,error
> log_single /var/log/gridftp.log

# Account mapping - AuthTool

For SC1, no action needs to be taken - accounts are being mapped based on the information stored in the user certificate.

For SC2 and SC3, start by creating a blank `/etc/grid-security/grid-mapfile` - or better, add a test mapping for yourself like:

``` 

"/DC=nz/DC=org/DC=nesi/DC=myproxyplus/O=University of Example/CN=Witty Admin AbcdEfgh12341234AbcdEfgh123" myaccount

```

This (with your own certificate DN) is sufficient to test the DTN itself.

For SC2 and SC3, to allow users to authenticate to the DTN, they would need a line in the file too. This could be either done manually by the system administrator, or the users can self-administer their account mappings with the AuthTool.

The rest of the section documents installing the AuthTool.

## Installing AuthTool

For SC2 and SC3, where it is desired for users to self-administer their account mappings (so that this does not have to be done for every DTN user by hand by the sys-admin), install the AuthTool using the following steps.

The AuthTool is actually a collection of two tools:

- One for administering the mappings of certificates issued by the MyProxyOAuth server - users authenticate with their federated login (Tuakiri for NeSI deployments).
- And the second one for administering the mappings of long-lived X509 certificates - in this case, users authenticate with their X509 certificate loaded in the browser.

In both cases, after establishing their external identity, the user will also have to authenticate with a local account. After that, the user would be able to add a mapping of the external identity to the local account. Please note that while a single external identity can only map to a single local account, multiple different external identities can map to the same local account - this may be the case when a user is both using the MyProxyOAuth server AND also has a long-lived X509 certificate used for other scenarios.

The AuthTool can be deployed either on the DTN directly, or could also be deployed on a separate system - in this case, it would be the deployers responsibility to make sure the GridFTP server can access the `grid-mapfile` file managed by the AuthTool. For the rest of this section, we assume the Authtool is being deployed on the DTN directly.

## AuthTool Installation - Preliminaries


Install Shibboleth SP as per [https://tuakiri.ac.nz/confluence/display/Tuakiri/Installing+Shibboleth+2.x+SP+on+RedHat+based+Linux](https://tuakiri.ac.nz/confluence/display/Tuakiri/Installing+Shibboleth+2.x+SP+on+RedHat+based+Linux)

- As an extension, to these instructions, we recommend to instruct ShibSP to mark the session cookies as secure (HTTPS only) - in `/etc/shibboleth/shibboleth2.xml`, in the `Sessions` element, set `cookieProps="https"`
- When registering the SP into the Federation Registry, request the following attributes:
``` 

Requested attributes:
Required:
   commonName: Uniquely identify user across data transfer service nodes.
   auEduPersonSharedToken: Uniquely identify user across data transfer service nodes.
   organizationName: Uniquely identify user across data transfer service nodes.
Optional:
   eduPersonAssurance: Confirm user's identity.
   eduPersonAffiliation: Confirm user's affiliation.

```



The AuthTool itself uses PHP:


## AuthTool Installation - SELinux considerations

RHEL and CentOS 6 come with SELinux - which in particular for Apache provides a very fine-grained set of permissions.

The AuthTool can operate with SELinux still turned on - it is only necessary to correctly label the files installed.

In preparation, install the SELinux management tools so that we can later adjust the SELinux policy with correct file labels as needed:

> yum install policycoreutils-python setools-console

## Install pwauth - local authentication tool

PWAuth is a simple tool for verifying a username and password according to the system settings - typically PAM. PWAuth read the username and password from standard input (as two separate lines) and returns an exit code that either confirms successful authentication (0==SUCCESS), or a non-zero code to indicate failed authentication (such as user account not found or password not accepted for the user account).

PWAuth is then invoked from the web Auth Tool to authenticate the user with the local account.

The following steps install PWAuth:


## Installing AuthTool itself

The AuthTool code is in the BeSTGRID legacy code repository (imported from the BeSTGRID DataFabric SVN repository) at [https://github.com/nesi/BeSTGRID-legacy/tree/master/df/auth/mapauth](https://github.com/nesi/BeSTGRID-legacy/tree/master/df/auth/mapauth)

This directory hierarchy in the SVN repository has three parts:

- Apache config file `httpd-conf/mapauth.conf`
- Sample grid-mapfile (mapfile/grid-mapfile) to go into /opt/mapauth/mapfile (where the working copy would live outside Apache and /etc hierarchies).
- AuthTool web application itself under `www`

To deploy the AuthTool:




- Edit configuration file `/var/www/html/register/config.php` and set:
- The `$site_name` and `$service_name` variables (and others as needed) to describe your DTN
- Adjust the various file paths if using a different deployment hierarchy

> *The Auth Tool is now available as https://*dtn.host.name*/register/



