# ContainerErrors

# Introduction 

This page lists errors that are found in the /opt/vdt/globus/var/container-real.log file, usually after starting the container:

>  globus-ws stop; globus-ws start

But services that run from time to time as cron jobs (MDS, Gridmap etc.) may also generate errors in the log.

# Common Errors 

# Java Error

>  WARN  utils.JavaUtils [1218](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=main,isAttachmentSupported&title=1218) Unable to find required classes
>  (javax.activation.DataHandler and javax.mail.internet.MimeMultipart). Attachment support is disabled.

- Apparently this one is another one of these acceptable errors:

>  Hi Anton,
>  As I said earlier:
>  :: I'm getting it too and this does not break anything - that's just
>  :: something Tomcat would like to have but does not need to run the globus
>  :: web services
>  I am getting the message and things work for me.

# Certificate Errors

# Gridmap Errors

These errors all indicate that the gridmap is not set up correctly. This section covers errors in the main globus gridmap, but note that MDS has its own gridmap which may produce similar errors - these are covered in the MDS section.

- Run /opt/vdt/edg/sbin/edg-mkgridmap to regenerate the grid map
- If /opt/vdt/edg/sbin/edg-mkgridmap does not exist, then maybe you ran Pacman from the wrong directory - try to install the EDG-Make-Gridmap package again, but cd to /opt/vdt before running the pacman command.
- Check /opt/vdt/edg/log/edg-mkgridmap.log for errors
- If the actual grid map /etc/grid-security/grid-mapfile is empty then check the steps under [Vladimir__Setup_NG2#APACGrid_NG2_Setup](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup_NG2&linkCreation=true&fromPageId=3818228849) and try to generate the map again. In particular make sure that you have the correct VOMS servers in /opt/vdt/edg/etc/edg-mkgridmap.conf.

# MDS Errors

## Incorrect grid-map Entry

>  WARN  authorization.GridMapAuthorization [158](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=ServiceThread-16,isPermitted&title=158) Gridmap authorization failed: peer 
>  "/C=AU/O=APACGrid/O=BeSTGRID/OU=BeSTGRID-MU/CN=ng2.massey.ac.nz" not in gridmap file.

- This error refers to the entry for your site in /etc/grid-security/mds-grid-mapfile. Check the entry for your site in the mapfile matches the expected site one from the error message. Therefore, my entry should read:


>  "/C=AU/O=APACGrid/O=BeSTGRID/OU=BeSTGRID-MU/CN=ng2.massey.ac.nz" grid-mds.
>  "/C=AU/O=APACGrid/O=BeSTGRID/OU=BeSTGRID-MU/CN=ng2.massey.ac.nz" grid-mds.

## ServiceAuthorizationChain Error

>  WARN  authorization.ServiceAuthorizationChain [292](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=ServiceThread-16,authorize&title=292)
>  "/C=AU/O=APACGrid/O=BeSTGRID/OU=BeSTGRID-MU/CN=ng2.massey.ac.nz" is not authorized to use operation:
>  {http://mds.globus.org/index/2004/07/12\}add on this service
>  2007-09-04 14:44:01,484 WARN  client.ServiceGroupRegistrationClient [472](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=Timer-5,status&title=472) Warning: Could not register
>  [https://ng2.massey.ac.nz:8443/wsrf/services/ReliableFileTransferFactoryService](https://ng2.massey.ac.nz:8443/wsrf/services/ReliableFileTransferFactoryService) to servicegroup at
>  [https://ng2.massey.ac.nz:8443/wsrf/services/DefaultIndexService](https://ng2.massey.ac.nz:8443/wsrf/services/DefaultIndexService) – check the URL and that the remote service is up. 
>  Remote exception was org.globus.wsrf.impl.security.authorization.exceptions.AuthorizationException:
>  "/C=AU/O=APACGrid/O=BeSTGRID/OU=BeSTGRID-MU/CN=ng2.massey.ac.nz" is not authorized to use operation:
>  {http://mds.globus.org/index/2004/07/12\}add on this service

- Probably related to the above error.

## DelegationUtil Error

>  ERROR delegation.DelegationUtil [253](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=RunQueueThread_0,getDelegationResource&title=253) Error getting delegation resource
>  org.globus.wsrf.NoSuchResourceException

(plus Java stack trace)

- I found some forum posts about this error:

>  "There are many things that can cause this error. I get it when the WSDL of my service has
>  erroneous operations or  namespaces or you could be using invalid interfaces in your code."

 "This exception is raised when a resource for a given key is not found. Usually raised by [ResourceHome](http://www.globus.org/api/javadoc-4.0/globus_java_ws_core/org/globus/wsrf/ResourceHome.html)

>  operations."

- For details: see [NoSuchResourceExceptionError](http://www.globus.org/api/javadoc-4.0/globus_java_ws_core/org/globus/wsrf/NoSuchResourceException.html) at Globus.

- Simple solution is to wipe the corresponding generated XML key in the /opt/vdt/vdt-app-data/globus/persisted/ng2-8443/ManagedExecutableJobResourceStateType directory.

- If you move these .xml files you may need to regenerate MIP info.???

# GLUE Errors

## ComputeElement transformation Error

>  WARN  transforms.GLUESchedulerElementTransform [377](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=Timer-6,transformElement&title=377) Unhandled exception during GLUE 
>  ComputeElement transformation
>  java.lang.Exception: Batch provider generated no useful information.

(+Java stack trace)

- Probably because you have not yet provided any site information in the MIP configuration files, but the MDS cron job is trying to advertise your site resources.

## Failed to Retrieve msgElements Error

>  ERROR transforms.GLUESchedulerElementTransform [218](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=Timer-5,transformElement&title=218) Failed to retrieve the Any msgElements

- I have no idea what causes this error - I gave up and set up my machine from scratch. The error is produced by a top-level exception catch, so it could be any one of many lower-level exceptions. It doesn't actually print the exception that is caught.

- I didn't get this error after setting-up from scratch again, so it is probably an incorrect entry in the MIP or MDS configuration files.

# MIP Errors

>  WARN  factory.ManagedJobFactoryResource [209](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=Thread-8,run&title=209) Recovery exception
>  org.globus.wsrf.ResourceException: ; nested exception is:

(+Java stack trace)

>  ***TODO** Not solved yet. Maybe because no MIP software info yet or .ini file structure not found.

# RFT Errors

If you get repeatedly the following message even for globusrun-ws jobs with no staging:

>     globusrun-ws: Job failed: Staging error for RSL element fileCleanUp.

Your RFT initialization might have failed and you need to restart the container.  The failure occurred because MySQL wasn't yet running when RFT was initialized - see [this discussion](/wiki/spaces/BeSTGRID/pages/3818228535#Vladimir&#39;sgridnotes-RFTstagingfails) for more information.
