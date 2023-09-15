# Set up proxy certificates

`Getting Started Roadmap`

# Introduction

Some applications, such as the [alternative webDAV clients for the data fabric](using-the-datafabric.md), do not use the same security and authorisation model as BeSTGRID. In these case short lifespan certificates (SLCs) can be issued from the ARCS MyProxy service.

These certificates are issued against either a [Grid Certificate](grid-certificate.md) or via an institutional Identity Provider (IdP) service registered with the [Tuakiri](category-tuakiri.md) New Zealand Access Federation.

# Prerequisites

- Grix will need to be installed
- Authorisation to access BeSTGRID services by either of:
	
- Being issued a [Grid Certificate](grid-certificate.md)
- An institutional IdP registered with [Tuakiri](category-tuakiri.md)

**NOTE:** Only [Grid Certificate](grid-certificate.md)s can be used to create SLCs with MyProxy from behind a HTTP Proxy.
