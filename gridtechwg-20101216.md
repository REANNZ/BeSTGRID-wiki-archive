# GridTechWG-20101216

[Grid Technical Working Group](grid-technical-working-group.md): meeting September 30, 2010.

## Program

At this TWG, we will discuss the various options we have for monitoring the grid middleware infrastructure:

- ARCS Nagios
- Grid Operations Center
- INCA

and we should come up with a recommendation for effective monitoring of our systems - so that we get alerted about real problems as soon as possible, but without flooding ourselves with false positives.

And Andrey will present on Hyperic:  [http://www.hyperic.com/products](http://www.hyperic.com/products)

## Minutes

Attending: Vlad, Russell Smithies, Aaron Hicks, Nick Jones, Markus Binsteiner, Kevin Buckley, Yuriy Halytskyy

- Hyperic - monitoring system, more suitable at long-term monitoring / resource graphs
	
- Detailed monitoring of resources / tomcat+apache utilization

- Vlad asks about suitability to monitor the DF and whether Jetty plugin available
- Markus confirms: Jetty plugin available
- Markus: let's monitor BeSTGRID services for admins who are interested

- Andrey: client protocols: [http://support.hyperic.com/display/DOC/Agent+Server+Communications+Diagram](http://support.hyperic.com/display/DOC/Agent+Server+Communications+Diagram)

- Discussion on monitoring BeSTGRID services
	
- Markus: let's get a list of what exactly we want to check for
		
- DF: Davis and iRODS running and files accessible
- Grid: backend server running and accessible, users can submit jobs
			
- Should be in /ARCS/BeSTGRID

- Kevin: Nagios escalation - local admin Acknowledge alert first, only then escalate

- Check if ARCS can do escalation - local admins alerts first

- Consider whether a test from Melbourne is correct

- Use Hyperic to monitor our services

## Recording

Listen to the AV recording of this meeting with [EVOplayer](http://evo.vrvs.org/evoPlayer/prod/EVOPlayer.jnlp?fileToPlay=http://media.bestgrid.org/TWG-2010-12-16.evx)
