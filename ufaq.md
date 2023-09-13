# UFAQ

Unanswered FAQ - This page collects together all those questions that don't yet have a complete

answer.

If you can find an unanswered question on the FAQ page or have one not covered, then please

add it to this page.  

We will look to provide an answer and move both question and answer to the FAQ page when

we have a more complete answer.

The following is thus Work-In-Progress, dynamic, Q&A content, ahead of anything reasonably static,

and hence actually being of use to anyone, being finalised.

If you are reading anything in this section, please do not use what it says as a basis for anything

BeSTGRID related: it WILL change: it will change WITHOUT WARNING: it will change OFTEN !

**Q:** What is SLCS

The answer can be found at [http://technical.bestgrid.org/index.php/SLCS](http://technical.bestgrid.org/index.php/SLCS)

**Q:** Can I run my own applications within BeSTGRID

- Can I limit access to my applications within BeSTGRID
- Can I use BeSTGRID to develop my applications

**A:** Yes, you can.

Firstly, the compute gateways allow you to upload shell scripts that can then invoke executables

that you have also provided as part of the job payload for the remote resource that will be

running your job.

Secondly, in as much as you upload (or otherwise access) your executables at job submission time,

access is restricted.

If running remote invocations of your applications on BeSTGRID helps you to develop them, then

you are free to do so - there is no current disticntion between production and development runs

of jobs submitted to the BeSTGRID resources.

Once you are ready to provide a more wider distribution of and/or a more user-friendly front-end

for, your applications, you will need to contact the grid administrators so as to assess the 

deployment and creation of a job submission template.

**Q:** Does BeSTGRID run application X or have resource R

- What resources does BeSTGRID plan to have
- What resources would BeSTGRID like to have

**Q:** Will local users benefit from a provision of resources through BeSTGRID

**Q:** How can I share existing resources within BeSTGRID

- How can I share an existing Condor grid within BeSTGRID
- How can I share an existing SGE grid within BeSTGRID
- How can I share existing data storage within BeSTGRID

**A:** The answers to the three above questions can be taken from the existing 

BeSTGRID documentation on deploying gateways.

**Q:** How should I start contributing new resources for use within BeSTGRID

- How should I deploy a Condor grid for use within BeSTGRID
- How should I deploy a SGE grid  for use within BeSTGRID
- How should I deploy a Rocks cluster for use within BeSTGRID
- How should I deploy a data storage system for use within BeSTGRID

**A:** BeSTGRID is not there to tell you what to deploy at your site, nor how to

deploy things.

The key to the sharing of resources are the gateway technologies. 

Those technologies in use within BeSTGRID are flexible enough to allow you

to share site-local resources which have been deployed as you, the local

adminstrator, wish to deploy them.

So, simply deploy your resources to meet your needs and then take a look

at placing a BeSTGRID gateway in front of them.
