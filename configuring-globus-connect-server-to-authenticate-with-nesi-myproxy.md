# Configuring Globus Connect Server to Authenticate with NeSI MyProxy+

Globus Connect Server (GCS) is a software package provided by Globus as an add - on to their web based data transfer service. It can be used to enable access to an institutional data store through the Globus web service This manual covers the configuration of GCS in a way that allows an institution's users to access their share on the data store by authenticating with the Globus web service through the Tuakiri Access Federation.

There are a multitude of different technologies and systems used to provide institutional storage, and just as many ways to provide institution wide user authentication. Therefore this guide can not provide an exhaustive manual for all possible setups, and it only outlines the configuration settings that are required to enable GCS to perform authentication with the NeSI MyProxy+ service. The configuration of GCS to properly integrate with an institution's data store is left to the institution's IT personnel.

# Prerequisites

- linux based server
- institutional users' accounts mapped to the server, with their shares mounted as their home directories (in a performant way)
- fast network connection from the server to the network where the targets for data transfers reside in (typically REANNZ / KAREN network)

The networking prerequisites listed in the [Globus Connect Server Installation Manual](https://support.globus.org/entries/23857088-Installing-Globus-Connect-Server) must be met as well, whereas the requirements pertaining to user authentication can be ignored.

# Installation

- Download the applicable package for 'Globus Connect Server' from [Globus Connect download page](https://support.globus.org/entries/24044351-Globus-Connect-Download-Links).
- Install according to the installation instructions outlined in the [Globus Connect Server Installation Manual](https://support.globus.org/entries/23857088-Installing-Globus-Connect-Server).
	
- When editing `/etc/globus-connect-server.conf`, change the settings as follows:

``` 

 [Endpoint]
 Name = <descriptive name for users to use in the Globus web interface>
 Public = True ;make endpoint visible to users

 [Security]
 IdentityMethod = OAuth
 AuthorizationMethod = Gridmap

 [GridFTP]
 RestrictPaths = RW~ ;restrict users to only be able to access their home directories

 [MyProxy]
 ;Server = %(HOSTNAME)s ;commented out to prevent MyProxy server from being installed locally

 [OAuth]
 Server = myproxyplus.nesi.org.nz ;NeSI's MyProxy+ server

```

- Configure GCS to trust MyProxy+
	
- Download the MyProxy+ CA certificate and configuration files from [here](https://myproxyplus.nesi.org.nz/certs/myproxyplus.nesi.org.nz_certificates.tar.gz)
- Unpack in `/var/lib/globus-connect-server/grid-security/certificates`

# User Mapping

In order for authentication with MyProxy+ to work, GCS needs to be made aware of the mapping between user identities as provided by MyProxy+ and user accounts present on the host GCS runs on. For this purpose, the file `/etc/grid-security/grid-mapfile` has to be created, and all the desired user mappings have to be entered into it. The easiest way to achieve this is by using the following command:

``` 

  grid-mapfile-add-entry -ln <local account name> -dn "<MyProxy+ issued identity>"

```

In order for users to find out their MyProxy+ issued identity, they can log into Globus with their Tuakiri identity, then go to 'Manage Identities'. In there they will find an entry called 'Tuakiri linked at sign in'. In this entry, the 'X.509 Subject' is the string that has to be entered into the mapfile.

Similarly {{ grid-mapfile-delete-entry}} can be used to delete mappings, and `grid-mapfile-check-consistency` can be used to check the consistency of the mappings in the file.
