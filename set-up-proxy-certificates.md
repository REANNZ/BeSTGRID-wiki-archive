# Set up proxy certificates

`Getting Started Roadmap`

# Introduction

Some applications, such as the [alternative webDAV clients for the data fabric](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Using_the_DataFabric&linkCreation=true&fromPageId=3816950916), do not use the same security and authorisation model as BeSTGRID. In these case short lifespan certificates (SLCs) can be issued from the ARCS MyProxy service.

These certificates are issued against either a [Grid Certificate](/wiki/spaces/BeSTGRID/pages/3816950618) or via an institutional Identity Provider (IdP) service registered with the [Tuakiri](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Category__Tuakiri&linkCreation=true&fromPageId=3816950916) New Zealand Access Federation.

# Prerequisites

- [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950916) will need to be installed
- Authorisation to access BeSTGRID services by either of:
	
- Being issued a [Grid Certificate](/wiki/spaces/BeSTGRID/pages/3816950618)
- An institutional IdP registered with [Tuakiri](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Category__Tuakiri&linkCreation=true&fromPageId=3816950916)

**NOTE:** Only [Grid Certificate](/wiki/spaces/BeSTGRID/pages/3816950618)s can be used to create SLCs with MyProxy from behind a HTTP Proxy.
