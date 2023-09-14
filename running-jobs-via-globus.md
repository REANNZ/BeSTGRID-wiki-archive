# Running Jobs via Globus

# Getting Grid certificate

If you have never used BeSTGRID before, you need to do these steps once only:

- [Submit a request for a certificate](https://ngportal.canterbury.ac.nz/certuserguide.html)
- Meet a RAO (Request Authority Operator) in [your area](http://wiki.arcs.org.au/bin/view/Main/RaoList) and provide him a photo ID.
- Retrieve a public key of your certificate and apply for VO membership via Grix tool ([par. 5-7](https://ngportal.canterbury.ac.nz/certuserguide.html))

# Grid Client Host

Originally we will provide accounts on a machine with Globus clients and necessary software installed. To run jobs from the client host users will need to do the following.

Every time you wish to login and submit jobs, you need to do these steps:

- Activate MyProxy([par. 8](https://ngportal.canterbury.ac.nz/certuserguide.html))
- Login on the Grid client Host: SSH to grid1.ceres.auckland.ac.nz (you will need to ask Yuriy for a login)
- Activate MyProxy credentials - replace "user.name" with your username:


>  [unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dgridclient%2B%7E%3Bsearch%3Fq%3Duser)$ myproxy-logon -l **user.name** -s myproxy.arcs.org.au
>  Enter MyProxy pass phrase:
>  A credential has been received for user user.name in /tmp/x509up_u514.
>  [unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dgridclient%2B%7E%3Bsearch%3Fq%3Duser)$ myproxy-logon -l **user.name** -s myproxy.arcs.org.au
>  Enter MyProxy pass phrase:
>  A credential has been received for user user.name in /tmp/x509up_u514.

- Transfer any required files. (See below.)
- Submit your job. (See below.)
- ...
- Collect output.

Various useful tools to interface with grid are described here: [Grid Tools](/wiki/spaces/BeSTGRID/pages/3818228739)

# Examples

## Transfering Files 

globus-url-copy is a command line client that can be used to transfer files via GridFTP to the gateway ( and to the cluster via /home/grid-besgrid directory which is NFS share).

>   globus-url-copy [file:///home/yhal003/something.tar.gz](file:///home/yhal003/something.tar.gz) gsiftp://ng2.auckland.ac.nz/home/grid-bestgrid/something.tar.gz

local location is specified with full path, and file:// protocol. Remote location on the gateway needs gsiftp:// prefix, gateway domain name (currently ng2.auckland.ac.nz though we may switch to ng2.auckland.ac.nz later) and path. Files can be transferred to and from other gridftp servers. Both arguments to globus-url-copy can be remote locations.

GUI GridFTP clients also exist for example [http://www.cs.virginia.edu/~gsw2c/GridToolsDir/Documentation/GridFtpClients.htm](http://www.cs.virginia.edu/~gsw2c/GridToolsDir/Documentation/GridFtpClients.htm)

## Submitting Jobs via Command Line

For simple non CPU intensive tasks it may be easier to submit them on the gateway directly.

Since gateway and cluster share home directory, it is convinient to unpack files submitted via grid ftp, for example:

>  globus-url-copy [file:///home/yhal003/something.tar.gz](file:///home/yhal003/something.tar.gz) gsiftp://ng2.auckland.ac.nz/home/grid-bestgrid/something.tar.gz
>  globusrun-ws -submit -s -J -S -F ng2.auckland.ac.nz -Ft Fork -c /bin/tar -xzvf something.tar.gz

The first command transfers something.tar.gz to the /home/grid-bestgrid (directory shared by both gateway and cluster).

Second command untars this file. The command and arguments are specified after -c option. Here:

- -F specifies gateway machine, for Auckland cluster it is ng2.auckland.ac.nz
- -Ft specifies type of task.
	
- PBS for jobs on the cluster.
- Fork for jobs running directly on the gateway. Good for "interactive" commands like ls, because jobs do not go through cluster queue and are scheduled almost immediately. Not good for process intensive jobs.
- nothing (no flag at all) for multijobs.

Additional details of the globusrun-ws options can be found [in the globusrun-ws manual](http://www.globus.org/toolkit/docs/4.0/execution/wsgram/rn01re01.html).

To submit jobs on the cluster, you need to describe them in xml format (RSL) and submit via **globusrun-ws** command. 

More examples can be found here: [http://wiki.arcs.org.au/bin/view/APACgrid/TestSuite](http://wiki.arcs.org.au/bin/view/APACgrid/TestSuite)

RSL documentation:

- [RSL Schema](http://www.globus.org/toolkit/docs/3.0/gram/rsl-schema.html)  (currently this page is broken)
- [RSL Extension Handling](http://www.globus.org/toolkit/docs/4.0/execution/wsgram/WS_GRAM_Job_Desc_Extensions.html)

## Simple Job Submission

The following RSL describes run of /bin/hostname on single machine. Save it in test1.rsl file and execute

>  globusrun-ws   -submit -s -J -S -F ng2.auckland.ac.nz:8443 -Ft PBS -f test1.pbs

``` 

 <!-- 
  this job description tells globus to run /bin/hostname command (<execution> tag)
  on single node of the cluster ( <jobType>).
 -->
 <job>
  <executable>/bin/hostname</executable> 
  <jobType>single</jobType> 
 </job>

```

## Use of Environmental Variables, Arguments, and Standard Input/Output

To specify files for standard error and standard output modify globusrun-ws command line (-so and -se options).

``` 

 <!-- globusrun-ws   -submit -s -J -S  -f test2.rsl  -so output.txt -se error.txt -->
 <!-- 
   demonstrates use of environmental variables, passing arguments and redirecting 
   standard output into file
 -->
 <job>
  <executable>/bin/env</executable> 
  <argument>TEST3='This variable was passed via command line arguments'</argument>
   <environment>
   <name>TEST1</name>
   <value>This value should appear on standard output </value>
 </environment>
  <environment> 
   <name>TEST2</name>
   <value>And this one too</value>
  </environment>
  <jobType>single</jobType> 
 </job>

```

## Submitting Multiple Jobs

It is easy to submit more then one job in the same file by putting  descriptions in `multiJob` tag.

``` 

 <multiJob>
  <job>
   ...
  </job>
  <job>
   ...
  </job>
 </multiJob>

```

The only difference is, the submission command line does not have -Ft flag, and each individual job should have the following at the start:

``` 

 <job>
 <factoryEndpoint
            xmlns:gram="http://www.globus.org/namespaces/2004/10/gram/job"
            xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/03/addressing">
        <wsa:Address>
            https://ng2hpc.ceres.auckland.ac.nz:8443/wsrf/services/ManagedJobFactoryService
        </wsa:Address>
        <wsa:ReferenceProperties>
            <gram:ResourceID>PBS</gram:ResourceID>
        </wsa:ReferenceProperties>
    </factoryEndpoint>
  ...

```

MultiJob is useful if you want to synchronize on completion of job set, as globusws-run will only complete when all jobs complete.

## Another method

**Note** - This mechanism is very strange and 

processes submited in this way will not be able to identify themselves or to locate peers. 

Communication can be arranged either by central server that will know about all jobs, some middleware like MPI (see next example)  or some other means. Also see limits section. For most cases it is better to use multiJob or mpi jobs.

- hostCount will determine number of nodes, and count - number of processes. For best performance it is better if number of processes is no more then number of cores requested. If process count is significantly larger there can be problems (see below).

``` 

  <!-- run job on multiple hosts, standard input is concatenated and
  stored in the file.
 -->
 <job>
  <executable>/bin/hostname</executable> 
 <count>2</count>
 <hostCount>2</hostCount>
  <queue>default@hpc-bestgrid.auckland.ac.nz</queue> 
  <jobType>multiple</jobType> 
 </job>

```

## Submitting MPI jobs 

MPI environment will take care of process communication and identification. Also because the internal mechanism for job submission is different from normal multijobs, the limits of processes are larger (but the performance still suffers).

``` 

 <job>
 <executable>test</executable> 
 <count>4</count>
 <hostCount>4</hostCount>
 <directory>/home/grid-bestgrid/MPI/</directory>
 <queue>default@hpc-bestgrid.auckland.ac.nz</queue> 
 <jobType>mpi</jobType> 
 </job>

```

# How To Monitor Job Execution

This link shows Auckland cluster statistics:

[UoA Rocks cluster statistics](http://hpc-bestgrid.auckland.ac.nz/ganglia/)

List of jobs executed and in the queue can be found here:

[List Of Jobs](http://hpc-bestgrid.auckland.ac.nz/ganglia/addons/rocks/queue.php?c=BeSTGRID%20Auckland%20Cluster)

The "name" column can be set from job description file by appending the following to the end, before closing  tag:

``` 

 <extensions>
        <jobname>Simple-Job-Name</jobname>
 </extensions>

```

For example:

``` 

 <job>
  <executable>sleep</executable> 
  <directory>/tmp</directory>
 <argument>10000</argument>
 <jobType>single</jobType> 
 <extensions>
        <jobname>simplename</jobname>
 </extensions> 
 </job>

```

# How To Query Job State From Command Line 

Job status can be discoved by saving "job handle" in  a file during submission and than using this handle in various queries.

To save job handle, add "-o test.epr" to globusrun-ws command, for example 

>  globusrun-ws  -submit -s  -F ng2.auckland.ac.nz:8443 -Ft PBS -o  test.epr -c echo "hello world"

test.epr can be any filename. This file can be used to query job status from different terminal. You can also add "-b" flag for batch submission, so that globusrun-ws returns immediately. 


>  wsrf-query -s [https://ng2.auckland.ac.nz:8443/wsrf/services/DefaultIndexService](https://ng2.auckland.ac.nz:8443/wsrf/services/DefaultIndexService) |grep Jobs
>  wsrf-query -s [https://ng2.auckland.ac.nz:8443/wsrf/services/DefaultIndexService](https://ng2.auckland.ac.nz:8443/wsrf/services/DefaultIndexService) |grep Jobs
