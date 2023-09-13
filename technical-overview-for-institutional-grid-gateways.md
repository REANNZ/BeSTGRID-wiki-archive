# Technical Overview for Institutional GRID Gateways

- Physical Gateway Server: [IBM x3500](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=The%20GateWay%20Configuration&linkCreation=true&fromPageId=3816950467)
- [Xen Domain 0](http://www.vpac.org/twiki/bin/view/APACgrid/XenInstall) Xen hypervisor - a manager of Virtual machines on Gateway Server (re: APAC)
- [NG2 Virtual Machine](http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsNg2) (1st Virtual machine) Gateway for Computational GRID
	
- Exports GRID configuration of institutional computational resources
- Exports to [APAC MDS Server](http://www.sapac.edu.au/webmds/) (monitoring and discovery service)
- GRID Configuration contains information about institutional clusters, applications, storage resources on site.
- 'Submits' computational jobs to clusters
- Provides information to APAC Grid Operation Centre about status of computational resources (such as number of jobs submitted)
- NG2 submits timing information about site
- Cluster management node (master/head node of a cluster) submits rest of information to GOC (list of job ids, 'grid user' information)
- NG2 subsitutes Real users for 'GRID users'
- NG2 host GSIftp server (Transfers files between storage resources and computational resources in both directions)
- Globus version 4 plus other middleware sourced from VDT 1.7
- NG2 submits jobs through PBS (Standard), but also through other batch systems (such as IBM Load Leveller for P575/BlueGene)
- NG2 receives information from clusters from pbs-telltail script (this script tails the logs on each cluster and sends off interesting entries to pbs-logmaker processs on globus grid gateway machines)
- [NGdata Virtual Machine](http://www.vpac.org/twiki/bin/view/APACgrid/VmdetailsNgdataVdt)
	
- a gate for data storage
- Hosts only GSIftp server
- NGPortal (Gridsphere portal – currently one [setup at Canterbury](/wiki/spaces/BeSTGRID/pages/3816951006))
- At APAC
	
- Myproxy server
- VOMS server
