# GridTechWG-20110303

[Grid Technical Working Group](/wiki/spaces/BeSTGRID/pages/3818228403): meeting March 3rd, 2011.

## Program

- DataFabric GeoIP redirection

## Minutes

Attending: Vladimir Mencl, Markus Binsteiner, Kevin Buckley, Andrey Kharuk, Gene Soudlenkov, Stuart Charters, Aaron Hicks

- Gene presented his current work on GeoIP redirection: redirecting users from [http://df.auckland.ac.nz/](http://df.auckland.ac.nz/) to either [http://df.auckland.ac.nz/BeSTGRID/home](http://df.auckland.ac.nz/BeSTGRID/home) or [http://df.bestgrid.org/BeSTGRID/home](http://df.bestgrid.org/BeSTGRID/home)
	
- Redirection is supposed to happen after a timeout (Vlad: timeout too short, getting redirected before page is rendered)
- Agreed this should be installed at [http://df.bestgrid.org/](http://df.bestgrid.org/) - and this address should be given to users as the entry point

- Redirection of webDAV users unlikely to work and not worth the effort

- Vlad reported on ARCS work on redirecting GridFTP / Griffin traffic to a nearby server (Griffin on Control connection may redirect Data connections to another Griffin server).

- Vlad briefly reported on ARCS iSftpd project and agreed to send link ([http://projects.arcs.org.au/trac/sftpirods/](http://projects.arcs.org.au/trac/sftpirods/))

- Markus suggested having a MyProxy server in CA mode that would be issuing certificates valid for the DataFabric based on a username (likely assigned to be sharedToken and a long generated password).  This could be long-lived credentials for mounting DF over webDAV.  The credentials would be regenerated via a Shibboleth protected web app.
	
- Agreed to be useful in principle
- Vlad volunteered to setup the MyProxy server after back from parental leave - if someone writes the web app.

## Action Items

- Gene to write up a wiki page about GeoIP redirection
	
- Vlad to install GeoIP redirection at [http://df.bestgrid.org/](http://df.bestgrid.org/)

- Vlad to send link to isftpd (done: [http://projects.arcs.org.au/trac/sftpirods/](http://projects.arcs.org.au/trac/sftpirods/))

## Recording

Listen to the AV recording of this meeting with [EVOplayer](http://evo.vrvs.org/evoPlayer/prod/EVOPlayer.jnlp?fileToPlay=http://media.bestgrid.org/TWG-2011-03-03.evx)
