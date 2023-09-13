# Access to ATLAS cluster

[ATLAS Cluster](http://monitor.atlas.aei.uni-hannover.de/ganglia/?m=load_one&r=hour&s=descending&hc=4&mc=2) supports access via GSISSH. Cluster administrators accept BeSTGRID certificate as proof of identity and given the host with gsissh installed, cluster can be accessed as

``` 

gsissh username@atlas1.atlas.aei.uni-hannover.de

```

The client machine needs to have CERN CA in grid-security/certificates (hash =  dd4b34ea).

Any users of grid1.ceres.auckland.ac.nz can login, if they have an account on cluster.
