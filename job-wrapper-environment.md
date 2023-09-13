# Job wrapper environment

# Background

When implementing workflows for certain kinds of job, for some jobs it is necessary or helpful to write a wrapper script that does some or all of the following:

- sets up some kind of environment,
- tests necessary pre-conditions,
- carries out pre-/post-processing of its own to provide e. g. better job monitoring than the output the application would give.

These cases are quite common, and the concern is always that scripting requirements cannot be satisfied on specific or all available resources (that might otherwise be suitable). This problem becomes more severe in cases where the computational scientist does not have control over the install on a targeted resource. This problem is less Grid specific by itself, but becomes more severe as the Grid enables easier access to a variety of resources at various locations.

# Aim

**This page identifies components that are useful in supporting a common "BeSTGRID job wrapper environment". 'None of these are considered as a *****must***** in order to participate in the BeSTGRID context.**

In summary, the environment:

- defines common packages, useful for job management
- sets a lowest common denominator for sites & resources wishing to deploy these common packages
- describes how to advertise resources as having these common pacakges

The tools for the job wrapper environment are packages, that are available on the computational resource itself (e. g. the cluster), and are used by a job wrapper to for example set up the computational environment for a particular executable to run, to maybe prepare some input files, and maybe receive output from the application for easier (automated) monitoring and post-computational processing.

These may be packaging tools (e. g. `tar`, `gzip`, `zip/unzip`), XML processing tools (e. g. the XML Python module), text search/replace/filter tools (e. g. `grep`, `sed`, `awk`), etc. So, things, that are typically found in job wrapper scripts, whether they are using a shell (bash), Python or Perl. The tools combo could be used for example to deliver a ZIP/tar file to a Grid node, have a Python script unpack the contents, set up the environment, modify some input files according to a parameter, start the computation and finally package up the result files into a ZIP/tar again.

These tools should not be too specialised, but rather be a low common, reliable denominator. That also suggests that their use not be version dependent, but rather restrained to longer supported base functionality of the various tools. It is intended as a common set of tools that allows one to manage computations, not perform them. 

The availability of tools on a platform should be published through MDS (As a "bestgrid-job-wrapper" package or so? Maybe versioned?), to advertise the compatibility 

# Terminology

Components stated below in the tool list with a *"should"* are to be considered as *"highly desirable."* Tools labelled with *"may"* are sensible extensions often found and used in job management, but are not expected to be present on participating resources.

# Standard UNIX Tools

- grep (should)
- sed (should)
- awk (should)
- cat (should)
- cut (should)
- sort (should)
- uniq (should)
- bc (should)

# Packing/Archiving Tools

- tar (should)
- gzip (should)
- bzip2 (may)
- zip/unzip (may)

# Python and Modules

Python should be provided if possible in a version of 2.5 or above, but not (yet) in a 3.x version.

- Python (should)

Python packages/modules:

- XML
	
- (c)elementtree, XML processing using the default `ElementTree` API (should)
- lxml (may)
- xml (may)

# Perl and Modules

- Perl (should)
