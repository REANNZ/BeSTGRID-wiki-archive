# Setting up a grid gateway

Setting up a grid gateway is a complex job - too hard to describe in a single wiki page.

As a high-level overview, a grid gateway is a job submission gateway, accepting jobs from the grid and passing them to a local resource manager (such PBS/Torque, SGE, LSF, or LoadLeveler).

Typically, a grid gateway would consist of several virtual machines:

- NGGUMS to handle authorization decisions.
- NG2 to run Globus Toolkit 4 and accept jobs via the WS-GRAM4 protocol.
- NG1 to run Globus Toolkit 2 (or now GRAM5) and provide alternative protocols.

The following documentation is relevant for this task:

- [Setting up a GUMS server](/wiki/spaces/BeSTGRID/pages/3816950966) (Alternatively, see [Setting up a GUMS server on Ubuntu](/wiki/spaces/BeSTGRID/pages/3816950479) - courtesy Guy Kloss)
	
- [Deploying Shibbolized AuthTool on a GUMS server](/wiki/spaces/BeSTGRID/pages/3816950613)
- [Configuring a GUMS server with pooled accounts](/wiki/spaces/BeSTGRID/pages/3816951003)
- [Setting up an NG2](/wiki/spaces/BeSTGRID/pages/3816950633) (Alternatively, see [Setting up an NG2 on Ubuntu](/wiki/spaces/BeSTGRID/pages/3816950445) - courtesy Guy Kloss)
	
- [Setting up an NG2/PBS specific parts](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setting%20up%20an%20NG2%2FPBS%20specific%20parts&linkCreation=true&fromPageId=3816950594)
- [Setting up an NG2/SGE specific parts](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setting%20up%20an%20NG2%2FSGE%20specific%20parts&linkCreation=true&fromPageId=3816950594)

- [Setup GRAM5 on CentOS 5](/wiki/spaces/BeSTGRID/pages/3816950554) (PBS centric)
	
- [Setup GRAM5 with LoadLeveler](/wiki/spaces/BeSTGRID/pages/3816950547) (LoadLeveler specific details)

- [Updating a grid gateway](/wiki/spaces/BeSTGRID/pages/3816950879)
