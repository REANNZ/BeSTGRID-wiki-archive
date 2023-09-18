# Setting up a grid gateway

Setting up a grid gateway is a complex job - too hard to describe in a single wiki page.

As a high-level overview, a grid gateway is a job submission gateway, accepting jobs from the grid and passing them to a local resource manager (such PBS/Torque, SGE, LSF, or LoadLeveler).

Typically, a grid gateway would consist of several virtual machines:

- NGGUMS to handle authorization decisions.
- NG2 to run Globus Toolkit 4 and accept jobs via the WS-GRAM4 protocol.
- NG1 to run Globus Toolkit 2 (or now GRAM5) and provide alternative protocols.

The following documentation is relevant for this task:

- [Setting up a GUMS server](setting-up-a-gums-server.md) (Alternatively, see [Setting up a GUMS server on Ubuntu](setting-up-a-gums-server-on-ubuntu.md) - courtesy Guy Kloss)
	
- [Deploying Shibbolized AuthTool on a GUMS server](deploying-shibbolized-authtool-on-a-gums-server.md)
- [Configuring a GUMS server with pooled accounts](configuring-a-gums-server-with-pooled-accounts.md)
- [Setting up an NG2](setting-up-an-ng2.md) (Alternatively, see [Setting up an NG2 on Ubuntu](setting-up-an-ng2-on-ubuntu.md) - courtesy Guy Kloss)
	
- [Setting up an NG2/PBS specific parts](setting-up-an-ng2-pbs-specific-parts.md)
- [Setting up an NG2/SGE specific parts](setting-up-an-ng2-sge-specific-parts.md)

- [Setup GRAM5 on CentOS 5](setup-gram5-on-centos-5.md) (PBS centric)
	
- [Setup GRAM5 with LoadLeveler](setup-gram5-with-loadleveler.md) (LoadLeveler specific details)

- [Updating a grid gateway](updating-a-grid-gateway.md)
