# GridTechWG-20101125

[Grid Technical Working Group](/wiki/spaces/BeSTGRID/pages/3816950451): meeting November 25, 2010.

## Program

One more TWG on user managemenent, tomorrow (Nov 25) at 10am.

## Minutes

Attending: Vladimir Mencl, Markus Binsteiner, Kevin Buckley, Nick Jones, Donald Neal, Yuriy Halytstkyy, Andrey Kharuk

## Outcome

We have agreed on the need to have a solution that would support the following use cases:

### Use cases

#### Use case 1: One step registration in Grisu=

Users should be able to access Grisu "in a one step process", where after logging in into Grisu with their institutional identity, they would be able to submit jobs to at least some computational capacity without having to register anywhere else.  

They might still need to extra registration steps to get access to additional capacity, but at least some ("demo BeSTGRID") should become available straight after signing into Grisu.

#### Use case 2: DataFabric user details

The DataFabric would be left open to automatically create accounts as users access the DataFabric for the first time.  We would however want to have a way to automatically register the details of the users getting setup on the DataFabric.

#### User case 3: DataFabric webDAV mount password

The service would also have a way for users to set a password for mounting the DataFabric via webDAV.

#### Use case 4: Non-Grisu Grid services=

Users who use the BeSTGRID computational grid via other ways then Grisu (GsiSSH, Grisu python API, ...) would need a way to register for the computational grid via other means - such as a web interface.

#### Use case 5: Group management

In the future, this service would also allow users to register for membership in individual groups on the 

### Proposed solution

The solution would be centered around a simple web-based service that would be providing several interfaces - web interfaces protected via Shibboleth and possibly also a RESTful interface (this might be used by Grisu Swing client, but it may prove easier to make Grisu Swing Client use the Shibboleth-protected web interface).

At the backend, the service would be registering users into a new BeSTGRID VOMS server.  To facilitate immediate login, the service would also have a way to initiate a user database reload at all BeSTGRID GUMS servers - or at least those GUMS servers supporting the DEMO VO.  Alternatively, the GUMS servers might just be configured to a really short reload interval (1m) and the service would cause the first login to wait.

- Use case 1 would be supported by modifying Grisu Swing Client to trigger the user registration workflow (accessing the user registration service on user's behalf) if the user is not registered for BeSTGRID services yet.

- Use case 2 would be supported by the already available code to register user details.

- Use case 3 would be supported by having a Shibboleth protected web interface for setting a webDAV password (similar to Gmail with Shibboleth login allowing to set an IMAP password)

- Use case 4 would be supported by a Shibboleth protected web interface.

- Use case 5 would be implemented as an extension of the Shibboleth protected web interface.
