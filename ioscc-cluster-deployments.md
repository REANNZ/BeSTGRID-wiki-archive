# IoSCC Cluster Deployments

Some basic info about cluster deployments

The listings themselves serve to both detail the wide range of clustering

deployments that exist, and so highlight that view that clustering should

not be considered something esoteric or beyond the scope of an institution

simply because they only have this many machines or run that OS, but perhaps

should be seen as a logical development of an existing network of computer

resources.

The information provided details the localname of the facility; whether or not

the organisation or one of its organisational units is reponsisble for the 

clustered facility; the OS in use on "compute nodes"; the number of nodes,

ignoring multi-cpu for simplicity; the clustering technology in use; whether 

or not the resources are dedicated to the cluster or whether the cluster 

makes use of spare cycles; and finally, whether the facility is local to

the institution or interfaces into BeSTGRID.

# AgResearch

|  Condor Cluster (test)  |  Institutional  |  Windows:XP  |  5    |  Condor  |  Cycle-stealing  |  Local  |
| ----------------------- | --------------- | ------------ | ----- | -------- | ---------------- | ------- |
|  Condor Cluster         |  Institutional  |  UNIX:Linux  |  120  |  Condor  |  Dedicated       |  Local  |

# The University of Auckland

|  Prod 1  |  Institutional  |  UNIX:Linux  |  10  |  Rocks  |  Dedicated  |  BeSTGRID-facing  |
| -------- | --------------- | ------------ | ---- | ------- | ----------- | ----------------- |
|  Prod 2  |  Institutional  |  UNIX:Linux  |  13  |  Rocks  |  Dedicated  |  BeSTGRID-facing  |
|  Test 1  |  Institutional  |  UNIX:Linux  |  2   |  Rocks  |  Dedicated  |  BeSTGRID-facing  |

# Auckland University of Technology

|  Nautilus  |  ?  |  UNIX:Linux  |  16  |  ?  |  ?  |  BeSTGRID-facing  |
| ---------- | --- | ------------ | ---- | --- | --- | ----------------- |

# Landcare

|  SCENZ-Grid  |  Institutional  |  UNIX:Linux  |  12  |  Sun Grid Engine  |  Dedicated  |  Local  |
| ------------ | --------------- | ------------ | ---- | ----------------- | ----------- | ------- |

# Lincoln University

|  Condor Cluster  |  ?  |  Windows  |  150  |  Condor  |  Cycle-Stealing  |  Local  |
| ---------------- | --- | --------- | ----- | -------- | ---------------- | ------- |

# Massey University

|  BeSTGRID cluster  |  Institutional  |  UNIX:Linux  |  33  |  PBS  |  Dedicated  |  BeSTGRID-facing  |
| ------------------ | --------------- | ------------ | ---- | ----- | ----------- | ----------------- |
|  Double Helix      |  Institutional  |  UNIX:Linux  |  30  |  PBS  |  Dedicated  |  Local            |
|  IIMS Cluster      |  Institutional  |  UNIX:Linux  |  5   |  PBS  |  Dedicated  |  Local            |

# University of Otago

|  Maggie  |  ?  |  UNIX:Linux  |  10  |  ?  |  ?  |  BeSTGRID-facing  |
| -------- | --- | ------------ | ---- | --- | --- | ----------------- |

# Victoria University of Wellington

|  ECS Grid    |  Sub-institutional  |  UNIX:NetBSD  |  230  |  Sun Grid Engine  |  Cycle-stealing  |  Local  |
| ------------ | ------------------- | ------------- | ----- | ----------------- | ---------------- | ------- |
|  SCS Grid    |  Sub-institutional  |  Windows:XP   |  950  |  Condor           |  Cycle-stealing  |  Local  |
|  OptiPortal  |  Sub-institutional  |  UNIX         |  6    |  Rocks            |  Dedicated       |  Local  |

# University of Canterbury

|  BlueFern p575                   |  Institutional                |  AIX 5.3 / Linux SLES9  |  16    |  LoadLeveler+POE  |  Dedicated  |  BeSTGRID                              |
| -------------------------------- | ----------------------------- | ----------------------- | ------ | ----------------- | ----------- | -------------------------------------- |
|  BlueFern BlueGene/L             |  Institutional                |  Linux                  |  2048  |  LoadLeveler      |  Dedicated  |  BeSGRID (with personal accounts only  |
|  Electrical Engineering Cluster  |  Institutional(ENGR college)  |  Linux                  |  33    |  ROCKS+SGE        |  Dedicated  |  BeSTGRID                              |
