# GridTechWG-20100325

[Grid Technical Working Group](/wiki/spaces/BeSTGRID/pages/3816950451): meeting March 25, 2010.

## Program

The middleware efforts are now focusing on data services - and we will

have a BeSTGRID DataFabric soon, deployed based on the ARCS DataFabric.

The DataFabric will be providing a web and webDAV interface to iRODS, a

data storage system.  This would allow the users to access the data from

anywhere with their browser - and to mount their data space directly at

their desktop via webDAV for more intesive workflows.

The talk will focus on:

- the middleware architecture of the Data Fabric
- use cases we would support (publishing data, open, closed and

semi-open collaborations, .... )
- projects we would support

In particular for the last point: if you know about users who would want

to store and share large (or small) amounts of data, please bring the

project up at the meeting - or invite the future users.

## Minutes

Attending: Vladimir Mencl, Guy Kloss, Stuart Charters, Tim Molteno, Mik Black, Kevin Buckley, Andrey Kharuk, Yuriy Halytskyy

- Vladimir gave a brief overview of iRODS and of the [iRODS deployment plan](/wiki/spaces/BeSTGRID/pages/3816950597)

- Mik suggests two initial projects:
	
- Cancer microarray data sets (Mik Black + Chris Print)
- [Virtual Screening for Drug Discovery](https://www.bestgrid.org/enablevirtualscreeningfordrugdiscovery) (Jack Flannagan, University of Auckland)

- Tim concerned over explicit storage selection in iRODS, luster FS can do that automatically, should we really use iRODS to manage where data is stored?

- Guy Kloss gave a presentation of Data Finder
	
- soon-to-be-released DataFinder 2.0 could use iRODS as storage resource and catalogue
- [Data Finder slides](http://www.slideshare.net/onyame/organizing-the-data-chaos-of-scientists-presentation)
