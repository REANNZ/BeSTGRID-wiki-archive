# Random Globus Notes

# Solutions to Common Problems


when reporting problem it is better to include output of globusws-run with -debug option.

# How to Arrange Job Communication

When a job with multiple processes is submitted to PBS directly, it starts a script on a single node with $PBS_NODEFILE file with names of hosts for each process. It is a task of that script to distribute workload. 

On the other hand when a job is submitted via globus with **jobType** multiple, globus will re-distribute processes without user intervention and $PBS_NODEFILE is insufficient to determine the identity of the process when there are multiple processes on a single host. Message passing middleware like MPI solves this problem by managing communication and providing a way to discover "rank" and total number of processes. OpenMPI implementation we are using has C and Fortran bindings, and there libraries in higher level languages built on the top of them but they have much greater communication overhead. 

For example we want to process 100 xml files named 1.xml, 2.xml , etc. with **beast**. Running them through the multiple jobType will produce 100 **beast** instances not aware of each other, and with no way to pick up right file. One way to solve this problem is some server process that will distribute jobs and will give filename to every process. Then **beast** call will be wrapped in the shell script that requests a file name. Another solution is to use MPI wrapper:

>  int main(int argc, char **argv){
>   int numtasks, rank, rc;
>   MPI_Status Stat;
>   rc = MPI_Init(&argc, &argv);
>   if (rc != MPI_SUCCESS){
>     printf("error when starting MPI program. Terminating\n");
>     MPI_Abort(MPI_COMM_WORLD,rc);
>   }
>   MPI_Comm_size(MPI_COMM_WORLD, &numtasks);
>   MPI_Comm_rank(MPI_COMM_WORLD, &rank);
>   execlp("/usr/local/bin/beast","beast",argv[rank+1](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=rank%2B1&linkCreation=true&fromPageId=3816950803),(char*)0);
>  }

And then start it as 

>  mpirun -np beastMPI *.xml

(see "Submitting MPI jobs" earlier on how to submit it through globus)

# Limits on Number of Processes

Errors start to occur if the number of processes is larger than approximately twice the number of cores requested, for non-mpi jobs.

For mpi jobs the limit is larger and currently uncertain.

More details: [Limits on Number of Processes with Torque](/wiki/spaces/BeSTGRID/pages/3816950855)
