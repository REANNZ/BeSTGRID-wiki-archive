# GridTechWG-20111027

[Grid Technical Working Group](grid-technical-working-group.md): meeting October 27th, 2011.

## Program

- GT4 vs. GRAM5 on grid gateways

- iRODS 3.0 / Postgres 9.1 / streaming data replication (postponed to November 24th, 2011, 10am)

## Minutes

Attending: Vladimir Mencl, Gene Soudlenkov, Aaron Hicks, Stuart Charters, Yuriy Halytskyy, Nick Jones, Andrew Farrell, Markus Binsteiner

- Yuriy confirms GRAM5 reasonably stable and used in production at Auckland site
	
- Albeit it has an issue with job manager breaking (needs to be killed and Auckland already has a process to kill it automatically, triggered by a specific log message)

- Decision to use GRAM5 on new gateways

- Markus: Grisu Template Client OK to use, but only as unsupported

- Linking new systems into the grid: wait for NeSI discussion (formal production process)
	
- VO mappings to be determined

- Extending job submission for NeSI to pass additional information
	
- Vlad: NeSI may have requirements like:
		
- Account number / project code
- Merit allocation flag
- BlueGene allocation parameters (Torus vs. mesh, SMP vs. DUAL vs. SN)
- Doable in principle (as RSL tags)
- Could be added into gricli as global variables
- NeSI would have to agree on a fixed vocabulary extension
- Requirements to be agreed upon

## Recording

[http://evo.vrvs.org/evoPlayer/prod/EVOPlayer.jnlp?fileToPlay=http://media.bestgrid.org/TWG-2011-10-27.evx](http://evo.vrvs.org/evoPlayer/prod/EVOPlayer.jnlp?fileToPlay=http://media.bestgrid.org/TWG-2011-10-27.evx)
