# BeSTGRID and APACGrid cooperation - Vladimir Mencl

I have been recently visiting VPAC - with the main goal to get the development of the grid infrastructure in New Zealand moving.

I would like to report on what I found important during the trip,

and I highlight some of the issues that I think should be discussed by the BeSTGRID steering committee.

I found the trip extremely useful - in establishing a personal contact, and in finding out how the grid infrastructure developed at APACGrid is really used, and which pieces of it are crucial for us to implement here.

As a positive consequence of the trip, I found that APACGrid (VPAC) are willing to share significant parts of their infrastructure with us - so that we can focus on those pieces which we really need established locally, and can share their infrastructure for the rest.

1) Certificate Authority

An important piece of infrastructure we already agreed to share is their Certificate Authority.  I have discussed with David Bannon what form of certificates they would issue for us, and there are several options.

1a) The APACGrid CA has it's signing policy restricted to issue only certificates within the namespace "/C=AU/O=APACGrid/*" (Country=Australia, Organization=APACGrid).

David suggested to slightly extend what I planned with Andrey, and recommends to issue certificates with

``` 

/C=AU/O=APACGrid/O=BeSTGRID/OU=<name of NZ university>/CN=<full name>

```

E.g, my current certificate is:

/C=AU/O=APACGrid/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl

1b)  David Bannon is been very eager to help, and is willing to adjust their signing policy to also issue certificates for /C=NZ/O=BeSTGRID/*

This would require an approval from Asia-Pacific Policy Management Authority - who have however already expressed a preliminary consent.

Technically, we would be able to use the "NZ" certificates after the updated signing policy is included in the CA certificates bundle and updated at all relevant grid nodes.  I expect this would be a matter of several months.  The NZ certificates would properly reflect the location and affiliation of their holders, and I would recommend this approach in the long term.

A drawback of this approach would be that if we ever decided to establish a separate NZ Certificate Authority (which I see as unlikely), handing the namespace over from APACGrid CA to the new BeSTGRID CA would mean to revoke all the issued certificates.  This is however an unlikely problem.

I would opt for format (1a) in the short term, intending to switch to (1b) once technically feasibly, but I believe this should be agreed by the BeSTGRID Steering Committee.

2) VOMRS / VOMS.

APACGrid have offered us to use their VOMS/VOMRS server (vomrs.apac.edu.au), and have created a BeSTGRID group one the server.  So far, this solution works for us "as good as our one VOMS server would" - membership in the BeSTGRID group is under our control.

The main motivation for this change was that VPAC urged us to focus on the really important tasks first (job submission gateway), focusing on other pieces of infrastructure (GUMS server, VOMRS) after we have the key pieces operational.  They have kindly offered to share their infrastructure in the meantime, and I think we should accept.

3) Grid Operations Center

VPAC has also offered to share their Grid Operations Center - a server that collects status information from all gateway nodes, and presents it in a concise way.  Our servers would be represented there separately as "New Zealand BeSTGRID".

Overall, VPAC have been extremely helpful, willing to help us to have the infrastructure operational soon.  I value their support very much, I hope to stay in touch with them, and I hope to have at least the job submission gateway operational soon.

I think the SC should reach an agreement on what form the certificates should have.  I would also strongly recommend that Anton travels to VPAC soon to also establish contact for himself.

With regards to all of you,

Vladimir
