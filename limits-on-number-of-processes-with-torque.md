# Limits on Number of Processes with Torque

# Limit on Simultaneous Connections for sshd

PBS script created by globus uses ssh to distribute jobs among nodes. 

**MaxStartups** variable in sshd.conf determines number of simultaneous connections 

to a single host. For example in our case it was 10, so there could be 100 jobs on 10 node cluster

at the same time (more if some jobs complete before all connections are established.) Increasing this number to 50 increased that limit to 500. 

Another solution would be to use rsh.

## Additional Details

From globus mailing list:

``` 

> We have 10 node cluster with 2
> quad-core processors per node, and when number of jobs is greater then
> 160 there seems to be increasing probability to get the following
> error:
>
>
> /bin/sh:
> /home/grid-bestgrid/.globus/90bbca80-2ba4-11dd-95fc-8fae74568b88/ 
> scheduler_pbs_cmd_script:
> No such file or directory
>
> This error does not happen all the time, but the probability increases
> as number of jobs increase, and I hasn't been able to trigger this
> error with number of processors < number of cores * 2.

```

The following error shows up on globus client:

>   ssh_exchange_identification: Connection closed by remote host

It was suggested that the problem is with NFS scalability: all nodes try to access

the same file (scheduler_pbs_cmd_script) and errors result. In our case it is more likely

>  that the problem is with sshd having limit on number of connections (and torque tries to execute

the script remotely via ssh).

Attempt to execute the following script 

>  for i in `seq 1 $1 `
>  do
>  ssh compute-$[Limits on Number of Processes with Torque](/wiki/spaces/BeSTGRID/pages/3816950855) echo "hello world" &
>  done;

Results in equivalent error when $1 is large (~ 150). 
