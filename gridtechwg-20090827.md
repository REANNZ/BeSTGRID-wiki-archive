# GridTechWG-20090827

[Grid Technical Working Group](grid-technical-working-group.md): meeting August 27, 2009.

## Program

New Zealand's BeSTGRID is run in tight collaboration with the Australian ARCS grid - and ARCS have recently upgraded their infrastructure from CentOS 4 / VDT 1.8.1 to CentOS 5.3 / VDT 1.10.1

It is clear we should do the same upgrade in BeSTGRID to keep the ARCS and BeSTGRID infrastructure closely aligned.

At this meeting, I'd like to open up a discussion on how we plan and perform the upgrade.  This could be done together with deploying the infrastructure at other places - and training other administrators in deploying the grid infrastructure.

Also, at Massey, this should include deploying a so-far missing GUMS server as a separate VM.

I strongly recommend to all grid administrators (and system administrators considering deploying the grid infrastructure) to attend this meeting.

## Minutes

- Kevin Buckley: update on status at Vic: will be deploying infrastructure on a few VMs obtained from ITS (ng2, nggums, idp, data grid gw) and a few VMs as a test cluster.
	
- yet to unfold
- VM infrastructure likely Xen
- scheduling system yet to be determined
- need to support interactive jobs

- VUW has research storage for internal use, part can be made available externally - perhaps as part of DataFabric
	
- KEvin keen to deploy a federated DF node

- Aaron Hicks / Landcare Research
	
- speced up VMs for infrastrucutre
- has a cluster running in "non-batch" mode so far (users running commandline jobs)
		
- users running Monte Carlo simulation
- so far just serial jobs, implementing scheduler, planning openmpi

- users not really using well-known applications, more using code obtained from other academics (would be ~ 500 runs of each locally compiled package)

- Kevin interested in using DRMA for submitting jobs across sched. systems (PBS, SGE, Condor) - asks if PBS supproted
- Vlad: use Globus as uniform interface
- Nick: Globus supports DRMA

- Nick: upgrade should be used to work as a team and bring a grid-admin at each site up to speed. Vlad to follow with Richard.
