# Middleware

## What middleware do BeSTGRID resources run on

A: BeSTGRID's middleware/gateways use a  software stack of components from the Virtual Data Toolkit (VDT)


---

## Do I need specific operating systems, software or competences to share existing resources through BeSTGRID

A: Operating systems: No. Software: Yes. Competences: probably.

>  Interaction with BeSTGRID will take place through a gateway which is based around a software stack of components from the [Virtual Data Toolkit (VDT)](http://vdt.cs.wisc.edu)
>  VDT components can sit atop a number of UNIX-like Operating Systems, most BeSTGRID sites currently use CentOS.

BeSTGRID resources are predominately batch-processing resources. BeSTGRID resources are normally acessed through Java-based software, and/or web browser, interfaces that serve to make the whole process platform neutral

Packages hosted within BeSTGRID are rarely accessed through their own GUI interface but by specifying /driver files/command scripts/ and data files which may need to be uploaded into BeSTGRID.


---

## How should I deploy a BeSTGRID gateway

A: There is no single "BeSTGRID gateway" to deploy .The gateway infrastructure comes from a flexible set of specific components, some of which are specific to a back-end resource. Individual gateway deployment thus very much depends on what resource(s) the gateway would be for. (?though there may be commonality?) Even then, you may find local considerations see you adding extra components not visible within other gateways sharing the same resources into BeSTGRID.

As of what BeSTGRID was, at 2010-02-15, you might need to deploy:

>  For compute resources:

- an NG2 running GRAM 4.0 (now 4.0.8) plus a GridFTP server
- an NGGUMS authorization server


>  For data-specific resources
>  For data-specific resources

- an NGData server

Some notes:

- GRAM 4.2 is not likely to work in our setting and is not backwards compatible.
- GRAM 5 is not yet supported by our environment
- If you want GRAM5, install it on an NG1.  This was the name for GT2 gateways.  An NG1 would run in parallel with NG2.
- : You don't need NGData unless you are merely running data-specific services. An NG2 must run GridFTP, so if you have both compute and data resources, an NG2 server will suffice.

See our instructions on [Setting up a grid gateway](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setting_up_a_grid_gateway&linkCreation=true&fromPageId=3818228935)


---

## Is there a recommended set of software packages generally useful for users of resources within BeSTGRID?

A: The minimum requirement for BeSTGRID is purely those required for providing resource access via BeSTGRID, being the BeSTGRID Gateways (see [Setting up a grid gateway](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setting_up_a_grid_gateway&linkCreation=true&fromPageId=3818228935)). However there is a useful [Job wrapper environment](/wiki/spaces/BeSTGRID/pages/3818228677), helpful for those looking to manage more complex computational tasks, where they might require some form of scripting or other support.
