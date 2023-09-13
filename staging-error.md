# Staging error

**Problem:**

Submitting job from local Grid client to a gateway with copying output files in fileStageOut back to the local machine.

**Error:**

globusrun-ws: Job failed: Staging error for RSL element fileStageOut

Connection creation error [Connection refused](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=Caused by&title=Connection%20refused)

**RSL job description:**

``` 

<!-- Usage: globusrun-ws -submit -s -J -S -F ng2test.auckland.ac.nz -Ft PBS -f test2.rsl -->
<job>
   <factoryEndpoint
            xmlns:gram="http://www.globus.org/namespaces/2004/10/gram/job"
            xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/03/addressing">
        <wsa:Address>
            https://ng2test.auckland.ac.nz:9443/wsrf/services/ManagedJobFactoryService
        </wsa:Address>
        <wsa:ReferenceProperties>
            <gram:ResourceID>PBS</gram:ResourceID>
        </wsa:ReferenceProperties>
    </factoryEndpoint>

 <executable>test</executable>
 <directory>${GLOBUS_USER_HOME}/MPI</directory>
 <!-- argument>*.xml</argument -->
 <stdout>test2mpi.out</stdout>
 <stderr>test2mpi.err</stderr>
 <count>80</count>
 <jobType>mpi</jobType>
 <fileStageOut>
     <transfer>
        <sourceUrl>gsiftp://ng2test.auckland.ac.nz/${GLOBUS_USER_HOME}/MPI/test2mpi.out</sourceUrl>
        <destinationUrl>file:////tmp/test2mpi.out</destinationUrl>
     </transfer>
     <transfer>
        <sourceUrl>gsiftp://ng2test.auckland.ac.nz/${GLOBUS_USER_HOME}/MPI/test2mpi.err</sourceUrl>
        <destinationUrl>file:////tmp/test2mpi.err</destinationUrl>
     </transfer>
 </fileStageOut>
 <fileCleanUp>
     <deletion>
         <file>gsiftp://ng2test.auckland.ac.nz:2811/${GLOBUS_USER_HOME}/MPI/test2mpi.out</file>
     </deletion>
     <deletion>
         <file>gsiftp://ng2test.auckland.ac.nz:2811/${GLOBUS_USER_HOME}/MPI/test2mpi.err</file>
     </deletion>
</fileCleanUp>
  <extensions>
      <resourceAllocationGroup>
              <hostCount>10</hostCount>
              <cpusPerHost>8</cpusPerHost>
              <processCount>80</processCount>
      </resourceAllocationGroup>
  </extensions>
</job>

```

**Cause:**

Globus uses gsiftp from a gateway (**ng2**) under allocated grid user (grid-bestgrid). The local machine has neither host certificate nor user certificate for grid-bestgrid user. Thus this user isn't allowed to write anything on the local machine.

**Solution:**

- [Request and install](http://wiki.arcs.org.au/bin/view/Main/HostCertificates) a host certificate for the local machine and install [CA Bundle](http://wiki.arcs.org.au/bin/view/Main/InstallCABundle) (at least, later will investigate more). I don't really need it for this VM which is a local client. But later and for other users it might be needed.
- Create a script to run a job and add globus-url-copy command to copy files from the gateway to local machine. Files should be deleted on the gateway in the script or in other way. fileStageOut/delete doesn't useful in this case.

[Akha103@bestgrid.org](https://reannz.atlassian.net/wiki/404?key%3Dbestgrid.org%3Bsearch%3Fq%3DUser__Akha103)
