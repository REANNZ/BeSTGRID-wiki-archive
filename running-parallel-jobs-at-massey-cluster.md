# Running parallel jobs at Massey cluster

I (Vladimir Mencl) found there were multiple MPI implementations installed on the Massey cluster head-node, and I found it necessary to gather some information on how to compile and run parallel jobs.

# Running parallel jobs from the grid

MPI jobs coming from the grid, requesting at least two nodes will be started with 

``` 
"mpiexec -np <nprocs> executable"
```

 (/usr/local/bin/mpiexec).

PBS will provide the PBS_NODEFILE variable (as well as other PBS_* variables) and mpiexec will picks these up from the environment.

When invoking the parallel executable, mpiexec will set the MPIRUN_* variables (incl. MPIRUN_HOST) for each executed instance.

# Compiling parallel applications

- Default mpicc is /usr/bin/mpicc, part of RPM package mvapich-0.9.9-1458

This compiler produces executables that can be started with mpiexec.
- MPICH has a compiler in /opt/mpich/gnu/bin/mpicc, and produces executables that could be started with /opt/mpich/gnu/bin/mpirun (but that does not really work)

# Running parallel applications

Applications compiled with /usr/bin/mpicc can be executed with /usr/local/bin/mpiexec - but only from inside a PBS job.

Within that environment, mpiexec picks both the host file and the number of processes to start (though an explicit -np n does not hurt).

- Package/version:
	
- /usr/local/bin/mpiexec comes from an unknown source
- /usr/bin/mpirun is part of mvapich-0.9.9-1458

# Summary

- Compile applications with just `mpicc` (`/usr/bin/mpicc`), part of `mvapich-0.9.9-1458`
- Run applications with 

``` 
mpiexec [-np <n>] <executable>
```

 (`/usr/local/bin/mpiexec`, only within PBS jobs)
