# GridTechWG-20090924

[Grid Technical Working Group](/wiki/spaces/BeSTGRID/pages/3818228403): meeting September 24, 2009.

## Program

Tim Molteno has kindly agreed to give together with Patrick Suggate a presentation about his work on OGRE - the Otago Grid Ruby Engine, a very viable alternative to Condor.  He would also talk about his prior experience with Condor - which triggered him into designing OGRE.

Stephen Cope will give a 20 minute presentation on Sun Grid Engine (SGE).

## Video recording

The two presentations at this meeting have been recorded by the EVO video recorder.

To play the presentations:


## Minutes

Stephen Cope: giving a presentation on SGE

- work on SGE just in stats dept
- first ad-hoc job running
- started with SGE on dedicated servers + lab desktops
- issues with making people happy with response times
- KEvin: question on mutiple queues with different job time limits

Tim Molteno talking on OGRE + Condor

- history: Condor used for tasks consisting of 10^5 jobs over 100 nodes
- problem: in Physics, hierarchical networks with many firewalls in between
- Condor needs bi-directional communication between compute node and master node
- possible workaround: Condor connection broker - however, this must be installed on the firewall
	
- must control firewall
- security implications
- CCB works with "vanilla universe" only - no features like suspending/migrating jobs
- looking at Condor source code (with dodgy license) to see if it can be improved
- looking at actual requierments - much smaller then Condor's features
- deciding to write own thing: OGRE

OGRE:

- only X509 cor auth
- no concept of multiple queues
- only one-way communication - from compute to master

design:

- XMLRPC to get job from Master
- Http to get job data from data server
- jobs have URLs
- jobs stored in SQL database, written in Ruby

job submission

- GUI client, talks SOAP via SSL to Master
- X509 cert of bidirectional auth to Master

cross-compile foo.exe for multiple platforms (win32, linux32, linux64), http PUT to data serve

queueing model:

- jobs can be killed without master being told
	
- client actively sends alive messages to master while running - no call home means client is dead
- client specifics max runtime, memory, hd
- user provdes an estimate of runtime
- jobs will be slaughtered when a machine gets used (screensaver ends) - incentive for users to split task into small jobs

- PBS compute node - get jobs when a PBS cluster is idle

future work:

- replace existing Windows client (a Windows service) with a Windows Screensaver
