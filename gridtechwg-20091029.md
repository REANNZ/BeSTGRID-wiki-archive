# GridTechWG-20091029

[Grid Technical Working Group](/wiki/spaces/BeSTGRID/pages/3818228403): meeting October 29, 2009.

## Program

**R on the grid**

- Mik's presentation: [Mik_black-R_on_the_Grid.pdf](attachments/Mik_black-R_on_the_Grid.pdf)
- Links:
	
- [Schmidberger et al. (2009)](http://www.jstatsoft.org/v31/i01/paper)
- [Bioconductor](http://bioconductor.org)
- [R-project mirror at Auckland](http://cran.stat.auckland.ac.nz)
- [Otago Integrated Genomics project (with link to GenePattern server)](http://bioanalysis.otago.ac.nz)
- [GenePattern page at MIT](http://www.broadinstitute.org/cancer/software/genepattern/)
- [New York Times article](http://www.nytimes.com/2009/01/07/technology/business-computing/07program.html?_r=1&scp=1&sq=robert%20gentleman&st=cse) and [follow-up blog entry](http://bits.blogs.nytimes.com/2009/01/08/r-you-ready-for-r/?scp=1&sq=Robert%20Gentleman&st=cse)
- [Biocep](http://biocep-distrib.r-forge.r-project.org/)

## Minutes

- Presentation by Mik Black: R, GenePattern
	
- Interesting projects to look at:
		
- Rgrid
- multiR
- Parallelism in R is done via SNOW which sits on top of Rmpi / Rpvm / Rnws

- Presentation by Paul Ronaldson:
- Condor at Landcare

- Presentation by Aaron:
	
- Running R at Landcare Research in SGE
- Interesting package: Rsge - for submitting R tasks into SGE from inside R
		
- Disadvantage: when doing MPI this way, the tasks can't access the context of the main process
- Useful trick: install R packages into the current directory (".")
	
- Mik Black says won't work for some scenarios (?itf to local pkgs)
