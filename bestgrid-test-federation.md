# BeSTGRID Test Federation

The BeSTGRID Test Federation exists to test new services before they are put into production.  The federation has an [OpenIdP identity provider](https://openidp.test.bestgrid.org/registry/login.php), a WAYF server, and a number of other services may be included at a time.

The primary source of the federation metadata is at the TEST WAYF server at [https://wayf.test.bestgrid.org/metadata/bestgrid-test-metadata.xml](https://wayf.test.bestgrid.org/metadata/bestgrid-test-metadata.xml).  To change the metadata, edit `/usr/local/shibboleth-wayf/bestgrid-test-metadata.xml` on `wayf.test.bestgrid.org`.  For downloading the metadata, check the WAYF server's certificate, issued by the BeSTGRID CA - the root certificate is included below.

For information on how to update the metadata, please see the page [Updating Federation Metadata](/wiki/spaces/BeSTGRID/pages/3816950858).

# Metadata consistency

When editing the metadata, please keep in mind the following:

- For an IdP, the value of the `KeyName` element in `KeyDescriptors` MUST match the hostname of the IdP.
- For an IdP, the value of `shib:Scope` gives the permitted value of Scope - and MUST be the same for both occurrences in the IDP definition.
- For an IdP, the Artifact resolution services is only accessible via port 8443 - the URL listed for `ArtifactResolutionService` MUST include the port, 8443.

The following inconsistencies were found in the metadata and were fixed on Jan 25, 2008:

- adding the port 8443 to the Artifact resolution service URL for: idp-test.auckland.ac.nz,  openidp.test.bestgrid.org, kilrogg.auckland.ac.nz

## Problems in metadata

There are inconsistencies in the metadata.  At first, one may find that `openidp.test.bestgrid.org` has two entries in the metadata, one with entityId `urn:mace:bestgrid:openidp.test.bestgrid.org` (appearing as correct) and one with `urn:mace:federation.org.au:bestgrid.org` (actually used by the openidp in the BeSTGRID (production) federation).  The second entry appears as if it should be removed - it uses the entityId of the production wiki server, it declares it provides IdP services with URLs of openidp.test, and it declares SP services with URLs of the BeSTGRID test wiki, wiki.test.bestgrid.org. 

However, it's more complicated.  As of 2008-01-31, BeSTGRID openidp.test.bestgrid.org cannot create sessions to plain AAF-L1 services, even though it's a member of AAF-L1.

After examining the AAF level-1 and level-2 metadata, I found that apparently, there is one organization entry for BeSTGRID with bestgrid wiki as a level-2 SP and bestgrid idp-test as a level-1 IdP, both with entityId urn:mace:federation.org.au:bestgrid.org

However, openidp.test thinks of itself as `urn:mace:bestgrid:openidp.test.bestgrid.org` and is registered as such in the bestgrid test federation

There is not a simple solution to the problem.  Obviously, Test OpenIdP cannot have two entityIds at the same time, and has to exist with just one.  However, if it is "`:bestgrid.org`", it would clash with production BeSTGRID IdP (at least for hosts which are in both BeSTGRID federations at the same time).  If it is different, it won't be able to issue attribute scope values "`@bestgrid.org`.  A clean solution would be to use name "`:test.bestgrid.org`" and scope value "`@test.bestgrid.org`".  That would however break testing the Test Wiki with same data against the Test IdP.

We may as well leave it as it is for now, and give up using the Test OpenIdP's membership in AAF L1.  

We will have to come up with a solution if we migrate the metadata to a federation management tool (possibly MAMS federation website).  I consider it as closed for me now - I don't need to login to AAF-L1 services with BeSTGRID Test OpenIdP.

# BeSTGRID CA Root Certificate

The BeSTGRID 

``` 

-----BEGIN CERTIFICATE-----
MIIDXDCCAsWgAwIBAgIBADANBgkqhkiG9w0BAQUFADCBgTEUMBIGA1UEAxMLYmVz
dGdyaWQtQ0ExCzAJBgNVBAYTAk5aMREwDwYDVQQHEwhBdWNrbGFuZDERMA8GA1UE
CxMIQmVTVEdSSUQxNjA0BgNVBAoTLUJyb2FkYmFuZCBlbmFibGVkIFNjaWVuY2Ug
YW5kIFRlY2hub2xvZ3kgR1JJRDAeFw0wNzA1MjQwMzI3MDVaFw0xNzA1MjEwMzI3
MDVaMIGBMRQwEgYDVQQDEwtiZXN0Z3JpZC1DQTELMAkGA1UEBhMCTloxETAPBgNV
BAcTCEF1Y2tsYW5kMREwDwYDVQQLEwhCZVNUR1JJRDE2MDQGA1UEChMtQnJvYWRi
YW5kIGVuYWJsZWQgU2NpZW5jZSBhbmQgVGVjaG5vbG9neSBHUklEMIGfMA0GCSqG
SIb3DQEBAQUAA4GNADCBiQKBgQCzaWPv4iN2UvAwllyBdZ3Of+0GvxPubwpAgLs6
rYNYRTQpa28BOyPsKOH6zIu25Nvv2kYw3ZAtqTreRCy8Kb+hAtDNjtJRBvyGD3uj
sogV1CXZGjXhzzcPkLBRkjpfTnGparLh1tqtkWPXiWu3JmMuCZt70YvQlJX+TK0p
5q0kywIDAQABo4HhMIHeMB0GA1UdDgQWBBTJaWDM6hxoNXz3Tr67tArck/PZDTCB
rgYDVR0jBIGmMIGjgBTJaWDM6hxoNXz3Tr67tArck/PZDaGBh6SBhDCBgTEUMBIG
A1UEAxMLYmVzdGdyaWQtQ0ExCzAJBgNVBAYTAk5aMREwDwYDVQQHEwhBdWNrbGFu
ZDERMA8GA1UECxMIQmVTVEdSSUQxNjA0BgNVBAoTLUJyb2FkYmFuZCBlbmFibGVk
IFNjaWVuY2UgYW5kIFRlY2hub2xvZ3kgR1JJRIIBADAMBgNVHRMEBTADAQH/MA0G
CSqGSIb3DQEBBQUAA4GBAHxbmAO03zsBkV9Rzg1DTKSd7sVOBh8BPDbhYDhHZFF0
695emFV48chUFzK7clurefYABp9b7wXnVCFqv3HF3fvaUEa+EOMZVVom3l/zXp7m
GvQLqh2JDUY6xs010vqeKaB3gJee9HoSVzhFnjzqYhtki6G2sQZu8SW9f/FH/9eh
-----END CERTIFICATE-----

```
