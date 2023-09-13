# Store files on filesystem

Sakai can store uploaded files (Resource tool) either in a table of a database or as a file on the file system. On default Sakai stores files in its database.

To use the filesystem to store binary content, add properties like the following to the sakai.properties file:

``` 

bodyPath@org.sakaiproject.content.api.ContentHostingService=/usr/local/tomcat/content/
# Only uncomment the bodyVolumes property if you have multiple content volumes 
# (sub directories/ mount points relative to the location specified above)
bodyVolumes@org.sakaiproject.content.api.ContentHostingService=v01,v02,v03
# uncomment the next line if you wish to set a site quota of 1Gb
# siteQuota@org.sakaiproject.content.api.ContentHostingService=1048576

```

[See Sakai Admin's Guide](http://bugs.sakaiproject.org/confluence/display/DOC/Sakai+Admin+Guide+-+Binary+Content+and+Filesystem+Settings)

[BeSTGRID VRE test server](http://vre.test.bestgrid.org) has been reconfigured to store files on the filesystem and to convert Content Resources table into files. After restart Sakai copied all files into the filesystem and left them in the Content Resources table.

This server runs Sakai 2.4. Current production Sakai server is 2.3. Admin's Guide for Sakai 2.3 hasn't been found yet but probably Sakai 2.3 supports storing files on the filesystem as well. In a document which describes entires of sakai.properties file for Sakai 2.3 there are **bodyVolume** and **bodyPath** parameters. 

[Akha103@bestgrid.org](https://reannz.atlassian.net/wiki/404?key%3Dbestgrid.org%3Bsearch%3Fq%3DUser__Akha103)
