# APAC Test Suite For Auckland Gateway

Not all of the [tests](http://wiki.arcs.org.au/bin/view/APACgrid/TestSuite) are going to work out of the box, so here are the modifications and notes.

# Test 1 

**Pass**

The exact command for test gateway:

>  globusrun-ws  -submit -s   -S -F ng2test.auckland.ac.nz:9443 -Ft Fork -c /usr/bin/whoami

Have to set valid gateway name and port number (the default 8443 is used by apache).

# Test 2

**Pass**

Exact command:

>   globusrun-ws -submit -s -J -S -F ng2test.auckland.ac.nz:9443 -Ft PBS -f gt1.rsl

Passing standard input and error between compute nodes and gateway requires either passwordless access between compute nodes and gateway, or using shared file system and configuring PBS to use **cp** instead of **scp**. We selected second option.

Shared file system is NFS mount from frontnode in /home/bestgrid-grid

Relevant PBS configuration file on cluster is /opt/torque/mom_priv/config with following entry:

>  $usecp *:/home /home

Without the changes above I see the following error in /var/log/messages on compute nodes:

>   May  7 17:15:37 compute-0-9 pbs_mom: sys_copy, command '/usr/bin/scp -rpB /opt/torque/spool/52.cluster.hpc.org.ER yhal003@ng2test.auckland.ac.nz:/  
>  home/yhal003/NG2Tests/STDIN.e52' failed with status=1, giving up after 4 attempts

The RSL file that works in our case would look like this:

>              [https://ng2test.auckland.ac.nz:9443/wsrf/services/ManagedJobFactoryService](https://ng2test.auckland.ac.nz:9443/wsrf/services/ManagedJobFactoryService)
>              PBS
>   /bin/hostname 

>  test.out
>  10 
>  multiple 

>                 10
>                 8
>                 80

i.e. the **extensions** section specifies *hostCount* and other stuff as well as using **count** and **jobType=multiple** tags.

If the **extensions** section is not used, the following error shows up:

>  -bash-3.00$ globusrun-ws -submit -s -J -S -F ng2test.auckland.ac.nz:9443 -Ft PBS -f gt1.rsl
>  Delegating user credentials...Done.
>  Submitting job...Done.
>  Job ID: uuid:ce4e34ce-1ca8-11dd-acae-00163e000004
>  Termination time: 05/09/2008 02:45 GMT
>  Current job state: Pending
>  Current job state: Active
>  Current job state: CleanUp-Hold
>  /bin/sh: /home/yhal003/.globus/ce988b50-1ca8-11dd-9baf-c04f6affd4b6/scheduler_pbs_cmd_script: No such file or directory
>  bash: /home/yhal003/.globus/ce988b50-1ca8-11dd-9baf-c04f6affd4b6/exit.0: No such file or directory
>  /bin/touch: cannot touch `/home/yhal003/.globus/ce988b50-1ca8-11dd-9baf-c04f6affd4b6/exit.0': No such file or directory
>  /opt/torque/mom_priv/jobs/110.cluster.hpc.org.SC: line 52: /home/yhal003/.globus/ce988b50-1ca8-11dd-9baf-c04f6affd4b6/exit.0: No such file or  directory 
>  /opt/torque/mom_priv/jobs/110.cluster.hpc.org.SC: line 53: [: too many arguments
>  Current job state: CleanUp
>  Current job state: Done
>  Destroying job...Done.
>  Cleaning up any delegated credentials...Done.

# Test 3
