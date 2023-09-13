# Data Fabric notes

# Notes/Ideas for a BeSTGRID Data Fabric 

This page intends to collect some ideas and points for discussion on a BeSTGRID data fabric. Even though the current common consensus seems to be to "run with" iRODS, it is intended to be also open towards potential other solutions. Especially as they *may* be more flexible or more easily "Gridified".

For now just a "wild" list of things to throw up and discuss.

# iRODS

- includes rule engine
- includes data replication
- master/slave cataloguing
- problems with iRODS "as a beast" to maintain and integrate
- problems with "Gridification"
- Python interface problems
	
- [PyRods](http://code.google.com/p/irodspython/wiki/PyRods) interface seems to be a bit troublesome at times
- The beginning of an alternative iRODS protocol implementation using Twisted by Russell Sim in the ARCS project: [http://github.com/russell/txirods/tree/master/txirods/](http://github.com/russell/txirods/tree/master/txirods/) (see also: [http://code.arcs.org.au/gitorious/txirods](http://code.arcs.org.au/gitorious/txirods))
- Potentially wrapping the iRODS C libraries using code generation through Ctypes/Ctypeslib or Boost.Python/Py++

# Supporting User Client Application

The [DataFinder](https://wiki.sistec.dlr.de/DataFinderOpenSource) (developed by [Simulation and Software Technology](http://www.dlr.de/sc/en/desktopdefault.aspx) at the German Aerospace Centre) could be a suitable user client supporting researchers' daily data management tasks

- extensible/flexible
- is also based on meta data catalogue, like iRODS
- a variety of data storage backends
	
- since version 2.0 it is easily possible to build an alternative backend storage layer
- this backend layer could bind to iRODS
- or it could bind to some/any of the below mentioned potential storage layers
- provides project specific customisations through GUI and scripting

# Alternative Storage Backends

For discussion alternatives, some suitable raw storage means, that could (easily) be used to base a Data Fabric on top:

- [XtreemFS](http://www.xtreemfs.org/)
	
- Developed in Europe, apparently mainly by the German [D-Grid Initiative](http://www.d-grid.de/) and in context with the (apparently French led) [XtreemOS](http://www.xtreemos.eu/) ambitions
- [Hadoop Distributed File System](http://hadoop.apache.org/common/docs/current/hdfs_design.html)
	
- distributed file system
- replicating
- Apache project
- [MongoDB](http://www.mongodb.org/) as a high performance non-rigidly structured ([NoSQL](http://en.wikipedia.org/wiki/NoSQL)) distribute
	
- as a high performance non-rigidly structured distributed database
- [NoSQL](http://en.wikipedia.org/wiki/NoSQL) concept (similar to CouchDB below)
- provisions for efficient file storage
- provisions for handling meta data
- [CouchDB](http://couchdb.apache.org/)
	
- in its core virtues similar to MongoDB above (also NoSQL concept)
- AFAIK not providing the efficient file storage means
- somewhat odd concept of coding queries up in JavaScript
