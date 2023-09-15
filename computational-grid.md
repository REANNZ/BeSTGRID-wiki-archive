# Computational GRID

# Overview

## Wikipedia

The term [Grid computing](http://en.wikipedia.org/wiki/Computational_Grid) originated in the early 1990s as a metaphor for making computer power as easy to access as an electric power grid.

Grid computing offers a model for solving massive computational problems by making use of the unused resources (CPU cycles and/or disk storage) of large numbers of disparate computers, often desktop computers, treated as a virtual cluster embedded in a distributed telecommunications infrastructure. Grid computing's focus on the ability to support computation across administrative domains sets it apart from traditional computer clusters or traditional distributed computing.

## IBM's definition

What is grid and grid computing? According to [IBM](http://www-128.ibm.com/developerworks/grid/library/gr-grid1/): "A grid is a collection of distributed computing resources available over a local or wide area network that appear to an end user or application as one large virtual computing system. The vision is to create virtual dynamic organizations through secure, coordinated resource-sharing among individuals, institutions, and resources. Grid computing is an approach to distributed computing that spans not only locations but also organizations, machine architectures and software boundaries to provide unlimited power, collaboration and information access to everyone connected to a grid."

# [Getting Started with BeSTGRIDs Computational GRID](/wiki/spaces/BeSTGRID/pages/3818228457)

# BeSTGRID Project Deliverables - Computational Grid

[Computational Grid Project Deliverables](/wiki/spaces/BeSTGRID/pages/3818228961)

# BeSTGRID Conceptual Design

## A graphical representation of the BeSTGRID [Conceptual Design.](attachments/BeSTGRID-Conceptual-Designv03.pdf)

## BeSTGRID GateWay Server Configuration 

## [BeSTGRID Auckland IP Addresses Pool](/wiki/spaces/BeSTGRID/pages/3818228780) 

**Status:** *the GateWay Server has been mounted in Computer Center of ITS, UoA*

>  ***[IBM System x3500](http://www-03.ibm.com/systems/x/tower/x3500/index.html)**** with upgraded configuration:** (detail description)

- 
- 2x 3.0GHz/1333MHz Dual core Intel processors
- 10GB DDR2 Memory
- **2x 73GB SAS hard drives (mirrored system disk) -*actual size is 68.2 GB**
- **4x 146GB SAS Hard Drives (Raid 5 VM images disk) -*actual size is 409.86 GB**
	
- 6x 10/100/1000 Ethernet ports (2x to storage, 2x Grid clusters & 2x Internet) with IP addresses:

## BeSTGRID GateWay Server Virtual Machines

>  ***Virtual Machines** on [Xen 3.0](http://www.xensource.com/products/xen/) Platform:

- 
- [Globus Server v4](http://www-unix.globus.org/toolkit/docs/4.0/)
- [Globus Server v2](http://www.globus.org/toolkit/docs/2.4/)
- [GridFTP](http://www-unix.globus.org/toolkit/docs/4.0/data/gridftp/)
- [PBS Server (Torque 2.1.3)](http://www.clusterresources.com/pages/products/torque-resource-manager.php)
- [MyProxy](http://grid.ncsa.uiuc.edu/myproxy/)/[Shibboleth](http://shibboleth.internet2.edu/) Server
- [Web Portal based on GridSphere](http://www.gridsphere.org/gridsphere/gridsphere?cid=2)
- [Sakai Server](http://www.sakaiproject.org/)

## [First BeSTGRID Test Grid](/wiki/spaces/BeSTGRID/pages/3818228493)

# [Technical Notes for setting up the Institutional Gateway Servers (APAC Style)](vladimirbestgridorg.md)

## Tips and suggestions

- [For GridSphere in Tomcat environment](gridsphere-tomcat.md)

# APAC Certificate Authority

- The APAC Grid Certificate Authority will be issuing X509 Globus style certificates until there is a more formal authority established to serve the Australian and NZ research community. Its proposed that there be a person (the Registration Authority Operator (RAO)) nominated at each relevant institute who is responsible for checking certificate applicants identity. These RAO identities will, in turn be established by a state RAO who will have personal knowledge of them and these State RAOs will be personally known to the APAC Grid Project Leader. This arrangement is not expected to be a long term one.

- [APAC-GRID CA Policy Statement](http://www.vpac.org/twiki/bin/view/APACgrid/CaPolicy_1_3)
- VPAC has authorised [Andrey Kharuk](andrey-kharuk.md) as a [Registration Authority Operator](http://www.vpac.org/twiki/bin/view/APACgrid/RaoDescriptor). He can send requests certs for people which he can recognize and the request is compliant with the APAC-GRID CA Policy Statement.

- The RAO has three primary responsibilities:

1. Establishes, beyond reasonable doubt, the identity of a person who is applying for a Certificate. This will usually be by seeing an appropriate 'Photo ID' such as a driver's license or staff card and observing that the photo matches the person presenting it. The RAO must physically meet the person applying for the certificate and must sight the 'photo ID' not (eg) a photocopy or reproduction.
2. Sign, electronically, and thus authorize, the Certificate Application.
3. Keep appropriate records of the above transaction.

- [Andrey Kharuk](andrey-kharuk.md) can also collect requests for certs from people, and process them in bulk by inviting a CA adminstrator from VPAC to create certificates.
- *Who recognises APAC certificates?* See [GRIDPMA](http://www.gridpma.org) where you can find all GRID organisation which recognize APAC certificates (see 'Asia and Pacific').

## [Federated Identity Initiatives in NZ](/wiki/spaces/BeSTGRID/pages/3818228589)

# Contact

[Andrey Kharuk, Research IT Consultant, University of Auckland](andrey-kharuk.md)

# Our partners

[Australian Partnership for Advanced Computing APAC Grid](http://www.grid.apac.edu.au/)
