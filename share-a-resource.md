# Share a resource

# How do I share an existing computational resource X within BeSTGRID?

A: It might be best to think in terms of the "functionality" you will need to add to your existing resource as opposed to simply bean counting, or putting names to, "machines"

Your BeSTGRID-facing compute resource will have some local components:

>    1. the actual resources doing the computation (compute nodes)
>    2. a head-node for controlling the activity on the compute nodes
>    3. a file storage area into which externally visible data can be placed

These resources are not usually directly visible to the outside world so let's assign them generic names as follows, assuming we have four compute nodes :

compute-be-1, compute-be-2, compute-be-3, compute-be-4

compute-fe-1

local-data-host:/local/compute-data

You'll then also need the BeSTGRID-facing parts:

>    1. mapping of the external users to local username for running jobs
>    2. transfering of data between external and internal filestore areas
>    3. presenting resources to, and scheduling requests from, the outside

Within the existing ARCS/BeSTGRID environment the functionality described above is often apparant from the names of machines comprising the actual gateway infrastructure

Are these names required ?

What does the "n" in "ng" stand for?

nggums - mapping of the external users to local username

ngdata -

ng2 - 

though there is no requirement for a one-to-one mapping.

Gateway deployers are free to merge the functionalities onto a host or group of hosts (?that merely respond to the standard names?)
